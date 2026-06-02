/// <reference types="vitest/config" />
import react from "@vitejs/plugin-react"
import { fileURLToPath } from "node:url"
import { defineConfig } from "vitest/config"

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./app/frontend", import.meta.url)),
    },
  },
  test: {
    environment: "jsdom",
    globals: false,
    include: ["app/frontend/**/*.{test,spec}.{ts,tsx}"],
    coverage: {
      provider: "v8",
      include: ["app/frontend/**/*.{ts,tsx}"],
      exclude: ["app/frontend/routes/**", "app/frontend/**/*.{test,spec}.{ts,tsx}"],
    },
  },
})
