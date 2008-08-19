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
      puts "%#{longest_gem_name_length}s %s" % [gemname, versions.join(", ")]
    end
  end
  
  def install
    puts "Installing all gems and versions in '%s'" % project
    each_gem_with_version do |gemname, version|
      cmd = "sudo gem install --ignore-dependencies --no-rdoc --no-ri -v %s %s" % [version, gemname]
      puts cmd
      system(cmd)
    end
  end
  
  def uninstall
    puts "Uninstalling all gems and versions in '%s'" % project
    each_gem_with_version do |gemname, version|
      cmd = "sudo gem uninstall --ignore-dependencies --executables -v %s %s" % [version, gemname]
      puts cmd
      system(cmd)
    end
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
