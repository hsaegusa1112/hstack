---
name: agentmap
description: Show a live map of every local TCP listener attributed to its repo/worktree and service (tilt engine/bridge/postgres, agent-spawned services in worktrees), with health probes and collision warnings. Use before or after running e2e/smoke tests, when smoke results look poisoned, or after agents have been spinning things up and you need to know what is actually listening and where it belongs.
---

# agentmap

`scripts/agentmap` lists every TCP listener, attributes it to a repo/worktree
(process cwd × `git worktree list` — dir names alone don't determine the
branch), names known services, probes health, and flags collisions.
Read-only; safe to run any time.

## Run

```bash
bash ~/.claude/skills/agentmap/scripts/agentmap             # table + warnings
bash ~/.claude/skills/agentmap/scripts/agentmap --json      # for scripts/agents
bash ~/.claude/skills/agentmap/scripts/agentmap --no-probe  # skip health curls
bash ~/.claude/skills/agentmap/scripts/agentmap --all       # include system-app listeners
bash ~/.claude/skills/agentmap/scripts/agentmap [root]      # default ~/Documents/GitHub
```

```text
NODE                                SERVICE           PORT   BRANCH                            STATUS
platform                            postgres-compose  5433   -                                 com.docker.backend
ledger-dev-bootstrap                engine            8080   main                              ✓ /actuator/health → postgres:5432 (tilt)
ledger-dev-bootstrap                bridge            8081   main                              ✓ /monitor/health → engine:8080 (tilt)
ledger-dev-bootstrap                postgres-tilt     5432   main                              tilt
ledger-dev-bootstrap                tilt-ui           10350  main                              ✓ / (tilt)
ledger-engine-burn-no-wallet-tests  -                 18998  fix/ingest-failure-parks-not-500  Python

(+7 other system listeners — --all to show)

⚠ unknown service Python on :18998 in ledger-engine-burn-no-wallet-tests
```

## Known service table

| port | service | notes |
|---|---|---|
| 8080 | engine | `/actuator/health`; tilt forward vs engine docker-compose both want it |
| 8081 | bridge | `/monitor/health`; edge → engine:8080 |
| 5432 | postgres (tilt) | |
| 5433 | postgres (engine-compose) | |
| 3000 | portal | usually disabled |
| 10350 | tilt UI | |
| 8899 | kubeview | usually disabled |
| 9092 | kafka | tilt kafka is in-cluster only — a host listener here is always a warning |

## Warnings

| Warning | Meaning |
|---|---|
| tilt is up but :N is held by X | that tilt port-forward lost the port — e2e/smoke results against :N are testing X, not tilt. Fix before trusting any run. |
| bridge → engine:8080 but nothing on 8080 | orphaned bridge |
| engine up but no postgres listener | engine can't reach a DB |
| two postgres stacks up | tilt + engine-compose both running — check which one the engine uses |
| kafka on host :9092 | someone bypassed the in-cluster convention |
| unknown service in a ledger worktree | an agent-spawned service on a nonstandard port — this is the "bridge on :9901" case |
| unattributed listener | listening from a directory under home but outside the workspace root; likely a stray agent artifact |

## Limits

- Dependency edges are declared defaults (bridge→engine:8080). It cannot read
  another process's env (macOS), so a bridge started with `ENGINE_BASE_URL`
  overridden still shows the default edge.
- Services whose port is published by Docker/OrbStack show under node
  `platform` without a worktree — the publish proxy owns the listener.
- Attribution is cwd-based: a service started from a worktree directory but
  immediately chdir'ing elsewhere may land unattributed.
