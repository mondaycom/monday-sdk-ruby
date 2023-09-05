# frozen_string_literal: true

shared_examples 'have common initialization' do
  it 'init with api' do
    client = described_class.new(api: 'https://its.me')
    expect(client.instance_eval('@api_domain', __FILE__, __LINE__)).to eq('https://its.me')
  end

  it 'init without api' do
    client = described_class.new
    expect(client.instance_eval('@api_domain', __FILE__, __LINE__)).to eq(nil)
  end

  it 'init with token' do
    client = described_class.new({ token: 'u2u2u2u' })
    expect(client.instance_eval('@token', __FILE__, __LINE__)).to eq('u2u2u2u')
  end
end
