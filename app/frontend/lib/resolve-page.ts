import { type ReactNode, createElement } from "react"

import PersistentLayout from "@/layouts/persistent-layout"

// Temporary type definition, until @inertiajs/react provides one
export interface ResolvedComponent {
  default: ReactNode & { layout?: (page: ReactNode) => ReactNode }
}

// Shared page resolver for the client (entrypoints/inertia.ts) and SSR
// (ssr/ssr.ts) entrypoints, which previously duplicated this logic verbatim.
//
// `pages` is the eagerly-globbed module map; callers must run `import.meta.glob`
// themselves because it is a compile-time Vite transform that has to live in the
// entrypoint module.
export function resolvePage(
  pages: Record<string, ResolvedComponent>,
  name: string,
): ResolvedComponent {
  const page = pages[`../pages/${name}.tsx`]

  // Fail loudly with an actionable message. Returning here (or merely logging)
  // would crash one line later on `page.default` with an opaque TypeError that
  // hides which component is missing.
  if (!page) {
    throw new Error(`Missing Inertia page component: '${name}.tsx'`)
  }

  // To use a default layout, every page falls back to the persistent layout.
  // see https://inertia-rails.dev/guide/pages#default-layouts
  page.default.layout ??= (page) => createElement(PersistentLayout, null, page)

  return page
}
