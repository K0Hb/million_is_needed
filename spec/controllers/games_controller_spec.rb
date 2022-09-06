require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryGirl.create(:game_with_questions, user: user) }

  describe '#create' do
    before(:each) { sign_in user }

    context 'creates game' do
      it 'shows flash notice and redirect to new game' do
        generate_questions(15)

        post :create
        game = assigns(:game)

        expect(game.finished?).to be_falsey
        expect(game.user).to eq(user)
        expect(response).to redirect_to(game_path(game))
        expect(flash[:notice]).to be
      end
    end


    context 'attempt to create second game' do
      it 'shows flash alert and redirect to actual game' do
        expect(game_w_questions.finished?).to be_falsey

        expect { post :create }.to change(Game, :count).by(0)
        game = assigns(:game)

        expect(game).to be_nil
        expect(response).to redirect_to(game_path(game_w_questions))
        expect(flash[:alert]).to be
      end
    end
  end

  describe '#answer' do
    before(:each) { sign_in user }
    let(:question) { game_w_questions.current_game_question }

    context 'answer correct'
      it 'dont shows flash alert and game continues' do
        put :answer, id: game_w_questions.id, letter: question.correct_answer_key
        game = assigns(:game)

        expect(game.finished?).to be_falsey
        expect(game.current_level).to be > 0
        expect(response).to redirect_to(game_path(game))
        expect(flash.empty?).to be_truthy
      end

    context 'answer wrong' do
      it 'shows flash alert and finished game' do
        wrong_answer = (question.variants.keys - [question.correct_answer_key]).sample

        put :answer, id: game_w_questions.id, letter: wrong_answer
        game = assigns(:game)

        expect(game.finished?).to be true
        expect(response).to redirect_to user_path(user)
        expect(flash[:alert]).to be
      end
    end
  end

  describe '#show game (sign_in user)' do
    before(:each) { sign_in user }

    context 'user show self game' do
      it 'render your game and game continues' do
        get :show, id: game_w_questions.id
        game = assigns(:game)

        expect(response.status).to eq(200)
        expect(response).to render_template('show')
        expect(game.finished?).to be_falsey
        expect(game.user).to eq(user)
        expect(game.status).to eq(:in_progress)
      end
    end

    context 'user show alien game' do
      it 'shows flash alert and redirect root_path' do
        alien_game = FactoryGirl.create(:game_with_questions)
        get :show, id: alien_game.id

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be
      end
    end
  end

  describe '#take_money' do
    before(:each) { sign_in user }

    context 'takes money' do
      it 'shows flash warning, balacne user equal prize and redirect user page' do
        game_w_questions.update_attribute(:current_level, 2)
        put :take_money, id: game_w_questions.id
        game = assigns(:game)

        expect(game.finished?).to be_truthy
        expect(game.prize).to eq(200)

        user.reload
        expect(user.balance).to eq(200)
        expect(response).to redirect_to(user_path(user))
        expect(flash[:warning]).to be
      end
    end
  end

  describe 'group test anonymous user' do
    context '#show game' do
      it 'shows flash aler and redirect log in page' do
        get :show, id: game_w_questions.id

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context '#create' do
      it 'shows flash alert, redirect log in page and game dont create' do
        expect { post :create }.to change(Game, :count).by(0)

        game = assigns(:game)

        expect(game).to be nil
        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context '#answer' do
      it 'shows flash alert and redirect log in page' do
        put :answer, id: game_w_questions.id

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context '#take_money' do
      it 'shows flash alert and redirect log in page' do
        put :take_money, id: game_w_questions.id

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end
  end
end
