const fs = require('fs');

const random100 = () => Array.from(new Array(100), () => Math.round(Math.random() * 100)).sort((a, b) => a - b);

fs.writeFileSync("./test/input/6.txt", `${random100().join(' ')}
${random100().join(' ')}`);