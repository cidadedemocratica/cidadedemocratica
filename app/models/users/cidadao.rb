class Cidadao < User
  
  def descricao_basica
    if self.sexo == "m"
      str = "Homem, "
    else
      str = "Mulher, "
    end
    str += "#{self.idade} anos"
    return str
  end

  def nome_do_tipo
    (self.sexo.present? and self.sexo == "f") ? "Cidadã" : "Cidadão"
  end

  def nome_da_classe
    "cidadao"
  end
end
