require 'generators/evolution'
require 'rails/generators/active_record'

module Evolution
  module Generators
    class MigrationGenerator < ::ActiveRecord::Generators::Base
      extend Base

      argument :name, :type => :string, :default => 'create_evolution'

      def generate_files
        migration_template 'migration.rb', "db/migrate/#{name}.rb"
      end
    end
  end
end
