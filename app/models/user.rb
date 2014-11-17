class User < Sequel::Model
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  
  def before_save
    self.email.downcase!
    super
  end

  plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :email, :password]
    validates_max_length 50, :name
    validates_format VALID_EMAIL_REGEX, :email
    validates_min_length 6, :password
  end
end
