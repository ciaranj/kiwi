
helpers do
  def resolve version, versions
    op, version = version.strip.split
    versions.sort.find do |other|
      case op
      when '='  ; other == version
      when '>'  ; other > version
      when '>=' ; other >= version
      when '>~'
        other[0..1] == version[0..1] && other >= version
      end
    end
  end
end