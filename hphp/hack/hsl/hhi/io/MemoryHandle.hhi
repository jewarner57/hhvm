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

namespace HH\Lib\IO;

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
  ) ;
  public function close(): void ;
  <<__ReturnDisposable>>
  public function closeWhenDisposed(): \IDisposable ;
  public async function readAllowPartialSuccessAsync(
    ?int $max_bytes = null,
    ?int $_timeout_nanos = null,
  ): Awaitable<string> ;
  public function readImpl(?int $max_bytes = null): string ;
  public function seek(int $pos): void ;
  public function tell(): int ;
  protected function writeImpl(string $data): int ;
  public async function writeAllowPartialSuccessAsync(
    string $data,
    ?int $timeout_nanos = null,
  ): Awaitable<int> ;
  public function getBuffer(): string ;
  /** Set the internal buffer and reset position to the beginning of the file.
   *
   * If you wish to preserve the position, use `tell()` and `seek()`,
   * or `appendToBuffer()`.
   */
  public function reset(string $data = ''): void ;
  /** Append data to the internal buffer, preserving position.
   *
   * @see `write()` if you want the offset to be changed.
   */
  public function appendToBuffer(string $data): void ;
  private function checkIsOpen(): void ;}

