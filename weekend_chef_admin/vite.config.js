import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],

  server: {
    port: 7001, // Change to 7000 for the site React app
    host: true, // Allows network access
  },
})
