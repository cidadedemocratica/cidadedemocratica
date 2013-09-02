module UsersHelper

  def ficha_do_usuario(usuario, options = {})
    render "users/ficha_do_usuario", :usuario => usuario, :options => options
  end

  def ficha_do_usuario_full(usuario, options = {})
    render "users/ficha_do_usuario_full", :usuario => usuario, :options => options
  end

  # Lista de usuários
  def usuarios(usuarios, options = {})
    options = {
      :vazio => "Não há usuários",
      :ficha_do_usuario_options => {}
    }.merge(options)
    render :partial => "users/usuarios",
           :locals => {
             :usuarios => usuarios,
             :options => options
           }
  end

  def lista_relacionados(users)
    html = '<ul id="usuarios_relacionados">'
      User.where(:id => users.map(&:id)).includes(:dado, :imagens).find_each do |user|
        html += "<li>#{link_to_perfil_with_avatar(user)}</li>"
      end
    html += "</ul>"
    html.html_safe
  end

  def link_to_perfil_with_avatar(user, options = {})
    link_to perfil_avatar(user, options), perfil_path(user)
  end

  def perfil_avatar(user, options = {})
    options = {
      :version => :mini,
      :image_options => {
        :class => "perfil_avatar #{user.nome_da_classe}",
        :alt => user.nome
      }
    }.merge(options)

    if user.imagem
      file = user.imagem.public_filename(options[:version] == "big" ? nil : options[:version])
    elsif user.organizacao?
      file = "icones/avatares/avatar_padrao_organizacao_#{options[:version]}.png"
    elsif user.sexo == "f"
      file = "icones/avatares/avatar_padrao_cidada_#{options[:version]}.png"
    else
      file = "icones/avatares/avatar_padrao_cidadao_#{options[:version]}.png"
    end
    image_tag(file, options[:image_options])
  end

  def descreve(obj, user, target = nil, my_options = {})
    options = {
      :truncate_comentario => false
    }.merge!(my_options)

    case obj.class.to_s
      when /(Proposta|Problema)/
        str = "<li class=\"#{obj.display_name.downcase} rounded\">"
        str += descreve_proposta(obj, user, target) if (obj.class == Proposta)
        str += descreve_problema(obj, user, target) if (obj.class == Problema)
      when "Inspiration"
        str = "<li class=\"inspiration rounded\">"
        str += "<i class='icon-plus-sign'></i>"
        str += "<div class='detalhes'><b>Deixou</b> uma inspiração<br />"
        str += link_to(obj.title, competition_path(obj.competition,
          :phase => 'inspiration_phase',
          :anchor => 'inspiration_' + obj.id.to_s
        ))
        str += "</div>"

      when "Comment"
        str = "<li class=\"comment #{obj.tipo} rounded\">"
        if obj.commentable_type and (obj.commentable_type.to_s == 'Topico')
          topico_comentado = Comment.find_commentable(obj.commentable_type, obj.commentable_id)
          str += descreve_comentario(obj, user, topico_comentado, target, options) if (obj.tipo=="comentario")
          str += descreve_pergunta(obj, user, topico_comentado, target, options) if (obj.tipo=="pergunta")
          str += descreve_resposta(obj, user, topico_comentado, target, options) if (obj.tipo=="resposta")
          str += descreve_ideia(obj, user, topico_comentado, target, options) if (obj.tipo=="ideia")
        end
      when "Adesao"
        str = "<li class=\"adesao rounded\">"
        str += descreve_adesao(obj, user, target)
      when "Seguido"
        str = "<li class=\"seguido rounded\">"
        str += descreve_seguido(obj, user, target)
    end
    str += "<span class=\"quando\">Há #{distance_of_time_in_words_to_now(obj.created_at)}.</span>"
    str += "</li>"
    return str.html_safe
  end

  def descreve_problema(obj, user, target)
    str = "<i class='icon-plus-sign'></i>"
    str += "<div class='detalhes'><b>Apontou</b> um <span class=\"topico_type problema\">problema</span><br />"
    str += link_to(obj.titulo, topico_url(:topico_slug => obj.to_param))
    str += "</div>"
  end

  def descreve_proposta(obj, user, target)
    str = "<i class='icon-plus-sign'></i>"
    str += "<div class='detalhes'><b>Criou</b> uma <span class=\"topico_type proposta\">proposta</span><br />"
    str += link_to(obj.titulo, topico_url(:topico_slug => obj.to_param))
    str += "</div>"
  end

  def descreve_comentario(obj, user, topico_comentado, target, options)
    Rails.cache.fetch(["descreve_comentario", obj.id, user.id, topico_comentado.id, target, options]) do
      str  = "<a href='#{topico_url(:topico_slug => topico_comentado.to_param, :anchor => obj.id)}' title='Leia a discussão completa...'><i class='icon-comment'></i></a>"
      str += "<div class='detalhes'><p class=\"descricao\"><b>Comentou</b>, sobre "
      str += descreve_comentario_qualquer(obj, user, topico_comentado, target, options)
      str += "</div>"
    end
  end

  def descreve_pergunta(obj, user, topico_comentado, target, options)
    str = "<a href='#{topico_url(:topico_slug => topico_comentado.to_param, :anchor => obj.id)}' title='Leia a discussão completa...'><i class='icon-ask'></i></a>"
    str += "<div class='detalhes'><p class=\"descricao\"><b>Perguntou</b>, sobre "
    str += descreve_comentario_qualquer(obj, user, topico_comentado, target, options)
    str += "</div>"
  end

  def descreve_resposta(obj, user, topico_comentado, target, options)
    str = "<a href='#{topico_url(:topico_slug => topico_comentado.to_param, :anchor => obj.id)}' title='Leia a discussão completa...'><i class='icon-check'></i></a>"
    str += "<div class='detalhes'><p class=\"descricao\"><b>Respondeu</b>, sobre "
    str += descreve_comentario_qualquer(obj, user, topico_comentado, target, options)
    str += "</div>"
  end

  def descreve_ideia(obj, user, topico_comentado, target, options)
    str = "<a href='#{topico_url(:topico_slug => topico_comentado.to_param, :anchor => obj.id)}' title='Leia a discussão completa...'><i class='icon-idea'></i></a>"
    str += "<div class='detalhes'><p class=\"descricao\">Deu uma <b>ideia</b> para "
    str += descreve_comentario_qualquer(obj, user, topico_comentado, target, options)
    str += "</div>"
  end

  def descreve_comentario_qualquer(obj, user, topico_comentado, target, options)
    str  = ""
    str += descreve_tipo_do_topico_e_seu_autor(topico_comentado, target)
    str += ":</p>"
    if options[:truncate_comentario]
      str += "<div class=\"o_comentario\">#{simple_format(truncate(obj.body, :length => options[:truncate_comentario]))}</div>"
    else
      str += "<div class=\"o_comentario\">#{simple_format(obj.body)}</div>"
    end
  end

  def descreve_adesao(obj, user, target)
    str = "<i class='icon-thumbs-up'></i>"
    str += "<div class='detalhes'>"
    str += "<p class=\"descricao\"><b>Apoiou</b> "
    str += descreve_tipo_do_topico_e_seu_autor(obj.topico, target)
    str += "</p>"
    str += "</div>"
  end

  def descreve_seguido(obj, user, target)
    str = "<i class='icon-print-shoes'></i>"
    str += "<div class='detalhes'>"
    str += "<p class=\"descricao\"><b>Seguindo</b> "
    str += descreve_tipo_do_topico_e_seu_autor(obj.topico, target)
    str += "</p>"
    str += "</div>"
  end

  def descreve_tipo_do_topico_e_seu_autor(topico, target)
    str  = "<span class=\"#{topico.display_name.downcase}\">#{topico.nome_do_tipo(:artigo => :definido)}</span> "
    str += "&#8220;#{link_to(topico.titulo, topico_url(:topico_slug => topico.to_param), :target => target)}"
    str += "&#8221; "
    str += "de "
    str += "#{link_to(topico.user.nome, perfil_url(:id => topico.user.id), :target => target ) }"
  end

  def atividades_count(collection, type)
    ret = []
    total = collection.length
    if total > 0
      ret << "Listando"
      if collection.respond_to? :total_entries
        total = collection.total_entries
        ret << "<span class=\"number\">#{collection.offset + 1} - #{collection.offset + collection.length}</span> de"
      end
      ret << "<span class=\"number\">#{total}</span>"
      ret << t("activerecord.attributes.user.atividades.#{type}", :count => total)
    else
      ret << "Nenhuma atividade encontrada"
    end
    ret.join(" ").html_safe
  end

end
