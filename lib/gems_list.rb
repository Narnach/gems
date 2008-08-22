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
end