require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'u-case', '~> 4.2.1'
  gem 'pry'
  gem 'awesome_print'
  gem 'activemodel'
end

Micro::Case.config do |config|
  config.enable_activemodel_validation = true
end

class Sum < Micro::Case
  attributes :a, :b

  def call!
    if a.is_a?(Numeric) && b.is_a?(Numeric)
      Success(result: { number: a + b })
    else
      Failure(:attributes_must_be_numerics)
    end
  end
end

class Add3 < Micro::Case
  attributes :number

  def call!
    if number.is_a?(Numeric)
      Success(result: { number: number + 3 })
    else
      Failure(:number_must_be_numerics)
    end
  end
end

require 'base64'

module Formatters
  ToString = -> value { value.to_s }
  ToBase64 = -> value { Base64.encode64(value.to_s) }
end

class FormatNumber < Micro::Case
  attribute :number, validates: { kind: Numeric }
  attribute :formatter, validates: { kind: { respond_to: :call } }

  def call!
    Success result: { number: formatter.call(number) }
  end
end

# S RP
# O CP
# L SP
# I SP
# D IP

SumAndAdd3 = Micro::Cases.flow([Sum, Add3])

result =
  SumAndAdd3
    .call(a: 1, b: 2)
    .then(FormatNumber, formatter: Formatters::ToString)

binding.pry
