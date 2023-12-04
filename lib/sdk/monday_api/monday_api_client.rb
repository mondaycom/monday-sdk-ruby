# frozen_string_literal: true

# Monday REST API implementation
module Monday
  class Client
    class MondayApiClient
      class << self
        COULD_NOT_PARSE_JSON_RESPONSE_ERROR = 'Could not parse JSON from monday.com\'s GraphQL API response'
        TOKEN_MISSING_ERROR = 'Token is required'

        def execute(query, token, conn, options = {})
          raise(Monday::MondayClientError, TOKEN_MISSING_ERROR) if token.nil? || token.empty?

          url = options[:api_domain]
          path = options[:path] || ''
          headers = options[:headers] || {}
          full_url = url + path

          api_request(full_url, conn, query, token: token, headers: headers)
        end

        private

        def api_request(url, conn, data, token:, headers: {})
          conn.post(
            url,
            data,
            headers.merge('Authorization' => token, 'Content-Type' => 'application/json')
          ).body
        rescue StandardError
          raise(Monday::MondayClientError, COULD_NOT_PARSE_JSON_RESPONSE_ERROR)
        end
      end
    end
  end
end
