require 'support/models'

##
# Reset all DSL variables so specs don't interfere with each other.
#
def reset_dsl_variables(klass)
  klass.send(:instance_variable_set, :@app_name, nil)
  klass.send(:instance_variable_set, :@auto_paging_size, nil)
  klass.send(:instance_variable_set, :@namespace, nil)
  klass.send(:instance_variable_set, :@publishable_attributes, nil)
  klass.send(:instance_variable_set, :@service_class, nil)
  klass.send(:instance_variable_set, :@service_name, nil)
end
