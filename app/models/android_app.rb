class AndroidApp < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :description]
    validates_max_length 50, :name
    validates_max_length 140, :description
    validates_unique :name, :where => (proc do |ds, obj, cols|
      ds.where(cols.map do |c|
        v = obj.send(c)
        v = v.downcase if v
        [Sequel.function(:lower, c), v]
      end)
    end)
  end
  one_to_many :builds
  one_to_many :permission_apps
end
