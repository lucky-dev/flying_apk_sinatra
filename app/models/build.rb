class Build < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:version, :fixes]
    validates_max_length 10, :version
    validates_max_length 140, :fixes
  end
  many_to_one :android_app
end
