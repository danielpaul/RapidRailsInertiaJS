# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "is publicly accessible without authentication" do
      get root_url
      expect(response).to have_http_status(:success)
    end

    it "does not redirect signed-out visitors to sign in" do
      get root_url
      expect(response).not_to redirect_to(sign_in_url)
    end
  end
end
