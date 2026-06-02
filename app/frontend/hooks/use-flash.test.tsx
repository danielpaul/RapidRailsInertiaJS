import { renderHook } from "@testing-library/react"
import { afterEach, describe, expect, it, vi } from "vitest"

import { useFlash } from "@/hooks/use-flash"

const mocks = vi.hoisted(() => {
  const unsubscribe = vi.fn()
  const flash: { alert?: string; notice?: string } = {}
  return {
    unsubscribe,
    routerOn: vi.fn(() => unsubscribe),
    toast: Object.assign(vi.fn(), { error: vi.fn() }),
    page: { props: { flash } },
  }
})

vi.mock("@inertiajs/react", () => ({
  usePage: () => mocks.page,
  router: { on: mocks.routerOn },
}))

vi.mock("sonner", () => ({ toast: mocks.toast }))

afterEach(() => {
  vi.clearAllMocks()
  mocks.page.props.flash = {}
})

describe("useFlash", () => {
  it("shows a toast for notice messages", () => {
    mocks.page.props.flash = { notice: "Saved" }
    renderHook(() => {
      useFlash()
    })
    expect(mocks.toast).toHaveBeenCalledWith("Saved")
  })

  it("shows an error toast for alert messages", () => {
    mocks.page.props.flash = { alert: "Something went wrong" }
    renderHook(() => {
      useFlash()
    })
    expect(mocks.toast.error).toHaveBeenCalledWith("Something went wrong")
  })

  it("subscribes to router 'start' and unsubscribes on unmount", () => {
    const { unmount } = renderHook(() => {
      useFlash()
    })
    expect(mocks.routerOn).toHaveBeenCalledWith("start", expect.any(Function))
    expect(mocks.unsubscribe).not.toHaveBeenCalled()

    unmount()
    expect(mocks.unsubscribe).toHaveBeenCalledTimes(1)
  })
})
