# Transmutation

Transmutation is a Ruby gem that provides a simple way to serialize Ruby objects into JSON.

It also adds an opinionated way to automatically find and use serializer classes based on the object's class name and the caller's namespace - it takes inspiration from the [Active Model Serializers](https://github.com/rails-api/active_model_serializers) gem, but strips away adapters.

It aims to be a performant and elegant solution for serializing Ruby objects into JSON, with a touch of opinionated "magic" :sparkles:.

## Installation

Add the gem to your Gemfile and then run `bundle install` to install the gem.

```ruby
gem "transmutation"
```

## Usage

### Basic Usage

- Define a serializer class that inherits from `Transmutation::Serializer` and define the attributes to be serialized.

  ```ruby
  class UserSerializer < Transmutation::Serializer
    attributes :id, :name, :email

    # You can define custom presentational attributes
    attribute :has_space_in_name do
      object.name.include?(" ")
    end

    belongs_to :organization # You can also use `has_one` or `association` to define "has one" relationships.

    has_many :posts # You can also use the `association` method to define "has many" relationships.
  end
  ```

- Serialize an object using the serializer class.

  ```ruby
  user = User.new(id: 1, name: "John Doe", email: "john@example.com")
  user.organization = Organization.new(id: 1, name: "Example Inc.")
  user.posts = [
    Post.new(id: 1, title: "My first post", body: "Sample body"),
    Post.new(id: 3, title: "This looks promising", body: "More content")
  ]

  UserSerializer.new(user).to_json # => "{\"id\":1,\"name\":\"John Doe\",\"has_space_in_name\":true,\"email\":\"john@example.com\",\"organization\":{\"id\":1,\"name\":\"Example Inc.\"},\"posts\":[{\"id\":1,\"title\":\"My first post\",\"body\":\"Sample body\"},{\"id\":3,\"title\":\"This looks promising\",\"body\":\"More content\"}]}"
  ```

  Formatted JSON output:

  ```json
  {
    "id": 1,
    "name": "John Doe",
    "has_space_in_name": true,
    "email": "john@example.com",
    "organization": {
      "id": 1,
      "name": "Example Inc."
    },
    "posts": [
      {
        "id": 1,
        "title": "My first post",
        "body": "Sample body"
      },
      {
        "id": 3,
        "title": "This looks promising",
        "body": "More content"
      }
    ]
  }
  ```

  As long as your object responds to the attributes defined in the serializer, it can be serialized.

  <details>
    <summary>Struct</summary>

    ```ruby
    User = Struct.new(:id, :name, :email)
    ```
  </details>

  <details>
    <summary>Class</summary>

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
  </details>

  <details>
    <summary>ActiveRecord</summary>

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
  </details>

### The `#serialize` method

When you include the `Transmutation::Serialization` module in your class, you can use the `#serialize` method to serialize an object.

It will attempt to find a serializer class based on the object's class name along with the caller's namespace.

```ruby
include Transmutation::Serialization

serialize(User.new) # => UserSerializer.new(User.new)
```

If no serializer class is found, it will return the object as is.

Under the hood, all `association` methods, i.e. `belongs_to`, `has_one`, and `has_many`, call `#serialize` to find the best-suited serializer class. Once a serializer class has been found once, equal circumstances will use the in-memory cache to return the serializer.

### With Ruby on Rails

When then `Transmutation::Serialization` module is included in a Rails controller, it also extends your `render` calls.

```ruby
class Api::V1::UsersController < ApplicationController
  include Transmutation::Serialization

  def show
    user = User.find(params[:id])

    render json: user
  end
end
```

This will attempt to bubble up the controller namespaces to find a defined serializer class:

- `Api::V1::UserSerializer`
- `Api::UserSerializer`
- `UserSerializer`

This calls the `#serialize` method under the hood.

If no serializer class is found, it will fall back to the default behavior of rendering the object as JSON.

You can disable this behaviour by passing `serialize: false` to the `render` method.

```ruby
render json: user, serialize: false # => user.to_json
```

## Configuration

You can override the serialization lookup by passing the following options:

- `namespace`: The namespace to use when looking up the serializer class.

  ```ruby
  render json: user, namespace: "V1" # => Api::V1::V1::UserSerializer
  ```

  To prevent caller namespaces from being appended to the provided namespace, prefix the namespace with `::`.

  ```ruby
  render json: user, namespace: "::V1" # => V1::UserSerializer
  ```

  The `namespace` key is forwarded to the `#serialize` method.

  ```ruby
  render json: user, namespace: "V1" # => serialize(user, namespace: "V1")
  ```

- `serializer`: The serializer class to use.

  ```ruby
  render json: user, serializer: "SuperUserSerializer" # => Api::V1::SuperUserSerializer
  ```

  To prevent all namespaces from being appended to the serializer class, prefix the serializer class with `::`.

  ```ruby
  render json: user, serializer: "::SuperUserSerializer" # => SuperUserSerializer
  ```

  The `serializer` key is forwarded to the `#serialize` method.

  ```ruby
  render json: user, serializer: "SuperUserSerializer" # => serialize(user, serializer: "SuperUserSerializer")
  ```

## Opinionated Architecture

If you follow the pattern outlined below, you can take full advantage of the automatic serializer lookup.

### File Structure

```
.
└── app/
    ├── controllers/
    │   └── api/
    │       ├── v1/
    │       │   └── users_controller.rb
    │       └── v2
    │           └── users_controller.rb
    ├── models/
    │   └── user.rb
    └── serializers/
        └── api/
            ├── v1/
            │   └── user_serializer.rb
            ├── v2/
            │   └── user_serializer.rb
            └── user_serializer.rb
```

### Inheritance

```ruby
class Api::UserSerializer < Transmutation::Serializer
  attributes :id, :name, :email
end

class Api::V1::UserSerializer < Api::UserSerializer
  attributes :phone # Added in V1
end

class Api::V2::UserSerializer < Api::UserSerializer
  attributes :avatar # Added in V2
end
```

To remove attributes, it is recommended to redefine all attributes and start anew. This acts as a reset and makes serializer inheritance much easier to follow.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.
