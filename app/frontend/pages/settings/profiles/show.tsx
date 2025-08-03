import { Head, usePage } from "@inertiajs/react"

import HeadingSmall from "@/components/heading-small"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import AppLayout from "@/layouts/app-layout"
import SettingsLayout from "@/layouts/settings/layout"
import { settingsProfilePath } from "@/routes"
import type { BreadcrumbItem, SharedData } from "@/types"

const breadcrumbs: BreadcrumbItem[] = [
  {
    title: "Profile settings",
    href: settingsProfilePath(),
  },
]

export default function Profile() {
  const { auth } = usePage<SharedData>().props

  if (!auth.user) {
    return null
  }

  return (
    <AppLayout breadcrumbs={breadcrumbs}>
      <Head title={breadcrumbs[breadcrumbs.length - 1].title} />

      <SettingsLayout>
        <div className="space-y-6">
          <HeadingSmall
            title="Profile information"
            description="Profile information is managed through Clerk. Your name is displayed from your Clerk profile."
          />

          <div className="space-y-6">
            <div className="grid gap-2">
              <Label htmlFor="name">Name</Label>

              <Input
                id="name"
                className="mt-1 block w-full"
                value={auth.user.name}
                readOnly
                disabled
                placeholder="Full name"
              />
              <p className="text-sm text-muted-foreground">
                To update your profile information, please visit your Clerk user profile.
              </p>
            </div>
          </div>
        </div>
      </SettingsLayout>
    </AppLayout>
  )
}
