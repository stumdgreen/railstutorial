require 'spec_helper'

describe UsersHelper do

  describe "gravatar_for" do
    before { @user = User.new(name: "name", email: "test@test.com", password: "foobar", password_confirmation: "foobar") }
    let(:gravatar) { gravatar_for(@user) }

    it "should show a generic gravatar for a false email" do
      # @TODO: Write tests for the gravatar_for method
    end

  end

end
