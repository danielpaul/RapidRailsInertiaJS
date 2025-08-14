import { SignUp, useAuth } from "@clerk/clerk-react"
import { Head, router } from "@inertiajs/react"
import { useEffect } from "react"

import AuthLayout from "@/layouts/auth-layout"

export default function SignUpPage() {
  const { getToken, isSignedIn } = useAuth()

  useEffect(() => {
    const createSession = async () => {
      if (isSignedIn) {
        try {
          const token = await getToken()
          if (token) {
            // Post the clerk token to our backend to create a session
            await fetch("/sign_up", {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token":
                  document
                    .querySelector('meta[name="csrf-token"]')
                    ?.getAttribute("content") ?? "",
              },
              body: JSON.stringify({ clerk_token: token }),
            })

            // Redirect after successful session creation
            router.visit("/dashboard")
          }
        } catch (error) {
          console.error("Failed to create session:", error)
        }
      }
    }

    void createSession()
  }, [isSignedIn, getToken])

  return (
    <AuthLayout
      title="Welcome"
      description="Create your account to get started"
    >
      <Head title="Sign up" />

      <div className="flex justify-center">
        <SignUp routing="path" path="/sign_up" fallbackRedirectUrl="/switch" />
      </div>

      <div className="text-muted-foreground mt-6 text-center text-xs">
        By clicking continue, you agree to our{" "}
        <a href="#" className="hover:text-primary underline underline-offset-4">
          Terms of Service
        </a>{" "}
        and{" "}
        <a href="#" className="hover:text-primary underline underline-offset-4">
          Privacy Policy
        </a>
        .
      </div>
    </AuthLayout>
  )
}
