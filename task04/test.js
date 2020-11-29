const child_process = require('child_process');
const fs = require('fs');
const { join } = require('path');
const { readFile } = fs.promises;

const TEST_COUNT = 6;
const COMPILER = 'c++ main.cpp -fopenmp -o main';
const INPUT_DIR = join(__dirname, 'test', 'input');
const OUTPUT_DIR = join(__dirname, 'test', 'output');

function compile() {
  try {
    const compile = child_process.execSync(COMPILER).toString();
    if (compile) console.log(`Compiler output:\n${compile}`);
    return true;
  } catch (e) {
    return false;
  }
}

function test() {
  console.log(new Array(100).join('\n'));
  console.log(`💽 Compiling...`)
  if (!compile()) return console.log(`❌ Compilation failed.`);
  console.log(`💽 Test started at ${new Date().toLocaleTimeString()}`)
  for (let i = 1; i <= TEST_COUNT; i++) runTest(i);
}

function runTest(i) {
  const INPUT_FILE = join(INPUT_DIR, `${i}.txt`);
  const OUTPUT_FILE = join(OUTPUT_DIR, `${i}.txt`);
  const OUTPUT_TEMP_FILE = join(OUTPUT_DIR, `${i}.tmp`);
  const time = Date.now();

  console.log(`🥚 Running test #${i}...`);
  const proc = child_process.spawn('./main', [INPUT_FILE, OUTPUT_TEMP_FILE]);
  let result = '';
  proc.stdout.on('data', (chunk) => result += chunk.toString());
  proc.stderr.on('data', (chunk) => result += chunk.toString());
  proc.on('close', async (code) => {
    try {
      if (code != 0) return printTestFailed(i, `Code: ${code}.\nOutput: ${result}`);
      const expected = (await readFile(OUTPUT_FILE)).toString();
      const given = (await readFile(OUTPUT_TEMP_FILE)).toString();
      if (expected != given) return console.log(`❌ Test #${i} failed.`, `
Expected output:
${expected}

Given output:
${given}

Output:
${result.toString()}`);
      console.log(`✅ Test #${i} finished successfully in ${Date.now() - time}ms.`);
    } catch (e) {
      console.log(`❌ Test #${i} failed.`, 'No output file was generated.');
    }
  });
}

test();
fs.watchFile('./main.cpp', { persistent: true, interval: 100 }, test);