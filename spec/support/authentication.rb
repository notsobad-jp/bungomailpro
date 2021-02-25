module AuthenticationForRequest
  def login(user)
    user.generate_magic_login_token!
    send(:get, auth_path, params: { token: user.magic_login_token })
  end
end
