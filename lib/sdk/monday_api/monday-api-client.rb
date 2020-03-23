# Monday REST API implementation
module Monday
  class Client

    private
    class MondayApiClient

      class << self

        COULD_NOT_PARSE_JSON_RESPONSE_ERROR = 'Could not parse JSON from monday.com\'s GraphQL API response'.freeze
        TOKEN_IS_REQUIRED_ERROR = 'Token is required'.freeze

        private
        def apiRequest(url, conn, data, token)
          begin
            res = conn.post(url, data.to_json,
                            'Authorization' => token, 'Content-Type' => 'application/json')
            res.body.to_json
          rescue StandardError => e
            raise Monday::MondayClientError.new COULD_NOT_PARSE_JSON_RESPONSE_ERROR.to_s
          end

        end

        public
        def execute(query, token,conn, options = {})
          if token.nil? || token.empty?
            raise Monday::MondayClientError.new TOKEN_MISSING_ERROR.to_s
          end

          url = options[:api_domain]
          path = options[:path] || ""
          full_url = url + path

          apiRequest(full_url, conn, query, token)
        end
      end
    end
  end
end

