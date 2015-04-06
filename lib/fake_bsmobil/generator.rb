require 'faker'

module FakeBsmobil
  module Generator
    autoload :Movements, 'fake_bsmobil/generator/movements'

    module_function

    def dni
      letters = ['' , 'N', 'Y']
      "#{letters.sample}#{Faker::Number.number(7)}#{letters.sample}"
    end

    def name
      [ Faker::Name.first_name,
        Faker::Name.last_name ].join(' ').upcase
    end

    def contract_name
      [
          Faker::Name.last_name,
          Faker::Name.first_name
      ].join(' ,').upcase
    end

    def phone_number(prefix: '+34')
      "#{prefix}#{Faker::Number.number(9)}"
    end

    def sex
      %w(H M).sample
    end

    def email(name: self.name, domain: Faker::Internet.domain_name)
      [ Faker::Internet.user_name(name), domain].join('@')
    end

    def contract_number(length: 10)
      "#{Faker::Number.number(length)}"
    end

    def person_number
      "#{Faker::Number.number(7)}"
    end

    def card_id
      "#{Faker::Number.number(7)}"
    end

    def number(value)
      Faker::Number.number(value)
    end

    def amount(amount = rand(1_000.0..10_000.0))
      num = ''

      thousands = amount / 1000
      if thousands > 0
        num += "#{rand(thousands)}."
      end

      num +=  '%03d' % [amount, 999].min
      num += '.' << ('%0.2f' % amount).split('.').last

      { value: num, currency: 'EUR' }
    end

    def account_number
      [4, 4, 2, 10].map(&Faker::Number.method(:number)).join('-')
    end

    def iban
      "ES#{Faker::Number.number(22)}"
    end

    def account(override = {})
      {
          alias: '',
          description: 'CUENTA EXPANSIÓN',
          availability: '',
          owner: name,
          product: '',
          productType: '',
          entityCode: '',
          contractCode: '',
          bic: 'BSAB ESBB',
          number: account_number,
          iban: iban,
          amount: amount,
          numOwners: 0,
          isOwner: false,
          isSBPManaged: false,
          isIberSecurities: false,
          joint: '',
          mobileWarning: ''
      }.merge(override)
    end

    def full_account(override = {})
      account(override).merge(
          availability: 'TOTAL',
          product: 'DV00083',
          productType: '',
          entityCode: '',
          contractCode: '',
          numOwners: 1,
          isOwner: true,
          isSBPManaged: false,
          isIberSecurities: false,
          joint: 'I',
          mobileWarning: 'A')
    end

    def debit_card(override = {})
      {
          bsprotect: "S",
          description: "BSCARD MASTERCARD BS",
          isMarsans: "false",
          name: name,
          productType: "TD",
          reference: "0",
          type: "OPERAC.",
          shortDescription: "BSCARD MASTERCARD BS",
          number: "5402________#{card_tail = number(4)}",
          realNumber: "5402#{number(8)}#{card_tail}",
          numcard: "TA #{number(5)}",
          isOwner: true,
          activatedLE: "P",
          codret: "",
          contractCCC: number(20),
          operativeCode: "4",
          cvv2: "   ",
          dni: "",
          entity: "",
          mail: "",
          mailChecked: "",
          phoneNumber: "",
          phoneNumberChecked: "",
          alias: "",
          expirationDate: "",
          balance: {value: "", currency: ""},
          availableBalance: {value: "", currency: ""},
          dms: "",
          indAlert: "",
          selectableIndex: "",
          canActivate: false,
          cardType: {
              background: "1",
              type: "mastercard",
              subtype: "debit",
              textColor: "#ffffff",
              iconColor: "#ffffff",
              logo: "mastercard1"
          },
          status: "active",
          availableOperations: [],
          isInternational: true,
          isInternet: true,
          isSticker: true,
          stickerCard: false,
          nfcCard: {
              isNfc: true,
              isActive: false,
              expirationDate: Faker::Date.forward.strftime('%d-%m-%y')
          },
          stickerPan: "",
          deteriorationLock: false,
          isPrepaidAnonymous: false
      }.merge(override)
    end


    def movement
      Movements.send(Movements.random)
    end

    def confirmed_card_movement
      city = Faker::Address.city

      concept = case %w(cajero company).sample
        when 'cajero'
          "CAJERO #{Faker::Company.name[0, 10].ljust(10, ' ')} OF.#{number(4)}".upcase
        when 'company'
          company = Faker::Company.name
          rand > 0.7 ? company.upcase : company
      end
      {
          movementNumber: number(4),
          concept: concept,
          date: Faker::Date.backward.strftime('%d-%m-%Y'),
          city: city = rand > 0.7 ? city.upcase : city,
          canSplit: false,
          amount: a = amount(rand(1..300)),
          indFracEnabled: true,
          indMov: "1",
          isTraspasable: false,
          commission: {:value => "0,00", :currency => "EUR"},
          originAmount: a,
          address: city,
          point: nil
      }
    end

    def unconfirmed_card_movement
      confirmed_card_movement.merge(movementNumber: '')
    end

    def confirmed_card_movements(n = 10)
      n.times.map { confirmed_card_movement }
    end

    def unconfirmed_card_movements(n = 10)
      n.times.map { unconfirmed_card_movement }
    end

    def movements(account)
      {account: full_account(account),
       accountMovements: 10.times.map { movement },
       moreElements: true}
    end
  end
end
