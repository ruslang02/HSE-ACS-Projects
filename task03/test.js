const child_process = require('child_process');
const fs = require('fs');
const { readFile } = fs.promises;

const TEST_COUNT = 1;

function compile() {
    try {
        const compile = child_process.execSync('c++ main.cpp -o main -pthread').toString();
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
    for (let i = 1; i <= TEST_COUNT; i++) {
        printTestRunning(i);
        const time = Date.now();
        const proc = child_process.spawn('./main', [
            `./test/input/${i}.txt`,
            `./test/output/${i}.tmp`
        ]);
        let result = '';
        proc.stdout.on('data', (chunk) => result += chunk.toString());
        proc.stderr.on('data', (chunk) => result += chunk.toString());
        proc.on('close', async (code) => {
            if (code != 0) return printTestFailed(i, `Code: ${code}.\nOutput: ${result}`);
            const expected = await readFile(`./test/output/${i}.txt`);
            const given = await readFile(`./test/output/${i}.tmp`);
            if (expected != given) return printTestFailed(i, `Expected output:\n"${expected}"\n\nGiven output: "${given}"`);
            printTestSuccessful(i, Date.now() - time);
        });
    }
}

function printTestRunning(i) {
    console.log(`🥚 Running test #${i}...`);
}

function printTestSuccessful(i, time) {
    console.log(`✅ Test #${i} finished successfully in ${time}.`);
}

function printTestFailed(i, message) {
    console.log(`❌ Test #${i} failed.`);
    console.log(message);
}

test();
fs.watchFile('./main.cpp', {persistent: true, interval: 100}, function () {
    // if (timer) return;
    // timer = setTimeout(() => {
        test();
    //    timer = undefined;
    // }, 500);
});