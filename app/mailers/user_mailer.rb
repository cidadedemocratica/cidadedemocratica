class UserMailer < Mailer
  helper :mailer

  def solicitar_vinculacao(organizacao_id, user_id)
    @organizacao = User.find(organizacao_id)
    @user        = User.find(user_id)

    options = default_options(:user => @organizacao)
    options.merge!(
      :subject => "#{options[:subject]}#{@user.nome} quer fazer parte de #{@organizacao.nome}"
    )
    mail(options) { |format| format.text }
  end

  def observatorio(user_id, desde=7.days.ago)
    user = User.find(user_id)
    @desde = desde
    @atividades = user.observatorios.first.atividades(desde)

    options = default_options(:user => user)
    options.merge!(
      :subject => "#{options[:subject]}Resumo do observatório"
    )
    mail(options) { |format| format.text }
  end

  def contato(usuario_destinatario_id, contato_params)
    usuario_destinatario = User.find(usuario_destinatario_id)
    contato_params.symbolize_keys!
    @contato = Contato.new
    @contato.nome = contato_params[:nome]
    @contato.email = contato_params[:email]
    @contato.mensagem = contato_params[:mensagem]
    options = default_options(:user => usuario_destinatario)
    options.merge!(
      :subject  => "#{options[:subject]}Nova mensagem de #{@contato.nome.nome_proprio}",
      :reply_to => "#{@contato.nome.nome_proprio} <#{@contato.email}>"
    )
    mail(options) { |format| format.text }
  end
end
