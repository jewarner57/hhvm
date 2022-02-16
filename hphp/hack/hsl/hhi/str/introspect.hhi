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

namespace HH\Lib\Str;

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
)[]: int ;
/**
 * Returns < 0 if `$string1` is less than `$string2`, > 0 if `$string1` is
 * greater than `$string2`, and 0 if they are equal (case-insensitive).
 *
 * For a case-sensitive comparison, see `Str\compare()`.
 */
function compare_ci(
  string $string1,
  string $string2,
)[]: int ;
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
)[]: bool ;
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
)[]: bool ;
/**
 * Returns whether the string ends with the given suffix.
 *
 * For a case-insensitive check, see `Str\ends_with_ci()`.
 */
function ends_with(
  string $string,
  string $suffix,
)[]: bool ;
/**
 * Returns whether the string ends with the given suffix (case-insensitive).
 *
 * For a case-sensitive check, see `Str\ends_with()`.
 */
function ends_with_ci(
  string $string,
  string $suffix,
)[]: bool ;
/**
 * Returns `true` if `$string` is null or the empty string.
 * Returns `false` otherwise.
 */
function is_empty(
  ?string $string,
)[]: bool ;
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
)[]: int ;
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
)[]: ?int ;
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
)[]: ?int ;
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
)[]: ?int ;
/**
 * Returns whether the string starts with the given prefix.
 *
 * For a case-insensitive check, see `Str\starts_with_ci()`.
 */
function starts_with(
  string $string,
  string $prefix,
)[]: bool ;
/**
 * Returns whether the string starts with the given prefix (case-insensitive).
 *
 * For a case-sensitive check, see `Str\starts_with()`.
 */
function starts_with_ci(
  string $string,
  string $prefix,
)[]: bool ;
