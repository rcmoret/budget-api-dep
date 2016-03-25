require 'spec_helper'

RSpec.describe BudgetMonth do
  let(:today) { Date.new(2099, 3, 14) }
  let(:first_of_march) { Date.new(2099, 3, 1) }
  let(:first_of_april) { first_of_march.next_month }
  let(:first_of_may) { first_of_march.next_month(2) }
  before { Timecop.travel(today) }
  describe 'the various ways a budget month can be instantiated' do
    context 'default' do
      subject { BudgetMonth.new.month }
      it { should eq first_of_march }
    end
    context 'it accpets a date as a named argument' do
      subject { BudgetMonth.new(args).month }
      let(:args) { { date: first_of_april } }
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
      context 'it also takes a method!' do
        subject { BudgetMonth.new(*args).month }
        let(:args) { [:next_month, { month: 4 }] }
        it { should eq first_of_may }
      end
    end
  end
  describe 'class methods' do
    subject { BudgetMonth }
    it { expect(subject.piped).to eq '03|2099' }
    it { expect(subject.piped(date: first_of_april)).to eq '04|2099' }
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
    describe '#puts_current_month' do
      it { expect(subject.puts_current_month).to eq 'March' }
    end
    describe '#current?' do
      it { should be_current }
      it { expect(BudgetMonth.new(:last_month).current?).to be false }
    end
    describe 'piped' do
      it { expect(subject.piped).to eq '03|2099' }
    end
    describe 'date range' do
      let(:expected_range) { (subject.first_day..subject.last_day) }
      it { expect(subject.date_range).to eq expected_range }
    end
  end
end
