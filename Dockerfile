# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
ARG LIGHTBURN_VERSION
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="medoix"

# title
ENV TITLE=LightBurn \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://lightburnsoftware.com/cdn/shop/files/lightburn-square.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    firefox-esr \
    fonts-dejavu \
    fonts-dejavu-extra \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-qt5 \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    libgstreamer1.0 \
    libgstreamer-plugins-bad1.0 \
    libgstreamer-plugins-base1.0 \
    libosmesa6 \
    libwebkit2gtk-4.0-37 \
    libwx-perl

RUN \
  echo "**** install lightburn from appimage ****" && \
  LATEST_FILE=$(curl -sX GET "https://release.lightburnsoftware.com/LightBurn/Release/latest/" | grep -oP '/.*\.AppImage' | head -n 1) && \
  DOWNLOAD_URL="https://release.lightburnsoftware.com${LATEST_FILE}" && \
  echo "${DOWNLOAD_URL}" && \

  cd /tmp && \
  curl -o \
    /tmp/lightburn.app -L \
    "${DOWNLOAD_URL}" && \
  chmod +x /tmp/lightburn.app && \
  ./lightburn.app --appimage-extract && \
  mv squashfs-root /opt/lightburn && \
  localedef -i en_GB -f UTF-8 en_GB.UTF-8 && \
  printf "Version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config