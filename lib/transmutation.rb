# frozen_string_literal: true

# A performant and expressive solution for serializing Ruby objects into JSON, with a touch of opinionated "magic" ✨.
#
# @example Basic usage
#   # Define a data class.
#   class User
#     attr_reader :name, :email
#
#     def initialize(name:, email:)
#       @name = name
#       @email = email
#     end
#   end
#
#   # Define a serializer.
#   class UserSerializer < Transmutation::Serializer
#     attribute :name
#   end
#
#   # Create an instance of the data class.
#   user = User.new(name: "John", email: "john@example.com")
#
#   # Serialize the data class instance.
#   UserSerializer.new(user).to_json # => "{\"name\":\"John\"}"
#
# @example Within a Rails controller
#   class UsersController < ApplicationController
#     include Transmutation::Serialization
#
#     def show
#       user = User.find(params[:id])
#
#       # Automatically lookup the UserSerializer
#       # Serialize the data class instance using the UserSerializer
#       # Render the result as JSON to the client
#       render json: user # => "{\"name\":\"John\"}"
#     end
#   end
module Transmutation
  class Error < StandardError; end
end

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

require "active_support"
require "active_support/core_ext/object/json"
