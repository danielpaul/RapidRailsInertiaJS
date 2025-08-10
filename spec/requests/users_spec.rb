# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }

  describe "DELETE /users" do
    context "when user is signed in" do
      before do 
        sign_in_as user
        
        # Mock Clerk API to prevent actual API calls
        allow_any_instance_of(Clerk::SDK).to receive_message_chain(:users, :delete_user).and_return(true)
      end

      it "deletes the current user and redirects to root" do
        expect {
          delete users_url
        }.to change(User, :count).by(-1)

        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        delete users_url
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end
end
