require 'rails_helper'

RSpec.describe GameQuestion, type: :model do
  let(:game_question) do
    FactoryGirl.create(:game_question, a: 2, b: 1, c: 4, d: 3)
  end

  describe '#variants' do
    context 'when variants equal correct hash' do
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
    context 'when answer correct' do
      it 'return true' do
        expect(game_question.answer_correct?('b')).to be true
      end
    end

    context 'when answer not correct' do
      it 'return false' do
        expect(game_question.answer_correct?('c')).to be false
      end
    end
  end

  describe '#correct_answer_key' do
    context 'when key correct' do
      it 'correct_answer_key equal "b" ' do
        expect(game_question.correct_answer_key).to eq 'b'
      end
    end

    context 'when key not correct' do
      it 'correct_answer_key dont equal "b" ' do
        expect(game_question.correct_answer_key).to_not eq 'c'
      end
    end
  end

  describe "#level" do
    context 'when correct work level' do
      it "question level equeal correct level" do
        expect(game_question.level).to eq(game_question.question.level)
      end
    end

    context 'when not correct work level' do
      it "question level not equeal correct level" do
        expect(game_question.level).not_to  eq(game_question.question.level - 1)
      end
    end
  end

  describe "#text" do
    context 'when game_question.text correct' do
      it "game_question.text equal correct text" do
        expect(game_question.text).to eq(game_question.question.text)
      end
    end

    context 'when game_question.text not correct' do
      it "game_question.text equal correct text" do
        expect(game_question.text).to_not eq('not correct text')
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
