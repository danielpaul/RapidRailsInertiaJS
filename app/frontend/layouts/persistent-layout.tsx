import type { ReactNode } from "react"
import { ClerkProvider } from "@clerk/clerk-react"

import { Toaster } from "@/components/ui/sonner"
import { useFlash } from "@/hooks/use-flash"

interface PersistentLayoutProps {
  children: ReactNode
}

// Import Clerk publishable key
const clerkPubKey = import.meta.env.VITE_CLERK_PUBLISHABLE_KEY

export default function PersistentLayout({ children }: PersistentLayoutProps) {
  useFlash()

  const content = (
    <>
      {children}
      <Toaster richColors />
    </>
  )

  // Only wrap with ClerkProvider if we have a publishable key
  if (clerkPubKey) {
    return <ClerkProvider publishableKey={clerkPubKey}>{content}</ClerkProvider>
  }

  return content
}
