class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    @auth = request.env["omniauth.auth"]
    if signed_in?
      signed_user
    else
      login
    end
  end
  alias_method :facebook, :all

  protected

  def signed_user
    @user = User.find_by_auth(@auth)
    unless @user
      add_auth_provider
    else
      auth_provider_owner
    end
    redirect_to root_path
  end

  def add_auth_provider
    current_user.add_auth_provider(@auth)
    flash[:notice] = "Agora você pode entrar com uma conta de #{action_name}."
  end

  def auth_provider_owner
    if @user == current_user
      flash[:warning] = "Esta conta já está associada ao seu usuário."
    else
      flash[:error] = "A conta está associada a outro usuário. Entre em contato conosco para desassociar."
    end
  end

  def login
    @user = User.find_by_auth(@auth)
    unless @user
      flash[:error] = "Esta conta não foi associada. Você deve acessar com e-mail e senha e depois associar sua conta através do menu superior."
      return redirect_to new_user_registration_path
    end
    set_flash_message(:notice, :success, :kind => @auth.provider) if is_navigational_format?
    sign_in_and_redirect @user, :event => :authentication
  end
end
