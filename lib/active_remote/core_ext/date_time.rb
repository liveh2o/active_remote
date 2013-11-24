DateTime.class_eval do
  unless instance_methods.include?(:to_i)
    def to_i
      to_time.to_i
    end
  end
end
