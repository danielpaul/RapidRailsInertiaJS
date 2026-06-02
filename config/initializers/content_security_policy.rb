# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.base_uri    :self
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, :blob
    policy.object_src  :none

    # Scripts: app bundles are served from :self; Clerk loads its widget script
    # from its CDN. We deliberately avoid :unsafe_inline here.
    policy.script_src :self, :https, "https://*.clerk.accounts.dev"

    # React/Tailwind emit inline styles, so :unsafe_inline is required for styles.
    policy.style_src :self, :https, :unsafe_inline

    # XHR/fetch targets: Clerk's API and Sentry's ingest endpoints.
    policy.connect_src :self, :https,
      "https://*.clerk.accounts.dev",
      "https://*.sentry.io",
      "https://*.ingest.sentry.io"

    policy.worker_src :self, :blob
    policy.frame_src  :self, "https://*.clerk.accounts.dev"

    if Rails.env.development?
      # Allow @vite/client to hot reload code and styles in development.
      vite_origin = "http://#{ViteRuby.config.host_with_port}"
      vite_ws = "ws://#{ViteRuby.config.host_with_port}"
      policy.script_src(*policy.script_src, :unsafe_eval, vite_origin)
      policy.connect_src(*policy.connect_src, vite_origin, vite_ws)
    end

    # Allow the SSR/test bundle to inline scripts when needed.
    policy.script_src(*policy.script_src, :blob) if Rails.env.test?
  end

  # Start in report-only mode so violations are logged without breaking the
  # application. Once you have confirmed there are no legitimate violations in
  # your environment, flip this to enforce the policy.
  config.content_security_policy_report_only = true
end
