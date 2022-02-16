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
)[]: T ;
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
)[]: T ;
/**
 * Returns whether a num is NAN.
 * NAN is "the not-a-number special float value"
 *
 * When comparing NAN to any value (including NAN) using operators
 * false will be returned. `NAN === NAN` is false.
 *
 * One must always check for NAN using `is_nan` and not `$x === NAN`.
 */
function is_nan(num $num)[]: bool ;
/**
 * Compares two numbers to see if they are within epsilon of each other.
 * If the difference equals epsilon this returns false.
 *
 * default epsilon of .00000001.
 *
 * When comparing large numbers consider passing in a large epsilon
 */
function almost_equals(num $num_one, num $num_two, num $epsilon = .00000001)[]: bool;
