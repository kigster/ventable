module Weather
  module Conditions
    class Sunny < Weather::Conditions::Condition
      event symbol: '☀ ️'
    end
  end
end
