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
        expect(game_question.answer_correct?('b')).to be_truthy
      end

      it 'return false' do
        expect(game_question.answer_correct?('c')).to be_falsey
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
end
