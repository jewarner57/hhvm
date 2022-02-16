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

namespace HH\Lib\OS;

use namespace HH\Lib\Str;
use namespace HH\Lib\_Private\_OS;

/** Convert a presentation-format (dotted) INET (IPv4)) address to network
 * format.
 *
 * See `man inet_pton`.
 *
 * @see inet_pton_inet6 for IPv6
 */
function inet_pton_inet(string $addr): in_addr ;
/** Convert a presentation-format (colon-separated) INET6 (IPv6) address to
 * network format.
 *
 * See `man inet_pton`.
 *
 * @see inet_pton_inet for IPv4
 */

function inet_pton_inet6(string $addr): in6_addr ;
/** Convert a presentation-format INET/INET6 address to network format.
 *
 * See `man inet_pton`
 *
 * @see inet_pton_inet() for a better-typed version for IPv4
 * @see inet_pton_inet6() for a better-typed version for IPv6
 */
function inet_pton(AddressFamily $af, string $addr): mixed ;
