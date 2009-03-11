require 'test/unit'
require 'rubygems'
require 'test/spec'
require 'active_support'
require 'active_record'
require 'attribute_mapper'

AttributeMapper.load

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Schema.define do 
  create_table :tickets do |table|
    table.column :status, :integer
  end
end

# Pseudo model for testing purposes
class Ticket < ActiveRecord::Base
end

context "Attribute Mapper" do
  def setup
    Ticket.map_attribute :status, :to => mapping
  end
  
  specify "mapping for each attribute is set" do
    assert_equal mapping[:open], Ticket.statuses[:open]
    assert_equal mapping[:closed], Ticket.statuses[:closed]
  end
  
  specify "getters and setters are overridden" do
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
  
  specify "setters allow indifferent access" do
    assert_nothing_raised do
      ticket.status = :open
    end
    assert_equal :open, ticket.status
    assert_nothing_raised do
      ticket.status = 'open'
    end
    assert_equal :open, ticket.status
  end
  
  specify "trying to map a non existant column fails" do
    assert_raises(ArgumentError) do
      Ticket.map_attribute :this_column_does_not_exist, :to => {:i_will_fail => 1}
    end
  end
  
  specify "setting an invalid value" do
    assert_raises(ArgumentError) do
      ticket.status = :non_existent_value
    end
  end
  
  specify "setting a primitive value directly works if primitive value is present in attribute mapping" do
    ticket = Ticket.new
    assert_nothing_raised do
      ticket.status = mapping[:open]
    end
    
    assert_equal :open, ticket.status
    
    assert_raises(ArgumentError) do
      ticket.status = 500
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