import { type FC } from "react"

const SentryTest: FC<{ test_type: string; message: string }> = ({ test_type, message }) => {
  const triggerFrontendError = () => {
    // This will trigger a frontend error for Sentry testing
    throw new Error("Test error from React frontend - this should be captured by Sentry in production")
  }

  const triggerPerformanceTest = () => {
    // Simulate some expensive operation for performance monitoring
    const start = Date.now()
    while (Date.now() - start < 100) {
      // Busy wait for 100ms
    }
    console.log("Performance test completed")
  }

  return (
    <div className="container mx-auto py-8">
      <h1 className="text-2xl font-bold mb-4">Sentry Error Tracking Test</h1>
      <p className="mb-4">{message}</p>
      
      <div className="space-y-4">
        {test_type === "frontend_error" && (
          <div>
            <h2 className="text-lg font-semibold mb-2">Frontend Error Test</h2>
            <button
              type="button"
              onClick={triggerFrontendError}
              className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
            >
              Trigger Frontend Error
            </button>
            <p className="text-sm text-gray-600 mt-2">
              This will only be captured by Sentry in production builds.
            </p>
          </div>
        )}
        
        {test_type === "performance" && (
          <div>
            <h2 className="text-lg font-semibold mb-2">Performance Test</h2>
            <button
              type="button"
              onClick={triggerPerformanceTest}
              className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            >
              Run Performance Test
            </button>
            <p className="text-sm text-gray-600 mt-2">
              This will be monitored by Sentry performance tracking in production.
            </p>
          </div>
        )}
      </div>
      
      <div className="mt-8 p-4 bg-yellow-50 border border-yellow-200 rounded">
        <h3 className="font-semibold text-yellow-800 mb-2">Note:</h3>
        <p className="text-yellow-700 text-sm">
          Sentry is only active in production environment. In development, errors will only appear in the browser console.
        </p>
      </div>
    </div>
  )
}

export default SentryTest