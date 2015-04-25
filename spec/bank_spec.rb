require 'fake_bsmobil/bank'

RSpec.describe FakeBsmobil::Bank do
  subject(:bank) { described_class.new }


  describe '#logger' do
    subject(:logger) { bank.logger }
    it { is_expected.to be(logger) }
  end

  describe '#datastore' do
    subject(:datastore) { bank.datastore }
    it { is_expected.to be(bank.datastore) }
  end

  describe '#accounts' do
    subject(:accounts) { bank.accounts }

    it { is_expected.to be_a(Hash) }
    it { is_expected.to have_key(:accounts) }

    it { is_expected.to_not eq(bank.accounts) }

    context '#use_account' do
      before do
        bank.use_account(owner: 'John Doe')
      end

      it { is_expected.to eq(bank.accounts) }
    end
  end

  describe '#session_id' do
    subject(:session_id) { bank.session_id }
    it { is_expected.to_not eq(bank.session_id) }

    context '#use_session' do
      around { |ex| bank.use_session('some-id', &ex) }
      it { is_expected.to eq(bank.session_id) }
    end
  end
end
