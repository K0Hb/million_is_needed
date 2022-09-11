require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) { create(:user) }

  let(:game_w_questions) do
    create(:game_with_questions, user: user)
  end

  describe '.create_game_for_user!' do
    context 'with valid parameters' do
      it 'works correctly' do
        generate_questions(60)

        game = nil

        expect {
          game = Game.create_game_for_user!(user)
        }.to change(Game, :count).by(1).and(
          change(GameQuestion, :count).by(15).and(
            change(Question, :count).by(0)
          )
        )

        expect(game.user).to eq(user)
        expect(game.status).to eq(:in_progress)
        expect(game.game_questions.size).to eq(15)
        expect(game.game_questions.map(&:level)).to eq (0..14).to_a
      end
    end
  end

  describe 'testing game mechanics' do
    context 'when answer is correct and the game continues' do
      it 'game continues' do
        level = game_w_questions.current_level
        q = game_w_questions.current_game_question
        expect(game_w_questions.status).to eq(:in_progress)

        game_w_questions.answer_current_question!(q.correct_answer_key)

        expect(game_w_questions.current_level).to eq(level + 1)
        expect(game_w_questions.current_game_question).not_to eq(q)
        expect(game_w_questions.status).to eq(:in_progress)
        expect(game_w_questions.finished?).to be false
      end
    end

    context 'when user takes the money and the game finished' do
      it 'game finished' do
        q = game_w_questions.current_game_question
        game_w_questions.answer_current_question!(q.correct_answer_key)

        game_w_questions.take_money!

        prize = game_w_questions.prize
        expect(prize).to be > 0
        expect(game_w_questions.status).to eq :money
        expect(game_w_questions.finished?).to be true
        expect(user.balance).to eq prize
      end
    end
  end

  describe '#status' do
    context 'check status if game finished now' do
      before(:each) do
        game_w_questions.finished_at = Time.now
        expect(game_w_questions.finished?).to be true
      end

      it ':won' do
        game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
        expect(game_w_questions.status).to eq(:won)
      end

      it ':fail' do
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:fail)
      end

      it ':timeout' do
        game_w_questions.created_at = 1.hour.ago
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:timeout)
      end

      it ':money' do
        expect(game_w_questions.status).to eq(:money)
      end
    end
  end

  describe '#level' do
    it 'return actual level' do
      level = game_w_questions.current_level
      expect(game_w_questions.current_game_question.level).to eq level
    end
  end

  describe '#previous_level' do
    it 'return actual previous_level' do
      level = game_w_questions.current_level - 1
      expect(game_w_questions.previous_level).to eq level
    end
  end

  describe '#answer_current_question!' do
    let(:q) { game_w_questions.current_game_question }
    let(:level) { game_w_questions.current_level }
    let(:answer) { game_w_questions.answer_current_question!(game_w_questions.current_game_question.correct_answer_key) }

    context 'when answer is correct' do
      it 'game not stopped' do

        expect(answer).to be_truthy
        expect(game_w_questions.current_level).to eq(1)
        expect(game_w_questions.finished?).to be false
      end

      context 'when it is the last question' do
        before(:each) do
          game_w_questions.current_level = Question::QUESTION_LEVELS.max
          game_w_questions.answer_current_question!(q.correct_answer_key)
        end

        let(:prize) { game_w_questions.prize }

        it 'max level' do
          expect(game_w_questions.current_level).to eq(15)
        end

        it 'stops the game' do
          expect(game_w_questions.finished?).to be true
        end

        it 'rewards with prize' do
          expect(prize).to eq Game::PRIZES[Question::QUESTION_LEVELS.max]
          expect(user.balance).to eq prize
        end

        it 'sets correct status' do
          expect(game_w_questions.status).to eq :won
        end
      end
    end

    context 'when answer is incorrect' do
      it 'game is stopped' do
        answer = game_w_questions.answer_current_question!('g')

        expect(answer).to be_falsey
        expect(game_w_questions.current_level).to eq(level)
        expect(game_w_questions.finished?).to be true
      end

      context 'when timeout' do
        it 'game is stopped' do
          game_w_questions.created_at = 1.hour.ago

          expect(answer).to be false
          expect(game_w_questions.current_level).to eq(level)
          expect(game_w_questions.finished?).to be true
        end
      end
    end
  end

  describe '#current_game_question' do
    it 'return actual game question' do
      expect(game_w_questions.current_game_question).to eq game_w_questions.game_questions.first
    end
  end
end
