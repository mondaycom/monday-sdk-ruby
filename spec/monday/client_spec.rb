# frozen_string_literal: true

RSpec.describe Monday::Client do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:conn) do
    Faraday.new do |b|
      b.request :json
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

  it_behaves_like 'have common initialization'

  it 'default api' do
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

  it 'default api with variables' do
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

  it 'custom api' do
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

  context 'raise_error middleware' do
    let(:conn) do
      Faraday.new do |b|
        b.request :json
        b.response :raise_error
        b.response :json
        b.adapter(:test, stubs)
      end
    end

    it 'on responce error' do
      stubs.post('/v2') do |_env|
        [
          422,
          { 'Content-Type': 'application/json' },
          '{"error": "some error happened" }'
        ]
      end

      client = Monday::Client.new(token: token, conn: conn)
      expect { client.api(query) }.to raise_error(Monday::MondayClientError)

      stubs.verify_stubbed_calls
    end
  end
end
