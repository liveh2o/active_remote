Date.class_eval do
  unless respond_to?(:to_i)
    def to_i
      to_time.to_i
    end
  end
end
