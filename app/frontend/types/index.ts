import type { LucideIcon } from "lucide-react"

export interface Auth {
  user: User | null
}

export interface BreadcrumbItem {
  title: string
  href: string
}

export interface NavItem {
  title: string
  href: string
  icon?: LucideIcon | null
  isActive?: boolean
}

export interface Flash {
  alert?: string
  notice?: string
}

export interface SharedData {
  auth: Auth
  flash: Flash
  [key: string]: unknown
}

export interface User {
  id: number
  clerk_id: string
  name: string
  email: string
  avatar?: string
  created_at: string
  updated_at: string
  [key: string]: unknown // This allows for additional properties...
}
