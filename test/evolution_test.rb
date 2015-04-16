require 'test_helper'

class EvolutionTest < ActiveSupport::TestCase
  klass = new_dummy_class(:name => :string, :extinct => :boolean, :generation => :integer) do
      track_evolution
    end

  # SAVE

  test '#save sets the generation number to 1 if it is blank' do
    record = klass.create!
    assert_equal 1, record.generation
  end

  # EVOLVE

  test '#evolve! creates a new copy of self with all the same attributes' do
    record = klass.create!(:name => 'test1')
    child = record.evolve!

    assert child.persisted?
    assert_equal record.attributes.except('id', 'generation'), child.attributes.except('id', 'generation')
  end

  test '#evolve! increments the generation number on the new copy' do
    record = klass.create!
    child = record.evolve!

    assert_equal record.generation + 1, child.generation
  end

  test '#evolve! raises an exception if the record is not persisted' do
    record = klass.new
    assert_raises(Evolution::UnableToEvolve) { record.evolve! }
  end

  test '#evolve! raises an exception if the record is extinct' do
    record = klass.create!
    record.extinct!
    assert_raises(Evolution::UnableToEvolve) { record.evolve! }
  end

  test '#evolve! makes self a parent of the new copy' do
    record = klass.create!
    child = record.evolve!

    assert_equal [record], child.parents
    assert_equal [child], record.children
    assert_equal [record, child].sort, child.ancestors.sort
    assert_equal [record, child].sort, record.descendants.sort
  end

  # EXTINCT

  test '#extinct! marks self as extinct' do
    record = klass.create!
    record.extinct!

    assert record.extinct?
  end

  test '#extinct! raises an exception if already extinct' do
    record = klass.create!
    record.extinct!
    assert_raises(Evolution::UnableToExtinct) { record.extinct! }
  end

  test '#extinct! raises an exception if already historic' do
    record = klass.create!
    record.evolve!
    assert_raises(Evolution::UnableToExtinct) { record.extinct! }
  end

  # REVIVE

  test '#revive unmarks self as extinct' do
    record = klass.create!
    record.extinct!
    record.revive!

    assert !record.extinct?
  end

  test '#revive! raises an exception if not extinct' do
    record = klass.create!
    assert_raises(Evolution::UnableToRevive) { record.revive! }
  end

  # CONVERGE

  test '::converge! creates a new record with the given and make it a child of all records passed as arguments' do
    parent1 = klass.create!
    parent2 = klass.create!
    child = klass.converge!(parent1, parent2)

    assert_equal [parent1, parent2], child.parents.sort_by(&:id)
    assert_equal [child], parent1.children
    assert_equal [child], parent2.children
  end

  test '::converge! raises an exception unless two or more parents are passed' do
    assert_raises(Evolution::UnableToConverge) { klass.converge! }
    assert_raises(Evolution::UnableToConverge) { klass.converge!(klass.create!) }
    assert_nothing_raised(Evolution::UnableToConverge) { klass.converge!(klass.create!, klass.create!) }
  end

  test '::converge! raises an exception unless all parents are persisted' do
    assert_raises(Evolution::UnableToConverge) { klass.converge!(klass.new, klass.create!) }
  end

  test '::converge! raises an exception if any parent is extinct' do
    record = klass.create!
    record.extinct!
    assert_raises(Evolution::UnableToConverge) { klass.converge!(record, klass.create!) }
  end

  test '::converge! accepts an options hash and assigns it as attributes of the new record' do
    child = klass.converge!(klass.create!, klass.create!, :name => 'test_converge')

    assert_equal 'test_converge', child.name
  end

  test '::converge! accepts an array of ids as parents' do
    ids = [klass.create!.id, klass.create!.id]
    child = klass.converge!(ids)

    assert_equal ids.sort, child.parent_ids.sort
  end

  test '::converge! increments the generation on the new copy using the highest generation number of the given parents' do
    parent1 = klass.create!(:generation => 4)
    parent2 = klass.create!(:generation => 1)
    child = klass.converge!(parent1, parent2)

    assert_equal 5, child.generation
  end

  # DESTROY AND RELINK

  test '#destroy_and_relink makes all parents of the destroyed record, parents of all children of the destroyed record' do
    parent1 = klass.create!
    parent2 = klass.create!
    child = klass.converge!(parent1, parent2)
    grandchild1 = child.evolve!
    grandchild2 = child.evolve!

    child.reload.destroy_and_relink!

    assert_equal [grandchild1, grandchild2], parent1.reload.children.sort_by(&:id)
    assert_equal [grandchild1, grandchild2], parent2.reload.children.sort_by(&:id)
  end

  test '#destroy_and_relink makes the record a root node if it has no parents' do
    parent = klass.create!
    child = parent.evolve!
    parent.destroy_and_relink!

    assert child.reload.root?
  end

  # EVOLUTION STATUS

  test '#evolution_status returns :current if the record has no children' do
    assert_equal :current, klass.create!.evolution_status
  end

  test '#current? returns true if the record is current' do
    assert klass.create!.current?
  end

  test '#evolution_status returns :current if the record is extinct, regardless of other statuses' do
    record = klass.create!
    record.extinct!
    assert_equal :extinct, record.evolution_status
  end

  test '#extinct? returns true if the record is extinct' do
    record = klass.create!
    record.extinct!
    assert record.extinct?
  end

  test '#evolution_status returns :historic if the record is not extinct and has children' do
    record = klass.create!
    record.evolve!
    assert_equal :historic, record.evolution_status
  end

  test '#historic? returns true if the record is historic' do
    record = klass.create!
    record.evolve!

    assert record.historic?
  end
end
