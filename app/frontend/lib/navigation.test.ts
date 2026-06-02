import { describe, expect, it } from "vitest"

import { footerNavItems, mainNavItems } from "@/lib/navigation"

describe("navigation config", () => {
  it("exposes a single dashboard item in the main nav", () => {
    expect(mainNavItems).toHaveLength(1)
    expect(mainNavItems[0]).toMatchObject({ title: "Dashboard" })
    expect(mainNavItems[0].href).toBeTruthy()
  })

  it("exposes external resource links in the footer nav", () => {
    const titles = footerNavItems.map((item) => item.title)
    expect(titles).toContain("Repository")
    expect(titles).toContain("Documentation")

    for (const item of footerNavItems) {
      expect(item.href).toMatch(/^https?:\/\//)
    }
  })
})
