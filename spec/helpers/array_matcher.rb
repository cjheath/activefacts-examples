RSpec::Matchers.define :be_different_array_from do |x|
  match do |actual|
    perform_match(actual, expected_as_array)
    @extra + @missing != []
  end

  def perform_match(actual, expected)
    @extra = actual - expected
    @missing = expected - actual
  end

  failure_message do |actual|
    "expected a difference in the two lists, but got none"
  end

  failure_message_when_negated do |actual|
    "expected no difference, but result #{
      [ (@missing.empty? ? nil : 'lacks '+@missing.sort.inspect),
        (@extra.empty? ? nil : 'has extra '+@extra.sort.inspect)
      ].compact * ' and '
    }"
  end

  description do
    "differ from expected set"
  end
end
