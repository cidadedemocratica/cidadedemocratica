class TopicoMailer < Mailer

  def new_comment(user_id, topico_id, comment_id)
    @user = User.find(user_id)
    @topico = Topico.find(topico_id)
    @comment = Comment.find(comment_id)
    options = default_options
    options.merge!(
      :to => "#{filter_name @user.nome} <#{@user.email}>",
      :subject  => "#{options[:subject]}#{@comment.user.nome} comentou #{@topico.nome_do_tipo(:artigo => :definido)}"
    )
    mail(options) { |format| format.text }
  end

  def warning_topic_enter_a_competition(topico_id, competition_id)
    @topico = Topico.find(topico_id)
    @competition = Competition.find(competition_id)

    options = default_options(:admin => true)
    options.merge!( :subject => "#{options[:subject]} #{@topico.titulo} atende aos requisitos de localização do concurso #{@competition.title}." )
    mail(options) { |format| format.text }
  end

  # Notifica dono do topico
  # que houve uma nova adesao.
  def nova_adesao(topico_id, adesao_id)
    topico = Topico.find(topico_id)
    @verbo = "apoiou"
    @adesao = Adesao.find(adesao_id)

    prepara_seguidores(topico, 'apoiou', @adesao)

    options = default_options(:topico => topico)
    options.merge!(
      :subject => "#{options[:subject]}#{@adesao.user.nome} apoiou #{topico.nome_do_tipo(:artigo => :definido)} no Cidade Democrática!"
    )
    mail(options) { |format| format.text }
  end

  # Notifica dono do topico
  # que houve uma nova adesao.
  # ATENÇÃO: ao remover um usuário da base, as adesoes sao removidas em cascata
  #          (graças ao :dependent => :destroy); o IF abaixo evita erros nesse caso.
  def remove_adesao(topico_id, adesao_id)
    topico = Topico.find(topico_id)
    @adesao = Adesao.find(adesao_id)

    if @adesao.user and topico.user
      @verbo = "deixou de apoiar"

      prepara_seguidores(topico, 'removeu a adesão', @adesao)

      options = default_options(:topico => topico)
      options.merge!(
        :subject => "#{options[:subject]}#{@adesao.user.nome} removeu o apoio de #{topico.nome_do_tipo(:artigo => :indefinido)} no Cidade Democrática!"
      )
      mail(options) { |format| format.text }
    end
  end

  def prepara_seguidores(topico, verbo, objeto)
    return unless topico.usuarios_que_seguem.size > 0
    topico.usuarios_que_seguem.each do |u|
      TopicoMailer.envia_seguidor(topico.id, verbo, objeto.id, objeto.class.to_s, u.id).deliver
    end
  end

  def envia_seguidor(topico_id, verbo, objeto_id, objeto_klass, seguidor_id)
    @topico = Topico.find(topico_id)
    @objeto = objeto_klass.constantize.find(objeto_id)
    @seguidor = User.find(seguidor_id)
    @verbo = verbo

    options = default_options(:recipients => ["#{filter_name @seguidor.nome} <#{@seguidor.email}>"])
    options.merge!(
      :subject => "#{options[:subject]}Nova atividade de #{@topico.nome_do_tipo(:artigo => :indefinido)} no Cidade Democrática!"
    )
    mail(options) { |format| format.text }
  end
end
