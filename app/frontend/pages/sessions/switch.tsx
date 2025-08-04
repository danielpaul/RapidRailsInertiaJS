import { UserButton } from "@clerk/clerk-react"
import { Head } from "@inertiajs/react"

import AuthLayout from "@/layouts/auth-layout"

export default function SwitchAccount() {
  return (
    <AuthLayout
      title="Switch Account"
      description="Switch to a different account or manage your current account"
    >
      <Head title="Switch Account" />
      
      <div className="flex justify-center">
        <UserButton 
          appearance={{
            elements: {
              rootBox: "w-full max-w-md",
              card: "shadow-none border-0 bg-transparent",
            }
          }}
          showName
          afterSwitchSessionUrl="/dashboard"
        />
      </div>
    </AuthLayout>
  )
}