#!/usr/bin/env node

/**
 * Converts UPLC Flat binary format to textual UPLC representation
 * Usage: node scripts/flat-to-uplc.js <input.flat> <output.uplc>
 */

import { readFileSync, writeFileSync } from 'fs';
import { parseUPLC, prettyUPLC } from '@harmoniclabs/uplc';

function convertFlatToUplc(inputPath, outputPath) {
  try {
    // Read flat binary file
    const flatBytes = readFileSync(inputPath);

    // Parse flat format to UPLC program
    const program = parseUPLC(flatBytes, "flat");

    // Create textual representation with program wrapper
    const version = `${program.version.major}.${program.version.minor}.${program.version.patch}`;
    const bodyText = prettyUPLC(program.body, 2);

    // Wrap in program declaration
    const uplcText = `(program ${version}\n${bodyText}\n)`;

    // Write to output file
    writeFileSync(outputPath, uplcText, 'utf8');

    console.log(`✓ Converted ${inputPath} → ${outputPath}`);
  } catch (error) {
    console.error(`✗ Error converting ${inputPath}:`, error.message);
    process.exit(1);
  }
}

// Parse command line arguments
const args = process.argv.slice(2);
if (args.length !== 2) {
  console.error('Usage: node scripts/flat-to-uplc.js <input.flat> <output.uplc>');
  process.exit(1);
}

const [inputPath, outputPath] = args;
convertFlatToUplc(inputPath, outputPath);
