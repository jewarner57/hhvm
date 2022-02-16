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

use namespace HH\Lib\_Private\_OS;

/** Get a file descriptor for request STDIN.
 *
 * Fails with EBADF if a request-specific file descriptor is not available, for
 * example, when running in HTTP server mode.
 */
function stdin(): FileDescriptor ;
/** Get a file descriptor for request STDOUT.
 *
 * Fails with EBADF if a request-specific file descriptor is not available, for
 * example, when running in HTTP server mode.
 */
function stdout(): FileDescriptor ;
/** Get a file descriptor for request STDERR.
 *
 * Fails with EBADF if a request-specific file descriptor is not available, for
 * example, when running in HTTP server mode.
 */

function stderr(): FileDescriptor ;
