# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Webhooks", type: :request do
  let(:user) { create(:user) }

  describe "POST /webhooks/clerk" do
    before do
      # Mock webhook signature verification to always pass
      allow_any_instance_of(WebhooksController).to receive(:verify_webhook_signature).and_return(nil)
      # Mock webhook headers
      allow_any_instance_of(ActionDispatch::Request).to receive(:headers).and_return(
        double("headers",
          "svix-signature" => "test_signature",
          "svix-timestamp" => "1234567890",
          "svix-id" => "test_id"
        )
      )
    end

    context "when user.deleted event is received" do
      it "deletes the user from our database" do
        user_id = user.id
        clerk_id = user.clerk_id

        post webhooks_clerk_url, params: {
          type: "user.deleted",
          data: {id: clerk_id}
        }

        expect(response).to have_http_status(:ok)
        expect(User.find_by(id: user_id)).to be_nil
      end

      it "logs when user is not found" do
        expect(Rails.logger).to receive(:warn).with("User with clerk_id invalid_id not found for deletion")

        post webhooks_clerk_url, params: {
          type: "user.deleted",
          data: {id: "invalid_id"}
        }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when user.updated event is received" do
      it "clears the user cache" do
        expect(Rails.cache).to receive(:delete).with("clerk_user/#{user.clerk_id}")

        post webhooks_clerk_url, params: {
          type: "user.updated",
          data: {id: user.clerk_id}
        }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
