require_relative '../../lib/associative_matrix'

describe AssociativeMatrix do
  let(:members_one) { %w(member1 member2) }
  let(:members_two) { %w(member1 member2 member3 member4) }
  let(:matrix) { AssociativeMatrix.new(members_one, members_two) }

  describe '#members' do
    it 'returns unique members' do
      matrix.members.should eq (members_one | members_two)
    end
  end

  describe '#associations' do
    it 'returns a hash with members associations' do
      associations = {
        'member1' => [['member2', 2], ['member3', 1], ['member4', 1]],
        'member2' => [['member1', 2], ['member3', 1], ['member4', 1]],
        'member3' => [['member1', 1], ['member2', 1], ['member4', 1]],
        'member4' => [['member1', 1], ['member2', 1], ['member3', 1]]
      }

      matrix.associations.should eq associations
    end
  end

  describe '.generate' do
    it 'generates an associative matrix' do
      csv     = <<-STRING
X,member1,member2,member3,member4
member1,0,2,1,1
member2,2,0,1,1
member3,1,1,0,1
member4,1,1,1,0
      STRING

      matrix.to_csv.should eq csv
    end
  end
end
