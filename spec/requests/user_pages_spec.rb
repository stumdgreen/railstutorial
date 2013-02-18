require 'spec_helper'

describe 'User Page' do
  subject { page }

  describe 'signup page' do
    before { visit signup_path }
    let(:submit) { 'submit_user_form' }
    it { should have_selector('h1', text: 'Sign up') }
    it { should have_selector('title', text: full_title('Sign up')) }

    describe 'with invalid information' do
      it 'should not create a user' do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe 'after submission' do

        describe 'with no entries' do
          before { click_button submit }
          it { should have_content('error') }
          it { should have_content('Name can\'t be blank') }
          it { should have_content('Email can\'t be blank') }
          it { should have_content('Password can\'t be blank') }
          it { should_not have_content('digest') }
        end

        describe 'with invalid email' do
          before do
            fill_in 'user_email', with: 'bad@email'
            click_button submit
          end
          it { should have_content('Email is invalid') }
        end

        describe 'with short password' do
          before do
            fill_in 'user_password', with: 'a'
            click_button submit
          end
          it { should have_content('Password is too short') }
        end

        describe 'with mismatching password confirmation' do
          before do
            fill_in 'user_password', with: 'aaaaaa'
            fill_in 'user_password_confirmation', with: 'bbbbbb'
            click_button submit
          end
          it { should have_content('Password doesn\'t match confirmation') }
        end

      end

    end

    describe 'with valid information' do
      before do
        fill_in 'user_name', with: 'Example User'
        fill_in 'user_email', with: 'Example@User.com'
        fill_in 'user_password', with: 'foobar'
        fill_in 'user_password_confirmation', with: 'foobar'
      end
      it 'should create a user' do
        expect { click_button submit }.to change(User, :count)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('example@user.com') }
        it { should have_selector('title', text: user.name) }
        it { should have_selector('.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign out') }

        describe "followed by signout" do
          before { click_link "Sign out" }
          it { should have_link('Sign in') }
        end
      end

    end
  end

  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }
    it { should have_selector('h1', text: user.name) }
    it { should have_selector('title', text: user.name) }
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit edit_user_path(user) }
    
    describe "page" do
      it { should have_selector('h1', text: "Update your profile") }
      it { should have_selector('title', text: "Edit user") }
      it { should have_link('change', href: '//gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirm", with: user.password
        click_button "Save changes"
      end
      it { should have_selector('title', text: new_name) }
      it { should have_selector('.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end
end
