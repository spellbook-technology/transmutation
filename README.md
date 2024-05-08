# Transmutation

Transmutation is a Ruby gem that provides a simple way to serialize Ruby objects into JSON.

It takes inspiration from the [Active Model Serializers](https://github.com/rails-api/active_model_serializers) gem, but strips away adapters.

It aims to be a performant and elegant solution for serializing Ruby objects into JSON, with a touch of opinionated "magic" :sparkles:.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add transmutation

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install transmutation

## Usage

### Basic Usage

- Define a serializer class that inherits from `Transmutation::Serializer` and define the attributes to be serialized.

  ```ruby
  class UserSerializer < Transmutation::Serializer
    attributes :id, :name, :email
  end
  ```

- Serialize an object using the serializer class.

  ```ruby
  class User
    attr_reader :id, :name, :email

    def initialize(id:, name:, email:)
      @id = id
      @name = name
      @email = email
    end
  end

  user = User.new(id: 1, name: "John Doe", email: "john@example.com")

  UserSerializer.new(user).to_json # => "{\"id\":1,\"name\":\"John Doe\",\"email\":\"john@example.com\"}"
  ```

  As long as your object responds to the attributes defined in the serializer, it can be serialized.

  - Struct

    ```ruby
    User = Struct.new(:id, :name, :email)
    ```

  - Class

    ```ruby
    class User
      attr_reader :id, :name, :email

      def initialize(id:, name:, email:)
        @id = id
        @name = name
        @email = email
      end
    end
    ```

  - ActiveRecord

    ```ruby
    # == Schema Information
    #
    # Table name: users
    #
    #  id    :bigint
    #  name  :string
    #  email :string
    class User < ApplicationRecord
    end
    ```

### Using the `Transmutation::Serialization` module

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/spellbook-technology/transmutation. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/spellbook-technology/transmutation/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Transmutation project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/spellbook-technology/transmutation/blob/main/CODE_OF_CONDUCT.md).
