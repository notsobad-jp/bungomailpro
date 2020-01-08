class String
  def word_count
    return if self.nil?
    self.delete("\r\n").scan(/[\w.\/:;'-]+/).length
  end
end
