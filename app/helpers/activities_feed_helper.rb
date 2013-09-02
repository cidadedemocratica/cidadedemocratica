module ActivitiesFeedHelper

  def activity_feed(item)
    user_link = link_to(item.user.nome, perfil_path(item.user))

    if item.is_a? Inspiration
      content = about_competition(item, user_link)
    else
      content = about_topics(item, user_link)
    end

    # time elapsed
    content += content_tag(:span, :class => "time") do
      "há " + distance_of_time_in_words_to_now(item.created_at)
    end

    content_tag(:li, content.html_safe, "data-time" => item.created_at.to_i)
  end

  private

  def to_label(label)
    content_tag(:span, "#{label}:", :class => "label")
  end

  def about_competition(item, user_link)
    link = link_to(item.title, competition_path(item.competition,
        :phase => 'inspiration_phase',
        :anchor => 'inspiration_' + item.id.to_s
      ),
    )
    "#{to_label("Inspiração")} #{user_link} deixou a inspiração #{link}."
  end

  def about_topics(item, user_link)
    description = case item
      when Proposta, Problema
        label = "#{item.type}"
        topic = item
        "criou "
      when Adesao
        label = "Apoio"
        topic = item.topico
        "apoiou "
      when Seguido
        label = "Seguiu"
        topic = item.topico
        "seguiu "
      when Comment
        label = "Comentário"
        topic = item.topico
        "comentou n"
    end
    description += topic.nome_do_tipo(:artigo => :definido)
    topic_link = link_to topic.titulo, topico_path(topic)
    "#{to_label(label)} #{user_link} #{description} #{topic_link}"
  end
end
