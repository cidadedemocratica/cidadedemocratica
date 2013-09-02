function incluirCidade(nome_da_cidade, pais_id, estado_id, cidade_id) {
  var lista = $$("#seletor_de_cidades .cidades_selecionadas")[0]
    , campo_da_cidade = "<input type=\"hidden\" name=\"locais[][pais_id][" + pais_id + "][estado_id][" + estado_id + "][cidade_id][]\" value=\"" + cidade_id + "\" id=\"locais_pais_id_"+ pais_id +"_estado_id_"+ estado_id +"_cidade_id_"+ cidade_id +"\" class=\"hidden_cidades_selecionadas\" />"
    , link_para_remover = "<a href=\"#\" title=\"\" onclick=\"removerCidade('" + nome_da_cidade + "', " + pais_id + ", " + estado_id + ", " + cidade_id + "); return false;\" class=\"remover\"><img src=\"/assets/icones/delete.png\" width=\"16\" height=\"16\" alt=\"Remover\" /></a>"
    , imagem_para_incluir = "<img src=\"/assets/icones/add.png\" width=\"16\" height=\"16\" alt=\"Incluir\" />"

    , item = $("cidades_a_selecionar_" + cidade_id)
    , item_selecionado = "<li id=\"cidades_selecionadas_" + cidade_id + "\">" + link_para_remover + ' ' + nome_da_cidade + campo_da_cidade + "</li>"

  Element.insert(lista, { top: item_selecionado })
  item.update(imagem_para_incluir + ' ' + nome_da_cidade)
  item.addClassName("selecionada")
}
function removerCidade(nome_da_cidade, pais_id, estado_id, cidade_id) {
  var link_para_incluir = "<a href=\"#\" title=\"\" onclick=\"incluirCidade('" + nome_da_cidade + "', " + pais_id + ", " + estado_id + ", " + cidade_id + "); return false;\" class=\"incluir\"><img src=\"/assets/icones/add.png\" width=\"16\" height=\"16\" alt=\"Incluir\" /></a>"
    , item = $("cidades_a_selecionar_" + cidade_id)
    , item_selecionado = $("cidades_selecionadas_" + cidade_id)

  item_selecionado.remove()
  if (item) {
    item.update(link_para_incluir + ' ' + nome_da_cidade)
    item.removeClassName("selecionada")
  }
}

function incluirBairro(nome, pais_id, estado_id, cidade_id, bairro_id) {
  var lista = $$("#seletor_de_bairros .bairros_selecionados")[0]
    , campo = "<input type=\"hidden\" name=\"locais[][pais_id][" + pais_id + "][estado_id][" + estado_id + "][cidade_id][" + cidade_id + "][bairro_id][]\" value=\"" + bairro_id + "\" />"
    , link_para_remover = "<a href=\"#\" title=\"\" onclick=\"removerBairro('" + nome + "', " + pais_id + ", " + estado_id + ", " + cidade_id + ", " + bairro_id  + "); return false;\" class=\"remover\"><img src=\"/assets/icones/delete.png\" width=\"16\" height=\"16\" alt=\"Remover\" /></a>"
    , imagem_para_incluir = "<img src=\"/assets/icones/add.png\" width=\"16\" height=\"16\" alt=\"Incluir\" />"

    , item = $("bairros_a_selecionar_" + bairro_id)
    , item_selecionado = "<li id=\"bairros_selecionados_" + bairro_id + "\">" + link_para_remover + ' ' + nome + campo + "</li>"

  Element.insert(lista, { top: item_selecionado })

  if (item) {
    item.update(imagem_para_incluir + ' ' + nome)
    item.addClassName("selecionada")
  }
}
function removerBairro(nome, pais_id, estado_id, cidade_id, bairro_id) {
  var link_para_incluir = "<a href=\"#\" title=\"\" onclick=\"incluirBairro('" + nome + "', " + pais_id + ", " + estado_id + ", " + cidade_id + ", " + bairro_id + "); return false;\" class=\"incluir\"><img src=\"/assets/icones/add.png\" width=\"16\" height=\"16\" alt=\"Incluir\" /></a>"
    , item = $("bairros_a_selecionar_" + bairro_id)
    , item_selecionado = $("bairros_selecionados_" + bairro_id)

  item_selecionado.remove()
  if (item) {
    item.update(link_para_incluir + ' ' + nome)
    item.removeClassName("selecionada")
  }
}

function concatenarInputValue(obj) {
  var ret = ""
  if (obj) {
    obj.each(function(item) {
      ret += item.value + ","
    })
  }
  return ret
}


function mostrarAmbito(ambito) {
  hideScopes()
  hideScopeSelectors()
  var seletor = null

  switch (ambito) {
    case "nacional":
      seletor = "seletor_de_pais"; break
    case "estadual":
      seletor = "seletor_de_estados"; break
    case "municipal":
      seletor = "seletor_de_cidades"; break
    default:
      seletor = "seletor_de_bairros"
  }

  $(seletor).removeClassName("escondido")
  // enable inputs of current selector
  $$("#" + seletor + " input").each(function(input) {
    input.disabled = false
  })
  $(ambito).addClassName("ambito_ativado")
}

function hideScopeSelectors() {
  $('ambitos').childElements().each(function(li) {
    li.removeClassName("ambito_desativado")
    li.removeClassName("ambito_ativado")
  })
}

function hideScopes() {
  // avoid send hidden sections
  $$("#localizacao_seletores input").each(function(input) {
    input.disabled = true
  })
  $("seletor_de_pais").addClassName("escondido")
  $("seletor_de_estados").addClassName("escondido")
  $("seletor_de_cidades").addClassName("escondido")
  $("seletor_de_bairros").addClassName("escondido")
}
