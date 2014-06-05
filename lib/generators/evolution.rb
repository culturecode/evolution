require 'rails/generators/named_base'

module Evolution
  module Generators
    module Base
      def source_root
        @_evolution_source_root ||= File.expand_path(File.join('../evolution', generator_name, 'templates'), __FILE__)
      end
    end
  end
end
