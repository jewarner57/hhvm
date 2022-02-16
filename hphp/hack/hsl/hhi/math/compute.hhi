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

namespace HH\Lib\Math;
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
function abs<T as num>(T $number)[]: T ;
/**
 * Converts the given string in base `$from_base` to base `$to_base`, assuming
 * letters a-z are used for digits for bases greater than 10. The conversion is
 * done to arbitrary precision.
 *
 * - To convert a string in some base to an int, see `Math\from_base()`.
 * - To convert an int to a string in some base, see `Math\to_base()`.
 */
function base_convert(string $value, int $from_base, int $to_base)[rx_local]: string ;
/**
 * Returns the smallest integer value greater than or equal to $value.
 *
 * To find the largest integer value less than or equal to `$value`, see
 * `Math\floor()`.
 */
function ceil(num $value)[]: float ;
/**
 * Returns the cosine of `$arg`.
 *
 * - To find the sine, see `Math\sin()`.
 * - To find the tangent, see `Math\tan()`.
 */
function cos(num $arg)[]: float ;
/**
 * Converts the given string in the given base to an int, assuming letters a-z
 * are used for digits when `$from_base` > 10.
 *
 * To base convert an int into a string, see `Math\to_base()`.
 */
function from_base(string $number, int $from_base)[]: int ;
/**
 * Returns e to the power `$arg`.
 *
 * To find the logarithm, see `Math\log()`.
 */
function exp(num $arg)[]: float ;
/**
 * Returns the largest integer value less than or equal to `$value`.
 *
 * - To find the smallest integer value greater than or equal to `$value`, see
 *   `Math\ceil()`.
 * - To find the largest integer value less than or equal to a ratio, see
 *   `Math\int_div()`.
 */
function floor(num $value)[]: float ;
/**
 * Returns the result of integer division of `$numerator` by `$denominator`.
 *
 * To round a single value, see `Math\floor()`.
 */
function int_div(int $numerator, int $denominator)[]: int ;
/**
 * Returns the logarithm base `$base` of `$arg`.
 *
 * For the exponential function, see `Math\exp()`.
 */
function log(num $arg, ?num $base = null)[]: float ;
/**
 * Returns the given number rounded to the specified precision. A positive
 * precision rounds to the nearest decimal place whereas a negative precision
 * rounds to the nearest power of ten. For example, a precision of 1 rounds to
 * the nearest tenth whereas a precision of -1 rounds to the nearest ten.
 */
function round(num $val, int $precision = 0)[]: float ;
/**
 * Returns the sine of $arg.
 *
 * - To find the cosine, see `Math\cos()`.
 * - To find the tangent, see `Math\tan()`.
 */
function sin(num $arg)[]: float ;
/**
 * Returns the square root of `$arg`.
 */
function sqrt(num $arg)[]: float ;
/**
 * Returns the tangent of `$arg`.
 *
 * - To find the cosine, see `Math\cos()`.
 * - To find the sine, see `Math\sin()`.
 */
function tan(num $arg)[]: float ;
/**
 * Converts the given non-negative number into the given base, using letters a-z
 * for digits when `$to_base` > 10.
 *
 * To base convert a string to an int, see `Math\from_base()`.
 */
function to_base(int $number, int $to_base)[rx_shallow]: string ;
