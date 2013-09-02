class LocaisController < ApplicationController
  skip_before_filter :complete_user_registration?

  def escolher_uma_regiao
    d = rand(999999999)
    local = signed_in? ? current_user.local : nil
    estado_id = local ? local.estado_id : nil
    cidade_id = local ? local.cidade_id : nil
    bairro_id = (local and local.bairro_id) ? local.bairro_id : nil
    estados = Estado.all(:order => "abrev ASC")
    cidades = estado_id ? Cidade.do_estado(estado_id).all : []
    bairros = cidade_id ? Bairro.da_cidade(cidade_id).all : []

    estados_options = view_context.options_for_select(estados.collect { |e| [ e.abrev, e.id ] }, estado_id)
    cidades_options = view_context.options_for_select(cidades.collect { |c| [ c.nome, c.id ] }, cidade_id)
    bairros_options = (local ? view_context.options_for_select(bairros.collect { |b| [ b.nome, b.id ] }, bairro_id) : "")

    render :update do |page|
      page.insert_html(:top, "locais",
                       :partial => "observatorios/seletor_de_local",
                        :locals => {
                          :d => d,
                          :estado_id => estado_id,
                          :cidade_id => cidade_id,
                          :bairro_id => bairro_id,
                          :estados_options => estados_options,
                          :cidades_options => cidades_options,
                          :bairros_options => bairros_options
                        })
    end
  end

  def cidades
    estado_id = _get_estado_id(params)
    @estados = Estado.find(:all, :order => "abrev ASC")
    @cidades = Cidade.includes(:estado).
      where(:estado_id => estado_id).
      paginate(:order => "cidades.nome ASC", :page => params[:page])
    @estado = @cidades.first.estado
  end

  # Cidades

  def cidades_options_for_select
    cidades = Cidade.do_estado(params[:estado_id]).includes(:estado).find(:all, :order => "nome ASC")
    local_options_for_select(cidades)
  end

  def cidades_li_for_ul
    cidades = Cidade.do_estado(params[:estado_id]).find(:all, :order => 'nome ASC')
    str_return = ""
    cs = params[:cidades_selecionadas].split(",")
    cidades.each do |cidade|
      str_return += render_to_string :partial => "locais/li_cidades",
                                              :locals => {
                                                 :cidade => cidade,
                                                 :selecionada => cs.include?(cidade.id.to_s)
                                              }
    end
    render :update do |page|
      page.replace_html 'ul_cidades', :text => str_return
    end
  end

  # Bairros

  def bairros_options_for_select
    bairros = Bairro.da_cidade(params[:cidade_id]).find(:all, :order => "nome ASC")
    local_options_for_select(bairros)
  end

  def bairros_li_for_ul
    bairros = Bairro.da_cidade(params[:cidade_id]).includes(:cidade).find(:all, :order => "nome ASC")
    render :partial => "locais/li_bairros",
           :locals => {
             :bairros => bairros,
             :selected => []
            }
  end

  protected

  def _get_estado_id(params)
    return params[:estado_id] if params[:estado_id]
    return current_user.local.estado_id if _user_signed_in_with_local

    Estado.find_by_abrev("SP").id
  end

  def _user_signed_in_with_local
    user_signed_in? && current_user.local
  end

  def local_options_for_select(collection)
    render :partial => "locais/options_for_select",
      :locals => {
        :my_collection => collection,
        :options => {
          :first_option => params[:first_option]
        }
      }
  end
end
