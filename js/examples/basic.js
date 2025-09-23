const { Tracer } = require('../tracer.js');

async function main() {
    // Basic usage với default style
    const tracer = new Tracer('Basic Example');

    await new Promise(resolve => setTimeout(resolve, 30));
    tracer.span('Initialize database');

    await new Promise(resolve => setTimeout(resolve, 50));
    tracer.span('Load user data');

    await new Promise(resolve => setTimeout(resolve, 20));
    tracer.span('Process data');

    await new Promise(resolve => setTimeout(resolve, 10));
    tracer.span('Generate response');

    tracer.end();
}

main().catch(console.error); 