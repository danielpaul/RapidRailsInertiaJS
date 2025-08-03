import { Head } from "@inertiajs/react"
import { SignIn } from "@clerk/clerk-react"

import AuthLayout from "@/layouts/auth-layout"

export default function Login() {
  return (
    <AuthLayout
      title="Sign in to your account"
      description="Welcome back! Sign in to continue"
    >
      <Head title="Sign in" />
      
      <div className="flex justify-center">
        <SignIn 
          routing="path"
          path="/sign_in"
          redirectUrl="/dashboard"
          appearance={{
            elements: {
              rootBox: "w-full max-w-md",
              card: "shadow-none border-0 bg-transparent",
            }
          }}
        />
      </div>
    </AuthLayout>
  )
}
