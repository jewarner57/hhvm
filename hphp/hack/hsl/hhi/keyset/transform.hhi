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

namespace HH\Lib\Keyset;

use namespace HH\Lib\Math;

/**
 * Returns a vec containing the given Traversable split into chunks of the
 * given size.
 *
 * If the given Traversable doesn't divide evenly, the final chunk will be
 * smaller than the specified size. If there are duplicate values in the
 * Traversable, some chunks may be smaller than the specified size.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function chunk<Tv as arraykey>(
  Traversable<Tv> $traversable,
  int $size,
)[]: vec<keyset<Tv>> ;
/**
 * Returns a new keyset where each value is the result of calling the given
 * function on the original value.
 *
 * Time complexity: O(n * f), where f is the complexity of `$value_func`
 * Space complexity: O(n)
 */
function map<Tv1, Tv2 as arraykey>(
  Traversable<Tv1> $traversable,
  (function(Tv1)[_]: Tv2) $value_func,
)[ctx $value_func]: keyset<Tv2> ;
/**
 * Returns a new keyset where each value is the result of calling the given
 * function on the original key and value.
 *
 * Time complexity: O(n * f), where f is the complexity of `$value_func`
 * Space complexity: O(n)
 */
function map_with_key<Tk, Tv1, Tv2 as arraykey>(
  KeyedTraversable<Tk, Tv1> $traversable,
  (function(Tk, Tv1)[_]: Tv2) $value_func,
)[ctx $value_func]: keyset<Tv2> ;
/**
 * Returns a new keyset formed by joining the values
 * within the given Traversables into
 * a keyset.
 *
 * For a fixed number of Traversables, see `Keyset\union()`.
 *
 * Time complexity: O(n), where n is the combined size of all the
 * `$traversables`
 * Space complexity: O(n), where n is the combined size of all the
 * `$traversables`
 */
function flatten<Tv as arraykey>(
  Traversable<Container<Tv>> $traversables,
)[]: keyset<Tv> ;
