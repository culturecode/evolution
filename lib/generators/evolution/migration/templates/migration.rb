class CreateEvolution < ActiveRecord::Migration
  def up
    create_table :evolution_descendants, :force => true do |t|
      t.string :category_type
      t.integer :descendant_id
      t.integer :ancestor_id
      t.integer :distance

      t.index [:descendant_id, :category_type]
      t.index [:ancestor_id, :category_type]
    end

    create_table :evolution_links, :force => true do |t|
      t.string :category_type
      t.integer :parent_id
      t.integer :child_id

      t.index [:parent_id, :category_type]
      t.index [:child_id, :category_type]
    end
  end

  def self.down
    drop_table :evolution_descendants
    drop_table :evolution_links
  end
end
