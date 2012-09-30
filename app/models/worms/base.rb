module Worms
  class Base
    def self.date2key(date)
      date.strftime('%Y-%m-%d')
    end
  end
end
