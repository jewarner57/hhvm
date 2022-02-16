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

namespace HH\Lib\Legacy_FIXME;
use namespace HH\Lib\{C, Math, Dict};

/**
 * Does the PHP style behaviour when doing an inc/dec operation.
 * Specially handles
 *   1. incrementing null
 *   2. inc/dec on empty and numeric strings
 */
function increment(mixed $value)[]: dynamic ;
/**
 * See docs on increment
 */
function decrement(mixed $value)[]: dynamic ;
/**
 * Does the PHP style behaviour for casting when doing a mathematical operation.
 * That happens under the following situations
 *   1. null converts to 0
 *   2. bool converts to 0/1
 *   3. numeric string converts to an int or double based on how the string looks.
 *   4. non-numeric string gets converted to 0
 *   5. resources get casted to int
 */
function cast_for_arithmetic(mixed $value)[]: dynamic ;
/**
 * Does the PHP style behaviour for casting when doing an exponentiation.
 * That happens under the following situations
 *   1. function pointers, and arrays get converted to 0
 *   2. see castForArithmatic
 */
function cast_for_exponent(mixed $value)[]: dynamic ;
/**
 * Does the PHP style behaviour when doing <, <=, >, >=, <=>.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function lt(mixed $l, mixed $r)[]: bool ;/**
 * Does the PHP style behaviour when doing <, <=, >, >=, <=>.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function lte(mixed $l, mixed $r)[]: bool ;/**
 * Does the PHP style behaviour when doing <, <=, >, >=, <=>.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function gt(mixed $l, mixed $r)[]: bool ;/**
 * Does the PHP style behaviour when doing <, <=, >, >=, <=>.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function gte(mixed $l, mixed $r)[]: bool ;/**
 * Does the PHP style behaviour when doing <, <=, >, >=, <=>.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function cmp(mixed $l, mixed $r)[]: int ;
/**
 * Does the PHP style behaviour when doing == or ===.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function eq(mixed $l, mixed $r)[]: bool ;
/**
 * Does the PHP style behaviour when doing == or ===.
 * tl/dr this involves a lot of potential implicit coercions. see
 * __cast_and_compare for the complete picture.
 */
function neq(mixed $l, mixed $r)[]: bool ;
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
function __cast_and_compare(mixed $l, mixed $r, COMPARISON_TYPE $ctype)[]: int ;
const int SWITCH_INT_SENTINEL = 7906240793;

/**
 * Do a modification on the switched value. This is in the case where the
 * switched expr is an ?arraykey
 */
function optional_arraykey_to_int_cast_for_switch(?arraykey $value)[]: int ;
/**
 * Do a modification on the switched value. This is in the case where the
 * switched expr is an ?num
 */
function optional_num_to_int_cast_for_switch(?num $value)[]: int ;
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
)[]: int ;

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
)[]: string ;
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
)[]: string ;
