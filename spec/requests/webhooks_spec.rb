# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Webhooks", type: :request do
  let(:user) { create(:user) }

  describe "POST /webhooks/clerk" do
    before do
      # Mock webhook signature verification to always pass
      allow_any_instance_of(WebhooksController).to receive(:verify_webhook_signature).and_return(nil)
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

    context "when an unhandled event type is received" do
      it "logs the event and still responds 200 so Svix does not retry" do
        allow(Rails.logger).to receive(:info)

        post webhooks_clerk_url, params: {
          type: "user.created",
          data: {id: "user_unhandled"}
        }

        expect(Rails.logger).to have_received(:info).with("Unhandled Clerk webhook event: user.created")
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the same delivery is retried (idempotency)" do
      it "processes a given svix-id only once" do
        # Use a real cache store so the unless_exist guard actually persists
        # (the test environment defaults to :null_store).
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
        headers = {"svix-id" => "msg_duplicate"}

        post webhooks_clerk_url,
          params: {type: "user.deleted", data: {id: user.clerk_id}},
          headers: headers
        expect(response).to have_http_status(:ok)
        expect(User.find_by(id: user.id)).to be_nil

        # A replay of the same delivery must be ignored, even though a new user
        # now exists with the same clerk_id.
        recreated = create(:user, clerk_id: user.clerk_id)
        post webhooks_clerk_url,
          params: {type: "user.deleted", data: {id: user.clerk_id}},
          headers: headers
        expect(response).to have_http_status(:ok)
        expect(User.find_by(id: recreated.id)).to be_present
      end

      it "releases the claim when the handler fails so a retry can reprocess" do
        cache = ActiveSupport::Cache::MemoryStore.new
        allow(Rails).to receive(:cache).and_return(cache)
        allow_any_instance_of(User).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)
        headers = {"svix-id" => "msg_failed"}

        expect {
          post webhooks_clerk_url,
            params: {type: "user.deleted", data: {id: user.clerk_id}},
            headers: headers
        }.to raise_error(ActiveRecord::RecordNotDestroyed)

        # The idempotency claim must be cleared so Svix's retry is not skipped.
        expect(cache.exist?("webhooks/clerk/msg_failed")).to be(false)
      end
    end
  end
end
