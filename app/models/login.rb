module Login
  extend self

  def valid?(encrypted_username, encrypted_password)
    encrypted_username == Settings.secrets.login_encrypted_username &&
      encrypted_password == Settings.secrets.login_encrypted_password
  end

  def encrypt_username(username)
    Digest::SHA256.hexdigest(username)
  end

  def encrypt_password(password)
    Digest::SHA256.hexdigest("#{password} #{Settings.secrets.login_salt}")
  end
end
