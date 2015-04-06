require 'fake_bsmobil/version'
require 'json-schema'
require 'logger'
require 'securerandom'

module FakeBsmobil
  autoload :Datastore, 'fake_bsmobil/datastore'
  autoload :Api, 'fake_bsmobil/api'
  autoload :Schema, 'fake_bsmobil/schema'
  autoload :Generator, 'fake_bsmobil/generator'

  module_function

  def user
    @user
  end

  def user=(user)
    @user = user
  end

  def datastore
    @datastore ||= Datastore.new
  end

  def validator
    JSON::Validator
  end

  ValidationError = JSON::Schema::ValidationError

  def logger
    @logger = Logger.new($stdout)
  end

  def generate_session_id
    @sessions ||= Set.new
    session_id = SecureRandom.base64(18) + '.pmobil3'
    @sessions.add(session_id)
    session_id
  end

  def generate_user
    {
        dni: Generator.dni,
        name: Generator.name,
        sex: Generator.sex,
        phoneNumber: Generator.phone_number,
        contractNumber: Generator.contract_number,
        hasMoreContracts: false,
        customization: '1H4XX000000032010011010211301211000000000010110011',
        isNewUser: false,
        pendingSignOperations: 0,
        personNumber: Generator.person_number,
        idType: '01',
        loginType: 5,
        promoLayer: {code: '', url: 'resources/mobapp/layers//', nShows: 0, exist: false},
        cardId: Generator.card_id,
        refreshActiveAgent: 10,
        signatureType: 'tpc',
        vTPCInscriptionKey: ''
    }
  end

  def session(info)
    logger.info info
    validator.validate!(Schema::SESSION, info)

    {
        user: self.user ||= generate_user,
        isInputTypeNumberSupported: true

    }
  end

  def products
    {
        accountProduct: {
            amount: amount = Generator.amount,
            accounts: [ Generator.account(amount: amount) ]
        },
        cardProduct: {
            amount: {value: "0,00", currency: "EUR"},
            cards: [Generator.debit_card]
        },
        investmentProduct: {
            amount: {:value => "", :currency => ""},
            securities: {:amount => {:value => "", :currency => ""}, :accounts => [], :type => ""},
            pensionPlan: {amount: {:value => "", :currency => ""}, accounts: [], type: ""},
            insuredPlanForecast: {amount: {:value => "", :currency => ""}, policies: []},
            investmentFund: {:amount => {:value => "", :currency => ""}, :accounts => [], :type => ""},
            depositProduct: {:amount => {:value => "", :currency => ""}, :accounts => []},
            unknowns: []
        },
        financialProduct: {
            amount: {:value => "0,00", :currency => "EUR"},
            loan: {:amount => {:value => "", :currency => ""}, :accounts => []},
            credit: {:amount => {:value => "", :currency => ""}, :accounts => []},
            expansionLineGP: {amount: {:value => "0,00", :currency => "EUR"},
                              expansionLines: []},
            unknowns: []
        },
        other: {amount: {value: "", currency: ""}, unknowns: []}
    }
  end

  def account_movements(json)
    logger.info json
    validator.validate!(Schema::ACCOUNT, json)

    account_info = JSON.parse(json).fetch('account') # FIXME: string keys :(
    account = Generator.full_account(account_info)

    movements(account)
  end

  def movements(account)
    Generator.movements(account)
  end

  def accounts
    {
        accounts: [Generator.full_account],
    }.merge(paginator)
  end

  def cards(_filter)
    {
        cards: [ Generator.debit_card ]
    }.merge(paginator)
  end

  def unconfirmed_card_movements(json)
    card = load_card(json)

    card_movements(card).merge(cardMovements: Generator.unconfirmed_card_movements)
  end

  def card_movements(card)
    {
        contractNumber: Generator.contract_number(length: 15),
        contractOwner: name = Generator.contract_name,
        paymentType: "",
        ptorete: "",
        previousBalance: {value: "0,00", currency: "EUR"},
        currentMonthBalance: {:value => "0,00", :currency => "EUR"},
        totalAmount: Generator.amount,
        pendingLiquidationBalance: {:value => "0,00", :currency => "EUR"},
        availableBalance: {:value => "0,00", :currency => "EUR"},
        willingBalance: {:value => "0,00", :currency => "EUR"},
        chargeAccount: {
            description: "",
            availability: "",
            owner: name,
            product: "",
            productType: "",
            entityCode: "",
            contractCode: "",
            bic: "",
            number: Generator.account_number,
            iban: "",
            amount: {:value => "", :currency => ""},
            numOwners: 0,
            isOwner: false,
            isSBPManaged: false,
            isIberSecurities: false,
            joint: "",
            mobileWarning: ""
        },
        card: card,
        hasUnconfirmedMovements: true
    }.merge(paginator)
  end

  def confirmed_card_movements(json)
    card = load_card(json)

    card_movements(card).merge(cardMovements: Generator.confirmed_card_movements)
  end

  def paginator
    {
        paginator: {
            page: 0,
            itemsPerPage: 20,
            order: 'desc',
            totalItems: 1
        }
    }
  end

  def load_card(json)
    logger.info json
    validator.validate!(Schema::CARD, json)

    card_info = JSON.parse(json).fetch('card') # FIXME: string keys :(

    Generator.debit_card(card_info)
  end

end
