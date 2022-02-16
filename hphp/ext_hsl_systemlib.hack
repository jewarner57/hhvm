///// /home/ubuntu/hhvm/hphp/hsl/src/Ref.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib {

/** Wrapper class for getting object (byref) semantics for a value type.
 *
 * This is especially useful for mutating values outside of a lambda's scope.
 *
 * In general, it's preferable to refactor to use return values or `inout`
 * parameters instead of using this class - however, a `Ref` of a Hack array
 * is generally preferable to a Hack collection - e.g. prefer `Ref<vec<T>>`
 * over `Vector<T>`.
 *
 * `C\reduce()` and `C\reduce_with_key()` can also be used in some situations
 * to avoid this class.
 */
final class Ref<T> {
  public function __construct(public T $value)[] {}

  /** Retrieve the stored value */
  public function get()[]: T {
    return $this->value;
  }

  /** Set the new value */
  public function set(T $new_value)[write_props]: void {
    $this->value = $new_value;
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/c/select.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\C {

use namespace HH\Lib\{_Private, Str};

/**
 * Returns the first value of the given Traversable for which the predicate
 * returns true, or null if no such value is found.
 *
 * Time complexity: O(n)
 * Space complexity: O(1)
 *
 * @see `C\findx` when a value is required
 */
function find<T>(
  Traversable<T> $traversable,
  (function(T)[_]: bool) $value_predicate,
)[ctx $value_predicate]: ?T {
  foreach ($traversable as $value) {
    if ($value_predicate($value)) {
      return $value;
    }
  }
  return null;
}

/**
 * Returns the first value of the given Traversable for which the predicate
 * returns true, or throws if no such value is found.
 *
 * Time complexity: O(n)
 * Space complexity: O(1)
 *
 * @see `C\find()` if you would prefer null if not found.
 */
function findx<T>(
  Traversable<T> $traversable,
  (function(T)[_]: bool) $value_predicate,
)[ctx $value_predicate]: T {
  foreach ($traversable as $value) {
    if ($value_predicate($value)) {
      return $value;
    }
  }
  invariant_violation('%s: Couldn\'t find target value.', __FUNCTION__);
}

/**
 * Returns the key of the first value of the given KeyedTraversable for which
 * the predicate returns true, or null if no such value is found.
 *
 * Time complexity: O(n)
 * Space complexity: O(1)
 */
function find_key<Tk, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  (function(Tv)[_]: bool) $value_predicate,
)[ctx $value_predicate]: ?Tk {
  foreach ($traversable as $key => $value) {
    if ($value_predicate($value)) {
      return $key;
    }
  }
  return null;
}

/**
 * Returns the first element of the given Traversable, or null if the
 * Traversable is empty.
 *
 * - For non-empty Traversables, see `C\firstx`.
 * - For possibly null Traversables, see `C\nfirst`.
 * - For single-element Traversables, see `C\onlyx`.
 * - For Awaitables that yield Traversables, see `C\first_async`.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function first<T>(
  Traversable<T> $traversable,
)[]: ?T {
  if ($traversable is Container<_>) {
    return _Private\Native\first($traversable);
  }
  foreach ($traversable as $value) {
    return $value;
  }
  return null;
}

/**
 * Returns the first element of the given Traversable, or throws if the
 * Traversable is empty.
 *
 * - For possibly empty Traversables, see `C\first`.
 * - For possibly null Traversables, see `C\nfirst`.
 * - For single-element Traversables, see `C\onlyx`.
 * - For Awaitables that yield Traversables, see `C\firstx_async`.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function firstx<T>(
  Traversable<T> $traversable,
)[]: T {
  if ($traversable is Container<_>) {
    $first_value = _Private\Native\first($traversable);
    if ($first_value is nonnull) {
      return $first_value;
    }
    invariant(
      !is_empty($traversable),
      '%s: Expected at least one element.',
      __FUNCTION__,
    );
    /* HH_FIXME[4110] invariant above implies this is T */
    return $first_value;
  }
  foreach ($traversable as $value) {
    return $value;
  }
  invariant_violation('%s: Expected at least one element.', __FUNCTION__);
}

/**
 * Returns the first key of the given KeyedTraversable, or null if the
 * KeyedTraversable is empty.
 *
 * For non-empty Traversables, see `C\first_keyx`.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function first_key<Tk, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: ?Tk {
  if ($traversable is KeyedContainer<_, _>) {
    return _Private\Native\first_key($traversable);
  }
  foreach ($traversable as $key => $_) {
    return $key;
  }
  return null;
}

/**
 * Returns the first key of the given KeyedTraversable, or throws if the
 * KeyedTraversable is empty.
 *
 * For possibly empty Traversables, see `C\first_key`.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function first_keyx<Tk, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: Tk {
  if ($traversable is KeyedContainer<_, _>) {
    $first_key = _Private\Native\first_key($traversable);
    invariant(
      $first_key is nonnull,
      '%s: Expected at least one element.',
      __FUNCTION__,
    );
    return $first_key;
  }
  foreach ($traversable as $key => $_) {
    return $key;
  }
  invariant_violation('%s: Expected at least one element.', __FUNCTION__);
}

/**
 * Returns the last element of the given Traversable, or null if the
 * Traversable is empty.
 *
 * - For non-empty Traversables, see `C\lastx`.
 * - For single-element Traversables, see `C\onlyx`.
 *
 * Time complexity: O(1) if `$traversable` is a `Container`, O(n) otherwise.
 * Space complexity: O(1)
 */
function last<T>(
  Traversable<T> $traversable,
)[]: ?T {
  if ($traversable is Container<_>) {
    return _Private\Native\last($traversable);
  }
  if ($traversable is Iterable<_>) {
    /* HH_FIXME[4390] need ctx constants */
    return $traversable->lastValue();
  }
  $value = null;
  foreach ($traversable as $value) {
  }
  return $value;
}

/**
 * Returns the last element of the given Traversable, or throws if the
 * Traversable is empty.
 *
 * - For possibly empty Traversables, see `C\last`.
 * - For single-element Traversables, see `C\onlyx`.
 *
 * Time complexity: O(1) if `$traversable` is a `Container`, O(n) otherwise.
 * Space complexity: O(1)
 */
function lastx<T>(
  Traversable<T> $traversable,
)[]: T {
  if ($traversable is Container<_>) {
    $last_value = _Private\Native\last($traversable);
    if ($last_value is nonnull) {
      return $last_value;
    }
    invariant(
      !is_empty($traversable),
      '%s: Expected at least one element.',
      __FUNCTION__,
    );
    /* HH_FIXME[4110] invariant above implies this is T */
    return $last_value;
  }
  $value = null;
  $did_iterate = false;
  foreach ($traversable as $value) {
    $did_iterate = true;
  }
  invariant($did_iterate, '%s: Expected at least one element.', __FUNCTION__);
  /* HH_FIXME[4110] invariant above implies this is T */
  return $value;
}

/**
 * Returns the last key of the given KeyedTraversable, or null if the
 * KeyedTraversable is empty.
 *
 * For non-empty Traversables, see `C\last_keyx`.
 *
 * Time complexity: O(1) if `$traversable` is a `Container`, O(n) otherwise.
 * Space complexity: O(1)
 */
function last_key<Tk, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: ?Tk {
  if ($traversable is KeyedContainer<_, _>) {
    return _Private\Native\last_key($traversable);
  }
  if ($traversable is KeyedIterable<_, _>) {
    /* HH_FIXME[4390] need ctx constants */
    return $traversable->lastKey();
  }
  $key = null;
  foreach ($traversable as $key => $_) {
  }
  return $key;
}

/**
 * Returns the last key of the given KeyedTraversable, or throws if the
 * KeyedTraversable is empty.
 *
 * For possibly empty Traversables, see `C\last_key`.
 *
 * Time complexity: O(1) if `$traversable` is a `Container`, O(n) otherwise.
 * Space complexity: O(1)
 */
function last_keyx<Tk, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: Tk {
  if ($traversable is KeyedContainer<_, _>) {
    $last_key = _Private\Native\last_key($traversable);
    invariant(
      $last_key is nonnull,
      '%s: Expected at least one element.',
      __FUNCTION__,
    );
    return $last_key;
  }
  $key = null;
  $did_iterate = false;
  foreach ($traversable as $key => $_) {
    $did_iterate = true;
  }
  invariant($did_iterate, '%s: Expected at least one element.', __FUNCTION__);
  /* HH_FIXME[4110] invariant above implies this is Tk */
  return $key;
}

/**
 * Returns the first element of the given Traversable, or null if the
 * Traversable is null or empty.
 *
 * - For non-null Traversables, see `C\first`.
 * - For non-empty Traversables, see `C\firstx`.
 * - For single-element Traversables, see `C\onlyx`.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function nfirst<T>(
  ?Traversable<T> $traversable,
)[]: ?T {
  return $traversable is nonnull ? first($traversable) : null;
}

/**
 * Returns the first and only element of the given Traversable, or throws if the
 * Traversable is empty or contains more than one element.
 *
 * An optional format string (and format arguments) may be passed to specify
 * a custom message for the exception in the error case.
 *
 * For Traversables with more than one element, see `C\firstx`.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function onlyx<T>(
  Traversable<T> $traversable,
  ?Str\SprintfFormatString $format_string = null,
  mixed ...$format_args
)[]: T {
  $first = true;
  $result = null;
  foreach ($traversable as $value) {
    invariant(
      $first,
      '%s',
      $format_string === null
        ? Str\format(
          'Expected exactly one element%s.',
          $traversable is Container<_>
            ? ' but got '.count($traversable)
            : '',
        )
        : \vsprintf($format_string, $format_args),
    );
    $result = $value;
    $first = false;
  }
  invariant(
    $first === false,
    '%s',
    $format_string === null
      ? 'Expected non-empty Traversable.'
      : \vsprintf($format_string, $format_args),
  );
  /* HH_FIXME[4110] $first is false implies $result is set to T */
  return $result;
}

/**
 * Removes the last element from a Container and returns it.
 * If the Container is empty, null will be returned.
 *
 * When an immutable Hack Collection is passed, the result will
 * be defined by your version of hhvm and not give the expected results.
 *
 * For non-empty Containers, see `pop_backx`.
 * To get the first element, see `pop_front`.
 *
 * Time complexity: O(1 or N) If the operation can happen in-place, O(1)
 *   if it must copy the Container, O(N).
 * Space complexity: O(1 or N) If the operation can happen in-place, O(1)
 *   if it must copy the Container, O(N).
 */
function pop_back<T as Container<Tv>, Tv>(
  inout T $container,
)[]: ?Tv {
  if (is_empty($container)) {
    return null;
  }
  return \array_pop(inout $container);
}

/**
 * Removes the last element from a Container and returns it.
 * If the Container is empty, an `InvariantException` is thrown.
 *
 * When an immutable Hack Collection is passed, the result will
 * be defined by your version of hhvm and not give the expected results.
 *
 * For maybe empty Containers, see `pop_back`.
 * To get the first element, see `pop_frontx`.
 *
 * Time complexity: O(1 or N) If the operation can happen in-place, O(1)
 *   if it must copy the Container, O(N).
 * Space complexity: O(1 or N) If the operation can happen in-place, O(1)
 *   if it must copy the Container, O(N).
 */
function pop_backx<T as Container<Tv>, Tv>(
  inout T $container,
)[]: Tv {
  invariant(
    !is_empty($container),
    '%s: Expected at least one element',
    __FUNCTION__,
  );
  return \array_pop(inout $container);
}

/**
 * Like `pop_back`, but removes the first item.
 *
 * Removes the first element from a Container and returns it.
 * If the Container is empty, null is returned.
 *
 * When an immutable Hack Collection is passed, the result will
 * be defined by your version of hhvm and not give the expected results.
 *
 * To enforce that the container is not empty, see `pop_frontx`.
 * To get the last element, see `pop_back`.
 *
 * Note that removing an item from the input array may not be "cheap." Keyed
 * containers such as `dict` can easily have the first item removed, but indexed
 * containers such as `vec` need to be wholly rewritten so the new [0] is the
 * old [1].
 *
 * Time complexity: O(1 or N): If the operation can happen in-place, O(1);
 *   if it must copy the Container, O(N).
 * Space complexity: O(1 or N): If the operation can happen in-place, O(1);
 *   if it must copy the Container, O(N).
 */
function pop_front<T as Container<Tv>, Tv>(inout T $container): ?Tv {
  if (is_empty($container)) {
    return null;
  }
  return \array_shift(inout $container);
}

/**
 * Like `pop_front` but enforces non-empty container as input.
 */
function pop_frontx<T as Container<Tv>, Tv>(inout T $container): Tv {
  invariant(
    !is_empty($container),
    '%s: Expected at least one element',
    __FUNCTION__,
  );
  return \array_shift(inout $container);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/c/introspect.php /////
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
namespace HH\Lib\C {

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
)[ctx $predicate]: bool {
  $predicate ??= \HH\Lib\_Private\boolval<>;
  foreach ($traversable as $value) {
    if ($predicate($value)) {
      return true;
    }
  }
  return false;
}

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
)[]: bool {
  if ($traversable is keyset<_>) {
    return $value is arraykey && contains_key($traversable, $value);
  }
  foreach ($traversable as $v) {
    if ($value === $v) {
      return true;
    }
  }
  return false;
}

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
)[]: bool {
  return \array_key_exists($key, $container);
}

/**
 * Returns the number of elements in the given Container.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function count(
  readonly Container<mixed> $container,
)[]: int {
  return \count($container);
}

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
)[ctx $predicate]: bool {
  $predicate ??= \HH\Lib\_Private\boolval<>;
  foreach ($traversable as $value) {
    if (!$predicate($value)) {
      return false;
    }
  }
  return true;
}

/**
 * Returns whether the given Container is empty.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
function is_empty<T>(
  readonly Container<T> $container,
)[]: bool {
  if ($container is \ConstCollection<_>) {
    return $container->isEmpty();
  }
  return !$container;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/c/deprecated.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\C {

/**
 * Returns the first element of the result of the given Awaitable, or null if
 * the Traversable is empty.
 *
 * For non-Awaitable Traversables, see `C\first`.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
<<__Deprecated('use C\\first(await #A)')>>
async function first_async<T>(
  Awaitable<Traversable<T>> $awaitable,
): Awaitable<?T> {
  return first(await $awaitable);
}

/**
 * Returns the first element of the result of the given Awaitable, or throws if
 * the Traversable is empty.
 *
 * For non-Awaitable Traversables, see `C\firstx`.
 *
 * Time complexity: O(1)
 * Space complexity: O(1)
 */
<<__Deprecated('use C\\firstx(await #A)')>>
async function firstx_async<T>(
  Awaitable<Traversable<T>> $awaitable,
): Awaitable<T> {
  return firstx(await $awaitable);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/c/order.php /////

/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\C {

use namespace HH\Lib\Vec;

/**
 * Returns true if the given Traversable<Tv> is sorted in ascending order.
 * If two neighbouring elements compare equal, this will be considered sorted.
 *
 * If no $comparator is provided, the `<=>` operator will be used.
 * This will sort numbers by value, strings by alphabetical order
 * or by the numeric value, if the strings are well-formed numbers,
 * and DateTime/DateTimeImmutable by their unixtime.
 *
 * To check the order of other types or mixtures of the
 * aforementioned types, see C\is_sorted_by.
 *
 * If the comparison operator `<=>` is not useful on Tv
 * and no $comparator is provided, the result of is_sorted
 * will not be useful.
 *
 * Time complexity: O((n * c), where c is the complexity of the
 * comparator function (which is O(1) if not provided explicitly)
 * Space complexity: O(n)
 */
function is_sorted<Tv>(
  Traversable<Tv> $traversable,
  ?(function(Tv, Tv)[_]: num) $comparator = null,
)[ctx $comparator]: bool {
  $vec = Vec\cast_clear_legacy_array_mark($traversable);
  if (is_empty($vec)) {
    return true;
  }

  $comparator ??= (Tv $a, Tv $b) ==>
    /*HH_FIXME[4240] Comparison may not be useful on Tv*/$a <=> $b;

  $previous = firstx($vec);
  foreach ($vec as $next) {
    if ($comparator($next, $previous) < 0) {
      return false;
    }
    $previous = $next;
  }

  return true;
}

/**
 * Returns true if the given Traversable<Tv> would be sorted in ascending order
 * after having been `Vec\map`ed with $scalar_func sorted in ascending order.
 * If two neighbouring elements compare equal, this will be considered sorted.
 *
 * If no $comparator is provided, the `<=>` operator will be used.
 * This will sort numbers by value, strings by alphabetical order
 * or by the numeric value, if the strings are well-formed numbers,
 * and DateTime/DateTimeImmutable by their unixtime.
 *
 * To check the order without a mapping function,
 * see `C\is_sorted`.
 *
 * If the comparison operator `<=>` is not useful on Ts
 * and no $comparator is provided, the result of is_sorted_by
 * will not be useful.
 *
 * Time complexity: O((n * c), where c is the complexity of the
 * comparator function (which is O(1) if not provided explicitly)
 * Space complexity: O(n)
 */
function is_sorted_by<Tv, Ts>(
  Traversable<Tv> $traversable,
  (function(Tv)[_]: Ts) $scalar_func,
  ?(function(Ts, Ts)[_]: num) $comparator = null,
)[ctx $scalar_func, ctx $comparator]: bool {
  $vec = Vec\cast_clear_legacy_array_mark($traversable);
  if (is_empty($vec)) {
    return true;
  }

  $comparator ??= (Ts $a, Ts $b) ==>
    /*HH_FIXME[4240] Comparison may not be useful on Ts*/$a <=> $b;

  $previous = $scalar_func(firstx($vec));
  foreach ($vec as $next) {
    $next = $scalar_func($next);
    if ($comparator($next, $previous) < 0) {
      return false;
    }
    $previous = $next;
  }

  return true;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/c/reduce.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

/**
 * C is for Containers. This file contains functions that run a calculation
 * over containers and traversables to get a single value result.
 */
namespace HH\Lib\C {

/**
 * Reduces the given Traversable into a single value by applying an accumulator
 * function against an intermediate result and each value.
 *
 * Time complexity: O(n)
 * Space complexity: O(1)
 */
function reduce<Tv, Ta>(
  Traversable<Tv> $traversable,
  (function(Ta, Tv)[_]: Ta) $accumulator,
  Ta $initial,
)[ctx $accumulator]: Ta {
  $result = $initial;
  foreach ($traversable as $value) {
    $result = $accumulator($result, $value);
  }
  return $result;
}

/**
 * Reduces the given KeyedTraversable into a single value by
 * applying an accumulator function against an intermediate result
 * and each key/value.
 *
 * Time complexity: O(n)
 * Space complexity: O(1)
 */
function reduce_with_key<Tk, Tv, Ta>(
  KeyedTraversable<Tk, Tv> $traversable,
  (function(Ta, Tk, Tv)[_]: Ta) $accumulator,
  Ta $initial,
)[ctx $accumulator]: Ta {
  $result = $initial;
  foreach ($traversable as $key => $value) {
    $result = $accumulator($result, $key, $value);
  }
  return $result;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/regex/private.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private {

use namespace HH\Lib\{Regex, Str};

/**
 * Returns the first match found in `$haystack` given the regex pattern `$pattern`
 * and an offset at which to start the search. The offset is updated to point
 * to the start of the match.
 *
 * Throws Invariant[Violation]Exception if `$offset` is not within plus/minus the length of `$haystack`
 * Returns null, or a Match containing
 *   - the entire matching string, at key 0,
 *   - the results of unnamed capture groups, at integer keys corresponding to
 *       the groups' occurrence within the pattern, and
 *   - the results of named capture groups, at string keys matching their respective names,
 */
function regex_match<T as Regex\Match>(
  string $haystack,
  Regex\Pattern<T> $pattern,
  inout int $offset,
)[]: ?T {
  $offset = validate_offset($offset, Str\length($haystack));
  list ($matches, $error) = _Regex\match($haystack, $pattern, inout $offset);
  if ($error is nonnull) {
    throw new Regex\Exception($pattern, $error);
  }
  return $matches;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/regex/exception.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Regex {

use namespace HH\Lib\Str;

final class Exception extends \Exception {
  public function __construct(Pattern<Match> $pattern, int $code)[]: void {
    $errors = dict[
      \PREG_INTERNAL_ERROR => 'Internal error',
      \PREG_BACKTRACK_LIMIT_ERROR => 'Backtrack limit error',
      \PREG_RECURSION_LIMIT_ERROR => 'Recursion limit error',
      \PREG_BAD_UTF8_ERROR => 'Bad UTF8 error',
      \PREG_BAD_UTF8_OFFSET_ERROR => 'Bad UTF8 offset error',
    ];
    parent::__construct(
      Str\format(
        "%s: %s",
        idx($errors, $code, 'Invalid pattern'),
        /* HH_FIXME[4110] Until we have a to_string() function */
        $pattern,
      ),
    );
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/regex/regex.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Regex {

use namespace HH\Lib\{_Private, Str};

/**
 * Returns the first match found in `$haystack` given the regex pattern `$pattern`
 * and an optional offset at which to start the search.
 * The regex pattern follows the PCRE library: https://www.pcre.org/original/doc/html/pcresyntax.html.
 *
 * Throws Invariant[Violation]Exception if `$offset` is not within plus/minus the length of `$haystack`.
 * Returns null if there is no match, or a Match containing
 *    - the entire matching string, at key 0,
 *    - the results of unnamed capture groups, at integer keys corresponding to
 *        the groups' occurrence within the pattern, and
 *    - the results of named capture groups, at string keys matching their respective names.
 */
function first_match<T as Match>(
  string $haystack,
  Pattern<T> $pattern,
  int $offset = 0,
)[]: ?T {
  return _Private\regex_match($haystack, $pattern, inout $offset);
}

/**
 * Returns all matches found in `$haystack` given the regex pattern `$pattern`
 * and an optional offset at which to start the search.
 * The regex pattern follows the PCRE library: https://www.pcre.org/original/doc/html/pcresyntax.html.
 *
 * Throws Invariant[Violation]Exception if `$offset` is not within plus/minus the length of `$haystack`.
 */
function every_match<T as Match>(
  string $haystack,
  Pattern<T> $pattern,
  int $offset = 0,
)[]: vec<T> {
  $haystack_length = Str\length($haystack);
  $result = vec[];
  while (true) {
    $match = _Private\regex_match($haystack, $pattern, inout $offset);
    if ($match === null) {
      break;
    }
    $result[] = $match;
    $match_length = Str\length(Shapes::at($match, 0) as string);
    if ($match_length === 0) {
      $offset++;
      if ($offset > $haystack_length) {
        break;
      }
    } else {
      $offset += $match_length;
    }
  }
  return $result;
}

/**
 * Returns whether a match exists in `$haystack` given the regex pattern `$pattern`
 * and an optional offset at which to start the search.
 * The regex pattern follows the PCRE library: https://www.pcre.org/original/doc/html/pcresyntax.html.
 *
 * Throws Invariant[Violation]Exception if `$offset` is not within plus/minus the length of `$haystack`.
 */
function matches(
  string $haystack,
  Pattern<Match> $pattern,
  int $offset = 0,
)[]: bool {
  return _Private\regex_match($haystack, $pattern, inout $offset) !== null;
}

/**
 * Returns `$haystack` with any substring matching `$pattern`
 * replaced by `$replacement`. If `$offset` is given, replacements are made
 * only starting from `$offset`.
 * The regex pattern follows the PCRE library: https://www.pcre.org/original/doc/html/pcresyntax.html.
 *
 * Throws Invariant[Violation]Exception if `$offset` is not within plus/minus the length of `$haystack`.
 */
function replace(
  string $haystack,
  Pattern<Match> $pattern,
  string $replacement,
  int $offset = 0,
)[]: string {
  // replace is the only one of these functions that calls into a native
  // helper other than match. It needs its own helper to be able to handle
  // backreferencing in the `$replacement` string. Our offset handling is
  // trivial so we do it here rather than pushing it down into the helper.
  $offset = _Private\validate_offset($offset, Str\length($haystack));

  if ($offset === 0) {
    list ($result, $error) =
      _Private\_Regex\replace($haystack, $pattern, $replacement);
    if ($error is nonnull) {
      throw new namespace\Exception($pattern, $error);
    }
    return $result as nonnull;
  }

  $haystack1 = Str\slice($haystack, 0, $offset);
  $haystack2 = Str\slice($haystack, $offset);
  list ($result, $error) =
    _Private\_Regex\replace($haystack2, $pattern, $replacement);
  if ($error is nonnull) {
    throw new namespace\Exception($pattern, $error);
  }
  return $haystack1 . ($result as nonnull);
}

/**
 * Returns `$haystack` with any substring matching `$pattern`
 * replaced by the result of `$replace_func` applied to that match.
 * If `$offset` is given, replacements are made only starting from `$offset`.
 * The regex pattern follows the PCRE library: https://www.pcre.org/original/doc/html/pcresyntax.html.
 *
 * Throws Invariant[Violation]Exception if `$offset` is not within plus/minus the length of `$haystack`.
 */
function replace_with<T as Match>(
  string $haystack,
  Pattern<T> $pattern,
  (function(T)[_]: string) $replace_func,
  int $offset = 0,
)[ctx $replace_func]: string {
  $haystack_length = Str\length($haystack);
  $result = Str\slice($haystack, 0, 0);
  $match_end = 0;
  while (true) {
    $match = _Private\regex_match($haystack, $pattern, inout $offset);
    if ($match === null) {
      break;
    }
    // Copy anything between the previous match and this one
    $result .= Str\slice($haystack, $match_end, $offset - $match_end);
    $result .= $replace_func($match);
    $match_length = Str\length(Shapes::at($match, 0) as string);
    $match_end = $offset + $match_length;
    if ($match_length === 0) {
      // To get the next match (and avoid looping forever), need to skip forward
      // before searching again
      // Note that `$offset` is for searching and `$match_end` is for copying
      $offset++;
      if ($offset > $haystack_length) {
        break;
      }
    } else {
      $offset = $match_end;
    }
  }
  $result .= Str\slice($haystack, $match_end);
  return $result;
}

/**
 * Splits `$haystack` into chunks by its substrings that match with `$pattern`.
 * If `$limit` is given, the returned vec will have at most that many elements.
 * The last element of the vec will be whatever is left of the haystack string
 * after the appropriate number of splits.
 * If no substrings of `$haystack` match `$delimiter`, a vec containing only `$haystack` will be returned.
 * The regex pattern follows the PCRE library: https://www.pcre.org/original/doc/html/pcresyntax.html.
 *
 * Throws Invariant[Violation]Exception if `$limit` < 2.
 */
function split(
  string $haystack,
  Pattern<Match> $delimiter,
  ?int $limit = null,
)[]: vec<string> {
  if ($limit === null) {
    $limit = \INF;
  }
  invariant(
    $limit > 1,
    'Expected limit greater than 1, got %d.',
    $limit,
  );
  $haystack_length = Str\length($haystack);
  $result = vec[];
  $offset = 0;
  $match_end = 0;
  $count = 1;
  $match = _Private\regex_match($haystack, $delimiter, inout $offset);
  while ($match && $count < $limit) {
    // Copy anything between the previous match and this one
    $result[] = Str\slice($haystack, $match_end, $offset - $match_end);
    $match_length = Str\length(Shapes::at($match, 0) as string);
    $match_end = $offset + $match_length;
    if ($match_length === 0) {
      // To get the next match (and avoid looping forever), need to skip forward
      // before searching again
      // Note that `$offset` is for searching and `$match_end` is for copying
      $offset++;
      if ($offset > $haystack_length) {
        break;
      }
    } else {
      $offset = $match_end;
    }
    $count++;
    $match = _Private\regex_match($haystack, $delimiter, inout $offset);
  }
  $result[] = Str\slice($haystack, $match_end);
  return $result;
}

/**
 * Renders a Regex Pattern to a string.
 * The regex pattern follows the PCRE library: https://www.pcre.org/original/doc/html/pcresyntax.html.
 */
function to_string(Pattern<Match> $pattern)[]: string {
  return $pattern as string;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/keyset/select.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Keyset {

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
)[]: keyset<Tv1> {
  if (!$first) {
    return keyset[];
  }
  if (!$second && !$rest) {
    return keyset($first);
  }
  $union = !$rest ? keyset($second) : union($second, ...$rest);
  return filter($first, $value ==> !C\contains_key($union, $value));
}
/**
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
)[]: keyset<Tv> {
  invariant($n >= 0, 'Expected non-negative N, got %d.', $n);
  $result = keyset[];
  $ii = -1;
  foreach ($traversable as $value) {
    $ii++;
    if ($ii < $n) {
      continue;
    }
    $result[] = $value;
  }
  return $result;
}

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
)[ctx $value_predicate]: keyset<Tv> {
  $value_predicate ??= \HH\Lib\_Private\boolval<>;
  $result = keyset[];
  foreach ($traversable as $value) {
    if ($value_predicate($value)) {
      $result[] = $value;
    }
  }
  return $result;
}

/**
 * Returns a new keyset containing only non-null values of the given
 * Traversable.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function filter_nulls<Tv as arraykey>(
  Traversable<?Tv> $traversable,
)[]: keyset<Tv> {
  $result = keyset[];
  foreach ($traversable as $value) {
    if ($value !== null) {
      $result[] = $value;
    }
  }
  return $result;
}

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
)[ctx $predicate]: keyset<Tv> {
  $result = keyset[];
  foreach ($traversable as $key => $value) {
    if ($predicate($key, $value)) {
      $result[] = $value;
    }
  }
  return $result;
}

/**
 * Returns a new keyset containing the keys of the given KeyedTraversable,
 * maintaining the iteration order.
 */
function keys<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: keyset<Tk> {
  $result = keyset[];
  foreach ($traversable as $key => $_) {
    $result[] = $key;
  }
  return $result;
}

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
)[]: keyset<Tv> {
  if (!$first || !$second) {
    return keyset[];
  }
  $intersection = keyset($first);
  $rest[] = $second;
  foreach ($rest as $traversable) {
    $next_intersection = keyset[];
    $keyed_traversable = keyset($traversable);
    foreach ($intersection as $value) {
      if (C\contains_key($keyed_traversable, $value)) {
        $next_intersection[] = $value;
      }
    }
    if (!$next_intersection) {
      return keyset[];
    }
    $intersection = $next_intersection;
  }
  return $intersection;
}

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
)[]: keyset<Tv> {
  if ($n === 0) {
    return keyset[];
  }
  invariant($n > 0, 'Expected non-negative N, got %d.', $n);
  $result = keyset[];
  $ii = 0;
  foreach ($traversable as $value) {
    $result[] = $value;
    $ii++;
    if ($ii === $n) {
      break;
    }
  }
  return $result;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/keyset/divide.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Keyset {

/**
 * Returns a 2-tuple containing keysets for which the given predicate returned
 * `true` and `false`, respectively.
 *
 * Time complexity: O(n * p), where p is the complexity of `$predicate`
 * Space complexity: O(n)
 */
function partition<Tv as arraykey>(
  Traversable<Tv> $traversable,
  (function(Tv)[_]: bool) $predicate,
)[ctx $predicate]: (keyset<Tv>, keyset<Tv>) {
  $success = keyset[];
  $failure = keyset[];
  foreach ($traversable as $value) {
    if ($predicate($value)) {
      $success[] = $value;
    } else {
      $failure[] = $value;
    }
  }
  return tuple($success, $failure);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/keyset/combine.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Keyset {

/**
 * Returns a new keyset containing all of the elements of the given
 * Traversables.
 *
 * For a variable number of Traversables, see `Keyset\flatten()`.
 *
 * Time complexity: O(n + m), where n is the size of `$first` and m is the
 * combined size of all the `...$rest`
 * Space complexity: O(n + m), where n is the size of `$first` and m is the
 * combined size of all the `...$rest`
 */
function union<Tv as arraykey>(
  Traversable<Tv> $first,
  Container<Tv> ...$rest
)[]: keyset<Tv> {
  $result = keyset($first);
  foreach ($rest as $traversable) {
    foreach ($traversable as $value) {
      $result[] = $value;
    }
  }
  return $result;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/keyset/transform.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Keyset {

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
)[]: vec<keyset<Tv>> {
  invariant($size > 0, 'Expected positive chunk size, got %d.', $size);
  $result = vec[];
  $ii = 0;
  $chunk_number = -1;
  foreach ($traversable as $value) {
    if ($ii % $size === 0) {
      $result[] = keyset[];
      $chunk_number++;
    }
    $result[$chunk_number][] = $value;
    $ii++;
  }
  return $result;
}

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
)[ctx $value_func]: keyset<Tv2> {
  $result = keyset[];
  foreach ($traversable as $value) {
    $result[] = $value_func($value);
  }
  return $result;
}

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
)[ctx $value_func]: keyset<Tv2> {
  $result = keyset[];
  foreach ($traversable as $key => $value) {
    $result[] = $value_func($key, $value);
  }
  return $result;
}

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
)[]: keyset<Tv> {
  $result = keyset[];
  foreach ($traversables as $traversable) {
    foreach ($traversable as $value) {
      $result[] = $value;
    }
  }
  return $result;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/keyset/introspect.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Keyset {

use namespace HH\Lib\C;

/**
 * Returns whether the two given keysets have the same elements, using strict
 * equality. To guarantee equality of order as well as contents, use `===`.
 *
 * Time complexity: O(n)
 * Space complexity: O(1)
 */
function equal<Tv as arraykey>(
  keyset<Tv> $keyset1,
  keyset<Tv> $keyset2,
)[]: bool {
  return $keyset1 == $keyset2;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/keyset/order.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Keyset {

/**
 * Returns a new keyset sorted by the values of the given Traversable. If the
 * optional comparator function isn't provided, the values will be sorted in
 * ascending order.
 *
 * Time complexity: O((n log n) * c), where c is the complexity of the
 * comparator function (which is O(1) if not explicitly provided)
 * Space complexity: O(n)
 */
function sort<Tv as arraykey>(
  Traversable<Tv> $traversable,
  ?(function(Tv, Tv)[_]: num) $comparator = null,
)[ctx $comparator]: keyset<Tv> {
  $keyset = keyset($traversable);
  if ($comparator) {
    \uksort(inout $keyset, $comparator);
  } else {
    \ksort(inout $keyset);
  }
  return keyset($keyset);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/keyset/async.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Keyset {

use namespace HH\Lib\Vec;

/**
 * Returns a new keyset containing the awaited result of the given Awaitables.
 *
 * Time complexity: O(n * a), where a is the complexity of the synchronous
 * portions of each Awaitable
 * Space complexity: O(n)
 *
 * The IO operations for each Awaitable will happen in parallel.
 */
async function from_async<Tv as arraykey>(
  Traversable<Awaitable<Tv>> $awaitables,
)[]: Awaitable<keyset<Tv>> {
  return keyset(await Vec\from_async($awaitables));
}

/**
 * Returns a new keyset containing only the values for which the given async
 * predicate returns `true`.
 *
 * For non-async predicates, see `Keyset\filter()`.
 *
 * Time complexity: O(n * p), where p is the complexity of the synchronous
 * portions of `$value_predicate`
 * Space complexity: O(n)
 *
 * The IO operations for each of the calls to `$value_predicate` will happen
 * in parallel.
 */
async function filter_async<Tv as arraykey>(
  Container<Tv> $container,
  (function(Tv)[_]: Awaitable<bool>) $value_predicate,
)[ctx $value_predicate]: Awaitable<keyset<Tv>> {
  $tests = await Vec\map_async($container, $value_predicate);
  $result = keyset[];
  $ii = 0;
  foreach ($container as $value) {
    if ($tests[$ii]) {
      $result[] = $value;
    }
    $ii++;
  }
  return $result;
}

/**
 * Returns a new keyset where the value is the result of calling the
 * given async function on the original values in the given traversable.
 *
 * Time complexity: O(n * f), where f is the complexity of the synchronous
 * portions of `$async_func`
 * Space complexity: O(n)
 *
 * The IO operations for each of calls to `$async_func` will happen in
 * parallel.
 */
async function map_async<Tv, Tk as arraykey>(
  Traversable<Tv> $traversable,
  (function(Tv)[_]: Awaitable<Tk>) $async_func,
)[ctx $async_func]: Awaitable<keyset<Tk>> {
  return keyset(await Vec\map_async($traversable, $async_func));
}

/**
 * Returns a 2-tuple containing keysets for which the given async
 * predicate returned `true` and `false`, respectively.
 *
 * For non-async predicates, see `Keyset\partition()`.
 *
 * Time complexity: O(n * p), where p is the complexity of synchronous portions
 * of `$value_predicate`
 * Space complexity: O(n)
 *
 * The IO operations for each of the calls to `$value_predicate` will happen
 * in parallel.
 */
async function partition_async<Tv as arraykey>(
  Container<Tv> $container,
  (function(Tv)[_]: Awaitable<bool>) $value_predicate,
)[ctx $value_predicate]: Awaitable<(keyset<Tv>, keyset<Tv>)> {
  $tests = await Vec\map_async($container, $value_predicate);
  $success = keyset[];
  $failure = keyset[];
  $ii = 0;
  foreach ($container as $value) {
    if ($tests[$ii]) {
      $success[] = $value;
    } else {
      $failure[] = $value;
    }
    $ii++;
  }
  return tuple($success, $failure);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/random/pseudo.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\PseudoRandom {

use namespace HH\Lib\{_Private, Math, SecureRandom};

/**
 * Returns a pseudorandom float in the range [0.0, 1.0) (i.e. the return value
 * is >= 0.0 and < 1.0). This is NOT suitable for cryptographic uses.
 *
 * For secure random floats, see `SecureRandom\float`.
 */
function float()[leak_safe]: float {
  return (float)(namespace\int(0, Math\INT53_MAX - 1) / Math\INT53_MAX);
}

/**
 * Returns a pseudorandom integer in the range from `$min` to `$max`, inclusive.
 * This is NOT suitable for cryptographic uses.
 *
 * For secure random integers, see `SecureRandom\int`.
 */
function int(
  int $min = \PHP_INT_MIN,
  int $max = \PHP_INT_MAX,
)[leak_safe]: int {
  invariant(
    $min <= $max,
    'Expected $min (%d) to be less than or equal to $max (%d).',
    $min,
    $max,
  );
  return _Private\Native\pseudorandom_int($min, $max);
}

/**
 * Returns a pseudorandom string of length `$length`. The string is composed of
 * characters from `$alphabet` if `$alphabet` is specified. This is NOT suitable
 * for cryptographic uses.
 *
 * For secure random strings, see `SecureRandom\string`.
 */
function string(
  int $length,
  ?string $alphabet = null,
)[leak_safe]: string {
  // This is a temporary alias. You should never, ever depend on this function
  // being cryptographically secure.
  return SecureRandom\string($length, $alphabet);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/random/secure.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\SecureRandom {

use namespace HH\Lib\{_Private, Math, Str};

/**
 * Returns a cryptographically secure random float in the range [0.0, 1.0)
 * (i.e. the return value is >= 0.0 and < 1.0).
 *
 * For pseudorandom floats, see `PseudoRandom\float`.
 */
function float()[leak_safe]: float {
  return (float)(namespace\int(0, Math\INT53_MAX - 1) / Math\INT53_MAX);
}

/**
 * Returns a cryptographically secure random integer in the range from `$min` to
 * `$max`, inclusive.
 *
 * For pseudorandom integers, see `PseudoRandom\int`.
 */
function int(
  int $min = \PHP_INT_MIN,
  int $max = \PHP_INT_MAX,
)[leak_safe]: int {
  invariant(
    $min <= $max,
    'Expected $min (%d) to be less than or equal to $max (%d).',
    $min,
    $max,
  );
  return _Private\Native\random_int($min, $max);
}

/**
 * Returns a securely generated random string of length `$length`. The string is
 * composed of characters from `$alphabet` if `$alphabet` is specified.
 *
 * For pseudorandom strings, see `PseudoRandom\string`.
 */
function string(
  int $length,
  ?string $alphabet = null,
)[leak_safe]: string {
  return _Private\random_string(
    ($length) ==> \random_bytes($length),
    $length,
    $alphabet,
  );
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/random/private.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private {

use namespace HH\Lib\{Math, Str};

function random_string(
  (function (int)[_]: string) $random_bytes,
  int $length,
  ?string $alphabet = null,
)[ctx $random_bytes]: string {
  invariant($length >= 0, 'Expected positive length, got %d', $length);
  if ($length === 0) {
    return '';
  }
  if ($alphabet === null) {
    return $random_bytes($length);
  }
  $alphabet_size = Str\length($alphabet);
  $bits = (int)Math\ceil(Math\log($alphabet_size, 2));
  // I do not expect us to have an alphabet with 2^56 characters. It is still
  // nice to have an upper bound, though, to avoid overflowing $unpacked_data
  invariant(
    $bits >= 1 && $bits <= 56,
    'Expected $alphabet\'s length to be in [2^1, 2^56]',
  );

  $ret = '';
  while ($length > 0) {
    // Generate twice as much data as we technically need. This is like
    // guessing "how many times do I need to flip a coin to get N heads?" I'm
    // guessing probably no more than 2N.
    $urandom_length = (int)Math\ceil(2 * $length * $bits / 8.0);
    $data = $random_bytes($urandom_length);

    $unpacked_data = 0; // The unused, unpacked data so far
    $unpacked_bits = 0; // A count of how many unused, unpacked bits we have
    for ($i = 0; $i < $urandom_length && $length > 0; ++$i) {
      // Unpack 8 bits
      $unpacked_data = ($unpacked_data << 8) | \unpack('C', $data[$i])[1];
      $unpacked_bits += 8;

      // While we have enough bits to select a character from the alphabet, keep
      // consuming the random data
      for (; $unpacked_bits >= $bits && $length > 0; $unpacked_bits -= $bits) {
        $index = ($unpacked_data & ((1 << $bits) - 1));
        $unpacked_data >>= $bits;
        // Unfortunately, the alphabet size is not necessarily a power of two.
        // Worst case, it is 2^k + 1, which means we need (k+1) bits and we
        // have around a 50% chance of missing as k gets larger
        if ($index < $alphabet_size) {
          $ret .= $alphabet[$index];
          --$length;
        }
      }
    }
  }

  return $ret;
}

const string ALPHABET_BASE64 =
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
const string ALPHABET_BASE64_URL =
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
}
///// /home/ubuntu/hhvm/hphp/hsl/src/legacy_fixme/str.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Legacy_FIXME {
use namespace HH\Lib\{C, Dict, Str, Vec};

/** Fix invalid inputs to `Str\replace_every` and similar functions.
 *
 * Replacement pairs are required to be a string-to-string map, where the key
 * is a non-empty string (as find-replace for the empty string doesn't make
 * sense).
 *
 * Previously, these requirements were not consistently enforced; the HSL would
 * sometimes raise an error, but sometimes would coerce to string, and silently
 * drop empty string keys.
 *
 * Non-string keys/values required a FIXME.
 *
 * This function is intended to be used like so:
 *
 *    $out = Str\replace_every(
 *      $in,
 *      Legacy_FIXME\coerce_possibly_invalid_str_replace_pairs($replacements)
 *    );
 *
 * Calls to this function should be removed when safe to do so.
 */
function coerce_possibly_invalid_str_replace_pairs(
  KeyedContainer<string, string> $pairs,
)[]: dict<string, string> {
  return $pairs
    |> Dict\pull_with_key($$, ($_k, $v) ==> (string) $v, ($k, $_v) ==> (string) $k)
    |> Dict\filter_keys($$, $k ==> $k !== '');
}

/** `Str\split()`, with old behavior for negative limits.
 *
 * `Str\split()` now consistently bans negative limits.
 *
 * Previously, negative limits were banned if the delimiter were the empty
 * string, but other delimiters would lead to truncation - unlike positive
 * limits, which lead to concatenation.
 *
 * For example:

 *   Str\split('a!b!c', '!') === vec['a', 'b', c']
 *   Str\split('a!b!c', '!', 2) === vec['a', 'b!c']
 *   Str\split('a!b!c', '!', -1) === vec['a', 'b']
 *
 *
 * This function reimplements this old behavior; `Str\split()` will now
 * consistently throw on negative limits.
 */
function split_with_possibly_negative_limit(
  string $string,
  string $delimiter,
  ?int $limit = null,
)[]: vec<string> {
 if ($delimiter !== '' && $limit is int && $limit < 0) {
   $full = Str\split($string, $delimiter);
   $limit += C\count($full);
   if ($limit <= 0) {
     return vec[];
   }
   return Vec\take($full, $limit);
 }
 return Str\split(
   $string,
   $delimiter,
   $limit,
  );
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/legacy_fixme/coercions.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Legacy_FIXME {
use namespace HH\Lib\{C, Math, Dict};

/**
 * Does the PHP style behaviour when doing an inc/dec operation.
 * Specially handles
 *   1. incrementing null
 *   2. inc/dec on empty and numeric strings
 */
function increment(mixed $value)[]: dynamic {
  if ($value is null) {
    return 1;
  }
  if ($value is string) {
    if (\is_numeric($value)) {
      return \HH\str_to_numeric($value) as nonnull + 1;
    }
    if ($value === '') {
      return '1';
    }
  }
  $value as dynamic;
  ++$value;
  return $value;
}

/**
 * See docs on increment
 */
function decrement(mixed $value)[]: dynamic {
  if ($value is string) {
    if (\is_numeric($value)) {
      return \HH\str_to_numeric($value) as nonnull - 1;
    }
    if ($value === '') {
      return -1;
    }
  }

  $value as dynamic;
  --$value;
  return $value;
}

/**
 * Does the PHP style behaviour for casting when doing a mathematical operation.
 * That happens under the following situations
 *   1. null converts to 0
 *   2. bool converts to 0/1
 *   3. numeric string converts to an int or double based on how the string looks.
 *   4. non-numeric string gets converted to 0
 *   5. resources get casted to int
 */
function cast_for_arithmetic(mixed $value)[]: dynamic {
  if ($value is null) {
    return 0;
  }
  if ($value is bool || $value is resource) {
    return (int)$value;
  }
  return $value is string ? \HH\str_to_numeric($value) ?? 0 : $value;
}

/**
 * Does the PHP style behaviour for casting when doing an exponentiation.
 * That happens under the following situations
 *   1. function pointers, and arrays get converted to 0
 *   2. see castForArithmatic
 */
function cast_for_exponent(mixed $value)[]: dynamic {
  if (\HH\is_class_meth($value)) {
    return $value;
  }
  if (\HH\is_fun($value) || $value is AnyArray<_, _>) {
    return 0;
  }
  return cast_for_arithmetic($value);
}

/**
 * Does the PHP style behaviour when doing <, <=, >, >=, <=>.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function lt(mixed $l, mixed $r)[]: bool {
  // avoid doing slow checks in super common case
  if ($l is string && $r is string) {
    return $l < $r;
  } else if ($l is num && $r is num) {
    return $l < $r;
  }
  return __cast_and_compare($l, $r, COMPARISON_TYPE::LT) === -1;
}
/**
 * Does the PHP style behaviour when doing <, <=, >, >=, <=>.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function lte(mixed $l, mixed $r)[]: bool {
  // avoid doing slow checks in super common case
  if ($l is string && $r is string) {
    return $l <= $r;
  } else if ($l is num && $r is num) {
    return $l <= $r;
  }
  return __cast_and_compare($l, $r, COMPARISON_TYPE::LT) !== 1;
}
/**
 * Does the PHP style behaviour when doing <, <=, >, >=, <=>.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function gt(mixed $l, mixed $r)[]: bool {
  // avoid doing slow checks in super common case
  if ($l is string && $r is string) {
    return $l > $r;
  } else if ($l is num && $r is num) {
    return $l > $r;
  }
  return __cast_and_compare($l, $r, COMPARISON_TYPE::GT) === 1;
}
/**
 * Does the PHP style behaviour when doing <, <=, >, >=, <=>.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function gte(mixed $l, mixed $r)[]: bool {
  // avoid doing slow checks in super common case
  if ($l is string && $r is string) {
    return $l >= $r;
  } else if ($l is num && $r is num) {
    return $l >= $r;
  }
  return __cast_and_compare($l, $r, COMPARISON_TYPE::GT) !== -1;
}
/**
 * Does the PHP style behaviour when doing <, <=, >, >=, <=>.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function cmp(mixed $l, mixed $r)[]: int {
  // avoid doing slow checks in super common case
  if ($l is string && $r is string) {
    return $l <=> $r;
  } else if ($l is num && $r is num) {
    return $l <=> $r;
  }
  return __cast_and_compare($l, $r, COMPARISON_TYPE::CMP);
}

/**
 * Does the PHP style behaviour when doing == or ===.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function eq(mixed $l, mixed $r)[]: bool {
  // avoid doing slow checks in super common case
  if (
    ($l is int && $r is int) ||
    ($l is float && $r is float) ||
    ($l is bool && $r is bool) ||
    ($l is string && $r is string && (!\is_numeric($l) || !\is_numeric($r)))
  ) {
    return $l == $r;
  }
  return __cast_and_compare($l, $r, COMPARISON_TYPE::EQ) === 0;
}

/**
 * Does the PHP style behaviour when doing == or ===.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function neq(mixed $l, mixed $r)[]: bool {
  // avoid doing slow checks in super common case
  if (
    ($l is int && $r is int) ||
    ($l is float && $r is float) ||
    ($l is bool && $r is bool) ||
    ($l is string && $r is string && (!\is_numeric($l) || !\is_numeric($r)))
  ) {
    return $l != $r;
  }
  return __cast_and_compare($l, $r, COMPARISON_TYPE::EQ) !== 0;
}

enum COMPARISON_TYPE: int {
  GT = 0;
  LT = 1;
  CMP = 2;
  EQ = 3;
}

/**
 * Do the casts PHP would do before doing <, <=, >, >=, <=>.
 * Then, do a modified form of <=> that correctl handles what gt/lt would do
 * in the different situations
 *
 * Note that this specifically doesn't handle coercions that would just trigger
 * exceptions from within hhvm by default. Instead we trigger the
 * exceptions here manually as part of the <=> invocation
 */
function __cast_and_compare(mixed $l, mixed $r, COMPARISON_TYPE $ctype)[]: int {
  if ($r is bool && !(\HH\is_fun($l) || \HH\is_class_meth($l))) {
    if (!($l is AnyArray<_, _>)) {
      $l = (bool)$l;
    } else if ($ctype === COMPARISON_TYPE::EQ) {
      $l = !C\is_empty($l);
    }
  } else if ($r is null) {
    if ($l is string) {
      $r = '';
    } else if (\is_object($l)) {
      $l = true;
      $r = false;
    } else {
      return __cast_and_compare($l, false, $ctype);
    }
  } else if (
    \HH\is_fun($r) ||
    \HH\is_fun($l) ||
    \HH\is_class_meth($r) ||
    \HH\is_class_meth($l)
  ) {
    // no-op.
  } else if ($r is num) {
    if ($l is null) {
      $l = false;
      $r = (bool)$r;
    } else if ($l is bool) {
      $r = (bool)$r;
    } else if ($l is string) {
      $l = \HH\str_to_numeric($l) ?? 0;
    } else if (
      $l is resource || (\is_object($l) && !($l is \ConstCollection<_>))
    ) {
      $l = $r is int ? (int)$l : (float)$l;
    }
    // if we're ==/!= an int and a float, convert both to float
    if (
      $ctype === COMPARISON_TYPE::EQ &&
      $r is num &&
      $l is num &&
      $r is int !== $l is int
    ) {
      $l = (float)$l;
      $r = (float)$r;
    }
  } else if ($r is string) {
    if ($l is null) {
      $l = '';
    } else if ($l is bool) {
      $r = (bool)$r;
    } else if ($l is num) {
      $r = \HH\str_to_numeric($r) ?? 0;
      return __cast_and_compare($l, $r, $ctype);
    } else if (\is_object($l)) {
      if ($l is \StringishObject && !($l is \ConstCollection<_>)) {
        $l = (string)$l;
      } else if (!($l is \ConstCollection<_>)) {
        $l = true;
        $r = false;
      }
    } else if ($l is resource) {
      $l = (float)$l;
      $r = (float)$r;
    } else if (
      $l is string &&
      $ctype === COMPARISON_TYPE::EQ &&
      \is_numeric($l) &&
      \is_numeric($r)
    ) {
      $l = \HH\str_to_numeric($l);
      $r = \HH\str_to_numeric($r);
      return __cast_and_compare($l, $r, $ctype);
    }
  } else if ($r is resource) {
    if ($l is null) {
      $l = false;
      $r = true;
    } else if ($l is bool) {
      // @lint-ignore CAST_NON_PRIMITIVE 2fax
      $r = (bool)$r;
    } else if ($l is num) {
      // @lint-ignore CAST_NON_PRIMITIVE 2fax
      $r = $l is int ? (int)$r : (float)$r;
    } else if ($l is string) {
      $l = (float)$l;
      // @lint-ignore CAST_NON_PRIMITIVE 2fax
      $r = (float)$r;
    } else if (\is_object($l)) {
      $l = true;
      $r = false;
    }
  } else if ($r is AnyArray<_, _> && ($l is null || $l is bool)) {
    if ($l is null) {
      $l = false;
    }
    if ($ctype === COMPARISON_TYPE::EQ) {
      $r = !C\is_empty($r);
    }
  } else if (
    ($r is vec<_> && $l is vec<_>) ||
    (
      $ctype === COMPARISON_TYPE::EQ &&
      $r is \ConstVector<_> &&
      $l is \ConstVector<_>
    )
  ) {
    if (C\count($l) !== C\count($r)) {
      return C\count($l) > C\count($r) ? 1 : -1;
    }
    foreach ($l as $i => $li) {
      $ri = $r[$i];
      $res = __cast_and_compare($li, $ri, $ctype);
      if ($res !== 0) {
        if (
          $ctype === COMPARISON_TYPE::GT &&
          \is_object($ri) &&
          \is_object($li) &&
          (\get_class($li) !== \get_class($ri) || $li is \Closure) &&
          !($li is \DateTimeInterface && $ri is \DateTimeInterface)
        ) {
          // flip the result :p
          return $res === -1 ? 1 : -1;
        }
        return $res;
      }
    }
    return 0;
  } else if (
    $ctype === COMPARISON_TYPE::EQ &&
    (
      ($r is dict<_, _> && $l is dict<_, _>) ||
      ($r is \ConstMap<_, _> && $l is \ConstMap<_, _>) ||
      ($r is \ConstSet<_> && $l is \ConstSet<_>)
    )
  ) {
    if (C\count($l) !== C\count($r)) return 1;
    foreach ($l as $i => $li) {
      if (
        /* HH_FIXME[4324] I've just confirmed this is safe */
        /* HH_FIXME[4005] Set is KeyedContainer... */
        !C\contains_key($r, $i) || __cast_and_compare($li, $r[$i], $ctype) !== 0
      ) {
        return 1;
      }
    }
    return 0;
  } else if (\is_object($r)) {
    if (
      $l is string && $r is \StringishObject && !($r is \ConstCollection<_>)
    ) {
      $r = (string)$r;
    } else if (
      $l is null ||
      $l is resource ||
      ($l is string && !($r is \ConstCollection<_>))
    ) {
      $l = false;
      $r = true;
    } else if ($l is num && !($r is \ConstCollection<_>)) {
      // this probably throws, but sometimes it doesn't!
      $r = $l is int ? (int)$r : (float)$r;
    } else if ($l is bool) {
      $r = (bool)$r;
    } else if (
      \is_object($l) &&
      !($l is \ConstCollection<_> || $r is \ConstCollection<_>) &&
      $l !== $r &&
      !($l is \DateTimeInterface && $r is \DateTimeInterface)
    ) {
      if (\get_class($l) !== \get_class($r) || $l is \Closure) {
        return $ctype === COMPARISON_TYPE::GT ? -1 : 1;
      } else if (!($l is \SimpleXMLElement)) {
        $l = \HH\object_prop_array($l);
        $r = \HH\object_prop_array($r);
        if (C\count($l) !== C\count($r)) {
          return C\count($l) > C\count($r) ? 1 : -1;
        }

        $loop_var = $ctype === COMPARISON_TYPE::GT ? $r : $l;
        $other_var = $ctype === COMPARISON_TYPE::GT ? $l : $r;
        foreach ($loop_var as $i => $_) {
          if (!C\contains_key($other_var, $i)) {
            // dyn prop in a but not b
            return $ctype === COMPARISON_TYPE::GT ? -1 : 1;
          }
          $li = $l[$i];
          $ri = $r[$i];
          $res = __cast_and_compare($li, $ri, $ctype);
          if ($res !== 0) {
            if (
              ($li is float && Math\is_nan($li)) ||
              ($ri is float && Math\is_nan($ri))
            ) {
              // in the case of NAN && GT, straight up flip the result
              return $ctype === COMPARISON_TYPE::GT && $res === -1 ? 1 : -1;
            }
            return $res;
          }
        }
        return 0;
      }
    }
  }

  if (($l is float && Math\is_nan($l)) || ($r is float && Math\is_nan($r))) {
    // trigger exception if necessary
    $_r = $ctype === COMPARISON_TYPE::EQ
      ? ($l as dynamic) == ($r as dynamic)
      : ($l as dynamic) <=> ($r as dynamic);
    return $ctype === COMPARISON_TYPE::LT ? 1 : -1;
  }

  if ($ctype === COMPARISON_TYPE::EQ) {
    return (int)($l != $r);
  }
  return ($l as dynamic) <=> ($r as dynamic);
}

const int SWITCH_INT_SENTINEL = 7906240793;

/**
 * Do a modification on the switched value. This is in the case where the
 * switched expr is an ?arraykey
 */
function optional_arraykey_to_int_cast_for_switch(?arraykey $value)[]: int {
  if ($value is null) return 0;
  if ($value is string) $value = \HH\str_to_numeric($value) ?? 0;
  if ($value is int) return $value;
  return Math\floor($value) === $value ? (int)$value : SWITCH_INT_SENTINEL;
}

/**
 * Do a modification on the switched value. This is in the case where the
 * switched expr is an ?num
 */
function optional_num_to_int_cast_for_switch(?num $value)[]: int {
  if ($value is int) return $value;
  if ($value is null) return 0;
  return Math\floor($value) === $value ? (int)$value : SWITCH_INT_SENTINEL;

}

/**
   * The rules for coercion when doing a comparison where the RHS is an int
   * are complicated and it's not sufficient to just do straight casts on $value.
   * Instead, we need to do some data tracking to convert the input to specifics
   * values to match specific cases under different circumstances.
   *
   * arraykey instead of int second arg courtesy of non-transparent enums
   */
function int_cast_for_switch(
  mixed $value,
  ?arraykey $first_truthy = null,
)[]: int {
  if ($value is int) return $value;
  if ($value is null) return 0;

  if ($value is string) {
    $value = \HH\str_to_numeric($value) ?? 0;
    if ($value is int) return $value;
    // fallthrough
  }
  if ($value is float) {
    return Math\floor($value) === $value ? (int)$value : SWITCH_INT_SENTINEL;
  }

  if ($value === false) return 0;
  if ($value === true) return $first_truthy as ?int ?? SWITCH_INT_SENTINEL;

  if ($value is resource) return (int)$value;

  if (\is_object($value) && !($value is \ConstCollection<_>)) {
    return (int)($value as dynamic); // this will probably throw
  }

  return SWITCH_INT_SENTINEL;
}


const string SWITCH_STRING_SENTINEL =
  'This string is to force fail matching a case';

/**
 * Do a modification on the switched value. This is in the case where none
 * of the case options are falsy, intish, or floatish
 *
 * arraykey instead of string for second arg courtesy of non-transparent enums
 */
function string_cast_for_basic_switch(
  mixed $value,
  ?arraykey $first_case,
)[]: string {
  if ($value is string) return $value;
  if ($value is null) return '';
  // check for 0ish or true
  if (($value is num && !$value) || ($value is bool && $value)) {
    return ($first_case as ?string) ?? SWITCH_STRING_SENTINEL;
  }
  if ($value is \StringishObject && !($value is \ConstCollection<_>)) {
    return (string)($value as dynamic); // this will throw
  }
  return SWITCH_STRING_SENTINEL;
}

/**
 * The rules for coercion when doing a comparison where the RHS is a string
 * are complicated and it's not sufficient to just do straight casts on $value.
 * Instead, we need to do some data tracking to convert the input to specifics
 * values to match specific cases under different circumstances.
 *
 * arraykey instead of string for second arg courtesy of non-transparent enums *
 */
function string_cast_for_switch(
  mixed $value,
  ?arraykey $first_truthy = null,
  ?arraykey $first_zeroish = null,
  ?arraykey $first_falsy = null,
  dict<arraykey, int> $intish_vals = dict[],
  dict<arraykey, float> $floatish_vals = dict[],
)[]: string {
  $default = SWITCH_STRING_SENTINEL;
  $orig_is_str = $value is string;
  if ($value is string) {
    if (!\is_numeric($value)) return $value;
    $default = $value;
    $value = \HH\str_to_numeric($value) as nonnull;
    // fallthrough
  }

  if ($value is null) return '';

  if ($value is resource) $value = (float)($value);

  if ($value is float) {
    if (Math\floor($value) === $value) {
      $value = (int)$value;
      // fallthrough
    } else {
      if ($orig_is_str) {
        $floatish_vals = Dict\filter_keys($floatish_vals, \is_numeric<>);
      }
      return C\find_key($floatish_vals, $n ==> $n === $value) as ?string ??
        $default;
    }
  }
  if ($value is int) {
    if ($orig_is_str) {
      $intish_vals = Dict\filter_keys($intish_vals, \is_numeric<>);
      // fallthrough
    } else if ($value === 0) {
      return $first_zeroish as ?string ?? $default;
    }
    return C\find_key($intish_vals, $n ==> $n === $value) as ?string ??
      $default;
  }

  if ($value === true) {
    return $first_truthy as ?string ?? SWITCH_STRING_SENTINEL;
  }
  if ($value === false) {
    return $first_falsy as ?string ?? SWITCH_STRING_SENTINEL;
  }

  if ($value is \StringishObject && !($value is \ConstCollection<_>)) {
    return (string)($value as dynamic); // this will throw
  }

  return SWITCH_STRING_SENTINEL;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/vec/select.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Vec {

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
)[]: vec<Tv1> {
  if (!$first) {
    return vec[];
  }
  if (!$second && !$rest) {
    return cast_clear_legacy_array_mark($first);
  }
  $union = !$rest
    ? keyset($second)
    : Keyset\union($second, ...$rest);
  return filter(
    $first,
    ($value) ==> !C\contains_key($union, $value),
  );
}

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
)[ctx $scalar_func]: vec<Tv> {
  if (!$first) {
    return vec[];
  }
  if (!$second) {
    return cast_clear_legacy_array_mark($first);
  }
  $set = Keyset\map($second, $scalar_func);
  return filter(
    $first,
    ($value) ==> !C\contains_key($set, $scalar_func($value)),
  );
}

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
)[]: vec<Tv> {
  invariant($n >= 0, 'Expected non-negative N, got %d.', $n);
  $result = vec[];
  $ii = -1;
  foreach ($traversable as $value) {
    $ii++;
    if ($ii < $n) {
      continue;
    }
    $result[] = $value;
  }
  return $result;
}

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
)[ctx $value_predicate]: vec<Tv> {
  $value_predicate ??= _Private\boolval<>;
  $result = vec[];
  foreach ($traversable as $value) {
    if ($value_predicate($value)) {
      $result[] = $value;
    }
  }
  return $result;
}

/**
 * Returns a new vec containing only non-null values of the given
 * Traversable.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function filter_nulls<Tv>(
  Traversable<?Tv> $traversable,
)[]: vec<Tv> {
  $result = vec[];
  foreach ($traversable as $value) {
    if ($value !== null) {
      $result[] = $value;
    }
  }
  return $result;
}

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
)[ctx $predicate]: vec<Tv> {
  $result = vec[];
  foreach ($traversable as $key => $value) {
    if ($predicate($key, $value)) {
      $result[] = $value;
    }
  }
  return $result;
}

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
)[]: vec<Tv> {
  $intersection = Keyset\intersect($first, $second, ...$rest);
  if (!$intersection) {
    return vec[];
  }
  return filter(
    $first,
    ($value) ==> C\contains_key($intersection, $value),
  );
}

/**
 * Returns a new vec containing the keys of the given KeyedTraversable.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function keys<Tk, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: vec<Tk> {
  $result = vec[];
  foreach ($traversable as $key => $_) {
    $result[] = $key;
  }
  return $result;
}

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
): vec<Tv> {
  invariant(
    $sample_size >= 0,
    'Expected non-negative sample size, got %d.',
    $sample_size,
  );
  return $traversable
    |> shuffle($$)
    |> take($$, $sample_size);
}

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
)[]: vec<Tv> {
  invariant($length === null || $length >= 0, 'Expected non-negative length.');
  $offset = _Private\validate_offset_lower_bound($offset, C\count($container));
  return cast_clear_legacy_array_mark(\array_slice($container, $offset, $length));
}

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
)[]: vec<Tv> {
  if ($n === 0) {
    return vec[];
  }
  invariant($n > 0, 'Expected non-negative N, got %d.', $n);
  $result = vec[];
  $ii = 0;
  foreach ($traversable as $value) {
    $result[] = $value;
    $ii++;
    if ($ii === $n) {
      break;
    }
  }
  return $result;
}

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
)[]: vec<Tv> {
  return vec(keyset($traversable));
}

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
)[ctx $scalar_func]: vec<Tv> {
  return vec(Dict\from_values($traversable, $scalar_func));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/vec/divide.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Vec {

/**
 * Returns a 2-tuple containing vecs for which the given predicate returned
 * `true` and `false`, respectively.
 *
 * Time complexity: O(n * p), where p is the complexity of `$predicate`
 * Space complexity: O(n)
 */
function partition<Tv>(
  Traversable<Tv> $traversable,
  (function(Tv)[_]: bool) $predicate,
)[ctx $predicate]: (vec<Tv>, vec<Tv>) {
  $success = vec[];
  $failure = vec[];
  foreach ($traversable as $value) {
    if ($predicate($value)) {
      $success[] = $value;
    } else {
      $failure[] = $value;
    }
  }
  return tuple($success, $failure);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/vec/combine.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Vec {

use namespace HH\Lib\{C, Math};

/**
 * Returns a new vec formed by concatenating the given Traversables together.
 *
 * For a variable number of Traversables, see `Vec\flatten()`.
 *
 * Time complexity: O(n + m), where n is the size of `$first` and m is the
 * combined size of all the `...$rest`
 * Space complexity: O(n + m), where n is the size of `$first` and m is the
 * combined size of all the `...$rest`
 */
function concat<Tv>(
  Traversable<Tv> $first,
  Container<Tv> ...$rest
)[]: vec<Tv> {
  $result = cast_clear_legacy_array_mark($first);
  foreach ($rest as $traversable) {
    foreach ($traversable as $value) {
      $result[] = $value;
    }
  }
  return $result;
}

/**
 * Returns a vec where each element is a tuple (pair) that combines, pairwise,
 * the elements of the two given Traversables.
 *
 * If the Traversables are not of equal length, the result will have
 * the same number of elements as the shortest Traversable.
 * Elements of the longer Traversable after the length of the shorter one
 * will be ignored.
 *
 * Time complexity: O(min(m, n)), where m is the size of `$first` and n is the
 * size of `$second`
 * Space complexity: O(min(m, n)), where m is the size of `$first` and n is the
 * size of `$second`
 */
<<__ProvenanceSkipFrame>>
function zip<Tv, Tu>(
  Traversable<Tv> $first,
  Traversable<Tu> $second,
)[]: vec<(Tv, Tu)> {
  $one = cast_clear_legacy_array_mark($first);
  $two = cast_clear_legacy_array_mark($second);
  $result = vec[];
  $lesser_count = Math\minva(C\count($one), C\count($two));
  for ($i = 0; $i < $lesser_count; ++$i) {
    $result[] = tuple($one[$i], $two[$i]);
  }
  return $result;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/vec/transform.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Vec {

use namespace HH\Lib\Math;

/**
 * Returns a vec containing the original vec split into chunks of the given
 * size. If the original vec doesn't divide evenly, the final chunk will be
 * smaller.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function chunk<Tv>(
  Traversable<Tv> $traversable,
  int $size,
)[]: vec<vec<Tv>> {
  invariant($size > 0, 'Expected positive chunk size, got %d.', $size);
  $result = vec[];
  $ii = 0;
  $chunk_number = -1;
  foreach ($traversable as $value) {
    if ($ii % $size === 0) {
      $result[] = vec[];
      $chunk_number++;
    }

    $result[$chunk_number][] = $value;
    $ii++;
  }
  return $result;
}

/**
 * Returns a new vec of size `$size` where all the values are `$value`.
 *
 * If you need a range of items not repeats, use `Vec\range(0, $n - 1)`.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function fill<Tv>(
  int $size,
  Tv $value,
)[]: vec<Tv> {
  invariant($size >= 0, 'Expected non-negative fill size, got %d.', $size);
  $result = vec[];
  for ($i = 0; $i < $size; $i++) {
    $result[] = $value;
  }
  return $result;
}

/**
 * Returns a new vec formed by joining the Traversable elements of the given
 * Traversable.
 *
 * For a fixed number of Traversables, see `Vec\concat()`.
 *
 * Time complexity: O(n), where n is the combined size of all the
 * `$traversables`
 * Space complexity: O(n), where n is the combined size of all the
 * `$traversables`
 */
function flatten<Tv>(
  Traversable<Container<Tv>> $traversables,
)[]: vec<Tv> {
  $result = vec[];
  foreach ($traversables as $traversable) {
    foreach ($traversable as $value) {
      $result[] = $value;
    }
  }
  return $result;
}

/**
 * Returns a new vec where each value is the result of calling the given
 * function on the original value.
 *
 * For async functions, see `Vec\map_async()`.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
<<__ProvenanceSkipFrame>>
function map<Tv1, Tv2>(
  Traversable<Tv1> $traversable,
  (function(Tv1)[_]: Tv2) $value_func,
)[ctx $value_func]: vec<Tv2> {
  $result = vec[];
  foreach ($traversable as $value) {
    $result[] = $value_func($value);
  }
  return $result;
}

/**
 * Returns a new vec where each value is the result of calling the given
 * function on the original key and value.
 *
 * Time complexity: O(n * f), where f is the complexity of `$value_func`
 * Space complexity: O(n)
 */
function map_with_key<Tk, Tv1, Tv2>(
  KeyedTraversable<Tk, Tv1> $traversable,
  (function(Tk, Tv1)[_]: Tv2) $value_func,
)[ctx $value_func]: vec<Tv2> {
  $result = vec[];
  foreach ($traversable as $key => $value) {
    $result[] = $value_func($key, $value);
  }
  return $result;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/vec/order.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Vec {

use namespace HH\Lib\{C, Dict, Math, Str};

/**
 * Returns a new vec containing the range of numbers from `$start` to `$end`
 * inclusive, with the step between elements being `$step` if provided, or 1 by
 * default. If `$start > $end`, it returns a descending range instead of
 * an empty one.
 *
 * If you don't need the items to be enumerated, consider Vec\fill.
 *
 * Time complexity: O(n), where `n` is the size of the resulting vec
 * Space complexity: O(n), where `n` is the size of the resulting vec
 */
function range<Tv as num>(
  Tv $start,
  Tv $end,
  ?Tv $step = null,
)[]: vec<Tv> {
  $step ??= 1;
  invariant($step > 0, 'Expected positive step.');
  if ($step > Math\abs($end - $start)) {
    return vec[$start];
  }
  return vec(\range($start, $end, $step));
}

/**
 * Returns a new vec with the values of the given Traversable in reversed
 * order.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function reverse<Tv>(
  Traversable<Tv> $traversable,
)[]: vec<Tv> {
  $vec = cast_clear_legacy_array_mark($traversable);
  for ($lo = 0, $hi = C\count($vec) - 1; $lo < $hi; $lo++, $hi--) {
    $temp = $vec[$lo];
    $vec[$lo] = $vec[$hi];
    $vec[$hi] = $temp;
  }
  return $vec;
}

/**
 * Returns a new vec with the values of the given Traversable in a random
 * order.
 *
 * Vec\shuffle is not using cryptographically secure randomness.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function shuffle<Tv>(
  Traversable<Tv> $traversable,
)[leak_safe]: vec<Tv> {
  $vec = cast_clear_legacy_array_mark($traversable);
  \shuffle(inout $vec);
  return $vec;
}

/**
 * Returns a new vec sorted by the values of the given Traversable. If the
 * optional comparator function isn't provided, the values will be sorted in
 * ascending order.
 *
 * To sort by some computable property of each value, see `Vec\sort_by()`.
 *
 * Time complexity: O((n log n) * c), where c is the complexity of the
 * comparator function (which is O(1) if not provided explicitly)
 * Space complexity: O(n)
 */
function sort<Tv>(
  Traversable<Tv> $traversable,
  ?(function(Tv, Tv)[_]: num) $comparator = null,
)[ctx $comparator]: vec<Tv> {
  $vec = cast_clear_legacy_array_mark($traversable);
  if ($comparator) {
    \usort(inout $vec, $comparator);
  } else {
    \sort(inout $vec);
  }
  return $vec;
}

/**
 * Returns a new vec sorted by some scalar property of each value of the given
 * Traversable, which is computed by the given function. If the optional
 * comparator function isn't provided, the values will be sorted in ascending
 * order of scalar key.
 *
 * To sort by the values of the Traversable, see `Vec\sort()`.
 *
 * Time complexity: O((n log n) * c + n * s), where c is the complexity of the
 * comparator function (which is O(1) if not provided explicitly) and s is the
 * complexity of the scalar function
 * Space complexity: O(n)
 */
function sort_by<Tv, Ts>(
  Traversable<Tv> $traversable,
  (function(Tv)[_]: Ts) $scalar_func,
  ?(function(Ts, Ts)[_]: num) $comparator = null,
)[ctx $scalar_func, ctx $comparator]: vec<Tv> {
  $vec = cast_clear_legacy_array_mark($traversable);
  $order_by = Dict\map($vec, $scalar_func);
  if ($comparator) {
    \uasort(inout $order_by, $comparator);
  } else {
    \asort(inout $order_by);
  }
  return map_with_key($order_by, ($k, $v) ==> $vec[$k]);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/vec/async.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Vec {

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
)[]: Awaitable<vec<Tv>> {
  $vec = cast_clear_legacy_array_mark($awaitables);

  /* HH_FIXME[4390] Magic Function */
  await AwaitAllWaitHandle::fromVec($vec);
  foreach ($vec as $index => $value) {
    /* HH_FIXME[4390] Magic Function */
    $vec[$index] = \HH\Asio\result($value);
  }
  /* HH_FIXME[4110] Reuse the existing vec to reduce peak memory. */
  return $vec;
}

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
)[ctx $value_predicate]: Awaitable<vec<Tv>> {
  $tests = await map_async($container, $value_predicate);
  $result = vec[];
  $ii = 0;
  foreach ($container as $value) {
    if ($tests[$ii]) {
      $result[] = $value;
    }
    $ii++;
  }
  return $result;
}

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
)[ctx $async_func]: Awaitable<vec<Tv2>> {
  $vec = cast_clear_legacy_array_mark($traversable);
  foreach ($vec as $i => $value) {
    $vec[$i] = $async_func($value);
  }

  /* HH_FIXME[4110] Okay to pass in Awaitable */
  /* HH_FIXME[4390] Magic Function */
  await AwaitAllWaitHandle::fromVec($vec);
  foreach ($vec as $index => $value) {
    /* HH_FIXME[4110] Reuse the existing vec to reduce peak memory. */
    /* HH_FIXME[4390] Magic Function */
    $vec[$index] = \HH\Asio\result($value);
  }
  /* HH_FIXME[4110] Reuse the existing vec to reduce peak memory. */
  return $vec;
}

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
)[ctx $value_predicate]: Awaitable<(vec<Tv>, vec<Tv>)> {
  $tests = await map_async($container, $value_predicate);
  $success = vec[];
  $failure = vec[];
  $ii = 0;
  foreach ($container as $value) {
    if ($tests[$ii]) {
      $success[] = $value;
    } else {
      $failure[] = $value;
    }
    $ii++;
  }
  return tuple($success, $failure);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/vec/cast.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Vec {

/**
 * Casts the given traversable to a vec, resetting the legacy array mark
 * if applicable.
 */
function cast_clear_legacy_array_mark<T>(
  Traversable<T> $x,
)[]: vec<T> {
  return ($x is vec<_>)
    ? vec(\HH\array_unmark_legacy($x))
    : vec($x);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/network/SocketOptions.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Network {

type SocketOptions = shape(
  ?'SO_REUSEADDR' => bool,
);
}
///// /home/ubuntu/hhvm/hphp/hsl/src/network/IPProtocolBehavior.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Network {

/** General behavior for selecting which IP version to use.
 *
 * Use `IPProtocolVersion` instead if a specific version is required.
 */
enum IPProtocolBehavior: int {
  PREFER_IPV6 = 0;
  FORCE_IPV6 = 6;
  FORCE_IPV4 = 4;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/network/CloseableSocket.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Network {

use namespace HH\Lib\{IO, TCP, Unix};

<<
  __Sealed(
    TCP\CloseableSocket::class,
    Unix\CloseableSocket::class,
  ),
>>
interface CloseableSocket extends Socket, IO\CloseableReadWriteHandle {
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/network/_Private/socket_connect_async.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_Network {

use namespace HH\Lib\OS;
use namespace HH\Lib\_Private\_OS;

/** Asynchronously connect to a socket.
 *
 * Returns a PHP Socket Error Code:
 * - 0 for success
 * - errno if > 0
 * - -(10000 + h_errno) if < 0
 */
async function socket_connect_async(
  OS\FileDescriptor $sock,
  OS\sockaddr $sa,
  int $timeout_ns,
): Awaitable<void> {
  $opts = OS\fcntl($sock, OS\FcntlOp::F_GETFL);
  OS\fcntl($sock, OS\FcntlOp::F_SETFL, ($opts as int) | OS\O_NONBLOCK);
  try {
    OS\connect($sock, $sa);
  } catch (OS\BlockingIOException $_) {
    // connect(2) documents non-blocking sockets as being ready for write
    // when complete
    try {
      $res = await _OS\poll_async($sock, \STREAM_AWAIT_WRITE, $timeout_ns);
    } catch (\Exception $e) {
      throw $e;
    }
    if ($res === \STREAM_AWAIT_CLOSED) {
      _OS\throw_errno(OS\Errno::ECONNRESET, 'connect');
    }
    if ($res === \STREAM_AWAIT_TIMEOUT) {
      _OS\throw_errno(OS\Errno::ETIMEDOUT, 'connect');
    }

    $errno = _OS\wrap_impl(
      () ==> _OS\getsockopt_int($sock, _OS\SOL_SOCKET, _OS\SO_ERROR),
    );

    if ($errno !== 0) {
      _OS\throw_errno($errno as OS\Errno, 'connect() failed');
    }
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/network/_Private/socket_accept_async.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_Network {

use namespace HH\Lib\OS;
use namespace HH\Lib\_Private\_OS;
/** Accept a socket connection, waiting if necessary */
async function socket_accept_async(
  OS\FileDescriptor $server,
): Awaitable<OS\FileDescriptor> {
  try {
    list($fd, $_addr) = OS\accept($server);
    return $fd;
  } catch (OS\BlockingIOException $_) {
    // accept (3P) defines select() as indicating the FD ready for read when there's a connection
    try {
      $result = await _OS\poll_async(
        $server,
        \STREAM_AWAIT_READ, /* timeout = */
        0,
      );
    } catch (_OS\ErrnoException $e) {
      _OS\throw_errno($e->getCode() as OS\Errno, '%s', $e->getMessage());
    }
    if ($result === \STREAM_AWAIT_CLOSED) {
      _OS\throw_errno(
        OS\Errno::ECONNABORTED,
        "Server socket closed while waiting for connection",
      );
    }
    list($fd, $_addr) = OS\accept($server);
    return $fd;
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/network/_Private/resolve_hostname.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_Network {

use namespace HH\Lib\{Network, OS};
use namespace HH\Lib\_Private\{_Network, _OS, _TCP};

/** A poor alternative to OS\getaddrinfo, which doesn't exist yet. */
function resolve_hostname(OS\AddressFamily $af, string $host): ?string {
  // FIXME: add OS\getaddrinfo, kill this function.
  switch ($af) {
    case OS\AddressFamily::AF_INET:
      // if it's already a valid IP, it just returns the input.
      return \gethostbyname($host);
    case OS\AddressFamily::AF_INET6:
      if (\filter_var($host, \FILTER_VALIDATE_IP, \FILTER_FLAG_IPV6)) {
        return $host;
      }
      $authns = null;
      $addtl = null;
      return \dns_get_record(
        $host,
        \DNS_AAAA,
        inout $authns,
        inout $addtl,
      )['AAAA'] ??
        null;
    default:
      _OS\throw_errno(
        OS\Errno::EAFNOSUPPORT,
        "Can only resolve hostnames to IPv4 and IPv6 addresses",
      );
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/network/_Private/socket_create_bind_listen_async.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_Network {

use namespace HH\Lib\{Network, OS};
use namespace HH\Lib\_Private\_OS;

/** Create a server socket and start listening */
async function socket_create_bind_listen_async(
  OS\SocketDomain $domain,
  OS\SocketType $type,
  int $proto,
  OS\sockaddr $addr,
  int $backlog,
  Network\SocketOptions $socket_options,
): Awaitable<OS\FileDescriptor> {
  $sock = OS\socket($domain, $type, $proto);

  if ($socket_options['SO_REUSEADDR'] ?? false) {
    _OS\wrap_impl(
      () ==> _OS\setsockopt_int($sock, _OS\SOL_SOCKET, _OS\SO_REUSEADDR, 1),
    );
  }
  $ops = OS\fcntl($sock, OS\FcntlOp::F_GETFL);
  OS\fcntl($sock, OS\FcntlOp::F_SETFL, ($ops as int) | OS\O_NONBLOCK);

  try {
    OS\bind($sock, $addr);
  } catch (OS\BlockingIOException $_) {
    await _OS\poll_async($sock, \STREAM_AWAIT_READ_WRITE, /* timeout = */ 0);

    $errno = _OS\wrap_impl(
      () ==> _OS\getsockopt_int($sock, _OS\SOL_SOCKET, _OS\SO_ERROR),
    ) as OS\Errno;
    if ($errno !== 0) {
      _OS\throw_errno($errno, 'bind() failed');
    }
  }

  OS\listen($sock, $backlog);

  return $sock;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/network/IPProtocolVersion.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Network {

/** A specific version of IP.
 *
 * Use `IPProtocolBehavior` instead if possible.
 */
enum IPProtocolVersion : int {
  IPV6 = 6;
  IPV4 = 4;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/network/Server.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Network {

/** Generic interface for a class able to accept socket connections.
 *
 * @see Unix\Server
 * @see TCP\Server
 */
interface Server<TSock as Socket> {
  /** The type of address used by this socket.
   *
   * For example, this is likely to be a string path for Unix sockets,
   * or hostname and port for TCP sockets.
   */
  abstract const type TAddress;

  /** Retrieve the next pending connection as a disposable.
   *
   * Will wait for new connections if none are pending.
   *
   * @see `nextConnectionNDAsync()` for non-disposables.
   */
  public function nextConnectionAsync(): Awaitable<TSock>;

  /** Return the local (listening) address for the server */
  public function getLocalAddress(): this::TAddress;

  /** Stop listening; open connection are not closed */
  public function stopListening(): void;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/network/Socket.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Network {

use namespace HH\Lib\{IO, TCP, Unix};

/** A handle representing a connection between processes.
 *
 * It is possible for both ends to be connected to the same process,
 * and to either be local or across a network.
 *
 * @see `TCP\Socket`
 * @see `Unix\Socket`
 */
<<__Sealed(
  CloseableSocket::class,
  TCP\Socket::class,
  Unix\Socket::class,
)>>
interface Socket extends IO\ReadWriteHandle {
  /** A local or peer address.
   *
   * For IP-based sockets, this is likely to be a host and port;
   * for Unix sockets, it is likely to be a filesystem path.
   */
  abstract const type TAddress;

  /** Returns the address of the local side of the socket */
  public function getLocalAddress(): this::TAddress;
  /** Returns the address of the remote side of the socket */
  public function getPeerAddress(): this::TAddress;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/Lock.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\File {

use namespace HH\Lib\{OS, _Private\_OS};

/**
 * A File Lock, which is unlocked as a disposable. To acquire one, call `lock`
 * on a Base object.
 *
 * Note that in some cases, such as the non-blocking lock types, we may throw
 * an `LockAcquisitionException` instead of acquiring the lock. If this
 * is not desired behavior it should be guarded against.
 */
final class Lock implements \IDisposable {

  public function __construct(private OS\FileDescriptor $fd) {
  }

  final public function __dispose(): void {
    try {
      OS\flock($this->fd, _OS\LOCK_UN);
    } catch (OS\ErrnoException $e) {
      if ($e->getErrno() !== OS\Errno::EBADF) {
        throw $e;
      }
    }
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/TemporaryFile.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\File {

use namespace HH\Lib\{IO, OS};
use namespace HH\Lib\_Private\_IO;

final class TemporaryFile implements \IDisposable {
  public function __construct(private CloseableReadWriteHandle $handle) {}

  public function getHandle(): CloseableReadWriteHandle {
    return $this->handle;
  }
  public function __dispose(): void {
    $f = $this->getHandle();
    try {
      $f->close();
    } catch (OS\ErrnoException $e) {
      if ($e->getErrno() !== OS\Errno::EBADF) {
        throw $e;
      }
    }
    \unlink($f->getPath());
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/AlreadyLockedException.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\File {

/**
 * Indicates that a lock failed, because the file is already locked.
 *
 * This class does not extend `OS\ErrnoException` as an `EWOULDBLOCK` after
 * `flock($fd, LOCK_NB)` is expected rather than an error; this exception is
 * thrown when the caller has explicitly requested an exception for these cases.
 */
final class AlreadyLockedException extends \Exception {
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/CloseableHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\File {

use namespace HH\Lib\IO;

interface CloseableHandle extends IO\CloseableSeekableHandle, Handle {
}

interface CloseableReadHandle
  extends IO\CloseableSeekableReadHandle, CloseableHandle, ReadHandle {
}

interface CloseableWriteHandle
  extends
    IO\CloseableSeekableWriteHandle,
    CloseableHandle,
    WriteHandle {
}

interface CloseableReadWriteHandle
  extends
    IO\CloseableSeekableReadWriteHandle,
    ReadWriteHandle,
    CloseableReadHandle,
    CloseableWriteHandle {
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/temporary_file.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\File {

use namespace HH\Lib\{OS, Str};
use namespace HH\Lib\_Private\_File;

/** Create a new temporary file.
 *
 * The file is automatically deleted when the disposable is removed.
 *
 * - If the prefix starts with `.`, it is interpretered relative to the current
 *   working directory.
 * - If the prefix statis with `/`, it is treated as an absolute path.
 * - Otherwise, it is created in the system temporary directory.
 *
 * Regardless of the kind of prefix, the parent directory must exist.
 *
 * A suffix can optionally be provided; this is useful when you need a
 * particular filename extension; for example,
 * `File\temporary_file('foo', '.txt')` may create `/tmp/foo123456.txt`.
 *
 * The temporary file:
 * - will be a new file (i.e. `O_CREAT | O_EXCL`)
 * - be owned by the current user
 * - be created with mode 0600
 */
<<__ReturnDisposable>>
function temporary_file(
  string $prefix = 'hack-tmp-',
  string $suffix = '',
): TemporaryFile {
  if (
    !(
      Str\starts_with($prefix, '/') ||
      Str\starts_with($prefix, './') ||
      Str\starts_with($prefix, '../')
    )
  ) {
    $prefix = Str\trim_right(\sys_get_temp_dir(), '/').'/'.$prefix;
  }
  $pattern = $prefix.'XXXXXX'.$suffix;
  list($handle, $path) = OS\mkstemps($pattern, Str\length($suffix));
  return new TemporaryFile(new _File\CloseableReadWriteHandle($handle, $path));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/LockType.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\File {

use namespace HH\Lib\OS;

enum LockType: int as int {
  /**
   * Any number of processes may have a shared lock simultaneously. It is
   * commonly called a reader lock. The creation of a Lock will block until
   * the lock is acquired.
   */
  SHARED = OS\LOCK_SH;

  /**
   * Only a single process may possess an exclusive lock to a given file at a
   * time. The creation of a Lock will block until the lock is acquired.
   */
  EXCLUSIVE = OS\LOCK_EX;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/open.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\File {
use namespace HH\Lib\{OS, _Private\_File};

function open_read_only(string $path): CloseableReadHandle {
  return OS\open($path, OS\O_RDONLY)
    |> new _File\CloseableReadHandle($$, $path);
}

function open_write_only(
  string $path,
  WriteMode $mode = WriteMode::OPEN_OR_CREATE,
  int $create_file_permissions = 0644,
): CloseableWriteHandle {
  return OS\open(
    $path,
    OS\O_WRONLY | $mode as int,
    ($mode & OS\O_CREAT) ? $create_file_permissions : null,
  )
    |> new _File\CloseableWriteHandle($$, $path);
}

function open_read_write(
  string $path,
  WriteMode $mode = WriteMode::OPEN_OR_CREATE,
  int $create_file_permissions = 0644,
): CloseableReadWriteHandle {
  return OS\open(
    $path,
    OS\O_RDWR | $mode as int,
    ($mode & OS\O_CREAT) ? $create_file_permissions : null,
  )
    |> new _File\CloseableReadWriteHandle($$, $path);
}

<<__Deprecated("Use open_read_only() instead")>>
function open_read_only_nd(string $path): CloseableReadHandle {
  return open_read_only($path);
}

<<__Deprecated("Use open_write_only() instead")>>
function open_write_only_nd(
  string $path,
  WriteMode $mode = WriteMode::OPEN_OR_CREATE,
  int $create_file_permissions = 0644,
): CloseableWriteHandle {
  return open_write_only($path, $mode, $create_file_permissions);
}

<<__ReturnDisposable, __Deprecated("Use open_read_write() instead")>>
function open_read_write_nd(
  string $path,
  WriteMode $mode = WriteMode::OPEN_OR_CREATE,
  int $create_file_permissions = 0644,
): CloseableReadWriteHandle {
  return open_read_write($path, $mode, $create_file_permissions);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/Handle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\File {

use namespace HH\Lib\IO;

interface Handle extends IO\SeekableFDHandle {
  /**
   * Get the name of this file.
   */
  public function getPath(): string;

  /**
   * Get the size of the file.
   */
  public function getSize(): int;

  /**
   * Get a shared or exclusive lock on the file.
   *
   * This will block until it acquires the lock, which may be forever.
   *
   * This involves a blocking syscall; async code will not execute while
   * waiting for a lock.
   */
  <<__ReturnDisposable>>
  public function lock(LockType $type): Lock;

  /**
   * Immediately get a shared or exclusive lock on a file, or throw.
   *
   * @throws `File\AlreadyLockedException` if `lock()` would block. **This
   *   is not a subclass of `OS\ErrnoException`**.
   * @throws `OS\ErrnoException` in any other case.
   */
  <<__ReturnDisposable>>
  public function tryLockx(LockType $type): Lock;
}

interface ReadHandle extends Handle, IO\SeekableReadFDHandle {
}

interface WriteHandle extends Handle, IO\SeekableWriteFDHandle {
  public function truncate(?int $length = null): void;
}

interface ReadWriteHandle extends WriteHandle, ReadHandle, IO\SeekableReadWriteFDHandle {
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/_Private/TruncateTrait.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_File {

use namespace HH\Lib\{IO, OS};
use namespace HH\Lib\_Private\_IO;

/**
 * This method can't be added directly to `_IO\FileDescriptorWriteHandleTrait`,
 * because only real files can be truncated on both MacOS and Linux.
 * On Linux you can also truncate posix shared memory, but that is not
 * supported on MacOS.
 */
trait TruncateTrait {
  require extends _IO\FileDescriptorHandle;

  final public function truncate(?int $length = null): void {
    OS\ftruncate($this->impl, $length ?? 0);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/_Private/CloseableReadWriteHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_File {

use namespace HH\Lib\{File, IO};
use namespace HH\Lib\_Private\_IO;

final class CloseableReadWriteHandle
  extends CloseableFileHandle
  implements File\CloseableReadWriteHandle {
  use _IO\FileDescriptorReadHandleTrait;
  use _IO\FileDescriptorWriteHandleTrait;
  use TruncateTrait;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/_Private/CloseableFileHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_File {

use namespace HH\Lib\Str;
use namespace HH\Lib\_Private\{_IO, _OS};
use namespace HH\Lib\{IO, File, OS};

<<__ConsistentConstruct>>
abstract class CloseableFileHandle
  extends _IO\FileDescriptorHandle
  implements File\Handle, IO\CloseableHandle {

  final public function __construct(
    OS\FileDescriptor $fd,
    protected string $filename,
  ) {
    parent::__construct($fd);
  }

  <<__Memoize>>
  final public function getPath(): string {
    return $this->filename;
  }

  final public function getSize(): int {
    $pos = OS\lseek($this->impl, 0, OS\SeekWhence::SEEK_CUR);
    $size = OS\lseek($this->impl, 0, OS\SeekWhence::SEEK_END);
    OS\lseek($this->impl, $pos, OS\SeekWhence::SEEK_SET);

    return $size;
  }

  final public function seek(int $offset): void {
    OS\lseek($this->impl, $offset, OS\SeekWhence::SEEK_SET);
  }

  final public function tell(): int {
    return OS\lseek($this->impl, 0, OS\SeekWhence::SEEK_CUR);
  }

  <<__ReturnDisposable>>
  final public function lock(File\LockType $type): File\Lock {
    OS\flock($this->impl, $type);
    return new File\Lock($this->impl);
  }

  <<__ReturnDisposable>>
  final public function tryLockx(File\LockType $type): File\Lock {
    try {
      OS\flock($this->impl, $type | OS\LOCK_NB);
      return new File\Lock($this->impl);
    } catch (OS\BlockingIOException $e) {
      if ($e->getErrno() === OS\Errno::EAGAIN) {
        throw new File\AlreadyLockedException();
      }
      throw $e;
    }
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/_Private/CloseableReadHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_File {

use namespace HH\Lib\{File, IO};
use namespace HH\Lib\_Private\_IO;

final class CloseableReadHandle
  extends CloseableFileHandle
  implements File\CloseableReadHandle {
  use _IO\FileDescriptorReadHandleTrait;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/_Private/CloseableWriteHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_File {

use namespace HH\Lib\{File, IO};
use namespace HH\Lib\_Private\_IO;

final class CloseableWriteHandle
  extends CloseableFileHandle
  implements File\CloseableWriteHandle {
  use _IO\FileDescriptorWriteHandleTrait;
  use TruncateTrait;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/file/WriteMode.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\File {

use namespace HH\Lib\OS;

enum WriteMode: int {
  /**
   * Open the file for writing only; place the file pointer at the beginning of
   * the file.
   *
   * If the file exits, it is not truncated (as with `TRUNCATE`), and the call
   * suceeds (unlike `EXCLUSIVE_CREATE`).
   */
  OPEN_OR_CREATE = OS\O_CREAT;

  /**
   * Open for writing only; place the file pointer at the beginning of the
   * file and truncate the file to zero length. If the file does not exist,
   * attempt to create it.
   */
  TRUNCATE = OS\O_TRUNC | OS\O_CREAT;

  /**
   * Open for writing only; place the file pointer at the end of the file. If
   * the file does not exist, attempt to create it. In this mode, seeking has
   * no effect, writes are always appended.
   */
  APPEND = OS\O_APPEND | OS\O_CREAT;

  /**
   * Create and open for writing only; place the file pointer at the beginning
   * of the file. If the file already exists, the filesystem call will throw an
   * exception. If the file does not exist, attempt to create it.
   */
  MUST_CREATE = OS\O_EXCL | OS\O_CREAT;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/private.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private {

/**
 * Verifies that the `$offset` is within plus/minus `$length`. Returns the
 * offset as a positive integer.
 */
function validate_offset(int $offset, int $length)[]: int {
  $original_offset = $offset;
  if ($offset < 0) {
    $offset += $length;
  }
  invariant(
    $offset >= 0 && $offset <= $length,
    'Offset %d was out-of-bounds for length %d',
    $original_offset,
    $length,
  );
  return $offset;
}

/**
 * Verifies that the `$offset` is not less than minus `$length`. Returns the
 * offset as a positive integer.
 */
function validate_offset_lower_bound(int $offset, int $length)[]: int {
  $original_offset = $offset;
  if ($offset < 0) {
    $offset += $length;
  }
  invariant(
    $offset >= 0,
    'Offset %d was out-of-bounds for length %d',
    $original_offset,
    $length,
  );
  return $offset;
}

function boolval(mixed $val)[]: bool {
  return (bool)$val;
}

const string ALPHABET_ALPHANUMERIC =
  '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

/**
 * Stop eager execution of an async function.
 *
 * ==== ONLY USE THIS IN HSL IMPLEMENTATION AND TESTS ===
 */
function stop_eager_execution(): RescheduleWaitHandle {
  return RescheduleWaitHandle::create(RescheduleWaitHandle::QUEUE_DEFAULT, 0);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/math/compare.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Math {

/**
 * Returns the largest of all input numbers.
 *
 * - To find the smallest number, see `Math\minva()`.
 * - For Traversables, see `Math\max()`.
 */
function maxva<T as num>(
  T $first,
  T $second,
  T ...$rest
)[]: T {
  $max = $first > $second ? $first : $second;
  foreach ($rest as $number) {
    if ($number > $max) {
      $max = $number;
    }
  }
  return $max;
}

/**
 * Returns the smallest of all input numbers.
 *
 * - To find the largest number, see `Math\maxva()`.
 * - For Traversables, see `Math\min()`.
 */
function minva<T as num>(
  T $first,
  T $second,
  T ...$rest
)[]: T {
  $min = $first < $second ? $first : $second;
  foreach ($rest as $number) {
    if ($number < $min) {
      $min = $number;
    }
  }
  return $min;
}

/**
 * Returns whether a num is NAN.
 * NAN is "the not-a-number special float value"
 *
 * When comparing NAN to any value (including NAN) using operators
 * false will be returned. `NAN === NAN` is false.
 *
 * One must always check for NAN using `is_nan` and not `$x === NAN`.
 */
function is_nan(num $num)[]: bool {
  return \is_nan((float)$num);
}

/**
 * Compares two numbers to see if they are within epsilon of each other.
 * If the difference equals epsilon this returns false.
 *
 * default epsilon of .00000001.
 *
 * When comparing large numbers consider passing in a large epsilon
 */
function almost_equals(num $num_one, num $num_two, num $epsilon = .00000001)[]: bool{
  return namespace\abs($num_one - $num_two) < $epsilon;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/math/compute.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Math {
use namespace HH\Lib\{C, Str};
use const HH\Lib\_Private\ALPHABET_ALPHANUMERIC;

/**
 * Returns the absolute value of `$number` (`$number` if `$number` > 0,
 * `-$number` if `$number` < 0).
 *
 * NB: for the smallest representable int, PHP_INT_MIN, the result is
 * "implementation-defined" because the corresponding positive number overflows
 * int. You will probably find that `Math\abs(PHP_INT_MIN) === PHP_INT_MIN`,
 * meaning the function can return a negative result in that case. To ensure
 * an int is non-negative for hashing use `$v & PHP_INT_MAX` instead.
 */
function abs<T as num>(T $number)[]: T {
  /* HH_FIXME[4110]: This returns a num, which may be a *supertype* of T */
  return $number < 0 ? -$number : $number;
}

/**
 * Converts the given string in base `$from_base` to base `$to_base`, assuming
 * letters a-z are used for digits for bases greater than 10. The conversion is
 * done to arbitrary precision.
 *
 * - To convert a string in some base to an int, see `Math\from_base()`.
 * - To convert an int to a string in some base, see `Math\to_base()`.
 */
function base_convert(string $value, int $from_base, int $to_base)[rx_local]: string {
  invariant(
    $value !== '',
    'Unexpected empty string, expected number in base %d',
    $from_base,
  );

  invariant(
    $from_base >= 2 && $from_base <= 36,
    'Expected $from_base to be between 2 and 36, got %d',
    $from_base,
  );

  invariant(
    $to_base >= 2 && $to_base <= 36,
    'Expected $to_base to be between 2 and 36, got %d',
    $to_base,
  );

  invariant(\bcscale(0) === true, 'Unexpected bcscale failure');

  $from_alphabet = Str\slice(ALPHABET_ALPHANUMERIC, 0, $from_base);
  $result_decimal = '0';
  $place_value = \bcpow((string)$from_base, (string)(Str\length($value) - 1));
  foreach (Str\chunk($value) as $digit) {
    $digit_numeric = Str\search_ci($from_alphabet, $digit);
    invariant(
      $digit_numeric !== null,
      'Invalid digit %s in base %d',
      $digit,
      $from_base,
    );
    $result_decimal = \bcadd(
      $result_decimal,
      \bcmul((string)$digit_numeric, $place_value),
    );
    $place_value = \bcdiv((string)$place_value, (string)$from_base);
  }

  if ($to_base === 10) {
    return $result_decimal;
  }

  $to_alphabet = Str\slice(ALPHABET_ALPHANUMERIC, 0, $to_base);
  $result = '';
  do {
    $result = $to_alphabet[\bcmod($result_decimal, (string)$to_base)].$result;
    $result_decimal = \bcdiv((string)$result_decimal, (string)$to_base);
    } while (\bccomp($result_decimal, '0') > 0);

  return $result;
}

/**
 * Returns the smallest integer value greater than or equal to $value.
 *
 * To find the largest integer value less than or equal to `$value`, see
 * `Math\floor()`.
 */
function ceil(num $value)[]: float {
  return \ceil($value);
}

/**
 * Returns the cosine of `$arg`.
 *
 * - To find the sine, see `Math\sin()`.
 * - To find the tangent, see `Math\tan()`.
 */
function cos(num $arg)[]: float {
  return \cos((float)$arg);
}

/**
 * Converts the given string in the given base to an int, assuming letters a-z
 * are used for digits when `$from_base` > 10.
 *
 * To base convert an int into a string, see `Math\to_base()`.
 */
function from_base(string $number, int $from_base)[]: int {
  invariant(
    $number !== '',
    'Unexpected empty string, expected number in base %d',
    $from_base,
  );

  invariant(
    $from_base >= 2 && $from_base <= 36,
    'Expected $from_base to be between 2 and 36, got %d',
    $from_base,
  );

  $limit = int_div(\PHP_INT_MAX, $from_base);
  $result = 0;
  foreach (Str\chunk($number) as $digit) {
    /* This was benchmarked against value lookups using both dict and vec,
     * as well as nasty math magic to do it without branching.
     * In interpreted form, the dict lookup beats this by about 30%,
     * and in compiled form, the vec lookup beats this by about 1%.
     * However, this form does not rely on processor cache for the lookup table,
     * so is likely to be slightly faster out in the wild.
     * See D14491063 for details of benchmarks that were run.
     */
    $oval = \ord($digit);
    // Branches sorted by guesstimated frequency of use. */
    if      (/* '0' - '9' */ $oval <= 57 && $oval >=  48) { $dval = $oval - 48; }
    else if (/* 'a' - 'z' */ $oval >= 97 && $oval <= 122) { $dval = $oval - 87; }
    else if (/* 'A' - 'Z' */ $oval >= 65 && $oval <=  90) { $dval = $oval - 55; }
    else                                                  { $dval = 99; }
    invariant(
      $dval < $from_base,
      'Invalid digit %s in base %d',
      $digit,
      $from_base,
    );
    $oldval = $result;
    $result = $from_base * $result + $dval;
    invariant(
      $oldval <= $limit && $result >= $oldval,
      'Unexpected integer overflow parsing %s from base %d',
      $number,
      $from_base,
    );
  }
  return $result;
}

/**
 * Returns e to the power `$arg`.
 *
 * To find the logarithm, see `Math\log()`.
 */
function exp(num $arg)[]: float {
  return \exp((float)$arg);
}

/**
 * Returns the largest integer value less than or equal to `$value`.
 *
 * - To find the smallest integer value greater than or equal to `$value`, see
 *   `Math\ceil()`.
 * - To find the largest integer value less than or equal to a ratio, see
 *   `Math\int_div()`.
 */
function floor(num $value)[]: float {
  return \floor($value);
}

/**
 * Returns the result of integer division of `$numerator` by `$denominator`.
 *
 * To round a single value, see `Math\floor()`.
 */
function int_div(int $numerator, int $denominator)[]: int {
  if ($denominator === 0) {
    throw new \DivisionByZeroException();
  }
  return \intdiv($numerator, $denominator);
}

/**
 * Returns the logarithm base `$base` of `$arg`.
 *
 * For the exponential function, see `Math\exp()`.
 */
function log(num $arg, ?num $base = null)[]: float {
  invariant($arg > 0, 'Expected positive argument for log, got %f', $arg);
  if ($base === null) {
    return \log((float)$arg);
  }
  invariant($base > 0, 'Expected positive base for log, got %f', $base);
  invariant($base !== 1, 'Logarithm undefined for base 1');
  return \log((float)$arg, (float)$base);
}

/**
 * Returns the given number rounded to the specified precision. A positive
 * precision rounds to the nearest decimal place whereas a negative precision
 * rounds to the nearest power of ten. For example, a precision of 1 rounds to
 * the nearest tenth whereas a precision of -1 rounds to the nearest ten.
 */
function round(num $val, int $precision = 0)[]: float {
  return \round($val, $precision);
}

/**
 * Returns the sine of $arg.
 *
 * - To find the cosine, see `Math\cos()`.
 * - To find the tangent, see `Math\tan()`.
 */
function sin(num $arg)[]: float {
  return \sin((float)$arg);
}

/**
 * Returns the square root of `$arg`.
 */
function sqrt(num $arg)[]: float {
  invariant($arg >= 0, 'Expected non-negative argument to sqrt, got %f', $arg);
  return \sqrt((float)$arg);
}

/**
 * Returns the tangent of `$arg`.
 *
 * - To find the cosine, see `Math\cos()`.
 * - To find the sine, see `Math\sin()`.
 */
function tan(num $arg)[]: float {
  return \tan((float)$arg);
}

/**
 * Converts the given non-negative number into the given base, using letters a-z
 * for digits when `$to_base` > 10.
 *
 * To base convert a string to an int, see `Math\from_base()`.
 */
function to_base(int $number, int $to_base)[rx_shallow]: string {
  invariant(
    $to_base >= 2 && $to_base <= 36,
    'Expected $to_base to be between 2 and 36, got %d',
    $to_base,
  );
  invariant(
    $number >= 0,
    'Expected non-negative base conversion input, got %d',
    $number,
  );
  $result = '';
  do {
    // This is ~20% faster than using '%' and 'int_div' when jit-compiled.
    $quotient = int_div($number, $to_base);
    $result = ALPHABET_ALPHANUMERIC[$number - $quotient*$to_base].$result;
    $number = $quotient;
  } while($number !== 0);
  return $result;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/math/containers.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Math {
use namespace HH\Lib\{C, Math, Vec};

/**
 * Returns the largest element of the given Traversable, or null if the
 * Traversable is empty.
 *
 * - For a known number of inputs, see `Math\maxva()`.
 * - To find the smallest number, see `Math\min()`.
 */
function max<T as num>(
  Traversable<T> $numbers,
)[]: ?T {
  $max = null;
  foreach ($numbers as $number) {
    if ($max === null || $number > $max) {
      $max = $number;
    }
  }
  return $max;
}

/**
 * Returns the largest element of the given Traversable, or null if the
 * Traversable is empty.
 *
 * The value for comparison is determined by the given function. In the case of
 * duplicate numeric keys, later values overwrite previous ones.
 *
 * For numeric elements, see `Math\max()`.
 */
function max_by<T>(
  Traversable<T> $traversable,
  (function(T)[_]: num) $num_func,
)[ctx $num_func]: ?T {
  $max = null;
  $max_num = null;
  foreach ($traversable as $value) {
    $value_num = $num_func($value);
    if ($max_num === null || $value_num >= $max_num) {
      $max = $value;
      $max_num = $value_num;
    }
  }
  return $max;
}

/**
 * Returns the arithmetic mean of the numbers in the given container.
 *
 * - To find the sum, see `Math\sum()`.
 * - To find the maximum, see `Math\max()`.
 * - To find the minimum, see `Math\min()`.
 */
function mean(Container<num> $numbers)[]: ?float {
  $count = (float)C\count($numbers);
  if ($count === 0.0) {
    return null;
  }
  $mean = 0.0;
  foreach ($numbers as $number) {
    $mean += $number / $count;
  }
  return $mean;
}

/**
 * Returns the median of the given numbers.
 *
 * To find the mean, see `Math\mean()`.
 */
function median(Container<num> $numbers)[]: ?float {
  $numbers = Vec\sort($numbers);
  $count = C\count($numbers);
  if ($count === 0) {
    return null;
  }
  $middle_index = Math\int_div($count, 2);
  if ($count % 2 === 0) {
    return Math\mean(
      vec[$numbers[$middle_index], $numbers[$middle_index - 1]]
    ) ?? 0.0;
  }
  return (float)$numbers[$middle_index];
}

/**
 * Returns the smallest element of the given Traversable, or null if the
 * Traversable is empty.
 *
 * - For a known number of inputs, see `Math\minva()`.
 * - To find the largest number, see `Math\max()`.
 */
function min<T as num>(
  Traversable<T> $numbers,
)[]: ?T {
  $min = null;
  foreach ($numbers as $number) {
    if ($min === null || $number < $min) {
      $min = $number;
    }
  }
  return $min;
}

/**
 * Returns the smallest element of the given Traversable, or null if the
 * Traversable is empty.
 *
 * The value for comparison is determined by the given function. In the case of
 * duplicate numeric keys, later values overwrite previous ones.
 *
 * For numeric elements, see `Math\min()`.
 */
function min_by<T>(
  Traversable<T> $traversable,
  (function(T)[_]: num) $num_func,
)[ctx $num_func]: ?T {
  $min = null;
  $min_num = null;
  foreach ($traversable as $value) {
    $value_num = $num_func($value);
    if ($min_num === null || $value_num <= $min_num) {
      $min = $value;
      $min_num = $value_num;
    }
  }
  return $min;
}

/**
 * Returns the integer sum of the values of the given Traversable.
 *
 * For a float sum, see `Math\sum_float()`.
 */
function sum(
  Traversable<int> $traversable,
)[]: int {
  $result = 0;
  foreach ($traversable as $value) {
    $result += (int)$value;
  }
  return $result;
}

/**
 * Returns the float sum of the values of the given Traversable.
 *
 * For an integer sum, see `Math\sum()`.
 */
function sum_float<T as num>(
  Traversable<T> $traversable,
)[]: float {
  $result = 0.0;
  foreach ($traversable as $value) {
    $result += (float)$value;
  }
  return $result;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/math/constants.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Math {

const int INT64_MAX = 9223372036854775807;
// - can't directly represent this as -x is a unary op on x, not a negative
//   literal
// - can't use (INT64_MAX + 1) as ints currently overly to float in external
//   builds for PHP compatibility
const int INT64_MIN = -1 << 63;
const int INT53_MAX = 9007199254740992;
const int INT53_MIN = -9007199254740993;
const int INT32_MAX = 2147483647;
const int INT32_MIN = -2147483648;
const int INT16_MAX = 32767;
const int INT16_MIN = -32768;

const int UINT32_MAX = 4294967295;
const int UINT16_MAX = 65535;

const float PI = 3.14159265358979323846;
const float E = 2.7182818284590452354;
const float NAN = \NAN;
}
///// /home/ubuntu/hhvm/hphp/hsl/src/locale/Category.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

namespace HH\Lib\Locale {

use namespace HH\Lib\_Private\_Locale;

enum Category: int {
  LC_ALL = _Locale\LC_ALL;
  LC_COLLATE = _Locale\LC_COLLATE;
  LC_CTYPE = _Locale\LC_CTYPE;
  LC_MONETARY = _Locale\LC_MONETARY;
  LC_NUMERIC = _Locale\LC_NUMERIC;
  LC_TIME = _Locale\LC_TIME;
  LC_MESSAGES = _Locale\LC_MESSAGES;
};
}
///// /home/ubuntu/hhvm/hphp/hsl/src/locale/mutate.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

namespace HH\Lib\Locale {

use namespace HH\Lib\_Private\_Locale;

/**
 * Create a new `Locale` object.
 *
 * The input should be of the form `country[.encoding]`, for example:
 * `"C"`, `en_US`, `en_US.UTF-8`.
 *
 * If present, the encoding currently **must** be 'UTF-8'.
 *
 * This will throw on 'magic' locales such as:
 * - the empty string: use `from_environment()`
 * - `'0'`: use `get_native()`
 */
function create(string $locale)[]: Locale {
  return _Locale\newlocale_all($locale);
}

/**
 * Create a new `Locale` object, based on an existing one.
 *
 * The input should be of the form `country[.encoding]`, for example:
 * `"C"`, `en_US`, `en_US.UTF-8`.
 *
 * If present, the encoding currently **must** be 'UTF-8'.
 *
 * The empty string is not considered a valid locale in Hack; the libc behavior
 * is equivalent to `get_native()`.
 */
function modified(Locale $orig, Category $cat, string $new)[read_globals]: Locale {
  if ($new === '') {
    // '' is the magic 'fetch from environment'
    throw new InvalidLocaleException(
      "Empty string passed; use `Locale\\from_environment() instead."
    );
  }

  return _Locale\newlocale_category(
    (int) $cat,
    $new,
    $orig,
  );
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/locale/predefined.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

namespace HH\Lib\Locale {

use namespace HH\Lib\_Private\_Locale;

/** DEPRECATED: Use `Locale\bytes()` instead.
 *
 * This function is being removed as:
 * - there is often confusion between "the C locale" and
 *   "the current libc locale"
 * - HHVM implements optimizations which are a visible behavior change; for
 *   example, `strlen("foo\0bar")` is 7 in HHVM, but 3 in libc.
 */
function c()[]: Locale {
  return _Locale\get_c_locale();
}

/** Retrieve a fixed locale suitable for byte-based operations.
 *
 * This is similar to the "C" locale, also known as the "POSIX" or "en_US_POSIX"
 * locale; it does not vary based on user/environment/machine settings.
 *
 * It differs from the real "C" locale in that it is usable on strings that
 * contain null bytes; for example, `Str\length_l(Locale\bytes(), "foo\0bar")`
 * will return 7, instead of 3. The behavior is equivalent if the strings
 * are well-formed.
 */
function bytes()[]: Locale {
  return _Locale\get_c_locale();
}

/** Retrieve the locale being used by libc functions for the current thread.
 *
 * In general, we discourage this: it can be surprising that it changes the
 * behavior of many libc functions, like `sprintf('%f'`), and error messages
 * from native code may be translated.
 *
 * For web applications, that's likely unwanted - we recommend frameworks add
 * the concept of a 'viewer locale', and explicitly pass it to the relevant
 * string functions instead.
 *
 * @see `set_native()`
 */
function get_native()[read_globals]: Locale {
  return _Locale\get_request_locale();
}

/** Set the libc locale for the current thread.
 *
 * This is highly discouraged; see the note for `get_native()` for details.
 */
function set_native(Locale $loc)[globals]: void {
  _Locale\set_request_locale($loc);
}

/** Retrieve the active locale from the native environment.
 *
 * This is usually set based on the `LC_*` environment variables.
 *
 * Web applications targeting diverse users should probably not use this,
 * however it is useful when aiming to support diverse users in CLI
 * programs.
 */
function from_environment()[read_globals]: Locale {
  return _Locale\get_environment_locale();
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/locale/Locale.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

namespace HH\Lib\Locale {

/** An object representing a locale and related settings.
 *
 * This also encapsulates the various `LC_*` settings, so, for example,
 * `LC_CTYPE` can indicate UTF-8, and `LC_COLLATE` and `LC_NUMERIC` can
 * be set to differing locations (e.g. `en_US` or and `fr_FR`).
 */
type Locale = \HH\Lib\_Private\_Locale\Locale;
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/SocketType.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

enum SocketType: int {
  SOCK_STREAM = _OS\SOCK_STREAM;
  SOCK_DGRAM = _OS\SOCK_DGRAM;
  SOCK_RAW = _OS\SOCK_RAW;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/close.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Close the specified `FileDescriptor`.
 *
 * See `man 2 close` for details. On error, an `ErrnoException` will be thrown.
 *
 * This function is not automatically retried on `EINTR`, as `close()` is not
 * safe to retry on `EINTR`.
 */
function close(FileDescriptor $fd): void {
  _OS\wrap_impl(() ==> _OS\close($fd));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/SocketDomain.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

enum SocketDomain: int {
  PF_UNIX = _OS\PF_UNIX;
  PF_INET = _OS\PF_INET;
  PF_INET6 = _OS\PF_INET6;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/getpeername.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Get address of the connected peer.
 *
 * See `man 2 getpeername` for details.
 *
 * @see getsockname
 * @see sockaddr_in
 * @see sockaddr_in6
 * @see sockaddr_un
 */
function getpeername(FileDescriptor $fd): sockaddr {
  $sa = _OS\wrap_impl(() ==> _OS\getpeername($fd));
  return _OS\sockaddr_from_native_sockaddr($sa);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/ttyname.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Get the name of the terminal associated with a file descriptor, if any.
 *
 * This function will throw if an error occurs; you may want to specifically
 * handle `ENOTTY`.
 */
function ttyname(FileDescriptor $fd): string {
  return _OS\wrap_impl(
    () ==> _OS\ttyname($fd),
  );
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/getsockname.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Get the name of the local end of a socket.
 *
 * See `man 2 getsockname` for details.
 *
 * @see getpeername()
 * @see sockaddr_in
 * @see sockaddr_in6
 * @see sockaddr_un
 */
function getsockname(FileDescriptor $fd): sockaddr {
  $sa = _OS\wrap_impl(() ==> _OS\getsockname($fd));
  return _OS\sockaddr_from_native_sockaddr($sa);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/mkdtemp.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\Str;
use namespace HH\Lib\_Private\_OS;

/** Create a temporary directory.
 *
 * This function creates a new, unique temporary directory, with the name
 * matching the provided template, and returns the path. The directory will be
 * created with permissions 0700.
 *
 * The template MUST end with `XXXXXX`; these are replaced with random
 * printable characters to create a unique name. While some platforms are more
 * flexible, the HSL always requires this for consistency. Any additional
 * trailing `X`s may result in literal X's (e.g. glibc), or in additional
 * randomness (e.g. BSD) - use a separator (e.g. `fooXXX.XXXXXX`) to guarantee
 * any characters are preserved.
 */
function mkdtemp(string $template): string {
  // This restriction exists with glibc, but BSD (e.g. MacOS) is more flexible;
  // don't let people accidentally write non-portable code.
  if (!Str\ends_with($template, 'XXXXXX')) {
    _OS\throw_errno(
      Errno::EINVAL,
      "mkdtemp template must always end with 'XXXXXX' (portability)",
    );
  }
  return _OS\wrap_impl(() ==> _OS\mkdtemp($template));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/sockaddr_in6.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

/** Address of an INET6 (IPv6) socket.
 *
 * See `man 7 ip6` (Linux) or `man 4 inet6` (BSD) for details.
 *
 * @see `sockaddr_in` for INET (IPv4) sockets.
 */
final class sockaddr_in6 extends sockaddr {
  /** Construct an instance.
   *
   * Unlike the C API, all integers are in host byte order.
   */
  public function __construct(
    private int $port,
    private int $flowInfo,
    private in6_addr $address,
    private int $scopeID,
  ) {
  }

  <<__Override>>
  final public function getFamily(): AddressFamily {
    return AddressFamily::AF_INET6;
  }

  /** Get the port, in host byte order. */
  final public function getPort(): int{
    return $this->port;
  }

  final public function getAddress(): in6_addr {
    return $this->address;
  }

  /** Get the flow ID.
   *
   * See `man ip6` for details.
   */
  final public function getFlowInfo(): int {
    return $this->flowInfo;
  }

  /** Get the scope ID.
   *
   * See `man ip6` for details.
   */
  final public function getScopeID(): int {
    return $this->scopeID;
  }

  final public function __debugInfo(): darray<string, mixed> {
    return darray[
      'port (host byte order)' => $this->port,
      'flow info (host byte order)' => $this->flowInfo,
      'scope ID (host byte order)' => $this->scopeID,
      'address (network format)' => $this->address,
      'address (presentation format)' =>
        inet_ntop_inet6($this->address),
    ];
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/flock.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

// Not using an enum (for now?) as it's a bit mask
/** Exclusive lock */
const int LOCK_EX = _OS\LOCK_EX;
/** Shared lock */
const int LOCK_SH = _OS\LOCK_SH;
/** Do not block on attempt to lock; throw instead */
const int LOCK_NB = _OS\LOCK_NB;
/** Unlock. */
const int LOCK_UN = _OS\LOCK_UN;

/** Acquire or remove an advisory lock on a file descriptor.
 *
 * See `man 2 flock` for details. On error, an `ErrnoException` will be thrown.
 *
 * A shared lock can also be 'upgraded' to an exclusive lock, however this
 * operation is not guaranteed to be atomic: systems may implement this by
 * releasing the shared lock, then attempting to acquire an exclusive lock. This
 * may lead to an upgrade attempt meaning that a lock is lost entirely, without
 * a replacement, as another process may potentially acquire a lock between
 * these operations.
 *
 * @param $flags a bitmask of `LOCK_` flags; one out of `LOCK_EX`, `LOCK_SH`, or
 *    `LOCK_UN` **must** be specified.
 */
function flock(FileDescriptor $fd, int $flags): void {
  if (
    ($flags & LOCK_EX) !== LOCK_EX &&
    ($flags & LOCK_SH) !== LOCK_SH &&
    ($flags & LOCK_UN) !== LOCK_UN
  ) {
    _OS\throw_errno(
      Errno::EINVAL,
      'LOCK_EX, LOCK_SH, or LOCK_UN must be specified',
    );
  }
  _OS\wrap_impl(() ==> _OS\flock($fd, $flags));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/pipe.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Create a pair of connected file descriptors.
 *
 * See `man 2 pipe` for details. On error, an `ErrnoException` will be thrown.
 *
 * `O_CLOEXEC` is implicitly set for consistent behavior between standalone CLI
 * mode and server modes. Use `OS\fcntl()` to remove if needed.
 *
 * @returns Two `FileDescriptor`s; the first is read-only, and the second is
 *   write-only. Data written to the second can be read from the first.
 */
function pipe(): (FileDescriptor, FileDescriptor) {
  list($r, $w) = _OS\wrap_impl(() ==> _OS\pipe());
  _OS\fcntl($r, _OS\F_SETFL, _OS\fcntl($r, _OS\F_GETFL) as int | _OS\O_CLOEXEC);
  _OS\fcntl($w, _OS\F_SETFL, _OS\fcntl($w, _OS\F_GETFL) as int | _OS\O_CLOEXEC);
  return tuple($r, $w);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/lseek.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

enum SeekWhence: int as int {
  SEEK_SET = _OS\SEEK_SET;
  SEEK_CUR = _OS\SEEK_CUR;
  SEEK_END = _OS\SEEK_END;
  SEEK_HOLE = _OS\SEEK_HOLE;
  SEEK_DATA = _OS\SEEK_DATA;
}
/** Reposition the current file offset.
 *
 * See `man 2 lseek` for details. On error, an `ErrnoException` will be thrown.
 */
function lseek(FileDescriptor $fd, int $offset, SeekWhence $whence): int {
  return _OS\wrap_impl(() ==> _OS\lseek($fd, $offset, $whence));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/ErrnoException.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\C;
use namespace HH\Lib\_Private\_OS;


/**
 * Base class for exceptions reported via the C `errno` variable.
 *
 * Subclasses exist for some specific `Errno` values, such as:
 * - `ChildProcessException` (`ECHILD`)
 * - `ConnectionException` and its' subclasses, `BrokenPipeException`
 *   (`EPIPE`, `ESHUTDOWN`), `ConnectionAbortedException` (`ECONNABORTED`),
 *   `ConnectionRefusedException` (`ECONNREFUSED`), and
 *   `ConnectionResetException` (`ECONNRESET`)
 * - `AlreadyExistsException` (`EEXIST`)
 * - `NotFoundException` (`ENOENT`)
 * - `IsADirectoryException` (`EISDIR`)
 * - `IsNotADirectoryException` (`ENOTDIR`)
 * - `PermissionException` (`EACCESS`, `EPERM`)
 * - `ProcessLookupException` (`ESRCH`)
 * - `TimeoutError` (`ETIMEDOUT`)
 *
 * It is strongly recommended to catch subclasses instead of this class if a
 * suitable subclass is defined; for example:
 *
 * ```Hack
 * // ANTIPATTERN:
 * catch (OS\ErrnoException $e) {
 *   if ($e->getErrno() === OS\Errno::ENOENT) {
 *     do_stuff();
 *   }
 * }
 * // RECOMMENDED:
 * catch (OS\NotFoundException $_) {
 *   do_stuff();
 * }
 * ```
 *
 * If a suitable subclass is not defined, the antipattern is unavoidable.
 */
class ErrnoException extends \Exception {
  public function __construct(private Errno $errno, string $message) {
    parent::__construct($message);
    // Can't be in constructor: constructor takes int, but property - and
    // accessor - are mixed.
    $this->code = $errno;
  }

  final public function getErrno(): Errno{
    return $this->errno;
  }

  /** Deprecated for clarity, and potential future ambiguity.
   *
   * In the future, we may have exceptions with multiple 'codes', such as an
   * `errno` and a getaddrinfo `GAI` constant.
   *
   * Keeping logging rate at 0 so that generic code that works on any exception
   * stays happy.
   */
  <<__Deprecated("Use `getErrno()` instead", 0)>>
  final public function getCode()[]: Errno {
    return $this->errno;
  }
}

final class BlockingIOException extends ErrnoException {
  public function __construct(Errno $code, string $message) {
    invariant(
      C\contains(static::_getValidErrnos(), $code),
      'Exception %s constructed with invalid code %s',
      static::class,
      $code,
    );
    parent::__construct($code, $message);
  }

  public static function _getValidErrnos(): keyset<Errno> {
    return keyset[
      Errno::EAGAIN,
      Errno::EALREADY,
      Errno::EINPROGRESS,
    ];
  }
}

final class ChildProcessException extends ErrnoException {
  public function __construct(string $message) {
    parent::__construct(static::_getValidErrno(), $message);
  }

  public static function _getValidErrno(): Errno {
    return Errno::ECHILD;
  }
}

abstract class ConnectionException extends ErrnoException {
}

final class BrokenPipeException extends ConnectionException {
  public function __construct(Errno $code, string $message) {
    invariant(
      C\contains(static::_getValidErrnos(), $code),
      'Exception %s constructed with invalid code %s',
      static::class,
      $code,
    );
    parent::__construct($code, $message);
  }

  public static function _getValidErrnos(): keyset<Errno> {
    return keyset[Errno::EPIPE, Errno::ESHUTDOWN];
  }
}

final class ConnectionAbortedException extends ConnectionException {
  public function __construct(string $message) {
    parent::__construct(static::_getValidErrno(), $message);
  }

  public static function _getValidErrno(): Errno {
    return Errno::ECONNABORTED;
  }
}

final class ConnectionRefusedException extends ConnectionException {
  public function __construct(string $message) {
    parent::__construct(static::_getValidErrno(), $message);
  }

  public static function _getValidErrno(): Errno {
    return Errno::ECONNREFUSED;
  }
}

final class ConnectionResetException extends ConnectionException {
  public function __construct(string $message) {
    parent::__construct(static::_getValidErrno(), $message);
  }

  public static function _getValidErrno(): Errno {
    return Errno::ECONNRESET;
  }
}

final class AlreadyExistsException extends ErrnoException {
  public function __construct(string $message) {
    parent::__construct(static::_getValidErrno(), $message);
  }

  public static function _getValidErrno(): Errno {
    return Errno::EEXIST;
  }
}

final class NotFoundException extends ErrnoException {
  public function __construct(string $message) {
    parent::__construct(static::_getValidErrno(), $message);
  }

  public static function _getValidErrno(): Errno {
    return Errno::ENOENT;
  }
}

final class IsADirectoryException extends ErrnoException {
  public function __construct(string $message) {
    parent::__construct(static::_getValidErrno(), $message);
  }

  public static function _getValidErrno(): Errno {
    return Errno::EISDIR;
  }
}

final class IsNotADirectoryException extends ErrnoException {
  public function __construct(string $message) {
    parent::__construct(static::_getValidErrno(), $message);
  }

  public static function _getValidErrno(): Errno {
    return Errno::ENOTDIR;
  }
}

final class PermissionException extends ErrnoException {
  public function __construct(Errno $code, string $message) {
    invariant(
      C\contains(static::_getValidErrnos(), $code),
      'Exception %s constructed with invalid code %s',
      static::class,
      $code,
    );
    parent::__construct($code, $message);
  }

  public static function _getValidErrnos(): keyset<Errno> {
    return keyset[
      Errno::EACCES,
      Errno::EPERM,
    ];
  }
}

final class ProcessLookupException extends ErrnoException {
  public function __construct(string $message) {
    parent::__construct(static::_getValidErrno(), $message);
  }

  public static function _getValidErrno(): Errno {
    return Errno::ESRCH;
  }
}

final class TimeoutException extends ErrnoException {
  public function __construct(string $message) {
    parent::__construct(static::_getValidErrno(), $message);
  }

  public static function _getValidErrno(): Errno {
    return Errno::ETIMEDOUT;
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/isatty.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Test if a file descriptor refers to a terminal.
 *
 * If the native call fails with `ENOTTY` (for example, on MacOS), this function
 * will return false.
 *
 * If the native call fails with any other error (for example, `EBADF`), this
 * function will throw.
 */
function isatty(FileDescriptor $fd): bool {
  return _OS\wrap_impl(
    () ==> _OS\isatty($fd),
  );
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/Errno.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

// hackfmt-ignore
/** OS-level error number constants from `errno.h`.
 *
 * These values are typically stored in a global `errno` variable by C APIs.
 *
 * **It is unsafe to call `Errno::getNames()` as this enum contains duplicate
 * values**; this is unavoidable for portability:
 * - on MacOS, `EOPNOTSUPP` and `ENOTSUP` are distinct values, so must be
 *   represented separately in this enum
 *  - On Linux, they are equal, so are a duplicate value.
 *
 * `0` is used to indicate success, but not defined in `errno.h`; we expect
 * Hack programs to use the `Errno` type when an error is known to have
 * occurred, or `?Errno` when an error /may/ have occurred.
 *
 * Negative values indicate that the constant is not defined on the current
 * operating system; for example, `ECHRNG` is not defined on MacOS.
 *
 * Constants are defined in this namespace by the runtime, but currently only
 * if they are defined on all supported platforms; in this enum we manually
 * specify the non-portable ones for now.
 */
enum Errno: int as int {
  /* SUCCESS = 0 */
  EPERM           = _OS\EPERM;
  ENOENT          = _OS\ENOENT;
  ESRCH           = _OS\ESRCH;
  EINTR           = _OS\EINTR;
  EIO             = _OS\EIO;
  ENXIO           = _OS\ENXIO;
  E2BIG           = _OS\E2BIG;
  ENOEXEC         = _OS\ENOEXEC;
  EBADF           = _OS\EBADF;
  ECHILD          = _OS\ECHILD;
  EAGAIN          = _OS\EAGAIN;
  ENOMEM          = _OS\ENOMEM;
  EACCES          = _OS\EACCES;
  EFAULT          = _OS\EFAULT;
  ENOTBLK         = _OS\ENOTBLK;
  EBUSY           = _OS\EBUSY;
  EEXIST          = _OS\EEXIST;
  EXDEV           = _OS\EXDEV;
  ENODEV          = _OS\ENODEV;
  ENOTDIR         = _OS\ENOTDIR;
  EISDIR          = _OS\EISDIR;
  EINVAL          = _OS\EINVAL;
  ENFILE          = _OS\ENFILE;
  EMFILE          = _OS\EMFILE;
  ENOTTY          = _OS\ENOTTY;
  ETXTBSY         = _OS\ETXTBSY;
  EFBIG           = _OS\EFBIG;
  ENOSPC          = _OS\ENOSPC;
  ESPIPE          = _OS\ESPIPE;
  EROFS           = _OS\EROFS;
  EMLINK          = _OS\EMLINK;
  EPIPE           = _OS\EPIPE;
  EDOM            = _OS\EDOM;
  ERANGE          = _OS\ERANGE;
  EDEADLK         = _OS\EDEADLK;
  ENAMETOOLONG    = _OS\ENAMETOOLONG;
  ENOLCK          = _OS\ENOLCK;
  ENOSYS          = _OS\ENOSYS;
  ENOTEMPTY       = _OS\ENOTEMPTY;
  ELOOP           = _OS\ELOOP;
  EWOULDBLOCK     = _OS\EAGAIN; // alias
  ENOMSG          = _OS\ENOMSG;
  EIDRM           = _OS\EIDRM;

  ECHRNG          = _OS\IS_MACOS ?  -44 :   44;
  EL2NSYNC        = _OS\IS_MACOS ?  -45 :   45;
  EL3HLT          = _OS\IS_MACOS ?  -46 :   46;
  EL3RST          = _OS\IS_MACOS ?  -47 :   47;
  ELNRNG          = _OS\IS_MACOS ?  -48 :   48;
  EUNATCH         = _OS\IS_MACOS ?  -49 :   49;
  ENOCSI          = _OS\IS_MACOS ?  -50 :   50;
  EL2HLT          = _OS\IS_MACOS ?  -51 :   51;
  EBADE           = _OS\IS_MACOS ?  -52 :   52;
  EBADR           = _OS\IS_MACOS ?  -53 :   53;
  EXFULL          = _OS\IS_MACOS ?  -54 :   54;
  ENOANO          = _OS\IS_MACOS ?  -55 :   55;
  EBADRQC         = _OS\IS_MACOS ?  -56 :   56;
  EBADSLT         = _OS\IS_MACOS ?  -57 :   57;
  EDEADLOCK       = _OS\EDEADLK;

  EBFONT          = _OS\IS_MACOS ?  -59 :   59;
  ENOSTR          = _OS\ENOSTR;
  ENODATA         = _OS\ENODATA;
  ETIME           = _OS\ETIME;
  ENOSR           = _OS\ENOSR;
  ENONET          = _OS\IS_MACOS ?  -64 :   64;
  ENOPKG          = _OS\IS_MACOS ?  -65 :   65;
  EREMOTE         = _OS\IS_MACOS ?  -66 :   66;
  ENOLINK         = _OS\ENOLINK;
  EADV            = _OS\IS_MACOS ?  -68 :   68;
  ESRMNT          = _OS\IS_MACOS ?  -69 :   69;
  ECOMM           = _OS\IS_MACOS ?  -70 :   70;
  EPROTO          = _OS\EPROTO;
  EMULTIHOP       = _OS\EMULTIHOP;
  EDOTDOT         = _OS\IS_MACOS ?  -73 :   73;
  EBADMSG         = _OS\EBADMSG;
  EOVERFLOW       = _OS\EOVERFLOW;
  ENOTUNIQ        = _OS\IS_MACOS ?  -76 :   76;
  EBADFD          = _OS\IS_MACOS ?  -77 :   77;
  EREMCHG         = _OS\IS_MACOS ?  -78 :   78;

  ELIBACC         = _OS\IS_MACOS ?  -79 :   79;
  ELIBBAD         = _OS\IS_MACOS ?  -80 :   80;
  ELIBSCN         = _OS\IS_MACOS ?  -81 :   81;
  ELIBMAX         = _OS\IS_MACOS ?  -82 :   82;
  ELIBEXEC        = _OS\IS_MACOS ?  -83 :   83;

  EILSEQ          = _OS\EILSEQ;
  ERESTART        = _OS\IS_MACOS ?  -85 :   85;
  ESTRPIPE        = _OS\IS_MACOS ?  -86 :   86;
  EUSERS          = _OS\EUSERS;
  ENOTSOCK        = _OS\ENOTSOCK;
  EDESTADDRREQ    = _OS\EDESTADDRREQ;
  EMSGSIZE        = _OS\EMSGSIZE;
  EPROTOTYPE      = _OS\EPROTOTYPE;
  ENOPROTOOPT     = _OS\ENOPROTOOPT;
  EPROTONOSUPPORT = _OS\EPROTONOSUPPORT;
  ESOCKTNOSUPPORT = _OS\ESOCKTNOSUPPORT;
  ENOTSUP         = _OS\ENOTSUP;
  EOPNOTSUPP      = _OS\EOPNOTSUPP;
  EPFNOSUPPORT    = _OS\EPFNOSUPPORT;
  EAFNOSUPPORT    = _OS\EAFNOSUPPORT;
  EADDRINUSE      = _OS\EADDRINUSE;
  EADDRNOTAVAIL   = _OS\EADDRNOTAVAIL;
  ENETDOWN        = _OS\ENETDOWN;
  ENETUNREACH     = _OS\ENETUNREACH;
  ENETRESET       = _OS\ENETRESET;
  ECONNABORTED    = _OS\ECONNABORTED;
  ECONNRESET      = _OS\ECONNRESET;
  ENOBUFS         = _OS\ENOBUFS;
  EISCONN         = _OS\EISCONN;
  ENOTCONN        = _OS\ENOTCONN;
  ESHUTDOWN       = _OS\ESHUTDOWN;
  ETOOMANYREFS    = _OS\IS_MACOS ? -109 :  109;
  ETIMEDOUT       = _OS\ETIMEDOUT;
  ECONNREFUSED    = _OS\ECONNREFUSED;
  // MacOS:
  // 62: ELOOP (35)
  // 63: ENAMETOOLONG (36)
  EHOSTDOWN       = _OS\EHOSTDOWN;
  EHOSTUNREACH    = _OS\EHOSTUNREACH;
  // 66: ENOTEMPTY (39)
  EPROCLIM        = _OS\IS_MACOS ?   67 :  -67;
  // 68: EUSERS (87)
  // 69: EDQUOT (112)
  EALREADY        = _OS\EALREADY;
  EINPROGRESS     = _OS\EINPROGRESS;
  ESTALE          = _OS\ESTALE;

  EUCLEAN         = _OS\IS_MACOS ? -117 :  117;
  ENOTNAM         = _OS\IS_MACOS ? -118 :  118;
  ENAVAIL         = _OS\IS_MACOS ? -119 :  119;
  EISNAM          = _OS\IS_MACOS ? -120 :  120;
  EREMOTEIO       = _OS\IS_MACOS ? -121 :  121;
  EDQUOT          = _OS\EDQUOT;

  ENOMEDIUM       = _OS\IS_MACOS ? -123 :  123;
  EMEDIUMTYPE     = _OS\IS_MACOS ? -124 :  124;

  // MacOS Extensions
  EBADRPC         = _OS\IS_MACOS ?   72 :  -72;
  ERPCMISMATCH    = _OS\IS_MACOS ?   73 :  -73;
  EPROGUNAVAIL    = _OS\IS_MACOS ?   74 :  -74;
  EPROGMISMATCH   = _OS\IS_MACOS ?   75 :  -75;
  EPROCUNAVAIL    = _OS\IS_MACOS ?   76 :  -76;
  // 77: ENOLCK (37)
  // 78: ENOSYS (38)
  EFTYPE          = _OS\IS_MACOS ?   79 :  -79;
  EAUTH           = _OS\IS_MACOS ?   80 :  -80;
  ENEEDAUTH       = _OS\IS_MACOS ?   81 :  -81;
  EPWROFF         = _OS\IS_MACOS ?   82 :  -82;
  EDEVERR         = _OS\IS_MACOS ?   83 :  -83;
  // 84: EOVERFLOW (75)
  EBADARCH        = _OS\IS_MACOS ?   86 :  -86;
  ESHLIBVERS      = _OS\IS_MACOS ?   87 :  -87;
  EBADMACHO       = _OS\IS_MACOS ?   88 :  -88;
  ECANCELLED      = _OS\IS_MACOS ?   89 :  -89;
  // 90: EIDRM (43)
  // 91: ENOMSG (42)
  // 92: EILSEQ (84)
  ENOATTR         = _OS\IS_MACOS ?   93 :  -93;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/socket.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

function socket(
  SocketDomain $domain,
  SocketType $type,
  int $protocol,
): FileDescriptor {
  return _OS\wrap_impl(
    () ==> _OS\socket($domain as int, $type as int, $protocol),
  );
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/mkostemps.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\Str;
use namespace HH\Lib\_Private\_OS;

/** Create a temporary file using a template filename, with an invariant suffix,
 * and the specified open flags.
 *
 * The template must contain exactly 6 `X` characters, followed immediately
 * by the invariant suffix.
 *
 * The length of the suffix must be specified; for example, if the template is
 * `fooXXXXXXbar`, the suffix len is 3, or for `fooXXXXXXbarbaz` it is 6. For
 * `fooXXXXXXXXXXXXXXXXXX`, any suffix len between 0 and 12 is valid.
 *
 * The template may be either a relative or absolute path, however the parent
 * directory must already exist.
 *
 * This function takes the same flags as `OS\open()`; like that function,
 * `O_CLOEXEC` is implied.
 *
 * The temporary file:
 * - will be a new file (i.e. `O_CREAT | O_EXCL`)
 * - be owned by the current user
 * - be created with mode 0600
 *
 * @see open
 * @see mkostemp
 * @see mkstemp
 * @see mkstemps
 *
 * @returns a `FileDescriptor` and the actual path.
 */
function mkostemps(
  string $template,
  int $suffix_length,
  int $flags,
): (FileDescriptor, string) {
  _OS\arg_assert($suffix_length >= 0, 'Suffix length must not be negative');
  _OS\arg_assert(
    Str\length($template) >= $suffix_length + 6,
    'Suffix length must be at most 6 less than the length of the template',
  );
  if ($suffix_length === 0) {
    _OS\arg_assert(
      Str\ends_with($template, 'XXXXXX'),
      'Template must end with exactly 6 `X` characters',
    );
  } else if ($suffix_length > 0) {
    $base = Str\slice($template, 0, Str\length($template) - $suffix_length);
    _OS\arg_assert(
      Str\ends_with($base, 'XXXXXX'),
      'Template must be of form prefixXXXXXXsuffix - exactly 6 `X` '.
      'characters are required',
    );
  }
  // We do not want LightProcess to be observable.
  $flags |= O_CLOEXEC;

  return _OS\wrap_impl(() ==> _OS\mkostemps($template, $suffix_length, $flags));
}

/** Create a temporary file using a template filename, with an invariant suffix.
 *
 * The template must contain exactly 6 `X` characters, followed immediately
 * by the invariant suffix.
 *
 * The length of the suffix must be specified; for example, if the template is
 * `fooXXXXXXbar`, the suffix len is 3, or for `fooXXXXXXbarbaz` it is 6. For
 * `fooXXXXXXXXXXXXXXXXXX`, any suffix len between 0 and 12 is valid.
 *
 * The template may be either a relative or absolute path, however the parent
 * directory must already exist.
 *
 * The temporary file:
 * - will be a new file (i.e. `O_CREAT | O_EXCL`)
 * - be owned by the current user
 * - be created with mode 0600
 *
 * @see mkostemp
 * @see mkostemps
 * @see mkstemp
 *
 * @returns a `FileDescriptor` and the actual path.
 */
function mkstemps(string $template, int $suffix_len): (FileDescriptor, string) {
  return mkostemps($template, $suffix_len, /* flags = */ 0);
}

/** Create a temporary file using a template filename and the specified open
 * flags.
 *
 * The template must end with exactly 6 `X` characters; the template may be
 * either a relative or absolute path, however the parent directory must already
 * exist.
 *
 * This function takes the same flags as `OS\open()`; like that function,
 * `O_CLOEXEC` is implied.
 *
 * The temporary file:
 * - will be a new file (i.e. `O_CREAT | O_EXCL`)
 * - be owned by the current user
 * - be created with mode 0600
 *
 * @see open
 * @see mkostemps
 * @see mkstemp
 * @see mkstemps
 *
 * @returns a `FileDescriptor` and the actual path.
 */
function mkostemp(string $template, int $flags): (FileDescriptor, string) {
  return mkostemps($template, /* suffix_len = */ 0, $flags);
}

/** Create a temporary file using a template filename.
 *
 * The template must end with exactly 6 `X` characters; the template may be
 * either a relative or absolute path, however the parent directory must already
 * exist.
 *
 * The temporary file:
 * - will be a new file (i.e. `O_CREAT | O_EXCL`)
 * - be owned by the current user
 * - be created with mode 0600
 *
 * @see mkostemp
 * @see mkostemps
 * @see mkstemps
 *
 * @returns a `FileDescriptor` and the actual path.
 */
function mkstemp(string $template): (FileDescriptor, string) {
  return mkostemps($template, /* suffix_len = */ 0, /* flags = */ 0);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/in_addr.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

/** The type of the network form of an INET (IPv4) address, in host byte order.
 *
 * Note that this differs from the C API, which uses network byte order.
 *
 * @see `in6_addr`
 */
type in_addr = int;
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/sockaddr_in.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

/** Address of an INET (IPv4) socket.
 *
 * See `man 7 ip` (Linux) or `man 4 inet` (BSD) for details.
 *
 * @see `sockaddr_in6` for INET6 (IPv6) sockets.
 */
final class sockaddr_in extends sockaddr {
  /** Construct a `sockaddr_in`.
   *
   * Unlike the C API, all integers are in host byte order, not network byte
   * order.
   */
  public function __construct(
    private int $port,
    private in_addr $address,
  ) {
  }

  <<__Override>>
  final public function getFamily(): AddressFamily {
    return AddressFamily::AF_INET;
  }

  /** Get the port, in host byte order. */
  final public function getPort(): int{
    return $this->port;
  }

  /** Get the IP address, as a 32-bit integer, in host byte order. */
  final public function getAddress(): in_addr {
    return $this->address;
  }

  final public function __debugInfo(): darray<string, mixed> {
    return darray[
      'port (host byte order)' => $this->port,
      'address (uint32)' => $this->address,
      'address (presentation format)' =>
        inet_ntop_inet($this->address),
    ];
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/open.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

// Not using an enum (for now?) as it's a bit mask
const int O_RDONLY = _OS\O_RDONLY;
const int O_WRONLY = _OS\O_WRONLY;
const int O_RDWR = _OS\O_RDWR;

const int O_NONBLOCK = _OS\O_NONBLOCK;
const int O_APPEND = _OS\O_APPEND;
const int O_CREAT = _OS\O_CREAT;
const int O_TRUNC = _OS\O_TRUNC;
const int O_EXCL = _OS\O_EXCL;
const int O_NOFOLLOW = _OS\O_NOFOLLOW;
const int O_CLOEXEC = _OS\O_CLOEXEC;

/** Open the specified path.
 *
 * See `man 2 open` for details. On error, an `ErrnoException` will be thrown.
 *
 * @param $flags a bitmask of `O_` flags; one out of `O_RDONLY`, `O_WRONLY`,
 *    and `O_RDWR` **must** be specified. `O_CLOEXEC` is implicit, so that
 *    standalone CLI mode is consistent with server modes. If needed, this can
 *    be removed with `OS\fcntl()`.
 * @param $mode specify the mode of the file to create if `O_CREAT` is specified
 *    and the file does not exist.
 */
function open(string $path, int $flags, ?int $mode = null): FileDescriptor {
  if (
    ($flags & O_RDONLY) !== O_RDONLY &&
    ($flags & O_WRONLY) !== O_WRONLY &&
    ($flags & O_RDWR) !== O_RDWR
  ) {
    _OS\throw_errno(
      Errno::EINVAL,
      'O_RDONLY, O_WRONLY, or O_RDWR must be specified',
    );
  }
  if ($mode !== null && ($flags & O_CREAT) !== O_CREAT) {
    _OS\throw_errno(
      Errno::EINVAL,
      'mode should only be specified in combination with O_CREAT',
    );
  }
  if (($flags & O_CREAT) && $mode === null) {
    _OS\throw_errno(
      Errno::EINVAL,
      'mode must be specified when O_CREAT is specified',
    );
  }
  $flags |= _OS\O_CLOEXEC;
  return _OS\wrap_impl(() ==> _OS\open($path, $flags, $mode ?? 0));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/sockaddr_un.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

/** Address of a UNIX-domain socket.
 *
 * UNIX sockets *may* have a path, which will usually - but not always - exist
 * on the local filesystem.
 *
 * See `man 7 unix` (Linux) or `man 6 unix` (BSD) for details.
 */
final class sockaddr_un extends sockaddr {
  public function __construct(private ?string $path) {}

  <<__Override>>
  final public function getFamily(): AddressFamily {
    return AddressFamily::AF_UNIX;
  }

  /** Get the path (if any) of a socket.
   *
   * @returns `null` if the socket does not have a path, for example, if created
   *   with `socketpair()`
   * @returns a `string` if the socket does have a path; this is usually - but
   *   not always - a filesystem path. For example, Linux supports 'abstract'
   *   unix sockets, which have a path beginning with a null byte and do not
   *   correspond to the filesystem.
   */
  final public function getPath(): ?string {
    return $this->path;
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/HErrno.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

// hackfmt-ignore
/** OS-level host error number constants from `netdb.h`.
 *
 * These values are typically stored in a global `h_errno` variable by C APIs.
 *
 * `NO_ADDRESS` is not defined here:
 * - on Linux, it is an alias for `NO_DATA`
 * - on MacOS, it is undefined.
 */
enum HErrno: int {
  HOST_NOT_FOUND = 1;
  TRY_AGAIN      = 2;
  NO_RECOVERY    = 3;
  NO_DATA        = 4;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/fcntl.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Supported operations for `fcntl()` */
enum FcntlOp: int {
  F_GETFD = _OS\F_GETFD;
  F_GETFL = _OS\F_GETFL;
  F_GETOWN = _OS\F_GETOWN;
  F_SETFD = _OS\F_SETFD;
  F_SETFL = _OS\F_SETFL;
  F_SETOWN = _OS\F_SETOWN;
}

const int FD_CLOEXEC = _OS\FD_CLOEXEC;

/** Control operations for file descriptors.
 *
 * See `man 2 fcntl` for details. On error, an `ErrnoException` will be thrown.
 */
function fcntl(FileDescriptor $fd, FcntlOp $cmd, ?int $arg = null): mixed {
  return _OS\wrap_impl(() ==> _OS\fcntl($fd, $cmd as int, $arg));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/connect.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Start a socket connection.
 *
 * See `man 2 connect` for details.
 *
 * @see `socket()`
 * @see `bind()`
 * @see `listen()`
 * @see `accept()`
 */
function connect(FileDescriptor $fd, sockaddr $sa): void {
  _OS\wrap_impl(
    () ==> _OS\connect($fd, _OS\native_sockaddr_from_sockaddr($sa)),
  );
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/read.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Read from the specified `FileDescriptor`.
 *
 * See `man 2 read` for details. On error, an `ErrnoException` will be thrown.
 */
function read(FileDescriptor $fd, int $max_bytes): string {
  return _OS\wrap_impl(() ==> _OS\read($fd, $max_bytes));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/HErrnoException.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\C;
use namespace HH\Lib\_Private\_OS;


/**
 * Class for exceptions reported via the C `h_errno` variable.
 */
final class HErrnoException extends \Exception {
  public function __construct(private HErrno $errno, string $message) {
    parent::__construct($message);
  }

  final public function getHErrno(): HErrno{
    return $this->errno;
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/inet_pton.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\Str;
use namespace HH\Lib\_Private\_OS;

/** Convert a presentation-format (dotted) INET (IPv4)) address to network
 * format.
 *
 * See `man inet_pton`.
 *
 * @see inet_pton_inet6 for IPv6
 */
function inet_pton_inet(string $addr): in_addr {
  // FIXME: add native builtin, use that instead
  if (!\filter_var($addr, \FILTER_VALIDATE_IP, \FILTER_FLAG_IPV4)) {
    _OS\throw_errno(
      Errno::EINVAL,
      "'%s' does not look like an IPv4 address",
      $addr,
    );
  }
  return \ip2long($addr);
}

/** Convert a presentation-format (colon-separated) INET6 (IPv6) address to
 * network format.
 *
 * See `man inet_pton`.
 *
 * @see inet_pton_inet for IPv4
 */

function inet_pton_inet6(string $addr): in6_addr {
  // FIXME: add native builtin, use that instead.
  if (!\filter_var($addr, \FILTER_VALIDATE_IP, \FILTER_FLAG_IPV4)) {
    _OS\throw_errno(
      Errno::EINVAL,
      "'%s' does not look like an IPv6 address",
      $addr,
    );
  }
  return _OS\string_as_in6_addr_UNSAFE(\inet_pton($addr));
}

/** Convert a presentation-format INET/INET6 address to network format.
 *
 * See `man inet_pton`
 *
 * @see inet_pton_inet() for a better-typed version for IPv4
 * @see inet_pton_inet6() for a better-typed version for IPv6
 */
function inet_pton(AddressFamily $af, string $addr): mixed {
  switch ($af) {
    case AddressFamily::AF_INET:
      return inet_pton_inet($addr);
    case AddressFamily::AF_INET6:
      return inet_pton_inet6($addr);
    default:
      _OS\throw_errno(
        Errno::EAFNOSUPPORT,
        "Address family is not supported by inet_pton",
      );
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/_Private/native_sockaddr_from_sockaddr.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_OS {
use namespace HH\Lib\OS;

function native_sockaddr_from_sockaddr(OS\sockaddr $sa): namespace\sockaddr {
  if ($sa is OS\sockaddr_un) {
    $path = $sa->getPath();
    if ($path is null) {
      return new namespace\sockaddr_un_unnamed();
    }
    return new namespace\sockaddr_un_pathname($path);
  }

  if ($sa is OS\sockaddr_in) {
    return new namespace\sockaddr_in(
      $sa->getPort(),
      $sa->getAddress(),
    );
  }

  if ($sa is OS\sockaddr_in6) {
    return new namespace\sockaddr_in6(
      $sa->getPort(),
      $sa->getFlowInfo(),
      $sa->getAddress() as string,
      $sa->getScopeID(),
    );
  }

  throw_errno(
    OS\Errno::EAFNOSUPPORT,
    "Unhandled sockaddr class %s",
    \get_class($sa),
  );
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/_Private/Errno.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_OS {

use namespace HH\Lib\{C, OS, Str};

<<__Memoize>>
function get_throw_errno_impl(): (function(OS\Errno, string): noreturn) {
  $single_code = keyset[
    OS\ChildProcessException::class,
    OS\ConnectionAbortedException::class,
    OS\ConnectionRefusedException::class,
    OS\ConnectionResetException::class,
    OS\AlreadyExistsException::class,
    OS\NotFoundException::class,
    OS\IsADirectoryException::class,
    OS\IsNotADirectoryException::class,
    OS\ProcessLookupException::class,
    OS\TimeoutException::class,
  ];
  $multiple_codes = keyset[
    OS\BlockingIOException::class,
    OS\BrokenPipeException::class,
    OS\PermissionException::class,
  ];

  $throws = new \HH\Lib\Ref(dict[]);
  $add_code = (OS\Errno $code, (function(string): noreturn) $impl) ==> {
    invariant(
      !C\contains_key($throws->value, $code),
      '%s has multiple exception implementations',
      $code,
    );
    $throws->value[$code] = $impl;
  };

  foreach ($single_code as $class) {
    $code = $class::_getValidErrno();
    $add_code($code, $msg ==> {
      throw new $class($msg);
    });
  }
  foreach ($multiple_codes as $class) {
    foreach ($class::_getValidErrnos() as $code) {
      $add_code($code, $msg ==> {
        throw new $class($code, $msg);
      });
    }
  }

  $throws = $throws->value;

  return ($code, $message) ==> {
    $override = $throws[$code] ?? null;
    if ($override) {
      $override($message);
    }
    throw new OS\ErrnoException($code, $message);
  };
}

function throw_errno(
  OS\Errno $errno,
  Str\SprintfFormatString $message,
  mixed ...$args
): noreturn {
  /* HH_FIXME[4027] needs literal format string */
  $message = Str\format($message, ...$args);
  invariant(
    $errno !== 0,
    "Asked to throw an errno ('%s'), but errno indicates success",
    $message,
  );
  $name = C\firstx(get_errno_names()[$errno]);
  $impl = get_throw_errno_impl();
  $impl($errno, Str\format("%s(%d): %s", $name, $errno, $message));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/_Private/wrap_impl.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_OS {

use namespace HH\Lib\OS;

function wrap_impl<T>((function(): T) $impl): T {
  try {
    return $impl();
  } catch (namespace\ErrnoException $e) {
    throw_errno($e->getCode() as OS\Errno, '%s', $e->getMessage());
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/_Private/get_errno_names.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_OS {
use namespace HH\Lib\{Dict, Keyset, OS};

<<__Memoize>>
function get_errno_names(): dict<OS\Errno, keyset<string>> {
  $values = OS\Errno::getValues();
  return Dict\group_by(
    Keyset\keys($values),
    $name ==> $values[$name],
  ) |> Dict\map($$, $names ==> keyset($names));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/_Private/sockaddr_from_native_sockaddr.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_OS {
use namespace HH\Lib\OS;

function sockaddr_from_native_sockaddr(namespace\sockaddr $sa): OS\sockaddr {
  if ($sa is namespace\sockaddr_un_pathname) {
    return new OS\sockaddr_un($sa->sun_path);
  }
  if ($sa is namespace\sockaddr_un_unnamed) {
    return new OS\sockaddr_un(null);
  }

  if ($sa is namespace\sockaddr_in) {
    return new OS\sockaddr_in(
      $sa->sin_port,
      $sa->sin_addr,
    );
  }

  if ($sa is namespace\sockaddr_in6) {
    return new OS\sockaddr_in6(
      $sa->sin6_port,
      $sa->sin6_flowinfo,
      string_as_in6_addr_UNSAFE($sa->sin6_addr),
      $sa->sin6_scope_id,
    );
  }

  throw_errno(
    OS\Errno::EOPNOTSUPP,
    "Unhandled builtin sockaddr class %s",
    \get_class($sa),
  );
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/_Private/HError.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_OS {

use namespace HH\Lib\OS;

// hackfmt-ignore
/** OS-level host error number constants from `netdb.h`.
 *
 * These values are typically stored in a global `h_errno` variable by C APIs.
 *
 * `NO_ADDRESS` is not defined here:
 * - on Linux, it is an alias for `NO_DATA`
 * - on MacOS, it is undefined.
 */
enum HError: int {
  HOST_NOT_FOUND = 1;
  TRY_AGAIN      = 2;
  NO_RECOVERY    = 3;
  NO_DATA        = 4;
}

}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/_Private/arg_assert.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_OS {

use namespace HH\Lib\{Str, OS};

/** Raises EINVAL if condition is false */
function arg_assert(bool $condition, Str\SprintfFormatString $message, mixed ...$args): void {
  if ($condition) {
    return;
  }
  /* HH_IGNORE_ERROR[4027] passing format string */
  throw_errno(OS\Errno::EINVAL, $message, ...$args);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/_Private/constants.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_OS {

use namespace HH\Lib\OS;

const bool IS_MACOS = \PHP_OS === 'Darwin';
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/ftruncate.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

function ftruncate(FileDescriptor $fd, int $length): void {
  _OS\arg_assert($length >= 0, '$length must be >= 0, got %d', $length);
  _OS\wrap_impl(() ==> _OS\ftruncate($fd, $length));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/AddressFamily.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

enum AddressFamily: int {
  AF_UNIX = _OS\AF_UNIX;
  AF_INET = _OS\AF_INET;
  AF_INET6 = _OS\AF_INET6;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/write.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Write from the specified `FileDescriptor`.
 *
 * See `man 2 write` for details. On error, an `ErrnoException` will be thrown.
 *
 * @returns the number of bytes written; it is possible for this function to
 *   succeed with a partial write.
 */
function write(FileDescriptor $fd, string $data): int {
  return _OS\wrap_impl(() ==> _OS\write($fd, $data));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/bind.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Bind a socket to an address.
 *
 * See `man 2 bind` for details.
 *
 * @see `socket()`
 * @see `listen()`
 * @see `accept()`
 * @see `connect()`
 */
function bind(FileDescriptor $fd, sockaddr $sa): void {
  _OS\wrap_impl(() ==> _OS\bind($fd, _OS\native_sockaddr_from_sockaddr($sa)));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/in6_addr.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

  /** The type of the network form of an INET6 (IPv6) address.
   *
   * @see `in4_addr` for IPv4
   */
  newtype in6_addr = string;

}

namespace HH\Lib\_Private\_OS {
  function string_as_in6_addr_UNSAFE(string $in): \HH\Lib\OS\in6_addr {
    return $in;
  }
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/sockaddr.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Address of a socket.
 *
 * @see `sockaddr_un` for UNIX domain sockets.
 * @see `sockaddr_in` for INET (IPv4) sockets.
 * @see `sockaddr_in6` for INET6 (IPv6) sockets.
 */
abstract class sockaddr {
  /** Get the address family of the socket.
   *
   * It may be more useful to check the type of the sockaddr object instead,
   * e.g.
   *
   * ```
   * - if ($sa->getFamily() === OS\AddressFamily::AF_UNIX) {
   * + if ($sa is OS\sockaddr_un) {
   * ```
   */
  abstract public function getFamily(): AddressFamily;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/accept.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Accept a connection on a socket.
 *
 * See `man 2 accept` for details.
 *
 * @see `socket()`
 * @see `bind()`
 * @see `listen()`
 * @see `connect()`
 */
function accept(FileDescriptor $fd): (FileDescriptor, sockaddr) {
  list($fd, $sa) = _OS\wrap_impl(() ==> _OS\accept($fd));
  return tuple($fd, _OS\sockaddr_from_native_sockaddr($sa));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/inet_ntop.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\Str;
use namespace HH\Lib\_Private\_OS;

/** Convert an INET (IPv4) address from network format to presentation
 * (dotted) format.
 *
 * See `man inet_ntop`
 *
 * @see `inet_ntop_inet6` for an IPv6 version
 */
function inet_ntop_inet(in_addr $addr): string {
  // FIXME: add native builtin, use that instead
  // this actually takes a string and immediately converts to int
  return \long2ip((string)$addr);
}

/** Convert an INET6 (IPv6) address from network format to presentation
 * (colon) format.
 *
 * See `man inet_ntop`
 *
 * @see `inet_ntop_inet` for an IPv4 version
 */
function inet_ntop_inet6(in6_addr $addr): string {
  return \inet_ntop($addr as string);
}


/** Convert an INET or INET6 address to presentation format.
 *
 * See `man inet_ntop`
 *
 * Fails with:
 * - `EAFNOSUPPORT` if the address family is not supported
 * - `EINVAL` if the address is the wrong type for the family
 *
 * @see inet_ntop_inet for a better-typed version for IPv4
 * @see inet_ntop_inet6 for a better-typed version for IPv6
 */
function inet_ntop(AddressFamily $af, dynamic $addr): string {
  switch ($af) {
    case AddressFamily::AF_INET:
      if (!$addr is int) {
        _OS\throw_errno(
          Errno::EINVAL,
          "AF_INET address must be an int",
        );
      }
      // NetLongs are always uint32
      if ($addr < 0 || $addr >= (1 << 32)) {
        _OS\throw_errno(
          Errno::EINVAL,
          "AF_INET address must fit in a uint32",
        );
      }
      return inet_ntop_inet($addr);
    case AddressFamily::AF_INET6:
      if (
        !(
          $addr is string &&
          \filter_var($addr, \FILTER_VALIDATE_IP, \FILTER_FLAG_IPV6)
        )
      ) {
        _OS\throw_errno(Errno::EINVAL, "AF_INET6 address must be an in6_addr");
      }
      return inet_ntop_inet6(_OS\string_as_in6_addr_UNSAFE($addr as string));
    default:
      _OS\throw_errno(Errno::EAFNOSUPPORT, 'inet_ntop()');
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/stdio.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Get a file descriptor for request STDIN.
 *
 * Fails with EBADF if a request-specific file descriptor is not available, for
 * example, when running in HTTP server mode.
 */
function stdin(): FileDescriptor {
  return _OS\wrap_impl(() ==> _OS\request_stdio_fd(_OS\STDIN_FILENO));
}

/** Get a file descriptor for request STDOUT.
 *
 * Fails with EBADF if a request-specific file descriptor is not available, for
 * example, when running in HTTP server mode.
 */
function stdout(): FileDescriptor {
  return _OS\wrap_impl(() ==> _OS\request_stdio_fd(_OS\STDOUT_FILENO));
}

/** Get a file descriptor for request STDERR.
 *
 * Fails with EBADF if a request-specific file descriptor is not available, for
 * example, when running in HTTP server mode.
 */

function stderr(): FileDescriptor {
  return _OS\wrap_impl(() ==> _OS\request_stdio_fd(_OS\STDERR_FILENO));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/os/listen.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\OS {

use namespace HH\Lib\_Private\_OS;

/** Listen for new connections to a socket.
 *
 * See `man 2 listen` for details.
 *
 * @see `socket()`
 * @see `bind()`
 * @see `accept()`
 * @see `connect()`
 */
function listen(FileDescriptor $fd, int $backlog): void {
  _OS\wrap_impl(() ==> _OS\listen($fd, $backlog));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/_Private/OptionalIncrementalTimeout.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private {

final class OptionalIncrementalTimeout {
  private ?int $end;
  public function __construct(
    ?int $timeout_ns,
    private (function(): ?int) $timeoutHandler,
  ) {
    if ($timeout_ns is null) {
      $this->end = null;
      return;
    }
    $this->end = self::nowNS() + $timeout_ns;
  }

  public function getRemainingNS(): ?int {
    if ($this->end is null) {
      return null;
    }

    $remaining = $this->end - self::nowNS();
    if ($remaining <= 0) {
      $th = $this->timeoutHandler;
      return $th();
    }
    return $remaining;
  }

  private static function nowNS(): int {
    return \clock_gettime_ns(\CLOCK_MONOTONIC);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/select.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\_Private;
use namespace HH\Lib\_Private\_Str;

/**
 * Returns a substring of length `$length` of the given string starting at the
 * `$offset`.
 *
 * If no length is given, the slice will contain the rest of the
 * string. If the length is zero, the empty string will be returned. If the
 * offset is out-of-bounds, a ViolationException will be thrown.
 *
 * Previously known as `substr` in PHP.
 */
function slice(
  string $string,
  int $offset,
  ?int $length = null,
)[]: string {
  return _Str\slice_l($string, $offset, $length ?? \PHP_INT_MAX);
}

/**
 * Returns the string with the given prefix removed, or the string itself if
 * it doesn't start with the prefix.
 */
function strip_prefix(
  string $string,
  string $prefix,
)[]: string {
  return _Str\strip_prefix_l($string, $prefix);
}

/**
 * Returns the string with the given suffix removed, or the string itself if
 * it doesn't end with the suffix.
 */
function strip_suffix(
  string $string,
  string $suffix,
)[]: string {
  return _Str\strip_suffix_l($string, $suffix);
}

/**
 * Returns the given string with whitespace stripped from the beginning and end.
 *
 * If the optional character mask isn't provided, the following characters will
 * be stripped: space, tab, newline, carriage return, NUL byte, vertical tab.
 *
 * - To only strip from the left, see `Str\trim_left()`.
 * - To only strip from the right, see `Str\trim_right()`.
 */
function trim(
  string $string,
  ?string $char_mask = null,
)[]: string {
  return _Str\trim_l($string, $char_mask);
}

/**
 * Returns the given string with whitespace stripped from the left.
 * See `Str\trim()` for more details.
 *
 * - To strip from both ends, see `Str\trim()`.
 * - To only strip from the right, see `Str\trim_right()`.
 * - To strip a specific prefix (instead of all characters matching a mask),
 *   see `Str\strip_prefix()`.
 */
function trim_left(
  string $string,
  ?string $char_mask = null,
)[]: string {
  return _Str\trim_left_l($string, $char_mask);
}

/**
 * Returns the given string with whitespace stripped from the right.
 * See `Str\trim` for more details.
 *
 * - To strip from both ends, see `Str\trim()`.
 * - To only strip from the left, see `Str\trim_left()`.
 * - To strip a specific suffix (instead of all characters matching a mask),
 *   see `Str\strip_suffix()`.
 */
function trim_right(
  string $string,
  ?string $char_mask = null,
)[]: string {
  return _Str\trim_right_l($string, $char_mask);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/divide.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\{Locale, _Private\_Str};

/**
 * Returns a vec containing the string split into chunks of the given size.
 *
 * To split the string on a delimiter, see `Str\split()`.
 */
function chunk(
  string $string,
  int $chunk_size = 1,
)[]: vec<string> {
  return _Str\chunk_l($string, $chunk_size);
}

/**
 * Returns a vec containing the string split on the given delimiter. The vec
 * will not contain the delimiter itself.
 *
 * If the limit is provided, the vec will only contain that many elements, where
 * the last element is the remainder of the string.
 *
 * To split the string into equally-sized chunks, see `Str\chunk()`.
 * To use a pattern as delimiter, see `Regex\split()`.
 *
 * Previously known as `explode` in PHP.
 */
function split(
  string $string,
  string $delimiter,
  ?int $limit = null,
)[]: vec<string> {
  return vec(_Str\split_l($string, $delimiter, $limit));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/divide_l.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\{Locale, _Private\_Str};

/**
 * Returns a vec containing the string split into chunks with the given number
 * of characters.
 *
 * $chunk_size is in characters,
 *
 * To split the string on a delimiter, see `Str\split_l()`.
 */
function chunk_l(
  Locale\Locale $locale,
  string $string,
  int $chunk_size = 1,
)[]: vec<string> {
  return _Str\chunk_l($string, $chunk_size, $locale);
}

/**
 * Returns a vec containing the string split on the given delimiter. The vec
 * will not contain the delimiter itself.
 *
 * If the limit is provided, the vec will only contain that many elements, where
 * the last element is the remainder of the string.
 *
 * To split the string into equally-sized chunks, see `Str\chunk_l()`.
 * To use a pattern as delimiter, see `Regex\split()`.
 */
function split_l(
  Locale\Locale $locale,
  string $string,
  string $delimiter,
  ?int $limit = null,
)[]: vec<string> {
  return _Str\split_l($string, $delimiter, $limit, $locale);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/format.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\_Private\_Str;

/**
 * This interface describes features of a valid format string for `Str\format`
 */
interface SprintfFormat {
  public function format_d(int $s): string;
  public function format_s(string $s): string;
  public function format_u(int $s): string;
  public function format_b(int $s): string; // bit strings
  // Technically %f is locale-dependent (and thus wrong)
  public function format_f(float $s): string;
  public function format_g(float $s): string;
  public function format_upcase_f(float $s): string;
  public function format_e(float $s): string;
  public function format_upcase_e(float $s): string;
  public function format_x(int $s): string;
  public function format_o(int $s): string;
  public function format_c(int $s): string;
  public function format_upcase_x(int $s): string;
  // %% takes no arguments
  public function format_0x25(): string;
  // Modifiers that don't change the type
  public function format_l(): SprintfFormat;
  public function format_0x20(): SprintfFormat; // ' '
  public function format_0x2b(): SprintfFormat; // '+'
  public function format_0x2d(): SprintfFormat; // '-'
  public function format_0x2e(): SprintfFormat; // '.'
  public function format_0x30(): SprintfFormat; // '0'
  public function format_0x31(): SprintfFormat; // ...
  public function format_0x32(): SprintfFormat;
  public function format_0x33(): SprintfFormat;
  public function format_0x34(): SprintfFormat;
  public function format_0x35(): SprintfFormat;
  public function format_0x36(): SprintfFormat;
  public function format_0x37(): SprintfFormat;
  public function format_0x38(): SprintfFormat;
  public function format_0x39(): SprintfFormat; // '9'
  public function format_0x27(): SprintfFormatQuote;
}

/**
 * Accessory interface for `SprintfFormat`
 * Note: This should really be a wildcard. It's only used once (with '=').
 */
interface SprintfFormatQuote {
  public function format_0x3d(): SprintfFormat;
}

type SprintfFormatString = \HH\FormatString<SprintfFormat>;

/**
 * Given a valid format string (defined by `SprintfFormatString`), return a
 * formatted string using `$format_args`
 */
function format(
  SprintfFormatString $format_string,
  mixed ...$format_args
)[]: string {
  return _Str\vsprintf_l(null, $format_string as string, $format_args);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/combine.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\Vec;

/**
 * Returns a string formed by joining the elements of the Traversable with the
 * given `$glue` string.
 *
 * Previously known as `implode` in PHP.
 */
function join(
  readonly Traversable<arraykey> $pieces,
  string $glue,
)[]: string {
  if ($pieces is Container<_>) {
    return \implode($glue, $pieces);
  }
  return \implode($glue, vec($pieces));
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/introspect_l.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\{Locale, _Private, _Private\_Str};

/**
 * Returns < 0 if `$string1` is less than `$string2`, > 0 if `$string1` is
 * greater than `$string2`, and 0 if they are equal.
 *
 * For a case-insensitive comparison, see `Str\compare_ci_l()`.
 *
 * Locale-specific collation rules will be followed, and strings will be
 * normalized in encodings that support multiple representations of the same
 * characters, such as UTF8.
 */
function compare_l(
  Locale\Locale $locale,
  string $string1,
  string $string2,
)[]: int {
  return _Str\strcoll_l($string1, $string2, $locale);
}

/**
 * Returns < 0 if `$string1` is less than `$string2`, > 0 if `$string1` is
 * greater than `$string2`, and 0 if they are equal (case-insensitive).
 *
 * For a case-sensitive comparison, see `Str\compare_l()`.
 *
 * Locale-specific collation and case-sensitivity rules will be used. For
 * example, case-insensitive comparisons between `i`, `I`, `ı`, and `İ` vary
 * by locale.
 */
function compare_ci_l(
  Locale\Locale $locale,
  string $string1,
  string $string2,
)[]: int {
  return _Str\strcasecmp_l($string1, $string2, $locale);
}

/**
 * Returns whether the "haystack" string contains the "needle" string.
 *
 * An optional offset determines where in the haystack the search begins. If the
 * offset is negative, the search will begin that many characters from the end
 * of the string. If the offset is out-of-bounds, a InvalidArgumentException will be
 * thrown.
 *
 * Strings will be normalized for comparison in encodings that support multiple
 * representations, such as UTF-8.
 *
 * - To get the position of the needle, see `Str\search_l()`.
 * - To search for the needle case-insensitively, see `Str\contains_ci_l()`.
 */
function contains_l(
  Locale\Locale $locale,
  string $haystack,
  string $needle,
  int $offset = 0,
)[]: bool {
  if ($needle === '') {
    if ($offset === 0) {
      return true;
    }
    $length = length_l($locale, $haystack);
    if ($offset > $length || $offset < -$length) {
      throw new \InvalidArgumentException(
        format('Offset %d out of bounds for length %d', $offset, $length)
      );
    }
    return true;
  }
  return search_l($locale, $haystack, $needle, $offset) !== null;
}

/**
 * Returns whether the "haystack" string contains the "needle" string
 * (case-insensitive).
 *
 * An optional offset determines where in the haystack the search begins. If the
 * offset is negative, the search will begin that many characters from the end
 * of the string. If the offset is out-of-bounds, a InvalidArgumentException will be
 * thrown.
 *
 * Locale-specific rules for case-insensitive comparisons will be used, and
 * strings will be normalized before comparing if the locale specifies an
 * encoding that supports multiple representations of the same characters, such
 * as UTF-8.
 *
 * - To search for the needle case-sensitively, see `Str\contains_l()`.
 * - To get the position of the needle case-insensitively, see `Str\search_ci_l()`.
 */
function contains_ci_l(
  Locale\Locale $locale,
  string $haystack,
  string $needle,
  int $offset = 0,
)[]: bool {
  if ($needle === '') {
    if ($offset === 0) {
      return true;
    }
    $length = length_l($locale, $haystack);
    if ($offset > $length || $offset < -$length) {
      throw new \InvalidArgumentException(
        format('Offset %d out of bounds for length %d', $offset, $length)
      );
    }
    return true;
  }
  return search_ci_l($locale, $haystack, $needle, $offset) !== null;
}

/**
 * Returns whether the string ends with the given suffix.
 *
 * Strings will be normalized before comparing if the locale specifies an
 * encoding that supports multiple representations of the same characters, such
 * as UTF-8.
 *
 * For a case-insensitive check, see `Str\ends_with_ci_l()`.
 */
function ends_with_l(
  Locale\Locale $locale,
  string $string,
  string $suffix,
)[]: bool {
  return _Str\ends_with_l($string, $suffix, $locale);
}

/**
 * Returns whether the string ends with the given suffix (case-insensitive).
 *
 * Locale-specific rules for case-insensitive comparisons will be used, and
 * strings will be normalized before comparing if the locale specifies an
 * encoding that supports multiple representations of the same characters, such
 * as UTF-8.
 *
 * For a case-sensitive check, see `Str\ends_with_l()`.
 */
function ends_with_ci_l(
  Locale\Locale $locale,
  string $string,
  string $suffix,
)[]: bool {
  return _Str\ends_with_ci_l($string, $suffix, $locale);
}

/**
 * Returns the length of the given string in characters.
 *
 * This function may be `O(1)` or `O(n)` depending on the encoding specified
 * by the locale (LC_CTYPE).
 *
 * @see `Str\length()` (or pass `Locale\c()`) for the length in bytes.
 */
function length_l(
  Locale\Locale $locale,
  string $string,
)[]: int {
  return _Str\strlen_l($string, $locale);
}

/**
 * Returns the first position of the "needle" string in the "haystack" string,
 * or null if it isn't found.
 *
 * An optional offset determines where in the haystack the search begins. If the
 * offset is negative, the search will begin that many characters from the end
 * of the string. If the offset is out-of-bounds, a InvalidArgumentException will be
 * thrown.
 *
 * - To simply check if the haystack contains the needle, see `Str\contains_l()`.
 * - To get the case-insensitive position, see `Str\search_ci_l()`.
 * - To get the last position of the needle, see `Str\search_last_l()`.
 */
function search_l(
  Locale\Locale $locale,
  string $haystack,
  string $needle,
  int $offset = 0,
)[]: ?int {
  $position = _Str\strpos_l($haystack, $needle, $offset, $locale);
  if ($position < 0) {
    return null;
  }
  return $position;
}

/**
 * Returns the first position of the "needle" string in the "haystack" string,
 * or null if it isn't found (case-insensitive).
 *
 * Locale-specific rules for case-insensitive comparisons will be used.
 *
 * An optional offset determines where in the haystack the search begins. If the
 * offset is negative, the search will begin that many characters from the end
 * of the string. If the offset is out-of-bounds, a InvalidArgumentException will be
 * thrown.
 *
 * - To simply check if the haystack contains the needle, see `Str\contains()`.
 * - To get the case-sensitive position, see `Str\search()`.
 * - To get the last position of the needle, see `Str\search_last()`.
 */
function search_ci_l(
  Locale\Locale $locale,
  string $haystack,
  string $needle,
  int $offset = 0,
)[]: ?int {
  $position = _Str\stripos_l($haystack, $needle, $offset, $locale);
  if ($position < 0) {
    return null;
  }
  return $position;
}

/**
 * Returns the last position of the "needle" string in the "haystack" string,
 * or null if it isn't found.
 *
 * An optional offset determines where in the haystack (from the beginning) the
 * search begins. If the offset is negative, the search will begin that many
 * characters from the end of the string and go backwards. If the offset is
 * out-of-bounds, a InvalidArgumentException will be thrown.
 *
 * - To simply check if the haystack contains the needle, see `Str\contains()`.
 * - To get the first position of the needle, see `Str\search()`.
 *
 * Previously known in PHP as `strrpos`.
 */
function search_last_l(
  Locale\Locale $locale,
  string $haystack,
  string $needle,
  int $offset = 0,
)[]: ?int {
  $haystack_length = length_l($locale, $haystack);
  $position = _Str\strrpos_l($haystack, $needle, $offset, $locale);
  if ($position < 0) {
    return null;
  }
  return $position;
}

/**
 * Returns whether the string starts with the given prefix.
 *
 * Strings will be normalized for comparison in encodings that support multiple
 * representations, such as UTF-8.
 *
 * For a case-insensitive check, see `Str\starts_with_ci_l()`.
 * For a byte-wise check, see `Str\starts_with()`
 */
function starts_with_l(
  Locale\Locale $locale,
  string $string,
  string $prefix,
)[]: bool {
  return _Str\starts_with_l($string, $prefix, $locale);
}

/**
 * Returns whether the string starts with the given prefix (case-insensitive).
 *
 * Locale-specific collation rules will be followed, and strings will be
 * normalized in encodings that support multiple representations of the same
 * characters, such as UTF8.
 *
 * For a case-sensitive check, see `Str\starts_with()`.
 */
function starts_with_ci_l(
  Locale\Locale $locale,
  string $string,
  string $prefix,
)[]: bool {
  return _Str\starts_with_ci_l($string, $prefix, $locale);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/transform.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\{_Private, C, Keyset, Vec, _Private\_Str};

/**
 * Returns the string with the first character capitalized.
 *
 * If the first character is already capitalized or isn't alphabetic, the string
 * will be unchanged.
 *
 * - To capitalize all characters, see `Str\uppercase()`.
 * - To capitalize all words, see `Str\capitalize_words()`.
 */
function capitalize(
  string $string,
)[]: string {
  if ($string === '') {
    return '';
  }
  return _Str\uppercase_l(slice($string, 0, 1)) . slice($string, 1);
}

/**
 * Returns the string with all words capitalized.
 *
 * Words are delimited by space, tab, newline, carriage return, form-feed, and
 * vertical tab by default, but you can specify custom delimiters.
 *
 * - To capitalize all characters, see `Str\uppercase()`.
 * - To capitalize only the first character, see `Str\capitalize()`.
 */
function capitalize_words(
  string $string,
  ?string $delimiters = null,
)[]: string {
  if ($string === '') {
    return $string;
  }
  if ($delimiters === null) {
    // Delimiters are defined by the locale
    return _Str\titlecase_l($string, /* locale = */ null);
  }

  $words = vec[];
  $offset = 0;
  $length = \strlen($string);
  while ($offset < $length) {
    $substr_len = \strcspn($string, $delimiters, $offset);
    $words[] = tuple(
      \substr($string, $offset, $substr_len),
      $offset + $substr_len < $length ? $string[$offset + $substr_len] : ''
    );
    $offset += $substr_len + 1;
  }

  $string = '';
  foreach ($words as list($word, $delimiter)) {
    $string .= namespace\capitalize($word).$delimiter;
  }
  return $string;
}

/**
 * Returns a string representation of the given number with grouped thousands.
 *
 * If `$decimals` is provided, the string will contain that many decimal places.
 * The optional `$decimal_point` and `$thousands_separator` arguments define the
 * strings used for decimals and commas, respectively.
 */
function format_number(
  num $number,
  int $decimals = 0,
  string $decimal_point = '.',
  string $thousands_separator = ',',
)[]: string {
  return \number_format(
    (float) $number,
    $decimals,
    $decimal_point,
    $thousands_separator,
  );
}

/**
 * Returns the string with all alphabetic characters converted to lowercase.
 */
function lowercase(
  string $string,
)[]: string {
  return _Str\lowercase_l($string);
}

/**
 * Returns the string padded to the total length (in bytes) by appending the
 * `$pad_string` to the left.
 *
 * If the length of the input string plus the pad string exceeds the total
 * length, the pad string will be truncated. If the total length is less than or
 * equal to the length of the input string, no padding will occur.
 *
 * To pad the string on the right, see `Str\pad_right()`.
 * To pad the string to a fixed number of characters, see `Str\pad_left_l()`.
 */
function pad_left(
  string $string,
  int $total_length,
  string $pad_string = ' ',
)[]: string {
  return _Str\pad_left_l($string, $total_length, $pad_string);
}

/**
 * Returns the string padded to the total length (in bytes) by appending the
 * `$pad_string` to the right.
 *
 * If the length of the input string plus the pad string exceeds the total
 * length, the pad string will be truncated. If the total length is less than or
 * equal to the length of the input string, no padding will occur.
 *
 * To pad the string on the left, see `Str\pad_left()`.
 * To pad the string to a fixed number of characters, see `Str\pad_right_l()`.
 */
function pad_right(
  string $string,
  int $total_length,
  string $pad_string = ' ',
)[]: string {
  return _Str\pad_right_l($string, $total_length, $pad_string);
}

/**
 * Returns the input string repeated `$multiplier` times.
 *
 * If the multiplier is 0, the empty string will be returned.
 */
function repeat(
  string $string,
  int $multiplier,
)[]: string {
  if ($multiplier < 0) {
    throw new \InvalidArgumentException('Expected non-negative multiplier');
  }
  return \str_repeat($string, $multiplier);
}

/**
 * Returns the "haystack" string with all occurrences of `$needle` replaced by
 * `$replacement`.
 *
 * - For a case-insensitive search/replace, see `Str\replace_ci()`.
 * - For multiple case-sensitive searches/replacements, see `Str\replace_every()`.
 * - For multiple case-insensitive searches/replacements, see `Str\replace_every_ci()`.
 */
function replace(
  string $haystack,
  string $needle,
  string $replacement,
)[]: string {
  return _Str\replace_l($haystack, $needle, $replacement);
}

/**
 * Returns the "haystack" string with all occurrences of `$needle` replaced by
 * `$replacement` (case-insensitive).
 *
 * - For a case-sensitive search/replace, see `Str\replace()`.
 * - For multiple case-sensitive searches/replacements, see `Str\replace_every()`.
 * - For multiple case-insensitive searches/replacements, see `Str\replace_every_ci()`.
 */
// not pure: str_ireplace uses global locale for capitalization
function replace_ci(
  string $haystack,
  string $needle,
  string $replacement,
)[rx]: string {
  return _Str\replace_ci_l($haystack, $needle, $replacement);
}

/**
 * Returns the "haystack" string with all occurrences of the keys of
 * `$replacements` replaced by the corresponding values.
 *
 * Replacements are applied in the order they are specified in `$replacements`,
 * and the new values are searched again for subsequent matches. For example,
 * `dict['a' => 'b', 'b' => 'c']` is equivalent to `dict['a' => 'c']`, but
 * `dict['b' => 'c', 'a' => 'b']` is not, despite having the same elements.
 *
 * If there are multiple overlapping matches, the match occuring earlier in
 * `$replacements` (not in `$haystack`) takes precedence.
 *
 * - For a single case-sensitive search/replace, see `Str\replace()`.
 * - For a single case-insensitive search/replace, see `Str\replace_ci()`.
 * - For multiple case-insensitive searches/replacements, see `Str\replace_every_ci()`.
 * - For not having new values searched again, see `Str\replace_every_nonrecursive()`.
 */
function replace_every(
  string $haystack,
  KeyedContainer<string, string> $replacements,
)[]: string {
  return _Str\replace_every_l($haystack, dict($replacements));
}

/**
 * Returns the "haystack" string with all occurrences of the keys of
 * `$replacements` replaced by the corresponding values (case-insensitive).
 *
 * Replacements are applied in the order they are specified in `$replacements`,
 * and the new values are searched again for subsequent matches. For example,
 * `dict['a' => 'b', 'b' => 'c']` is equivalent to `dict['a' => 'c']`, but
 * `dict['b' => 'c', 'a' => 'b']` is not, despite having the same elements.
 *
 * If there are multiple overlapping matches, the match occuring earlier in
 * `$replacements` (not in `$haystack`) takes precedence.
 *
 * - For a single case-sensitive search/replace, see `Str\replace()`.
 * - For a single case-insensitive search/replace, see `Str\replace_ci()`.
 * - For multiple case-sensitive searches/replacements, see `Str\replace_every()`.
 * - For not having new values searched again, see `Str\replace_every_nonrecursive_ci()`.
 */
function replace_every_ci(
  string $haystack,
  KeyedContainer<string, string> $replacements,
)[rx]: string {
  return _Str\replace_every_ci_l($haystack, dict($replacements));
}

/**
 * Returns the "haystack" string with all occurrences of the keys of
 * `$replacements` replaced by the corresponding values. Once a substring has
 * been replaced, its new value will not be searched again.
 *
 * If there are multiple overlapping matches, the match occuring earlier in
 * `$haystack` takes precedence. If a replacer is a prefix of another (like
 * "car" and "carpet"), the longer one (carpet) takes precedence. The ordering
 * of `$replacements` therefore doesn't matter.
 *
 * - For having new values searched again, see `Str\replace_every()`.
 */
function replace_every_nonrecursive(
  string $haystack,
  KeyedContainer<string, string> $replacements,
)[rx]: string {
  return _Str\replace_every_nonrecursive_l($haystack, dict($replacements));
}

/**
 * Returns the "haystack" string with all occurrences of the keys of
 * `$replacements` replaced by the corresponding values (case-insensitive).
 * Once a substring has been replaced, its new value will not be searched
 * again.
 *
 * If there are multiple overlapping matches, the match occuring earlier in
 * `$haystack` takes precedence. If a replacer is a case-insensitive prefix of
 * another (like "Car" and "CARPET"), the longer one (carpet) takes precedence.
 * The ordering of `$replacements` therefore doesn't matter.
 *
 * When two replacers are passed that are identical except for case,
 * an InvalidArgumentException is thrown.
 *
 * Time complexity: O(a + length * b), where a is the sum of all key lengths and
 * b is the sum of distinct key lengths (length is the length of `$haystack`)
 *
 * - For having new values searched again, see `Str\replace_every_ci()`.
 */
function replace_every_nonrecursive_ci(
  string $haystack,
  KeyedContainer<string, string> $replacements,
)[rx]: string {
  return _Str\replace_every_nonrecursive_ci_l($haystack, dict($replacements));
}

/** Reverse a string by bytes.
 *
 * @see `Str\reverse_l()` to reverse by characters instead.
 */
function reverse(string $string)[]: string {
  for ($lo = 0, $hi = namespace\length($string) - 1; $lo < $hi; $lo++, $hi--) {
    $temp = $string[$lo];
    $string[$lo] = $string[$hi];
    $string[$hi] = $temp;
  }
  return $string;
}

/**
 * Return the string with a slice specified by the offset/length replaced by the
 * given replacement string.
 *
 * If the length is omitted or exceeds the upper bound of the string, the
 * remainder of the string will be replaced. If the length is zero, the
 * replacement will be inserted at the offset.
 *
 * Offset can be positive or negative. When positive, replacement starts from the
 * beginning of the string; when negative, replacement starts from the end of the string.
 *
 * Some examples:
 * - `Str\splice("apple", "orange", 0)` without `$length`, `$string` is replaced, resolving to `"orange"`
 * - `Str\splice("apple", "orange", 3)` inserting at `$offset` `3` from the start of `$string` resolves to `"apporange"`
 * - `Str\splice("apple", "orange", -2)` inserting at `$offset` `-2` from the end of `$string` resolves to `"apporange"`
 * - `Str\splice("apple", "orange", 0, 0)` with `$length` `0`, `$replacement` is appended at `$offset` `0` and resolves to `"orangeapple"`
 * - `Str\splice("apple", "orange", 5, 0)` with `$length` `0`, `$replacement` is appended at `$offset` `5` and resolves to `"appleorange"`
 *
 * Previously known in PHP as `substr_replace`.
 */
function splice(
  string $string,
  string $replacement,
  int $offset,
  ?int $length = null,
)[]: string {
  return _Str\splice_l($string, $replacement, $offset, $length);
}

/**
 * Returns the given string as an integer, or null if the string isn't numeric.
 */
function to_int(
  string $string,
)[]: ?int {
  if ((string)(int)$string === $string) {
    return (int)$string;
  }
  return null;
}

/**
 * Returns the string with all alphabetic characters converted to uppercase.
 */
function uppercase(
  string $string,
)[]: string {
  return _Str\uppercase_l($string);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/introspect.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\{_Private, _Private\_Str};

/**
 * Returns < 0 if `$string1` is less than `$string2`, > 0 if `$string1` is
 * greater than `$string2`, and 0 if they are equal.
 *
 * For a case-insensitive comparison, see `Str\compare_ci()`.
 */
function compare(
  string $string1,
  string $string2,
)[]: int {
  return _Str\strcoll_l($string1, $string2);
}

/**
 * Returns < 0 if `$string1` is less than `$string2`, > 0 if `$string1` is
 * greater than `$string2`, and 0 if they are equal (case-insensitive).
 *
 * For a case-sensitive comparison, see `Str\compare()`.
 */
function compare_ci(
  string $string1,
  string $string2,
)[]: int {
  return _Str\strcasecmp_l($string1, $string2);
}

/**
 * Returns whether the "haystack" string contains the "needle" string.
 *
 * An optional offset determines where in the haystack the search begins. If the
 * offset is negative, the search will begin that many characters from the end
 * of the string. If the offset is out-of-bounds, a ViolationException will be
 * thrown.
 *
 * - To get the position of the needle, see `Str\search()`.
 * - To search for the needle case-insensitively, see `Str\contains_ci()`.
 */
function contains(
  string $haystack,
  string $needle,
  int $offset = 0,
)[]: bool {
  if ($needle === '') {
    if ($offset === 0) {
      return true;
    }
    $length = length($haystack);
    if ($offset > $length || $offset < -$length) {
      throw new \InvalidArgumentException(
        format('Offset %d out of bounds for length %d', $offset, $length)
      );
    }
    return true;
  }
  return search($haystack, $needle, $offset) !== null;
}

/**
 * Returns whether the "haystack" string contains the "needle" string
 * (case-insensitive).
 *
 * An optional offset determines where in the haystack the search begins. If the
 * offset is negative, the search will begin that many characters from the end
 * of the string. If the offset is out-of-bounds, a ViolationException will be
 * thrown.
 *
 * - To search for the needle case-sensitively, see `Str\contains()`.
 * - To get the position of the needle case-insensitively, see `Str\search_ci()`.
 */
function contains_ci(
  string $haystack,
  string $needle,
  int $offset = 0,
)[]: bool {
  if ($needle === '') {
    if ($offset === 0) {
      return true;
    }
    $length = length($haystack);
    if ($offset > $length || $offset < -$length) {
      throw new \InvalidArgumentException(
        format('Offset %d out of bounds for length %d', $offset, $length)
      );
    }
    return true;
  }
  return search_ci($haystack, $needle, $offset) !== null;
}

/**
 * Returns whether the string ends with the given suffix.
 *
 * For a case-insensitive check, see `Str\ends_with_ci()`.
 */
function ends_with(
  string $string,
  string $suffix,
)[]: bool {
  return _Str\ends_with_l($string, $suffix);
}

/**
 * Returns whether the string ends with the given suffix (case-insensitive).
 *
 * For a case-sensitive check, see `Str\ends_with()`.
 */
function ends_with_ci(
  string $string,
  string $suffix,
)[]: bool {
  return _Str\ends_with_ci_l($string, $suffix);
}

/**
 * Returns `true` if `$string` is null or the empty string.
 * Returns `false` otherwise.
 */
function is_empty(
  ?string $string,
)[]: bool {
  return $string === null || $string === '';
}

/**
 * Returns the length of the given string, i.e. the number of bytes.
 *
 * This function is `O(1)`: it always returns the number of bytes in the string,
 * even if a byte is null. For example, `Str\length("foo\0bar")` is 7, not 3.
 *
 * @see `Str\length_l()` for the length in characters.
 */
function length(
  string $string,
)[]: int {
  return _Str\strlen_l($string);
}

/**
 * Returns the first position of the "needle" string in the "haystack" string,
 * or null if it isn't found.
 *
 * An optional offset determines where in the haystack the search begins. If the
 * offset is negative, the search will begin that many characters from the end
 * of the string. If the offset is out-of-bounds, a ViolationException will be
 * thrown.
 *
 * - To simply check if the haystack contains the needle, see `Str\contains()`.
 * - To get the case-insensitive position, see `Str\search_ci()`.
 * - To get the last position of the needle, see `Str\search_last()`.
 *
 * Previously known in PHP as `strpos`.
 */
function search(
  string $haystack,
  string $needle,
  int $offset = 0,
)[]: ?int {
  $position = _Str\strpos_l($haystack, $needle, $offset);
  if ($position < 0) {
    return null;
  }
  return $position;
}

/**
 * Returns the first position of the "needle" string in the "haystack" string,
 * or null if it isn't found (case-insensitive).
 *
 * An optional offset determines where in the haystack the search begins. If the
 * offset is negative, the search will begin that many characters from the end
 * of the string. If the offset is out-of-bounds, a ViolationException will be
 * thrown.
 *
 * - To simply check if the haystack contains the needle, see `Str\contains()`.
 * - To get the case-sensitive position, see `Str\search()`.
 * - To get the last position of the needle, see `Str\search_last()`.
 *
 * Previously known in PHP as `stripos`.
 */
function search_ci(
  string $haystack,
  string $needle,
  int $offset = 0,
)[]: ?int {
  $position = _Str\stripos_l($haystack, $needle, $offset);
  if ($position < 0) {
    return null;
  }
  return $position;
}

/**
 * Returns the last position of the "needle" string in the "haystack" string,
 * or null if it isn't found.
 *
 * An optional offset determines where in the haystack (from the beginning) the
 * search begins. If the offset is negative, the search will begin that many
 * characters from the end of the string and go backwards. If the offset is
 * out-of-bounds, a ViolationException will be thrown.
 *
 * - To simply check if the haystack contains the needle, see `Str\contains()`.
 * - To get the first position of the needle, see `Str\search()`.
 *
 * Previously known in PHP as `strrpos`.
 */
function search_last(
  string $haystack,
  string $needle,
  int $offset = 0,
)[]: ?int {
$haystack_length = length($haystack);
  $position = _Str\strrpos_l($haystack, $needle, $offset);
  if ($position < 0) {
    return null;
  }
  return $position;
}

/**
 * Returns whether the string starts with the given prefix.
 *
 * For a case-insensitive check, see `Str\starts_with_ci()`.
 */
function starts_with(
  string $string,
  string $prefix,
)[]: bool {
  return _Str\starts_with_l($string, $prefix);
}

/**
 * Returns whether the string starts with the given prefix (case-insensitive).
 *
 * For a case-sensitive check, see `Str\starts_with()`.
 */
function starts_with_ci(
  string $string,
  string $prefix,
)[]: bool {
  return _Str\starts_with_ci_l($string, $prefix);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/transform_l.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\{_Private, C, Keyset, Locale, Vec, _Private\_Str};

/**
 * Returns the string with the first character capitalized.
 *
 * If the first character is already capitalized or isn't alphabetic, the string
 * will be unchanged.
 *
 * Locale-specific capitalization rules will be respected, e.g. `i` -> `I` vs
 * `i` -> `İ`.
 *
 * - To capitalize all characters, see `Str\uppercase_l()`.
 * - To capitalize all words, see `Str\capitalize_words_l()`.
 */
function capitalize_l(
  Locale\Locale $locale,
  string $string,
)[]: string {
  if ($string === '') {
    return '';
  }
  return uppercase_l($locale, slice_l($locale, $string, 0, 1)).slice_l($locale, $string, 1);
}

/**
 * Returns the string with all words capitalized.
 *
 * Locale-specific capitalization rules will be respected, e.g. `i` -> `I` vs
 * `i` -> `İ`.
 *
 * Delimiters are defined by the locale.
 *
 * - To capitalize all characters, see `Str\uppercase_l()`.
 * - To capitalize only the first character, see `Str\capitalize_l()`.
 */
function capitalize_words_l(
  Locale\Locale $locale,
  string $string,
)[]: string {
  return _Str\titlecase_l($string, $locale);
}

/**
 * Returns the string with all alphabetic characters converted to lowercase.
 *
 * Locale-specific capitalization rules will be respected, e.g. `I` -> `i` vs
 * `I` -> `ı`
 */
function lowercase_l(
  Locale\Locale $locale,
  string $string,
)[]: string {
  return _Str\lowercase_l($string, $locale);
}

/**
 * Returns the string padded to the total length (in characters) by appending
 * the `$pad_string` to the left.
 *
 * If the length of the input string plus the pad string exceeds the total
 * length, the pad string will be truncated. If the total length is less than or
 * equal to the length of the input string, no padding will occur.
 *
 * To pad the string on the right, see `Str\pad_right_l()`.
 * To pad the string to a fixed number of bytes, see `Str\pad_left()`.
 */
function pad_left_l(
  Locale\Locale $locale,
  string $string,
  int $total_length,
  string $pad_string = ' ',
)[]: string {
  return _Str\pad_left_l($string, $total_length, $pad_string, $locale);
}

/**
 * Returns the string padded to the total length (in characters) by appending
 * the `$pad_string` to the right.
 *
 * If the length of the input string plus the pad string exceeds the total
 * length, the pad string will be truncated. If the total length is less than or
 * equal to the length of the input string, no padding will occur.
 *
 * To pad the string on the left, see `Str\pad_left()`.
 * To pad the string to a fixed number of bytes, see `Str\pad_right()`
 */
function pad_right_l(
  Locale\Locale $locale,
  string $string,
  int $total_length,
  string $pad_string = ' ',
)[]: string {
  return _Str\pad_right_l($string, $total_length, $pad_string, $locale);
}

/**
 * Returns the "haystack" string with all occurrences of `$needle` replaced by
 * `$replacement`.
 *
 * Strings will be normalized for comparison in encodings that support multiple
 * representations, such as UTF-8.
 *
 * - For a case-insensitive search/replace, see `Str\replace_ci_l()`.
 * - For multiple case-sensitive searches/replacements, see `Str\replace_every_l()`.
 * - For multiple case-insensitive searches/replacements, see `Str\replace_every_ci_l()`.
 */
function replace_l(
  Locale\Locale $locale,
  string $haystack,
  string $needle,
  string $replacement,
)[]: string {
  return _Str\replace_l($haystack, $needle, $replacement, $locale);
}

/**
 * Returns the "haystack" string with all occurrences of `$needle` replaced by
 * `$replacement` (case-insensitive).
 *
 * Locale-specific rules for case-insensitive comparisons will be used, and
 * strings will be normalized before comparing if the locale specifies an
 * encoding that supports multiple representations of the same characters, such
 * as UTF-8.
 *
 * - For a case-sensitive search/replace, see `Str\replace_l()`.
 * - For multiple case-sensitive searches/replacements, see `Str\replace_every_l()`.
 * - For multiple case-insensitive searches/replacements, see `Str\replace_every_ci_l()`.
 */
function replace_ci_l(
  Locale\Locale $locale,
  string $haystack,
  string $needle,
  string $replacement,
)[rx]: string {
  return _Str\replace_ci_l($haystack, $needle, $replacement, $locale);
}

/**
 * Returns the "haystack" string with all occurrences of the keys of
 * `$replacements` replaced by the corresponding values.
 *
 * Strings will be normalized for comparison in encodings that support multiple
 * representations, such as UTF-8.
 *
 * Replacements are applied in the order they are specified in `$replacements`,
 * and the new values are searched again for subsequent matches. For example,
 * `dict['a' => 'b', 'b' => 'c']` is equivalent to `dict['a' => 'c']`, but
 * `dict['b' => 'c', 'a' => 'b']` is not, despite having the same elements.
 *
 * If there are multiple overlapping matches, the match occuring earlier in
 * `$replacements` (not in `$haystack`) takes precedence.
 *
 * - For a single case-sensitive search/replace, see `Str\replace_l()`.
 * - For a single case-insensitive search/replace, see `Str\replace_ci_l()`.
 * - For multiple case-insensitive searches/replacements, see `Str\replace_every_ci_l()`.
 * - For not having new values searched again, see `Str\replace_every_nonrecursive_l()`.
 */
function replace_every_l(
  Locale\Locale $locale,
  string $haystack,
  KeyedContainer<string, string> $replacements,
)[]: string {
  return _Str\replace_every_l($haystack, dict($replacements), $locale);
}

/**
 * Returns the "haystack" string with all occurrences of the keys of
 * `$replacements` replaced by the corresponding values (case-insensitive).
 *
 * Locale-specific rules for case-insensitive comparisons will be used, and
 * strings will be normalized before comparing if the locale specifies an
 * encoding that supports multiple representations of the same characters, such
 * as UTF-8.
 *
 * Replacements are applied in the order they are specified in `$replacements`,
 * and the new values are searched again for subsequent matches. For example,
 * `dict['a' => 'b', 'b' => 'c']` is equivalent to `dict['a' => 'c']`, but
 * `dict['b' => 'c', 'a' => 'b']` is not, despite having the same elements.
 *
 * If there are multiple overlapping matches, the match occuring earlier in
 * `$replacements` (not in `$haystack`) takes precedence.
 *
 * - For a single case-sensitive search/replace, see `Str\replace_l()`.
 * - For a single case-insensitive search/replace, see `Str\replace_ci_l()`.
 * - For multiple case-sensitive searches/replacements, see `Str\replace_every_l()`.
 * - For not having new values searched again, see `Str\replace_every_nonrecursive_ci_l()`.
 */
function replace_every_ci_l(
  Locale\Locale $locale,
  string $haystack,
  KeyedContainer<string, string> $replacements,
)[rx]: string {
  return _Str\replace_every_ci_l($haystack, dict($replacements), $locale);
}

/**
 * Returns the "haystack" string with all occurrences of the keys of
 * `$replacements` replaced by the corresponding values. Once a substring has
 * been replaced, its new value will not be searched again.
 *
 * Strings will be normalized for comparison in encodings that support multiple
 * representations, such as UTF-8.
 *
 * If there are multiple overlapping matches, the match occuring earlier in
 * `$haystack` takes precedence. If a replacer is a prefix of another (like
 * "car" and "carpet"), the longer one (carpet) takes precedence. The ordering
 * of `$replacements` therefore doesn't matter.
 *
 * - For having new values searched again, see `Str\replace_every_l()`.
 */
function replace_every_nonrecursive_l(
  Locale\Locale $locale,
  string $haystack,
  KeyedContainer<string, string> $replacements,
)[rx]: string {
  return _Str\replace_every_nonrecursive_l($haystack, dict($replacements), $locale);
}

/**
 * Returns the "haystack" string with all occurrences of the keys of
 * `$replacements` replaced by the corresponding values (case-insensitive).
 * Once a substring has been replaced, its new value will not be searched
 * again.
 *
 * Locale-specific rules for case-insensitive comparisons will be used, and
 * strings will be normalized before comparing if the locale specifies an
 * encoding that supports multiple representations of the same characters, such
 * as UTF-8.
 *
 * If there are multiple overlapping matches, the match occuring earlier in
 * `$haystack` takes precedence. If a replacer is a case-insensitive prefix of
 * another (like "Car" and "CARPET"), the longer one (carpet) takes precedence.
 * The ordering of `$replacements` therefore doesn't matter.
 *
 * When two replacers are passed that are identical except for case,
 * an InvalidArgumentException is thrown.
 *
 * Time complexity: O(a + length * b), where a is the sum of all key lengths and
 * b is the sum of distinct key lengths (length is the length of `$haystack`)
 *
 * - For having new values searched again, see `Str\replace_every_ci_l()`.
 */
function replace_every_nonrecursive_ci_l(
  Locale\Locale $locale,
  string $haystack,
  KeyedContainer<string, string> $replacements,
)[rx]: string {
  return _Str\replace_every_nonrecursive_ci_l($haystack, dict($replacements), $locale);
}

/** Reverse a string by characters.
 *
 * @see `Str\reverse()` to reverse by bytes instead.
 */
function reverse_l(Locale\Locale $locale, string $string)[]: string {
  return _Str\reverse_l($string, $locale);
}

/**
 * Return the string with a slice specified by the offset/length replaced by the
 * given replacement string.
 *
 * If the length is omitted or exceeds the upper bound of the string, the
 * remainder of the string will be replaced. If the length is zero, the
 * replacement will be inserted at the offset.
 *
 *
 * Offset can be positive or negative. When positive, replacement starts from the
 * beginning of the string; when negative, replacement starts from the end of the string.
 *
 * Some examples:
 * - `Str\splice_l($l, "apple", "orange", 0)` without `$length`, `$string` is replaced, resolving to `"orange"`
 * - `Str\splice_l($l, "apple", "orange", 3)` inserting at `$offset` `3` from the start of `$string` resolves to `"apporange"`
 * - `Str\splice_l($l, "apple", "orange", -2)` inserting at `$offset` `-2` from the end of `$string` resolves to `"apporange"`
 * - `Str\splice_l($l, "apple", "orange", 0, 0)` with `$length` `0`, `$replacement` is appended at `$offset` `0` and resolves to `"orangeapple"`
 * - `Str\splice_l($l, "apple", "orange", 5, 0)` with `$length` `0`, `$replacement` is appended at `$offset` `5` and resolves to `"appleorange"`
 *
 */
function splice_l(
  Locale\Locale $locale,
  string $string,
  string $replacement,
  int $offset,
  ?int $length = null,
)[]: string {
  return _Str\splice_l($string, $replacement, $offset, $length, $locale);
}

/**
 * Returns the string with all alphabetic characters converted to uppercase.
 *
 * Locale-specific capitalization rules will be respected, e.g. `i` -> `I` vs
 * `i` -> `İ`.
 */
function uppercase_l(
  Locale\Locale $locale,
  string $string,
)[]: string {
  return _Str\uppercase_l($string, $locale);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/select_l.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\{Locale, _Private, _Private\_Str};

/**
 * Returns a substring of length `$length` of the given string starting at the
 * `$offset`.
 *
 * `$offset` and `$length` are specified as a number of characters.
 *
 * If no length is given, the slice will contain the rest of the
 * string. If the length is zero, the empty string will be returned. If the
 * offset is out-of-bounds, an InvalidArgumentException will be thrown.
 *
 * See `slice()` for a byte-based operation.
 */
function slice_l(
  Locale\Locale $locale,
  string $string,
  int $offset,
  ?int $length = null,
)[]: string {
  return _Str\slice_l($string, $offset, $length ?? \PHP_INT_MAX, $locale);
}

/**
 * Returns the string with the given prefix removed, or the string itself if
 * it doesn't start with the prefix.
 *
 * Strings will be normalized for comparison in encodings that support multiple
 * representations, such as UTF-8.
 */
function strip_prefix_l(
  Locale\Locale $locale,
  string $string,
  string $prefix,
)[]: string {
  return _Str\strip_prefix_l($string, $prefix, $locale);
}

/**
 * Returns the string with the given suffix removed, or the string itself if
 * it doesn't end with the suffix.
 *
 * Strings will be normalized for comparison in encodings that support multiple
 * representations, such as UTF-8.
 */
function strip_suffix_l(
  Locale\Locale $locale,
  string $string,
  string $suffix,
)[]: string {
  return _Str\strip_suffix_l($string, $suffix, $locale);
}

/**
 * Returns the given string with whitespace stripped from the beginning and end.
 *
 * If the optional character mask isn't provided, the characters removed are
 * defined by the locale/encoding.
 *
 * - To only strip from the left, see `Str\trim_left_l()`.
 * - To only strip from the right, see `Str\trim_right_l()`.
 */
function trim_l(
  Locale\Locale $locale,
  string $string,
  ?string $char_mask = null,
)[]: string {
  return _Str\trim_l($string, $char_mask, $locale);
}

/**
 * Returns the given string with whitespace stripped from the left.
 * See `Str\trim_l()` for more details.
 *
 * - To strip from both ends, see `Str\trim_l()`.
 * - To only strip from the right, see `Str\trim_right_l()`.
 * - To strip a specific prefix (instead of all characters matching a mask),
 *   see `Str\strip_prefix_l()`.
 */
function trim_left_l(
  Locale\Locale $locale,
  string $string,
  ?string $char_mask = null,
)[]: string {
  return _Str\trim_left_l($string, $char_mask, $locale);
}

/**
 * Returns the given string with whitespace stripped from the right.
 * See `Str\trim_l` for more details.
 *
 * - To strip from both ends, see `Str\trim_l()`.
 * - To only strip from the left, see `Str\trim_left_l()`.
 * - To strip a specific suffix (instead of all characters matching a mask),
 *   see `Str\strip_suffix_l()`.
 */
function trim_right_l(
  Locale\Locale $locale,
  string $string,
  ?string $char_mask = null,
)[]: string {
  return _Str\trim_right_l($string, $char_mask, $locale);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/str/format_l.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Str {

use namespace HH\Lib\Locale;
use namespace HH\Lib\_Private\_Str;

/**
 * Given a valid format string (defined by `SprintfFormatString`), return a
 * formatted string using `$format_args`
 */
function format_l(
  Locale\Locale $locale,
  SprintfFormatString $format_string,
  mixed ...$format_args
)[]: string {
  return _Str\vsprintf_l($locale, $format_string as string, $format_args);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/unix/CloseableSocket.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Unix {

use namespace HH\Lib\Network;
use namespace HH\Lib\_Private\_Unix;

<<__Sealed(_Unix\CloseableSocket::class)>>
interface CloseableSocket extends Socket, Network\CloseableSocket {
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/unix/ConnectOptions.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Unix {

type ConnectOptions = shape(
  ?'timeout_ns' => int,
);
}
///// /home/ubuntu/hhvm/hphp/hsl/src/unix/connect.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Unix {

use namespace HH\Lib\{Network, OS};
use namespace HH\Lib\_Private\{_Network, _Unix};

/** Asynchronously connect to the specified unix socket. */
async function connect_async(
  string $path,
  ConnectOptions $opts = shape(),
): Awaitable<CloseableSocket> {
  $timeout_ns = $opts['timeout_ns'] ?? 0;
  $sock = OS\socket(OS\SocketDomain::PF_UNIX, OS\SocketType::SOCK_STREAM, 0);
  await _Network\socket_connect_async(
    $sock,
    new OS\sockaddr_un($path),
    $timeout_ns,
  );
  return new _Unix\CloseableSocket($sock);
}

<<__Deprecated('use connect_async() instead')>>
async function connect_nd_async(
  string $path,
  ConnectOptions $opts,
): Awaitable<CloseableSocket> {
  return await connect_async($path, $opts);

}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/unix/_Private/CloseableSocket.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_Unix {

use namespace HH\Lib\{IO, Network, OS, Unix};
use namespace HH\Lib\_Private\{_IO, _Network};

final class CloseableSocket
  extends _IO\FileDescriptorHandle
  implements Unix\CloseableSocket, IO\CloseableReadWriteHandle {
  use _IO\FileDescriptorReadHandleTrait;
  use _IO\FileDescriptorWriteHandleTrait;

  public function __construct(OS\FileDescriptor $impl) {
    parent::__construct($impl);
  }

  public function getLocalAddress(): ?string {
    return (OS\getsockname($this->impl) as OS\sockaddr_un)->getPath();
  }

  public function getPeerAddress(): ?string {
    return (OS\getpeername($this->impl) as OS\sockaddr_un)->getPath();
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/unix/Server.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Unix {

use namespace HH\Lib\{Network, OS};
use namespace HH\Lib\_Private\{_Network, _Unix};

final class Server implements Network\Server<CloseableSocket> {
  /** Path */
  const type TAddress = string;

  private function __construct(private OS\FileDescriptor $impl) {
  }

  /** Create a bound and listening instance */
  public static async function createAsync(string $path): Awaitable<this> {
    return await _Network\socket_create_bind_listen_async(
      OS\SocketDomain::PF_UNIX,
      OS\SocketType::SOCK_STREAM,
      /* proto = */ 0,
      new OS\sockaddr_un($path),
      /* backlog = */ 16,
      /* socket options = */ shape(),
    )
      |> new self($$);
  }

  public async function nextConnectionAsync(): Awaitable<CloseableSocket> {
    return await _Network\socket_accept_async($this->impl)
      |> new _Unix\CloseableSocket($$);
  }

  public function getLocalAddress(): string {
    return (OS\getsockname($this->impl) as OS\sockaddr_un)->getPath()
      as nonnull;
  }

  public function stopListening(): void {
    OS\close($this->impl);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/unix/Socket.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Unix {

use namespace HH\Lib\{IO, Network};

/** A Unix socket for a server or client connection.
 *
 * @see `Unix\Server` to accept new connections
 * @see `Unix\connect_async()` to connect to an existing server
 */
<<__Sealed(CloseableSocket::class)>>
interface Socket extends Network\Socket {
  /** An identifier; usually a file path, but this isn't guaranteed. */
  const type TAddress = ?string;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/CloseableHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

/**
 * A non-disposable handle that is explicitly closeable.
 *
 * Some handles, such as those returned by `IO\server_error()` may
 * be neither disposable nor closeable.
 */
interface CloseableHandle extends Handle {
  /** Close the handle */
  public function close(): void;

  /** Close the handle when the returned disposable is disposed.
   *
   * Usage: `using $handle->closeWhenDisposed();`
   */
  <<__ReturnDisposable>>
  public function closeWhenDisposed(): \IDisposable;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/pipe.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

use namespace HH\Lib\{_Private\_IO, OS};

/** Create a pair of handles, where writes to the `WriteHandle` can be
 * read from the `ReadHandle`.
 *
 * @see `Network\Socket`
 */
function pipe(): (CloseableReadFDHandle, CloseableWriteFDHandle) {
  list($r, $w) = \HH\Lib\OS\pipe();
  return tuple(
    new _IO\PipeReadHandle($r),
    new _IO\PipeWriteHandle($w),
  );
}


<<__Deprecated("use pipe() instead")>>
function pipe_nd(): (CloseableReadFDHandle, CloseableWriteFDHandle) {
  return pipe();
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/SeekableHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

/** A handle that can have its' position changed. */
interface SeekableHandle extends Handle {
  /**
   * Move to a specific offset within a handle.
   *
   * Offset is relative to the start of the handle - so, the beginning of the
   * handle is always offset 0.
   */
  public function seek(int $offset): void;

  /**
   * Get the current pointer position within a handle.
   */
  public function tell(): int;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/FDHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

use namespace HH\Lib\OS;

interface FDHandle extends Handle {
  public function getFileDescriptor(): OS\FileDescriptor;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/WriteHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

use namespace HH\Lib\Fileystem;
use namespace HH\Lib\_Private;

/** An interface for a writable Handle.
 *
 * Order of operations is guaranteed, *except* for `writeImplBlocking`;
 * `writeImplBlocking()` will immediately try to write to the handle.
 */
interface WriteHandle extends Handle {
  /** An immediate unordered write.
   *
   * @see `writeAllAsync()`
   * @see `writeAllowPartialSuccessAsync()`
   * @throws `OS\BlockingIOException` if the handle is a socket or similar,
   *   and the write would block.
   * @returns the number of bytes written on success, which may be 0
   */
  protected function writeImpl(string $bytes): int;

  /** Write data, waiting if necessary.
   *
   * A wrapper around `write()` that will wait if `write()` would throw
   * an `OS\BlockingIOException`
   *
   * It is possible for the write to *partially* succeed - check the return
   * value and call again if needed.
   *
   * @returns the number of bytes written, which may be less than the length of
   *   input string.
   */
  public function writeAllowPartialSuccessAsync(
    string $bytes,
    ?int $timeout_ns = null,
  ): Awaitable<int>;

  /** Write all of the requested data.
   *
   * A wrapper aroudn `writeAsync()` that will:
   * - do multiple writes if necessary to write the entire provided buffer
   * - fail with EPIPE if it is not possible to write all the requested data
   *
   * It is possible for this to never return, e.g. if called on a pipe or
   * or socket which the other end keeps open forever. Set a timeout if you
   * do not want this to happen.
   */
  public function writeAllAsync(
    string $bytes,
    ?int $timeout_ns = null,
  ): Awaitable<void>;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/ReadHandleConvenienceMethodsTrait.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

use namespace HH\Lib\{Math, Str, OS};
use namespace HH\Lib\_Private\{_IO, _OS};

/** Trait implementing `ReadHandle` methods that can be implemented in terms
 * of more basic methods.
 */
trait ReadHandleConvenienceMethodsTrait {
  require implements ReadHandle;

  public async function readAllAsync(
    ?int $max_bytes = null,
    ?int $timeout_ns = null,
  ): Awaitable<string> {
    _OS\arg_assert(
      $max_bytes is null || $max_bytes > 0,
      'Max bytes must be null, or > 0',
    );
    _OS\arg_assert(
      $timeout_ns is null || $timeout_ns > 0,
      'Timeout must be null, or > 0',
    );

    $to_read = $max_bytes ?? Math\INT64_MAX;

    $data = '';
    $timer = new \HH\Lib\_Private\OptionalIncrementalTimeout(
      $timeout_ns,
      () ==> {
        _OS\throw_errno(
          OS\Errno::ETIMEDOUT,
          "Reached timeout before %s data could be read.",
          $data === '' ? 'any' : 'all',
        );
      },
    );

    do {
      $chunk_size = Math\minva($to_read, _IO\DEFAULT_READ_BUFFER_SIZE);
      /* @lint-ignore AWAIT_IN_LOOP */
      $chunk = await $this->readAllowPartialSuccessAsync(
        $chunk_size,
        $timer->getRemainingNS(),
      );
      $data .= $chunk;
      $to_read -= Str\length($chunk);
    } while ($to_read > 0 && $chunk !== '');
    return $data;
  }

  public async function readFixedSizeAsync(
    int $size,
    ?int $timeout_ns = null,
  ): Awaitable<string> {
    $data = await $this->readAllAsync($size);
    if (Str\length($data) !== $size) {
      _OS\throw_errno(
        OS\Errno::EPIPE,
        "%d bytes were requested, but only able to read %d bytes",
        $size,
        Str\length($data),
      );
    }
    return $data;
  }

}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/WriteHandleConvenienceMethodsTrait.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

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
  ): Awaitable<void> {
    if ($data === '') {
      return;
    }

    _OS\arg_assert(
      $timeout_ns is null || $timeout_ns > 0,
      'Timeout must be null, or > 0',
    );

    $original_size = Str\length($data);

    $timer = new \HH\Lib\_Private\OptionalIncrementalTimeout(
      $timeout_ns,
      () ==> {
        _OS\throw_errno(
          OS\Errno::ETIMEDOUT,
          "Reached timeout before %s data could be read.",
          $data === '' ? 'any' : 'all',
        );
      },
    );

    do {
      /* @lint-ignore AWAIT_IN_LOOP */
      $written = await $this->writeAllowPartialSuccessAsync(
        $data,
        $timer->getRemainingNS(),
      );
      $data = Str\slice($data, $written);
    } while ($written !== 0 && $data !== '');

    if ($data !== '') {
      _OS\throw_errno(
        OS\Errno::EPIPE,
        "asked to write %d bytes, but only able to write %d bytes",
        $original_size,
        $original_size - Str\length($data),
      );
    }
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/BufferedReader.php /////
/*
 *  Copyright (c) 2017-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

/* @lint-ignore-every AWAIT_IN_LOOP */

namespace HH\Lib\IO {

use namespace HH\Lib\{IO, Math, OS, Str};
use namespace HH\Lib\_Private\_OS;

/** Wrapper for `ReadHandle`s, with buffered line-based byte-based accessors.
 *
 * - `readLineAsync()` is similar to `fgets()`
 * - `readUntilAsync()` is a more general form
 * - `readByteAsync()` is similar to `fgetc()`
 */
final class BufferedReader implements IO\ReadHandle {
  use ReadHandleConvenienceMethodsTrait;

  public function __construct(private IO\ReadHandle $handle) {
  }

  public function getHandle(): IO\ReadHandle {
    return $this->handle;
  }

  private bool $eof = false;
  private string $buffer = '';

  // implementing interface
  public function readImpl(?int $max_bytes = null): string {
    _OS\arg_assert(
      $max_bytes is null || $max_bytes > 0,
      "Max bytes must be null, or greater than 0",
    );

    if ($this->eof) {
      return '';
    }
    if ($this->buffer === '') {
      $this->buffer = $this->getHandle()->readImpl();
      if ($this->buffer === '') {
        $this->eof = true;
        return '';
      }
    }

    if ($max_bytes is null || $max_bytes >= Str\length($this->buffer)) {
      $buf = $this->buffer;
      $this->buffer = '';
      return $buf;
    }
    $buf = $this->buffer;
    $this->buffer = Str\slice($buf, $max_bytes);
    return Str\slice($buf, 0, $max_bytes);
  }

  public async function readAllowPartialSuccessAsync(
    ?int $max_bytes = null,
    ?int $timeout_ns = null,
  ): Awaitable<string> {
    _OS\arg_assert(
      $max_bytes is null || $max_bytes > 0,
      "Max bytes must be null, or greater than 0",
    );
    _OS\arg_assert(
      $timeout_ns is null || $timeout_ns > 0,
      "Timeout must be null, or greater than 0",
    );

    if ($this->eof) {
      return '';
    }
    if ($this->buffer === '') {
      await $this->fillBufferAsync(null, $timeout_ns);
    }

    // We either have a buffer, or reached EOF; either way, behavior matches
    // read, so just delegate
    return $this->readImpl($max_bytes);
  }

  /** Read until the specified suffix is seen.
   *
   * The trailing suffix is read (so won't be returned by other calls), but is not
   * included in the return value.
   *
   * This call returns null if the suffix is not seen, even if there is other
   * data.
   *
   * @see `readUntilxAsync()` if you want to throw EPIPE instead of returning null
   * @see `linesIterator()` if you want to iterate over all lines
   * @see `readLineAsync()` if you want trailing data instead of null
   */
  public async function readUntilAsync(string $suffix): Awaitable<?string> {
    $buf = $this->buffer;
    $idx = Str\search($buf, $suffix);
    $suffix_len = Str\length($suffix);
    if ($idx !== null) {
      $this->buffer = Str\slice($buf, $idx + $suffix_len);
      return Str\slice($buf, 0, $idx);
    }

    do {
      // + 1 as it would have been matched in the previous iteration if it
      // fully fit in the chunk
      $offset = Math\maxva(0, Str\length($buf) - $suffix_len + 1);
      $chunk = await $this->handle->readAllowPartialSuccessAsync();
      if ($chunk === '') {
        $this->buffer = $buf;
        return null;
      }
      $buf .= $chunk;
      $idx = Str\search($buf, $suffix, $offset);
    } while ($idx === null);

    $this->buffer = Str\slice($buf, $idx + $suffix_len);
    return Str\slice($buf, 0, $idx);
  }

  /** Read until the suffix, or raise EPIPE if the separator is not seen.
   *
   * This is similar to `readUntilAsync()`, however it raises EPIPE instead
   * of returning null.
   */
  public async function readUntilxAsync(string $suffix): Awaitable<string> {
    $ret = await $this->readUntilAsync($suffix);
    if ($ret === null) {
      throw new OS\BrokenPipeException(
        OS\Errno::EPIPE,
        'Marker/suffix not found before end of file',
      );
    }
    return $ret;
  }

  /** Read until the platform end-of-line sequence is seen, or EOF is reached.
   *
   * On current platforms, this is always `\n`; it may have other values on other
   * platforms in the future, e.g. `\r\n`.
   *
   * The newline sequence is read (so won't be returned by other calls), but is not
   * included in the return value.
   *
   * - Returns null if the end of file is reached with no data.
   * - Returns a string otherwise
   *
   * Some illustrative edge cases:
   * - `''` is considered a 0-line input
   * - `'foo'` is considered a 1-line input
   * - `"foo\nbar"` is considered a 2-line input
   * - `"foo\nbar\n"` is also considered a 2-line input
   *
   * @see `linesIterator()` for an iterator
   * @see `readLinexAsync()` to throw EPIPE instead of returning null
   * @see `readUntilAsync()` for a more general form
   */
  public async function readLineAsync(): Awaitable<?string> {
    try {
      $line = await $this->readUntilAsync("\n");
    } catch (OS\ErrnoException $ex) {
      if ($ex->getErrno() === OS\Errno::EBADF) {
        // Eg foreach ($stdin->linesIterator()) when stdin is closed
        return null;
      }
      throw $ex;
    }

    if ($line !== null) {
      return $line;
    }

    $line = await $this->readAllAsync();
    return $line === '' ? null : $line;
  }

  /** Read a line or throw EPIPE.
   *
   * @see `readLineAsync()` for details.
   */
  public async function readLinexAsync(): Awaitable<string> {
    $line = await $this->readLineAsync();
    if ($line !== null) {
      return $line;
    }
    throw new OS\BrokenPipeException(OS\Errno::EPIPE, 'No more lines to read.');
  }

  /** Iterate over all lines in the file.
   *
   * Usage:
   *
   * ```
   * foreach ($reader->linesIterator() await as $line) {
   *   do_stuff($line);
   * }
   * ```
   */
  public function linesIterator(): AsyncIterator<string> {
    return new BufferedReaderLineIterator($this);
  }

  <<__Override>> // from trait
  public async function readFixedSizeAsync(
    int $size,
    ?int $timeout_ns = null,
  ): Awaitable<string> {
    $timer = new \HH\Lib\_Private\OptionalIncrementalTimeout(
      $timeout_ns,
      () ==> {
        _OS\throw_errno(
          OS\Errno::ETIMEDOUT,
          "Reached timeout before reading requested amount of data",
        );
      },
    );
    while (Str\length($this->buffer) < $size && !$this->eof) {
      await $this->fillBufferAsync(
        $size - Str\length($this->buffer),
        $timer->getRemainingNS(),
      );
    }
    if ($this->eof) {
      throw new OS\BrokenPipeException(
        OS\Errno::EPIPE,
        'Reached end of file before requested size',
      );
    }
    $buffer_size = Str\length($this->buffer);
    invariant(
      $buffer_size >= $size,
      "Should have read the requested data or reached EOF",
    );
    if ($size === $buffer_size) {
      $ret = $this->buffer;
      $this->buffer = '';
      return $ret;
    }
    $ret = Str\slice($this->buffer, 0, $size);
    $this->buffer = Str\slice($this->buffer, $size);
    return $ret;
  }

  /** Read a single byte from the handle.
   *
   * Fails with EPIPE if the handle is closed or otherwise unreadable.
   */
  public async function readByteAsync(
    ?int $timeout_ns = null,
  ): Awaitable<string> {
    _OS\arg_assert(
      $timeout_ns is null || $timeout_ns > 0,
      "Timeout must be null, or greater than 0",
    );
    if ($this->buffer === '' && !$this->eof) {
      await $this->fillBufferAsync(null, $timeout_ns);
    }
    if ($this->buffer === '') {
      _OS\throw_errno(OS\Errno::EPIPE, "Reached EOF without any more data");
    }
    $ret = $this->buffer[0];
    if ($ret === $this->buffer) {
      $this->buffer = '';
      return $ret;
    }
    $this->buffer = Str\slice($this->buffer, 1);
    return $ret;
  }

  /** If we are known to have reached the end of the file.
   *
   * This function is best-effort: `true` is reliable, but `false` is more of
   * 'maybe'. For example, if called on an open socket with no data available,
   * it will return `false`; it is then possible that a future read will:
   * - return data if the other send sends some more
   * - block forever, or until timeout if set
   * - return the empty string if the socket closes the connection
   *
   * Additionally, helpers such as `readUntil` may fail with `EPIPE`.
   */
  public function isEndOfFile(): bool {
    if ($this->eof) {
      return true;
    }
    if ($this->buffer !== '') {
      return false;
    }

    // attempt to make `while (!$handle->isEOF()) {` safe on a closed file
    // handle, e.g. STDIN; if we just return `$this->eof`, the caller loop
    // body must check for EPIPE and EBADF which is unexpected.
    try {
      // Calling the non-async (but still non-blocking) version as the async
      // version could wait for the other end to send data - which could lead
      // to both ends of a pipe/socket waiting on each other.
      $this->buffer = $this->handle->readImpl();
      if ($this->buffer === '') {
        $this->eof = true;
        return true;
      }
    } catch (OS\BlockingIOException $_EWOULDBLOCK) {
      return false;
    } catch (OS\ErrnoException $ex) {
      if ($ex->getErrno() === OS\Errno::EBADF) {
        $this->eof = true;
        return true;
      }
      // ignore; they'll hit it again when they try a real read
    }
    return false;
  }

  private async function fillBufferAsync(
    ?int $desired_bytes,
    ?int $timeout_ns,
  ): Awaitable<void> {
    $chunk = await $this->getHandle()
      ->readAllowPartialSuccessAsync($desired_bytes, $timeout_ns);
    if ($chunk === '') {
      $this->eof = true;
    }
    $this->buffer .= $chunk;
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/Handle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

use namespace HH\Lib\{File, Network};

/** An interface for an IO stream.
 *
 * For example, an IO handle might be attached to a file, a network socket, or
 * just an in-memory buffer.
 *
 * HSL IO handles can be thought of as having a combination of behaviors - some
 * of which are mutually exclusive - which are reflected in more-specific
 * interfaces; for example:
 * - Closeable
 * - Seekable
 * - Readable
 * - Writable
 *
 * These can be combined to arbitrary interfaces; for example, if you are
 * writing a function that writes some data, you may want to take a
 * `IO\WriteHandle` - or, if you read, write, and seek,
 * `IO\SeekableReadWriteHandle`; only specify `Closeable` if
 * your code requires that the close method is defined.
 *
 * Some types of handle imply these behaviors; for example, all `File\Handle`s
 * are `IO\SeekableHandle`s.
 *
 * You probably want to start with one of:
 * - `File\open_read_only()`, `File\open_write_only()`, or
 *   `File\open_read_write()`
 * - `IO\pipe()`
 * - `IO\request_input()`, `IO\request_output()`, or `IO\request_error()`; these
 *   used for all kinds of requests, including both HTTP and CLI requests.
 * - `IO\server_output()`, `IO\server_error()`
 * - `TCP\connect_async()` or `TCP\Server`
 * - `Unix\connect_async()`, or `Unix\Server`
 */
interface Handle {
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/MemoryHandle.php /////
/*
 *  Copyright (c) 2017-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

use namespace HH\Lib\{Math, OS, Str};
use namespace HH\Lib\_Private\{_IO, _OS};

enum MemoryHandleWriteMode: int {
  OVERWRITE = 0;
  APPEND = OS\O_APPEND;
}

/** Read from/write to an in-memory buffer.
 *
 * This class is intended for use in unit tests.
 *
 * @see `IO\pipe()` for more complicated tests
 */
final class MemoryHandle implements CloseableSeekableReadWriteHandle {
  use ReadHandleConvenienceMethodsTrait;
  use WriteHandleConvenienceMethodsTrait;

  private int $offset = 0;
  private bool $open = true;

  public function __construct(
    private string $buffer = '',
    private MemoryHandleWriteMode $writeMode = MemoryHandleWriteMode::OVERWRITE,
  ) {
  }

  public function close(): void {
    $this->open = false;
    $this->offset = -1;
  }

  <<__ReturnDisposable>>
  public function closeWhenDisposed(): \IDisposable {
    return new _IO\CloseWhenDisposed($this);
  }

  public async function readAllowPartialSuccessAsync(
    ?int $max_bytes = null,
    ?int $_timeout_nanos = null,
  ): Awaitable<string> {
    return $this->readImpl($max_bytes);
  }

  public function readImpl(?int $max_bytes = null): string {
    $this->checkIsOpen();

    $max_bytes ??= Math\INT64_MAX;
    _OS\arg_assert($max_bytes > 0, '$max_bytes must be null or positive');
    $len = Str\length($this->buffer);
    if ($this->offset >= $len) {
      return '';
    }
    $to_read = Math\minva($max_bytes, $len - $this->offset);

    $ret = Str\slice($this->buffer, $this->offset, $to_read);
    $this->offset += $to_read;
    return $ret;
  }

  public function seek(int $pos): void {
    $this->checkIsOpen();

    _OS\arg_assert($pos >= 0, "Position must be >= 0");
    // Past end of file is explicitly fine
    $this->offset = $pos;
  }

  public function tell(): int {
    $this->checkIsOpen();
    return $this->offset;
  }

  protected function writeImpl(string $data): int {
    $this->checkIsOpen();
    $length = Str\length($this->buffer);
    if ($length < $this->offset) {
      $this->buffer .= Str\repeat("\0", $this->offset - $length);
      $length = $this->offset;
    }

    if ($this->writeMode === MemoryHandleWriteMode::APPEND) {
      $this->buffer .= $data;
      $this->offset = Str\length($this->buffer);
      return Str\length($data);
    }

    _OS\arg_assert(
      $this->writeMode === MemoryHandleWriteMode::OVERWRITE,
      "Write mode must be OVERWRITE or APPEND",
    );

    $data_length = Str\length($data);
    $new = Str\slice($this->buffer, 0, $this->offset).$data;
    if ($this->offset < $length) {
      $new .= Str\slice(
        $this->buffer,
        Math\minva($this->offset + $data_length, $length),
      );
    }
    $this->buffer = $new;
    $this->offset += $data_length;
    return $data_length;
  }

  public async function writeAllowPartialSuccessAsync(
    string $data,
    ?int $timeout_nanos = null,
  ): Awaitable<int> {
    return $this->writeImpl($data);
  }

  public function getBuffer(): string {
    return $this->buffer;
  }

  /** Set the internal buffer and reset position to the beginning of the file.
   *
   * If you wish to preserve the position, use `tell()` and `seek()`,
   * or `appendToBuffer()`.
   */
  public function reset(string $data = ''): void {
    $this->open = true;
    $this->buffer = $data;
    $this->offset = 0;
  }

  /** Append data to the internal buffer, preserving position.
   *
   * @see `write()` if you want the offset to be changed.
   */
  public function appendToBuffer(string $data): void {
    $this->checkIsOpen();
    $this->buffer .= $data;
  }

  private function checkIsOpen(): void {
    if (!$this->open) {
      _OS\throw_errno(
        OS\Errno::EBADF,
        "%s::close() was already called",
        self::class,
      );
    }
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/intersection_interfaces.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {
  use namespace HH\Lib\{C, Dict, Str, Vec};

  <<__EntryPoint>>
  function generate_intersection_interfaces(): void {
    // Map these to powers of two, so we can later use a bitmask
    $bases = vec[
      'Closeable',
      'Seekable',
      'Read',
      'Write',
      'FD',
    ]
      |> Dict\flip($$)
      |> Dict\map($$, $vec_idx ==> 2 ** $vec_idx as int);

    for ($i = 3; $i < (2 ** C\count($bases)); $i++) {
      // $i is a bitmask that represents:
      // - the current interface
      // - the parents: for each set bit, turn it off. That's a parent.
      //
      // For example, the parents of 111 are 011, 101, and 110.
      //
      // If we have ^0*10*$, we have a direct child of 'Handle', not an
      // intersection (a.k.a. composite/intermediate) interface.
      if (Str\trim((string)$i, '0') === '1') {
        continue;
      }
      $active = Dict\filter($bases, $bit ==> ($i & $bit) === $bit);
      $parents = Dict\map(
        $active,
        $this_bit ==> Dict\filter($active, $bit ==> $bit !== $this_bit)
          |> Vec\keys($$)
          |> Str\join($$, '').'Handle',
      );
      if (C\count($parents) === 1) {
        continue;
      }
      \printf(
        "interface %sHandle extends %s {}\n",
        Str\join(Vec\keys($active), ''),
        Str\join($parents, ', '),
      );
    }
  }

}

namespace HH\Lib\IO {

  // Generated with the above function, then `hackfmt`

  interface CloseableSeekableHandle extends SeekableHandle, CloseableHandle {}
  interface CloseableReadHandle extends ReadHandle, CloseableHandle {}
  interface SeekableReadHandle extends ReadHandle, SeekableHandle {}
  interface CloseableSeekableReadHandle
    extends SeekableReadHandle, CloseableReadHandle, CloseableSeekableHandle {}
  interface CloseableWriteHandle extends WriteHandle, CloseableHandle {}
  interface SeekableWriteHandle extends WriteHandle, SeekableHandle {}
  interface CloseableSeekableWriteHandle
    extends
      SeekableWriteHandle,
      CloseableWriteHandle,
      CloseableSeekableHandle {}
  interface ReadWriteHandle extends WriteHandle, ReadHandle {}
  interface CloseableReadWriteHandle
    extends ReadWriteHandle, CloseableWriteHandle, CloseableReadHandle {}
  interface SeekableReadWriteHandle
    extends ReadWriteHandle, SeekableWriteHandle, SeekableReadHandle {}
  interface CloseableSeekableReadWriteHandle
    extends
      SeekableReadWriteHandle,
      CloseableReadWriteHandle,
      CloseableSeekableWriteHandle,
      CloseableSeekableReadHandle {}
  interface CloseableFDHandle extends FDHandle, CloseableHandle {}
  interface SeekableFDHandle extends FDHandle, SeekableHandle {}
  interface CloseableSeekableFDHandle
    extends SeekableFDHandle, CloseableFDHandle, CloseableSeekableHandle {}
  interface ReadFDHandle extends FDHandle, ReadHandle {}
  interface CloseableReadFDHandle
    extends ReadFDHandle, CloseableFDHandle, CloseableReadHandle {}
  interface SeekableReadFDHandle
    extends ReadFDHandle, SeekableFDHandle, SeekableReadHandle {}
  interface CloseableSeekableReadFDHandle
    extends
      SeekableReadFDHandle,
      CloseableReadFDHandle,
      CloseableSeekableFDHandle,
      CloseableSeekableReadHandle {}
  interface WriteFDHandle extends FDHandle, WriteHandle {}
  interface CloseableWriteFDHandle
    extends WriteFDHandle, CloseableFDHandle, CloseableWriteHandle {}
  interface SeekableWriteFDHandle
    extends WriteFDHandle, SeekableFDHandle, SeekableWriteHandle {}
  interface CloseableSeekableWriteFDHandle
    extends
      SeekableWriteFDHandle,
      CloseableWriteFDHandle,
      CloseableSeekableFDHandle,
      CloseableSeekableWriteHandle {}
  interface ReadWriteFDHandle
    extends WriteFDHandle, ReadFDHandle, ReadWriteHandle {}
  interface CloseableReadWriteFDHandle
    extends
      ReadWriteFDHandle,
      CloseableWriteFDHandle,
      CloseableReadFDHandle,
      CloseableReadWriteHandle {}
  interface SeekableReadWriteFDHandle
    extends
      ReadWriteFDHandle,
      SeekableWriteFDHandle,
      SeekableReadFDHandle,
      SeekableReadWriteHandle {}
  interface CloseableSeekableReadWriteFDHandle
    extends
      SeekableReadWriteFDHandle,
      CloseableReadWriteFDHandle,
      CloseableSeekableWriteFDHandle,
      CloseableSeekableReadFDHandle,
      CloseableSeekableReadWriteHandle {}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/StdioReadHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

use namespace HH\Lib\{IO, OS};

final class StdioReadHandle
  extends FileDescriptorHandle
  implements IO\CloseableReadFDHandle {

  use FileDescriptorReadHandleTrait;
  public function __construct(OS\FileDescriptor $fd) {
    parent::__construct($fd);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/FileDescriptorWriteHandleTrait.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

use namespace HH\Lib\{IO, Math, OS, Str};
use namespace HH\Lib\_Private\_OS;

trait FileDescriptorWriteHandleTrait implements IO\WriteHandle {
  require extends FileDescriptorHandle;
  use IO\WriteHandleConvenienceMethodsTrait;

  final protected function writeImpl(string $bytes): int {
    return OS\write($this->impl, $bytes);
  }

  final public async function writeAllowPartialSuccessAsync(
    string $bytes,
    ?int $timeout_ns = null,
  ): Awaitable<int> {
    _OS\arg_assert(
      $timeout_ns is null || $timeout_ns > 0,
      '$timeout_ns must be null, or > 0',
    );
    $timeout_ns ??= 0;

    try {
      return $this->writeImpl($bytes);
    } catch (OS\BlockingIOException $_) {
      // We need to wait, which we do below...
    }
    await $this->selectAsync(\STREAM_AWAIT_WRITE, $timeout_ns);
    return $this->writeImpl($bytes);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/CloseWhenDisposed.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

use namespace HH\Lib\IO;

final class CloseWhenDisposed implements \IDisposable {
  public function __construct(
    private IO\CloseableHandle $handle,
  ) {
  }

  public function __dispose(): void {
    $this->handle->close();
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/FileDescriptorHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

use namespace HH\Lib\{IO, OS, Str};
use namespace HH\Lib\_Private\{_IO, _OS};

abstract class FileDescriptorHandle implements IO\CloseableHandle, IO\FDHandle {
  protected bool $isAwaitable = true;

  protected function __construct(protected OS\FileDescriptor $impl) {
    // Preserve existing flags, especially O_APPEND
    $flags = OS\fcntl($impl, OS\FcntlOp::F_GETFL) as int;
    OS\fcntl($impl, OS\FcntlOp::F_SETFL, $flags | OS\O_NONBLOCK);
  }

  final public function getFileDescriptor(): OS\FileDescriptor {
    return $this->impl;
  }

  final protected async function selectAsync(
    int $flags,
    int $timeout_ns,
  ): Awaitable<void> {
    if (!$this->isAwaitable) {
      return;
    }
    try {
      $result = await _OS\poll_async($this->impl, $flags, $timeout_ns);
      if ($result === \STREAM_AWAIT_CLOSED) {
        _OS\throw_errno(OS\Errno::EBADFD, "Can't await a closed FD");
      }

    } catch (_OS\ErrnoException $e) {
      if ($e->getCode() === OS\Errno::ENOTSUP) {
        // e.g. real files on Linux when using epoll
        $this->isAwaitable = false;
        return;
      }
      throw $e;
    }
  }

  final public function close(): void {
    OS\close($this->impl);
  }

  <<__ReturnDisposable>>
  final public function closeWhenDisposed(): \IDisposable {
    return new _IO\CloseWhenDisposed($this);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/ResponseWriteHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

use namespace HH\Lib\{IO, OS};

final class ResponseWriteHandle implements IO\WriteHandle {
  use IO\WriteHandleConvenienceMethodsTrait;

  protected function writeImpl(string $bytes): int {
    return namespace\response_write($bytes);
  }

  public async function writeAllowPartialSuccessAsync(
    string $bytes,
    ?int $_timeout_ns = null,
  ): Awaitable<int> {
    return $this->writeImpl($bytes);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/PipeReadHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

use namespace HH\Lib\{IO, OS};

final class PipeReadHandle
  extends FileDescriptorHandle
  implements IO\CloseableReadFDHandle {
  use FileDescriptorReadHandleTrait;
  public function __construct(OS\FileDescriptor $r) {
    parent::__construct($r);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/FileDescriptorReadHandleTrait.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

use namespace HH\Lib\{IO, Str, OS, Math};
use namespace HH\Lib\_Private\_OS;

trait FileDescriptorReadHandleTrait implements IO\ReadHandle {
  require extends FileDescriptorHandle;
  use IO\ReadHandleConvenienceMethodsTrait;

  final public function readImpl(?int $max_bytes = null): string {
    $max_bytes ??= DEFAULT_READ_BUFFER_SIZE;

    _OS\arg_assert($max_bytes > 0, '$max_bytes must be null, or > 0');
    return OS\read($this->impl, $max_bytes);
  }

  final public async function readAllowPartialSuccessAsync(
    ?int $max_bytes = null,
    ?int $timeout_ns = null,
  ): Awaitable<string> {
    $max_bytes ??= DEFAULT_READ_BUFFER_SIZE;

    _OS\arg_assert($max_bytes > 0, '$max_bytes must be null, or > 0');
    _OS\arg_assert(
      $timeout_ns is null || $timeout_ns > 0,
      '$timeout_ns must be null, or > 0',
    );
    $timeout_ns ??= 0;

    try {
      return $this->readImpl($max_bytes);
    } catch (OS\BlockingIOException $_) {
      // this means we need to wait for data, which we do below...
    }

    await $this->selectAsync(\STREAM_AWAIT_READ, $timeout_ns);
    return $this->readImpl($max_bytes);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/PipeWriteHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

use namespace HH\Lib\{IO, OS};

final class PipeWriteHandle
  extends FileDescriptorHandle
  implements IO\CloseableWriteFDHandle {
  use FileDescriptorWriteHandleTrait;

  public function __construct(OS\FileDescriptor $r) {
    parent::__construct($r);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/DEFAULT_READ_BUFFER_SIZE.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

const int DEFAULT_READ_BUFFER_SIZE = 1024 * 8; // 8 KiB
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/StdioWriteHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

use namespace HH\Lib\{IO, OS};

final class StdioWriteHandle
  extends FileDescriptorHandle
  implements IO\CloseableWriteFDHandle {
  use FileDescriptorWriteHandleTrait;

  public function __construct(OS\FileDescriptor $fd) {
    parent::__construct($fd);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/_Private/RequestReadHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_IO {

use namespace HH\Lib\{IO, OS};
use namespace HH\Lib\_Private\_OS;

final class RequestReadHandle implements IO\ReadHandle {
  use IO\ReadHandleConvenienceMethodsTrait;

  public function readImpl(?int $max_bytes = null): string {
    $max_bytes ??= DEFAULT_READ_BUFFER_SIZE;
    _OS\arg_assert($max_bytes > 0, '$max_bytes must be null or positive');
    return namespace\request_read($max_bytes);
  }

  public async function readAllowPartialSuccessAsync(
    ?int $max_bytes = null,
    ?int $timeout_ns = null,
  ): Awaitable<string> {
    return $this->readImpl($max_bytes);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/BufferedReaderLineIterator.php /////
/*
 *  Copyright (c) 2017-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

use namespace HH\Lib\OS;

final class BufferedReaderLineIterator implements AsyncIterator<string> {
  public function __construct(private BufferedReader $reader) {
  }

  public async function next(): Awaitable<?(mixed, string)> {
    $line = await $this->reader->readLineAsync();
    if ($line === null) {
      return null;
    }
    return tuple(null, $line);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/ReadHandle.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

use namespace HH\Lib\Fileystem;
use namespace HH\Lib\_Private;

/** An `IO\Handle` that is readable.
 *
 * If implementing this interface, you may wish to use
 * `ReadHandleConvenienceAccessorTrait`, which implements `readAllAsync()` and
 * `readFixedSizeAsync()` on top of `readAsync`.
 */
interface ReadHandle extends Handle {
  /** An immediate, unordered read.
   *
   * @see `readAsync`
   * @see `readAllAsync`
   * @param $max_bytes the maximum number of bytes to read
   *   - if `null`, an internal default will be used.
   *   - if 0, `EINVAL` will be raised.
   *   - up to `$max_bytes` may be allocated in a buffer; large values may lead
   *     to unnecessarily hitting the request memory limit.
   * @throws `OS\BlockingIOException` if there is no more
   *   data available to read. If you want to wait for more
   *   data, use `readAsync` instead.
   * @returns
   *   - the read data on success.
   *   - the empty string if the end of file is reached.
   */
  public function readImpl(?int $max_bytes = null): string;

  /** Read from the handle, waiting for data if necessary.
   *
   * A wrapper around `read()` that will wait for more data if there is none
   * available at present.
   *
   * @see `readAllAsync`
   * @param max_bytes the maximum number of bytes to read
   *   - if `null`, an internal default will be used.
   *   - if 0, `EINVAL` will be raised.
   *   - up to `$max_bytes` may be allocated in a buffer; large values may lead
   *     to unnecessarily hitting the request memory limit.
   * @returns
   *   - the read data on success
   *   - the empty string if the end of file is reached.
   */
  public function readAllowPartialSuccessAsync(
    ?int $max_bytes = null,
    ?int $timeout_ns = null,
  ): Awaitable<string>;

  /** Read until there is no more data to read.
   *
   * It is possible for this to never return, e.g. if called on a pipe or
   * or socket which the other end keeps open forever. Set a timeout if you
   * do not want this to happen.
   *
   * Up to `$max_bytes` may be allocated in a buffer; large values may lead to
   * unnecessarily hitting the request memory limit.
   */
  public function readAllAsync(
    ?int $max_bytes = null,
    ?int $timeout_ns = null,
  ): Awaitable<string>;

  /** Read a fixed amount of data.
   *
   * Will fail with `EPIPE` if the file is closed before that much data is
   * available.
   *
   * It is possible for this to never return, e.g. if called on a pipe or
   * or socket which the other end keeps open forever. Set a timeout if you
   * do not want this to happen.
   */
  public function readFixedSizeAsync(
    int $size,
    ?int $timeout_ns = null,
  ): Awaitable<string>;

}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/io/stdio.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\IO {

use namespace HH\Lib\OS;
use namespace HH\Lib\_Private\_IO;

/** Return the output handle for the current request.
 *
 * This should generally be used for sending data to clients. In CLI mode, this
 * is usually the process STDOUT.
 *
 * This MAY be a `CloseableWriteFDHandle`.
 *
 * @see requestOutput
 */
<<__Memoize>>
function request_output(): WriteHandle {
  try {
    return new _IO\StdioWriteHandle(OS\stdout());
  } catch (OS\ErrnoException $e) {
    if ($e->getErrno() === OS\Errno::EBADF) {
      return new _IO\ResponseWriteHandle();
    }
    throw $e;
  }
}

/** Return the error output handle for the current request.
 *
 * This is usually only available for CLI scripts; it will return null in most
 * other contexts, including HTTP requests.
 *
 * For a throwing version, use `request_errorx()`.
 *
 * In CLI mode, this is usually the process STDERR.
 */
function request_error(): ?CloseableWriteFDHandle {
  try {
    return request_errorx();
  } catch (OS\ErrnoException $e) {
    if ($e->getErrno() === OS\Errno::EBADF) {
      return null;
    }
    throw $e;
  }
}

/** Return the error output handle for the current request.
 *
 * This is usually only available for CLI scripts; it will fail with `EBADF.
 * in most other contexts, including HTTP requests.
 *
 * For a non-throwing version, use `request_error()`.
 *
 * In CLI mode, this is usually the process STDERR.
 */
function request_errorx(): CloseableWriteFDHandle {
  return new _IO\StdioWriteHandle(OS\stderr());
}

/** Return the input handle for the current request.
 *
 * In CLI mode, this is likely STDIN; for HTTP requests, it may contain the
 * POST data, if any.
 *
 * This MAY be a `CloseableReadFDHandle`.
 */
<<__Memoize>>
function request_input(): ReadHandle {
  try {
    return new _IO\StdioReadHandle(OS\stdin());
  } catch (OS\ErrnoException $e) {
    if ($e->getErrno() === OS\Errno::EBADF) {
      return new _IO\RequestReadHandle();
    }
    throw $e;
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/tcp/CloseableSocket.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\TCP {

use namespace HH\Lib\Network;
use namespace HH\Lib\_Private\_TCP;

<<__Sealed(_TCP\CloseableTCPSocket::class)>>
interface CloseableSocket
  extends Socket, Network\CloseableSocket {
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/tcp/ConnectOptions.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\TCP {
use namespace HH\Lib\Network;

type ConnectOptions = shape(
  ?'timeout_ns' => ?int,
  ?'ip_version' => Network\IPProtocolBehavior,
);
}
///// /home/ubuntu/hhvm/hphp/hsl/src/tcp/connect.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\TCP {

use namespace HH\Lib\{Network, OS};
use namespace HH\Lib\_Private\{_Network, _OS, _TCP};

/** Connect to a socket asynchronously, returning a non-disposable handle.
 *
 * If using IPv6 with a fallback to IPv4 with a connection timeout, the timeout
 * will apply separately to the IPv4 and IPv6 connection attempts.
 */
async function connect_async(
  string $host,
  int $port,
  ConnectOptions $opts = shape(),
): Awaitable<CloseableSocket> {
  $ipver = $opts['ip_version'] ?? Network\IPProtocolBehavior::PREFER_IPV6;
  $timeout_ns = $opts['timeout_ns'] ?? 0;
  switch ($ipver) {
    case Network\IPProtocolBehavior::PREFER_IPV6:
      $sds = vec[OS\SocketDomain::PF_INET6, OS\SocketDomain::PF_INET];
      break;
    case Network\IPProtocolBehavior::FORCE_IPV6:
      $sds = vec[OS\SocketDomain::PF_INET6];
      break;
    case Network\IPProtocolBehavior::FORCE_IPV4:
      $sds = vec[OS\SocketDomain::PF_INET];
      break;
  }

  $ex = null;
  foreach ($sds as $sd) {
    $sock = OS\socket($sd, OS\SocketType::SOCK_STREAM, 0);
    $sa = null;
    switch ($sd) {
      case OS\SocketDomain::PF_INET:
        $ipv4_host = _Network\resolve_hostname(
          OS\AddressFamily::AF_INET,
          $host,
        );
        if ($ipv4_host is nonnull) {
          $sa = new OS\sockaddr_in(
            $port,
            OS\inet_pton_inet($ipv4_host),
          );
        }
        break;
      case OS\SocketDomain::PF_INET6:
        $ipv6_host = _Network\resolve_hostname(
          OS\AddressFamily::AF_INET6,
          $host,
        );

        if ($ipv6_host !== null) {
          $sa = new OS\sockaddr_in6(
            $port,
            /* flowinfo = */ 0,
            OS\inet_pton_inet6($ipv6_host),
            /* scope id = */ 0,
          );
        }
        break;
      case OS\SocketDomain::PF_UNIX:
        invariant_violation('unreachable');
    }

    if ($sa === null) {
      continue;
    }

    try {
      await _Network\socket_connect_async($sock, $sa, $timeout_ns);
      return new _TCP\CloseableTCPSocket($sock);
    } catch (OS\ErrnoException $this_sd_ex) {
      $ex = $this_sd_ex;
    }
  }
  if ($ex === null) {
    _OS\throw_errno(
      OS\Errno::EINVAL,
      "Failed to create a sockaddr for any domain",
    );
  }
  throw $ex;
}

<<__Deprecated("Use connect_async() instead")>>
async function connect_nd_async(
  string $host,
  int $port,
  ConnectOptions $opts = shape(),
): Awaitable<CloseableSocket> {
  return await connect_async($host, $port, $opts);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/tcp/ServerOptions.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\TCP {
use namespace HH\Lib\Network;

type ServerOptions = shape(
  ?'backlog' => int,
  ?'socket_options' => Network\SocketOptions,
);
}
///// /home/ubuntu/hhvm/hphp/hsl/src/tcp/_Private/CloseableTCPSocket.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\_Private\_TCP {

use namespace HH\Lib\{IO, Network, OS, TCP};
use namespace HH\Lib\_Private\{_IO, _Network};

final class CloseableTCPSocket
  extends _IO\FileDescriptorHandle
  implements TCP\CloseableSocket, IO\CloseableReadWriteHandle {
  use _IO\FileDescriptorReadHandleTrait;
  use _IO\FileDescriptorWriteHandleTrait;

  public function __construct(OS\FileDescriptor $impl) {
    parent::__construct($impl);
  }

  public function getLocalAddress(): (string, int) {
    $sa = OS\getsockname($this->impl) as OS\sockaddr_in;
    return tuple(
      OS\inet_ntop_inet($sa->getAddress()),
      $sa->getPort(),
    );
  }

  public function getPeerAddress(): (string, int) {
    $sa = OS\getpeername($this->impl) as OS\sockaddr_in;
    return tuple(
      OS\inet_ntop_inet($sa->getAddress()),
      $sa->getPort(),
    );
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/tcp/Server.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\TCP {

use namespace HH\Lib\{OS, Network};
use namespace HH\Lib\_Private\{_Network, _OS, _TCP};

final class Server implements Network\Server<CloseableSocket> {
  /** Host and port */
  const type TAddress = (string, int);

  private function __construct(private OS\FileDescriptor $impl) {
  }

  /** Create a bound and listening instance */
  public static async function createAsync(
    Network\IPProtocolVersion $ipv,
    string $host,
    int $port,
    ServerOptions $opts = shape(),
  ): Awaitable<this> {
    // FIXME: rewrite this once we have OS\getaddrinfo
    switch ($ipv) {
      case Network\IPProtocolVersion::IPV6:
        try {
          $in6_addr = OS\inet_pton_inet6($host);
        } catch (OS\ErrnoException $e) {
          if ($e->getErrno() !== OS\Errno::EINVAL) {
            throw $e;
          }
          $host = _Network\resolve_hostname(OS\AddressFamily::AF_INET6, $host);
          if ($host === null) {
            $host = _Network\resolve_hostname(
              OS\AddressFamily::AF_INET6,
              'localhost',
            );
            if ($host === null) {
              // match bind() errno
              _OS\throw_errno(
                OS\Errno::EADDRNOTAVAIL,
                'failed to resolve localhost to IPv6, assuming IPv6 unsupported',
              );
            }
            throw $e;
          }
          $in6_addr = OS\inet_pton_inet6($host);
        }
        $sd = OS\SocketDomain::PF_INET6;
        $sa = new OS\sockaddr_in6(
          $port,
          /* flowInfo = */ 0,
          $in6_addr,
          /* scopeID = */ 0,
        );
        break;
      case Network\IPProtocolVersion::IPV4:
        try {
          $in_addr = OS\inet_pton_inet($host);
        } catch (OS\ErrnoException $e) {
          if ($e->getErrno() !== OS\Errno::EINVAL) {
            throw $e;
          }
          $host = _Network\resolve_hostname(OS\AddressFamily::AF_INET, $host);
          if ($host === null) {
            $host = _Network\resolve_hostname(
              OS\AddressFamily::AF_INET,
              'localhost',
            );
            if ($host === null) {
              // match bind() errno
              _OS\throw_errno(
                OS\Errno::EADDRNOTAVAIL,
                'failed to resolve localhost to IPv4, assuming IPv4 unsupported',
              );
            }
            throw $e;
          }

          $in_addr = OS\inet_pton_inet($host);
        }
        $sd = OS\SocketDomain::PF_INET;
        $sa = new OS\sockaddr_in($port, $in_addr);
        break;
    }

    return await _Network\socket_create_bind_listen_async(
      $sd,
      OS\SocketType::SOCK_STREAM,
      /* proto = */ 0,
      $sa,
      $opts['backlog'] ?? 16,
      $opts['socket_options'] ?? shape(),
    )
      |> new self($$);
  }

  public async function nextConnectionAsync(): Awaitable<CloseableSocket> {
    return await _Network\socket_accept_async($this->impl)
      |> new _TCP\CloseableTCPSocket($$);
  }

  public function getLocalAddress(): (string, int) {
    $sa = OS\getsockname($this->impl);
    if ($sa is OS\sockaddr_in) {
      return tuple(OS\inet_ntop_inet($sa->getAddress()), $sa->getPort());
    }
    if ($sa is OS\sockaddr_in6) {
      return tuple(OS\inet_ntop_inet6($sa->getAddress()), $sa->getPort());
    }
    _OS\throw_errno(
      OS\Errno::EAFNOSUPPORT,
      "%s is not supported",
      OS\AddressFamily::getNames()[$sa->getFamily()],
    );
  }

  public function stopListening(): void {
    OS\close($this->impl);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/tcp/Socket.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\TCP {

use namespace HH\Lib\{IO, Network};

/**
 * A TCP client or server socket.
 *
 * @see `TCP\Server` to create a server.
 * @see `TCP\connect_async()` to connect to an existing server.
 */
<<__Sealed(CloseableSocket::class)>>
interface Socket extends Network\Socket {
  /** A host and port number */
  const type TAddress = (string, int);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/dict/select.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Dict {

use namespace HH\Lib\C;

/**
 * Returns a new dict containing only the entries of the first KeyedTraversable
 * whose keys do not appear in any of the other ones.
 *
 * Time complexity: O(n + m), where n is size of `$first` and m is the combined
 * size of `$second` plus all the `...$rest`
 * Space complexity: O(n + m), where n is size of `$first` and m is the combined
 * size of `$second` plus all the `...$rest` -- note that this is bigger than
 * O(n)
 */
function diff_by_key<Tk1 as arraykey, Tk2 as arraykey, Tv>(
  KeyedTraversable<Tk1, Tv> $first,
  KeyedTraversable<Tk2, mixed> $second,
  KeyedContainer<Tk2, mixed> ...$rest
)[]: dict<Tk1, Tv> {
  if (!$first) {
    return dict[];
  }
  if (!$second && !$rest) {
    return cast_clear_legacy_array_mark($first);
  }
  $union = merge($second, ...$rest);
  return filter_keys(
    $first,
    $key ==> !C\contains_key($union, $key),
  );
}

/**
 * Returns a new dict containing all except the first `$n` entries of the
 * given KeyedTraversable.
 *
 * To take only the first `$n` entries, see `Dict\take()`.
 *
 * Time complexity: O(n), where n is the size of `$traversable`
 * Space complexity: O(n), where n is the size of `$traversable`
 */
function drop<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  int $n,
)[]: dict<Tk, Tv> {
  invariant($n >= 0, 'Expected non-negative N, got %d.', $n);
  $result = dict[];
  $ii = -1;
  foreach ($traversable as $key => $value) {
    $ii++;
    if ($ii < $n) {
      continue;
    }
    $result[$key] = $value;
  }
  return $result;
}

/**
 * Returns a new dict containing only the values for which the given predicate
 * returns `true`. The default predicate is casting the value to boolean.
 *
 * - To remove null values in a typechecker-visible way, see `Dict\filter_nulls()`.
 * - To use an async predicate, see `Dict\filter_async()`.
 *
 * Time complexity: O(n * p), where p is the complexity of `$value_predicate`
 * (which is O(1) if not provided explicitly)
 * Space complexity: O(n)
 */
function filter<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  ?(function(Tv)[_]: bool) $value_predicate = null,
)[ctx $value_predicate]: dict<Tk, Tv> {
  $value_predicate ??= \HH\Lib\_Private\boolval<>;
  $dict = dict[];
  foreach ($traversable as $key => $value) {
    if ($value_predicate($value)) {
      $dict[$key] = $value;
    }
  }
  return $dict;
}

/**
 * Just like filter, but your predicate can include the key as well as
 * the value.
 *
 * To use an async predicate, see `Dict\filter_with_key_async()`.
 *
 * Time complexity: O(n * p), where p is the complexity of `$value_predicate`
 * (which is O(1) if not provided explicitly)
 * Space complexity: O(n)
 */
function filter_with_key<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  (function(Tk, Tv)[_]: bool) $predicate,
)[ctx $predicate]: dict<Tk, Tv> {
  $dict = dict[];
  foreach ($traversable as $key => $value) {
    if ($predicate($key, $value)) {
      $dict[$key] = $value;
    }
  }
  return $dict;
}

/**
 * Returns a new dict containing only the keys for which the given predicate
 * returns `true`. The default predicate is casting the key to boolean.
 *
 * Time complexity: O(n * p), where p is the complexity of `$value_predicate`
 * (which is O(1) if not provided explicitly)
 * Space complexity: O(n)
 */
function filter_keys<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  ?(function(Tk)[_]: bool) $key_predicate = null,
)[ctx $key_predicate]: dict<Tk, Tv> {
  $key_predicate ??= \HH\Lib\_Private\boolval<>;
  $dict = dict[];
  foreach ($traversable as $key => $value) {
    if ($key_predicate($key)) {
      $dict[$key] = $value;
    }
  }
  return $dict;
}

/**
 * Given a KeyedTraversable with nullable values, returns a new dict with
 * null values removed.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function filter_nulls<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, ?Tv> $traversable,
)[]: dict<Tk, Tv> {
  $result = dict[];
  foreach ($traversable as $key => $value) {
    if ($value !== null) {
      $result[$key] = $value;
    }
  }
  return $result;
}

/**
 * Returns a new dict containing only the keys found in both the input container
 * and the given Traversable. The dict will have the same ordering as the
 * `$keys` Traversable.
 *
 * Time complexity: O(k), where k is the size of `$keys`.
 * Space complexity: O(k), where k is the size of `$keys`.
 */
function select_keys<Tk as arraykey, Tv>(
  KeyedContainer<Tk, Tv> $container,
  Traversable<Tk> $keys,
)[]: dict<Tk, Tv> {
  $result = dict[];
  if (!C\is_empty($container)) {
    foreach ($keys as $key) {
      if (C\contains_key($container, $key)) {
        $result[$key] = $container[$key];
      }
    }
  }
  return $result;
}

/**
 * Returns a new dict containing the first `$n` entries of the given
 * KeyedTraversable.
 *
 * To drop the first `$n` entries, see `Dict\drop()`.
 *
 * Time complexity: O(n), where n is `$n`
 * Space complexity: O(n), where n is `$n`
 */
function take<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  int $n,
)[]: dict<Tk, Tv> {
  if ($n === 0) {
    return dict[];
  }
  invariant($n > 0, 'Expected non-negative length, got %d.', $n);
  $result = dict[];
  $ii = 0;
  foreach ($traversable as $key => $value) {
    $result[$key] = $value;
    $ii++;
    if ($ii === $n) {
      break;
    }
  }
  return $result;
}

/**
 * Returns a new dict in which each value appears exactly once. In case of
 * duplicate values, later keys will overwrite the previous ones.
 *
 * For non-arraykey values, see `Dict\unique_by()`.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function unique<Tk as arraykey, Tv as arraykey>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: dict<Tk, Tv> {
  return flip(flip($traversable));
}

/**
 * Returns a new dict in which each value appears exactly once, where the
 * value's uniqueness is determined by transforming it to a scalar via the
 * given function. In case of duplicate scalar values, later keys will overwrite
 * the previous ones.
 *
 * For arraykey values, see `Dict\unique()`.
 *
 * Time complexity: O(n * s), where s is the complexity of `$scalar_func`
 * Space complexity: O(n)
 */
function unique_by<Tk as arraykey, Tv, Ts as arraykey>(
  KeyedContainer<Tk, Tv> $container,
  (function(Tv)[_]: Ts) $scalar_func,
)[ctx $scalar_func]: dict<Tk, Tv> {
  // We first convert the container to dict[scalar_key => original_key] to
  // remove duplicates, then back to dict[original_key => original_value].
  return $container
    |> pull_with_key(
      $$,
      ($k, $_) ==> $k,
      ($_, $v) ==> $scalar_func($v),
    )
    |> pull(
      $$,
      $orig_key ==> $container[$orig_key],
      $x ==> $x,
    );
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/dict/divide.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Dict {

/**
 * Returns a 2-tuple containing dicts for which the given predicate returned
 * `true` and `false`, respectively.
 *
 * Time complexity: O(n * p), where p is the complexity of `$predicate`.
 * Space complexity: O(n)
 */
function partition<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  (function(Tv)[_]: bool) $predicate,
)[ctx $predicate]: (dict<Tk, Tv>, dict<Tk, Tv>) {
  $success = dict[];
  $failure = dict[];
  foreach ($traversable as $key => $value) {
    if ($predicate($value)) {
      $success[$key] = $value;
    } else {
      $failure[$key] = $value;
    }
  }
  return tuple($success, $failure);
}

/**
 * Returns a 2-tuple containing dicts for which the given keyed predicate
 * returned `true` and `false`, respectively.
 *
 * Time complexity: O(n * p), where p is the complexity of `$predicate`.
 * Space complexity: O(n)
 */
function partition_with_key<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  (function(Tk, Tv)[_]: bool) $predicate,
)[ctx $predicate]: (dict<Tk, Tv>, dict<Tk, Tv>) {
  $success = dict[];
  $failure = dict[];
  foreach ($traversable as $key => $value) {
    if ($predicate($key, $value)) {
      $success[$key] = $value;
    } else {
      $failure[$key] = $value;
    }
  }
  return tuple($success, $failure);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/dict/combine.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Dict {

use namespace HH\Lib\{C, Vec};

/**
 * Returns a new dict where each element in `$keys` maps to the
 * corresponding element in `$values`.
 *
 * Time complexity: O(n) where n is the size of `$keys` (which must be the same
 * as the size of `$values`)
 * Space complexity: O(n) where n is the size of `$keys` (which must be the same
 * as the size of `$values`)
 */
function associate<Tk as arraykey, Tv>(
  Traversable<Tk> $keys,
  Traversable<Tv> $values,
)[]: dict<Tk, Tv> {
  $key_vec = Vec\cast_clear_legacy_array_mark($keys);
  $value_vec = Vec\cast_clear_legacy_array_mark($values);
  invariant(
    C\count($key_vec) === C\count($value_vec),
    'Expected length of keys and values to be the same',
  );
  $result = dict[];
  foreach ($key_vec as $idx => $key) {
    $result[$key] = $value_vec[$idx];
  }
  return $result;
}

/**
 * Merges multiple KeyedTraversables into a new dict. In the case of duplicate
 * keys, later values will overwrite the previous ones.
 *
 * Time complexity: O(n + m), where n is the size of `$first` and m is the
 * combined size of all the `...$rest`
 * Space complexity: O(n + m), where n is the size of `$first` and m is the
 * combined size of all the `...$rest`
 */
function merge<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $first,
  KeyedContainer<Tk, Tv> ...$rest
)[]: dict<Tk, Tv> {
  $result = cast_clear_legacy_array_mark($first);
  foreach ($rest as $traversable) {
    foreach ($traversable as $key => $value) {
      $result[$key] = $value;
    }
  }
  return $result;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/dict/transform.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Dict {

use namespace HH\Lib\Math;

/**
 * Returns a vec containing the original dict split into chunks of the given
 * size.
 *
 * If the original dict doesn't divide evenly, the final chunk will be
 * smaller.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function chunk<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $traversable,
  int $size,
)[]: vec<dict<Tk, Tv>> {
  invariant($size > 0, 'Expected positive chunk size, got %d.', $size);
  $result = vec[];
  $ii = 0;
  $chunk_number = -1;
  foreach ($traversable as $key => $value) {
    if ($ii % $size === 0) {
      $result[] = dict[];
      $chunk_number++;
    }
    $result[$chunk_number][$key] = $value;
    $ii++;
  }
  return $result;
}

/**
 * Returns a new dict mapping each value to the number of times it appears
 * in the given Traversable.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function count_values<Tv as arraykey>(
  Traversable<Tv> $values,
)[]: dict<Tv, int> {
  $result = dict[];
  foreach ($values as $value) {
    $result[$value] = idx($result, $value, 0) + 1;
  }
  return $result;
}

/**
 * Returns a new dict formed by merging the KeyedContainer elements of the
 * given Traversable.
 *
 * In the case of duplicate keys, later values will overwrite
 * the previous ones.
 *
 * For a fixed number of KeyedTraversables, see `Dict\merge()`.
 *
 * Time complexity: O(n), where n is the combined size of all the
 * `$traversables`
 * Space complexity: O(n), where n is the combined size of all the
 * `$traversables`
 */
function flatten<Tk as arraykey, Tv>(
  Traversable<KeyedContainer<Tk, Tv>> $traversables,
)[]: dict<Tk, Tv> {
  $result = dict[];
  foreach ($traversables as $traversable) {
    foreach ($traversable as $key => $value) {
      $result[$key] = $value;
    }
  }
  return $result;
}

/**
 * Returns a new dict where all the given keys map to the given value.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function fill_keys<Tk as arraykey, Tv>(
  Traversable<Tk> $keys,
  Tv $value,
)[]: dict<Tk, Tv> {
  $result = dict[];
  foreach ($keys as $key) {
    $result[$key] = $value;
  }
  return $result;
}

/**
 * Returns a new dict keyed by the values of the given KeyedTraversable
 * and vice-versa.
 *
 * In case of duplicate values, later keys overwrite the
 * previous ones.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function flip<Tk, Tv as arraykey>(
  KeyedTraversable<Tk, Tv> $traversable,
)[]: dict<Tv, Tk> {
  $result = dict[];
  foreach ($traversable as $key => $value) {
    $result[$value] = $key;
  }
  return $result;
}

/**
 * Returns a new dict where each value is the result of calling the given
 * function on the corresponding key.
 *
 * - To use an async function, see `Dict\from_key_async()`.
 * - To create a dict from values, see `Dict\from_values()`.
 * - To create a dict from key/value tuples, see `Dict\from_entries()`.
 *
 * Time complexity: O(n * f), where f is the complexity of `$value_func`
 * Space complexity: O(n)
 */
function from_keys<Tk as arraykey, Tv>(
  Traversable<Tk> $keys,
  (function(Tk)[_]: Tv) $value_func,
)[ctx $value_func]: dict<Tk, Tv> {
  $result = dict[];
  foreach ($keys as $key) {
    $result[$key] = $value_func($key);
  }
  return $result;
}

/**
 * Returns a new dict where each mapping is defined by the given key/value
 * tuples.
 *
 * In the case of duplicate keys, later values will overwrite the
 * previous ones.
 *
 * - To create a dict from keys, see `Dict\from_keys()`.
 * - To create a dict from values, see `Dict\from_values()`.
 *
 * Also known as `unzip` or `fromItems` in other implementations.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function from_entries<Tk as arraykey, Tv>(
  Traversable<(Tk, Tv)> $entries,
)[]: dict<Tk, Tv> {
  $result = dict[];
  foreach ($entries as list($key, $value)) {
    $result[$key] = $value;
  }
  return $result;
}

/**
 * Returns a new dict keyed by the result of calling the given function on each
 * corresponding value.
 *
 * In the case of duplicate keys, later values will
 * overwrite the previous ones.
 *
 * - To create a dict from keys, see `Dict\from_keys()`.
 * - To create a dict from key/value tuples, see `Dict\from_entries()`.
 * - To create a dict containing all values with the same keys, see `Dict\group_by()`.
 *
 * Time complexity: O(n)
 * Space complexity: O(n)
 */
function from_values<Tk as arraykey, Tv>(
  Traversable<Tv> $values,
  (function(Tv)[_]: Tk) $key_func,
)[ctx $key_func]: dict<Tk, Tv> {
  $result = dict[];
  foreach ($values as $value) {
    $result[$key_func($value)] = $value;
  }
  return $result;
}

 /**
  * Return a dict keyed by the result of calling the giving function, preserving
  * duplicate values.
  *
  *  - keys are the results of the given function called on the given values.
  *  - values are vecs of original values that all produced the same key.
  *
  * If a value produces a null key, it's omitted from the result.
  *
  * Time complexity: O(n * f), where f is the complexity of `$key_func`
  * Space complexity: O(n)
  */
function group_by<Tk as arraykey, Tv>(
  Traversable<Tv> $values,
  (function(Tv)[_]: ?Tk) $key_func,
)[ctx $key_func]: dict<Tk, vec<Tv>> {
  $result = dict[];
  foreach ($values as $value) {
    $key = $key_func($value);
    if ($key === null) {
      continue;
    }
    $result[$key] ??= vec[];
    $result[$key][] = $value;
  }
  return $result;
}

/**
 * Returns a new dict where each value is the result of calling the given
 * function on the original value.
 *
 * To use an async function, see `Dict\map_async()`.
 *
 * Time complexity: O(n * f), where f is the complexity of `$value_func`
 * Space complexity: O(n)
 */
<<__ProvenanceSkipFrame>>
function map<Tk as arraykey, Tv1, Tv2>(
  KeyedTraversable<Tk, Tv1> $traversable,
  (function(Tv1)[_]: Tv2) $value_func,
)[ctx $value_func]: dict<Tk, Tv2> {
  $result = dict[];
  foreach ($traversable as $key => $value) {
    $result[$key] = $value_func($value);
  }
  return $result;
}

/**
 * Returns a new dict where each key is the result of calling the given
 * function on the original key. In the case of duplicate keys, later values
 * will overwrite the previous ones.
 *
 * Time complexity: O(n * f), where f is the complexity of `$key_func`
 * Space complexity: O(n)
 */
function map_keys<Tk1, Tk2 as arraykey, Tv>(
  KeyedTraversable<Tk1, Tv> $traversable,
  (function(Tk1)[_]: Tk2) $key_func,
)[ctx $key_func]: dict<Tk2, Tv> {
  $result = dict[];
  foreach ($traversable as $key => $value) {
    $result[$key_func($key)] = $value;
  }
  return $result;
}

/**
 * Returns a new dict where each value is the result of calling the given
 * function on the original value and key.
 *
 * Time complexity: O(n * f), where f is the complexity of `$value_func`
 * Space complexity: O(n)
 */
function map_with_key<Tk as arraykey, Tv1, Tv2>(
  KeyedTraversable<Tk, Tv1> $traversable,
  (function(Tk, Tv1)[_]: Tv2) $value_func,
)[ctx $value_func]: dict<Tk, Tv2> {
  $result = dict[];
  foreach ($traversable as $key => $value) {
    $result[$key] = $value_func($key, $value);
  }
  return $result;
}

/**
 * Returns a new dict with mapped keys and values.
 *
 *  - values are the result of calling `$value_func` on the original value
 *  - keys are the result of calling `$key_func` on the original value.
 * In the case of duplicate keys, later values will overwrite the previous ones.
 *
 * Time complexity: O(n * (f1 + f2), where f1 is the complexity of `$value_func`
 * and f2 is the complexity of `$key_func`
 * Space complexity: O(n)
 */
function pull<Tk as arraykey, Tv1, Tv2>(
  Traversable<Tv1> $traversable,
  (function(Tv1)[_]: Tv2) $value_func,
  (function(Tv1)[_]: Tk) $key_func,
)[ctx $value_func, ctx $key_func]: dict<Tk, Tv2> {
  $result = dict[];
  foreach ($traversable as $value) {
    $result[$key_func($value)] = $value_func($value);
  }
  return $result;
}

/**
 * Returns a new dict with mapped keys and values.
 *
 *  - values are the result of calling `$value_func` on the original value/key
 *  - keys are the result of calling `$key_func` on the original value/key.
 * In the case of duplicate keys, later values will overwrite the previous ones.
 *
 * Time complexity: O(n * (f1 + f2), where f1 is the complexity of `$value_func`
 * and f2 is the complexity of `$key_func`
 * Space complexity: O(n)
 */
function pull_with_key<Tk1, Tk2 as arraykey, Tv1, Tv2>(
  KeyedTraversable<Tk1, Tv1> $traversable,
  (function(Tk1, Tv1)[_]: Tv2) $value_func,
  (function(Tk1, Tv1)[_]: Tk2) $key_func,
)[ctx $value_func, ctx $key_func]: dict<Tk2, Tv2> {
  $result = dict[];
  foreach ($traversable as $key => $value) {
    $result[$key_func($key, $value)] = $value_func($key, $value);
  }
  return $result;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/dict/introspect.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Dict {

use namespace HH\Lib\C;

/**
 * Returns whether the two given dicts have the same entries, using strict
 * equality. To guarantee equality of order as well as contents, use `===`.
 *
 * Time complexity: O(n)
 * Space complexity: O(1)
 */
function equal<Tk as arraykey, Tv>(
  dict<Tk, Tv> $dict1,
  dict<Tk, Tv> $dict2,
)[]: bool {
  if ($dict1 === $dict2) {
    return true;
  }
  if (C\count($dict1) !== C\count($dict2)) {
    return false;
  }
  foreach ($dict1 as $key => $value) {
    if (!C\contains_key($dict2, $key) || $dict2[$key] !== $value) {
      return false;
    }
  }
  return true;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/dict/order.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Dict {

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
)[]: dict<Tk, Tv> {
  $dict = cast_clear_legacy_array_mark($traversable);
  return $dict
    |> Vec\keys($$)
    |> Vec\reverse($$)
    |> from_keys($$, ($k) ==> $dict[$k]);
}

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
)[leak_safe]: dict<Tk, Tv> {
  $dict = cast_clear_legacy_array_mark($container);
  return Vec\keys($container)
    |> Vec\shuffle($$)
    |> from_keys($$, ($k) ==> $dict[$k]);
}

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
)[ctx $value_comparator]: dict<Tk, Tv> {
  $result = cast_clear_legacy_array_mark($traversable);
  if ($value_comparator) {
    \uasort(inout $result, $value_comparator);
  } else {
    \asort(inout $result);
  }
  return dict($result);
}

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
)[ctx $scalar_func, ctx $scalar_comparator]: dict<Tk, Tv> {
  $tuple_comparator = $scalar_comparator
    ? ((Ts, Tv) $a, (Ts, Tv) $b) ==> $scalar_comparator($a[0], $b[0])
    /* HH_FIXME[4240] need Scalar type */
    : ((Ts, Tv) $a, (Ts, Tv) $b) ==> $a[0] <=> $b[0];
  return $traversable
    |> map($$, $v ==> tuple($scalar_func($v), $v))
    |> sort($$, $tuple_comparator)
    |> map($$, $t ==> $t[1]);
}

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
)[ctx $key_comparator]: dict<Tk, Tv> {
  $result = cast_clear_legacy_array_mark($traversable);
  if ($key_comparator) {
    \uksort(inout $result, $key_comparator);
  } else {
    \ksort(inout $result);
  }
  return dict($result);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/dict/async.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Dict {

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
)[]: Awaitable<dict<Tk, Tv>> {
  $dict = cast_clear_legacy_array_mark($awaitables);

  /* HH_FIXME[4390] Magic Function */
  await AwaitAllWaitHandle::fromDict($dict);
  foreach ($dict as $key => $value) {
    /* HH_FIXME[4390] Magic Function */
    $dict[$key] = \HH\Asio\result($value);
  }
  /* HH_FIXME[4110] Reuse the existing dict to reduce peak memory. */
  return $dict;
}

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
)[ctx $async_func]: Awaitable<dict<Tk, Tv>> {
  $awaitables = dict[];
  foreach ($keys as $key) {
    $awaitables[$key] ??= $async_func($key);
  }
  /* HH_FIXME[4135] Unset local variable to reduce peak memory. */
  unset($keys);

  /* HH_FIXME[4390] Magic Function */
  await AwaitAllWaitHandle::fromDict($awaitables);
  foreach ($awaitables as $key => $value) {
    /* HH_FIXME[4390] Magic Function */
    $awaitables[$key] = \HH\Asio\result($value);
  }
  /* HH_FIXME[4110] Reuse the existing dict to reduce peak memory. */
  return $awaitables;
}

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
)[ctx $value_predicate]: Awaitable<dict<Tk, Tv>> {
  $tests = await map_async($traversable, $value_predicate);
  $result = dict[];
  foreach ($traversable as $key => $value) {
    if ($tests[$key]) {
      $result[$key] = $value;
    }
  }
  return $result;
}

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
)[ctx $predicate]: Awaitable<dict<Tk, Tv>> {
  $tests = await map_with_key_async($traversable, $predicate);
  $result = dict[];
  foreach ($tests as $k => $v) {
    if ($v) {
      $result[$k] = $traversable[$k];
    }
  }
  return $result;
}

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
)[ctx $value_func]: Awaitable<dict<Tk, Tv2>> {
  $dict = cast_clear_legacy_array_mark($traversable);
  foreach ($dict as $key => $value) {
    $dict[$key] = $value_func($value);
  }

  /* HH_FIXME[4110] Okay to pass in Awaitable */
  /* HH_FIXME[4390] Magic Function */
  await AwaitAllWaitHandle::fromDict($dict);
  foreach ($dict as $key => $value) {
    /* HH_FIXME[4110] Reuse the existing dict to reduce peak memory. */
    /* HH_FIXME[4390] Magic Function */
    $dict[$key] = \HH\Asio\result($value);
  }
  /* HH_FIXME[4110] Reuse the existing dict to reduce peak memory. */
  return $dict;
}

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
)[ctx $async_func]: Awaitable<dict<Tk, Tv2>> {
  $awaitables = map_with_key($traversable, $async_func);
  /* HH_FIXME[4135] Unset local variable to reduce peak memory. */
  unset($traversable);

  /* HH_FIXME[4390] Magic Function */
  await AwaitAllWaitHandle::fromDict($awaitables);
  foreach ($awaitables as $index => $value) {
    /* HH_FIXME[4390] Magic Function */
    $awaitables[$index] = \HH\Asio\result($value);
  }
  /* HH_FIXME[4110] Reuse the existing dict to reduce peak memory. */
  return $awaitables;
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/dict/cast.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Dict {

/**
 * Casts the given traversable to a dict, resetting the legacy array mark
 * if applicable.
 */
function cast_clear_legacy_array_mark<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, Tv> $x,
)[]: dict<Tk, Tv> {
  return ($x is dict<_,_>)
    ? dict(\HH\array_unmark_legacy($x))
    : dict($x);
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/async/Semaphore.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Async {

use namespace HH\Lib\C;

/** Run an operation with a limit on number of ongoing asynchronous jobs.
 *
 * All operations must have the same input type (`Tin`) and output type (`Tout`),
 * and be processed by the same function; `Tin` may be a callable invoked by the
 * funtion for maximum flexibility, however this pattern is best avoided in favor
 * of creating semaphores with a more narrow process.
 *
 * Use `genWaitFor()` to retrieve a `Tout` from a `Tin`.
 */
final class Semaphore<Tin, Tout> {

  private static int $uniqueIDCounter = 0;
  private dict<int, Condition<null>> $blocking = dict[];
  private Awaitable<void> $activeGen;
  private int $runningCount = 0;
  private int $recentOpenCount = 0;

  /** Create a semaphore.
   *
   * The concurrent limit is per instance; for example, if there are two ongoing requests
   * executing the same code, there will be up to concurrentLimit in each request, meaning
   * up to 2 * concurrentLimit in total.
   */
  public function __construct(
    private int $concurrentLimit,
    private (function(Tin): Awaitable<Tout>) $f,
  ) {
    invariant($concurrentLimit > 0, "Concurrent limit must be greater than 0.");
    $this->activeGen = async {};
  }

  /** Produce a `Tout` from a `Tin`, respecting the concurrency limit. */
  public async function waitForAsync(Tin $value): Awaitable<Tout> {
    $gen = async {
      if (
        $this->runningCount + $this->recentOpenCount >= $this->concurrentLimit
      ) {
        $unique_id = self::$uniqueIDCounter;
        self::$uniqueIDCounter++;
        $condition = new Condition();
        $this->blocking[$unique_id] = $condition;
        await $condition->waitForNotificationAsync($this->activeGen);
        invariant(
          $this->recentOpenCount > 0,
          'Expecting at least one recentOpenCount.',
        );
        $this->recentOpenCount--;
      }
      invariant(
        $this->runningCount < $this->concurrentLimit,
        'Expecting open run slot',
      );
      $f = $this->f;
      $this->runningCount++;
      try {
        return await $f($value);
      } finally {
        $this->runningCount--;
        $next_blocked_id = C\first_key($this->blocking);
        if ($next_blocked_id !== null) {
          $next_blocked = $this->blocking[$next_blocked_id];
          unset($this->blocking[$next_blocked_id]);
          $this->recentOpenCount++;
          $next_blocked->succeed(null);
        }
      }
    };
    $this->activeGen = AwaitAllWaitHandle::fromVec(
      vec[$gen, $this->activeGen],
    );
    return await $gen;
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/async/Poll.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Async {

/** An async poll/select equivalent for traversables without a related key.
 *
 * ===== WARNING ===== WARNING ===== WARNING ===== WARNING ===== WARNING =====
 *
 * See detailed warning at top of `BasePoll`
 *
 * ===== WARNING ===== WARNING ===== WARNING ===== WARNING ===== WARNING =====
 */

final class Poll<Tv> extends BasePoll<mixed, Tv> implements AsyncIterator<Tv> {
  /** Create a Poll from the specified list of awaitables.
   *
   * See `KeyedPoll` if you have a `KeyedTraversable` and want to preserve
   * keys.
   */
  public static function from(Traversable<Awaitable<Tv>> $awaitables): this {
    return self::fromImpl(new Vector($awaitables));
  }

  /** Add an additional awaitable to the poll. */
  public function add(Awaitable<Tv> $awaitable): void {
    $this->addImpl(null, $awaitable);
  }

  /** Add multiple additional awaitables to the poll.
   *
   * See `KeyedPoll` if you have a `KeyedTraversable` and want to preserve keys.
   */
  public function addMulti(Traversable<Awaitable<Tv>> $awaitables): void {
    $this->addMultiImpl(new Vector($awaitables));
  }

  /** Wait for all polled `Awaitable`s, ignoring the results.
   *
   * This is a convenience function, for when the `Awaitable`'s side effects
   * are needed instead of the result.
   */
  public async function waitUntilEmptyAsync(): Awaitable<void> {
    foreach ($this await as $_) {
      // do nothing
    }
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/async/KeyedPoll.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Async {

/** A keyed variant of `Poll`.
 *
 * See `Poll` if you do not need to preserve keys.
 *
 * Keys are retrieved with:
 *
 * ```
 * foreach ($keyed_poll await as $k => $v) {
 * ```
 *
 * ===== WARNING ===== WARNING ===== WARNING ===== WARNING ===== WARNING =====
 *
 * See detailed warning for `BasePoll`
 *
 * ===== WARNING ===== WARNING ===== WARNING ===== WARNING ===== WARNING =====
 */
final class KeyedPoll<Tk, Tv>
  extends BasePoll<Tk, Tv>
  implements AsyncKeyedIterator<Tk, Tv> {

  /** Create a `KeyedPoll` from the specified list of awaitables.
   *
   * See `Poll` if keys are unimportant.
   */
  public static function from(
    KeyedTraversable<Tk, Awaitable<Tv>> $awaitables,
  ): this {
    return self::fromImpl($awaitables);
  }

  /** Add a single awaitable to the poll.
   *
   * The key is retrieved with `foreach ($poll await as $k => $v) {}`
   */
  public function add(Tk $key, Awaitable<Tv> $awaitable): void {
    $this->addImpl($key, $awaitable);
  }

  /** Add multiple keys and awaitables to the poll */
  public function addMulti(
    KeyedTraversable<Tk, Awaitable<Tv>> $awaitables,
  ): void {
    $this->addMultiImpl($awaitables);
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/async/ConditionNode.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Async {

/**
 * A linked list node storing Condition and pointer to the next node.
 */
final class ConditionNode<T> extends Condition<T> {
  private ?ConditionNode<T> $next = null;

  public function addNext(): ConditionNode<T> {
    invariant($this->next === null, 'The next node already exists');
    $this->next = new ConditionNode();
    return $this->next;
  }

  public function getNext(): ?ConditionNode<T> {
    return $this->next;
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/async/Condition.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Async {

/**
 * A wrapper around ConditionWaitHandle that allows notification events
 * to occur before the condition is awaited.
 */
class Condition<T> {
  private ?Awaitable<T> $condition = null;

  /**
   * Notify the condition variable of success and set the result.
   */
  final public function succeed(T $result): void {
    if ($this->condition === null) {
      $this->condition = async {
        return $result;
      };
    } else {
      invariant(
        $this->condition is ConditionWaitHandle<_>,
        'Unable to notify AsyncCondition twice',
      );
      /* HH_FIXME[4110]: Type error revealed by type-safe instanceof feature. See https://fburl.com/instanceof */
      $this->condition->succeed($result);
    }
  }

  /**
   * Notify the condition variable of failure and set the exception.
   */
  final public function fail(\Exception $exception): void {
    if ($this->condition === null) {
      $this->condition = async {
        throw $exception;
      };
    } else {
      invariant(
        $this->condition is ConditionWaitHandle<_>,
        'Unable to notify AsyncCondition twice',
      );
      $this->condition->fail($exception);
    }
  }

  /**
   * Asynchronously wait for the condition variable to be notified and
   * return the result or throw the exception received via notification.
   *
   * The caller must provide an Awaitable $notifiers (which must be a
   * WaitHandle) that must not finish before the notification is received.
   * This means $notifiers must represent work that is guaranteed to
   * eventually trigger the notification. As long as the notification is
   * issued only once, asynchronous execution unrelated to $notifiers is
   * allowed to trigger the notification.
   */
  <<__ProvenanceSkipFrame>>
  final public async function waitForNotificationAsync(
    Awaitable<void> $notifiers,
  ): Awaitable<T> {
    if ($this->condition === null) {
      $this->condition = ConditionWaitHandle::create($notifiers);
    }
    return await $this->condition;
  }
}
}
///// /home/ubuntu/hhvm/hphp/hsl/src/async/BasePoll.php /////
/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

namespace HH\Lib\Async {

/**
 * Asynchronous equivalent of mechanisms such as epoll(), poll() and select().
 *
 * Read the warnings here first, then see the `Poll` and `KeyedPoll`
 * instantiable subclasses.
 *
 * Transforms a set of Awaitables to an asynchronous iterator that produces
 * results of these Awaitables as soon as they are ready. The order of results
 * is not guaranteed in any way. New Awaitables can be added to the Poll
 * while it is being iterated.
 *
 * This mechanism has two primary use cases:
 *
 * 1. Speculatively issuing non-CPU-intensive requests to different backends
 *    with very high processing latency, waiting for the first satisfying
 *    result and ignoring all remaining requests.
 *
 *    Example: cross-DC memcache requests
 *
 * 2. Processing relatively small number of high level results in the order
 *    of completion and flushing the output to the user.
 *
 *    Example: pagelets, multiple GraphQL queries, streamable GraphQL queries
 *
 * ===== WARNING ===== WARNING ===== WARNING ===== WARNING ===== WARNING =====
 *
 * This is a very heavy-weight mechanism with non-trivial CPU cost. NEVER use
 * this in the following situations:
 *
 * 1. Waiting for the first available result and ignoring the rest of work,
 *    unless the processing latency is extremely high (10ms or more) and
 *    the CPU cost of ignored work is negligible. Note: the ignored work
 *    will still be computed and will delay your processing anyway if it's
 *    CPU costly.
 *
 * 2. Reordering huge amount of intermediary results. This is currently known
 *    to be CPU-intensive.
 *
 * ===== WARNING ===== WARNING ===== WARNING ===== WARNING ===== WARNING =====
 */

<<__ConsistentConstruct>>
abstract class BasePoll<Tk, Tv> {
  final public static function create(): this {
    return new static();
  }

  final protected static function fromImpl(
    KeyedTraversable<Tk, Awaitable<Tv>> $awaitables,
  ): this {
    $poll = new static();
    $poll->addMultiImpl($awaitables);
    return $poll;
  }

  private ?ConditionNode<(Tk, Tv)> $lastAdded;
  private ?ConditionNode<(Tk, Tv)> $lastNotified;
  private ?ConditionNode<(Tk, Tv)> $lastAwaited;
  private Awaitable<void> $notifiers;

  private function __construct() {
    $head = new ConditionNode();
    $this->lastAdded = $head;
    $this->lastNotified = $head;
    $this->lastAwaited = $head;
    $this->notifiers = async {
    };
  }

  final protected function addImpl(Tk $key, Awaitable<Tv> $awaitable): void {
    invariant(
      $this->lastAdded !== null,
      'Unable to add item, iteration already finished',
    );

    // Create condition node representing pending event.
    $this->lastAdded = $this->lastAdded->addNext();

    // Make sure the next pending condition is notified upon completion.
    $awaitable = $this->waitForThenNotify($key, $awaitable);

    // Keep track of all pending events.
    $this->notifiers = AwaitAllWaitHandle::fromVec(
      vec[$awaitable, $this->notifiers],
    );
  }

  final protected function addMultiImpl(
    KeyedTraversable<Tk, Awaitable<Tv>> $awaitables,
  ): void {
    invariant(
      $this->lastAdded !== null,
      'Unable to add item, iteration already finished',
    );
    $last_added = $this->lastAdded;

    // Initialize new list of notifiers.
    $notifiers = vec[$this->notifiers];

    foreach ($awaitables as $key => $awaitable) {
      // Create condition node representing pending event.
      $last_added = $last_added->addNext();

      // Make sure the next pending condition is notified upon completion.
      $awaitable = $this->waitForThenNotify($key, $awaitable);
      $notifiers[] = $awaitable;
    }

    // Keep track of all pending events.
    $this->lastAdded = $last_added;
    $this->notifiers = AwaitAllWaitHandle::fromVec($notifiers);
  }

  <<__ProvenanceSkipFrame>>
  private async function waitForThenNotify(
    Tk $key,
    Awaitable<Tv> $awaitable,
  ): Awaitable<void> {
    try {
      $result = await $awaitable;
      $this->lastNotified = ($this->lastNotified as nonnull)->getNext() as
        nonnull;
      $this->lastNotified->succeed(tuple($key, $result));
    } catch (\Exception $exception) {
      $this->lastNotified = ($this->lastNotified as nonnull)->getNext() as
        nonnull;
      $this->lastNotified->fail($exception);
    }
  }

  <<__ProvenanceSkipFrame>>
  final public async function next(): Awaitable<?(Tk, Tv)> {
    invariant(
      $this->lastAwaited !== null,
      'Unable to iterate, iteration already finished',
    );

    $this->lastAwaited = $this->lastAwaited->getNext();
    if ($this->lastAwaited === null) {
      // End of iteration, no pending events to await.
      $this->lastAdded = null;
      $this->lastNotified = null;
      return null;
    }

    return await $this->lastAwaited->waitForNotificationAsync($this->notifiers);
  }

  final public function hasNext(): bool {
    invariant(
      $this->lastAwaited !== null,
      'Unable to iterate, iteration already finished',
    );
    return $this->lastAwaited->getNext() !== null;
  }
}
}
