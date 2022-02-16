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

/** Address of an INET6 (IPv6) socket.
 *
 * See `man 7 ip6` (Linux) or `man 4 inet6` (BSD) for details.
 *
 * @see `sockaddr_in` for INET (IPv4) sockets.
 */
final class sockaddr_in6 extends sockaddr {
  /** Construct an instance.
   *
   * Unlike the C API, all integers are in host byte order.
   */
  public function __construct(
    private int $port,
    private int $flowInfo,
    private in6_addr $address,
    private int $scopeID,
  ) ;
  <<__Override>>
  final public function getFamily(): AddressFamily ;
  /** Get the port, in host byte order. */
  final public function getPort(): int;
  final public function getAddress(): in6_addr ;
  /** Get the flow ID.
   *
   * See `man ip6` for details.
   */
  final public function getFlowInfo(): int ;
  /** Get the scope ID.
   *
   * See `man ip6` for details.
   */
  final public function getScopeID(): int ;
  final public function __debugInfo(): darray<string, mixed> ;}

