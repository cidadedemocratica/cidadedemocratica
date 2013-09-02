require 'spec_helper'

describe User do
  let!(:user) { FactoryGirl.create(:cidadao) }

  describe "#from_email" do
    it "creates a new user" do
      user = User.from_email("from_email@mail.com")
      user.should be_a(User)
      user.persisted?.should be_false
      user.password.should_not be_blank
      user.email.should == "from_email@mail.com"
    end

    it "returns a persisted user" do
      finded_user = User.from_email(user.email)
      finded_user.should be_a(User)
      finded_user.persisted?.should be_true
    end
  end

  describe "#find_by_auth" do
    it "returns a user" do
      OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
        provider: 'facebook',
        uid:      '1',
        info:     { nickname: "jcemer", email: "jean.emer@codeminer42.com" }
      })

      user.add_auth_provider(OmniAuth.config.mock_auth[:facebook])

      finded_user = User.find_by_auth(OmniAuth.config.mock_auth[:facebook])
      finded_user.should.should == user
    end
  end

  describe "#add_auth_provider" do
    it "includes a provider" do
      OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
        provider: 'facebook',
        uid:      '1123',
        info:     { nickname: "jcemer", email: "jean.emer@codeminer42.com" }
      })

      user.add_auth_provider(OmniAuth.config.mock_auth[:facebook])

      user.authorizations.first.provider.should == 'facebook'
      user.authorizations.first.uid.should == '1123'
    end
  end

  describe '.update_counters' do
    before do
      Settings.user_relevancia_peso_topicos = 1
      Settings.user_relevancia_peso_inspiracoes = 1
      Settings.user_relevancia_peso_comentarios = 1
      Settings.user_relevancia_peso_apoios = 1
    end

    it 'calculates relevancia' do
      counters = {
        "topicos_count" => 1,
        "inspirations_count" => 1,
        "comments_count" => 1,
        "adesoes_count" => 1
      }

      User.update_counters(user.id, counters)
      user.reload

      user.relevancia.should eq 400
    end
  end
end
