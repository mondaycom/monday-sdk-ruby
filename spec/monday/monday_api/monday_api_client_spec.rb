# frozen_string_literal: true

RSpec.describe Monday::Client::MondayApiClient do
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

  it 'should throw errors without token' do
    expect do
      Monday::Client::MondayApiClient.execute(query, nil, conn)
    end.to raise_error(Monday::MondayClientError)

    expect do
      Monday::Client::MondayApiClient.execute(query, '', conn)
    end.to raise_error(Monday::MondayClientError)
  end
end
