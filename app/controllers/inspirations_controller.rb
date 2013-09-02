class InspirationsController < InheritedResources::Base
  belongs_to :competition

  respond_to :html

  actions :new, :create

  before_filter :authenticate_user!
  before_filter :assign_user

  def create
    create!(:notice => "Sua inspiração foi salva com sucesso") { competition_path(resource.competition) }
  end

  private

  def assign_user
    build_resource.user = current_user
  end
end
