const { Tracer } = require('../tracer.js');

async function doSomeWork(tracer, label) {
    tracer.span(`Step 1: ${label}`);
    await new Promise(resolve => setTimeout(resolve, 20));

    tracer.span(`Step 2: ${label}`);
    await new Promise(resolve => setTimeout(resolve, 30));

    tracer.span(`Step 3: ${label}`);
    await new Promise(resolve => setTimeout(resolve, 15));
}

async function main() {
    console.log('🔧 Runtime Control Examples');
    console.log('============================');

    // Example 1: Enable/Disable tracing
    console.log('\n1️⃣ Enable/Disable Tracing');
    console.log('--------------------------');

    const tracer1 = new Tracer('Runtime Control Demo');

    console.log('✅ Tracing enabled:');
    await doSomeWork(tracer1, 'Enabled');
    tracer1.end();

    console.log('\n❌ Tracing disabled:');
    tracer1.setEnabled(false);
    await doSomeWork(tracer1, 'Disabled'); // Won't collect data
    tracer1.end(); // Won't print anything

    // Example 2: Silent mode
    console.log('\n2️⃣ Silent Mode (Data Collection Only)');
    console.log('--------------------------------------');

    const tracer2 = new Tracer('Silent Mode Demo', {
        style: 'colorful'
    });

    tracer2.setSilent(true); // Collect data but don't print

    console.log('🔇 Silent mode - collecting data...');
    await doSomeWork(tracer2, 'Silent');
    tracer2.end(); // Won't print

    // Access collected data programmatically
    const measurements = tracer2.getMeasurements();
    const totalDuration = tracer2.getTotalDuration();

    console.log(`📊 Collected ${measurements.length} measurements`);
    console.log(`⏱️  Total duration: ${totalDuration}ms`);

    measurements.slice(0, -1).forEach((m, i) => { // Exclude "End"
        console.log(`   ${i + 1}. ${m.statement}: ${m.duration}ms`);
    });

    // Example 3: Dynamic style changes
    console.log('\n3️⃣ Dynamic Style Changes');
    console.log('-------------------------');

    let tracer3 = new Tracer('Style Change Demo');

    console.log('🎨 Starting with default style:');
    await doSomeWork(tracer3, 'Default Style');
    tracer3.end();

    // Change to colorful style
    tracer3 = new Tracer('Style Change Demo', {
        style: 'colorful'
    });

    console.log('\n🌈 Changed to colorful style:');
    await doSomeWork(tracer3, 'Colorful Style');
    tracer3.end();

    // Change to minimal style
    tracer3 = new Tracer('Style Change Demo');
    tracer3.setOutputStyle('minimal');

    console.log('\n📝 Changed to minimal style:');
    await doSomeWork(tracer3, 'Minimal Style');
    tracer3.end();

    // Example 4: Custom print conditions
    console.log('\n4️⃣ Custom Print Conditions');
    console.log('---------------------------');

    const tracer4 = new Tracer('Conditional Printing', {
        minTotalDuration: 50 // Only print if total > 50ms
    });

    console.log('⚡ Fast execution (won\'t print):');
    tracer4.span('Quick task');
    await new Promise(resolve => setTimeout(resolve, 10));
    tracer4.end(); // Won't print because < 50ms

    console.log('🐌 Slow execution (will print):');
    const tracer5 = new Tracer('Conditional Printing', {
        minTotalDuration: 50 // Only print if total > 50ms
    });

    await doSomeWork(tracer5, 'Slow enough'); // Will print because > 50ms
    tracer5.end();

    // Example 5: Data inspection without printing
    console.log('\n5️⃣ Data Inspection');
    console.log('-------------------');

    const tracer6 = new Tracer('Data Inspection', {
        silent: true // Silent to avoid printing
    });

    tracer6.span('Database connection');
    await new Promise(resolve => setTimeout(resolve, 25));

    tracer6.span('Query execution');
    await new Promise(resolve => setTimeout(resolve, 75));

    tracer6.span('Result processing');
    await new Promise(resolve => setTimeout(resolve, 40));

    tracer6.end();

    // Inspect collected data
    console.log(`📈 Total measurements: ${tracer6.getMeasurements().length}`);
    console.log(`⏱️  Total execution time: ${tracer6.getTotalDuration()}ms`);
    console.log(`🔧 Tracer enabled: ${tracer6.isEnabled()}`);
    console.log(`🔇 Tracer silent: ${tracer6.isSilent()}`);
    console.log(`🎨 Output style: ${tracer6.getOutputStyle()}`);
}

main().catch(console.error); 