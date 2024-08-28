#!/bin/bash

MOD_LINKS_FILE=$1

# MODリンクのファイルを読み込んで、各リンクからMODをダウンロードする
while IFS= read -r mod_url; do
    # 空行やコメント行を無視
    if [[ -z "$mod_url" || "$mod_url" == \#* ]]; then
        continue
    fi
    
    echo "Downloading MOD from $mod_url..."
    curl -L -o "/home/steam/resonite-headless/rml_mods/$(basename $mod_url)" "$mod_url"
done < "$MOD_LINKS_FILE"
