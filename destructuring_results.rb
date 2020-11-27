require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'u-case', '~> 4.2'
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

result = Add3.call(number: 1)

p result
puts "-------------"

data, type = Add3.call(number: 1)

p [data, type]
puts "-------------"

Add3.call(number: 1) do |on|
  on.success { |result| p result }
  on.success { |data, type| p [data, type] }
end

puts "-------------"

Add3
  .call(number: 1)
  .on_success { |result| p result }
  .on_success { |result, use_case| p [result, use_case] }
  .on_success { |(data, type)| p [data, type] }
