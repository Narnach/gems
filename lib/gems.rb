require 'gems_config'
require 'gems_parser'
require 'gems_list'

class Gems
  attr_reader :project, :projects, :gems, :gems_config

  def initialize(*projects)
    @projects = projects.flatten
    @project = projects.first
    @gems_config = GemsConfig.new(@project)
    @gems = @gems_config.gems
  end

  def diff_current
    not_in_current = projects_gems - current_gems_list
    in_current = current_gems_list - projects_gems

    puts 'Gems unique to "%s":' % projects.join(", ")
    print_gem_list(not_in_current)
    puts
    puts 'Gems unique to the current gems list:'
    print_gem_list(in_current)
  end

  def list
    list_name = projects.size == 1 ? 'Gems in' : 'Union of all gems in'
    projects_list = projects.join(", ")
    puts '%s %s:' % [list_name, projects_list]
    print_gem_list(projects_gems)
  end

  def install
    puts "Installing all gems and versions in '%s'" % project
    install_gems_list(gems - current_gems_list)
  end

  def switch_from_current
    puts 'Switching to %s:' % projects.join(", ")
    to_install = projects_gems - current_gems_list
    to_uninstall = current_gems_list - projects_gems

    install_gems_list(to_install)
    uninstall_gems_list(to_uninstall)
  end

  def uninstall
    puts "Uninstalling all gems and versions in '%s'" % project
    uninstall_gems_list(gems)
  end

  private

  def current_gems_list
    @current_gems_list ||= GemsParser.new('current').gems
  end

  def install_gems_list(gems)
    results = {}
    gems.each_gem_with_version do |gemname, versions|
      versions.each do |version|
        cmd = "sudo gem install --ignore-dependencies --no-rdoc --no-ri -v %s %s > /dev/null" % [version, gemname]
        if gems_config.options_for(gemname).size > 0
          cmd << ' -- %s' % gems_config.options_for(gemname).join(" ")
        end
        puts cmd
        result = system(cmd)
        results['%s-%s' % [gemname, version]] = result
      end
    end
    successful = results.select {|gemname, success| success}
    unsuccessful = results.select {|gemname, success| !success}
    puts
    puts "Successfully installed: %s" % successful.map{|ary| ary[0]}.sort.join(", ")
    puts
    puts "Failed to install: %s" % unsuccessful.map{|ary| ary[0]}.sort.join(", ")
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

  def projects_gems
    @projects_gems ||= projects.inject(GemsList.new) do |gems_list, project|
      gems_list + GemsConfig.new(project).gems
    end
  end

  def uninstall_gems_list(gems)
    results = {}
    gems.each_gem_with_version do |gemname, version|
      cmd = "sudo gem uninstall --ignore-dependencies --executables -v %s %s > /dev/null" % [version, gemname]
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
end
