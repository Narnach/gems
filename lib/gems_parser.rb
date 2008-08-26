class GemsParser
  attr_reader :file

  def initialize(file)
    @file = file
  end

  def gems
    @gems ||= parse_gems
  end

  protected

  def str
    @str ||= read_file
  end

  private

  def parse_gems
    parsed_gems = GemsList.new
    str.each do |line|
      gemname, *versions = line.split(" ")
      next if gemname.to_s.size == 0
      versions.each {|v| v.gsub!(/[^\d.]/,'')}
      versions = versions.select {|v| v =~ /(\d+\.)+\d+/}
      versions.flatten!
      versions.compact!
      versions.uniq!
      next if versions.size == 0
      parsed_gems[gemname] = versions
    end
    return parsed_gems
  end

  def read_file
    if file == 'current'
      return `gem list`
    else
      raise 'File does not exist: "%s"' % file unless File.exist?(file)
      return File.read(file)
    end
  end
end
