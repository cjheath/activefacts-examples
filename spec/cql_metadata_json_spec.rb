#
# ActiveFacts tests: Parse all CQL files and check the generated JSON Metadata
# Copyright (c) 2013 Clifford Heath. Read the LICENSE file.
#

require 'spec_helper'
require 'stringio'
require 'activefacts/metamodel'
require 'activefacts/support'
require 'activefacts/input/cql'
require 'activefacts/generators/metadata/json'

ACTUAL_METADATA_JSON_PATH = 'actual/metadata/json'
FileUtils.mkdir_p(ACTUAL_METADATA_JSON_PATH) unless File.exist?(ACTUAL_METADATA_JSON_PATH)

# Generate and return the JSON Metadata for the given vocabulary
def generate_metadata_json(vocabulary)
  output = StringIO.new
  @dumper = ActiveFacts::Generators::Metadata::JSON.new(vocabulary.constellation)
  @dumper.generate(output)
  output.rewind
  output.read
end

def sequential_uuids t
  i = 1
  sequence = {}
  t.gsub /"........-....-....-....-............"/ do |uuid|
    (sequence[uuid] ||= i += 1).to_s
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
    expected_file = source_file.sub(%r{cql/(.*).cql\Z}, 'metadata/json/\1.json')
    actual_file = source_file.sub(%r{cql/(.*).cql}, ACTUAL_METADATA_JSON_PATH+'/\1.json')

    File.delete(actual_file) if File.exist?(actual_file)
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
	actual_text = generate_metadata_json(vocabulary)
	File.open(actual_file, "w") { |f| f.write actual_text }

	pending("expected output file #{expected_file} not found") and next unless File.exists? expected_file
	expected_text = File.open(expected_file) {|f| f.read }

	broken = generate_failures[File.basename(actual_file, ".cql")]

	if broken
	  pending(broken) {
	    subject { sequential_uuids(actual_text) }
	    it { should_not differ_from(sequential_uuids(expected_text)) }
	  }
	else
	  actual_text = sequential_uuids(actual_text)
	  expected_text = sequential_uuids(expected_text)
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
