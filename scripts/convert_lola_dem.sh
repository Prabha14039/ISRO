#!/bin/bash
set -e

LBL="DEM/LDEM_80S_20M.LBL"
IMG="DEM/LDEM_80S_20M.IMG"
CUB="dem_cub/ldem_80s_20m.cub"

mkdir -p dem_cub

echo "📥 Converting LOLA IMG + LBL to .cub..."
pds2isis from=$LBL to=$CUB

