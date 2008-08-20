require 'yaml'
require 'gems_parser'

class GemsConfig
  attr_reader :name

  def initialize(name)
    @name = name
  end
  
  def add_gems(file)
    new_gems = GemsParser.new(file).gems
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
    new_gems = GemsParser.new(file).gems
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

  # Load gems. Old data is automatically converted to new data.
  def gems
    gem_data = (project['gems'] ||= {})
    return gem_data if gem_data.kind_of? Hash
    new_gems = {}
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
    @config ||= load_config
  end

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

  private

  def config_file
    File.expand_path('~/.gems.yml')
  end

  def load_config
    YAML.load_file(config_file)
  rescue SystemCallError, ArgumentError
    {}
  end

  def save_config
    File.open(config_file, 'wb') {|f| f.puts(config.to_yaml)}
  end
end
