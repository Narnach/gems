require 'gems_config'
require 'gems_parser'
require 'gems_list'

class Hash
  def longest_key_length
    map{|key, value| key.to_s.size}.max || 0
  end
end

class Gems
  attr_reader :project, :gems, :gems_config

  def initialize(project)
    @project = project
    @gems_config = GemsConfig.new(@project)
    @gems = @gems_config.gems
  end

  def diff_current
    current_gems = GemsList.new(GemsParser.new('current').gems)
    project_gems = GemsList.new(gems)
    not_in_current = project_gems - current_gems
    in_current = current_gems - project_gems

    puts 'Gems unique to "%s":' % project
    print_gem_list(not_in_current)
    puts
    puts 'Gems unique to the current gems list:'
    print_gem_list(in_current)
  end

  def list
    puts 'Gems in "%s":' % project
    print_gem_list(gems)
  end

  def install
    puts "Installing all gems and versions in '%s'" % project
    results = {}
    each_gem_with_version do |gemname, version|
      cmd = "sudo gem install --ignore-dependencies --no-rdoc --no-ri -v %s %s" % [version, gemname]
      if gems_config.options_for(gemname).size > 0
        cmd << ' -- %s' % gems_config.options_for(gemname).join(" ")
      end
      puts cmd
      result = system(cmd)
      results['%s-%s' % [gemname, version]] = result
    end
    successful = results.select {|gemname, success| success}
    unsuccessful = results.select {|gemname, success| !success}
    puts
    puts "Successfully installed: %s" % successful.map{|ary| ary[0]}.sort.join(", ")
    puts
    puts "Failed to install: %s" % unsuccessful.map{|ary| ary[0]}.sort.join(", ")
  end

  def uninstall
    puts "Uninstalling all gems and versions in '%s'" % project
    results = {}
    each_gem_with_version do |gemname, version|
      cmd = "sudo gem uninstall --ignore-dependencies --executables -v %s %s" % [version, gemname]
      puts cmd
      result = system(cmd)
      results['%s-%s' % [gemname, version]] = result
    end
    successful = results.select {|gemname, success| success}
    unsuccessful = results.select {|gemname, success| !success}
    puts
    puts "Successfully uninstalled: %s" % successful.map{|ary| ary[0]}.sort.join(", ")
    puts
    puts "Failed to uninstall: %s" % unsuccessful.map{|ary| ary[0]}.sort.join(", ")
  end

  private

  def each_gem_with_version(&block)
    raise ArgumentError, 'No block provided' unless block
    gems.each do |gemname, versions|
      versions.each do |version|
        block.call(gemname, version)
      end
    end
  end

  def print_gem_list(gems)
    gems.each do |gemname, versions|
      line = "%#{gems.longest_key_length}s %s" % [gemname, versions.join(", ")]
      if gems_config.options_for(gemname).size > 0
        line << ' [%s]' % gems_config.options_for(gemname).join(" ")
      end
      puts line
    end
  end
end
