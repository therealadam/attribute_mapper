# AttributeMapper

AttributeMapper provides a transparent interface for mapping
symbolic representations to a column in the database of a more primitive type.
For example, rather than hardcoding values like 1 or 2 to represent that a
Ticket model's status column is "open" or "closed" you would create the
following mapping:

    class Ticket < ActiveRecord::Base
      include AttributeMapper
      
      map_attribute :status, :to => {:open => 1, :closed => 2}
    end
  
You can now get and set the status column symbolically:

    ticket.status = :open
    ticket.status # => :open
  
Internally, the integer 1 will be stored in the database.

An authoritative list of the mapping is available as a class method which is the pluralized version of the attribute:

    Ticket.statuses # => {:open => 1, :closed => 2}
  
The primitive values of the mapping can always be used to assign the column,
though the getter for the attribute will always return the higher level
symbolic representation.

    ticket.status = 1
    ticket.status # => :open

## Authors

Marcel Molina, Jr., Bruce Williams and Adam Keys

Released under the MIT License (see LICENSE).
