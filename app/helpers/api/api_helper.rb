module ApiHelper
  VALID_APP_TYPE_REGEX = /application\/vnd\.(\w*);\s*version=(\d+)/i

  def self.get_api_version(header_accept)
    if header_accept
      header = header_accept.match(VALID_APP_TYPE_REGEX)

      is_valid_type_app = (header && !header.captures.empty? && header.captures[0] == 'flyingapk')

      if (is_valid_type_app)
        return header.captures[1] ? header.captures[1].to_i : 0
      end
    end

    return 0
  end

  def self.response(status)
    [ status, { 'Content-Type' => 'application/json' }, yield.to_json ]
  end
end
