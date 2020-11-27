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

require 'securerandom'

User = Struct.new(:id, :name, :email)

class CreateUser < Micro::Case
  attribute :name, {
    default: -> value { String(value).strip },
    validates: { presence: true }
  }

  attribute :email, {
    default: -> value { String(value).strip.downcase },
    validates: { format: { with: /.+@.+/ } }
  }

  def call!
    user = User.new(SecureRandom.uuid, name, email)

    Success(:user_created, result: { user: user })
  end
end

result = CreateUser.call(name: ' Rodrigo ', email: 'RODRIGO@gmail.com')

binding.pry
