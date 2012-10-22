Integer.class_eval do
  unless respond_to?(:to_date)
    def to_date
      to_time.to_date
    end
  end
  
  unless respond_to?(:to_datetime)
    def to_datetime
      to_time.to_datetime
    end
  end

  unless respond_to?(:to_time)
    def to_date
      Time.at(self)
    end
  end
end
