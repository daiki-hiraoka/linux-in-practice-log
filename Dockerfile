# 「Linuxのしくみ 増補改訂版」実験環境
# 本文が x86_64 前提で書かれているため、Apple Silicon 上でも amd64 で動かす
FROM ubuntu:20.04

# apt が対話プロンプト（タイムゾーン選択など）で止まらないようにする
ENV DEBIAN_FRONTEND=noninteractive

# Ubuntu の公式イメージは man ページを展開しない設定になっているため解除する。
# apt-get install より前に実行しないと、入れたパッケージの man が読めない。
RUN [ -f /etc/dpkg/dpkg.cfg.d/excludes ] && sed -i '/path-exclude/d' /etc/dpkg/dpkg.cfg.d/excludes || true

# README 記載のパッケージのうち、コンテナ内で意味を持つものを入れる。
# 除外したもの:
#   qemu-kvm / libvirt / virt-manager … macOS 上のコンテナから KVM を触れない（10章）
#   linux-tools (perf)                … コンテナからカーネルの性能イベントを見られない（3章）
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
      psmisc \
      lsof \
      bc \
      e2fsprogs \
      man-db \
      manpages \
      util-linux \
      time \
      less \
      vim \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work
CMD ["/bin/bash"]
