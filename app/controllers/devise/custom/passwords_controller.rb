class Devise::Custom::PasswordsController < Devise::PasswordsController
  skip_before_filter :require_no_authentication, :if => proc { |c| c.signed_in? && c.current_user.admin? }
end

