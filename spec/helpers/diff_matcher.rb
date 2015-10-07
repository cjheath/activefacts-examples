require 'pathname'

require 'rspec/matchers'

RSpec::Matchers.define :differ_from do |expected|
  match do |actual|
    case expected
    when Pathname
      @m = have_different_contents expected
      @m.matches?(actual)
    when Array
      # REVISIT: Check that expected should be in an extra array here:
      @m = be_different_array_from [expected]
      @m.matches?(actual)
    when String
      @m = have_different_contents expected
      @m.matches?(actual)
    else
      raise "DiffMatcher doesn't know how to match a #{expected.class}"
    end
  end

  failure_message do |actual|
    @m.failure_message
  end

  failure_message_when_negated do |actual|
    @m.failure_message_when_negated
  end

  description do
    @m.description
  end
end
