#
# ActiveFacts tests: Parse all NORMA files and check the generated JSON for the diagrams
# Copyright (c) 2011 Clifford Heath. Read the LICENSE file.
#

require File.dirname(__FILE__) + '/spec_helper'
require 'stringio'
require 'activefacts/metamodel'
require 'activefacts/support'
require 'activefacts/input/orm'
require 'activefacts/generators/diagrams/json'

ACTUAL_DIAGRAMS_JSON_PATH = 'actual/diagrams/json'
FileUtils.mkdir_p(ACTUAL_DIAGRAMS_JSON_PATH)

# Generate and return the JSON for the given vocabulary
def generate_diagrams_json(vocabulary)
  output = StringIO.new
  @dumper = ActiveFacts::Generators::Diagrams::JSON.new(vocabulary.constellation)
  @dumper.generate(output)
  output.rewind
  output.read
end

def sequential_uuids t
  i = 1
  sequence = {}
  t.gsub /"........-....-....-....-......"/ do |uuid|
    (sequence[uuid] ||= i += 1).to_s
  end
end

context "ORM Loader" do

  load_failures = {
    "SubtypePI" => "Has an illegal uniqueness constraint",
  }
  generate_failures = {
    # "OddIdentifier" => "Strange identification pattern is incorrectly verbalised to CQL",  # Fixed
    "UnaryIdentification" => "No PI for VisitStatus",
  }

  pattern = ENV["AFTESTS"] || "*"
  source_files = Dir["orm/#{pattern}.orm"]

  source_files.each do |source_file|
    base = File.basename(source_file, ".orm")
    expected_file = 'diagrams/json/'+base+'.json'
    actual_file = ACTUAL_DIAGRAMS_JSON_PATH+'/'+base+'.json'

    File.delete(actual_file) rescue nil	  # Delete if the file exists

    describe "loading #{source_file} to a model" do
      begin
        vocabulary = ActiveFacts::Input::ORM.readfile(source_file)
      rescue => e
        raise unless load_failures.include?(base)
        pending load_failures[base]
      end

      subject {vocabulary}
      it {should_not be_nil}
      vocabulary.finalise

      it "should generate the expected #{actual_file}" do
	actual_text = nil
	expect { actual_text = generate_diagrams_json(vocabulary) }.to_not raise_error
	File.open(actual_file, "w") { |f| f.write actual_text }
	unless File.exists? expected_file
	  skip "expected output file #{expected_file} not found"
	end

	expected_text = File.open(expected_file) {|f| f.read }

	broken = generate_failures[base]
	pending(broken) if broken

	actual_text = sequential_uuids(actual_text)
	expected_text = sequential_uuids(expected_text)

	expect(actual_text).to_not differ_from(expected_text)
	if expected_text == actual_text
	  File.delete(actual_file)  # It succeeded, we don't need the file.
	end
      end
    end
  end
end
