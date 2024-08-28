#!/bin/bash

MOD_DIR="/home/steam/resonite-headless/rml_mods"
LINKS_FILE=$1

# リンクファイルからURLを読み込み、MODをダウンロード
if [ -f "$LINKS_FILE" ]; then
    while IFS= read -r url; do
        if [ ! -z "$url" ]; then
            wget -P $MOD_DIR $url
        fi
    done < "$LINKS_FILE"
else
    echo "リンクファイルが見つかりません: $LINKS_FILE"
fi
