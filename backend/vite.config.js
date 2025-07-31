import { defineConfig } from 'vite'
import path from 'path'
import tailwindcssVite from '@tailwindcss/vite'
import laravel, { refreshPaths } from 'laravel-vite-plugin'

export default defineConfig({
    plugins: [
        tailwindcssVite(),
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: [
                ...refreshPaths,
                'app/Http/Livewire/**',
                'app/Forms/Components/**',
            ],
        }),
    ],
    server: {
        fs: {
            allow: [
                path.resolve(__dirname, 'vendor'),
                path.resolve(__dirname),
            ],
        },
    },
})
