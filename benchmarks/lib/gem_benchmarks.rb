# frozen_string_literal: true

class GemBenchmarks
  def self.report(**options, &block)
    new(**options, &block).groups.each_value(&:report)
  end

  def initialize(**options, &block)
    config[:output] = options.fetch(:output, true)
    config[:style] = options.fetch(:style, :markdown)

    instance_eval(&block)
  end

  def groups
    @groups ||= {}
  end

  def config
    @config ||= {}
  end

  private

  def group(name, &block)
    groups[name] = Group.new(name, **config, &block)
  end

  class Group
    attr_accessor :name, :config

    def initialize(name, **config, &block)
      @name = name
      @config = config

      instance_eval(&block)
    end

    def calculate_outputs
      examples.each_value do |example|
        example.output = example.run
      end
    end

    def calculate_time
      time_report = Benchmark.ips quiet: true do |x|
        examples.each do |name, example|
          x.report(name) { example.run }
        end
      end

      fastest_entry = time_report.entries.max_by(&:ips)

      time_report.entries.each do |entry|
        examples[entry.label].ips = "#{Benchmark::IPS::Helpers.scale(entry.ips)} #{format("±%4.1f%%", (100.0 * entry.ips_sd.to_f / entry.ips))}"
        examples[entry.label].ips_comparison = fastest_entry.ips != entry.ips ? "#{format("%.2fx slower", fastest_entry.ips.to_f / entry.ips)}" : "baseline"
      end

      time_report
    end

    def calculate_memory
      memory_report = Benchmark.memory quiet: true do |x|
        examples.each do |name, example|
          x.report(name) { example.run }
        end
      end

      smallest_entry = memory_report.entries.min_by { |entry| entry.measurement.memory.allocated }

      memory_report.entries.each do |entry|
        examples[entry.label].allocations = Benchmark::Memory::Helpers.scale(entry.measurement.memory.allocated)
        examples[entry.label].allocations_comparison = smallest_entry.measurement.memory.allocated != entry.measurement.memory.allocated ? "#{format("%.2fx more", entry.measurement.memory.allocated.to_f / smallest_entry.measurement.memory.allocated)}" : "baseline"
      end

      memory_report
    end

    def calculate
      calculate_outputs if config[:output]
      calculate_time
      calculate_memory

      nil
    end

    def report
      calculate

      table = Terminal::Table.new(headings:, rows:, style: { border: config[:style] })

      table.align_column 1, :right
      table.align_column 2, :right
      table.align_column 3, :right
      table.align_column 4, :right

      puts "### #{name}\n\n#{table}\n\n"
    end

    def examples
      @examples ||= {}
    end

    def headings
      ["Gem", "IPS", "Comparison", "Allocations", "Comparison", (config[:output] ? "Output" : nil)].compact
    end

    def rows
      examples.values.lazy.sort_by(&:ips).reverse.map do |example|
        [example.label, example.ips, example.ips_comparison, example.allocations, example.allocations_comparison, (config[:output] ? example.output : nil)].compact
      end
    end

    private

    def example(gem_name, &block)
      examples[gem_name] = Example.new(gem_name, **config, &block)
    end

    class Example
      attr_accessor :label, :block, :ips, :ips_comparison, :allocations, :allocations_comparison, :output
      attr_accessor :gem_name, :config

      def initialize(gem_name, **config, &block)
        @gem_name = gem_name
        @config = config
        @label = if config[:style] == :markdown
                   "[#{gem_name} #{gem_version}](#{gem_url})"
                 else
                   "#{gem_name} #{gem_version}"
                 end
        @block = block
      end

      def run
        block.call
      end

      private

      def gem_version
        specs.version
      end

      def gem_url
        specs.metadata["source_code_uri"] || specs.homepage || "https://rubygems.org/gems/#{gem_name}"
      end

      def specs
        Gem.loaded_specs[gem_name]
      end
    end
  end
end
