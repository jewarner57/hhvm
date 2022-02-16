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

namespace HH\Lib\Async;

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
  final public static function create(): this ;
  final protected static function fromImpl(
    KeyedTraversable<Tk, Awaitable<Tv>> $awaitables,
  ): this ;
  private ?ConditionNode<(Tk, Tv)> $lastAdded;
  private ?ConditionNode<(Tk, Tv)> $lastNotified;
  private ?ConditionNode<(Tk, Tv)> $lastAwaited;
  private Awaitable<void> $notifiers;

  private function __construct() ;
  final protected function addImpl(Tk $key, Awaitable<Tv> $awaitable): void ;
  final protected function addMultiImpl(
    KeyedTraversable<Tk, Awaitable<Tv>> $awaitables,
  ): void ;
  <<__ProvenanceSkipFrame>>
  private async function waitForThenNotify(
    Tk $key,
    Awaitable<Tv> $awaitable,
  ): Awaitable<void> ;
  <<__ProvenanceSkipFrame>>
  final public async function next(): Awaitable<?(Tk, Tv)> ;
  final public function hasNext(): bool ;}

