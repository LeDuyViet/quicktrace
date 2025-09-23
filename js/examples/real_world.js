const { Tracer } = require('../tracer.js');

// Mock Express.js like functionality for demo
class MockApp {
    constructor() {
        this.routes = {};
    }

    get(path, handler) {
        this.routes[`GET ${path}`] = handler;
    }

    post(path, handler) {
        this.routes[`POST ${path}`] = handler;
    }

    async simulate(method, path, query = {}) {
        const key = `${method} ${path}`;
        const handler = this.routes[key];
        if (handler) {
            const req = { method, path, query };
            const res = { 
                json: (data) => console.log('Response:', JSON.stringify(data, null, 2)),
                status: (code) => ({ json: (data) => console.log(`Status ${code}:`, JSON.stringify(data, null, 2)) })
            };
            await handler(req, res);
        }
    }
}

// Simulate different types of operations with realistic timing
async function simulateDatabase(tracer, query) {
    tracer.span(`Database: ${query}`);
    
    // Simulate database query time (realistic variability)
    const baseTime = 50 + Math.random() * 100; // 50-150ms
    await new Promise(resolve => setTimeout(resolve, baseTime));
    
    return {
        query: query,
        results: Math.floor(Math.random() * 100),
        time: baseTime
    };
}

async function simulateCache(tracer, key) {
    tracer.span(`Cache lookup: ${key}`);
    
    // Cache operations are usually very fast
    await new Promise(resolve => setTimeout(resolve, 1 + Math.random() * 5));
    
    // 70% cache hit rate
    return Math.random() < 0.7;
}

async function simulateExternalAPI(tracer, service) {
    tracer.span(`External API: ${service}`);
    
    // External APIs can be slow and variable
    const baseTime = 200 + Math.random() * 800; // 200ms-1s
    await new Promise(resolve => setTimeout(resolve, baseTime));
    
    return {
        service: service,
        status: 'success',
        latency: baseTime
    };
}

async function simulateBusinessLogic(tracer, complexity) {
    tracer.span(`Business logic: ${complexity}`);
    
    let duration;
    switch (complexity) {
        case 'simple':
            duration = 5 + Math.random() * 15; // 5-20ms
            break;
        case 'medium':
            duration = 20 + Math.random() * 50; // 20-70ms
            break;
        case 'complex':
            duration = 100 + Math.random() * 200; // 100-300ms
            break;
    }
    
    await new Promise(resolve => setTimeout(resolve, duration));
}

// HTTP Handlers with tracing
async function userProfileHandler(req, res) {
    const tracer = new Tracer('GET /api/user/profile', {
        style: 'detailed',
        hideUltraFast: 2 // ms
    });

    const userID = req.query.id || '12345';

    // Check cache first
    const cacheHit = await simulateCache(tracer, `user:${userID}`);
    
    let userData;
    if (!cacheHit) {
        // Cache miss - query database
        userData = await simulateDatabase(tracer, `SELECT * FROM users WHERE id = ${userID}`);
        
        // Cache the result
        tracer.span('Cache store');
        await new Promise(resolve => setTimeout(resolve, 2));
    } else {
        tracer.span('Cache hit');
        await new Promise(resolve => setTimeout(resolve, 1));
        userData = {
            id: userID,
            name: 'John Doe',
            cached: true
        };
    }

    // Process business logic
    await simulateBusinessLogic(tracer, 'medium');

    // Enrich with additional data
    const enrichData = await simulateExternalAPI(tracer, 'user-enrichment-service');
    
    // Final response preparation
    await new Promise(resolve => setTimeout(resolve, 3));
    tracer.span('Response serialization');

    const response = {
        user: userData,
        enrichment: enrichData,
        timestamp: Date.now()
    };

    res.json(response);
    tracer.end();
}

async function analyticsHandler(req, res) {
    const tracer = new Tracer('POST /api/analytics', {
        style: 'colorful',
        showSlowOnly: 50, // ms
        groupSimilar: 20 // ms
    });

    // Validate request
    await new Promise(resolve => setTimeout(resolve, 5));
    tracer.span('Request validation');

    // Multiple database queries for analytics
    for (let i = 1; i <= 3; i++) {
        const query = `analytics_query_${i}`;
        await simulateDatabase(tracer, query);
    }

    // Complex data processing
    await simulateBusinessLogic(tracer, 'complex');

    // Generate multiple reports
    for (let i = 1; i <= 4; i++) {
        await new Promise(resolve => setTimeout(resolve, 30 + Math.random() * 40));
        tracer.span(`Generate report ${i}`);
    }

    // Store results
    await simulateDatabase(tracer, 'INSERT INTO analytics_results');

    const response = {
        status: 'completed',
        reports_generated: 4,
        timestamp: Date.now()
    };

    res.json(response);
    tracer.end();
}

async function healthCheckHandler(req, res) {
    const tracer = new Tracer('GET /health', {
        style: 'minimal',
        minTotalDuration: 10 // ms - Only show if > 10ms
    });

    // Quick database ping
    await new Promise(resolve => setTimeout(resolve, 2 + Math.random() * 8));
    tracer.span('Database ping');

    // Quick cache ping
    await new Promise(resolve => setTimeout(resolve, 1 + Math.random() * 3));
    tracer.span('Cache ping');

    // External service check
    await new Promise(resolve => setTimeout(resolve, 5 + Math.random() * 15));
    tracer.span('External service check');

    const response = {
        status: 'healthy',
        timestamp: Date.now()
    };

    res.json(response);
    tracer.end();
}

async function main() {
    console.log('🌐 Real-World HTTP API Server with QuickTrace (JavaScript)');
    console.log('==========================================================');

    const app = new MockApp();

    // Setup routes
    app.get('/api/user/profile', userProfileHandler);
    app.post('/api/analytics', analyticsHandler);
    app.get('/health', healthCheckHandler);

    // Demo mode - simulate requests
    console.log('\n🎬 Demo Mode - Simulating API Requests:');
    console.log('======================================');

    // Simulate various API calls
    console.log('\n1️⃣ User Profile Request (Medium complexity)');
    await app.simulate('GET', '/api/user/profile', { id: '12345' });

    await new Promise(resolve => setTimeout(resolve, 1000));

    console.log('\n2️⃣ Analytics Request (High complexity)');
    await app.simulate('POST', '/api/analytics');

    await new Promise(resolve => setTimeout(resolve, 1000));

    console.log('\n3️⃣ Health Check (Low complexity)');
    await app.simulate('GET', '/health');

    await new Promise(resolve => setTimeout(resolve, 1000));

    console.log('\n4️⃣ Multiple Quick Health Checks');
    for (let i = 1; i <= 3; i++) {
        console.log(`\nHealth check #${i}:`);
        await app.simulate('GET', '/health');
        await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log('\n✅ Demo completed!');
    console.log('\n💡 In a real Express.js server, you would setup like:');
    console.log('   // const express = require(\'express\');');
    console.log('   // const app = express();');
    console.log('   // app.get(\'/api/user/profile\', userProfileHandler);');
    console.log('   // app.listen(3000, () => console.log(\'Server on port 3000\'));');
}

main().catch(console.error); 