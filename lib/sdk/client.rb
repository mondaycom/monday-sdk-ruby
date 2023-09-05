# frozen_string_literal: true

# Monday Client implementation
module Monday
  class MondayClientError < StandardError; end

  class Client
    TOKEN_MISSING_ERROR = "Should send 'token' as an option or call mondaySdk.setToken(TOKEN)"

    def initialize(options = {})
      @token = options[:token] # @type string , Client token provided by monday.com
      @api_domain = options[:api] # @type string (optional) monday api domain can be changed, default defined in constants
      @connection = options[:conn] # dependency injection for testing
    end

    # Main entry point to the client
    def api(query, options = {})
      token = options[:token] || @token

      raise(MondayClientError, TOKEN_MISSING_ERROR) if token.nil? || token.empty?

      params = {}
      params[:query] = query
      params[:variables] = options[:variables] || {}

      options[:api_domain] = api_domain

      MondayApiClient.execute(params, token, connection, options)
    end

    private

    def api_domain
      @api_domain ||= MONDAY_API_URL
    end

    def connection
      @connection ||= Faraday.new do |client|
        client.request :json

        client.response :raise_error
        client.response :json
      end
    end
  end
end
