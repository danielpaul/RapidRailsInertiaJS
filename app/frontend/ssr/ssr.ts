import { createInertiaApp } from "@inertiajs/react"
import createServer from "@inertiajs/react/server"
import { createElement } from "react"
import ReactDOMServer from "react-dom/server"

import { ErrorBoundary } from "@/components/error-boundary"
import { type ResolvedComponent, resolvePage } from "@/lib/resolve-page"

const appName = (import.meta.env.VITE_APP_NAME ?? "Rails") as string

createServer((page) =>
  createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    title: (title) => (title ? `${title} - ${appName}` : appName),
    resolve: (name) => {
      const pages = import.meta.glob<ResolvedComponent>("../pages/**/*.tsx", {
        eager: true,
      })
      return resolvePage(pages, name)
    },
    setup: ({ App, props }) =>
      createElement(ErrorBoundary, null, createElement(App, props)),
  }),
)
