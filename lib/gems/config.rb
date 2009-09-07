require 'yaml'
require 'gems/parser'

module Gems
  class Config
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def add_gems(file)
      new_gems = Gems::Parser.new(file).gems
      new_gems.each do |gemname, versions|
        versions.each do |version|
          add_gem(gemname, version)
        end
      end
      save_config
    end

    def export_gems(file)
      File.open(file,'wb') do |f|
        gems.sort_by{|gemname, versions| gemname}.each do |gemname, versions|
          f.puts "%s (%s)" % [gemname, versions.join(", ")]
        end
      end
    end

    def import_gems(file)
      new_gems = Gems::Parser.new(file).gems
      self.gems = new_gems
      save_config
    end

    def options_for(gemname)
      gem_options[gemname] || []
    end

    def set_gem_options(gemname, options)
      gem_options[gemname] = options
      save_config
    end

    # Load gems.
    #
    # Returns a Gems::List.
    #
    # Old data structures are automatically converted to new data structures.
    def gems
      gem_data = (project['gems'] ||= Gems::List.new)
      return gem_data if gem_data.kind_of? Gems::List
      if gem_data.kind_of? Hash
        project['gems'] = Gems::List.new(gem_data)
        save_config
        return gems
      end
      new_gems = Gems::List.new
      gem_data.each do |gem_ary|
        new_gems[gem_ary[0]] = gem_ary[1]
      end
      project['gems'] = new_gems
      save_config
      return gems
    end

    def project_names
      projects.keys.sort
    end

    protected

    def add_gem(gemname, version)
      gems[gemname] ||= []
      gems[gemname] << version
      gems[gemname].uniq!
      gems[gemname].sort!
    end

    def config
      @config ||= config_content
    end
    alias_method :load_config, :config

    def gem_options
      project['gems_options'] ||= {}
    end

    def gems=(new_gems)
      project['gems'] = new_gems
    end

    def project
      projects[name] ||= {}
    end

    def projects
      config['projects'] ||= {}
    end

    def save_config
      File.open(config_file, 'wb') {|f| f.puts(config.to_yaml)}
    end

    private

    def config_file
      File.expand_path('~/.gems.yml')
    end
    
    def config_content
      YAML.load_file(config_file)
    rescue SystemCallError, ArgumentError => e
      {}
    rescue TypeError => e
      $stderr.puts "Upgrading #{config_file}"
      require 'gems/updater'
      updater = Gems::Updater.new(name)
      updater.update
      retry
    end
  end
end