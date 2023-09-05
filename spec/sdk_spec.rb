# frozen_string_literal: true

require 'faraday'
require 'json'

RSpec.describe Monday do
  it 'has a version number' do
    expect(Monday::VERSION).not_to be nil
  end
end
