require 'spec_helper'

describe MacroTag do
  context 'validations' do
    it { should validate_presence_of(:title) }
  end
end
