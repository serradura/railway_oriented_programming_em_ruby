require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'u-case', '~> 4.2.1'
  gem 'pry'
  gem 'awesome_print'
end

require 'securerandom'

User = Struct.new(:id, :name, :email)

class NormalizeNameAndEmail < Micro::Case
  attributes :name, :email

  def call!
    Success result: {
      name: String(name).strip,
      email: String(email).strip.downcase
    }
  end
end

class ValidateNameAndEmail < Micro::Case
  attributes :name, :email

  def call!
    validations_errors = {}
    validations_errors[:name] = "can't be blank" if name.empty?
    validations_errors[:email] = "is invalid" if email !~ /.+@.+/

    return Success(:valid_attributes) if validations_errors.empty?

    Failure(:invalid_attributes, result: validations_errors )
  end
end

class CreateUser < Micro::Case
  attributes :name, :email

  def call!
    user = User.new(
      SecureRandom.uuid,
      name,
      email
    )

    Success(:user_created, result: { user: user })
  end
end

class CreateUserFlow1 < Micro::Case
  flow([
    NormalizeNameAndEmail,
    ValidateNameAndEmail,
    CreateUser
  ])
end

CreateUserFlow2 = Micro::Cases.flow([
  NormalizeNameAndEmail,
  ValidateNameAndEmail,
  CreateUser
])

result1 = CreateUserFlow1.call(name: ' Rodrigo ', email: 'RODRIGO@gmail.com')
result2 = CreateUserFlow2.call(name: ' Rodrigo ', email: 'RODRIGO@gmail.com')

binding.pry
