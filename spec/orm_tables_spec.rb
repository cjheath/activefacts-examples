#
# ActiveFacts test:
#
# Parse all NORMA files, compute the composition (list of tables)
# and compare that with NORMA's output.
#
# Copyright (c) 2008 Clifford Heath. Read the LICENSE file.
#

require File.dirname(__FILE__) + '/spec_helper'
require 'stringio'
require 'activefacts/metamodel'
require 'activefacts/rmap'
require 'activefacts/support'
require 'activefacts/input/orm'

ACTUAL_ORM_TABLES_PATH = 'actual/orm/tables'
EXPECTED_ORM_TABLES_PATH = 'actual/orm/expected'
FileUtils.mkdir_p(ACTUAL_ORM_TABLES_PATH)
FileUtils.mkdir_p(EXPECTED_ORM_TABLES_PATH)

# The exceptions table is keyed by the model name, and contains the added and removed table names vs NORMA
load_failures = {
  "CinemaTickets" => "Derived fact type lacks an apparently necessary uniqueness constraint",
}
norma_table_exceptions = {
  "Corporate" => [%w{}, %w{Comment ContactReport ID Money Name Nr Photo ReferenceCheck Resource TimeDivision}],          # ActiveFacts absorbs Agreement into ContextNote, Enforcement into Constraint, lots into Concept
  "Metamodel" => [%w{Query}, %w{Agreement Enforcement Comment ContactReport ID Money Nr Photo ReferenceCheck Resource TimeDivision Constraint ContextNote Fact Instance Query Unit}],          # ActiveFacts absorbs Agreement into ContextNote, Enforcement into Constraint, lots into Concept
  "MetamodelNext" => [[], %w{Agreement Enforcement TypeInheritance}],
  "Orienteering" => [%w{Punch}, []],                                # NORMA doesn't make a table for the IDENTITY field
  "OrienteeringER" => [%w{SeriesEvent}, []],                        # NORMA doesn't make a table for the IDENTITY field
  "RedundantDependency" => [%w{Politician StateOrProvince}, %w{LegislativeDistrict}],   # NORMA doesn't make a table for the 3 IDENTITY fields
  "Warehousing" => [%w{Product Warehouse}, %w{Dispatch Receipt}],                     # NORMA doesn't make a table for the IDENTITY field
  "ServiceDirector" => [%w{DataStoreService MonitorNotificationUser}, %w{DataStoreFileHostSystem }],
  "SeparateSubtype" => [%w{Claim}, %w{Incident}],
}
  
def extract_created_tables_from_sql sql_file
  File.open(sql_file) do |f|
    f.
    readlines.
    select do |l|
      l =~ /CREATE TABLE/
    end.
    map do |l|
      l.chomp.gsub(/.*CREATE TABLE\s+\W*(\w+\.)?"?(\w+)"?.*/, '\2')
    end.
    sort
  end
end

context "Relational Composition from ORM" do

  pattern = ENV["AFTESTS"] || "*"
  source_files = Dir["orm/#{pattern}.orm"]

  source_files.each do |source_file|
    base = File.basename(source_file, ".orm")
    exception = norma_table_exceptions[base]
    sql_file_pattern = source_file.sub(/\.orm\Z/, '.*sql')
    sql_file = Dir[sql_file_pattern][0]
    next unless sql_file
    next if load_failures.include?(base)

    actual_tables_file = ACTUAL_ORM_TABLES_PATH+'/'+base+'.tables'
    expected_tables_file = EXPECTED_ORM_TABLES_PATH+'/'+base+'.tables'

    table_description = (exception ? "a modified" :  "the same") + " list of tables like those in #{sql_file}"
    describe "loading #{source_file} to a compute #{table_description}" do
      begin
        vocabulary = ActiveFacts::Input::ORM.readfile(source_file)

	# Get the list of tables from our composition:
	tables = vocabulary.tables
	table_names = tables.map{|o| o.name.gsub(/\s/,'')}.sort
      rescue => e
        pending and next load_failures[base]
      end

      subject {vocabulary}
      it {should_not be_nil}
      vocabulary.finalise

      # Get the list of tables from NORMA's SQL:
      expected_tables = extract_created_tables_from_sql(sql_file)
      if exception
        expected_tables = expected_tables + exception[0] - exception[1]
      end

      # Save the actual and expected composition to files
      File.open(actual_tables_file, "w") { |f| f.puts table_names*"\n" }
      File.open(expected_tables_file, "w") { |f| f.puts expected_tables*"\n" }

      # Calculate the columns and column names; REVISIT: check the results
      tables.each do |table|
	table.columns
      end

      it "should generate the expected tables" do
	# Check that the list matched:
	expect(table_names).to_not differ_from(expected_tables)

	if table_names == expected_tables
	  File.delete(actual_tables_file)
	  File.delete(expected_tables_file)
	end
      end
    end
  end
end
