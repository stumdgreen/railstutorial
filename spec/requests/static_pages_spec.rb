require 'spec_helper'

describe "Static Pages" do
  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading) { 'Sample App' }
    let(:page_title) { '' }
    it_should_behave_like "all static pages"
    it { should_not have_selector('title', text: ' | Home') }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "without any feed items" do
        it { should_not have_selector('ol', class: 'microposts') }
      end

      describe "with one feed item" do
        before do
          FactoryGirl.create(:micropost, user: user)
          sign_in user
          visit root_path
        end

        it { should have_selector('ol', class: 'microposts') }
        it { should have_content("1 micropost") }
      end

      describe "with two feed items" do
        before do
          FactoryGirl.create(:micropost, user: user, content: "Lorem")
          FactoryGirl.create(:micropost, user: user, content: "Ipsum")
          sign_in user
          visit root_path
        end
        
        it { should have_selector('ol', class: 'microposts') }
        it { should have_content("2 microposts") }
        it "should render the user's feed" do
          user.feed.each do |item|
            page.should have_selector("li##{item.id}", text: item.content)
          end
        end

        describe "follower/following counts" do
          let(:other_user) { FactoryGirl.create(:user) }
          before do
            other_user.follow!(user)
            visit root_path
          end

          it { should have_link("0 following", href: following_user_path(user)) }
          it { should have_link("1 followers", href: followers_user_path(user)) }
        end
      end

      describe "with enough feed items to trigger pagination" do
        before do
          40.times { FactoryGirl.create(:micropost, user: user) }
          sign_in user
          visit root_path
        end
        
        it { should have_selector('ol', class: 'microposts') }
        it { should have_content("40 microposts") }
        it "should render the first page of user's feed items" do
          user.feed[0..29].each do |item|
            page.should have_selector("li##{item.id}", text: item.content)
          end
        end
        it "should not render the second page of user's feed items" do
          user.feed[30..39].each do |item|
            page.should_not have_selector("li##{item.id}", text: item.content)
          end
        end

         describe "on the second page of feed items" do
          before { click_link "2" }

          it "should render the second page of feed items" do
            user.feed[30..39].each do |item|
              page.should have_selector("li##{item.id}", text: item.content)
            end
          end
        end
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }
    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }
    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading) { 'Contact Us' }
    let(:page_title) { 'Contact Us' }
    it_should_behave_like "all static pages"
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact Us')
    click_link "Home"
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('')
  end
end
