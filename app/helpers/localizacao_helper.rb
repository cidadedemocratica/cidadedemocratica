module LocalizacaoHelper
  def select_estado(local, my_options = {})
    options = {
      :dom_id => "estado_id"
    }.merge!(my_options)
    select_tag("local[estado_id]", options_for_select(Estado.find(:all, :order => "abrev ASC").collect { |c| [ "#{c.abrev} - #{c.nome}", c.id ] }, cidade_escolhida(local, options).estado_id), :id => options[:dom_id])
  end

  def select_bairro(local, options = {})
    options = {
      :first_option => nil,
      :class => "filtro",
      :style => "width:200px"
    }.merge(options)

    bairro_escolhido_id = local ? local.bairro_id : nil

    lista_de_opcoes = ""
    lista_de_opcoes += "<option value=null>#{options[:first_option]}</option>" if options[:first_option]
    lista_de_opcoes += options_for_select(Bairro.find(:all, :conditions => { :cidade_id => cidade_escolhida(local, options).id }, :order => "nome ASC").collect{ |b| [ b.nome, b.id ] }, bairro_escolhido_id)

    select_tag("local[bairro_id]", lista_de_opcoes.html_safe, options.delete_if { |k,v|  k.to_s == "cidade_corrente" }) + content_tag(:span, " opcional", :class => "ajuda")
  end

  def select_cidade(local, options = {})
    options = {
      :first_option => nil,
      :class => "filtro"
    }.merge!(options)

    lista_de_opcoes = ""
    lista_de_opcoes += "<option value=null>#{options[:first_option]}</option>" if options[:first_option]
    lista_de_opcoes += options_for_select(Cidade.find(:all, :conditions => { :estado_id => cidade_escolhida(local, options).estado_id }, :order => "nome ASC").collect { |c| [ c.nome, c.id ] }, cidade_escolhida(local, options).id)

    select_tag "local[cidade_id]", lista_de_opcoes.html_safe, options.delete_if { |k,v|  k.to_s == "cidade_corrente" }
  end

  def cidade_escolhida(local, options = {})
    if local and local.cidade_id
      Cidade.find(local.cidade_id)
    elsif options[:cidade_corrente]
      options[:cidade_corrente]
    else
      Cidade.find_by_nome "São Paulo"
    end
  end

  def descrever_locais(locais)
    locais.map do |local|
      link_to local, topicos_path(local.to_link_hash)
    end.join(" - ").html_safe rescue ""
  end

  def local_ambito
    if @topico.locais.present?
      @topico.locais.first.ambito
    else
      # default ambito
      "municipal"
    end
  end
end
