
# Monday Client implementation
module Monday

  class MondayClientError < StandardError; end

  class Client

    TOKEN_MISSING_ERROR = "Should send 'token' as an option or call mondaySdk.setToken(TOKEN)".freeze

    def initialize(options = {})
      @token = options[:token] # @type string , Client token provided by monday.com
      @api_domain = options[:api] # @type string (optional) monday api domain cna be changed, default defined in constants
      @faraday_client = options[:conn] || Faraday.new # dependency injection for testing
    end

    # Main entry point to the client
    def api(query, options = {})
      token = options[:token] || @token

      if token.nil? || token.empty?
        raise MondayClientError.new TOKEN_MISSING_ERROR.to_s
      end

      params = {}
      params[:query] = query
      params[:variables] = options[:variables] || {}

      options[:api_domain] = @api_domain || MONDAY_API_URL


      MondayApiClient.execute(params, token, @faraday_client, options)
    end

  end

end


