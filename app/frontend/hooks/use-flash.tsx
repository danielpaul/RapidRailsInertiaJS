import { router, usePage } from "@inertiajs/react"
import { useEffect, useState } from "react"
import { toast } from "sonner"

import type { Flash } from "@/types"

const emptyFlash = {}

export const useFlash = () => {
  const { flash } = usePage<{ flash: Flash }>().props
  const [currentFlash, setCurrentFlash] = useState<Flash>(emptyFlash)

  useEffect(() => {
    setCurrentFlash(flash)
  }, [flash])

  useEffect(() => {
    // Clear stale flash messages as soon as a new visit starts. `router.on`
    // returns an unsubscribe callback that must run on unmount to avoid leaking
    // a new listener on every render.
    return router.on("start", () => {
      setCurrentFlash(emptyFlash)
    })
  }, [])

  useEffect(() => {
    if (currentFlash.alert) {
      toast.error(currentFlash.alert)
    }
    if (currentFlash.notice) {
      toast(currentFlash.notice)
    }
  }, [currentFlash])
}
