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

use namespace HH\Lib\{IO, Str, OS, Math};
use namespace HH\Lib\_Private\_OS;

trait FileDescriptorReadHandleTrait implements IO\ReadHandle {
  require extends FileDescriptorHandle;
  use IO\ReadHandleConvenienceMethodsTrait;

  final public function readImpl(?int $max_bytes = null): string ;
  final public async function readAllowPartialSuccessAsync(
    ?int $max_bytes = null,
    ?int $timeout_ns = null,
  ): Awaitable<string> ;}

