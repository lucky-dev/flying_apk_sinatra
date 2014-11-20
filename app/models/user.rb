class User < Sequel::Model
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i

  def before_save
    self.email.downcase!
    self.encoded_password = UserHelper.salt_password(self.password)
    self.access_token = UserHelper::generate_access_token(self.name, self.email)
    super
  end

  plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :email]
    validates_max_length 50, :name
    validates_format VALID_EMAIL_REGEX, :email
    validates_unique :email
    # It's a virtual property
    validates_presence :password if @check_password
    validates_min_length 6, :password if @check_password
  end
  one_to_many :permission_apps
  
  # Virtual property
  def password
    @password
  end

  def password=(password)
    @check_password = true
    @password = password
  end
end
