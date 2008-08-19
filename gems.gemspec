Gem::Specification.new do |s|
  # Project
  s.name         = 'gems'
  s.summary      = "Gems is a simple tool to manage sets of RubyGems."
  s.description  = "Gems is a simple tool to manage sets of RubyGems. It can be used to install and uninstall large numbers of gems."
  s.version      = '0.1.0'
  s.date         = '2008-08-19'
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Wes Oldenbeuving"]
  s.email        = "narnach@gmail.com"
  s.homepage     = "http://www.github.com/Narnach/gems"

  # Files
  s.bindir       = "bin"
  s.executables  = %w[gems]
  s.require_path = "lib"
  s.files        = ['MIT-LICENSE', 'README.rdoc', 'Rakefile', 'bin/gems', 'lib/gems.rb', 'lib/gems_config.rb', 'lib/gems_parser.rb', 'gems.gemspec']
  s.test_files   = []

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[ README.rdoc MIT-LICENSE]
  s.rdoc_options << '--inline-source' << '--line-numbers' << '--main' << 'README.rdoc'

  # Requirements
  s.required_ruby_version = ">= 1.8.0"
end
