require 'spec_helper'
require 'fake_bsmobil'

RSpec.describe FakeBsmobil do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  it 'delegates to bank' do
    expect(described_class.datastore).to be(described_class.bank.datastore)
  end
end
