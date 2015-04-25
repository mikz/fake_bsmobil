require 'fake_bsmobil/version'
require 'logger'


require 'json-schema'

module FakeBsmobil
  autoload :DataStore, 'fake_bsmobil/data_store'
  autoload :Api, 'fake_bsmobil/api'
  autoload :Schema, 'fake_bsmobil/schema'
  autoload :Generator, 'fake_bsmobil/generator'
  autoload :Bank, 'fake_bsmobil/bank'


  ValidationError = JSON::Schema::ValidationError

  class InvalidInputError < StandardError
    def to_json
      { errorMessage: message, code: '' }.to_json
    end

    def status
      500
    end
  end

  class << self
    def logger
      @logger ||= Logger.new($stdout)
    end

    def bank
      @bank ||= FakeBsmobil::Bank.new
    end

    def validator
      JSON::Validator
    end

    def method_missing(*args, &block)
      bank.public_send(*args, &block)
    end
  end
end
