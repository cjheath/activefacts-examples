#
# ActiveFacts tests: Parse all NORMA files and check the generated CQL.
# Copyright (c) 2008 Clifford Heath. Read the LICENSE file.
#

require File.dirname(__FILE__) + '/spec_helper'
require 'stringio'
require 'activefacts/metamodel'
require 'activefacts/support'
require 'activefacts/input/cql'
require 'activefacts/generators/cql'

describe "CQL Parser" do
  cql_failures = {
    "Airline" => "Contains queries, unsupported",
    "CompanyQuery" => "Contains queries, unsupported",
  }

  pattern = ENV["AFTESTS"] || "*"
  source_files = Dir["cql/#{pattern}.cql"]
  source_files.each do |cql_file|
    context "should load CQL #{cql_file} without parse errors" do
      broken = cql_failures[File.basename(cql_file, ".cql")]

      vocabulary = nil
      if broken
        pending(broken) {
          lambda { vocabulary = ActiveFacts::Input::CQL.readfile(cql_file) }.should_not raise_error
        }
      else
	  subject {
	    lambda { vocabulary = ActiveFacts::Input::CQL.readfile(cql_file) }
	  }
	  it { should_not raise_error }
      end
      vocabulary.finalise if vocabulary
    end
  end
end
