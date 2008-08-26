Gem::Specification.new do |s|
  # Project
  s.name         = 'gems'
  s.summary      = "Gems is a simple tool to manage sets of RubyGems."
  s.description  = "Gems is a simple tool to manage sets of RubyGems. It can be used to install and uninstall large numbers of gems."
  s.version      = '0.2.0'
  s.date         = '2008-08-26'
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Wes Oldenbeuving"]
  s.email        = "narnach@gmail.com"
  s.homepage     = "http://www.github.com/Narnach/gems"

  # Files
  s.bindir       = "bin"
  s.executables  = %w[gems]
  s.require_path = "lib"
  root_files     = %w[MIT-LICENSE README.rdoc Rakefile gems.gemspec]
  bin_files      = %w[gems]
  lib_files      = %w[gems gems_config gems_parser gems_list]
  test_files     = %w[]
  spec_files     = %w[]
  s.test_files   = test_files.map {|f| 'test/%s_test.rb' % f} + spec_files.map {|f| 'spec/%s_spec.rb' % f}
  s.files        = root_files + s.test_files + bin_files.map {|f| 'bin/%s' % f} + lib_files.map {|f| 'lib/%s.rb' % f}

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[ README.rdoc MIT-LICENSE]
  s.rdoc_options << '--inline-source' << '--line-numbers' << '--main' << 'README.rdoc'

  # Requirements
  s.required_ruby_version = ">= 1.8.0"
end
