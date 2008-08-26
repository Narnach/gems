module LongestKeyLength
  def longest_key_length
    map{|key, value| key.to_s.size}.max || 0
  end
end

class Hash
  include LongestKeyLength
end
