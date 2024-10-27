# frozen_string_literal: true

module MarkdownHelper
  def parse_markdown_table(markdown, nil_value: "nil")
    header_row, _, *rows = markdown.split("\n")
    header_names = header_row.delete_prefix("|").split("|")&.map(&:strip)

    rows.map do |raw_row|
      parse_markdown_row(raw_row, nil_value:, header_names:)
    end
  end

  private

  def cast_nil_value(value, nil_value:)
    value == nil_value ? nil : value
  end

  def parse_markdown_row(raw_row, nil_value:, header_names:)
    row = raw_row.delete_prefix("|").split("|")&.map(&:strip)

    row.each_with_object({}).with_index do |(value, hash), index|
      hash[header_names[index].to_sym] = cast_nil_value(value, nil_value:)
    end
  end
end
