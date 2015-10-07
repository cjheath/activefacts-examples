#
# ActiveFacts tests: Parse all CQL files and check the generated Ruby.
# Copyright (c) 2008 Clifford Heath. Read the LICENSE file.
#

require 'spec_helper'
require 'stringio'
require 'activefacts/metamodel'
require 'activefacts/support'
require 'activefacts/input/cql'
require 'activefacts/generators/ruby'

ACTUAL_PATH = 'actual/ruby'
FileUtils.mkdir_p(ACTUAL_PATH)

# Generate and return the Ruby for the given vocabulary
def generate(vocabulary)
  output = StringIO.new
  @dumper = ActiveFacts::Generators::RUBY.new(vocabulary.constellation)
  @dumper.generate(output)
  output.rewind
  output.read
end

class String
  def strip_comments()
    c_comment = %r{/\*((?!\*/).)*\*/}m
    gsub(c_comment, '').gsub(%r{\n\n+},"\n")
  end
end

context "CQL Loader" do
  load_failures = {
    "Airline" => "Contains queries, not supported",
    "CompanyQuery" => "Contains queries, not supported",
    # "OrienteeringER" => "Invalid model, it just works differently in CQL"
  }
  generate_failures = {
  }

  pattern = ENV["AFTESTS"] || "*"
  source_files = Dir["cql/#{pattern}.cql"]

  source_files.each do |source_file|
    expected_file = source_file.sub(%r{cql/(.*).cql\Z}, 'ruby/\1.rb')
    actual_file = source_file.sub(%r{cql/(.*).cql\Z}, ACTUAL_PATH+'/\1.rb')

    File.delete(actual_file) rescue nil	  # Delete if the file exists
    describe "compiling #{source_file} to a model" do
      broken = load_failures[File.basename(source_file, ".cql")]
      vocabulary = nil
      if broken
        pending(broken) {
          vocabulary = ActiveFacts::Input::CQL.readfile(source_file)
        }
      else
        begin
          vocabulary = ActiveFacts::Input::CQL.readfile(source_file)
        rescue => e
          trace :exception, "#{e.message}\n" +
            "\t#{e.backtrace*"\n\t"}"
          raise
        end
      end
      subject {vocabulary}
      it {should_not be_nil}
      vocabulary.finalise

      context "and generating #{actual_file}" do
	# Build and save the actual file:
	actual_text = generate(vocabulary)
	File.open(actual_file, "w") { |f| f.write actual_text }
	pending("expected output file #{expected_file} not found") and next unless File.exists? expected_file
	expected_text = File.open(expected_file) {|f| f.read }

	broken = generate_failures[File.basename(actual_file, ".cql")]
	if broken
	  pending(broken) {
	    subject { actual_text }
	    it { should_not differ_from(expected_text) }
	  }
	else
	  subject { actual_text }
	  it { should_not differ_from(expected_text) }
	  if expected_text == actual_text
	    File.delete(actual_file)  # It succeeded, we don't need the file.
	  end
	end
      end
    end
  end
end
