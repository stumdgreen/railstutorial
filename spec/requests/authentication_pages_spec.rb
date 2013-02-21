require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "sign-in page" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }
      it { should have_selector('h1', text: 'Sign in') }
      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('.alert.alert-error') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in(user) }
      it { should have_selector('title', text: user.name) }
      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should_not have_link('Sign in', href: signin_path) }
    end
  end

  describe "Authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do
        before { visit edit_user_path(user) }
        it { should have_selector('title', text: 'Sign in') }

        describe "Visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: "Sign in") }
        end
      end

      describe "submitting to the update action" do
        before { put user_path(user) }
        specify { response.should redirect_to(signin_path) }
      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do
          it "Should render the originally requested protected page" do
            page.should have_selector('title', text: "Edit user")
          end
        end
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "Visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end

      describe "PUT request to Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }
      before { sign_in non_admin }
      
      describe "DELETE request to Users#destroy" do
        before { delete user_path(user) }
        specify { response. should redirect_to(root_path) }
      end

    end
  end
end
