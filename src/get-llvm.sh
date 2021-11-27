#!/bin/bash
set -ex

export DISTRO_FANCYNAME="$(lsb_release -c | awk '{ print $2 }')"
curl -sL http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -

if [[ "$CONFIGURED_LLVM_VERSION" == "latest" ]]; then
  sudo add-apt-repository -y "deb http://apt.llvm.org/$DISTRO_FANCYNAME/ llvm-toolchain-$DISTRO_FANCYNAME main"
  # Get the largest Clang package number available.
  export LLVM_VER="$(apt-cache search --full 'clang-[[:digit:]]*$' | grep '^Package: clang' | cut -d ' ' -f 2 | sort -V | tail -n 1 | sed 's/clang-//')"
else
  sudo add-apt-repository -y "deb http://apt.llvm.org/$DISTRO_FANCYNAME/ llvm-toolchain-$DISTRO_FANCYNAME-$CONFIGURED_LLVM_VERSION main"
  export LLVM_VER="$CONFIGURED_LLVM_VERSION"
fi

sudo apt-get -y --no-install-recommends install \
  clang-$LLVM_VER      \
  clang-tidy-$LLVM_VER
sudo update-alternatives --install                   \
  /usr/bin/clang clang /usr/bin/clang-$LLVM_VER 1000 \
  --slave                                            \
    /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-$LLVM_VER
update-alternatives --query clang
