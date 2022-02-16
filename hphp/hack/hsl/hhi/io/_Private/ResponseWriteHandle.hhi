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

namespace HH\Lib\_Private\_IO;

use namespace HH\Lib\{IO, OS};

final class ResponseWriteHandle implements IO\WriteHandle {
  use IO\WriteHandleConvenienceMethodsTrait;

  protected function writeImpl(string $bytes): int ;
  public async function writeAllowPartialSuccessAsync(
    string $bytes,
    ?int $_timeout_ns = null,
  ): Awaitable<int> ;}

