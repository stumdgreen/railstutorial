FactoryGirl.define do
  factory :user do
    name "Test User"
    email "testuser@testuser.com"
    password "foobar"
    password_confirmation "foobar"
  end
end
