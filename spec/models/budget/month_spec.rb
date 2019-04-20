require 'spec_helper'

RSpec.describe Budget::Interval, type: :model do
  it { should have_many(:items) }

  describe 'month validations' do
    context 'month is nil' do
      specify do
        subject = FactoryBot.build(:budget_interval, month: nil)

        expect(subject).to be_invalid
      end
    end

    context 'month is greater than 12' do
      specify do
        subject = FactoryBot.build(:budget_interval, month: 13)

        expect(subject).to be_invalid
      end
    end

    context 'month is less than 1' do
      specify do
        subject = FactoryBot.build(:budget_interval, month: 0)

        expect(subject).to be_invalid
      end
    end

    context 'month is 1-12'do
      specify do
        subject = FactoryBot.build(:budget_interval, month: (1..12).to_a.sample)

        expect(subject).to be_valid
      end
    end
  end

  describe 'year validations' do
    context 'year is nil' do
      specify do
        subject = FactoryBot.build(:budget_interval, year: nil)

        expect(subject).to be_invalid
      end
    end

    context 'year is too early' do # 1990's gtfo
      specify do
        subject = FactoryBot.build(:budget_interval, year: 1999)

        expect(subject).to be_invalid
      end
    end

    context 'year is too late' do # if we live that long
      specify do
        subject = FactoryBot.build(:budget_interval, year: 2100)

        expect(subject).to be_invalid
      end
    end

    context 'year is valid' do
      specify do
        subject = FactoryBot.build(:budget_interval, year: (2000..2099).to_a.sample)

        expect(subject).to be_valid
      end
    end

    describe '#set_up?' do
      context 'when set up completed at is populated' do
        specify do
          subject = FactoryBot.build(:budget_interval, set_up_completed_at: 1.day.ago)

          expect(subject.set_up?).to be true
        end
      end

      context 'when set up completed at is nil' do
        specify do
          subject = FactoryBot.build(:budget_interval, set_up_completed_at: nil)

          expect(subject.set_up?).to be false
        end
      end
    end

    describe '#closed_out?' do
      context 'when close out completed at is populated' do
        specify do
          subject = FactoryBot.build(:budget_interval, close_out_completed_at: 1.day.ago)

          expect(subject.closed_out?).to be true
        end
      end

      context 'when close out completed at is nil' do
        specify do
          subject = FactoryBot.build(:budget_interval, close_out_completed_at: nil)

          expect(subject.closed_out?).to be false
        end
      end
    end

    describe '.for' do
      let(:year) { (2000..2099).to_a.sample }
      let(:today) { Date.new(year, 3, 14) }
      let(:first_of_march) { Date.new(year, 3, 1) }
      let(:first_of_april) { Date.new(year, 4, 1) }

      before { Timecop.travel(today) }

      describe 'accepts a date object as a named parameter' do
        specify do
          subject = described_class.for(date: first_of_march)
          expect(subject.month).to be 3
          expect(subject.year).to be year
        end
      end

      describe 'accpets a date string as a named parameter' do
        specify do
          subject = described_class.for(date: first_of_march.to_s)
          expect(subject.month).to be 3
          expect(subject.year).to be year
        end
      end

      describe 'raising an error if invalid date' do
        specify do
          expect { described_class.for(date: 'foo bar') }.to raise_error ArgumentError
        end
      end

      describe 'passing a month as a named parameter' do
        specify do
          subject = described_class.for(month: 3)
          expect(subject.month).to be 3
          expect(subject.year).to be year
        end
      end
    end

    describe '#first_date' do
      specify do
        subject = FactoryBot.build(:budget_interval, month: 3, year: 2019)
        expect(subject.first_date).to eq Date.new(2019, 3, 1)
      end
    end

    describe '#last_date' do
      specify do
        subject = FactoryBot.build(:budget_interval, month: 3, year: 2019)
        expect(subject.last_date).to eq Date.new(2019, 3, 31)
      end
    end

    describe '#current?' do
      context 'in the past' do
        specify do
          subject = FactoryBot.build(:budget_interval, year: (Date.today.year + 1))
          expect(subject.current?).to be false
        end
      end

      context 'in the future' do
        specify do
          subject = FactoryBot.build(:budget_interval, year: (Date.today.year - 1))
          expect(subject.current?).to be false
        end
      end

      context 'in current month' do
        specify do
          today = Date.today
          subject = FactoryBot.build(:budget_interval, year: today.year, month: today.month)
          expect(subject.current?).to be true
        end
      end

    end

    describe '#days_remaining' do
      before { Timecop.travel(today) }
      let(:year) { (2000..2077).to_a.sample }
      let(:today) { Date.new(year, 3, 31) }

      context 'in current month' do
        specify do
          subject = FactoryBot.build(:budget_interval, year: year, month: today.month)
          expect(subject.days_remaining).to be 1
        end
      end

      context 'in a past month' do
        specify do
          subject = FactoryBot.build(:budget_interval, year: (year - 1), month: today.month)
          expect(subject.days_remaining).to be 31
        end
      end
    end
  end
end
