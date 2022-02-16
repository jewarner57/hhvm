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

final class Server implements Network\Server<CloseableSocket> {
  /** Path */
  const type TAddress = string;

  private function __construct(private OS\FileDescriptor $impl) ;
  /** Create a bound and listening instance */
  public static async function createAsync(string $path): Awaitable<this> ;
  public async function nextConnectionAsync(): Awaitable<CloseableSocket> ;
  public function getLocalAddress(): string ;
  public function stopListening(): void ;}

