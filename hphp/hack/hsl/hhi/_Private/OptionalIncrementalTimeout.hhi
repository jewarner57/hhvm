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

namespace HH\Lib\_Private;

final class OptionalIncrementalTimeout {
  private ?int $end;
  public function __construct(
    ?int $timeout_ns,
    private (function(): ?int) $timeoutHandler,
  ) ;
  public function getRemainingNS(): ?int ;
  private static function nowNS(): int ;}

