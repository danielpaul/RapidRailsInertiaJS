import { useForm } from "@inertiajs/react"
import { type FormEventHandler } from "react"

import HeadingSmall from "@/components/heading-small"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { usersPath } from "@/routes"

export default function DeleteUser() {
  const {
    delete: destroy,
    processing,
  } = useForm()

  const deleteUser: FormEventHandler = (e) => {
    e.preventDefault()

    destroy(usersPath(), {
      preserveScroll: true,
    })
  }

  return (
    <div className="space-y-6">
      <HeadingSmall
        title="Delete account"
        description="Delete your account and all of its resources"
      />
      <div className="space-y-4 rounded-lg border border-red-100 bg-red-50 p-4 dark:border-red-200/10 dark:bg-red-700/10">
        <div className="relative space-y-0.5 text-red-600 dark:text-red-100">
          <p className="font-medium">Warning</p>
          <p className="text-sm">
            Please proceed with caution, this cannot be undone.
          </p>
        </div>

        <Dialog>
          <DialogTrigger asChild>
            <Button variant="destructive">Delete account</Button>
          </DialogTrigger>
          <DialogContent>
            <DialogTitle>
              Are you sure you want to delete your account?
            </DialogTitle>
            <DialogDescription>
              Once your account is deleted, all of its resources and data will
              also be permanently deleted from both our system and Clerk.
            </DialogDescription>
            <form onSubmit={deleteUser}>
              <DialogFooter>
                <DialogClose asChild>
                  <Button variant="secondary">
                    Cancel
                  </Button>
                </DialogClose>

                <Button variant="destructive" disabled={processing} asChild>
                  <button type="submit">Delete account</button>
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  )
}
