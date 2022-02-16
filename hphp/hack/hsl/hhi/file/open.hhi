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
use namespace HH\Lib\{OS, _Private\_File};

function open_read_only(string $path): CloseableReadHandle ;
function open_write_only(
  string $path,
  WriteMode $mode = WriteMode::OPEN_OR_CREATE,
  int $create_file_permissions = 0644,
): CloseableWriteHandle ;
function open_read_write(
  string $path,
  WriteMode $mode = WriteMode::OPEN_OR_CREATE,
  int $create_file_permissions = 0644,
): CloseableReadWriteHandle ;
<<__Deprecated("Use open_read_only() instead")>>
function open_read_only_nd(string $path): CloseableReadHandle ;
<<__Deprecated("Use open_write_only() instead")>>
function open_write_only_nd(
  string $path,
  WriteMode $mode = WriteMode::OPEN_OR_CREATE,
  int $create_file_permissions = 0644,
): CloseableWriteHandle ;
<<__ReturnDisposable, __Deprecated("Use open_read_write() instead")>>
function open_read_write_nd(
  string $path,
  WriteMode $mode = WriteMode::OPEN_OR_CREATE,
  int $create_file_permissions = 0644,
): CloseableReadWriteHandle ;
