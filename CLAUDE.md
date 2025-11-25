# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a benchmark submission repository for the [UPLC-CAPE benchmark](https://github.com/IntersectMBO/UPLC-CAPE) using the [Pebble programming language](https://github.com/HarmonicLabs/pebble). Pebble is a TypeScript-like language that compiles to UPLC (Untyped Plutus Core) for Cardano smart contracts. The benchmarks are intentionally simple recursive implementations without optimizations to test raw UPLC performance.

## Development Commands

### Setup

```bash
# Enter Nix development shell (provides bun, nodejs, git)
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

3. **Flat → UPLC**: Convert binary to textual UPLC representation
   ```bash
   node scripts/flat-to-uplc.js benchmarks/{scenario}/{scenario}.flat benchmarks/{scenario}/{scenario}.uplc
   ```

## Architecture

### Compilation Pipeline

```
.pebble source → Pebble CLI → .flat binary → flat-to-uplc.js → .uplc textual
                                    ↓
                            UPLC-CAPE execution
```

**Output formats:**
- **`.uplc` files**: Textual UPLC in S-expression syntax (primary output, committed to repo)
- **`.flat` files**: Binary UPLC Flat format (temporary build artifact, gitignored)

**Important**: UPLC-CAPE only uses textual `.uplc` files. The `.flat` files are generated only as an intermediate step because Pebble CLI outputs flat format, which is then converted to textual format.

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
   "compile:new": "pebble export --function-name fnName --entry benchmarks/{scenario}/{scenario}.pebble --output benchmarks/{scenario}/{scenario}.flat && node scripts/flat-to-uplc.js benchmarks/{scenario}/{scenario}.flat benchmarks/{scenario}/{scenario}.uplc"
   ```

5. **Update `build` script**: Add `&& bun run compile:new` to build chain

6. **Update documentation**: Add scenario description to README.md

### Common Optimization Strategies

Based on other CAPE submissions:
- `naive_recursion`: Baseline recursive implementation (current)
- `size`: Code-size optimization
- `exbudget`: Execution budget optimization
- `prepacked`: Pre-computed data optimizations

## Key Dependencies

- `@harmoniclabs/pebble-cli` (v0.1.2) - Pebble to UPLC compiler
- `@harmoniclabs/uplc` - UPLC parsing and pretty-printing (used by flat-to-uplc.js)
- Bun runtime for fast package management and script execution
- Nix flake for reproducible development environment

## Conversion Tool

The `scripts/flat-to-uplc.js` utility converts UPLC Flat binary format to textual representation:
- Uses `@harmoniclabs/uplc` library's `parseUPLC()` and `prettyUPLC()` functions
- Wraps output in `(program VERSION ...)` format matching CAPE conventions
- Handles all UPLC constructs: lambdas, applications, builtins, constants, etc.
