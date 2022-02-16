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

namespace HH\Lib\File;

use namespace HH\Lib\{IO, OS};
use namespace HH\Lib\_Private\_IO;

final class TemporaryFile implements \IDisposable {
  public function __construct(private CloseableReadWriteHandle $handle) ;
  public function getHandle(): CloseableReadWriteHandle ;  public function __dispose(): void ;}

