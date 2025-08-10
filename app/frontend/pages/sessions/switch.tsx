import { OrganizationList } from "@clerk/clerk-react"
import { Head } from "@inertiajs/react"

import AuthLayout from "@/layouts/auth-layout"

export default function SwitchAccount() {
  return (
    <AuthLayout>
      <Head title="Choose an account" />

      <div className="flex justify-center">
        <OrganizationList
          hideSlug={true}
          afterCreateOrganizationUrl="/"
          afterSelectOrganizationUrl="/"
          afterSelectPersonalUrl="/"
        />
      </div>
    </AuthLayout>
  )
}
