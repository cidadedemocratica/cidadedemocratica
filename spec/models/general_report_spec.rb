require 'spec_helper'

describe GeneralReport do
  let(:today) { Date.today }
  let(:ten_days_ago) { 10.days.ago }

  describe 'dates' do
    context 'initializes without specify dates' do
      it { subject.to.should eq today }
      it { subject.from.should eq Date.today.beginning_of_month }
    end

    context 'intializes with specific dates' do
      subject { GeneralReport.new(:from => ten_days_ago, :to => today)  }

      it { subject.to.should eq today }
      it { subject.from.should eq ten_days_ago }
    end
  end

  %w(state_ids city_ids).each do |attribute|
    it "ignores blank #{attribute}" do
      general_report = GeneralReport.new(attribute => ["","", "1"])

      general_report.send(attribute).should eq [1]
    end
  end

  it "ignores blank tags" do
    general_report = GeneralReport.new(:tags => ["","", "1"])

    general_report.tags.should eq ["1"]
  end
end
