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

use namespace HH\Lib\{Network, OS};
use namespace HH\Lib\_Private\_OS;

/** Create a server socket and start listening */
async function socket_create_bind_listen_async(
  OS\SocketDomain $domain,
  OS\SocketType $type,
  int $proto,
  OS\sockaddr $addr,
  int $backlog,
  Network\SocketOptions $socket_options,
): Awaitable<OS\FileDescriptor> ;
