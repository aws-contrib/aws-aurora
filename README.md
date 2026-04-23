# aurora

> Schema migrations for AWS Aurora DSQL — because [Atlas doesn't support it yet](https://github.com/ariga/atlas/issues/3539).

[![CI](https://github.com/aws-contrib/aws-aurora/actions/workflows/ci.yml/badge.svg)](https://github.com/aws-contrib/aws-aurora/actions/workflows/ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/aws-contrib/aws-aurora?sort=semver)](https://github.com/aws-contrib/aws-aurora/releases/latest)
[![Go Version](https://img.shields.io/github/go-mod/go-version/aws-contrib/aws-aurora)](go.mod)
[![Go Reference](https://pkg.go.dev/badge/github.com/aws-contrib/aws-aurora.svg)](https://pkg.go.dev/github.com/aws-contrib/aws-aurora)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GHCR](https://img.shields.io/badge/container-ghcr.io-blue?logo=github)](https://github.com/aws-contrib/aws-aurora/pkgs/container/aws-aurora)

`aurora` is a CLI tool that brings **schema-as-code migrations** to [AWS Aurora DSQL](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/what-is-aurora-dsql.html). It uses the same HCL config format as [Atlas](https://atlasgo.io/), handles distributed locking, generates IAM auth tokens automatically, and translates PostgreSQL index syntax to Aurora DSQL-compatible equivalents — so your local dev environment and production stay in sync.

## Features

- **Atlas-compatible HCL config** — familiar `env`, `variable`, and `data` blocks
- **IAM token generation** — `data.aws_dsql_token` fetches a signed auth token at runtime
- **Distributed locking** — prevents concurrent migrations across multiple replicas or CI runs
- **Index syntax translation** — rewrites `CONCURRENTLY` to `ASYNC` automatically for Aurora DSQL
- **Idempotent-first design** — each migration is safe to re-run; no drift surprises
- **Multi-platform Docker image** — `linux/amd64` and `linux/arm64` published to GHCR

## Quick Start

### 1. Install

**Docker (recommended)**

```dockerfile
FROM ghcr.io/aws-contrib/aws-aurora:edge AS aurora
FROM scratch

WORKDIR /app
COPY --from=aurora /bin/aurora /app/aurora
```

**From source**

```bash
go install github.com/aws-contrib/aws-aurora/cmd/aurora@latest
```

### 2. Create a config file

Create `aurora.hcl` in your project root:

```hcl
env "aws" {
  migration {
    dir = "file://database/migration"
  }

  url = "postgres://${var.aws_dsql_username}:${urlescape(data.aws_dsql_token.this)}@${var.aws_dsql_host}/mydb"
}

data "aws_dsql_token" "this" {
  username = var.aws_dsql_username
  endpoint = var.aws_dsql_host
  region   = var.aws_region
}

variable "aws_dsql_username" {
  type    = string
  default = "my-service"
}

variable "aws_dsql_host" {
  type    = string
  default = getenv("DATABASE_HOST")
}

variable "aws_region" {
  type    = string
  default = getenv("AWS_REGION")
}
```

### 3. Write migrations

Use **Atlas** to generate migration files, then place them in your migrations directory (e.g. `database/migration/`).

**Migrations must be idempotent** — Aurora DSQL does not allow a single transaction to contain multiple DDL and DML statements, and the CLI executes each statement individually. Write migrations so they can be safely re-applied:

```sql
-- Good: idempotent
CREATE TABLE IF NOT EXISTS users (
  id   UUID PRIMARY KEY,
  name TEXT NOT NULL
);

ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;
```

**Index creation** — use `CONCURRENTLY` locally (runs outside a transaction in PostgreSQL). The CLI translates it to `ASYNC` when running against Aurora DSQL:

```sql
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users (email);
-- Becomes on Aurora DSQL:
-- CREATE INDEX ASYNC IF NOT EXISTS idx_users_email ON users (email);
```

> All SQL statements must end with `;` — the CLI splits migration files on semicolons.

### 4. Apply migrations

```bash
aurora migrate --env aws apply
```

### 5. Check migration status

```bash
# Show current status
aurora migrate --env aws status

# Block until all pending migrations are applied (useful in CI/CD init containers)
aurora migrate --env aws status --wait --wait-timeout 10m
```

## CLI Reference

```
aurora migrate [flags] <command>

Flags:
  --config  Path to config file (default: file://aurora.hcl)
  --env     Environment name from config (required)

Commands:
  apply   Apply all pending migrations
  status  Show migration status

apply flags:
  --lock-timeout  How long to wait for the distributed lock (default: 25m)

status flags:
  --wait          Block until no pending migrations remain
  --wait-timeout  Maximum time to wait (default: 25m)
```

## Development

Dependencies are managed via [Nix](https://nixos.org/) flakes. You can work locally with `nix develop` or inside a Dev Container — both use the same toolchain.

### Nix shell (recommended)

Requires Nix with flakes enabled (`experimental-features = nix-command flakes`).

```bash
nix develop
```

This drops you into a shell with Go, PostgreSQL client tools, and AWS CLI available. You'll need a local PostgreSQL instance — see `$AURORA_DATABASE_URL` for the expected connection string.

### Dev Container

This project ships with a [Dev Container](https://containers.dev/) powered by the [Nix devcontainer feature](https://github.com/devcontainers/features). It installs the same Nix environment and spins up a PostgreSQL service automatically.

```bash
# Open in VS Code with Dev Containers extension installed
code .
# Then: Reopen in Container
```

Once inside the container, a local PostgreSQL instance is available at `127.0.0.1:5432` and `$AURORA_DATABASE_URL` is set automatically. Enter the Nix shell to get the full toolchain:

```bash
nix develop
```

```bash
# Run tests
go tool ginkgo -r

# Run tests with coverage
go tool ginkgo -r -coverprofile=coverprofile.out
```

## Contributing

Contributions are welcome. Please open an issue before submitting a pull request for significant changes.

1. Fork the repo and create a feature branch
2. Run `nix develop` to enter the development environment
3. Write tests for new behaviour
4. Ensure `go tool ginkgo -r` passes
5. Open a PR — the CI pipeline will run tests automatically
