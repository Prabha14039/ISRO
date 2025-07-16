import torch
import torch.nn as nn
from torchvision.models import resnet50


class DemEncoder(nn.Module):
    def __init__(self, in_channels, out_channels):
        super().__init__()
        self.sldem_encoder = nn.Sequential(
            nn.Conv2d(in_c, out_channels, 3, stride=2, padding=1),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_channels, out_channels, 3, padding=1),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True)
        )

    def forward(self, x):
        return self.sldem_encoder(x)

class NacEncoder(nn.Module):
    def __init__(self, pretrained=True):
        super().__init__()
        resnet = resnet50(pretrained=pretrained)

