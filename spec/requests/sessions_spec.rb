# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /new" do
    it "returns http success" do
      get sign_in_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /sign_in" do
    context "with Clerk authentication" do
      it "redirects to dashboard" do
        # Clerk handles authentication on frontend, this just redirects
        post sign_in_url
        expect(response).to redirect_to(dashboard_url)
      end
    end
  end

  describe "DELETE /sign_out" do
    before { sign_in_as user }

    it "signs out the user and redirects to root" do
      delete session_url(user.sessions.last)
      expect(response).to redirect_to(root_url)
    end
  end
end
