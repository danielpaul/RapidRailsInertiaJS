# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /sign_in" do
    context "when user is not signed in" do
      it "returns http success" do
        get sign_in_url
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is already signed in" do
      before { sign_in_as user }

      it "redirects to root with notice" do
        get sign_in_url
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("You are already signed in")
      end
    end
  end

  describe "GET /switch" do
    context "when user is signed in" do
      before { sign_in_as user }

      it "returns http success" do
        get switch_account_url
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        get switch_account_url
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end

  describe "Clerk Authentication" do
    let(:clerk_user_id) { "user_#{SecureRandom.hex(8)}" }
    let(:clerk_session_token) { "sess_#{SecureRandom.hex(16)}" }

    context "with valid __session cookie" do
      before do
        # Set up the __session cookie that Clerk would provide
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

      it "authenticates user via __session cookie" do
        # First request should create the user
        expect {
          get dashboard_url
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:success)

        # Verify the user was created with the correct clerk_id
        user = User.find_by(clerk_id: clerk_user_id)
        expect(user).to be_present
      end

      it "finds existing user on subsequent requests" do
        # Create user first
        existing_user = create(:user, clerk_id: clerk_user_id)

        # Second request should find existing user
        expect {
          get dashboard_url
        }.not_to change(User, :count)

        expect(response).to have_http_status(:success)
      end
    end

    context "without __session cookie" do
      it "redirects to sign in" do
        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end

      it "does not create any users" do
        expect {
          get dashboard_url
        }.not_to change(User, :count)
      end
    end

    context "with invalid __session cookie" do
      before do
        cookies[:__session] = "invalid_session_token"

        # Mock the clerk proxy to return no authenticated user
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
          double("clerk_proxy",
            user?: false,
            user_id: nil,
            organization_id: nil
          )
        )
      end

      it "redirects to sign in" do
        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end

      it "does not create any users" do
        expect {
          get dashboard_url
        }.not_to change(User, :count)
      end
    end

    context "with expired __session cookie" do
      before do
        cookies[:__session] = "expired_session_token"

        # Mock the clerk proxy to return no authenticated user
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
          double("clerk_proxy",
            user?: false,
            user_id: nil,
            organization_id: nil
          )
        )
      end

      it "redirects to sign in" do
        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end
end
