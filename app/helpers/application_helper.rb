module ApplicationHelper

  def flash_message
    messages = ""
    [:notice, :info, :warning, :error, :alert].each do |type|
      messages = content_tag(:p, flash[type], :class => type) if flash[type]
    end
    content_tag(:div, messages, :id => "flash_message") if (messages and not messages.empty?)
  end

  def sexo(dados)
    if dados.sexo == 'm'
      image_tag "icones/male.png"
    elsif dados.sexo == 'f'
      image_tag "icones/female.png"
    end
  end

  def tag_cloud(tags, &block)
    super(tags.sort_by(&:name), %w(nuvem_1 nuvem_2 nuvem_3 nuvem_4 nuvem_5), &block)
  end

  def tag_cloud_contexto(tags, options = {}, classes = %w(nuvem_1 nuvem_2 nuvem_3 nuvem_4 nuvem_5))
    if tags and not tags.empty?
      if options[:relevancia]
        max_count = tags.sort_by{ |t| t.relevancia.to_i }.last.relevancia.to_f
      else
        max_count = tags.sort_by{ |t| t.total.to_i }.last.total.to_f
      end

      # hack when user has only tags with zero relevance
      max_count = 1 if max_count == 0.0

      tags.sort{ |b,a| b.name.downcase.remover_acentos <=> a.name.downcase.remover_acentos }.each do |tag|
        if options[:relevancia]
          index = ((tag.relevancia.to_f / max_count.to_f) * (classes.size - 1)).to_i
        else
          index = ((tag.total.to_f / max_count.to_f) * (classes.size - 1)).to_i
        end
        yield tag, classes[index]
      end
    end
  end

  def menu_link_to_with_context(name, type, html_options = {})
    # just keep context in some controllers
    context = ["users", "topicos"].include?(controller_name)
    self.send("link_to_#{type}_with_context", name, {}, html_options, context)
  end

  def link_to_topicos_with_context(name, options = {}, html_options = {}, context = true)
    options = options.stringify_keys

    if context
      settings = settings_for_context(options, %w(topico_type estado_abrev cidade_slug bairro_id tag_id user_type order))
    else
      settings = options
    end
    settings = link_with_context_order(settings, Topico::ORDERS)
    html_options = select_item_based_on_params(options, html_options)

    link_to name, topicos_path(settings), html_options
  end

  def link_to_usuarios_with_context(name, options = {}, html_options = {}, context = true)
    options = options.stringify_keys

    if context
      settings = settings_for_context(options, %w(user_type estado_abrev cidade_slug bairro_id order))
    else
      settings = options
    end
    settings = link_with_context_order(settings, User::ORDERS)
    html_options = select_item_based_on_params(options, html_options)

    link_to name, usuarios_path(settings), html_options
  end

  def link_to_competition_with_context(name, options = {}, html_options = {}, context = true)
    options = options.stringify_keys

    if context
      options["phase"] = @phase.to_s unless options.key? "phase"
      settings = settings_for_context(options, %w(tag_id order))
    else
      settings = options
    end
    settings = link_with_context_order(settings, Competition::ORDERS)
    html_options = select_item_based_on_params(options, html_options)

    link_to name, competition_path(settings), html_options
  end

  def filtro(nome_do_filtro, links, options = {})
    options = {
      :numero_de_links => 10,
      :expandido => false
    }.merge(options)
    render :partial => "/shared/filtro",
           :locals => {
             :nome_do_filtro => nome_do_filtro,
             :links => links,
             :url_para_ver_mais => "",
             :options => options
           }
  end

  def is_owner?(model)
    user_signed_in? and current_user.owns? model
  end

  def is_owner_or_admin?(model)
    user_signed_in? and (current_user.admin? or current_user.owns? model)
  end

  def pluralize_without_count(count, singular, plural = nil)
    pluralize(count, singular, plural).sub(/^\d+\s/, "")
  end

  def cache_unless_admin name = {}, options = nil, &block
    if not user_signed_in? or not current_user.admin?
      cache name, options, &block
    else
      yield
    end
  end

  protected

  def select_item_based_on_params(options, html_options)
    if options.merge(params).slice(*options.keys) == options
      html_options[:class] = "#{html_options[:class].to_s} selected"
    end
    html_options
  end

  def link_with_context_order(settings, orders)
    settings["order"] = nil if settings["order"] and not orders.include?(settings["order"])
    settings
  end

  def settings_for_context(options, allowed_params)
    params.slice(*allowed_params).merge(options)
  end

end
