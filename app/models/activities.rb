module Activities
  module Base
    def activities_summary(limit = 10)
      activities = [:topicos, :inspirations, :comments, :adesoes, :seguidos].map do |model|
        self.send("activities_#{model}").limit(limit)
      end.flatten

      activities.sort_by { |a| a.created_at }.reverse[0...limit]
    end

    def activities_topicos
      Topico.includes(:user => [:dado]).desc
    end

    def activities_propostas
      activities_topicos.do_tipo(:proposta)
    end

    def activities_problemas
      activities_topicos.do_tipo(:problema)
    end

    def activities_inspirations
      Inspiration.includes(:competition, :user => [:dado]).desc
    end

    def activities_comments
      Comment.by_topic.joins("INNER JOIN topicos commentable ON commentable.id = comments.commentable_id").includes(:user => [:dado]).desc
    end

    def activities_adesoes
      Adesao.joins(:topico).includes(:user => [:dado]).desc
    end

    def activities_seguidos
      Seguido.joins(:topico).includes(:user => [:dado]).desc
    end
  end

  module User
    include Base

    def activities_topicos
      super.where(:user_id => id)
    end

    def activities_inspirations
      super.where(:user_id => id)
    end

    def activities_comments
      super.where(:user_id => id)
    end

    def activities_adesoes
      super.where(:user_id => id)
    end

    def activities_seguidos
      super.where(:user_id => id)
    end
  end

  module Competition
    include Base

    def activities_topicos
      super.where(:competition_id => id)
    end

    def activities_inspirations
      super.where(:competition_id => id)
    end

    def activities_comments
      super.where("commentable.competition_id" => id)
    end

    def activities_adesoes
      super.where("topicos.competition_id" => id)
    end

    def activities_seguidos
      super.where("topicos.competition_id" => id)
    end
  end
end

class ActivitiesBase
  include Activities::Base
end
