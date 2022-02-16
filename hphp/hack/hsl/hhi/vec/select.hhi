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

namespace HH\Lib\Vec;

use namespace HH\Lib\{C, Dict, Keyset, _Private};

/**
 * Returns a new vec containing only the elements of the first Traversable that
 * do not appear in any of the other ones.
 *
 * For vecs that contain non-arraykey elements, see `Vec\diff_by()`.
 *
 * Time complexity: O(n + m), where n is size of `$first` and m is the combined
 * size of `$second` plus all the `...$rest`
 * Space complexity: O(n + m), where n is size of `$first` and m is the combined
 * size of `$second` plus all the `...$rest` -- note that this is bigger than
 * O(n)
 */
function diff<Tv1 as arraykey, Tv2 as arraykey>(
  Traversable<Tv1> $first,
  Traversable<Tv2> $second,
  Container<Tv2> ...$rest
)[]: vec<Tv1> ;
/**
 * Returns a new vec containing only the elements of the first Traversable
 * that do not appear in the second one, where an element's identity is
 * determined by the scalar function.
 *
 * For vecs that contain arraykey elements, see `Vec\diff()`.
 *
 * Time complexity: O((n + m) * s), where n is the size of `$first`, m is the
 * size of `$second`, and s is the complexity of `$scalar_func`
 * Space complexity: O(n + m), where n is the size of `$first` and m is the size
 * of `$second` -- note that this is bigger than O(n)
 */
function diff_by<Tv, Ts as arraykey>(
  Traversable<Tv> $first,
  Traversable<Tv> $second,
  (function(Tv)[_]: Ts) $scalar_func,
)[ctx $scalar_func]: vec<Tv> ;
/**
 * Returns a new vec containing all except the first `$n` elements of the
 * given Traversable.
 *
 * To take only the first `$n` elements, see `Vec\take()`.
 *
 * Time complexity: O(n), where n is the size of `$traversable`
 * Space complexity: O(n), where n is the size of `$traversable`
 */
function drop<Tv>(
  Traversable<Tv> $traversable,
  int $n,
)[]: vec<Tv> ;
/**
 * Returns a new vec containing only the values for which the given predicate
 * returns `true`. The default predicate is casting the value to boolean.
 *
 * - To remove null values in a typechecker-visible way, see
 *   `Vec\filter_nulls()`.
 * - To use an async predicate, see `Vec\filter_async()`.
 *
 * Time complexity: O(n * p), where p is the complexity of `$value_predicate`
 * Space complexity: O(n)
 */
function filter<Tv>(
  Traversable<Tv> $traversable,
  ?(function(Tv)[_]: bool) $value_predicate = null,
)[ctx $value_predicate]: vec<Tv> ;
/**
 * Returns a new vec containing only non-null values of the given
 * Traversable.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function filter_nulls<Tv>(
  Traversable<?Tv> $traversable,
)[]: vec<Tv> ;
/**
 * Returns a new vec containing only the values for which the given predicate
 * returns `true`.
 *
 * If you don't need access to the key, see `Vec\filter()`.
 *
 * Time complexity: O(n * p), where p is the complexity of `$predicate`
 * Space complexity: O(n)
 */
function filter_with_key<Tk, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  (function(Tk, Tv)[_]: bool) $predicate,
)[ctx $predicate]: vec<Tv> ;
/**
 * Returns a new vec containing only the elements of the first Traversable that
 * appear in all the other ones. Duplicate values are preserved.
 *
 * Time complexity: O(n + m), where n is size of `$first` and m is the combined
 * size of `$second` plus all the `...$rest`
 * Space complexity: O(n), where n is size of `$first`
 */
function intersect<Tv as arraykey>(
  Traversable<Tv> $first,
  Traversable<Tv> $second,
  Container<Tv> ...$rest
)[]: vec<Tv> ;
/**
 * Returns a new vec containing the keys of the given KeyedTraversable.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function keys<Tk, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: vec<Tk> ;
/**
 * Returns a new vec containing an unbiased random sample of up to
 * `$sample_size` elements (fewer iff `$sample_size` is larger than the size of
 * `$traversable`).
 *
 * Time complexity: O(n), where n is the size of `$traversable`
 * Space complexity: O(n), where n is the size of `$traversable` -- note that n
 * may be bigger than `$sample_size`
 */
function sample<Tv>(
  Traversable<Tv> $traversable,
  int $sample_size,
): vec<Tv> ;
/**
 * Returns a new vec containing the subsequence of the given Traversable
 * determined by the offset and length.
 *
 * If no length is given or it exceeds the upper bound of the Traversable,
 * the vec will contain every element after the offset.
 *
 * - To take only the first `$n` elements, see `Vec\take()`.
 * - To drop the first `$n` elements, see `Vec\drop()`.
 *
 * Time complexity: O(n), where n is the size of the slice
 * Space complexity: O(n), where n is the size of the slice
 */
function slice<Tv>(
  Container<Tv> $container,
  int $offset,
  ?int $length = null,
)[]: vec<Tv> ;
/**
 * Returns a new vec containing the first `$n` elements of the given
 * Traversable.
 *
 * To drop the first `$n` elements, see `Vec\drop()`.
 *
 * Time complexity: O(n), where n is `$n`
 * Space complexity: O(n), where n is `$n`
 */
function take<Tv>(
  Traversable<Tv> $traversable,
  int $n,
)[]: vec<Tv> ;
/**
 * Returns a new vec containing each element of the given Traversable exactly
 * once. The Traversable must contain arraykey values, and strict equality will
 * be used.
 *
 * For non-arraykey elements, see `Vec\unique_by()`.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function unique<Tv as arraykey>(
  Traversable<Tv> $traversable,
)[]: vec<Tv> ;
/**
 * Returns a new vec containing each element of the given Traversable exactly
 * once, where uniqueness is determined by calling the given scalar function on
 * the values. In case of duplicate scalar keys, later values will overwrite
 * previous ones.
 *
 * For arraykey elements, see `Vec\unique()`.
 *
 * Time complexity: O(n * s), where s is the complexity of `$scalar_func`
 * Space complexity: O(n)
 */
function unique_by<Tv, Ts as arraykey>(
  Traversable<Tv> $traversable,
  (function(Tv)[_]: Ts) $scalar_func,
)[ctx $scalar_func]: vec<Tv> ;
