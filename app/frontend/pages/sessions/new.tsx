import { SignIn } from "@clerk/clerk-react"
import { Head } from "@inertiajs/react"

import AuthLayout from "@/layouts/auth-layout"

export default function SignInSignUp() {
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
          redirectUrl="/dashboard"
          fallbackRedirectUrl="/switch"
          appearance={{
            elements: {
              rootBox: "w-full max-w-md",
              card: "shadow-none border-0 bg-transparent",
            }
          }}
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
