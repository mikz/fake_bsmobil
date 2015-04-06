module FakeBsmobil
  module Generator
    module Movements
      module_function

      def withdrawal(timestamp: Util.timestamp)
        movement = Util.card(timestamp: timestamp, amount: Util.negative(1000))

        movement.merge(
            concept: "WITHDRAWAL ATM #{Util.card_number} #{timestamp.strftime('%d.%m')}",
            conceptCode: "01",
            conceptDetail: "CHECKS - WITHDRAWALS",
            referencor: "#{movement[:referencor]} #{Generator.number(12)}",
        )
      end

      def purchase
        Util.card(amount: Util.negative(100)).merge(
            concept: "PURCHASE WITH CARD #{Util.card_number} #{Util.company_name}",
            conceptCode: "12",
            conceptDetail: "CREDIT CARDS - DEBITS CARDS"
        )
      end

      def commission
        Util.card(amount: Util.negative(10)).merge(
            concept: "NON-EURO CURRENCY COMMISSION ",
            canSplit: false,
            conceptCode: "06",
            conceptDetail: "REMITTANCE OF BILLS"
        )
      end

      def transfer(timestamp: Util.timestamp)
        Util.basic(amount: Util.negative(1000), timestamp: timestamp).merge(
            concept: "TRANSFER A #{Util.full_name}",
            canSplit: false,
            existDocument: true,
            conceptCode: "04",
            conceptDetail: "DRAFTS - INTERBANK TRANSFERS - INTRABANK TRANSFERS - CHECKS",
            referencor: "#{Generator.number(4)}#{timestamp.strftime('%Y-%m-%d %H:%M:%S')} 01 EUR                   #{Generator.number(6)}DV #{Generator.number(29)}",
        )
      end

      def salary
        Util.basic(amount: Util.positive(5000)).merge(
            concept: "SALARY PAYMENT #{Util.company_name}",
            existDocument: true,
            conceptCode: "15",
            conceptDetail: "SALARIES - SOCIAL SECURITY",
            referencor: "#{Generator.number(6)} #{Generator.number(15)} 01 P EUR                  #{Generator.number(20)}CAIX#{Generator.number(25)}",
        )
      end

      def random
        (self.methods - self.class.methods - [__method__]).sample
      end

      module Util
        module_function

        def basic(timestamp: Util.timestamp, amount:, balance: positive(1000))
          puts "{ timestamp: #{timestamp}, amount: #{amount}, balance: #{balance} }"
          {
              date: date = timestamp.strftime('%d-%m-%y'),
              valueDate: (timestamp + [0, 0, 0, 1].sample).strftime('%d-%m-%y'),
              canSplit: amount < -200,
              amount: Util.currency(amount),
              balance: Util.currency(balance + amount),
              apuntNumber: Generator.number(12),
              existDocument: false,
              cardNumber: '',
              productCode: '0',
              numPAN: '',
              returnBillCode: '',
              timeStamp: timestamp.strftime('%Y%m%d%H%M%S%6N'),
              sessionDate: date
          }
        end

        def timestamp
          (Faker::Date.backward.to_time + rand(24*60*60)).to_datetime
        end

        def card(timestamp: Util.timestamp, **options)
          puts "{timestamp: #{timestamp}, #{options}}"
          basic(timestamp: timestamp, **options).merge(
              numPAN: card = full_card_number,
              referencor: "#{card}       #{timestamp.strftime('%Y-%m-%d %H:%M:%S')}",
          )
        end

        # TODO: let generator generate card
        def card_number
          card = full_card_number.scan(/(\d{4})/)
          card[2] = card[1] = 'X' * 4
          card.join
        end

        def company_name
          Faker::Company.name.upcase
        end

        def full_name
          Faker::Name.name
        end

        def full_card_number
          "5402#{Generator.number(12)}"
        end

        def positive(value)
          rand(value).to_f
        end

        def negative(value)
          rand(value).to_f * -1
        end

        def currency(amount)
          # FIXME: this is possibly buggy implementation taken from SO
          value = amount.to_f.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
          { value: value, currency: 'EUR' }
        end
      end

    end
  end

end
