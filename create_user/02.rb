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
    normalized_name, normalized_email = normalize_attributes

    validations_errors = validate_attributes(normalized_name, normalized_email)

    return create_user(normalized_name, normalized_email) if validations_errors.empty?

    Failure(:invalid_attributes, result: validations_errors )
  end

  private

    def normalize_attributes
      [
        String(name).strip,
        String(email).strip.downcase
      ]
    end

    def validate_attributes(name, email)
      validations_errors = {}
      validations_errors[:name] = "can't be blank" if name.empty?
      validations_errors[:email] = "is invalid" if email !~ /.+@.+/
      validations_errors
    end

    def create_user(name, email)
      user = User.new(
        SecureRandom.uuid,
        name,
        email
      )

      Success(:user_created, result: { user: user })
    end
end

result = CreateUser.call(name: ' Rodrigo ', email: 'RODRIGO@gmail.com')

binding.pry
