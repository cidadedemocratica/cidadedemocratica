module MailerHelper
  
  # Retorna uma string que descreve textualmente as atividades do observatorio
  def resumo_numerico_do_observatorio(atividades)
    str = "Não houve atividade alguma em seu observatório."
    topico = 0
    adesao = 0
    comentario = 0
    atividades.each do |a|
      case a
        when Topico, Proposta, Problema
          topico += 1
        when Adesao
          adesao += 1
        when Comment
          comentario += 1
      end
    end
    if ((topico != 0) or (comentario != 0) or (adesao != 0))
      str = ""
      str += "##>  #{pluralize(topico, 'Proposta/problema', 'Propostas e problemas')} que usuários cadastraram.\n" if (topico > 0)
      str += "##>  #{pluralize(comentario, 'Comentário novo', 'Comentários novos')} nas propostas e problemas de seu interesse.\n" if (comentario > 0)
      str += "##>  #{pluralize(adesao, 'Novo Apoio', 'Novos Apoios')} às propostas e problemas que você observa.\n" if (adesao > 0)
    end
    return str
  end
  
  # Retorna uma string que descreve textualmente os temas do observatorio
  def observatorio_temas(observatorio)
    if observatorio.tags.empty?
      str = "Todos os temas"
    else
      tmp = []
      observatorio.tags.each { |tema| tmp << "\"#{tema.name}\"" }
      ultimo = tmp.pop
      str  = tmp.join(", ")
      str += " ou #{ultimo}"
    end
    return str
  end
  
  # Retorna uma string que descreve textualmente os locais do observatorio
  def observatorio_locais(observatorio)
    if observatorio.locais.empty?
      str = "Em todos o site, independente da localização"
    else
      tmp = []
      observatorio.locais.each do |local|
        tmp << "em todo o país" if (local.ambito == "nacional")
        tmp << "no estado '#{local.estado.nome}'" if (local.ambito == "estadual")
        tmp << "na cidade '#{local.cidade.nome}-#{local.cidade.estado.abrev}'" if (local.ambito == "municipal")
        tmp << "no bairro '#{local.bairro.nome} (#{local.bairro.cidade.nome}-#{local.bairro.cidade.estado.abrev})'" if (local.ambito == "local")
      end
      ultimo = tmp.pop
      str  = tmp.join(", ")
      str += " ou #{ultimo}"
    end
    return str
  end

  # Retorna o rodapé para todos os e-mails enviados.
  def rodape
    rodape = "..........................................................................\n"
    rodape += "\n"
    rodape += "Cidade Democrática: www.cidadedemocratica.org.br\n"
    rodape += "Apóie, colabore, aponte problemas e crie propostas para uma cidade melhor"
    return rodape
  end

  def tipo_do_comentario(comentario)
    case comentario.tipo
      when "comentario"
        "fez um comentário"
      when "pergunta"
        "fez uma pergunta"
      when "resposta"
        "deu uma resposta"
      when "ideia"
        "lançou sua ideia"
    end
  end

  def quebra
    "\n"
  end

  def url_para_observatorio
    "http://www.cidadedemocratica.org.br/meu-observatorio"
  end

  def url_para_editar_observatorio
    "http://www.cidadedemocratica.org.br/meu-observatorio/editar"
  end

end
