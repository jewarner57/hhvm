#!/bin/sh
# Copyright (c) 2019, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the "hack" directory of this source tree.

# Do not use this file directly - either use dev_env.sh or dev_env_rust_only.sh

export CMAKE_SOURCE_DIR="/home/ubuntu/hhvm"
export CMAKE_INSTALL_FULL_SYSCONFDIR="/usr/local/etc"
export CMAKE_INSTALL_FULL_BINDIR="/usr/local/bin"

export HACK_NO_CARGO_VENDOR=true
export OPAMROOT="/home/ubuntu/hhvm/hphp/hack/_build/opam"
export PYTHONPATH="/home/ubuntu/hhvm" # needed for verify.py for `hack_dune_test`
export CARGO_HOME="/home/ubuntu/hhvm/hphp/hack/_build/cargo_home"
export RUSTC="/home/ubuntu/hhvm/third-party/rustc/bundled_rust-prefix/bin/rustc"
export DUNE_BUILD_DIR="/home/ubuntu/hhvm/hphp/hack/_build"
export HACK_SOURCE_ROOT="/home/ubuntu/hhvm/hphp/hack"
export HACK_BUILD_ROOT="/home/ubuntu/hhvm/hphp/hack/_build/default"
export HACK_BIN_DIR="/home/ubuntu/hhvm/hphp/hack/bin"
export PATH="/home/ubuntu/hhvm/third-party/rustc/bundled_rust-prefix/bin:/home/ubuntu/hhvm/third-party/rustc/bundled_rust-prefix/bin:$(dirname "/home/ubuntu/hhvm/third-party/opam/opamDownload-prefix/opam"):$PATH"

export HACK_EXTRA_INCLUDE_PATHS="/home/ubuntu/hhvm;/home/ubuntu/hhvm/third-party/lz4/bundled_lz4-prefix/include;/home/ubuntu/hhvm/third-party/zstd/bundled_zstd-prefix/include;/usr/include"
export HACK_EXTRA_LINK_OPTS="/home/ubuntu/hhvm/third-party/lz4/bundled_lz4-prefix/lib/liblz4.a;/home/ubuntu/hhvm/third-party/zstd/bundled_zstd-prefix/lib/libzstd.a"
export HACK_EXTRA_LIB_PATHS="/usr/lib/x86_64-linux-gnu"
export HACK_EXTRA_NATIVE_LIBRARIES="sqlite3"
