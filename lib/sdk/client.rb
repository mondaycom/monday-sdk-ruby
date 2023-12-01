# frozen_string_literal: true

# Monday Client implementation
module Monday
  class MondayClientError < StandardError; end

  class Client
    TOKEN_MISSING_ERROR = "Should send 'token' as an option or call mondaySdk.setToken(TOKEN)"

    def initialize(options = {})
      @token = options[:token] # @type string , Client token provided by monday.com
      @api_domain = options[:api] # @type string (optional) monday api domain can be changed, default defined in constants
      @api_version = options[:api_version] # @type string (optional) monday api_version (ref: https://developer.monday.com/api-reference/docs/api-versioning)
      @connection = options[:conn] # dependency injection for testing
    end

    # Main entry point to the client
    def api(query, options = {})
      token = options[:token] || @token
      raise(MondayClientError, TOKEN_MISSING_ERROR) unless token

      prepare_options!(options)
      params = { query: query, variables: options[:variables] || {} }

      MondayApiClient.execute(params, token, connection, options)
    end

    # method for updating api version like in JS SDK
    # ref: https://developer.monday.com/api-reference/docs/api-versioning#using-the-sdk
    def set_api_version(version)
      @api_version = version
    end

    private

    def prepare_options!(options = {})
      api_version = options[:api_version] || @api_version
      options[:api_domain] ||= api_domain
      options[:headers] ||= {}
      options[:headers].merge!('API-Version' => api_version) if api_version
      options
    end

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
