#!/bin/sh

MOD_LINKS_FILE=$1
HEADLESSDIR=${STEAMAPPDIR}/Headless

mkdir -p \
    ${HEADLESSDIR}/Libraries \
    ${HEADLESSDIR}/rml_libs \
    ${HEADLESSDIR}/rml_mods

curl -L -o ${HEADLESSDIR}/Libraries/ResoniteModLoader.dll \
    https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/ResoniteModLoader.dll
curl -L -o ${HEADLESSDIR}/rml_libs/0Harmony-Net8.dll \
    https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/0Harmony-Net8.dll

# MODリンクのファイルを読み込んで、各リンクからMODをダウンロードする
while IFS= read -r mod_url; do
    # 空行やコメント行を無視
    if [[ -z "$mod_url" || "$mod_url" == \#* ]]; then
        continue
    fi
    echo "Downloading MOD from $mod_url..."
    curl -L -o "${HEADLESSDIR}/rml_mods/$(basename $mod_url)" "$mod_url"
done < "$MOD_LINKS_FILE"
