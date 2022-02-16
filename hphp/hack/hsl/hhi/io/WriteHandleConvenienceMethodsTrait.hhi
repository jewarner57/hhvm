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

namespace HH\Lib\IO;

use namespace HH\Lib\{Str, OS};
use namespace HH\Lib\_Private\_OS;

/** Trait implementing `WriteHandle` methods that can be implemented in terms
 * of more basic methods.
 */
trait WriteHandleConvenienceMethodsTrait {
  require implements WriteHandle;

  public async function writeAllAsync(
    string $data,
    ?int $timeout_ns = null,
  ): Awaitable<void> ;}

