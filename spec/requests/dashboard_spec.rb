# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /dashboard" do
    context "when signed in" do
      let(:user) { create(:user) }

      before { sign_in_as user }

      it "returns http success" do
        get dashboard_url
        expect(response).to have_http_status(:success)
      end
    end

    context "when signed out" do
      it "redirects to sign in" do
        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end
end
