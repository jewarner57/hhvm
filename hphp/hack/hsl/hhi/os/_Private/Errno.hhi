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

namespace HH\Lib\_Private\_OS;

use namespace HH\Lib\{C, OS, Str};

<<__Memoize>>
function get_throw_errno_impl(): (function(OS\Errno, string): noreturn) ;
function throw_errno(
  OS\Errno $errno,
  Str\SprintfFormatString $message,
  mixed ...$args
): noreturn ;
