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

/** Convert an INET (IPv4) address from network format to presentation
 * (dotted) format.
 *
 * See `man inet_ntop`
 *
 * @see `inet_ntop_inet6` for an IPv6 version
 */
function inet_ntop_inet(in_addr $addr): string ;
/** Convert an INET6 (IPv6) address from network format to presentation
 * (colon) format.
 *
 * See `man inet_ntop`
 *
 * @see `inet_ntop_inet` for an IPv4 version
 */
function inet_ntop_inet6(in6_addr $addr): string ;

/** Convert an INET or INET6 address to presentation format.
 *
 * See `man inet_ntop`
 *
 * Fails with:
 * - `EAFNOSUPPORT` if the address family is not supported
 * - `EINVAL` if the address is the wrong type for the family
 *
 * @see inet_ntop_inet for a better-typed version for IPv4
 * @see inet_ntop_inet6 for a better-typed version for IPv6
 */
function inet_ntop(AddressFamily $af, dynamic $addr): string ;
