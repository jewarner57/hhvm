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

namespace HH\Lib\Async;

/**
 * A linked list node storing Condition and pointer to the next node.
 */
final class ConditionNode<T> extends Condition<T> {
  private ?ConditionNode<T> $next = null;

  public function addNext(): ConditionNode<T> ;
  public function getNext(): ?ConditionNode<T> ;}

