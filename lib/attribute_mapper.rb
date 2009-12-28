module AttributeMapper
  
  def self.included(model)
    model.extend ClassMethods
    model.send(:include, InstanceMethods)
  end
  
  module ClassMethods # @private
    
    # Map a column in your table to a human-friendly attribute on your model.
    #
    # @example Define a Ticket model with a status column that maps to open or closed
    #   map_attribute :status, :to => {:open => 1, :closed => 2}
    #
    # @param [String] attribute the column to map on
    # @param [Hash] options the options for this attribute
    # @option options [Hash] :to The enumeration to use for this attribute. See example above.
    def map_attribute(attribute, options)
        mapping = options[:to]
        verify_existence_of attribute
        add_accessor_for    attribute, mapping
        override            attribute
    end
    
    private
      def add_accessor_for(attribute, mapping)
        class_eval(<<-EVAL)
          class << self
            def #{attribute.to_s.pluralize}
              #{mapping.inspect}
            end
          end
        EVAL
      end
    
      def override(*args)
        override_getters *args
        override_setters *args
      end
      
      def override_getters(attribute)
        class_eval(<<-EVAL)
          def #{attribute}
            self.class.#{attribute.to_s.pluralize}.invert[read_attribute(:#{attribute})]
          end
        EVAL
      end
      
      def override_setters(attribute)
        class_eval(<<-EVAL)
          def #{attribute}=(raw_value)
            value = resolve_value_of :#{attribute}, raw_value
            write_attribute(:#{attribute}, value)
          end
        EVAL
      end
      
      def verify_existence_of(attribute)
        raise ArgumentError, "`#{attribute}' is not an attribute of `#{self}'" unless column_names.include?(attribute.to_s)
      end
  end
  
  module InstanceMethods
    private
      def resolve_value_of(attribute, raw_value)
        check_value = raw_value.is_a?(String) ? raw_value.to_sym : raw_value
        mapping = self.class.send(attribute.to_s.pluralize)
        raise ArgumentError, "`#{check_value}' not present in attribute mapping `#{mapping.inspect}'" unless mapping.to_a.flatten.include? check_value
        mapping[check_value] || check_value
      end
  end
end
