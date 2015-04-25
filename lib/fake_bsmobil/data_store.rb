module FakeBsmobil
  class DataStore

    attr_reader :account

    # TODO: when merging, raise on unknown keys
    def account=(attributes)
      @account = FakeBsmobil::Generator.full_account.merge(attributes)
    end
  end
end
