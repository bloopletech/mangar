class Fixnum
  alias_method :to_str, :to_s

  alias_method :spaceship_original, :<=>
  def <=>(s2)
    if(s2.is_a?(String))
      self.to_s <=> s2
    else
      spaceship_original(s2)
    end
  end
end
