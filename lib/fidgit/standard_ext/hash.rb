class Hash
  # Merge not only the hashes, but all nested hashes as well.
  # Written by Stefan Rusterholz (apeiros) from http://www.ruby-forum.com/topic/142809
  def deep_merge!(other)
    merger = lambda do |key, a, b|
      (a.is_a?(Hash) && b.is_a?(Hash)) ? a.merge!(b, &merger) : b
    end

    merge!(other, &merger)
  end
end