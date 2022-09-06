require 'rails_helper'

RSpec.describe GameQuestion, type: :model do
  let(:game_question) do
    FactoryGirl.create(:game_question, a: 2, b: 1, c: 4, d: 3)
  end

  describe '#variants' do
    context 'check return correct hash' do
        it 'return eq hash' do
          expect(game_question.variants).to eq(
            'a' => game_question.question.answer2,
            'b' => game_question.question.answer1,
            'c' => game_question.question.answer4,
            'd' => game_question.question.answer3
          )
        end
      end
    end

  describe '#answer_correct?' do
    context 'check correct work answer_correct?' do
      it 'return true' do
        expect(game_question.answer_correct?('b')).to be true
      end

      it 'return false' do
        expect(game_question.answer_correct?('c')).to be false
      end
    end
  end

  describe "#level" do
    context 'check correct work level' do
      it "level correctly" do
        expect(game_question.level).to eq(game_question.question.level)
      end

      it "level not correctly" do
        expect(game_question.level).not_to  eq(game_question.question.level - 1)
      end
    end
  end

  describe "#text" do
    context 'check correct work text' do
      it "text correctly" do
        expect(game_question.text).to eq(game_question.question.text)
      end
    end
  end

  describe '#help_hash' do
    context '#add_audience_help' do
      it 'audience_help has correct keys' do
        expect(game_question.help_hash).not_to include(:audience_help)

        game_question.add_audience_help

        expect(game_question.help_hash).to include(:audience_help)

        ah = game_question.help_hash[:audience_help]
        expect(ah.keys).to contain_exactly('a', 'b', 'c', 'd')
      end
    end

    context '#add_fifty_fifty' do
      it 'there are 2 answers left and one of them is correct' do
        expect(game_question.help_hash).not_to include(:fifty_fifty)

        game_question.add_fifty_fifty

        expect(game_question.help_hash).to include(:fifty_fifty)
        ff = game_question.help_hash[:fifty_fifty]

        expect(ff).to include('b')
        expect(ff.size).to eq 2
      end
    end
  end
end
