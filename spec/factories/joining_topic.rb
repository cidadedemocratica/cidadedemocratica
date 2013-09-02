FactoryGirl.define do
  factory :joining_topic do
    user  { FactoryGirl.create(:user) }
    current_phase :propose_phase
    topicos_from { [FactoryGirl.create(:competition_proposal), FactoryGirl.create(:competition_proposal)] }

    factory :joining_topic_with_author do
      current_phase :author_phase
      author { topicos_from[0].user }

      factory :joining_topic_pending do
        title { Forgery(:basic).text }
        description { Forgery(:basic).text }
        current_phase :pending_phase
      end

      factory :joining_topic_aproved do
        current_phase :aproved_phase
        title { Forgery(:basic).text }
        description { Forgery(:basic).text }
        topico_to { FactoryGirl.create(:competition_proposal, :user => author) }
      end
    end
  end
end
