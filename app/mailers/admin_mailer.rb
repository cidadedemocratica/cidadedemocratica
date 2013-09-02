class AdminMailer < Mailer

  # Notifica admin que a ENTIDADE (= ong, empresa etc.)
  # solicitou um cadastro especial
  def pedido_cadastro_entidade(solicitante)
    solicitante.symbolize_keys!
    @solicitante = solicitante
    options = default_options(:admin => true)
    options.merge!(
      :subject  => "#{options[:subject]}#{solicitante[:nome]} solicitou um cadastro de \"#{solicitante[:entidade]}\" no Cidade Democrática!",
      :reply_to => "#{filter_name solicitante[:nome]} <#{solicitante[:email]}>"
    )
    mail(options) { |format| format.text }
  end

  def denuncia_em_topico(topico_id, denuncia)
    denuncia.symbolize_keys!
    @topico = Topico.find(topico_id)
    @denuncia = denuncia
    options = default_options(:admin => true)
    options.merge!(
      :subject  => "#{options[:subject]}#{denuncia[:nome]} denunciou algo em \"#{@topico.titulo}\" no Cidade Democrática!",
      :reply_to => "#{filter_name denuncia[:nome]} <#{denuncia[:email]}>"
    )
    mail(options) { |format| format.text }
  end
end
