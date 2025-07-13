#!/bin/bash
set -e

CUB_FOLDER=""
JSON_FOLDER=""

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --cub_folder)
            CUB_FOLDER="$2"
            shift 2
            ;;
        --json_folder)
            JSON_FOLDER="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 --cub_folder path --json_folder path"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate input
if [[ -z "$CUB_FOLDER" || -z "$JSON_FOLDER" ]]; then
    echo "❗ Missing required arguments"
    echo "Usage: $0 --cub_folder path --json_folder path"
    exit 1
fi

mkdir -p "$JSON_FOLDER"

for cub in "$CUB_FOLDER"/*.cub; do
    base=$(basename "$cub" .cub)
    json="$JSON_FOLDER/$base.json"
    echo "📝 Generating ISD for $cub → $json"
    isd_generate -o "$json" "$cub"
done

