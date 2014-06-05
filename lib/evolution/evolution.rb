module Evolution
  module ActiveRecord
    module ActMethod
      def track_evolution
        extend Evolution::ActiveRecord::ClassMethods
        include Evolution::ActiveRecord::InstanceMethods

        acts_as_dag :link_table => 'evolution_links', :descendant_table => 'evolution_descendants'

        # Set initialize the generation of a new record
        before_validation :on => :create do |record|
          record.generation ||= 1
        end
      end
    end

    module ClassMethods
      def converge!(*parents)
        attributes = parents.extract_options!
        parents = parents.flatten
        parents = find(parents) unless parents.all?{|p| p.is_a? self }

        raise UnableToConverge, "Can't converge fewer than two records" unless parents.many?
        raise UnableToConverge, "Can't converge unsaved records" if parents.any?(&:new_record?)

        record = create!(attributes.merge( :generation => parents.collect(&:generation).max + 1 ))

        parents.flatten.each do |parent|
          record.add_parent(parent)
        end

        return record
      end
    end

    module InstanceMethods
      # Creates a new child copy of the record
      def evolve!
        raise UnableToEvolve, "Can't evolve unsaved record" if new_record?
        raise UnableToEvolve, "Can't evolve extinct record" if extinct?

        child = self.dup
        child.generation += 1
        child.save!
        add_child(child)

        return child
      end

      # Marks the record as exitinct, i.e. no more records can evolve from it
      def extinct!
        raise UnableToExtinct, "Can't extinct an already extinct record" if extinct?
        update_column(:extinct, true)
      end

      def revive!
        raise UnableToRevive, "Can't revive an unextinct record" unless extinct?
        update_column(:extinct, false)
      end

      def destroy_and_relink!
        parents = self.parents.to_a
        children = self.children.to_a

        destroy

        if parents.present?
          children.each do |child|
            parents.each do |parent|
              parent.add_child(child)
            end
          end
        else
          children.each(&:make_root)
        end
      end

      def evolution_status
        return :extinct if extinct?
        return :current if children.empty?
        return :historic
      end
    end
  end

  class UnableToEvolve < StandardError; end
  class UnableToExtinct < StandardError; end
  class UnableToRevive < StandardError; end
  class UnableToConverge < StandardError; end
end
