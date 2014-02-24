##
# Reset all DSL variables so specs don't interfere with each other.
#
def reset_dsl_variables(klass)
  reset_app_name(klass)
  reset_auto_paging_size(klass)
  reset_namespace(klass)
  reset_publishable_attributes(klass)
  reset_service_class(klass)
  reset_service_name(klass)
end

def reset_app_name(klass)
 klass.send(:instance_variable_set, :@app_name, nil)
end

def reset_auto_paging_size(klass)
 klass.send(:instance_variable_set, :@auto_paging_size, nil)
end

def reset_namespace(klass)
 klass.send(:instance_variable_set, :@namespace, nil)
end

def reset_publishable_attributes(klass)
 klass.send(:instance_variable_set, :@publishable_attributes, nil)
end

def reset_service_class(klass)
 klass.send(:instance_variable_set, :@service_class, nil)
end

def reset_service_name(klass)
 klass.send(:instance_variable_set, :@service_name, nil)
end
