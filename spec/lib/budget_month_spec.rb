require 'spec_helper'

RSpec.describe BudgetMonth do
  let(:today) { Date.new(2099, 3, 14) }
  let(:first_of_march) { Date.new(2099, 3, 1) }
  let(:first_of_april) { first_of_march.next_month }

  before { Timecop.travel(today) }

  describe 'the various ways a budget month can be instantiated' do
    context 'default' do
      subject { BudgetMonth.new.month }
      it { should eq first_of_march }
    end

    context 'it accepts a date as a named argument' do
      subject { BudgetMonth.new(args).month }
      let(:args) { { date: first_of_april } }
      it { should eq first_of_april }
    end

    context 'a stringified date is given' do
      subject { BudgetMonth.new(args).month }
      let(:args) { { date: first_of_april.to_s } }
      it { should eq first_of_april }
    end

    context 'it accepts a year/month hash' do
      context 'both year/month provided' do
        subject { BudgetMonth.new(args).month }
        let(:args) { { year: '2099', month: '3' } }
        it { should eq first_of_march }
      end

      context 'current year is assumed is only month provided' do
        subject { BudgetMonth.new(args).month }
        let(:args) { { month: '3' } }
        it { should eq first_of_march }
      end
    end
  end

  describe 'public instance methods' do
    let(:last_of_march) { Date.new(2099, 3, 31) }
    before { Timecop.travel(last_of_march) }
    subject { BudgetMonth.new }
    describe '#first_day' do
      it { expect(subject.first_day).to eq first_of_march }
    end
    describe '#last_day' do
      it { expect(subject.last_day).to eq last_of_march }
    end
    describe '#days_remaining' do
      it { expect(subject.days_remaining).to be 1 }
    end
    describe '#print_month' do
      it { expect(subject.print_month).to eq 'March' }
    end
    describe '#current?' do
      it { should be_current }
    end
    describe 'date range' do
      let(:expected_range) { (subject.first_day..subject.last_day) }
      it { expect(subject.date_range).to eq expected_range }
    end
  end
end
