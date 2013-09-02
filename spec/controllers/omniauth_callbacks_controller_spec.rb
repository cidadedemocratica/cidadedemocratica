require 'spec_helper'

describe OmniauthCallbacksController do
  let!(:user) { FactoryGirl.create(:cidadao) }

  context "Facebook" do
    describe "do not login unregistered authorization" do
      before do
        OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
          provider: "facebook",
          uid:      "987654321",
          info:     { nickname: "jcemer" }
        })

        request.env["devise.mapping"] = Devise.mappings[:user]
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]

        get :facebook
      end

      it { should_not be_user_signed_in }
      it { response.should redirect_to(new_user_registration_path) }
      it { should set_the_flash[:error].to(/Esta conta não foi associada/) }
    end

    describe "login" do
      before do
        OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
          provider: "facebook",
          uid:      "987654321",
          info:     { nickname: "jcemer", email: user.email }
        })

        user.authorizations.build :provider => "facebook", :uid => "987654321"
        user.save!

        request.env["devise.mapping"] = Devise.mappings[:user]
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]

        get :facebook
        user.reload
      end

      it { should be_user_signed_in }
      it { subject.current_user.should == user }
      it { subject.current_user.authorizations.size.should == 1  }
      it { response.should redirect_to(root_path) }
      it { should set_the_flash[:notice].to('Autenticado com sucesso com uma conta de facebook.') }
    end

    describe "adds a provider to a logged user" do
      before do
        OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
          provider: "facebook",
          uid:      "987654321",
          info:     { nickname: "jcemer", email: user.email }
        })

        request.env["devise.mapping"] = Devise.mappings[:user]
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]

        sign_in user
        get :facebook
        user.reload
      end

      it { response.should redirect_to(root_path) }
      it { user.authorizations.size.should == 1  }
      it { subject.current_user.authorizations.first.provider.should == "facebook" }
      it { subject.current_user.authorizations.first.uid.should == "987654321" }
      it { should set_the_flash[:notice].to('Agora você pode entrar com uma conta de facebook.') }
    end

    describe "this provider already have been added" do
      before do
        OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
          provider: "facebook",
          uid:      "987654321",
          info:     { nickname: "jcemer", email: user.email }
        })

        request.env["devise.mapping"] = Devise.mappings[:user]
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]

        user.add_auth_provider(OmniAuth.config.mock_auth[:facebook])

        sign_in user
        get :facebook
        user.reload
      end

      it { response.should redirect_to(root_path) }
      it { user.authorizations.size.should == 1 }
      it { should set_the_flash[:warning].to(/já está associada/) }
    end

    describe "this provider already have been added by another user" do
      let!(:another_user) { FactoryGirl.create(:cidadao) }

      before do
        OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
          provider: "facebook",
          uid:      "987654321",
          info:     { nickname: "jcemer", email: user.email }
        })

        request.env["devise.mapping"] = Devise.mappings[:user]
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]

        another_user.add_auth_provider(OmniAuth.config.mock_auth[:facebook])

        sign_in user
        get :facebook
        user.reload
      end

      it { response.should redirect_to(root_path) }
      it { user.authorizations.size.should == 0 }
      it { should set_the_flash[:error].to(/outro usuário/) }
    end
  end
end
