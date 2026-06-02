import { Component, type ErrorInfo, type ReactNode } from "react"

import { buttonVariants } from "@/components/ui/button"

interface ErrorBoundaryProps {
  children: ReactNode
}

interface ErrorBoundaryState {
  hasError: boolean
}

// Top-level error boundary so an unexpected client render error degrades to a
// recoverable message instead of a blank screen. React error boundaries must
// be class components.
export class ErrorBoundary extends Component<
  ErrorBoundaryProps,
  ErrorBoundaryState
> {
  state: ErrorBoundaryState = { hasError: false }

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { hasError: true }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error("Unhandled rendering error:", error, errorInfo)

    // Report to Sentry when it is active (same guard as the init in
    // entrypoints/inertia.ts). captureException is a no-op if Sentry was never
    // initialized, and the dynamic import keeps Sentry out of the dev bundle.
    if (import.meta.env.PROD && import.meta.env.VITE_SENTRY_DSN) {
      void import("@sentry/react").then((Sentry) => {
        Sentry.captureException(error, {
          contexts: { react: { componentStack: errorInfo.componentStack } },
        })
      })
    }
  }

  handleReload = () => {
    window.location.reload()
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex min-h-screen flex-col items-center justify-center gap-4 p-6 text-center">
          <h1 className="text-xl font-semibold">Something went wrong</h1>
          <p className="text-muted-foreground max-w-md">
            An unexpected error occurred. Try reloading the page, and if the
            problem persists please contact support.
          </p>
          <button
            type="button"
            onClick={this.handleReload}
            className={buttonVariants()}
          >
            Reload page
          </button>
        </div>
      )
    }

    return this.props.children
  }
}
