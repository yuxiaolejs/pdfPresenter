#!/bin/bash
set -eo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <input.pdf> <task_name> <output_dir>"
  echo "Example: $0 presentation.pdf presentation output"
  exit 1
fi

IMAGE_DIR=${2:-./Slides}
rm -rf $IMAGE_DIR
mkdir -p $IMAGE_DIR
pdftoppm -png -r 600 $1 ./${IMAGE_DIR}/out
node convert.js $IMAGE_DIR $3