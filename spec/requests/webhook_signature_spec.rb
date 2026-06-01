# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Clerk webhook signature verification" do
  let(:controller) { WebhooksController.new }
  let(:secret) { "whsec_#{Base64.strict_encode64("supersecret")}" }
  let(:svix_id) { "msg_#{SecureRandom.hex(8)}" }
  let(:timestamp) { Time.now.to_i.to_s }
  let(:payload) { '{"type":"user.updated","data":{"id":"user_123"}}' }

  def sign(secret, id, ts, body)
    key = Base64.strict_decode64(secret.delete_prefix("whsec_"))
    digest = OpenSSL::HMAC.digest("SHA256", key, "#{id}.#{ts}.#{body}")
    "v1,#{Base64.strict_encode64(digest)}"
  end

  def valid?(signature, body = payload, ts = timestamp)
    controller.send(:valid_signature?, secret, svix_id, ts, signature, body)
  end

  it "accepts a correctly signed payload" do
    expect(valid?(sign(secret, svix_id, timestamp, payload))).to be(true)
  end

  it "rejects a tampered payload" do
    signature = sign(secret, svix_id, timestamp, payload)
    expect(valid?(signature, "tampered")).to be(false)
  end

  it "rejects an invalid signature" do
    expect(valid?("v1,not-a-real-signature")).to be(false)
  end

  it "rejects a stale timestamp (replay protection)" do
    stale = (Time.now - 10.minutes).to_i.to_s
    expect(valid?(sign(secret, svix_id, stale, payload), payload, stale)).to be(false)
  end

  it "rejects a non-numeric timestamp" do
    expect(valid?(sign(secret, svix_id, timestamp, payload), payload, "not-a-timestamp")).to be(false)
  end
end
