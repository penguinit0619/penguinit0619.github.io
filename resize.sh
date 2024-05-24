#!/bin/bash

# 첫 번째 인자로 타겟 폴더를 입력받습니다. 예: 202405-1
TARGET=$1

# 타겟 폴더 경로를 설정합니다.
TARGET_DIR="content/post/${TARGET//-//}/"

# images 폴더와 index.md 파일이 존재하는지 확인합니다.
if [ ! -d "${TARGET_DIR}images" ] || [ ! -f "${TARGET_DIR}index.md" ]; then
    echo "images 폴더 또는 index.md 파일이 ${TARGET_DIR}에 존재하지 않습니다."
    exit 1
fi

# images 폴더 내의 PNG 파일을 가로 1024픽셀로 리사이즈하고, 새로운 파일명에 _1024px suffix를 추가합니다.
for IMG in ${TARGET_DIR}images/*.png; do
    BASENAME=$(basename "$IMG" .png)
    NEW_IMG="${TARGET_DIR}images/${BASENAME}_1024px.png"
    convert "$IMG" -resize 1024x "$NEW_IMG"
done

# index.md 파일 내의 이미지 파일명을 업데이트합니다.
sed -i '' 's/\.png/_1024px.png/g' "${TARGET_DIR}index.md"

echo "작업이 완료되었습니다."
