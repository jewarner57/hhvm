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

/**
 * Returns a new vec with each value `await`ed in parallel.
 *
 * Time complexity: O(n * a), where a is the complexity of synchronous
 * portions of each Awaitable
 * Space complexity: O(n)
 *
 * The IO operations for each Awaitable will happen in parallel.
 */
async function from_async<Tv>(
  Traversable<Awaitable<Tv>> $awaitables,
)[]: Awaitable<vec<Tv>> ;
/**
 * Returns a new vec containing only the values for which the given async
 * predicate returns `true`.
 *
 * For non-async predicates, see `Vec\filter()`.
 *
 * Time complexity: O(n * p), where p is the complexity of synchronous portions
 * of `$value_predicate`
 * Space complexity: O(n)
 *
 * The IO operations for each of the calls to `$value_predicate` will happen
 * in parallel.
 */
async function filter_async<Tv>(
  Container<Tv> $container,
  (function(Tv)[_]: Awaitable<bool>) $value_predicate,
)[ctx $value_predicate]: Awaitable<vec<Tv>> ;
/**
 * Returns a new vec where each value is the result of calling the given
 * async function on the original value.
 *
 * For non-async functions, see `Vec\map()`.
 *
 * Time complexity: O(n * f), where `f` is the complexity of the synchronous
 * portions of `$async_func`
 * Space complexity: O(n)
 *
 * The IO operations for each of calls to `$async_func` will happen in
 * parallel.
 */
async function map_async<Tv1, Tv2>(
  Traversable<Tv1> $traversable,
  (function(Tv1)[_]: Awaitable<Tv2>) $async_func,
)[ctx $async_func]: Awaitable<vec<Tv2>> ;
/**
 * Returns a 2-tuple containing vecs for which the given async
 * predicate returned `true` and `false`, respectively.
 *
 * For non-async predicates, see `Vec\partition()`.
 *
 * Time complexity: O(n * p), where p is the complexity of synchronous portions
 * of `$value_predicate`
 * Space complexity: O(n)
 *
 * The IO operations for each of the calls to `$value_predicate` will happen
 * in parallel.
 */
async function partition_async<Tv>(
  Container<Tv> $container,
  (function(Tv)[_]: Awaitable<bool>) $value_predicate,
)[ctx $value_predicate]: Awaitable<(vec<Tv>, vec<Tv>)> ;
