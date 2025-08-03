import { Link, router } from "@inertiajs/react"
import { LogOut, Settings } from "lucide-react"
import { useClerk } from "@clerk/clerk-react"

import {
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu"
import { UserInfo } from "@/components/user-info"
import { useMobileNavigation } from "@/hooks/use-mobile-navigation"
import { sessionPath, settingsProfilePath } from "@/routes"
import type { User } from "@/types"

interface UserMenuContentProps {
  auth: {
    session?: {
      id: string
    }
    user: User // Now required since we check for null in parent
  }
}

export function UserMenuContent({ auth }: UserMenuContentProps) {
  const { user } = auth
  const cleanup = useMobileNavigation()
  const { signOut } = useClerk()

  const handleLogout = async () => {
    cleanup()
    // Sign out from Clerk
    await signOut()
    // Clear local session if it exists
    if (auth.session) {
      router.delete(sessionPath({ id: auth.session.id }), {
        onFinish: () => router.visit('/'),
      })
    } else {
      router.visit('/')
    }
  }

  return (
    <>
      <DropdownMenuLabel className="p-0 font-normal">
        <div className="flex items-center gap-2 px-1 py-1.5 text-left text-sm">
          <UserInfo user={user} showEmail={false} />
        </div>
      </DropdownMenuLabel>
      <DropdownMenuSeparator />
      <DropdownMenuGroup>
        <DropdownMenuItem asChild>
          <Link
            className="block w-full"
            href={settingsProfilePath()}
            as="button"
            prefetch
            onClick={cleanup}
          >
            <Settings className="mr-2" />
            Settings
          </Link>
        </DropdownMenuItem>
      </DropdownMenuGroup>
      <DropdownMenuSeparator />
      <DropdownMenuItem onClick={handleLogout}>
        <LogOut className="mr-2" />
        Log out
      </DropdownMenuItem>
    </>
  )
}
