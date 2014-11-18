module ApiV1
  API_VERSION = 1

  class ApiHandler
    def self.register(email, password)
      user = User.first(email: email)
      if user
        [409, { 'Content-Type' => 'application/json' }, "Not OK"]
      else
        [200, { 'Content-Type' => 'application/json' }, "OK"]
      end
    end
  end
end
