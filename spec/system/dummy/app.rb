# frozen_string_literal: true

require "json"

require_relative "controllers/base_controller"
require_relative "controllers/api/application_controller"
require_relative "controllers/api/v1/health_controller"
require_relative "controllers/api/v1/posts_controller"
require_relative "controllers/api/v1/products_controller"
require_relative "controllers/api/v1/users_controller"
require_relative "lib/money"
require_relative "models/post"
require_relative "models/product"
require_relative "models/user"
require_relative "serializers/api/v1/post_serializer"
require_relative "serializers/api/v1/user_serializer"
require_relative "serializers/api/v1/detailed/post_serializer"
require_relative "serializers/api/v1/detailed/user_serializer"
require_relative "serializers/money_serializer"
require_relative "serializers/product_serializer"
