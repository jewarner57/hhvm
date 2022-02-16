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

namespace HH\Lib\Regex;

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
)[]: ?T ;
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
)[]: vec<T> ;
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
)[]: bool ;
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
)[]: string ;
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
)[ctx $replace_func]: string ;
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
)[]: vec<string> ;
/**
 * Renders a Regex Pattern to a string.
 * The regex pattern follows the PCRE library: https://www.pcre.org/original/doc/html/pcresyntax.html.
 */
function to_string(Pattern<Match> $pattern)[]: string ;
