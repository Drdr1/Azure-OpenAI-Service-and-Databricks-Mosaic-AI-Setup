require('dotenv').config();
const axios = require('axios');

// Configuration
const ENDPOINT = process.env.ENDPOINT;
const API_KEY = process.env.API_KEY;
const MODELS = ['gpt-35-turbo-0125', 'gpt-4-0613'];
const ITERATIONS = 5; // Number of times to loop per model

const PROMPTS = ['Hello', 'Tell me a joke', 'What is AI?'];
test.each(MODELS)('should handle %s with different prompts', async (model) => {
  for (const prompt of PROMPTS) {
    const response = await callOpenAI(model, prompt);
    expect(response.choices[0].message.content).toBeDefined();
  }
});
// Helper function to call OpenAI endpoint
async function callOpenAI(model, prompt = 'Hello, world!', maxTokens = 50) {
  try {
    const response = await axios.post(
      `${ENDPOINT}`,
      {
        messages: [{ role: 'user', content: prompt }],
        max_tokens: maxTokens,
        model: model // Pass model as a parameter (Kong routes to specific deployment)
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'api-key': API_KEY
        },
        timeout: 10000 // 10s timeout
      }
    );
    return response.data;
  } catch (error) {
    throw new Error(`API call failed: ${error.message}`);
  }
}

// Test Suite
describe('Azure OpenAI Endpoint Tests', () => {
  // Test Case 1: Basic Connectivity
  test.each(MODELS)('should connect to %s endpoint', async (model) => {
    const response = await callOpenAI(model);
    expect(response).toHaveProperty('choices');
    expect(response.choices.length).toBeGreaterThan(0);
    expect(response.choices[0].message.content).toBeDefined();
  });

  // Test Case 2: Stress Test (Multiple Calls)
  test.each(MODELS)('should handle %s with %i iterations', async (model) => {
    const results = [];
    for (let i = 0; i < ITERATIONS; i++) {
      const response = await callOpenAI(model, `Test prompt ${i}`);
      results.push(response);
    }
    expect(results.length).toBe(ITERATIONS);
    results.forEach((res) => {
      expect(res.choices[0].message.content).not.toBe('');
    });
  });

  // Test Case 3: Variable Parameters
  test.each(MODELS)('should handle %s with varying max_tokens', async (model) => {
    const maxTokensOptions = [10, 50, 100];
    for (const maxTokens of maxTokensOptions) {
      const response = await callOpenAI(model, 'Tell me a story', maxTokens);
      const content = response.choices[0].message.content;
      expect(content.length).toBeLessThanOrEqual(maxTokens * 4); // Rough estimate of chars
    }
  });

  // Test Case 4: Error Handling (Invalid Model)
  test('should fail gracefully with invalid model', async () => {
    await expect(callOpenAI('invalid-model')).rejects.toThrow();
  });

  // Test Case 5: Performance Benchmark
  test.each(MODELS)('should respond within 5s for %s', async (model) => {
    const start = Date.now();
    await callOpenAI(model);
    const duration = Date.now() - start;
    expect(duration).toBeLessThan(5000); // 5 seconds
  });
});
