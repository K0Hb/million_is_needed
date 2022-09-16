require 'rails_helper'

RSpec.describe GameQuestion, type: :model do
  let(:game_question) do
    create(:game_question, a: 2, b: 1, c: 4, d: 3)
  end

  describe '#variants' do
      it 'return eq hash' do
        expect(game_question.variants).to eq(
          'a' => game_question.question.answer2,
          'b' => game_question.question.answer1,
          'c' => game_question.question.answer4,
          'd' => game_question.question.answer3
        )
      end
    end

  describe '#answer_correct?' do
    it 'return true' do
      expect(game_question.answer_correct?('b')).to be true
    end
  end

  describe '#correct_answer_key' do
    it 'return correct key' do
      expect(game_question.correct_answer_key).to eq 'b'
    end
  end

  describe "#level" do
    it "return correct question level" do
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  describe "#text" do
    it "return correct text" do
      expect(game_question.text).to eq(game_question.question.text)
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

    context '#add_friend_call' do
      it 'help_hash has key :friend_call and help include text in locale' do
        expect(game_question.help_hash).not_to include(:friend_call)

        game_question.add_friend_call
        expect(game_question.help_hash).to include(:friend_call)

        fc = game_question.help_hash[:friend_call]
        expect(fc).to include('вариант')
      end
    end
  end
end
