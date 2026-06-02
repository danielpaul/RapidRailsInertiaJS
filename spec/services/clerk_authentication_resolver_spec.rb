# frozen_string_literal: true

require "rails_helper"

RSpec.describe ClerkAuthenticationResolver do
  # Build a Clerk-proxy-like double. Pass include_role: false / include_org: false
  # to omit the organization_role / organization_id messages entirely. Omitting
  # the org messages mirrors a Clerk instance with organizations disabled, which
  # the service must tolerate via respond_to?.
  def clerk_double(user_id:, organization_id: nil, organization_role: nil, include_role: true, include_org: true)
    attrs = {user_id:}
    attrs[:organization_id] = organization_id if include_org
    attrs[:organization_role] = organization_role if include_role
    double("clerk_proxy", **attrs)
  end

  # A proxy from a Clerk instance with organizations disabled: no org methods.
  def clerk_double_without_orgs(user_id:)
    clerk_double(user_id:, include_org: false, include_role: false)
  end

  it "returns nil for everything when clerk is nil" do
    resolver = described_class.new(nil)

    expect(resolver.user).to be_nil
    expect(resolver.org).to be_nil
    expect(resolver.role).to be_nil
  end

  describe "#user" do
    let(:clerk) { clerk_double(user_id: "user_abc", organization_id: nil) }

    it "finds or creates the user" do
      expect { described_class.new(clerk).user }.to change(User, :count).by(1)
      expect(User.find_by(clerk_id: "user_abc")).to be_present
    end

    it "does not recreate an existing user" do
      create(:user, clerk_id: "user_abc")

      expect { described_class.new(clerk).user }.not_to change(User, :count)
    end

    it "resolves the user WITHOUT touching orgs, even when an org is present" do
      with_org = clerk_double(user_id: "user_abc", organization_id: "org_xyz", organization_role: "org:admin")
      resolver = described_class.new(with_org)

      expect { resolver.user }.not_to change(Org, :count)
    end

    it "recovers from a concurrent-creation race instead of raising" do
      existing = create(:user, clerk_id: "user_abc")
      # Simulate losing the INSERT race: the unique index rejects the create.
      allow(User).to receive(:find_or_create_by).and_raise(ActiveRecord::RecordNotUnique)

      expect(described_class.new(clerk).user).to eq(existing)
    end
  end

  describe "#org" do
    it "finds or creates the Org anchor for the active org" do
      clerk = clerk_double(user_id: "user_abc", organization_id: "org_xyz", organization_role: "org:admin")

      expect { described_class.new(clerk).org }.to change(Org, :count).by(1)
      expect(Org.find_by(clerk_org_id: "org_xyz")).to be_present
    end

    it "finds the existing Org anchor instead of creating a duplicate" do
      create(:org, clerk_org_id: "org_xyz")
      clerk = clerk_double(user_id: "user_abc", organization_id: "org_xyz")

      expect { described_class.new(clerk).org }.not_to change(Org, :count)
    end

    it "is nil when the user is in no organization (mixed setup)" do
      existing_org = create(:org)
      clerk = clerk_double(user_id: "user_abc", organization_id: nil)

      resolver = described_class.new(clerk)
      expect { resolver.org }.not_to change(Org, :count)
      expect(resolver.org).to be_nil
      expect(Org.exists?(existing_org.id)).to be(true) # unrelated orgs untouched
    end

    it "is nil and does not raise when Clerk organizations are disabled" do
      resolver = described_class.new(clerk_double_without_orgs(user_id: "user_abc"))

      expect { resolver.org }.not_to change(Org, :count)
      expect(resolver.org).to be_nil
    end

    it "resolves the org anchor even when there is no user" do
      clerk = clerk_double(user_id: nil, organization_id: "org_xyz", organization_role: "org:admin")

      resolver = described_class.new(clerk)
      expect(resolver.user).to be_nil
      expect(resolver.org).to eq(Org.find_by(clerk_org_id: "org_xyz"))
    end
  end

  describe "#role" do
    it "is read live from the token, not persisted" do
      clerk = clerk_double(user_id: "user_abc", organization_id: "org_xyz", organization_role: "org:admin")
      expect(described_class.new(clerk).role).to eq("org:admin")

      promoted = clerk_double(user_id: "user_abc", organization_id: "org_xyz", organization_role: "org:member")
      expect(described_class.new(promoted).role).to eq("org:member")
    end

    it "is nil when the proxy does not expose organization_role" do
      clerk = clerk_double(user_id: "user_abc", organization_id: "org_xyz", include_role: false)

      expect(described_class.new(clerk).role).to be_nil
    end
  end
end
