require 'test_helper'

class AttributeMapperTest < Test::Unit::TestCase

  context "Attribute Mapper" do
    setup do
      Ticket.map_attribute :status, :to => mapping
    end

    should "set mapping for each attribute" do
      assert_equal mapping[:open], Ticket.statuses[:open]
      assert_equal mapping[:closed], Ticket.statuses[:closed]
    end

    should "override getters and setters" do
      assert_nil ticket.status
      assert_nothing_raised do
        ticket.status = :open
      end
      assert_equal :open, ticket.status
      assert_equal mapping[:open], ticket[:status]

      assert_nothing_raised do
        ticket.status = :closed
      end

      assert_equal :closed, ticket.status
      assert_equal mapping[:closed], ticket[:status]
    end

    should 'define predicates for each attribute' do
      ticket.status = :open
      assert ticket.open?
    end

    should "allow indifferent access to setters" do
      assert_nothing_raised do
        ticket.status = :open
      end
      assert_equal :open, ticket.status
      assert_nothing_raised do
        ticket.status = 'open'
      end
      assert_equal :open, ticket.status
    end

    should "raise an exception when trying to map to a non-existent column" do
      assert_raises(ArgumentError) do
        Ticket.map_attribute :this_column_does_not_exist, :to => {:i_will_fail => 1}
      end
    end

    should "raise an exception when setting an invalid value" do
      assert_raises(ArgumentError) do
        ticket.status = :non_existent_value
      end
    end

    should "allow setting a primitive value directly if the value is present in the mapping" do
      ticket = Ticket.new
      assert_nothing_raised do
        ticket.status = mapping[:open]
      end

      assert_equal :open, ticket.status

      assert_raises(ArgumentError) do
        ticket.status = 500
      end
    end

    should "work with mass assignment" do
      ticket.update_attributes(:status => :open, :name => 'Red is too red')
    end

    should "work with attr_accessible" do
      new_ticket = Class.new(ActiveRecord::Base) do
        set_table_name "tickets"

        include AttributeMapper
        map_attribute :status, :to => {:open => 1, :closed => 2}

        attr_accessible :status
      end

      t = new_ticket.new
      t.status = :open

      assert_equal :open, t.status
    end

    should "provide a helper for forms" do
      assert_equal [[["Closed", :closed], ["Open", :open]]], ticket.status_options
      assert_equal [[["Open", :open], ["Closed", :closed]]], ticket.status_options(false)
      ticket.status = :open
      assert_equal [[["Open", :open], ["Closed", :closed]], {:selected => :open}], ticket.status_options(false)
    end

    should "provide a class level helper for forms" do
      assert_equal [["Closed", :closed], ["Open", :open]], Ticket.status_options
      assert_equal [["Open", :open], ["Closed", :closed]], Ticket.status_options(false)
    end

    should "not raise an error when setting to a blank value" do
      assert_nothing_raised {
        ticket.update_attributes(:status => "")
      }
    end

    should "not raise an error when setting to a nil value" do
      assert_nothing_raised {
        ticket.update_attributes(:status => nil)
      }
    end

    should "turn off generation of predicate methods" do
      new_ticket = Class.new(ActiveRecord::Base) do
        set_table_name "tickets"

        include AttributeMapper
        map_attribute :status, :to => {:open => 1, :closed => 2}, :predicate_methods => false
      end

      t = new_ticket.new
      t.status = :open

      assert_raises(NoMethodError) {
        t.open?
      }
    end

    
    context "setting nil as a valid value in the mapping" do
      setup do
        Ticket.map_attribute :status, :to => mapping(:unanswered => nil)
      end

      should "allow setting the status by primitive value" do
        assert_nothing_raised do
          ticket.status = mapping[:unanswered]
        end
        assert_equal :unanswered, ticket.status
        assert ticket.unanswered?
      end

      
      should "allow setting the status by symbol" do
        assert_nothing_raised do
          ticket.status = :unanswered
        end
        assert_equal :unanswered, ticket.status
        assert ticket.unanswered?
      end

    end

    should 'auto-expand arrays to a hash with the raw value being the index + 1' do
      array_ticket = Class.new(ActiveRecord::Base) do
        set_table_name "tickets"

        include AttributeMapper
        map_attribute :status, :to => [:open, :closed]
      end

      ticket = array_ticket.new

      assert_nil ticket.status
      assert_nothing_raised do
        ticket.status = :open
      end
      assert_equal :open, ticket.status
      assert_equal mapping[:open], ticket[:status]

      assert_nothing_raised do
        ticket.status = :closed
      end

      assert_equal :closed, ticket.status
      assert_equal mapping[:closed], ticket[:status]

    end

  end

  #######
  private
  #######

  def mapping(options = {})
    {:open => 1, :closed => 2}.merge(options)
  end

  def ticket
    @ticket ||= Ticket.new
  end

end
