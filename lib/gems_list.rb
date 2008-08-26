class GemsList < Hash
  def initialize(hsh={})
    hsh.each do |key, value|
      self[key] = value
    end
  end

  def -(other)
    diff = GemsList.new
    self.each do |gem, versions|
      if other.has_key?(gem)
        other_versions = other[gem]
        versions_unique_to_current = versions - other_versions
        diff[gem] = versions_unique_to_current if versions_unique_to_current.size > 0
      else
        diff[gem] = versions
      end
    end
    diff
  end

  # Returns a new Gemlist which is the union of both GemLists.
  def +(other)
    union = GemList.new
    self.each do |gem, versions|
      union[gem] = versions
    end
    other.each do |gem, versions|
      if union.has_key? gem
        union[gem] = (union[gem] + versions).uniq.sort
      else
        union[gem] = versions
      end
    end
    union
  end

  def each_gem_with_version(&block)
    raise ArgumentError, 'No block provided' unless block
    self.each do |gemname, versions|
      versions.each do |version|
        block.call(gemname, version)
      end
    end
  end

  def longest_key_length
    map{|key, value| key.to_s.size}.max || 0
  end
end