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
use namespace HH\Lib\_Private\{_Network, _OS, _TCP};

/** A poor alternative to OS\getaddrinfo, which doesn't exist yet. */
function resolve_hostname(OS\AddressFamily $af, string $host): ?string ;
