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

namespace HH\Lib\_Private\_IO {
  use namespace HH\Lib\{C, Dict, Str, Vec};

  <<__EntryPoint>>
  function generate_intersection_interfaces(): void ;
}

namespace HH\Lib\IO {

  // Generated with the above function, then `hackfmt`

  interface CloseableSeekableHandle extends SeekableHandle, CloseableHandle {}
  interface CloseableReadHandle extends ReadHandle, CloseableHandle {}
  interface SeekableReadHandle extends ReadHandle, SeekableHandle {}
  interface CloseableSeekableReadHandle
    extends SeekableReadHandle, CloseableReadHandle, CloseableSeekableHandle {}
  interface CloseableWriteHandle extends WriteHandle, CloseableHandle {}
  interface SeekableWriteHandle extends WriteHandle, SeekableHandle {}
  interface CloseableSeekableWriteHandle
    extends
      SeekableWriteHandle,
      CloseableWriteHandle,
      CloseableSeekableHandle {}
  interface ReadWriteHandle extends WriteHandle, ReadHandle {}
  interface CloseableReadWriteHandle
    extends ReadWriteHandle, CloseableWriteHandle, CloseableReadHandle {}
  interface SeekableReadWriteHandle
    extends ReadWriteHandle, SeekableWriteHandle, SeekableReadHandle {}
  interface CloseableSeekableReadWriteHandle
    extends
      SeekableReadWriteHandle,
      CloseableReadWriteHandle,
      CloseableSeekableWriteHandle,
      CloseableSeekableReadHandle {}
  interface CloseableFDHandle extends FDHandle, CloseableHandle {}
  interface SeekableFDHandle extends FDHandle, SeekableHandle {}
  interface CloseableSeekableFDHandle
    extends SeekableFDHandle, CloseableFDHandle, CloseableSeekableHandle {}
  interface ReadFDHandle extends FDHandle, ReadHandle {}
  interface CloseableReadFDHandle
    extends ReadFDHandle, CloseableFDHandle, CloseableReadHandle {}
  interface SeekableReadFDHandle
    extends ReadFDHandle, SeekableFDHandle, SeekableReadHandle {}
  interface CloseableSeekableReadFDHandle
    extends
      SeekableReadFDHandle,
      CloseableReadFDHandle,
      CloseableSeekableFDHandle,
      CloseableSeekableReadHandle {}
  interface WriteFDHandle extends FDHandle, WriteHandle {}
  interface CloseableWriteFDHandle
    extends WriteFDHandle, CloseableFDHandle, CloseableWriteHandle {}
  interface SeekableWriteFDHandle
    extends WriteFDHandle, SeekableFDHandle, SeekableWriteHandle {}
  interface CloseableSeekableWriteFDHandle
    extends
      SeekableWriteFDHandle,
      CloseableWriteFDHandle,
      CloseableSeekableFDHandle,
      CloseableSeekableWriteHandle {}
  interface ReadWriteFDHandle
    extends WriteFDHandle, ReadFDHandle, ReadWriteHandle {}
  interface CloseableReadWriteFDHandle
    extends
      ReadWriteFDHandle,
      CloseableWriteFDHandle,
      CloseableReadFDHandle,
      CloseableReadWriteHandle {}
  interface SeekableReadWriteFDHandle
    extends
      ReadWriteFDHandle,
      SeekableWriteFDHandle,
      SeekableReadFDHandle,
      SeekableReadWriteHandle {}
  interface CloseableSeekableReadWriteFDHandle
    extends
      SeekableReadWriteFDHandle,
      CloseableReadWriteFDHandle,
      CloseableSeekableWriteFDHandle,
      CloseableSeekableReadFDHandle,
      CloseableSeekableReadWriteHandle {}
}

