# AGENTS.md

This file provides guidance to coding agents (Claude Code, Codex) when working with code in this repository.

## Project Overview

This is a benchmark submission repository for the [UPLC-CAPE benchmark](https://github.com/IntersectMBO/UPLC-CAPE) using the [Pebble programming language](https://github.com/HarmonicLabs/pebble). Pebble is a TypeScript-like language that compiles to UPLC (Untyped Plutus Core) for Cardano smart contracts. The benchmarks are intentionally simple recursive implementations without optimizations to test raw UPLC performance.

## Development Commands

### Setup

```bash
# Enter Nix development shell (provides bun, nodejs, git, aiken)
nix develop

# Install dependencies including Pebble CLI
bun install
```

### Building

```bash
# Build all benchmarks (generates both .flat and .uplc files)
bun run build

# Build individual benchmarks
bun run compile:fib     # fibonacci_naive_recursion.pebble → .flat + .uplc
bun run compile:fact    # factorial_naive_recursion.pebble → .flat + .uplc

# Clean generated files
bun run clean
```

### Build Pipeline

Each compilation script performs three steps:

1. **Pebble → Flat**: Compile Pebble source to UPLC Flat binary format
   ```bash
   pebble export --function-name <fn> --entry <input.pebble>
   ```
   Note: Pebble CLI always outputs to `./out/out.flat` regardless of `--output` flag

2. **Copy Flat**: Copy from Pebble's output location to scenario directory
   ```bash
   cp out/out.flat benchmarks/{scenario}/{scenario}.flat
   ```

3. **Flat → UPLC**: Convert binary to textual UPLC representation using Aiken
   ```bash
   aiken uplc decode benchmarks/{scenario}/{scenario}.flat > benchmarks/{scenario}/{scenario}.uplc
   ```

## Architecture

### Compilation Pipeline

```
.pebble source → Pebble CLI → .flat binary → aiken uplc decode → .uplc textual
                                    ↓
                            UPLC-CAPE execution
```

**Output formats:**
- **`.uplc` files**: Textual UPLC in S-expression syntax (primary output, committed to repo)
- **`.flat` files**: Binary UPLC Flat format (temporary build artifact, gitignored)

**Important**: UPLC-CAPE only uses textual `.uplc` files. The `.flat` files are generated only as an intermediate step because Pebble CLI outputs flat format, which is then converted to textual format using Aiken's `uplc decode` command. Aiken produces standard UPLC S-expression syntax without trailing commas.

### CAPE Naming Conventions

Benchmarks follow CAPE repository conventions:
- **Scenario naming**: `{algorithm}_{optimization_strategy}` (e.g., `fibonacci_naive_recursion`)
- **Directory structure**: One directory per scenario containing all related files
- **File naming**: All files in a scenario directory share the same base name

### Pebble Language Basics

- **Syntax**: TypeScript-like with type annotations
- **Types**: `int`, function return types required
- **Functions**: Standard function syntax with typed parameters
- **Benchmarks**: Naive recursive implementations (no memoization or tail-call optimization)

Example:
```pebble
function fib( n: int ): int {
    if( n <= 1 ) return n;
    return fib( n - 2 ) + fib( n - 1 );
}
```

## Adding New Benchmarks

Follow CAPE naming conventions when adding new scenarios:

1. **Choose scenario name**: Use pattern `{algorithm}_{strategy}` (e.g., `fibonacci_size`, `factorial_exbudget`)

2. **Create directory**: `benchmarks/{scenario_name}/`

3. **Write Pebble source**: `benchmarks/{scenario_name}/{scenario_name}.pebble`

4. **Add compilation script** to `package.json`:
   ```json
   "compile:new": "pebble export --function-name fnName --entry benchmarks/{scenario}/{scenario}.pebble && cp out/out.flat benchmarks/{scenario}/{scenario}.flat && aiken uplc decode benchmarks/{scenario}/{scenario}.flat > benchmarks/{scenario}/{scenario}.uplc"
   ```

5. **Update `build` script**: Add `&& bun run compile:new` to build chain

6. **Update documentation**: Add scenario description to README.md

### Common Optimization Strategies

Based on other CAPE submissions:
- `naive_recursion`: Baseline recursive implementation (current)
- `size`: Code-size optimization
- `exbudget`: Execution budget optimization
- `prepacked`: Pre-computed data optimizations

## Branch Model

UPLC-CAPE pins each Pebble row to a commit of this repository and names a branch in the row's `source/README.md`. Each compiler version has a long-lived branch named `pebble-<version>`:

- `main`: the latest compiler version, currently 0.5.0.
- `pebble-0.5.0`: the branch the 0.5.0 rows name. It has the same history as `main` until `main` moves to the next version.
- `pebble-0.4.4`: frozen at 0.4.4. It contains both 0.4.4 pins, `f8fad765` (fibonacci) and `22089ad1` (factorial).
- `pebble-0.1.2`: frozen at 0.1.2. It contains both 0.1.2 pins, `ebb35dbe` (fibonacci) and `a906d905` (factorial). It still converts flat to text with `scripts/flat-to-uplc.js`, whose output has trailing commas.

Never delete or rebase these branches: a fresh clone cannot check out an unreachable pin. Do not move an old branch to newer tooling, because its job is to rebuild the exact UPLC that UPLC-CAPE pins. A fix that applies to several versions, such as a source bug, lands on each affected branch as its own commit, and each affected CAPE row is re-pinned.

To bump the compiler, do the bump on a feature branch, fast-forward `main` to it, and create `pebble-<new version>` at the new `main` head.

## Key Dependencies

- `@harmoniclabs/pebble-cli` (v0.5.0, pinned exactly) - Pebble to UPLC compiler. Its output cases on built-in `Bool`, which needs protocol version 11 (van Rossem); `aiken uplc eval` cannot run it
- `aiken` (v1.1.19) - Cardano smart contract platform providing UPLC tools
- Bun runtime for fast package management and script execution
- Nix flake for reproducible development environment

## UPLC Conversion

The build pipeline uses Aiken's `uplc decode` command to convert UPLC Flat binary format to textual representation:
- Produces standard UPLC S-expression syntax
- No trailing commas (compliant with UPLC standards)
- Outputs in `(program VERSION ...)` format matching CAPE conventions
- Handles all UPLC constructs: lambdas, applications, builtins, constants, etc.
