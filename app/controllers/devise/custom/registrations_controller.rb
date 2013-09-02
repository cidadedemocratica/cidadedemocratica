class Devise::Custom::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_no_authentication, :if => proc { |c| c.signed_in? && c.current_user.admin? }

  def after_inactive_sign_up_path_for(resource)
    waiting_for_confirmation_path(resource)
  end
end
