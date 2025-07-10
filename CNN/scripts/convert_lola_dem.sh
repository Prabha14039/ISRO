#!/bin/bash
set -e

LBL="DEM/LDEM_80S_20M.LBL"
IMG="DEM/LDEM_80S_20M.IMG"
CUB="DEM_cub/ldem_80s_20m.cub"

mkdir -p DEM_cub

echo "📥 Converting LOLA IMG + LBL to .cub..."
pds2isis from=$LBL to=$CUB

