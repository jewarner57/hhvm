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

namespace HH\Lib\OS;

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
  public function __construct(private Errno $errno, string $message) ;
  final public function getErrno(): Errno;
  /** Deprecated for clarity, and potential future ambiguity.
   *
   * In the future, we may have exceptions with multiple 'codes', such as an
   * `errno` and a getaddrinfo `GAI` constant.
   *
   * Keeping logging rate at 0 so that generic code that works on any exception
   * stays happy.
   */
  <<__Deprecated("Use `getErrno()` instead", 0)>>
  final public function getCode()[]: Errno ;}

final class BlockingIOException extends ErrnoException {
  public function __construct(Errno $code, string $message) ;
  public static function _getValidErrnos(): keyset<Errno> ;}

final class ChildProcessException extends ErrnoException {
  public function __construct(string $message) ;
  public static function _getValidErrno(): Errno ;}

abstract class ConnectionException extends ErrnoException {
}

final class BrokenPipeException extends ConnectionException {
  public function __construct(Errno $code, string $message) ;
  public static function _getValidErrnos(): keyset<Errno> ;}

final class ConnectionAbortedException extends ConnectionException {
  public function __construct(string $message) ;
  public static function _getValidErrno(): Errno ;}

final class ConnectionRefusedException extends ConnectionException {
  public function __construct(string $message) ;
  public static function _getValidErrno(): Errno ;}

final class ConnectionResetException extends ConnectionException {
  public function __construct(string $message) ;
  public static function _getValidErrno(): Errno ;}

final class AlreadyExistsException extends ErrnoException {
  public function __construct(string $message) ;
  public static function _getValidErrno(): Errno ;}

final class NotFoundException extends ErrnoException {
  public function __construct(string $message) ;
  public static function _getValidErrno(): Errno ;}

final class IsADirectoryException extends ErrnoException {
  public function __construct(string $message) ;
  public static function _getValidErrno(): Errno ;}

final class IsNotADirectoryException extends ErrnoException {
  public function __construct(string $message) ;
  public static function _getValidErrno(): Errno ;}

final class PermissionException extends ErrnoException {
  public function __construct(Errno $code, string $message) ;
  public static function _getValidErrnos(): keyset<Errno> ;}

final class ProcessLookupException extends ErrnoException {
  public function __construct(string $message) ;
  public static function _getValidErrno(): Errno ;}

final class TimeoutException extends ErrnoException {
  public function __construct(string $message) ;
  public static function _getValidErrno(): Errno ;}

