require 'gems_config'

class Gems
  attr_reader :project, :gems, :gems_config

  def initialize(project)
    @project = project
    @gems_config = GemsConfig.new(@project)
    @gems = @gems_config.gems
  end

  def list
    puts 'Gems in "%s":' % project
    gems.each do |gemname, versions|
      line = "%#{longest_gem_name_length}s %s" % [gemname, versions.join(", ")]
      if gems_config.options_for(gemname).size > 0
        line << ' [%s]' % gems_config.options_for(gemname).join(" ")
      end
      puts line
    end
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

  def longest_gem_name_length
    gems.map{|ary| ary[0].size}.max
  end
end
