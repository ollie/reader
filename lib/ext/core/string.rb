class String
  def present?
    self !~ /\A\s*\z/
  end
end
