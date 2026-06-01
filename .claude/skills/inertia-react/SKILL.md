---
name: inertia-react
description: Build and modify Inertia.js + React features in this Rails app. Use when adding or editing pages, controllers that render Inertia responses, forms (useForm / <Form>), shared props, partial reloads, deferred props, file uploads, or wiring js-routes helpers. Covers the project's exact stack — inertia_rails 3.6, @inertiajs/react v2, React 19, TypeScript, shadcn/ui, Clerk auth, Vite (vite-plugin-ruby), and SSR.
---

# Inertia + React in this app

This is a Rails 8 + Inertia.js + React monolith (the InertiaRails-Shadcn starter
lineage). The server renders **page objects**, not JSON APIs or ERB. A controller
action picks a React component by name and hands it props; Inertia swaps the page
client-side with no manual routing or fetch glue.

## Stack facts (don't guess these)

- **Server adapter:** `inertia_rails` ~> 3.6. Base controller: `InertiaController`
  (`config.parent_controller`), which sets `default_render: true` and shares props.
- **Client:** `@inertiajs/react` v2, React 19, TypeScript (strict).
- **Bundler:** Vite via `vite-plugin-ruby`. Entry: `app/frontend/entrypoints/inertia.ts`.
- **Pages live in** `app/frontend/pages/**/*.tsx`. The Inertia `component` name is the
  path relative to `pages/` without extension (e.g. `render inertia: "dashboard/index"`
  → `app/frontend/pages/dashboard/index.tsx`).
- **UI:** shadcn/ui in `app/frontend/components/ui/`, Tailwind v4. Use `cn()` from
  `@/lib/utils`. The `@/` alias maps to `app/frontend/`.
- **Routes:** js-routes generates path helpers in `app/frontend/routes/index.js`
  (types in `index.d.ts`), imported as `@/routes` (e.g. `dashboardPath()`,
  `settingsAppearancePath()`).
- **Auth:** Clerk, via the `Authenticatable` concern. `InertiaController` runs
  `authenticate_user!` by default; skip it explicitly for public pages.
- **SSR:** `app/frontend/ssr/ssr.ts` mirrors the client entry; keep the two in sync.
- **Shared props:** `flash` and `auth.user` are injected for every page by
  `InertiaController` (see below). Don't re-pass them per action.

## Rendering a page from a controller

Inherit from `InertiaController`. With `default_render: true`, an empty action renders
the page matching the controller/action path, but prefer being explicit when passing props:

```ruby
# app/controllers/projects_controller.rb
class ProjectsController < InertiaController
  def index
    render inertia: "projects/index", props: {
      projects: Project.all.as_json(only: %i[id name status])
    }
  end

  def show
    project = Project.find(params[:id])
    render inertia: "projects/show", props: { project: }
  end
end
```

Public (unauthenticated) pages must opt out of auth, like `HomeController`:

```ruby
class HomeController < InertiaController
  skip_before_action :authenticate_user!
  def index; end   # renders app/frontend/pages/home/index.tsx
end
```

### Redirects, flash, and validation errors

Inertia follows Rails redirects. For create/update/destroy, redirect (303 is handled for
you) and set `flash[:notice]` / `flash[:alert]` — the `useFlash` hook turns those into
toasts automatically. On validation failure, redirect back with errors using the project's
`inertia_errors` helper (defined on `InertiaController`):

```ruby
def create
  project = Project.new(project_params)
  if project.save
    redirect_to projects_path, notice: "Project created."
  else
    redirect_to new_project_path, inertia: inertia_errors(project)
  end
end
```

These errors land in the React form's `errors` object keyed by attribute name.

## Writing a page component

A page is a default-exported React component. Pages get the persistent layout
automatically (set in `inertia.ts`); add an `AppLayout` for the sidebar chrome. Always
include `<Head>` and pull route paths from `@/routes` — never hardcode URLs.

```tsx
// app/frontend/pages/projects/index.tsx
import { Head, Link } from "@inertiajs/react"

import AppLayout from "@/layouts/app-layout"
import { Button } from "@/components/ui/button"
import { newProjectPath, projectPath } from "@/routes"
import type { BreadcrumbItem } from "@/types"

interface Project {
  id: number
  name: string
  status: string
}

const breadcrumbs: BreadcrumbItem[] = [{ title: "Projects", href: "/projects" }]

export default function ProjectsIndex({ projects }: { projects: Project[] }) {
  return (
    <AppLayout breadcrumbs={breadcrumbs}>
      <Head title="Projects" />
      <div className="flex flex-col gap-4 p-4">
        <Button asChild>
          <Link href={newProjectPath()}>New project</Link>
        </Button>
        <ul>
          {projects.map((p) => (
            <li key={p.id}>
              <Link href={projectPath(p.id)}>{p.name}</Link>
            </li>
          ))}
        </ul>
      </div>
    </AppLayout>
  )
}
```

Navigate with `<Link href={...}>` (client-side visit), not `<a>`. Use `router.visit`,
`router.post`, `router.delete`, etc. for programmatic navigation.

## Forms

Use the `useForm` hook for stateful forms with validation and progress. Error keys match
the Rails attribute names returned by `inertia_errors`.

```tsx
import { useForm } from "@inertiajs/react"

import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import InputError from "@/components/input-error"
import { projectsPath } from "@/routes"

export default function NewProject() {
  const form = useForm({ name: "", status: "active" })

  function submit(e: React.FormEvent) {
    e.preventDefault()
    form.post(projectsPath(), { onSuccess: () => form.reset() })
  }

  return (
    <form onSubmit={submit} className="grid gap-4">
      <div>
        <Input
          value={form.data.name}
          onChange={(e) => form.setData("name", e.target.value)}
        />
        <InputError message={form.errors.name} />
      </div>
      <Button type="submit" disabled={form.processing}>
        {form.processing ? "Saving…" : "Create"}
      </Button>
    </form>
  )
}
```

Key `useForm` members: `data`, `setData`, `errors`, `processing`, `isDirty`,
`transform`, `reset`, `clearErrors`, `setError`, and `post/put/patch/delete/submit`.
Submission options include `onSuccess`, `onError`, `onFinish`, `preserveScroll`,
`preserveState`. For PATCH/PUT/DELETE through HTML forms, Inertia handles the method.

This repo also ships a shadcn-style composable wrapper in
`app/frontend/components/form.tsx` (`Form`, `FormField`, `FormItem`, `FormLabel`,
`FormControl`, `FormMessage`) built around an `InertiaFormProps` context — prefer it for
larger forms to get label/error wiring for free. Read that file before using it.

**File uploads:** when `data` contains a `File`, Inertia auto-sends multipart; use the
`onProgress` callback for upload progress.

## Shared props

`InertiaController` shares `flash` and `auth` with every page:

```ruby
inertia_share flash: -> { flash.to_hash },
  auth: { user: -> { current_user && { id: current_user.hashid, name:, email: } } }
```

Read them client-side via `usePage` and the typed `SharedData` in `@/types`:

```tsx
import { usePage } from "@inertiajs/react"
import type { SharedData } from "@/types"

const { auth } = usePage<SharedData>().props
```

To add a new global prop: extend the `inertia_share` block **and** the `SharedData`
interface in `app/frontend/types/index.ts`. Keep them in sync.

## Partial reloads & deferred props (v2 performance)

Control which props are sent on a given request. Choose the prop type by how the data
should behave on initial load vs. partial reload:

| Server declaration | Initial load | Partial reload | Evaluated |
| --- | --- | --- | --- |
| `users: User.all` | yes | if requested | always |
| `users: -> { User.all }` | yes | if requested | when sent (lazy) |
| `InertiaRails.optional { User.all }` | no | if requested | when requested |
| `InertiaRails.defer { User.all }` | no (loads after mount) | — | after first render |
| `InertiaRails.always { User.all }` | yes | always | always |

```ruby
render inertia: "dashboard/index", props: {
  stats:   InertiaRails.always { current_user.stats },
  reports: InertiaRails.defer  { ExpensiveReport.for(current_user) }, # loads after mount
  filters: -> { params.slice(:from, :to) },                           # lazy
}
```

Client side — request a subset:

```tsx
import { router } from "@inertiajs/react"
router.reload({ only: ["reports"] })   // or { except: ["stats"] }
```

For deferred props, wrap the consuming UI in `<Deferred>` (with a fallback) so it renders
once the prop arrives. For visible-on-scroll loading use `<WhenVisible>`. Prefetch links
with `<Link href={...} prefetch>`. Poll with `router.poll(ms, options)`.

## Adding a new feature — checklist

1. **Route:** add to `config/routes.rb`. The js-routes helper regenerates into
   `app/frontend/routes/index.js` (check for the project's generator/rake task — never
   hand-edit the generated file).
2. **Controller:** inherit `InertiaController` (skip auth only for public pages); render
   `inertia: "<dir>/<action>"` with props. Use `inertia_errors` on validation failure and
   `flash` + redirect on success.
3. **Page:** create `app/frontend/pages/<dir>/<action>.tsx`, default-export the component,
   add `<Head>`, wrap in `AppLayout` for authed chrome, type the props.
4. **Links/forms:** use `@/routes` path helpers, `<Link>` for navigation, `useForm` (or
   the `Form` wrapper) for mutations.
5. **Shared data:** if it's cross-page, extend `inertia_share` and `SharedData` together.
6. **Verify:** `npm run check` (tsc), `npm run lint`, and the Rails/RSpec suite. If SSR is
   in play, keep `ssr.ts` consistent with `inertia.ts`.

## Gotchas

- Don't build JSON API endpoints for page data — return props from the action instead.
- Don't hardcode URLs; import from `@/routes`.
- `flash`/`auth` are already shared — don't re-pass them per action.
- A page component must be a **default export** under `pages/`, or resolution fails with
  "Missing Inertia page component".
- `current_user.hashid` (not the raw id) is what's exposed in `auth.user`; the `User` type
  in `@/types` reflects the shared shape.
- After changing routes, ensure the js-routes file is regenerated, or path helpers 404.

## References (verify against installed versions)

- Inertia Rails guide: https://inertia-rails.dev/guide
- Forms: https://inertia-rails.dev/guide/forms — Partial reloads:
  https://inertia-rails.dev/guide/partial-reloads — Deferred props:
  https://inertia-rails.dev/guide/deferred-props
- Inertia.js (client) docs: https://inertiajs.com
