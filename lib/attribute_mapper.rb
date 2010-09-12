module AttributeMapper

  def self.included(model)
    model.extend ClassMethods
    model.send(:include, InstanceMethods)
  end

  module ClassMethods # @private

    # Map a column in your table to a human-friendly attribute on your
    # model. When +attribute+ is accessed, it will return the key
    # from the mapping hash. When the attribute is updated, the value
    # from the mapping hash is written to the database.
    #
    # A class method is also added providing access to the mapping
    # hash, i.e. defining an attribute +status+ will add a
    # +statuses+ class method that returns the hash passed to the
    # +:to+ option.
    #
    # Predicates are also added to each object for each attribute. If
    # you have a key +open+ in your mapping, your objects will have
    # an +open?+ method that returns true if the attribute value is
    # +:open+
    #
    # Each attribute you map generates an options method, suitable for
    # use in form helpers. If you define an attribute +status+,
    # instances of your model will have a +status_options+ method
    # (on the class and any instances)
    # that returns a sorted array of arrays containing
    # humanized-option-name/value pairs. By default this array is
    # sorted by the option name (closed/open/etc.) If you'd rather
    # sort by value, pass +false+ to the options method. This method
    # also will set the selected option for records where the
    # attribute is already set.
    #
    # @example Define a Ticket model with a status column:
    #   map_attribute :status, :to => {:open => 1, :closed => 2}
    #
    # @param [String] attribute the column to map on
    # @param [Hash] options the options for this attribute
    # @option options [Hash] :to The enumeration to use for this
    #   attribute. See example above.
    # @option options :predicate_methods Generate methods for checking
    #   whether an object has a certain attribute set
    def map_attribute(attribute, options)
      mapping = build_mapping(options)
      verify_existence_of attribute
      add_accessor_for    attribute, mapping
      add_predicates_for  attribute, mapping.keys if options.fetch(:predicate_methods) { true }
      override            attribute
      add_options_helper_for attribute, mapping
      add_options_helper_to_class attribute, self
    end

    private
    def build_mapping(options)
      case options[:to]
      when Hash
        options[:to]
      when Array
        build_mapping_from_array(options[:to])
      end
    end

    # Transforms an array into a hash for the mapping.
    #   [:open, :closed] # => { :open => 1, :closed => 2 }
    #
    def build_mapping_from_array(array)
      array.enum_for(:each_with_index).inject({}) { |h, (o, i)| h[o] = i+1; h }
    end

    def add_accessor_for(attribute, mapping)
      class_eval(<<-EVAL, __FILE__, __LINE__)
        class << self
          def #{attribute.to_s.pluralize}
            #{mapping.inspect}
          end
        end
      EVAL
    end

    def add_predicates_for(attribute, names)
      names.each do |name|
        class_eval(<<-RUBY, __FILE__, __LINE__)
          def #{name}?
            self.#{attribute} == :#{name}
          end
        RUBY
      end
    end

    def add_options_helper_for(attribute, mapping)
      class_eval(<<-EVAL, __FILE__, __LINE__)
        def #{attribute}_options(sort_by_keys=true)
          options = self.class.#{attribute.to_s.pluralize}.sort { |l, r|
            sort_by_keys ? l.first.to_s <=> r.first.to_s : l.last <=> r.last
          }.map { |f|
            [f[0].to_s.capitalize, f[0]]
          }
          self.#{attribute}.present? ? [options, {:selected => self.#{attribute}}] : [options]
        end
      EVAL
    end

    def add_options_helper_to_class(attribute, klass)
      klass.instance_eval(<<-EVAL, __FILE__, __LINE__)
        def #{attribute}_options(sort_by_keys=true)
          options = #{attribute.to_s.pluralize}.sort { |l, r|
            sort_by_keys ? l.first.to_s <=> r.first.to_s : l.last <=> r.last
          }.map { |f|
            [f[0].to_s.capitalize, f[0]]
          }
        end
      EVAL
    end

    def override(*args)
      override_getters *args
      override_setters *args
    end

    def override_getters(attribute)
      class_eval(<<-EVAL, __FILE__, __LINE__)
        def #{attribute}
          self.class.#{attribute.to_s.pluralize}.invert[read_attribute(:#{attribute})]
        end
      EVAL
    end

    def override_setters(attribute)
      class_eval(<<-EVAL, __FILE__, __LINE__)
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
      return raw_value if raw_value.blank?
      check_value = raw_value.is_a?(String) ? raw_value.to_sym : raw_value
      mapping = self.class.send(attribute.to_s.pluralize)
      raise ArgumentError, "`#{check_value}' not present in attribute mapping `#{mapping.inspect}'" unless mapping.to_a.flatten.include? check_value
      mapping.include?(check_value) ? mapping[check_value] : check_value
    end

  end

end
