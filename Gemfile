source 'https://rubygems.org'

gemspec

if ENV['PWD'] =~ %r{\A#{ENV['HOME']}/work}
  $stderr.puts "Using work area gems for #{File.basename(File.dirname(__FILE__))} from activefacts-examples"
  gem 'activefacts-api', path: '/Users/cjh/work/activefacts/api'
  gem 'activefacts-metamodel', path: '/Users/cjh/work/activefacts/metamodel'
  gem 'activefacts-rmap', path: '/Users/cjh/work/activefacts/rmap'
  gem 'activefacts-cql', path: '/Users/cjh/work/activefacts/cql'
  gem 'activefacts-orm', path: '/Users/cjh/work/activefacts/orm'
  gem 'activefacts-generators', path: '/Users/cjh/work/activefacts/generators'
end
