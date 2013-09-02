class Devise::Custom::SessionsController < Devise::SessionsController
  def create
    super # call original create action from Devise
    current_user.historico_de_logins.create(:ip => request.remote_ip) if current_user
  end
end

