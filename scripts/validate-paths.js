#!/usr/bin/env node

/**
 * 🔍 Validate Paths Script
 * 
 * בדוק את כל הקבצים בפרויקט:
 * 1. Relative paths ארוכים מדי (יותר מ-3 levels)
 * 2. Hardcoded Windows paths
 * 3. Mixed path separators (Windows vs Unix)
 * 
 * שימוש: npm run validate:paths
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Colors for terminal
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  gray: '\x1b[90m',
};

const log = {
  error: (msg) => console.log(`${colors.red}🔴 ${msg}${colors.reset}`),
  warn: (msg) => console.log(`${colors.yellow}🟡 ${msg}${colors.reset}`),
  success: (msg) => console.log(`${colors.green}✅ ${msg}${colors.reset}`),
  info: (msg) => console.log(`${colors.blue}ℹ️  ${msg}${colors.reset}`),
  debug: (msg) => console.log(`${colors.gray}${msg}${colors.reset}`),
};

// Configuration
const PROJECT_ROOT = 'C:\\projects\\salsheli';
const DART_EXTENSIONS = ['.dart'];
const IGNORE_PATTERNS = [
  'node_modules/',
  '.git/',
  'build/',
  '.dart_tool/',
  'coverage/',
  '*.g.dart', // Generated files
];

// Statistics
let stats = {
  totalFiles: 0,
  filesChecked: 0,
  errorCount: 0,
  warningCount: 0,
};

/**
 * Get all Dart files in project
 */
function getAllDartFiles(dir) {
  let files = [];

  try {
    const items = fs.readdirSync(dir);

    items.forEach((item) => {
      const fullPath = path.join(dir, item);
      const stat = fs.statSync(fullPath);

      // Skip ignored patterns
      if (IGNORE_PATTERNS.some((pattern) => fullPath.includes(pattern))) {
        return;
      }

      if (stat.isDirectory()) {
        files = files.concat(getAllDartFiles(fullPath));
      } else if (DART_EXTENSIONS.includes(path.extname(item))) {
        files.push(fullPath);
      }
    });
  } catch (err) {
    log.warn(`Cannot read directory: ${dir}`);
  }

  return files;
}

/**
 * Validate single file
 */
function validateFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.split('\n');
    const relativePath = path.relative(PROJECT_ROOT, filePath);

    let fileErrors = [];
    let fileWarnings = [];

    lines.forEach((line, lineNum) => {
      const lineNumber = lineNum + 1;

      // ❌ Pattern 1: Relative paths ארוכים (יותר מ-3 levels)
      const relativeDeepPattern = /import\s+['"]\.\.\/\.\.\/\.\.\/[\w\/\-_.]+\.dart['"];/;
      if (relativeDeepPattern.test(line)) {
        fileErrors.push({
          line: lineNumber,
          type: 'DEEP_RELATIVE_PATH',
          message: 'Relative path too deep (3+ levels)',
          code: line.trim(),
        });
      }

      // ❌ Pattern 2: Hardcoded Windows paths
      const windowsPathPattern = /C:\\[\\\/\w\-_.\/]+/;
      if (windowsPathPattern.test(line) && !line.includes('projects/salsheli')) {
        fileWarnings.push({
          line: lineNumber,
          type: 'HARDCODED_WINDOWS_PATH',
          message: 'Hardcoded Windows path detected',
          code: line.trim(),
        });
      }

      // ❌ Pattern 3: C:\Users path (personal machine path!)
      if (line.includes('C:\\Users\\')) {
        fileErrors.push({
          line: lineNumber,
          type: 'PERSONAL_MACHINE_PATH',
          message: 'Personal machine path detected',
          code: line.trim(),
        });
      }

      // ⚠️ Pattern 4: Mixed path separators
      if (line.includes('/') && line.includes('\\') && !line.includes('http')) {
        fileWarnings.push({
          line: lineNumber,
          type: 'MIXED_PATH_SEPARATORS',
          message: 'Mixed path separators (/ and \\)',
          code: line.trim(),
        });
      }

      // ⚠️ Pattern 5: Potential relative path that might break
      const suspiciousRelativePattern = /import\s+['"]\.\.\/[\w\/\-_.]+\.dart['"];/;
      if (suspiciousRelativePattern.test(line)) {
        // Only warn if it's going up multiple levels
        const level = (line.match(/\.\.\//g) || []).length;
        if (level > 2) {
          fileWarnings.push({
            line: lineNumber,
            type: 'RELATIVE_PATH_WARNING',
            message: `Relative import going up ${level} levels`,
            code: line.trim(),
          });
        }
      }
    });

    // Report errors
    if (fileErrors.length > 0) {
      log.error(`\n${relativePath}`);
      fileErrors.forEach((err) => {
        log.error(`  Line ${err.line}: [${err.type}] ${err.message}`);
        log.debug(`    ${err.code}`);
      });
      stats.errorCount += fileErrors.length;
    }

    // Report warnings
    if (fileWarnings.length > 0) {
      log.warn(`\n${relativePath}`);
      fileWarnings.forEach((warn) => {
        log.warn(`  Line ${warn.line}: [${warn.type}] ${warn.message}`);
        log.debug(`    ${warn.code}`);
      });
      stats.warningCount += fileWarnings.length;
    }
  } catch (err) {
    log.error(`Error reading file: ${filePath} - ${err.message}`);
    stats.errorCount++;
  }
}

/**
 * Main validation
 */
function main() {
  log.info('\n🔍 Starting path validation...\n');

  try {
    const dartFiles = getAllDartFiles(PROJECT_ROOT);
    stats.totalFiles = dartFiles.length;

    if (dartFiles.length === 0) {
      log.warn('No Dart files found!');
      process.exit(1);
    }

    log.info(`Found ${dartFiles.length} Dart files\n`);

    dartFiles.forEach((file, index) => {
      validateFile(file);
      stats.filesChecked++;

      // Show progress every 20 files
      if ((index + 1) % 20 === 0) {
        log.debug(`Progress: ${index + 1}/${dartFiles.length}`);
      }
    });

    // Print summary
    console.log(`\n${'='.repeat(60)}`);
    log.info(`📊 VALIDATION SUMMARY`);
    console.log(`${'='.repeat(60)}`);
    log.info(`Files checked: ${stats.filesChecked}/${stats.totalFiles}`);

    if (stats.errorCount > 0) {
      log.error(`Errors found: ${stats.errorCount}`);
    } else {
      log.success(`No errors found!`);
    }

    if (stats.warningCount > 0) {
      log.warn(`Warnings found: ${stats.warningCount}`);
    } else {
      log.success(`No warnings found!`);
    }

    console.log(`${'='.repeat(60)}\n`);

    // Exit with appropriate code
    if (stats.errorCount > 0) {
      process.exit(1);
    } else {
      process.exit(0);
    }
  } catch (err) {
    log.error(`Fatal error: ${err.message}`);
    process.exit(1);
  }
}

// Run
main();
