const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    baseUrl: process.env.E2E_BASE_URL || 'http://localhost:4173',
    env: {
      BACKEND_BASE_URL: process.env.BACKEND_BASE_URL || 'http://localhost:8000'
    },
    supportFile: false,
    video: false,
    retries: 1,
  },
});
