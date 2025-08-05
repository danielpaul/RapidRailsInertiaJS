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
    context "with valid Clerk token" do
      it "creates a session and returns success" do
        post sign_in_url, params: { clerk_token: "valid_token" }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)["success"]).to be true
      end
    end

    context "without Clerk token" do
      it "returns unprocessable entity" do
        post sign_in_url, params: {}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid token")
      end
    end
  end

  describe "DELETE /sign_out" do
    before { sign_in_as user }

    it "signs out the user and redirects to root" do
      delete session_url(user)
      expect(response).to redirect_to(root_url)
    end
  end
end
