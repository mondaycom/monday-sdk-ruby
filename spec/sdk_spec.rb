require 'faraday'
require 'json'

RSpec.describe Monday::Client do
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }

  query = "query {
              me {
                name
              }
            }"
  token = "mockToken!@#"

  it "has a version number" do
    expect(Monday::VERSION).not_to be nil
  end

  it "init with api" do
    client = Monday::Client.new(options={api: "https://its.me"})
    expect(client.instance_eval '@api_domain').to eq("https://its.me")
  end

  it "init without api" do
    client = Monday::Client.new
    expect(client.instance_eval '@api_domain').to eq(nil)
  end

  it "init with token" do
    client = Monday::Client.new(options={token: "u2u2u2u"})
    expect(client.instance_eval '@token').to eq("u2u2u2u")
  end

  it "e2e custom api" do
    stubs.post('/v2') do |env|
      expect(env.url.host).to eq('its.me.com')
      [
          200,
          { 'Content-Type': 'application/json', },
          '{"name": "monday"}'
      ]
    end

    client = Monday::Client.new(options={token: token,api:"https://its.me.com/v2", conn: conn})

    expect(client.api(query)).to eq('"{\\"name\\": \\"monday\\"}"')
    stubs.verify_stubbed_calls
  end

  it "e2e default api" do
    stubs.post('/v2') do |env|
      expect(env.url.host).to eq('api.monday.com')
      [
          200,
          { 'Content-Type': 'application/json', },
          '{"name": "monday"}'
      ]
    end

    client = Monday::Client.new(options={token: token, conn: conn})

    expect(client.api(query)).to eq('"{\\"name\\": \\"monday\\"}"')
    stubs.verify_stubbed_calls
  end

  it "e2e default api with variables" do
    stubs.post('/v2') do |env|
      expect(env.url.host).to eq('api.monday.com')
      expect(env.request_body).to eq('{"query":"query {\n              me {\n                name\n              }\n            }","variables":{"name":"as"}}')
      [
          200,
          { 'Content-Type': 'application/json', },
          '{"name": "monday"}'
      ]
    end

    client = Monday::Client.new(options={token: token, conn: conn})

    expect(client.api(query,options={variables: {"name":"as",}})).to eq('"{\\"name\\": \\"monday\\"}"')
    stubs.verify_stubbed_calls
  end

  it "monday-api-client execute without token" do

    expect {
      Monday::Client::MondayApiClient.execute(query,nil,conn)
    }.to raise_error(Monday::MondayClientError)

    expect {
      Monday::Client::MondayApiClient.execute(query,"",conn)
    }.to raise_error(Monday::MondayClientError)
  end

end
