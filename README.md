# linux-in-practice-log

『[試して理解]Linuxのしくみ 増補改訂版』（武内覚）を読みながら、実験を実際に走らせて確かめた記録。
本文の要約ではなく、**手元で出た数値と、そこから分かったこと**を残している。

教材のサンプルコード: [satoru-takeuchi/linux-in-practice-2nd](https://github.com/satoru-takeuchi/linux-in-practice-2nd)

## 記録

| 章 | 内容 |
|---|---|
| [2章 プロセス管理（基礎編）](notes/02-process-management-1.md) | fork / execve / 実行ファイルの構造 / 仮想記憶の2階層 |

## 実験環境

母艦は macOS (Apple Silicon)。`/proc` も `strace` も存在せず、実行ファイルが ELF ではなく Mach-O になるため、Docker で Ubuntu 20.04 の環境を用意している。

このリポジトリの `Dockerfile` と `compose.yaml` を**教材リポジトリのルートに置いて**使う。

```bash
git clone https://github.com/satoru-takeuchi/linux-in-practice-2nd.git
cd linux-in-practice-2nd
cp /path/to/this-repo/{Dockerfile,compose.yaml} .

docker compose run --rm x86    # 通常はこちら
docker compose run --rm arm    # strace を使うときだけこちら
```

カレントディレクトリが `/work` にマウントされるので、ホスト側で編集したファイルがそのまま動く。

### アーキテクチャを2つ用意している理由

本は x86_64 前提で書かれているので、Apple Silicon 上でも `platform: linux/amd64` で動かせばシステムコール番号などが本文と一致する。ところが**エミュレーション環境では `strace` が動かない**。

```
strace: test_ptrace_get_syscall_info: PTRACE_TRACEME: Function not implemented
```

QEMU が `ptrace` を実装していないためで、権限や seccomp の問題ではない。そこで両方をサービスとして定義し、使い分けている。

| | `x86`（エミュレーション） | `arm`（ネイティブ） |
|---|---|---|
| 本文との一致 | 一致（`execve`=59, `-no-pie` が効く） | 不一致（`execve`=221） |
| `strace` | 動かない | 動く |
| 速度 | 遅い | 速い |

仮想化関連パッケージ（qemu-kvm, libvirt）は、コンテナから KVM を触れないため入れていない。10章に入るときは VM を立てる必要がある。

## macOS での制約

実験を進める中で、教材が使うのに Docker イメージへ入れていなかったコマンドが判明したものは Dockerfile に追加している（`file`, `pstree`, `lsof`, `mkfs.ext4`, `bc`, `man`）。`perf`（3章）はコンテナからカーネルの性能イベントを参照できないため入れておらず、必要になった時点で VM を立てる方針。

Docker に移行する前、母艦で直接試して詰まった点。同じ環境の人向けのメモ。

| 症状 | 原因と対処 |
|---|---|
| `cc: error: unknown option '-o'` | `cc` が別のコマンドのエイリアスになっていた。コンパイラに届いていない。`\cc` か `clang` で回避 |
| `zsh: command not found: readelf` | macOS に readelf はない。そもそも対象が ELF ではなく Mach-O なので入れても読めない。`otool -h` / `otool -l` が対応するツール |
| `warning: argument unused: '-no-pie'` | Apple Silicon は PIE 必須のため無視される。アドレスを固定して観察したいなら Linux 環境が要る |
| `strace: PTRACE_TRACEME: Function not implemented` | QEMU エミュレーション下では ptrace が使えない。arm64 ネイティブのコンテナに切り替える |
| パイプに繋ぐと出力が消える | バッファに溜まった内容が `execve` でメモリごと破棄される。`python3 -u` か exec 前のフラッシュで回避 |
