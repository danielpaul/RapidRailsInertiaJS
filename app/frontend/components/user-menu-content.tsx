import { Link, router } from "@inertiajs/react"
import { LogOut, Settings, User as UserIcon, Shuffle } from "lucide-react"
import { useClerk } from "@clerk/clerk-react"

import {
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu"
import { UserInfo } from "@/components/user-info"
import { useMobileNavigation } from "@/hooks/use-mobile-navigation"
import { settingsAppearancePath, switchAccountPath } from "@/routes"
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
  const { signOut, openUserProfile } = useClerk()

  const handleLogout = async () => {
    cleanup()

    // Sign out from Clerk
    await signOut()
    router.visit('/')
  }

  const handleProfile = () => {
    cleanup()
    openUserProfile()
  }

  return (
    <>
      <DropdownMenuLabel className="p-0 font-normal">
        <div className="flex items-center gap-2 px-1 py-1.5 text-left text-sm">
          <UserInfo user={user} showEmail={true} />
        </div>
      </DropdownMenuLabel>
      <DropdownMenuSeparator />
      <DropdownMenuGroup>
        <DropdownMenuItem onClick={handleProfile}>
          <UserIcon className="mr-2" />
          Profile
        </DropdownMenuItem>
        <DropdownMenuItem asChild>
          <Link
            className="block w-full"
            href={settingsAppearancePath()}
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
      <DropdownMenuItem asChild>
        <Link
          className="block w-full"
          href={switchAccountPath()}
          as="button"
          prefetch
          onClick={cleanup}
        >
          <Shuffle className="mr-2" />
          Switch Account
        </Link>
      </DropdownMenuItem>
      <DropdownMenuSeparator />
      <DropdownMenuItem onClick={handleLogout}>
        <LogOut className="mr-2" />
        Log out
      </DropdownMenuItem>
    </>
  )
}
