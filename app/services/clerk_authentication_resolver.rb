# frozen_string_literal: true

# Resolves the domain records (User, Org) for a request from the Clerk session
# proxy. Extracted from the Authenticatable concern so the find-or-create-on-read
# logic lives in one testable place.
#
# User and Org are thin local ID anchors so app-owned data can reference them by
# foreign key — they intentionally do NOT mirror Clerk-managed data. The user's
# role in the active org is read straight from the token (Clerk is the source of
# truth) rather than persisted, so it can never drift.
#
# Each attribute is resolved lazily and memoized, so a caller that only needs the
# user (the common path, via authenticate_user!) never pays for an Org lookup —
# the org is found/created only when #org or #role is actually accessed.
#
# Organizations are optional: this works whether Clerk orgs are disabled entirely
# (the proxy may not expose org methods at all) or enabled but the current user is
# in a personal/no-org context. In those cases org and role are simply nil and the
# user still resolves.
class ClerkAuthenticationResolver
  def self.call(clerk)
    new(clerk)
  end

  def initialize(clerk)
    @clerk = clerk
  end

  def user
    return @user if defined?(@user)

    @user = (user_id = clerk&.user_id) ? find_or_create(User, clerk_id: user_id) : nil
  end

  def org
    return @org if defined?(@org)

    @org = (org_id = clerk_organization_id) ? find_or_create(Org, clerk_org_id: org_id) : nil
  end

  def role
    return @role if defined?(@role)

    @role = clerk_organization_role
  end

  private

  attr_reader :clerk

  # find_or_create_by keeps the common path a single SELECT, but a concurrent
  # first-time resolve can lose the INSERT race and raise RecordNotUnique (the
  # unique index enforces it). Retry the lookup so that becomes a hit, not a 500.
  #
  # NOTE: create_or_find_by is unsuitable here — these models validate uniqueness,
  # so on the common already-exists path its `create` fails validation, never
  # issues an INSERT, and returns an invalid unsaved record instead of the row.
  def find_or_create(model, attributes)
    model.find_or_create_by(attributes)
  rescue ActiveRecord::RecordNotUnique
    model.find_by!(attributes)
  end

  # When Clerk orgs are disabled the proxy may not expose org methods at all,
  # so guard with respond_to? before calling them.
  def clerk_organization_id
    return nil unless clerk.respond_to?(:organization_id)

    clerk.organization_id
  end

  def clerk_organization_role
    return nil unless clerk.respond_to?(:organization_role)

    clerk.organization_role
  end
end
