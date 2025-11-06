#!/bin/bash
set -exo pipefail

IMAGE_DIR=${2:-./Slides}
rm -rf $IMAGE_DIR
mkdir -p $IMAGE_DIR
pdftoppm -png -r 600 $1 ./${IMAGE_DIR}/out
node convert.js $IMAGE_DIR $3