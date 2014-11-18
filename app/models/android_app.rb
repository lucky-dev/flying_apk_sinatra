class AndroidApp < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :description]
    validates_max_length 50, :name
    validates_max_length 140, :description
  end
  one_to_many :builds
  one_to_many :permission_apps
end
