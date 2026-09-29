---
name: ledger-e2e
description: Run the ledger e2e suite (kafka → bridge → engine → db) against the local Tilt/kind dev env to verify bridge/engine changes, happy-path ingest, and engine-down no-loss behavior. Use when asked to "verify" engine/bridge work end-to-end, run the e2e suite, or check failure behavior.
---

# Ledger e2e verification

`~/Documents/GitHub/ledger-dev-bootstrap/e2e/` verifies the full ingest path in
the local Tilt/kind env (cluster `ledger-dev`, ns `ledger`): events published
to kafka are forwarded by ledger-bridge to ledger-engine and land as
`ledger_movement`/`ledger_entry` rows in postgres — plus the outage contract:
engine down ⇒ offsets stay uncommitted, no DLT, no crashloop; recovery ⇒ full
drain, exactly once, per-owner order. Check-by-check coverage and scope
boundaries: `e2e/TESTS.md`.

## Preflight — check before running

1. `tilt up` is running: `curl -sf localhost:8080/actuator/health` and
   `curl -sf localhost:8081/monitor/health` must both answer. If not, tell the
   user to start Tilt — don't try to fix the environment by hand.
2. `kubectl config current-context` starts with `kind-ledger-dev`.
3. Tools: `kubectl jq curl psql uuidgen`.

`run-all.sh` preflights again itself and exits 2 with a pointed message if
anything is missing.

## Run

```bash
bash ~/Documents/GitHub/ledger-dev-bootstrap/e2e/run-all.sh   # whole suite (~1 min)
bash ~/Documents/GitHub/ledger-dev-bootstrap/e2e/scenarios/01-happy-path.sh   # single scenario
```

- Exit 0 only if every scenario passes. Output is per-check PASS/FAIL lines —
  summarize failures, don't dump the full log back. The full output is kept in
  `e2e/runs/<ts>-<runId>.log` (gitignored) for later `inspect.sh`/grepping.
- Scenario 02 scales the engine to 0 and always scales it back (EXIT trap),
  even on failure or Ctrl-C.
- One suite at a time — concurrent runs share the bridge's consumer group and
  counter deltas, so they false-fail.

## Inspect what a run produced

`bash e2e/inspect.sh [runId]` (default: the runId saved in `e2e/runs/.last-run`)
prints every artifact —
movements, entry legs, wallets/balances, failed ingests, raw kafka events —
one record per line prefixed `MOVEMENT |`, `ENTRY |`, `WALLET |`, `FAILED |`,
`KAFKA |`, ending with a `COUNTS` line. Grep by eventId: `inspect.sh <rid> |
grep evt-<rid>-hp-a1`. When investigating a red run, this is the first place
to look — it shows whether events reached kafka, the DB, or the fail queue.

## After changing bridge/engine code (the main loop)

1. Tilt rebuilds on save — wait for the resource to go green
   (`kubectl -n ledger rollout status deploy/ledger-bridge` or `.../ledger-engine`;
   engine boots with deferred DB init, so "green" ≠ "ready" for a few seconds).
2. Run the suite. Engine needs ~30–60s after scale-up in scenario 02; the
   suite waits — you don't need to.

## Interpreting failures

| Symptom | Where to look |
|---|---|
| forwarded counters not advancing / lag stuck | `kubectl -n ledger logs deploy/ledger-bridge --tail=100`; `curl -s localhost:8081/monitor/health \| jq` |
| movements missing / amounts wrong | `kubectl -n ledger logs deploy/ledger-engine --tail=200`; `failed_transaction_ingest` rows (`NO_RULE` = rules not seeded → re-run `ledger-engine/scripts/bootstrap-runtime.sh` with `BASE_URL=http://localhost:8080`) |
| DLT counter > 0 | poison message — inspect: `kubectl -n ledger exec deploy/kafka -- /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic ledger.transaction.events.DLT --from-beginning --max-messages 5` |
| "committed offsets NOT advancing" FAILS on a healthy run | something else is committing offsets (another consumer in group `ledger-bridge`) |
| bridge counters reset mid-run | bridge restarted (Tilt rebuild mid-run) — rerun after the rebuild settles |

Reproduce with the single failing scenario first; only look at service logs
once you know which scenario/phase went red.

Do **not** weaken an assertion or hand-tweak the environment to make a red
suite green — a red check means the flow (or the test's assumption) needs
investigating. If a check is genuinely wrong (drifted API/schema), fix the
harness and say so in the summary.
