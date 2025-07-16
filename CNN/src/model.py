import torch
import torch.nn as nn
from torchvision.models import resnet50

# -------------------------------
# 1. Basic Decoder Block
# -------------------------------
class UpBlock(nn.Module):
    def __init__(self, in_c, skip_c, out_c):
        super().__init__()
        self.up = nn.ConvTranspose2d(in_c, out_c, kernel_size=2, stride=2)
        self.conv = nn.Sequential(
            nn.Conv2d(skip_c + out_c, out_c, kernel_size=3, padding=1),
            nn.BatchNorm2d(out_c),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_c, out_c, kernel_size=3, padding=1),
            nn.BatchNorm2d(out_c),
            nn.ReLU(inplace=True),
        )

    def forward(self, x, skip):
        x = self.up(x)
        x = torch.cat([x, skip], dim=1)
        return self.conv(x)

# -------------------------------
# 2. Fuse Block
# -------------------------------
class FuseBlock(nn.Module):
    def __init__(self, nac_c, dem_c, out_c):
        super().__init__()
        self.fuse = nn.Sequential(
            nn.Conv2d(nac_c + dem_c, out_c, kernel_size=1),
            nn.ReLU(inplace=True)
        )

    def forward(self, nac, dem):
        x = torch.cat([nac, dem], dim=1)
        return self.fuse(x)

# -------------------------------
# 3. DEM Encoder (Simple Blocks)
# -------------------------------
class DownBlock(nn.Module):
    def __init__(self, in_c, out_c):
        super().__init__()
        self.encode = nn.Sequential(
            nn.Conv2d(in_c, out_c, 3, stride=2, padding=1),
            nn.BatchNorm2d(out_c),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_c, out_c, 3, padding=1),
            nn.BatchNorm2d(out_c),
            nn.ReLU(inplace=True)
        )

    def forward(self, x):
        return self.encode(x)

# -------------------------------
# 4. NAC Encoder (ResNet-50)
# -------------------------------
class ResNetEncoder(nn.Module):
    def __init__(self, pretrained=True):
        super().__init__()
        resnet = resnet50(pretrained=pretrained)

        # Change input to 1-channel
        self.conv1 = nn.Conv2d(1, 64, kernel_size=7, stride=2, padding=3, bias=False)
        self.conv1.weight.data = resnet.conv1.weight.data.sum(dim=1, keepdim=True) / 3.0

        self.bn1 = resnet.bn1
        self.relu = resnet.relu
        self.maxpool = resnet.maxpool

        self.layer1 = resnet.layer1  # 256
        self.layer2 = resnet.layer2  # 512
        self.layer3 = resnet.layer3  # 1024

    def forward(self, x):
        skips = []

        x = self.conv1(x)
        x = self.bn1(x)
        x = self.relu(x)
        skips.append(x)        # 64

        x = self.maxpool(x)
        x = self.layer1(x)
        skips.append(x)        # 256

        x = self.layer2(x)
        skips.append(x)        # 512

        x = self.layer3(x)
        skips.append(x)        # 1024

        return x, skips

# -------------------------------
# 5. Full DualEncoderUNet Model
# -------------------------------
class DualEncoderUNet(nn.Module):
    def __init__(self):
        super().__init__()

        # NAC (ResNet-50 encoder)
        self.nac_encoder = ResNetEncoder()

        # DEM Encoder (Custom)
        self.dem_enc1 = DownBlock(1, 64)
        self.dem_enc2 = DownBlock(64, 256)
        self.dem_enc3 = DownBlock(256, 512)
        self.dem_enc4 = DownBlock(512, 1024)

        # Fusi
        self.fuse = FuseBlock(2048, 1024, 1024)

        # Decoder
        self.up4 = UpBlock(1024, 1024, 512)
        self.up3 = UpBlock(512, 512, 256)
        self.up2 = UpBlock(256, 256, 128)
        self.up1 = nn.ConvTranspose2d(128, 64, kernel_size=2, stride=2)
        self.out = nn.Conv2d(64, 1, kernel_size=1)

    def forward(self, nac, dem):
        # NAC path (ResNet)
        nac_out, nac_skips = self.nac_encoder(nac)

        # DEM path (custom)
        d1 = self.dem_enc1(dem)     # 64
        d2 = self.dem_enc2(d1)      # 256
        d3 = self.dem_enc3(d2)      # 512
        d4 = self.dem_enc4(d3)      # 1024

        # Fuse deepest layer
        fused = self.fuse(nac_out, d4)

        # Decoder
        x = self.up4(fused, nac_skips[3])  # skip = 1024
        x = self.up3(x, nac_skips[2])      # skip = 512
        x = self.up2(x, nac_skips[1])      # skip = 256
        x = self.up1(x)                    # upsample to original
        return self.out(x)

