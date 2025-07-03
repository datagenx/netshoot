#!/usr/bin/env bash
set -euo pipefail

hash jq >/dev/null 2>&1 || (echo "install jq" && exit 131)

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
     jq -r '.tag_name'                                          # Get tag
}

get_latest_assets_list() {
  curl -s  https://api.github.com/repos/$1/releases/latest | jq -r '.assets[].name'
}

ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH=amd64
        ;;
    aarch64)
        ARCH=arm64
        ;;
esac

OS=$(uname)
case $OS in 
  Darwin)
    OS=darwin
    ;;
  Linux)
    OS=linux
    ;;
esac

bin_dir=/tmp/${ARCH}
mkdir -p ${bin_dir}

get_ctop() {
  local file VERSION LINK
  VERSION=$(get_latest_release bcicen/ctop)
  file=$(get_latest_assets_list bcicen/ctop | grep "linux-${ARCH}\$")
  LINK="https://github.com/bcicen/ctop/releases/download/${VERSION}/${file}"

  echo "Downloading ctop $VERSION from $LINK"
  wget "$LINK" -O ${bin_dir}/ctop && chmod +x ${bin_dir}/ctop
  [ "$OS" == "linux" ] && ${bin_dir}/ctop -h
}

get_calicoctl() {
  local file TERM_ARCH VERSION LINK
  VERSION=$(get_latest_release projectcalico/calico)
  file=$(get_latest_assets_list projectcalico/calico | grep calicoctl-linux-${ARCH})
  LINK="https://github.com/projectcalico/calico/releases/download/${VERSION}/${file}"

  echo "Downloading calico $VERSION from $LINK"
  wget "$LINK" -O ${bin_dir}/calicoctl && chmod +x ${bin_dir}/calicoctl
  [ "$OS" == "linux" ] && ${bin_dir}/calicoctl version
}

get_termshark() {
  local file TERM_ARCH VERSION LINK
  case "$ARCH" in
    *)
      VERSION=$(get_latest_release gcla/termshark)
      if [ "$ARCH" == "amd64" ]; then
        TERM_ARCH=x64
      else
        TERM_ARCH="$ARCH"
      fi

      file=$(get_latest_assets_list gcla/termshark | grep linux_${TERM_ARCH}.tar.gz)
      LINK="https://github.com/gcla/termshark/releases/download/${VERSION}/${file}"

      echo "Downloading termshark $VERSION from $LINK"
      wget "$LINK" -O /tmp/termshark.tar.gz && \
      tar -zxvf /tmp/termshark.tar.gz --strip-components=1 -C ${bin_dir}
      chmod +x ${bin_dir}/termshark
      [ "$OS" == "linux" ] && ${bin_dir}/termshark -h
      ;;
  esac
}

get_grpcurl() {
  local file TERM_ARCH VERSION LINK
  if [ "$ARCH" == "amd64" ]; then
    TERM_ARCH=x86_64
  else
    TERM_ARCH="$ARCH"
  fi
  VERSION=$(get_latest_release fullstorydev/grpcurl )
  file=$(get_latest_assets_list fullstorydev/grpcurl | grep linux_${TERM_ARCH}.tar.gz)
  LINK="https://github.com/fullstorydev/grpcurl/releases/download/${VERSION}/${file}"

  echo "Downloading grpcurl $VERSION from $LINK"
  wget "$LINK" -O /tmp/grpcurl.tar.gz  && \
  tar --no-same-owner -zxvf /tmp/grpcurl.tar.gz grpcurl && \
  mv "grpcurl" ${bin_dir}/grpcurl && \
  chmod a+x ${bin_dir}/grpcurl
  [ "$OS" == "linux" ] && ${bin_dir}/grpcurl -version
}

get_fortio() {
    local file TERM_ARCH VERSION LINK
  if [ "$ARCH" == "amd64" ]; then
    TERM_ARCH=x86_64
  else
    TERM_ARCH="$ARCH"
  fi
  VERSION=$(get_latest_release fortio/fortio)
  file=$(get_latest_assets_list fortio/fortio | grep -E "linux_${ARCH}-.+.tgz")
  LINK="https://github.com/fortio/fortio/releases/download/${VERSION}/${file}"

  echo "Downloading fortio $VERSION from $LINK"
  wget "$LINK" -O /tmp/fortio.tgz  && \
  tar -zxvf /tmp/fortio.tgz usr/bin/fortio --strip-components=2 && \
  mv fortio ${bin_dir}/fortio && \
  chmod +x ${bin_dir}/fortio
  [ "$OS" == "linux" ] && ${bin_dir}/fortio version
}


get_ctop
get_calicoctl
get_termshark
get_grpcurl
get_fortio

ls -l ${bin_dir}