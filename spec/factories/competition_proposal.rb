FactoryGirl.define do
  factory :competition_proposal, :parent => :proposta, :class => Proposta do
    competition
  end

  factory :competition_proposal_with_imagens_and_links, :parent => :proposta_with_imagens_and_links do
    competition
  end
end
