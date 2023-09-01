# frozen_string_literal: true

require 'faraday'
require 'json'

RSpec.describe Monday::Client do
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   do
    Faraday.new do |b|
      b.request :json

      b.response :raise_error
      b.response :json

      b.adapter(:test, stubs)
    end
  end

  query = %(
    query {
      me {
        name
      }
    }
  )
  token = 'mockToken!@#'

  it 'has a version number' do
    expect(Monday::VERSION).not_to be nil
  end

  it 'init with api' do
    client = Monday::Client.new(api: 'https://its.me')
    expect(client.instance_eval('@api_domain', __FILE__, __LINE__)).to eq('https://its.me')
  end

  it 'init without api' do
    client = Monday::Client.new
    expect(client.instance_eval('@api_domain', __FILE__, __LINE__)).to eq(nil)
  end

  it 'init with token' do
    client = Monday::Client.new({ token: 'u2u2u2u' })
    expect(client.instance_eval('@token', __FILE__, __LINE__)).to eq('u2u2u2u')
  end

  it 'e2e custom api' do
    stubs.post('/v2') do |env|
      expect(env.url.host).to eq('its.me.com')
      [
        200,
        { 'Content-Type': 'application/json' },
        '{"name": "monday"}'
      ]
    end

    client = Monday::Client.new(token: token, api: 'https://its.me.com/v2', conn: conn)

    expect(client.api(query)).to eq({ 'name' => 'monday' })
    stubs.verify_stubbed_calls
  end

  it 'e2e default api' do
    stubs.post('/v2') do |env|
      expect(env.url.host).to eq('api.monday.com')
      [
        200,
        { 'Content-Type': 'application/json' },
        '{"name": "monday"}'
      ]
    end

    client = Monday::Client.new(token: token, conn: conn)

    expect(client.api(query)).to eq('name' => 'monday')
    stubs.verify_stubbed_calls
  end

  it 'e2e default api with variables' do
    stubs.post('/v2') do |env|
      expect(env.url.host).to eq('api.monday.com')

      parsed_request = JSON.parse(env.request_body)
      expect(parsed_request).to include('variables' => { 'name' => 'as' })
      expect(parsed_request).to include('query' => String)
      expect(parsed_request['query'].gsub(/\s/, '')).to eq('query{me{name}}')

      [
        200,
        { 'Content-Type': 'application/json' },
        '{"name": "monday"}'
      ]
    end

    client = Monday::Client.new(token: token, conn: conn)

    expect(client.api(query, variables: { "name": 'as' })).to eq('name' => 'monday')
    stubs.verify_stubbed_calls
  end

  it 'monday-api-client execute without token' do
    expect do
      Monday::Client::MondayApiClient.execute(query, nil, conn)
    end.to raise_error(Monday::MondayClientError)

    expect do
      Monday::Client::MondayApiClient.execute(query, '', conn)
    end.to raise_error(Monday::MondayClientError)
  end
end
