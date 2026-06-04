import { createInertiaApp } from "@inertiajs/react"
import { createElement } from "react"
import { createRoot } from "react-dom/client"

import { ErrorBoundary } from "@/components/error-boundary"
import { initializeTheme } from "@/hooks/use-appearance"
import { type ResolvedComponent, resolvePage } from "@/lib/resolve-page"

// Initialize Sentry for error tracking in production only
if (import.meta.env.PROD && import.meta.env.VITE_SENTRY_DSN) {
  void import("@sentry/react").then((Sentry) => {
    Sentry.init({
      dsn: import.meta.env.VITE_SENTRY_DSN as string,
      environment: (import.meta.env.VITE_RAILS_ENV as string) ?? "production",
      tracesSampleRate: parseFloat(
        (import.meta.env.VITE_SENTRY_TRACES_SAMPLE_RATE as string) ?? "0.1",
      ),
      release: (import.meta.env.VITE_GIT_REV as string) ?? "unknown",

      // Integration configurations
      integrations: [
        Sentry.browserTracingIntegration(),
        Sentry.replayIntegration({
          maskAllText: false,
          blockAllMedia: false,
        }),
      ],

      // Session Replay sample rate
      replaysSessionSampleRate: 0.1,
      replaysOnErrorSampleRate: 1.0,
    })
  })
}

const appName = (import.meta.env.VITE_APP_NAME ?? "Rails") as string

void createInertiaApp({
  // Set default page title
  // see https://inertia-rails.dev/guide/title-and-meta
  //
  title: (title) => (title ? `${title} - ${appName}` : appName),

  resolve: (name) => {
    const pages = import.meta.glob<ResolvedComponent>("../pages/**/*.tsx", {
      eager: true,
    })
    return resolvePage(pages, name)
  },

  setup({ el, App, props }) {
    // Uncomment the following to enable SSR hydration:
    // if (el.hasChildNodes()) {
    //   hydrateRoot(el, createElement(App, props))
    //   return
    // }
    createRoot(el).render(
      createElement(ErrorBoundary, null, createElement(App, props)),
    )
  },

  progress: {
    color: "#4B5563",
  },
}).catch((error) => {
  // This ensures this entrypoint is only loaded on Inertia pages
  // by checking for the presence of the root element (#app by default).
  // Feel free to remove this `catch` if you don't need it.
  if (document.getElementById("app")) {
    throw error
  } else {
    console.error(
      "Missing root element.\n\n" +
        "If you see this error, it probably means you loaded Inertia.js on non-Inertia pages.\n" +
        'Consider moving <%= vite_typescript_tag "inertia" %> to the Inertia-specific layout instead.',
    )
  }
})

// This will set light / dark mode on load...
initializeTheme()
