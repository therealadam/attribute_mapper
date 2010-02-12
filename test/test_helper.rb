require 'test/unit'
require 'shoulda'

require 'active_record'
require 'attribute_mapper'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Schema.define do 
  create_table :tickets do |table|
    table.column :status, :integer
    table.column :name, :string
  end
end

# Pseudo model for testing purposes
class Ticket < ActiveRecord::Base
  include AttributeMapper
end

