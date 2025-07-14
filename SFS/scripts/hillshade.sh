
#!/bin/bash
set -e

# Default values
INPUT=""
OUTPUT=""
AZIMUTH=""
ELEVATION=""
FINAL=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --in)
            INPUT="$2"
            shift 2
            ;;
        --out)
            OUTPUT="$2"
            shift 2
            ;;
        --azi)
            AZIMUTH="$2"
            shift 2
            ;;
        --ele)
            ELEVATION="$2"
            shift 2
            ;;
        --fin)
            FINAL="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 --in path --out path --azi path --ele value --fin value"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate input
if [[ -z "$INPUT" || -z "$ELEVATION" || -z "$OUTPUT" || -z "$AZIMUTH" ]]; then
    echo "❗ Missing required arguments"
    echo "Usage: $0 --in path --out path --azi path --ele value --fin value"
    exit 1
fi

mkdir -p Dataset/tif

hillshade --azimuth "$AZIMUTH" --elevation "$ELEVATION" "$INPUT" -o "$OUTPUT"
gdal_translate -b 1 "$OUTPUT" "$FINAL"




