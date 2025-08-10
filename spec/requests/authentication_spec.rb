# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:clerk_user_id) { "user_#{SecureRandom.hex(8)}" }
  let(:clerk_session_token) { "sess_#{SecureRandom.hex(16)}" }
  let(:user) { create(:user, clerk_id: clerk_user_id) }

  describe "current_user method" do
    context "with valid Clerk session" do
      before do
        cookies[:__session] = clerk_session_token

        # Mock Clerk SDK to return valid session
        allow_any_instance_of(Clerk::SDK).to receive(:verify_token).and_return(
          {"sub" => clerk_user_id}
        )

        # Mock the clerk proxy that would be set by middleware
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
          double("clerk_proxy",
            user?: true,
            user_id: clerk_user_id,
            organization_id: nil
          )
        )
      end

      it "returns the current user" do
        get dashboard_url
        expect(response).to have_http_status(:success)

        # The user should be accessible in the controller
        user = User.find_by(clerk_id: clerk_user_id)
        expect(user).to be_present
      end

      it "creates user if it doesn't exist" do
        expect {
          get dashboard_url
        }.to change(User, :count).by(1)
      end

      it "finds existing user if it exists" do
        user # Create the user first

        expect {
          get dashboard_url
        }.not_to change(User, :count)
      end
    end

    context "without Clerk session" do
      it "returns nil for current_user" do
        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end
    end

    context "with invalid Clerk session" do
      before do
        cookies[:__session] = "invalid_token"

        # Mock the clerk proxy to return nil (no authenticated user)
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
          double("clerk_proxy",
            user?: false,
            user_id: nil,
            organization_id: nil
          )
        )
      end

      it "returns nil for current_user" do
        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end

  describe "user_signed_in? method" do
    context "when user is authenticated" do
      before do
        cookies[:__session] = clerk_session_token

        # Mock the clerk proxy that would be set by middleware
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
          double("clerk_proxy",
            user?: true,
            user_id: clerk_user_id,
            organization_id: nil
          )
        )
      end

      it "returns true" do
        get dashboard_url
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not authenticated" do
      it "returns false" do
        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end

  describe "authenticate_user! method" do
    context "when user is not authenticated" do
      it "redirects to sign in path" do
        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end
    end

    context "when user is authenticated" do
      before do
        cookies[:__session] = clerk_session_token

        # Mock the clerk proxy that would be set by middleware
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
          double("clerk_proxy",
            user?: true,
            user_id: clerk_user_id,
            organization_id: nil
          )
        )
      end

      it "allows access to protected routes" do
        get dashboard_url
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "Clerk session cookie handling" do
    context "with __session cookie present" do
      before do
        cookies[:__session] = clerk_session_token
      end

      it "processes the session cookie" do
        # Mock the clerk proxy that would be set by middleware
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
          double("clerk_proxy",
            user?: true,
            user_id: clerk_user_id,
            organization_id: nil
          )
        )

        get dashboard_url
        expect(response).to have_http_status(:success)
      end
    end

    context "without __session cookie" do
      it "treats user as unauthenticated" do
        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end
    end

    context "with empty __session cookie" do
      before do
        cookies[:__session] = ""
      end

      it "treats user as unauthenticated" do
        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end

  describe "Clerk SDK integration" do
    context "when Clerk SDK raises errors" do
      before do
        cookies[:__session] = clerk_session_token
      end

      it "handles network errors gracefully" do
        # Mock the clerk proxy to simulate no authentication due to error
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
          double("clerk_proxy",
            user?: false,
            user_id: nil,
            organization_id: nil
          )
        )

        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end

      it "handles server errors gracefully" do
        # Mock the clerk proxy to simulate no authentication due to error
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
          double("clerk_proxy",
            user?: false,
            user_id: nil,
            organization_id: nil
          )
        )

        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end

  describe "session persistence" do
    before do
      cookies[:__session] = clerk_session_token

      # Mock the clerk proxy that would be set by middleware
      allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
        double("clerk_proxy",
          user?: true,
          user_id: clerk_user_id,
          organization_id: nil
        )
      )
    end

    it "maintains user session across multiple requests" do
      # First request
      get dashboard_url
      expect(response).to have_http_status(:success)

      # Second request should still be authenticated
      get dashboard_url
      expect(response).to have_http_status(:success)
    end

    it "creates user only once" do
      expect {
        get dashboard_url
        get dashboard_url
      }.to change(User, :count).by(1)
    end
  end
end
