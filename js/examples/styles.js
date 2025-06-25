const { Tracer } = require('../tracer.js');

async function simulateWork(tracer) {
    tracer.span('Load configuration');
    await new Promise(resolve => setTimeout(resolve, 25));

    tracer.span('Connect to database');
    await new Promise(resolve => setTimeout(resolve, 75));

    tracer.span('Execute complex query');
    await new Promise(resolve => setTimeout(resolve, 120));

    tracer.span('Process results');
    await new Promise(resolve => setTimeout(resolve, 45));

    tracer.span('Cache data');
    await new Promise(resolve => setTimeout(resolve, 15));

    tracer.span('Generate response');
    await new Promise(resolve => setTimeout(resolve, 8));
}

async function main() {
    const styles = [
        { name: 'Default', style: 'default' },
        { name: 'Colorful', style: 'colorful' },
        { name: 'Minimal', style: 'minimal' },
        { name: 'Detailed', style: 'detailed' },
        { name: 'Table', style: 'table' },
        { name: 'JSON', style: 'json' }
    ];

    for (const s of styles) {
        console.log(`\n\x1b[1;36m=================== ${s.name.toUpperCase()} STYLE ===================\x1b[0m`);

        const tracer = new Tracer(`API Processing - ${s.name} Style`, {
            style: s.style
        });

        await simulateWork(tracer);
        tracer.end();

        await new Promise(resolve => setTimeout(resolve, 500)); // Brief pause between styles
    }
}

main().catch(console.error); 