require 'digest/md5'

module BuildHelper
  VALID_ANDROID_APP_REGEX = /(.*)\.(\w+)/i
  
  def self.android_app?(file_name)
    file_info = file_name.match(VALID_ANDROID_APP_REGEX)
    file_info ? file_info.captures[1] == 'apk' : false
  end
  
  def self.generate_build_name(user_name, user_email)
    Digest::MD5.hexdigest("#{user_name}#{user_email}#{Time.now}")
  end
  
  def self.get_build_hash(path_to_build)
    Digest::MD5.file(path_to_build).hexdigest
  end
end
