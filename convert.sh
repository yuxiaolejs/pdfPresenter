#!/bin/bash
set -eo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <input.pdf> [dpi]"
  echo "Example: $0 presentation.pdf 150"
  exit 1
fi
FILE_BASE_NAME=$(basename "$1" .pdf)
DPI=${2:-600}
DEST_FOLDER=dist/${FILE_BASE_NAME}
echo "Converting $1 to images in $DEST_FOLDER ..."
rm -rf $DEST_FOLDER
mkdir -p $DEST_FOLDER
mkdir -p $DEST_FOLDER/s
pdftoppm -png -r ${DPI} $1 ./${DEST_FOLDER}/s/out
for img in ${DEST_FOLDER}/s/out-*.png; do
  ffmpeg -i "$img" -vcodec libwebp -lossless 1 -qscale 75 -preset default -an -vsync 0 "${img%.png}.webp" 2>/dev/null
  rm "$img"
done
FILE_LIST=$(ls ${DEST_FOLDER}/s/out-* | xargs -n 1 basename | jq -R . | jq -s .)
cat > $DEST_FOLDER/slide.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Slide Show</title>
    <style>
        body {
            margin: 0;
            background-color: #000;
            overflow: hidden;
        }
        img {
            width: 100vw;
            height: 100vh;
            object-fit: contain;
        }
    </style>
</head>
<body>
    <img />
</body>
<script>
    let currentIndex = 0
    let slideList = ${FILE_LIST}
    function loadSlide(index) {
        document.querySelector("img").src = \`./s/\${slideList[index]}\`
        currentIndex = index
    }
    function nextSlide() {
        if (currentIndex < slideList.length - 1)
            loadSlide(currentIndex + 1)
    }
    function prevSlide() {
        if (currentIndex > 0)
            loadSlide(currentIndex - 1)
    }
    function toggleFullScreen() {
        if (!document.fullscreenElement) {
            document.documentElement.requestFullscreen();
        } else if (document.exitFullscreen) {
            document.exitFullscreen();
        }
    }
    document.querySelector("img").onclick = nextSlide
    document.onkeydown = (e) => {
        if (e.key === "ArrowRight" || e.key === " " || e.key === "Enter" || e.key === "ArrowDown")
            nextSlide()
        else if (e.key === "ArrowLeft" || e.key === "ArrowUp" || e.key === "Backspace")
            prevSlide()
        else if (e.key === "Escape")
            window.electron.send("exit")
        else if (e.key === "f")
            toggleFullScreen()

    }
    document.onwheel = (e) => {
        (e.deltaY > 0 ? nextSlide : prevSlide)()
    }
    loadSlide(0)
</script>
</html>
EOF