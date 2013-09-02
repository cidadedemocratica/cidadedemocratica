class JoiningTopicMailer < Mailer
  helper :mailer

  def created(id)
    @joining_topic = JoiningTopic.find(id)
    options = default_options(:admin => true)
    options.merge!(
      :subject  => "[Cidade Democrática] Uma nova sugestão de união foi deixada!"
    )
    mail(options) { |format| format.text }
  end

  def attributed_author(id)
    @joining_topic = JoiningTopic.find(id)
    unless @joining_topic.expired?
      @date = @joining_topic.expiration_date
    end    
    mail_to_author :subject  => "[Cidade Democrática] Sua proposta foi escolhida para ser unificada"
  end

  def pending_phase(id)
    @joining_topic = JoiningTopic.find(id)
    unless @joining_topic.expired?
      @date = @joining_topic.expiration_date
    end
    mail_to_coauthor :subject  => "[Cidade Democrática] Sua proposta foi escolhida para ser unificada"
  end

  def suggest(id, suggestion)
    @joining_topic = JoiningTopic.find(id)
    @suggestion = suggestion
    unless @joining_topic.expired?
      @date = @joining_topic.expiration_date
    end
    mail_to_author :subject  => "[Cidade Democrática] O outro autor da sua união sugeriu mudanças"
  end

  def rejected(id)
    @joining_topic = JoiningTopic.find(id)
    mail_to_author :subject  => "[Cidade Democrática] A união das propostas não foi aceita"
  end

  def aproved_to_author(id)
    @joining_topic = JoiningTopic.find(id)
    mail_to_author :subject  => "[Cidade Democrática] A união das propostas foi aceita"
  end

  def aproved_to_follower(id, user_id)
    @joining_topic = JoiningTopic.find(id)
    @user = User.find(user_id)
    mail_to @user, :subject  => "[Cidade Democrática] Uma proposta que você segue foi unificada"
  end

  protected

  def mail_to(to, settings)
    options = default_options
    options[:to] = "#{filter_name to.nome} <#{to.email}>"
    mail(options.merge(settings)) { |format| format.text }
  end

  def mail_to_author(settings)
    mail_to @joining_topic.author, settings
  end

  def mail_to_coauthor(settings)
    mail_to @joining_topic.coauthor, settings
  end
end
