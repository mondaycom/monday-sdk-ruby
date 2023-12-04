# frozen_string_literal: true

module Monday
  # The `Storage` class provides a simple interface for interacting
  # with the Monday.com Global Storage API.
  class Storage
    # Initialize a new instance of the Global Storage.
    #
    # @param token [String] The users access token (permanent or short-lived) used for API requests.
    # @param connection [Faraday::Connection] An existing Faraday connection to be used for the requests.
    def initialize(token: nil, api: nil, conn: nil)
      @token = token
      @api_domain = api
      @connection = conn
    end

    # Retrieve data from the storage.
    #
    # @param key [String] The key associated with the data.
    # @param shared [Boolean] A flag indicating whether the data is shared with the frontend. Default is `false`.
    # @param extra [Hash] Additional headers to include in the API request.
    # @return [Hash] The retrieved data. (value & version)
    def get(key, shared: false, **extra)
      res = connection.get(resource_endpoint(key, shared: shared), {}, headers(**extra))
      res.body
    end

    # Create/update data in the storage.
    #
    # @param key [String] The key to associate with the data.
    # @param data [String, Hash] The data to be stored.
    # @param shared [Boolean] A flag indicating whether the data is shared with the frontend. Default is `false`.
    # @param extra [Hash] Additional headers to include in the API request.
    # @return [Hash] The response from the API. (version)
    def set(key, data, shared: false, **extra)
      data = { value: data } if data.is_a?(String)
      res = connection.post(resource_endpoint(key, shared: shared), data.to_json, headers(**extra))
      res.body
    end

    # Delete data from the storage.
    #
    # @param key [String] The key associated with the data.
    # @param shared [Boolean] A flag indicating whether the data is shared with the frontend. Default is `false`.
    # @param extra [Hash] Additional headers to include in the API request.
    def delete(key, shared: false, **extra)
      connection.delete(resource_endpoint(key, shared: shared), {}, headers(**extra))
    end

    # Get the parsed value of the given key.
    #
    # @param key [String] The key associated with the data.
    # @param shared [Boolean] A flag indicating whether the data is shared with the frontend. Default is `false`.
    # @param extra [Hash] Additional headers to include in the API request.
    # @return The retrieved parsed value, nil if not found or failed to parse.
    def get_parsed_value(key, shared: false, **extra)
      result = get(key, shared: shared, **extra)
      raw_value = result&.fetch('value', nil)
      return unless raw_value

      JSON.parse(raw_value)
    rescue JSON::ParserError
      nil
    end

    private

    def api_domain
      @api_domain ||= MONDAY_STORAGE_URL
    end

    def headers(token: nil, **extra_headers)
      extra_headers.merge(
        'Authorization' => token || @token,
        'Content-Type' => 'application/json'
      )
    end

    def resource_endpoint(key, shared: false)
      full_url = "#{api_domain}/#{URI.encode_www_form_component(key)}"
      return full_url unless shared

      "#{full_url}?shareGlobally=true"
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
