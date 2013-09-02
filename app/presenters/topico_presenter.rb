module TopicoPresenter
  def display_location
    locais.collect { |l| l.descricao }.join(', ')
  end

  def keywords
    keywords = display_name.downcase
    keywords += ",#{tags.collect{|t| t.name}.join(',')}" if tags
  end

  def nome_do_tipo(options = {})
    str = ""
    my_options = {
      :artigo => false, # pode ser :definido, :indefinido
      :possessivo => false, #se true, "seu", "sua"
      :demonstrativo => false, #se true, "esse", "essa"
      :plural => false
    }.merge!(options)

    if my_options[:demonstrativo]
      str += "esse" if self.type.to_s == "Problema"
      str += "essa" if self.type.to_s == "Proposta"
    end

    if my_options[:artigo] == :indefinido
      str += "um" if self.type.to_s == "Problema"
      str += "uma" if self.type.to_s == "Proposta"
    elsif my_options[:artigo] == :definido
      str += self.artigo_definido
    end

    if my_options[:possessivo]
      str += "seu" if self.type.to_s == "Problema"
      str += "sua" if self.type.to_s == "Proposta"
    end

    if my_options[:indefinido]
      str += "outro" if self.type.to_s == "Problema"
      str += "outra" if self.type.to_s == "Proposta"
    end

    return "#{str} #{self.display_name.downcase}"
  end

  def artigo_definido
    "o"
  end

  def display_name
    type.to_s
  end
end
