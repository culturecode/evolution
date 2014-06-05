# Evolution

## Installation

In your Gemfile
```ruby
gem 'evolution', :github => 'culturecode/evolution'
```

Generate the tables
```bash
rails generate evolution:migration
```

Add the tracking columns to your own tables in a migration
```ruby
add_column 'my_models', :extinct, :boolean, :default => false
add_column 'my_models', :generation, :integer
add_index 'my_models', :extinct

MyModel.update_all(:extinct => false)
MyModel.update_all(:generation => 1)

change_column_null 'my_models', :extinct, false
change_column_null 'my_models', :generation, false
```

## Usage

```ruby
doc = Document.create
new_doc = doc.evolve
new_doc.generation #=> 2
```
