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

use namespace HH\Lib\{OS, Network};
use namespace HH\Lib\_Private\{_Network, _OS, _TCP};

final class Server implements Network\Server<CloseableSocket> {
  /** Host and port */
  const type TAddress = (string, int);

  private function __construct(private OS\FileDescriptor $impl) ;
  /** Create a bound and listening instance */
  public static async function createAsync(
    Network\IPProtocolVersion $ipv,
    string $host,
    int $port,
    ServerOptions $opts = shape(),
  ): Awaitable<this> ;
  public async function nextConnectionAsync(): Awaitable<CloseableSocket> ;
  public function getLocalAddress(): (string, int) ;
  public function stopListening(): void ;}

