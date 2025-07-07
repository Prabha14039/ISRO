#!/bin/bash
set -e

echo "🔧 Running parallel bundle adjustment..."

parallel_bundle_adjust                           \
  --image-list bundle_para/image_list.txt        \
  --camera-list bundle_para/camera_list.txt      \
  --processes 4                                  \
  --ip-per-image 20000                           \
  --overlap-limit 200                            \
  --num-iterations 100                           \
  --num-passes 2                                 \
  --min-matches 1                                \
  --max-pairwise-matches 2000                    \
  --camera-weight 0                              \
  --robust-threshold 2                           \
  --tri-weight 0.05                              \
  --tri-robust-threshold 0.05                    \
  --remove-outliers-params "75.0 3.0 100 100"    \
  --save-intermediate-cameras                    \
  --match-first-to-last                          \
  --min-triangulation-angle 1e-10                \
  --datum D_MOON                                 \
  -o ba/run

