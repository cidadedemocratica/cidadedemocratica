class Mailer < ActionMailer::Base
  include Resque::Mailer
  helper :application
  ADMIN_NAME_AND_EMAIL  = "Administrador do Cidade Democrática <ryband@uol.com.br>"

  protected

  def default_options(params = {})
    options = {
      :from    => params[:from] || "Cidade Democrática <noreply@cidadedemocratica.org.br>",
      :subject => "[Cidade Democrática] " #inicio padrao dos emails
    }
    if params[:admin]
      params[:recipients] = Settings['emails_administrador'].blank? ? ADMIN_NAME_AND_EMAIL : Settings['emails_administrador']
    end
    if params[:topico]
      @topico = params[:topico]
      params[:recipients] = "#{filter_name @topico.user.nome} <#{@topico.user.email}>"
    end
    if params[:user]
      @user = params[:user]
      params[:recipients] = @user.email
      params[:recipients] = "#{filter_name @user.nome} <#{@user.email}>" if @user && @user.nome
    end
    params[:recipients] = params[:recipients].join(", ") if params[:recipients] === Array
    options.merge!(:to => params[:recipients]) if params[:recipients]
    options
  end

  def filter_name(name)
    name.blank? ? name : name.gsub(/\W+/, ' ')
  end

end
