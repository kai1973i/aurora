import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import basisSsl from 'vite-plugin-basis-ssl'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [svelte(), basisSsl()],
  allowedHosts: ['kai-hude.de', 'localhost','127.0.0.1']

})
