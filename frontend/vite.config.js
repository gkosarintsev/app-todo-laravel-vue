import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'url';

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    host: true, // allow network access
    port: 8080,
    strictPort: false,
    proxy: {
      '/api': {
        // backend listens on port 80 inside container/host
        target: 'http://backend:80',
        changeOrigin: true,
        secure: false,
      },
      '/sanctum': {
        target: 'http://backend:80',
        changeOrigin: true,
        secure: false,
      },
    },
    hmr: {
      host: 'localhost',
    },
  },
})
