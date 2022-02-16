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

use namespace HH\Lib\{C, Dict};

/**
 * Returns a new dict with each value `await`ed in parallel.
 *
 * Time complexity: O(n * a), where a is the complexity of the synchronous
 * portions of each Awaitable
 * Space complexity: O(n)
 *
 * The IO operations for each Awaitable will happen in parallel.
 */
async function from_async<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Awaitable<Tv>> $awaitables,
)[]: Awaitable<dict<Tk, Tv>> ;
/**
 * Returns a new dict where each value is the result of calling the given
 * async function on the corresponding key.
 *
 * For non-async functions, see `Dict\from_keys()`.
 *
 * Time complexity: O(n * f), where f is the complexity of `$async_func`
 * Space complexity: O(n)
 */
async function from_keys_async<Tk as arraykey, Tv>(
  Traversable<Tk> $keys,
  (function(Tk)[_]: Awaitable<Tv>) $async_func,
)[ctx $async_func]: Awaitable<dict<Tk, Tv>> ;
/**
 * Returns a new dict containing only the values for which the given async
 * predicate returns `true`.
 *
 * For non-async predicates, see `Dict\filter()`.
 *
 * Time complexity: O(n * p), where p is the complexity of the synchronous
 * portions of `$value_predicate`
 * Space complexity: O(n)
 *
 * The IO operations for each of the calls to `$value_predicate` will happen
 * in parallel.
 */
async function filter_async<Tk as arraykey, Tv>(
  KeyedContainer<Tk, Tv> $traversable,
  (function(Tv)[_]: Awaitable<bool>) $value_predicate,
)[ctx $value_predicate]: Awaitable<dict<Tk, Tv>> ;
/**
 * Like `filter_async`, but lets you utilize the keys of your dict too.
 *
 * For non-async filters with key, see `Dict\filter_with_key()`.
 *
 * Time complexity: O(n * p), where p is the complexity of `$value_predicate`
 * Space complexity: O(n)
 */
async function filter_with_key_async<Tk as arraykey, Tv>(
  KeyedContainer<Tk, Tv> $traversable,
  (function(Tk, Tv)[_]: Awaitable<bool>) $predicate,
)[ctx $predicate]: Awaitable<dict<Tk, Tv>> ;
/**
 * Returns a new dict where each value is the result of calling the given
 * async function on the original value.
 *
 * For non-async functions, see `Dict\map()`.
 *
 * Time complexity: O(n * f), where f is the complexity of the synchronous
 * portions of `$async_func`
 * Space complexity: O(n)
 *
 * The IO operations for each of calls to `$async_func` will happen in
 * parallel.
 */
async function map_async<Tk as arraykey, Tv1, Tv2>(
  KeyedTraversable<Tk, Tv1> $traversable,
  (function(Tv1)[_]: Awaitable<Tv2>) $value_func,
)[ctx $value_func]: Awaitable<dict<Tk, Tv2>> ;
/**
 * Returns a new dict where each value is the result of calling the given
 * async function on the original key and value.
 *
 * For non-async functions, see `Dict\map()`.
 *
 * Time complexity: O(n * a), where a is the complexity of each Awaitable
 * Space complexity: O(n)
 */
async function map_with_key_async<Tk as arraykey, Tv1, Tv2>(
  KeyedTraversable<Tk, Tv1> $traversable,
  (function(Tk, Tv1)[_]: Awaitable<Tv2>) $async_func,
)[ctx $async_func]: Awaitable<dict<Tk, Tv2>> ;
