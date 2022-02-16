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

use namespace HH\Lib\C;

/**
 * Returns a new keyset containing only the elements of the first Traversable
 * that do not appear in any of the other ones.
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
)[]: keyset<Tv1> ;/**
 * Returns a new keyset containing all except the first `$n` elements of
 * the given Traversable.
 *
 * To take only the first `$n` elements, see `Keyset\take()`.
 *
 * Time complexity: O(n), where n is the size of `$traversable`
 * Space complexity: O(n), where n is the size of `$traversable`
 */
function drop<Tv as arraykey>(
  Traversable<Tv> $traversable,
  int $n,
)[]: keyset<Tv> ;
/**
 * Returns a new keyset containing only the values for which the given predicate
 * returns `true`. The default predicate is casting the value to boolean.
 *
 * To remove null values in a typechecker-visible way, see `Keyset\filter_nulls()`.
 *
 * Time complexity: O(n * p), where p is the complexity of `$value_predicate`
 * Space complexity: O(n)
 */
function filter<Tv as arraykey>(
  Traversable<Tv> $traversable,
  ?(function(Tv)[_]: bool) $value_predicate = null,
)[ctx $value_predicate]: keyset<Tv> ;
/**
 * Returns a new keyset containing only non-null values of the given
 * Traversable.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function filter_nulls<Tv as arraykey>(
  Traversable<?Tv> $traversable,
)[]: keyset<Tv> ;
/**
 * Returns a new keyset containing only the values for which the given predicate
 * returns `true`.
 *
 * If you don't need access to the key, see `Keyset\filter()`.
 *
 * Time complexity: O(n * p), where p is the complexity of `$predicate`
 * Space complexity: O(n)
 */
function filter_with_key<Tk, Tv as arraykey>(
  KeyedTraversable<Tk, Tv> $traversable,
  (function(Tk, Tv)[_]: bool) $predicate,
)[ctx $predicate]: keyset<Tv> ;
/**
 * Returns a new keyset containing the keys of the given KeyedTraversable,
 * maintaining the iteration order.
 */
function keys<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: keyset<Tk> ;
/**
 * Returns a new keyset containing only the elements of the first Traversable
 * that appear in all the other ones.
 *
 * Time complexity: O(n + m), where n is size of `$first` and m is the combined
 * size of `$second` plus all the `...$rest`
 * Space complexity: O(n), where n is size of `$first`
 */
function intersect<Tv as arraykey>(
  Traversable<Tv> $first,
  Traversable<Tv> $second,
  Container<Tv> ...$rest
)[]: keyset<Tv> ;
/**
 * Returns a new keyset containing the first `$n` elements of the given
 * Traversable.
 *
 * If there are duplicate values in the Traversable, the keyset may be shorter
 * than the specified length.
 *
 * To drop the first `$n` elements, see `Keyset\drop()`.
 *
 * Time complexity: O(n), where n is `$n`
 * Space complexity: O(n), where n is `$n`
 */
function take<Tv as arraykey>(
  Traversable<Tv> $traversable,
  int $n,
)[]: keyset<Tv> ;
