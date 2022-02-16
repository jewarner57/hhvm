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

namespace HH\Lib\Dict;

use namespace HH\Lib\Vec;

/**
 * Returns a new dict with the original entries in reversed iteration
 * order.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function reverse<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: dict<Tk, Tv> ;
/**
 * Returns a new dict with the key value pairs of the given input container in a random
 * order.
 *
 * Dict\shuffle is not using cryptographically secure randomness.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function shuffle<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $container,
)[leak_safe]: dict<Tk, Tv> ;
/**
 * Returns a new dict sorted by the values of the given KeyedTraversable. If the
 * optional comparator function isn't provided, the values will be sorted in
 * ascending order.
 *
 * - To sort by some computable property of each value, see `Dict\sort_by()`.
 * - To sort by the keys of the KeyedTraversable, see `Dict\sort_by_key()`.
 *
 * Time complexity: O((n log n) * c), where c is the complexity of the
 * comparator function (which is O(1) if not provided explicitly)
 * Space complexity: O(n)
 */
function sort<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  ?(function(Tv, Tv)[_]: num) $value_comparator = null,
)[ctx $value_comparator]: dict<Tk, Tv> ;
/**
 * Returns a new dict sorted by some scalar property of each value of the given
 * KeyedTraversable, which is computed by the given function. If the optional
 * comparator function isn't provided, the values will be sorted in ascending
 * order of scalar key.
 *
 * - To sort by the values of the KeyedTraversable, see `Dict\sort()`.
 * - To sort by the keys of the KeyedTraversable, see `Dict\sort_by_key()`.
 *
 * Time complexity: O((n log n) * c + n * s), where c is the complexity of the
 * comparator function (which is O(1) if not provided explicitly) and s is the
 * complexity of the scalar function
 * Space complexity: O(n)
 */
function sort_by<Tk as arraykey, Tv, Ts>(
  KeyedTraversable<Tk, Tv> $traversable,
  (function(Tv)[_]: Ts) $scalar_func,
  ?(function(Ts, Ts)[_]: num) $scalar_comparator = null,
)[ctx $scalar_func, ctx $scalar_comparator]: dict<Tk, Tv> ;
/**
 * Returns a new dict sorted by the keys of the given KeyedTraversable. If the
 * optional comparator function isn't provided, the keys will be sorted in
 * ascending order.
 *
 * - To sort by the values of the KeyedTraversable, see `Dict\sort()`.
 * - To sort by some computable property of each value, see `Dict\sort_by()`.
 *
 * Time complexity: O((n log n) * c), where c is the complexity of the
 * comparator function (which is O(1) if not provided explicitly)
 * Space complexity: O(n)
 */
function sort_by_key<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  ?(function(Tk, Tk)[_]: num) $key_comparator = null,
)[ctx $key_comparator]: dict<Tk, Tv> ;
