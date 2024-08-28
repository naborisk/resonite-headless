FROM ubuntu

LABEL name=resonite-headless org.opencontainers.image.authors="panther.ru@gmail.com"

ENV STEAMAPPID=2519830 \
    STEAMAPP=resonite \
    STEAMCMDURL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
    STEAMCMDDIR=/opt/steamcmd \
    STEAMBETA=__CHANGEME__ \
    STEAMBETAPASSWORD=__CHANGEME__ \
    STEAMLOGIN=__CHANGEME__ \
    USER=2000 \
    HOMEDIR=/home/steam
ENV STEAMAPPDIR="${HOMEDIR}/${STEAMAPP}-headless"

# Prepare the basic environment
RUN set -x && \
    apt -y update && \
    apt -y upgrade && \
    apt -y install curl lib32gcc-s1 libopus-dev libopus0 opus-tools libc6-dev dotnet-runtime-8.0 ca-certificates gnupg && \
    rm -rf /var/lib/{apt,dpkg,cache}

RUN gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

RUN echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official-stable.list

RUN apt update && apt install -y mono-devel

# Add locales
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    update-locale LANG=en_GB.UTF-8 && \
    rm -rf /var/lib/{apt,dpkg,cache}
ENV LANG en_GB.UTF-8

# Create user, install SteamCMD
RUN groupadd --gid ${USER} steam && \
    useradd --home-dir ${HOMEDIR} \
        --create-home \
        --shell /bin/bash \
        --comment "" \
        --gid ${USER} \
        --uid ${USER} \
        steam && \
    mkdir -p ${STEAMCMDDIR} ${STEAMAPPDIR} /Config /Logs /Scripts /home/steam/resonite-headless/Libraries /home/steam/resonite-headless/rml_libs /home/steam/resonite-headless/rml_mods && \
    cd ${STEAMCMDDIR} && \
    curl -sqL ${STEAMCMDURL} | tar zxfv - && \
    chown -R ${USER}:${USER} ${STEAMCMDDIR} ${STEAMAPPDIR} /Config /Logs /home/steam/resonite-headless/Libraries /home/steam/resonite-headless/rml_libs /home/steam/resonite-headless/rml_mods

# ResoniteModLoaderの導入
RUN wget -P /home/steam/resonite-headless/Libraries https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/ResoniteModLoader.dll && \
    wget -P /home/steam/resonite-headless/rml_libs https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/0Harmony-Net8.dll && \

# MODリンクを管理するファイルとダウンロードスクリプトを追加
COPY --chown=${USER}:${USER} --chmod=755 ./src/download_mods.sh /Scripts/download_mods.sh
COPY --chown=${USER}:${USER} ./src/default_mod_links.txt /home/steam/resonite-headless/default_mod_links.txt

# デフォルトのMODをダウンロード
RUN /Scripts/download_mods.sh /home/steam/resonite-headless/default_mod_links.txt

COPY --chown=${USER}:${USER} --chmod=755 ./src/setup_resonite.sh ./src/start_resonite.sh /Scripts/

# Switch to user
USER ${USER}

WORKDIR ${STEAMAPPDIR}

VOLUME ["${STEAMAPPDIR}", "/Config", "/Logs"]

STOPSIGNAL SIGINT

ENTRYPOINT ["/Scripts/setup_resonite.sh"]
CMD ["/Scripts/start_resonite.sh"]
