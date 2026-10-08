# Pebble CAPE Submissions

This repository hosts [Pebble](https://github.com/HarmonicLabs/pebble) submission sources for the [UPLC-CAPE benchmark](https://github.com/IntersectMBO/UPLC-CAPE).

## Repository Structure

- `benchmarks/`: Contains the source code for the benchmarks (following CAPE naming conventions).
  - `fibonacci_naive_recursion/`: Naive recursive Fibonacci implementation.
  - `factorial_naive_recursion/`: Naive recursive Factorial implementation.
- `flake.nix`: Nix flake defining the development environment.
- `package.json`: Node.js project configuration and build scripts.

## Prerequisites

- [Nix](https://nixos.org/download.html) with [flakes enabled](https://nixos.wiki/wiki/Flakes).

## Setup

1. Enter the development shell:

   ```bash
   nix develop
   ```

   This provides `bun`, `nodejs`, `aiken`, and other necessary tools.

2. Install project dependencies (including the Pebble CLI, pinned to 0.4.4):

   ```bash
   bun install
   ```

## Building Benchmarks

To compile the benchmark sources into both UPLC Flat (binary) and textual UPLC formats:

```bash
bun run build
```

This will generate `.uplc` files (textual UPLC format) in the respective benchmark directories:
- `benchmarks/fibonacci_naive_recursion/fibonacci_naive_recursion.uplc`
- `benchmarks/factorial_naive_recursion/factorial_naive_recursion.uplc`

Note: `.flat` files (binary format) are generated as intermediate build artifacts but are not committed (excluded via `.gitignore`).

You can also compile them individually:

```bash
bun run compile:fib
bun run compile:fact
```

To clean generated files:

```bash
bun run clean
```

## Output Formats

- **`.uplc` files**: Human-readable textual UPLC representation in S-expression syntax (primary output for CAPE benchmarking)
- **`.flat` files**: Binary UPLC Flat format, generated as intermediate build artifact (gitignored, not committed)

## Protocol Version

Pebble 0.4.4 compiles `if` to a `case` on the built-in `Bool` that `lessThanInteger` returns. Casing on built-in types needs protocol version 11 (van Rossem), so the UPLC runs only on an evaluator that supports it, such as the one in UPLC-CAPE. `aiken uplc eval` from Aiken 1.1.19 rejects it with `attempted to case a non-const`. The build uses Aiken only for `aiken uplc decode`, which is not affected.
