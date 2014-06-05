require 'evolution/evolution'
require 'acts_as_dag'

ActiveRecord::Base.extend Evolution::ActiveRecord::ActMethod

module Evolution
end
