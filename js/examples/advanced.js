const { Tracer } = require('../tracer.js');

async function main() {
    // Advanced usage với smart filtering
    const tracer = new Tracer('Advanced Example', {
        style: 'detailed',
        hideUltraFast: 1,      // ms
        showSlowOnly: 10,      // ms  
        groupSimilar: 5,       // ms
        minTotalDuration: 50   // ms
    });

    // Simulate database operations
    await new Promise(resolve => setTimeout(resolve, 100));
    tracer.span('Connect to database');

    await new Promise(resolve => setTimeout(resolve, 45));
    tracer.span('Execute query 1');

    await new Promise(resolve => setTimeout(resolve, 50)); // Similar to query 1
    tracer.span('Execute query 2');

    await new Promise(resolve => setTimeout(resolve, 5));
    tracer.span('Cache result');

    await new Promise(resolve => setTimeout(resolve, 0.5)); // Will be hidden
    tracer.span('Ultra fast operation');

    await new Promise(resolve => setTimeout(resolve, 200));
    tracer.span('Process business logic');

    await new Promise(resolve => setTimeout(resolve, 30));
    tracer.span('Send notification');

    tracer.end();
}

main().catch(console.error); 