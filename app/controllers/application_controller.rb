# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery

  # Mantém o desenvolvimento seguro e livre de indexadores.
  before_filter :get_settings
  before_filter :complete_user_registration?
  before_filter :set_default_meta_tags

  include AutoComplete
  helper AutoCompleteMacrosHelper

  def obter_localizacao
    @pais = Pais.find(1)

    if !params[:estado_abrev].blank?
      if Estado.exists?(:abrev => params[:estado_abrev])
        @estado = Estado.find_by_abrev(params[:estado_abrev])
        if !params[:cidade_slug].blank?
          if @estado.cidades.exists?(:slug => params[:cidade_slug])
            @cidade = @estado.cidades.find_by_slug(params[:cidade_slug])
            if !params[:bairro_id].blank?
              if @cidade.bairros.exists?(params[:bairro_id])
                @bairro = @cidade.bairros.find_by_id(params[:bairro_id])
              else
                render :file => "#{Rails.root.to_s}/public/404.html", :layout => false, :status => 404 and return
              end
            end
          else
            render :file => "#{Rails.root.to_s}/public/404.html", :layout => false, :status => 404 and return
          end
        end
      else
        render :file => "#{Rails.root.to_s}/public/404.html", :layout => false, :status => 404 and return
      end
    end
  end

  def set_admin_locale
    I18n.locale = :"pt-BR"
  end

  protected

  helper_method :ambiente_producao?

  def ambiente_producao?
    (Rails.env == 'production')
  end

  def get_settings
    @settings = Settings.all
  end

  def set_default_meta_tags
    set_meta_tags DefaultMetaTags.for(request)
  end

  def complete_user_registration?
    unless controller_name =~ /sessions/
      if user_signed_in? && current_user.pending?
        redirect_to completar_cadastro_path
      end
    end
  end

  # Devise extensions

  def admin_signed_in?
    signed_in? && current_user.admin?
  end

  def authenticate_admin!
    unless admin_signed_in?
      flash[:error] = "Você precisa ser administrador para acessar esta seção."
      redirect_to new_user_session_url
    end
  end
end
