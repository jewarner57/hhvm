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

namespace HH\Lib\_Private\_TCP;

use namespace HH\Lib\{IO, Network, OS, TCP};
use namespace HH\Lib\_Private\{_IO, _Network};

final class CloseableTCPSocket
  extends _IO\FileDescriptorHandle
  implements TCP\CloseableSocket, IO\CloseableReadWriteHandle {
  use _IO\FileDescriptorReadHandleTrait;
  use _IO\FileDescriptorWriteHandleTrait;

  public function __construct(OS\FileDescriptor $impl) ;
  public function getLocalAddress(): (string, int) ;
  public function getPeerAddress(): (string, int) ;}

