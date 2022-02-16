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

use namespace HH\Lib\{IO, OS, Str};
use namespace HH\Lib\_Private\{_IO, _OS};

abstract class FileDescriptorHandle implements IO\CloseableHandle, IO\FDHandle {
  protected bool $isAwaitable = true;

  protected function __construct(protected OS\FileDescriptor $impl) ;
  final public function getFileDescriptor(): OS\FileDescriptor ;
  final protected async function selectAsync(
    int $flags,
    int $timeout_ns,
  ): Awaitable<void> ;
  final public function close(): void ;
  <<__ReturnDisposable>>
  final public function closeWhenDisposed(): \IDisposable ;}

