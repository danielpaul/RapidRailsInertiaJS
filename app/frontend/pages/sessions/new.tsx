import { SignIn, useAuth } from "@clerk/clerk-react"
import { Head, router } from "@inertiajs/react"
import { useEffect } from "react"

import AuthLayout from "@/layouts/auth-layout"

export default function SignInSignUp() {
  const { isSignedIn } = useAuth()

  useEffect(() => {
    if (isSignedIn) {
      // If user is already signed in, redirect to dashboard
      router.visit("/dashboard")
    }
  }, [isSignedIn])

  return (
    <AuthLayout
      title="Welcome"
      description="Sign in to your account or create a new one"
    >
      <Head title="Sign in" />

      <div className="flex justify-center">
        <SignIn routing="path" path="/sign_in" fallbackRedirectUrl="/switch" />
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
