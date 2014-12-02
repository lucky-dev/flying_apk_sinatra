class AccessToken < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:access_token]
  end

  many_to_one :user
end
