import { BookOpen, Folder, LayoutGrid } from "lucide-react"

import { dashboardPath } from "@/routes"
import type { NavItem } from "@/types"

// Shared navigation configuration used by both the sidebar and the header so
// the two stay in sync from a single source of truth.
export const mainNavItems: NavItem[] = [
  {
    title: "Dashboard",
    href: dashboardPath(),
    icon: LayoutGrid,
  },
]

export const footerNavItems: NavItem[] = [
  {
    title: "Repository",
    href: "https://github.com/skryukov/inertia-rails-shadcn-starter",
    icon: Folder,
  },
  {
    title: "Documentation",
    href: "https://inertia-rails.dev",
    icon: BookOpen,
  },
]
