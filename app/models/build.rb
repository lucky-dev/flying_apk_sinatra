class Sequel::Model
  def validates_constant(type)
    errors.add(type, 'must be debug or release') if ((send(type) != 'debug') && (send(type) != 'release'))
  end
end

class Build < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:version, :fixes]
    validates_max_length 10, :version
    validates_max_length 140, :fixes
    validates_constant :type
  end
  many_to_one :android_app
end
