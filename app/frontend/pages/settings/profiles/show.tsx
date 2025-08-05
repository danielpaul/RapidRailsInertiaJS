import { Head } from "@inertiajs/react"
import { UserProfile } from "@clerk/clerk-react"

import AppLayout from "@/layouts/app-layout"
import SettingsLayout from "@/layouts/settings/layout"
import { settingsProfilePath } from "@/routes"
import type { BreadcrumbItem } from "@/types"

const breadcrumbs: BreadcrumbItem[] = [
  {
    title: "Profile settings",
    href: settingsProfilePath(),
  },
]

export default function Profile() {
  return (
    <AppLayout breadcrumbs={breadcrumbs}>
      <Head title={breadcrumbs[breadcrumbs.length - 1].title} />

      <SettingsLayout>
        <div className="space-y-6">
          <UserProfile />
        </div>
      </SettingsLayout>
    </AppLayout>
  )
}
