const { Tracer } = require('../tracer.js');

async function simulateVariousOperations(tracer) {
    // Ultra fast operations
    await new Promise(resolve => setTimeout(resolve, 0.5));
    tracer.span('Ultra fast operation 1');

    await new Promise(resolve => setTimeout(resolve, 0.8));
    tracer.span('Ultra fast operation 2');

    // Fast operations
    await new Promise(resolve => setTimeout(resolve, 5));
    tracer.span('Fast validation');

    await new Promise(resolve => setTimeout(resolve, 8));
    tracer.span('Quick lookup');

    // Medium operations
    await new Promise(resolve => setTimeout(resolve, 45));
    tracer.span('Medium processing');

    await new Promise(resolve => setTimeout(resolve, 48)); // Similar to above
    tracer.span('Similar processing');

    await new Promise(resolve => setTimeout(resolve, 44)); // Also similar
    tracer.span('Another similar task');

    // Slow operations
    await new Promise(resolve => setTimeout(resolve, 150));
    tracer.span('Slow database query');

    await new Promise(resolve => setTimeout(resolve, 200));
    tracer.span('Complex computation');

    // Very slow operation
    await new Promise(resolve => setTimeout(resolve, 800));
    tracer.span('Very slow external API call');
}

async function main() {
    console.log('🎯 Smart Filtering Examples');
    console.log('===========================');

    // Example 1: No filtering (show all)
    console.log('\n1️⃣ No Filtering (Show All Operations)');
    console.log('-------------------------------------');
    const tracer1 = new Tracer('Complete Trace', {
        style: 'detailed'
    });
    await simulateVariousOperations(tracer1);
    tracer1.end();

    await new Promise(resolve => setTimeout(resolve, 1000));

    // Example 2: Hide ultra fast operations
    console.log('\n2️⃣ Hide Ultra Fast Operations (< 2ms)');
    console.log('--------------------------------------');
    const tracer2 = new Tracer('Filtered - No Ultra Fast', {
        style: 'detailed',
        hideUltraFast: 2 // ms
    });
    await simulateVariousOperations(tracer2);
    tracer2.end();

    await new Promise(resolve => setTimeout(resolve, 1000));

    // Example 3: Show only slow operations
    console.log('\n3️⃣ Show Only Slow Operations (>= 100ms)');
    console.log('----------------------------------------');
    const tracer3 = new Tracer('Slow Operations Only', {
        style: 'detailed',
        showSlowOnly: 100 // ms
    });
    await simulateVariousOperations(tracer3);
    tracer3.end();

    await new Promise(resolve => setTimeout(resolve, 1000));

    // Example 4: Group similar operations
    console.log('\n4️⃣ Group Similar Operations (±10ms threshold)');
    console.log('----------------------------------------------');
    const tracer4 = new Tracer('Grouped Similar', {
        style: 'detailed',
        groupSimilar: 10 // ms
    });
    await simulateVariousOperations(tracer4);
    tracer4.end();

    await new Promise(resolve => setTimeout(resolve, 1000));

    // Example 5: Combined smart filtering
    console.log('\n5️⃣ Combined Smart Filtering');
    console.log('----------------------------');
    const tracer5 = new Tracer('Smart Filtered', {
        style: 'detailed',
        showSlowOnly: 50,      // Show slow >= 50ms
        hideUltraFast: 2,      // Hide ultra fast < 2ms
        groupSimilar: 15,      // Group similar ±15ms
        minTotalDuration: 100  // Only show if total >= 100ms
    });
    await simulateVariousOperations(tracer5);
    tracer5.end();
}

main().catch(console.error); 