begin
  require 'debugger'
rescue Exception
end
require 'rspec'

if (Kernel.const_get('Debugger') rescue nil)
  Debugger.start
  class RSpec::Expectations::ExpectationNotMetError 
    alias_method :firstaid_initialize, :initialize

    def initialize *args, &b
      send(:firstaid_initialize, *args, &b)
      if trace :fail
	puts "Stopped due to #{self.class}: #{message} at "+caller*"\n\t"
	debugger
	true # Exception thrown
      end
    end
  end

  if $0 == __FILE__
    describe "RSpec" do
      it "should load use exceptions on should failure" do
	@foo = :bar
	1.should == 2
      end
    end
  end
end
