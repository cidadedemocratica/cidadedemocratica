module TopicosHelper

  # Infos de cada topico
  def topico(topico, options = {})
    my_options = {
      :titulo_max_chars => 100,
      :mostrar_local => false,
      :mostrar_atividades => true,
      :show_supports => true
    }
    options = my_options.merge!(options)
    render :partial => "topicos/topico",
           :locals => {
             :topico => topico,
             :options => options
           }
  end

  # Lista de Topicos
  def topicos(topicos, options = {})
    my_options = {
      :link_in_tags => true,
      :paginate => false,
      :show_supports => true
    }
    options = my_options.merge!(options)
    render :partial => "topicos/topicos",
           :locals => {
             :topicos => topicos,
             :options => options
           }
  end

  def comentario(comentario, options = {})
    render :partial => "comments/comentario",
           :locals => { :comentario => comentario }
  end

  def comentarios(comentarios, options = {})
    render :partial => "comments/comentarios",
           :locals => { :comentarios => comentarios }
  end

  def comentarios_estatisticas(comentarios, topico, options = {})
    render :partial => "comments/comentarios_estatisticas",
           :locals => {
             :comentarios => comentarios,
             :topico => topico
           }
  end

  def comentarios_estatisticas_media_por_tempo(from, total, options={})
    from_time = from.to_time
    to_time = Time.now.to_time
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    media = (distance_in_minutes/total).round
    case media
      when 0..1             then
        outra_media = total
        outra_media = (total/distance_in_minutes).round if (distance_in_minutes != 0)
        return "#{pluralize(outra_media,'comentário')} por minuto"
      when 2..59            then return "1 comentário a cada hora"
      when 60..1439         then return "mais de 1 comentário por dia"
      when 1440..4319       then return "1 comentário a cada 3 dias"
      when 4320..8639       then return "mais de 1 comentário por semana"
      when 8640..10079      then return "1 comentário por semana"
      when 10080..41759     then return "mais de 1 comentário por mês"
      when 41760..43199     then return "1 comentário por mês"
      when 43200..126000    then return "cerca de 1 comentário a cada 3 meses"
      when 86400..525599    then return "1 comentário por ano"
      else                       return "menos de 1 comentário por ano"
    end
  end

  def show_coauthor?
    @joining and @joining.topico_to == @topico and @topico.user !=  @joining.coauthor
  end

  def outer_topico_joined
    if @joining.topicos_from[0] == @topico
      @joining.topicos_from[1]
    else
      @joining.topicos_from[0]
    end
  end

  def joining_topico_to?
    @joining and @joining.topico_to == @topico
  end
end
