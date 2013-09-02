require 'spec_helper'

describe Tag do
  let!(:proposta) { FactoryGirl.create(:proposta) }
  let!(:proposta2) { FactoryGirl.create(:proposta) }

  describe "remove duplicate" do
    before do
      tag_id = Tag.find_by_name("tag1").id
      # create a duplication
      ActsAsTaggableOn::Tagging.update_all({ :tag_id => tag_id }, { :taggable_id => proposta.id })

      Tag.remove_duplicate(tag_id)
      proposta.reload
      proposta2.reload
    end

    it { proposta.tags.size == 1 }
    it { proposta.tag_list == "tag1" }

    it { proposta2.tags.size == 2 }
    it { proposta2.tag_list == "tag1, tag2" }
  end

  describe "join tags" do
    before do
      to_tag_id = Tag.find_by_name("tag1").id
      from_tag_id = Tag.find_by_name("tag2").id

      Tag.join_tags(to_tag_id, from_tag_id)
      proposta.reload
      proposta2.reload
    end

    it { proposta.tags.size == 1 }
    it { proposta2.tags.size == 1 }
    it { proposta.tag_list == "tag1" }
    it { proposta2.tag_list == "tag1" }
  end
end

