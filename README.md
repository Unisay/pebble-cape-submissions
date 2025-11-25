# Pebble CAPE Submissions

This repository hosts [Pebble](https://github.com/HarmonicLabs/pebble) submission sources for the [UPLC-CAPE benchmark](https://github.com/IntersectMBO/UPLC-CAPE).

## Repository Structure

- `benchmarks/`: Contains the source code for the benchmarks (following CAPE naming conventions).
  - `fibonacci_naive_recursion/`: Naive recursive Fibonacci implementation.
  - `factorial_naive_recursion/`: Naive recursive Factorial implementation.
- `scripts/`: Utility scripts for build process.
  - `flat-to-uplc.js`: Converts UPLC Flat binary format to textual UPLC representation.
- `flake.nix`: Nix flake defining the development environment.
- `package.json`: Node.js project configuration and build scripts.

## Prerequisites

- [Nix](https://nixos.org/download.html) with [flakes enabled](https://nixos.wiki/wiki/Flakes).

## Setup

1. Enter the development shell:

   ```bash
   nix develop
   ```

   This provides `bun`, `nodejs`, and other necessary tools.

2. Install project dependencies (including the Pebble CLI):

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

