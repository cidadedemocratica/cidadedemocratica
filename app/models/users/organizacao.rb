class Organizacao < User
  
  def descricao_basica
    return self.type
  end
  
  def nome_do_tipo
    "Organização"
  end
  
  def nome_da_classe
    "organizacao"
  end
end
