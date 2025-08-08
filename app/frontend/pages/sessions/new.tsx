import { SignIn, useAuth } from "@clerk/clerk-react"
import { Head, router } from "@inertiajs/react"
import { useEffect } from "react"

import AuthLayout from "@/layouts/auth-layout"

export default function SignInSignUp() {
  const { getToken, isSignedIn } = useAuth()

  useEffect(() => {
    const createSession = async () => {
      if (isSignedIn) {
        try {
          const token = await getToken()
          if (token) {
            // Post the clerk token to our backend to create a session
            await fetch('/sign_in', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
              },
              body: JSON.stringify({ clerk_token: token })
            })
            
            // Redirect after successful session creation
            router.visit('/dashboard')
          }
        } catch (error) {
          console.error('Failed to create session:', error)
        }
      }
    }

    createSession()
  }, [isSignedIn, getToken])

  return (
    <AuthLayout
      title="Welcome"
      description="Sign in to your account or create a new one"
    >
      <Head title="Sign in" />
      
      <div className="flex justify-center">
        <SignIn 
          routing="path"
          path="/sign_in"
          fallbackRedirectUrl="/switch"
        />
      </div>
      
      <div className="mt-6 text-center text-xs text-muted-foreground">
        By clicking continue, you agree to our{" "}
        <a href="#" className="underline underline-offset-4 hover:text-primary">
          Terms of Service
        </a>{" "}
        and{" "}
        <a href="#" className="underline underline-offset-4 hover:text-primary">
          Privacy Policy
        </a>
        .
      </div>
    </AuthLayout>
  )
}
