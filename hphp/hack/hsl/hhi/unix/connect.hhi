<?hh
// @generated from implementation

/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Unix;

use namespace HH\Lib\{Network, OS};
use namespace HH\Lib\_Private\{_Network, _Unix};

/** Asynchronously connect to the specified unix socket. */
async function connect_async(
  string $path,
  ConnectOptions $opts = shape(),
): Awaitable<CloseableSocket> ;
<<__Deprecated('use connect_async() instead')>>
async function connect_nd_async(
  string $path,
  ConnectOptions $opts,
): Awaitable<CloseableSocket> ;
