class PermissionApp < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:permission]
  end

  many_to_one :user
  many_to_one :android_app
end
