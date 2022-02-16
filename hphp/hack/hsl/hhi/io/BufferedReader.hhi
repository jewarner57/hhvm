<?hh
// @generated from implementation

/*
 *  Copyright (c) 2017-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the hphp/hsl/ subdirectory of this source tree.
 *
 */

/* @lint-ignore-every AWAIT_IN_LOOP */

namespace HH\Lib\IO;

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

  public function __construct(private IO\ReadHandle $handle) ;
  public function getHandle(): IO\ReadHandle ;
  private bool $eof = false;
  private string $buffer = '';

  // implementing interface
  public function readImpl(?int $max_bytes = null): string ;
  public async function readAllowPartialSuccessAsync(
    ?int $max_bytes = null,
    ?int $timeout_ns = null,
  ): Awaitable<string> ;
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
  public async function readUntilAsync(string $suffix): Awaitable<?string> ;
  /** Read until the suffix, or raise EPIPE if the separator is not seen.
   *
   * This is similar to `readUntilAsync()`, however it raises EPIPE instead
   * of returning null.
   */
  public async function readUntilxAsync(string $suffix): Awaitable<string> ;
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
  public async function readLineAsync(): Awaitable<?string> ;
  /** Read a line or throw EPIPE.
   *
   * @see `readLineAsync()` for details.
   */
  public async function readLinexAsync(): Awaitable<string> ;
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
  public function linesIterator(): AsyncIterator<string> ;
  <<__Override>> // from trait
  public async function readFixedSizeAsync(
    int $size,
    ?int $timeout_ns = null,
  ): Awaitable<string> ;
  /** Read a single byte from the handle.
   *
   * Fails with EPIPE if the handle is closed or otherwise unreadable.
   */
  public async function readByteAsync(
    ?int $timeout_ns = null,
  ): Awaitable<string> ;
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
  public function isEndOfFile(): bool ;
  private async function fillBufferAsync(
    ?int $desired_bytes,
    ?int $timeout_ns,
  ): Awaitable<void> ;}

