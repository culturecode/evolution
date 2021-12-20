# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

# Create ActsAsDag tables
ActiveRecord::Migration.create_table :evolution_descendants, :force => true do |t|
  t.string :category_type
  t.integer :descendant_id
  t.integer :ancestor_id
  t.integer :distance
end

ActiveRecord::Migration.create_table :evolution_links, :force => true do |t|
  t.string :category_type
  t.integer :parent_id
  t.integer :child_id
end

# HELPERS

# Dummy Classes
$DUMMY_CLASS_COUNTER = 0
class CreateDummyTable < ActiveRecord::Migration[4.2]
  def self.make_table(table_name = 'dummies', columns = {})
    create_table table_name, :force => true do |t|
      columns.each do |name, type|
        t.column name, type
      end
    end
  end
end

def new_dummy_class(columns = {}, &block)
  $DUMMY_CLASS_COUNTER += 1
  klass_name = "Dummy#{$DUMMY_CLASS_COUNTER}"

  # Create the class
  eval("class #{klass_name} < #{ActiveRecord::Base}; end")
  klass = klass_name.constantize

  klass.table_name = "dummies_#{$DUMMY_CLASS_COUNTER}"
  CreateDummyTable.make_table(klass.table_name, columns)

  # Eval anything inside the dummy class
  if block_given?
    klass.instance_eval(&block)
  end

  return klass
end

# Output queries to the console
def debug_queries
  logger = ActiveRecord::Base.logger
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  yield
ensure
  ActiveRecord::Base.logger = logger
end
