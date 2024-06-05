# frozen_string_literal: true

module Transmutation
  # @api private
  module ClassAttributes
    def class_attribute(
      *names,
      instance_accessor: true,
      instance_reader: instance_accessor,
      instance_writer: instance_accessor,
      default: nil
    )
      class_attribute_reader(*names, instance_reader: instance_reader, default: default)
      class_attribute_writer(*names, instance_writer: instance_writer, default: default)
    end

    def class_attribute_reader(*names, instance_reader: true, default: nil)
      names.each do |name|
        self.class.define_method(name) do
          instance_variable_get("@#{name}")
        end

        define_method(name) { self.class.send(name) } if instance_reader

        instance_variable_set("@#{name}", default)
      end
    end

    def class_attribute_writer(*names, instance_writer: true, default: nil)
      names.each do |name|
        self.class.define_method("#{name}=") do |value|
          instance_variable_set("@#{name}", value)
        end

        define_method("#{name}=") { |value| self.class.send("#{name}=", value) } if instance_writer

        instance_variable_set("@#{name}", default)
      end
    end
  end
end
