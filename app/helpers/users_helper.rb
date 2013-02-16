module UsersHelper

  # Returns the Gravater (http://gravatar.com) for a given user
  def gravatar_for(user, options = { size: 50 } )
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "//secure.gravatar.com/avatar/#{gravatar_id}?s=#{options[:size]}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
