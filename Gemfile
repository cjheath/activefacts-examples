source 'https://rubygems.org'

gemspec

if ENV['PWD'] =~ %r{\A#{ENV['HOME']}/work}i
  $stderr.puts "Using work area gems for #{File.basename(File.dirname(__FILE__))} from activefacts-examples"
  gem 'activefacts-api', path: '../api'
  gem 'activefacts-metamodel', path: '../metamodel'
  gem 'activefacts-rmap', path: '../rmap'
  gem 'activefacts-cql', path: '../cql'
  gem 'activefacts-orm', path: '../orm'
  gem 'activefacts-generators', path: '../generators'
end
