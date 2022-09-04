require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) { FactoryGirl.create(:user) }

  let(:game_w_questions) do
    FactoryGirl.create(:game_with_questions, user: user)
  end

  context 'Game Factory' do
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

  context 'game mechanics' do
    it 'answer correct continues game' do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)
      expect(game_w_questions.current_game_question).not_to eq(q)
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    it 'take_money! finishes the game' do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)

      game_w_questions.take_money!

      prize = game_w_questions.prize
      expect(prize).to be > 0
      expect(game_w_questions.status).to eq :money
      expect(game_w_questions.finished?).to be_truthy
      expect(user.balance).to eq prize
    end
  end

  describe '#status' do
    context 'check status if game finished now' do
      before(:each) do
        game_w_questions.finished_at = Time.now
        expect(game_w_questions.finished?).to be_truthy
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
      it 'previous_level not correctly' do
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
    context 'answer correct' do
      it 'answer -> true; current_level -> level(next), game_w_questions.finished? -> true' do
        answer = game_w_questions.answer_current_question!(q.correct_answer_key)

        expect(answer).to be_truthy
        expect(game_w_questions.current_level).to eq(1)
        expect(game_w_questions.finished?).to be_falsey
      end
    end

    context 'answer uncorrect' do
      it 'answer -> false; current_level -> level, game_w_questions.finished? -> true' do
        answer = game_w_questions.answer_current_question!('g')

        expect(answer).to be_falsey
        expect(game_w_questions.current_level).to eq(level)
        expect(game_w_questions.finished?).to be_truthy
      end
    end

    context 'answer timeout' do
      it 'answer -> false; current_level -> level, game_w_questions.finished? -> true' do
        game_w_questions.created_at = 1.hour.ago
        answer = game_w_questions.answer_current_question!(q.correct_answer_key)

        expect(answer).to be_falsey
        expect(game_w_questions.current_level).to eq(level)
        expect(game_w_questions.finished?).to be_truthy
      end
    end

    context 'final answer and prize = 1 million' do
      it 'answer -> true; prize -> million; status -> :won; finished? -> true; balance -> million; current_level-> 14(max)' do
        game_w_questions.current_level = Question::QUESTION_LEVELS.max
        answer = game_w_questions.answer_current_question!(q.correct_answer_key)
        prize = game_w_questions.prize

        expect(answer).to be_truthy
        expect(game_w_questions.current_level).to eq(15)
        expect(game_w_questions.finished?).to be_truthy
        expect(prize).to eq Game::PRIZES[Question::QUESTION_LEVELS.max]
        expect(user.balance).to eq prize
        expect(game_w_questions.status).to eq :won
      end
    end
  end
end
