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
<<file:__EnableUnstableFeatures('readonly')>>

/**
 * C is for Containers. This file contains functions that ask
 * questions of (i.e. introspect) containers and traversables.
 */
namespace HH\Lib\C;

/**
 * Returns true if the given predicate returns true for any element of the
 * given Traversable. If no predicate is provided, it defaults to casting the
 * element to bool. If the Traversable is empty, it returns false.
 *
 * If you're looking for `C\none`, use `!C\any`.
 *
 * Time complexity: O(n)
 * Space complexity: O(1)
 */
function any<T>(
  Traversable<T> $traversable,
  ?(function(T)[_]: bool) $predicate = null,
)[ctx $predicate]: bool ;
/**
 * Returns true if the given Traversable contains the value. Strict equality is
 * used.
 *
 * Time complexity: O(n) (O(1) for keysets)
 * Space complexity: O(1)
 */
function contains<
  <<__NonDisjoint>> T1,
  <<__NonDisjoint>> T2
>(
  readonly Traversable<T1> $traversable,
  readonly T2 $value,
)[]: bool ;
/**
 * Returns true if the given KeyedContainer contains the key.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function contains_key<
  <<__NonDisjoint>> Tk1 as arraykey,
  <<__NonDisjoint>> Tk2 as arraykey,
  Tv
>(
  readonly KeyedContainer<Tk1, Tv> $container,
  readonly Tk2 $key,
)[]: bool ;
/**
 * Returns the number of elements in the given Container.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function count(
  readonly Container<mixed> $container,
)[]: int ;
/**
 * Returns true if the given predicate returns true for every element of the
 * given Traversable. If no predicate is provided, it defaults to casting the
 * element to bool. If the Traversable is empty, returns true.
 *
 * If you're looking for `C\all`, this is it.
 *
 * Time complexity: O(n)
 * Space complexity: O(1)
 */
function every<T>(
  Traversable<T> $traversable,
  ?(function(T)[_]: bool) $predicate = null,
)[ctx $predicate]: bool ;
/**
 * Returns whether the given Container is empty.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function is_empty<T>(
  readonly Container<T> $container,
)[]: bool ;
