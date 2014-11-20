module ApiHelper
  VALID_APP_TYPE_REGEX = /application\/vnd\.(\w*);\s*version=(\d+)/i

  def self.get_api_version(header_accept)
    header = header_accept.match(VALID_APP_TYPE_REGEX)

    is_valid_type_app = (header && !header.captures.empty? && header.captures[0] == 'flyingapp')

    if (is_valid_type_app)
      return header.captures[1].to_i if (header.captures.size >= 2)
    end

    return 0
  end

  def self.response(status)
    [ status, { 'Content-Type' => 'application/json' }, yield.to_json ]
  end
end
