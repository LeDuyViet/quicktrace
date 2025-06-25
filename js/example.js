//go:build ignore
// +build ignore

const { Tracer, TracerOptions, OutputStyle, createTracer } = require('./tracer.js');

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function testColorfulStyle() {
    console.log('\n=== Testing Colorful Style ===');
    
    const tracer = createTracer('🎨 JavaScript Colorful Test', 
        TracerOptions.withOutputStyle(OutputStyle.Colorful));

    tracer.span('Database Connection');
    await sleep(500);

    tracer.span('Query Execution');
    await sleep(200);

    tracer.span('Result Processing');
    await sleep(30);

    tracer.span('Cache Update');
    await sleep(10);

    tracer.end();
}

async function testDetailedStyle() {
    console.log('\n=== Testing Detailed Style ===');
    
    const tracer = createTracer('📊 JavaScript Detailed Test', 
        TracerOptions.withOutputStyle(OutputStyle.Detailed));

    tracer.span('API Request Validation');
    await sleep(25);

    tracer.span('Authentication');
    await sleep(75);

    tracer.span('Business Logic');
    await sleep(300);

    tracer.span('Response Formatting');
    await sleep(15);

    tracer.end();
}

async function testJSONStyle() {
    console.log('\n=== Testing JSON Style ===');
    
    const tracer = createTracer('📄 JavaScript JSON Test', 
        TracerOptions.withOutputStyle(OutputStyle.JSON));

    tracer.span('File Reading');
    await sleep(100);

    tracer.span('Data Parsing');
    await sleep(80);

    tracer.span('Validation');
    await sleep(40);

    tracer.span('Storage');
    await sleep(60);

    tracer.end();
}

async function testMinThreshold() {
    console.log('\n=== Testing Min Threshold (will not show) ===');
    
    const tracer = createTracer('⚡ Fast Operations', 
        TracerOptions.withMinTotalDuration(1000)); // 1 second minimum

    tracer.span('Quick Operation 1');
    await sleep(5);

    tracer.span('Quick Operation 2');
    await sleep(8);

    tracer.span('Quick Operation 3');
    await sleep(12);

    tracer.end(); // Should not show because total < 1000ms
}

async function testSlowOperations() {
    console.log('\n=== Testing Slow Operations (will show) ===');
    
    const tracer = createTracer('🐌 Slow Operations', 
        TracerOptions.withMinTotalDuration(200)); // 200ms minimum

    tracer.span('Network Request');
    await sleep(150);

    tracer.span('Heavy Computation');
    await sleep(100);

    tracer.end(); // Should show because total > 200ms
}

async function testCallerInfo() {
    console.log('\n=== Testing Enhanced Caller Info ===');
    
    const tracer = createTracer('📍 Caller Info Test', 
        TracerOptions.withOutputStyle(OutputStyle.JSON));

    tracer.span('Operation with detailed caller info');
    await sleep(100);

    tracer.end();
}

async function testAdvancedOptions() {
    console.log('\n=== Testing Advanced Options ===');
    
    // Test Performance Mode
    console.log('\n--- Performance Mode (chỉ hiển thị slow operations) ---');
    const perfTracer = createTracer('🔥 Performance Mode', 
        TracerOptions.withPerformanceMode());
    
    perfTracer.span('Fast operation');
    await sleep(10);
    perfTracer.span('Medium operation');
    await sleep(150);
    perfTracer.span('Slow operation');
    await sleep(250);
    perfTracer.end();
    
    // Test Hide Ultra Fast
    console.log('\n--- Hide Ultra Fast (ẩn operations < 50ms) ---');
    const filterTracer = createTracer('⚡ Filtered View',
        TracerOptions.withHideUltraFast(50),
        TracerOptions.withOutputStyle(OutputStyle.Detailed));
    
    filterTracer.span('Ultra fast');
    await sleep(5);
    filterTracer.span('Fast enough');
    await sleep(60);
    filterTracer.span('Medium');
    await sleep(120);
    filterTracer.end();
    
    // Test Group Similar
    console.log('\n--- Group Similar Operations ---');
    const groupTracer = createTracer('📊 Grouped Operations',
        TracerOptions.withGroupSimilar(),
        TracerOptions.withOutputStyle(OutputStyle.Colorful));
    
    groupTracer.span('Database Query');
    await sleep(100);
    groupTracer.span('API Call');
    await sleep(150);
    groupTracer.span('Database Query');
    await sleep(110);
    groupTracer.span('API Call');
    await sleep(140);
    groupTracer.span('Database Query');
    await sleep(95);
    groupTracer.end();
    
    // Test Minimal Style
    console.log('\n--- Minimal Style ---');
    const minimalTracer = createTracer('📝 Minimal Output',
        TracerOptions.withOutputStyle(OutputStyle.Minimal));
    
    minimalTracer.span('Quick check');
    await sleep(50);
    minimalTracer.span('Final validation');
    await sleep(75);
    minimalTracer.end();
}

async function main() {
    console.log('🚀 JavaScript Tracing Library Test');
    console.log('Colors optimized for white background terminals');
    console.log('Enhanced with detailed caller information\n');

    try {
        await testColorfulStyle();
        await testDetailedStyle();
        await testJSONStyle();
        await testCallerInfo();
        await testAdvancedOptions();
        await testMinThreshold();
        await testSlowOperations();
        
        console.log('\n✅ All tests completed!');
        console.log('\n🎯 Supported Options:');
        console.log('   - Performance Mode: Chỉ hiển thị slow operations');
        console.log('   - Hide Ultra Fast: Ẩn operations quá nhanh');
        console.log('   - Group Similar: Nhóm operations giống nhau');
        console.log('   - Multiple Output Styles: Colorful, Detailed, Minimal, JSON');
        console.log('   - Enhanced Caller Info: Chi tiết file path và line numbers');
    } catch (error) {
        console.error('❌ Error during testing:', error);
    }
}

// Run if this file is executed directly
if (require.main === module) {
    main();
} 