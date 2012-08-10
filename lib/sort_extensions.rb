=begin
class String
  alias_method :spaceship_original, :<=>
  def <=>(s2)
    if(!s2.is_a?(String))
      self <=> s2.to_s
    else
      spaceship_original(s2)
    end
  end
end
=end

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

  alias_method :equals_original, :==
  def ==(s2)
    if(s2.is_a?(String))
      return false
    else
      equals_original(s2)
    end
  end
end
