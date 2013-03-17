require 'spec_helper'

describe 'User Page' do
  subject { page }

  describe "index" do

    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { should have_selector('title', text: "All users") }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { should have_link('Next') }
      its(:html) { should match('>2</a>') }
      
      it "should list each user" do
        User.all[0..2].each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do
      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it { should_not have_link('delete', href: user_path(admin)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it "should not be able to delete itself" do
          expect { delete user_path(admin) }.not_to change(User, :count)
        end
      end
    end

    before do
      sign_in FactoryGirl.create(:user)
      FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
      FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")
      visit users_path
    end

    it { should have_selector('title', text: "All users") }

    it "Should list each user" do
      User.all.each do |user|
        page.should have_selector('li', text: user.name)
      end

    end

  end

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

    describe "for a user without microposts" do
      before { visit user_path(user) }
      
      it { should have_selector('h1', text: user.name) }
      it { should have_selector('title', text: user.name) }
      it { should_not have_selector('h3', text: "Microposts (10)") }
    end

    describe "for a user with microposts" do
      before do
        10.times { FactoryGirl.create(:micropost, user: user) }
        visit user_path(user)
      end

      it { should have_selector('h3', text: "Microposts (10)") }
    end

    describe "follow/unfollow button" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it { should have_selector('input', value: "follow") }

        it "should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_selector("input", value: "Unfollow") }
        end
      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_selector('input', value: "follow") }
        end
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end
    
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

  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_selector('title', text: full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_selector('title', text: full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
end