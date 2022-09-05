require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) { FactoryGirl.create(:user) }

  let(:game_w_questions) do
    FactoryGirl.create(:game_with_questions, user: user)
  end

  describe '.create_game_for_user!' do
    context 'creating a game with valid parameters' do
      it 'Game.create_game! new correct game' do
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
    context 'answer is correct and the game continues' do
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

    context 'user takes the money and the game finished' do
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
    context 'check correct work level' do
      it 'level correctly' do
        level = game_w_questions.current_level
        expect(game_w_questions.current_game_question.level).to eq level
      end

      it 'level not correctly' do
        level = game_w_questions.current_level - 1
        expect(game_w_questions.current_game_question.level).not_to eq level
      end
    end
  end

  describe '#previous_level' do
    context 'check correct work previous_level' do
      it 'previous_level correctly' do
        level = game_w_questions.current_level - 1
        expect(game_w_questions.previous_level).to eq level
      end

      it 'previous_level not correctly' do
        level = game_w_questions.current_level
        expect(game_w_questions.previous_level).not_to eq level
      end
    end
  end

  describe '#answer_current_question' do
    let(:q) { game_w_questions.current_game_question }
    let(:level) { game_w_questions.current_level }
    context 'game is not stopped, the answer is correct' do
      it 'answer correct' do
        answer = game_w_questions.answer_current_question!(q.correct_answer_key)

        expect(answer).to be_truthy
        expect(game_w_questions.current_level).to eq(1)
        expect(game_w_questions.finished?).to be false
      end
    end

    context 'game is stopped, the answer is incorrect' do
      it 'answer uncorrect' do
        answer = game_w_questions.answer_current_question!('g')

        expect(answer).to be_falsey
        expect(game_w_questions.current_level).to eq(level)
        expect(game_w_questions.finished?).to be true
      end
    end

    context 'game is stopped, the time limit for the response has been exceeded' do
      it 'answer timout' do
        game_w_questions.created_at = 1.hour.ago
        answer = game_w_questions.answer_current_question!(q.correct_answer_key)

        expect(answer).to be false
        expect(game_w_questions.current_level).to eq(level)
        expect(game_w_questions.finished?).to be true
      end
    end

    context 'last answer to the question and receiving the final prize' do
      it 'final answer and prize 1 million' do
        game_w_questions.current_level = Question::QUESTION_LEVELS.max
        answer = game_w_questions.answer_current_question!(q.correct_answer_key)
        prize = game_w_questions.prize

        expect(answer).to be true
        expect(game_w_questions.current_level).to eq(15)
        expect(game_w_questions.finished?).to be true
        expect(prize).to eq Game::PRIZES[Question::QUESTION_LEVELS.max]
        expect(user.balance).to eq prize
        expect(game_w_questions.status).to eq :won
      end
    end
  end
end
