# frozen_string_literal: true

class BaseController
  def render(json:)
    JSON.parse(JSON.generate(json))
  end
end
