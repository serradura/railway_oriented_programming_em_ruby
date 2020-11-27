require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'u-case', '~> 4.2.1'
  gem 'pry'
  gem 'awesome_print'
end

require 'securerandom'

User = Struct.new(:id, :name, :email)

class CreateUser < Micro::Case
  attributes :name, :email

  def call!
    normalized_name = String(name).strip
    normalized_email = String(email).strip.downcase

    validations_errors = {}
    validations_errors[:name] = "can't be blank" if normalized_name.empty?
    validations_errors[:email] = "is invalid" if normalized_email !~ /.+@.+/

    if !validations_errors.empty?
      return Failure(:invalid_attributes, result: validations_errors )
    end

    user = User.new(
      SecureRandom.uuid,
      normalized_name,
      normalized_email
    )

    Success(:user_created, result: { user: user })
  end
end

result = CreateUser.call(name: ' Rodrigo ', email: 'RODRIGO@gmail.com')

binding.pry
