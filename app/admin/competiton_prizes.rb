ActiveAdmin.register CompetitionPrize do
  belongs_to :competition

  form :partial => 'form'

  index do
    selectable_column

    column :id
    column :name
    column :offerer do |competition|
      competition.offerer.nome
    end
    column :winning_topic do |competition|
      competition.winning_topic.titulo if competition.winning_topic
    end

    default_actions
  end

  action_item :only => :show do
    link_to 'Prêmios', admin_new_competition_competition_prizes_path(competition)
  end

  show do |competition_prize|
    attributes_table do
      row :name
      row :offerer do
        link_to competition_prize.offerer.nome, admin_new_user_path(competition_prize.offerer)
      end
      row :description
      row :winning_topic do
        if competition_prize.winning_topic.present?
          link_to competition_prize.winning_topic.titulo, admin_new_topico_path(competition_prize.winning_topic)
        end
      end
    end

    active_admin_comments
  end

  filter :name
  filter :created_at
end
