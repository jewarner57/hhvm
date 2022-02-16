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

namespace HH\Lib\_Private\_File;

use namespace HH\Lib\Str;
use namespace HH\Lib\_Private\{_IO, _OS};
use namespace HH\Lib\{IO, File, OS};

<<__ConsistentConstruct>>
abstract class CloseableFileHandle
  extends _IO\FileDescriptorHandle
  implements File\Handle, IO\CloseableHandle {

  final public function __construct(
    OS\FileDescriptor $fd,
    protected string $filename,
  ) ;
  <<__Memoize>>
  final public function getPath(): string ;
  final public function getSize(): int ;
  final public function seek(int $offset): void ;
  final public function tell(): int ;
  <<__ReturnDisposable>>
  final public function lock(File\LockType $type): File\Lock ;
  <<__ReturnDisposable>>
  final public function tryLockx(File\LockType $type): File\Lock ;}

