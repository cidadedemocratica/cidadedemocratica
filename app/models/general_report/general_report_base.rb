class GeneralReportBase
  def initialize
    @store = Hash.new { |hash, key|
      hash[key] = Hash.new { |hash, key|
        hash[key] = case key
          when "users" then []
          when "model" then nil
          else 0
        end
      }
    }
  end

  def topic_model(model)
    if model.respond_to? :topico
      model.topico
    else
      model
    end
  end

  def users_stats(users)
    { "total" => users.size }.merge(Hash[
      users.group_by(&:nome_do_tipo).map{ |type, data| [type, data.size] }.sort
    ])
  end
end
