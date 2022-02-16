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

namespace HH\Lib\TCP;

use namespace HH\Lib\{Network, OS};
use namespace HH\Lib\_Private\{_Network, _OS, _TCP};

/** Connect to a socket asynchronously, returning a non-disposable handle.
 *
 * If using IPv6 with a fallback to IPv4 with a connection timeout, the timeout
 * will apply separately to the IPv4 and IPv6 connection attempts.
 */
async function connect_async(
  string $host,
  int $port,
  ConnectOptions $opts = shape(),
): Awaitable<CloseableSocket> ;
<<__Deprecated("Use connect_async() instead")>>
async function connect_nd_async(
  string $host,
  int $port,
  ConnectOptions $opts = shape(),
): Awaitable<CloseableSocket> ;
