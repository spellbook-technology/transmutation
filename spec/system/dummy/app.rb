# frozen_string_literal: true

require "json"

require_relative "controllers/base_controller"
require_relative "controllers/api/application_controller"
require_relative "controllers/api/v1/users_controller"
require_relative "controllers/api/v1/posts_controller"
require_relative "models/post"
require_relative "models/user"
require_relative "serializers/api/v1/post_serializer"
require_relative "serializers/api/v1/user_serializer"
require_relative "serializers/api/v1/detailed/post_serializer"
require_relative "serializers/api/v1/detailed/user_serializer"
