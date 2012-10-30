Integer.class_eval do
  unless instance_methods.include?(:to_date)
    def to_date
      to_time.to_date
    end
  end
  
  unless instance_methods.include?(:to_datetime)
    def to_datetime
      to_time.to_datetime
    end
  end

  unless instance_methods.include?(:to_time)
    def to_time
      Time.at(self)
    end
  end
end
