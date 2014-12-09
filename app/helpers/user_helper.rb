require 'digest/md5'

module UserHelper
  def self.salt_password(password)
    Digest::MD5.hexdigest("#{password}#{FlyingApk::App::PASSWORD_SALT}")
  end
  
  def self.equal_passwords?(original_password, encoded_password)
    Digest::MD5.hexdigest("#{original_password}#{FlyingApk::App::PASSWORD_SALT}") == encoded_password
  end
  
  def self.generate_access_token(user_name, user_email)
    Digest::MD5.hexdigest("#{user_name}#{user_email}#{Time.now}")
  end
end
