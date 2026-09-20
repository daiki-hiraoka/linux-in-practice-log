# 「Linuxのしくみ 増補改訂版」実験環境
# 本文が x86_64 前提で書かれているため、Apple Silicon 上でも amd64 で動かす
FROM ubuntu:20.04

# apt が対話プロンプト（タイムゾーン選択など）で止まらないようにする
ENV DEBIAN_FRONTEND=noninteractive

# README 記載のパッケージのうち、コンテナ内で意味を持つものを入れる。
# qemu-kvm / libvirt / virt-manager（10章の仮想化実験）は、
# macOS 上のコンテナからは KVM を触れないため除外している。
RUN apt-get update && apt-get install -y --no-install-recommends \
      binutils \
      file \
      build-essential \
      golang \
      sysstat \
      python3-matplotlib \
      python3-pil \
      fonts-takao \
      fio \
      jq \
      strace \
      ltrace \
      procps \
      util-linux \
      time \
      less \
      vim \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work
CMD ["/bin/bash"]
