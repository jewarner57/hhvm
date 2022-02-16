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

namespace HH\Lib\_Private\_Network;

use namespace HH\Lib\OS;
use namespace HH\Lib\_Private\_OS;

/** Asynchronously connect to a socket.
 *
 * Returns a PHP Socket Error Code:
 * - 0 for success
 * - errno if > 0
 * - -(10000 + h_errno) if < 0
 */
async function socket_connect_async(
  OS\FileDescriptor $sock,
  OS\sockaddr $sa,
  int $timeout_ns,
): Awaitable<void> ;
