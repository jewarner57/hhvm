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

use namespace HH\Lib\{IO, Math, OS, Str};
use namespace HH\Lib\_Private\_OS;

trait FileDescriptorWriteHandleTrait implements IO\WriteHandle {
  require extends FileDescriptorHandle;
  use IO\WriteHandleConvenienceMethodsTrait;

  final protected function writeImpl(string $bytes): int ;
  final public async function writeAllowPartialSuccessAsync(
    string $bytes,
    ?int $timeout_ns = null,
  ): Awaitable<int> ;}

