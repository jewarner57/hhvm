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
/** Accept a socket connection, waiting if necessary */
async function socket_accept_async(
  OS\FileDescriptor $server,
): Awaitable<OS\FileDescriptor> ;
