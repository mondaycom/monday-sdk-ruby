# frozen_string_literal: true

RSpec.describe Monday::Storage do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:conn) do
    Faraday.new do |b|
      b.request :json
      b.response :json
      b.adapter(:test, stubs)
    end
  end

  token = 'mockToken!@#'

  it_behaves_like 'have common initialization'

  subject { described_class.new(token: token, conn: conn) }

  context '#get' do
    it 'default api' do
      stubs.get('/app_storage_api/v2/test') do |env|
        expect(env.url.host).to eq('apps-storage.monday.com')
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"value": "monday", "version": "abcde"}'
        ]
      end

      expect(subject.get('test')).to include('value' => 'monday')
      stubs.verify_stubbed_calls
    end

    it 'handle null value' do
      stubs.get('/app_storage_api/v2/test') do |_env|
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"value":null}'
        ]
      end

      expect(subject.get('test')).to include('value' => nil)
      stubs.verify_stubbed_calls
    end

    it 'escapes path' do
      stubs.get('/app_storage_api/v2/test%3A%3Afoo') do |_env|
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"value": "buzz"}'
        ]
      end

      expect(subject.get('test::foo')).to include('value' => 'buzz')
      stubs.verify_stubbed_calls
    end

    it 'shared data storage' do
      stubs.get('/app_storage_api/v2/test?shareGlobally=true') do |_env|
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"value": "foo", "version": "abcde"}'
        ]
      end

      expect(subject.get('test', shared: true)).to include('value' => 'foo', 'version' => be_a_kind_of(String))
      stubs.verify_stubbed_calls
    end
  end

  context '#set' do
    it 'default use' do
      stubs.post('/app_storage_api/v2/test') do |env|
        expect(env.url.host).to eq('apps-storage.monday.com')
        [
          201,
          { 'Content-Type': 'application/json' },
          '{"version": "abcde"}'
        ]
      end

      expect(subject.set('test', 'updated')).to include('version' => be_a_kind_of(String))
      stubs.verify_stubbed_calls
    end

    it 'shared storage use' do
      stubs.post('/app_storage_api/v2/test?shareGlobally=true') do |env|
        expect(env.url.host).to eq('apps-storage.monday.com')
        [
          201,
          { 'Content-Type': 'application/json' },
          '{"version": "abcde"}'
        ]
      end

      expect(subject.set('test', 'updated', shared: true)).to include('version' => be_a_kind_of(String))
      stubs.verify_stubbed_calls
    end
  end

  context '#delete' do
    it 'default use' do
      stubs.delete('/app_storage_api/v2/test') do |env|
        expect(env.url.host).to eq('apps-storage.monday.com')
        [
          204,
          { 'Content-Type': 'application/json' }
        ]
      end

      expect(subject.delete('test')).to be_success
      stubs.verify_stubbed_calls
    end

    it 'shared storage use' do
      stubs.delete('/app_storage_api/v2/test?shareGlobally=true') do |env|
        expect(env.url.host).to eq('apps-storage.monday.com')
        [
          204,
          { 'Content-Type': 'application/json' }
        ]
      end

      expect(subject.delete('test', shared: true)).to be_success
      stubs.verify_stubbed_calls
    end
  end

  context '#get_parsed_value' do
    it 'default api' do
      stubs.get('/app_storage_api/v2/test') do |env|
        expect(env.url.host).to eq('apps-storage.monday.com')
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"value": "\"monday\"", "version": "abcde"}'
        ]
      end

      expect(subject.get_parsed_value('test')).to eq('monday')
      stubs.verify_stubbed_calls
    end

    it 'handles parse errors' do
      stubs.get('/app_storage_api/v2/test') do |env|
        expect(env.url.host).to eq('apps-storage.monday.com')
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"value": "monday\"", "version": "abcde"}'
        ]
      end

      expect(subject.get_parsed_value('test')).to be_nil
      stubs.verify_stubbed_calls
    end

    it 'handles blank response' do
      stubs.get('/app_storage_api/v2/test') do |env|
        expect(env.url.host).to eq('apps-storage.monday.com')
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"value": null}'
        ]
      end

      expect(subject.get_parsed_value('test')).to be_nil
      stubs.verify_stubbed_calls
    end

    it 'allows to receive an array' do
      stubs.get('/app_storage_api/v2/test') do |env|
        expect(env.url.host).to eq('apps-storage.monday.com')
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"value": "[\"one\",\"two\"]", "version": "abcde"}'
        ]
      end

      expect(subject.get_parsed_value('test')).to eq(%w[one two])
      stubs.verify_stubbed_calls
    end
  end
end
