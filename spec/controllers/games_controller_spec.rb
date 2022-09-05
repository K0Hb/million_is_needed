require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryGirl.create(:game_with_questions, user: user) }

  describe '#create' do
    before(:each) { sign_in user }

    context 'creates game' do
      it 'finished -> false; user -> user; response -> redirect_to(game_path(game); flash -> true' do
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
      it 'finished -> false; game -> nil; flash -> true' do
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

    context 'answer correct'
      it 'finished? -> false; current_level > 0; response -> redirect_to(game_path(game); flash -> empty' do
        put :answer, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key
        game = assigns(:game)

        expect(game.finished?).to be_falsey
        expect(game.current_level).to be > 0
        expect(response).to redirect_to(game_path(game))
        expect(flash.empty?).to be_truthy
      end
  end

  describe '#show game (user -> user)' do
    before(:each) { sign_in user }

    context 'user show self game' do
      it 'status -> 200; response -> render_template(show), finished? -> false; user -> user' do
        get :show, id: game_w_questions.id
        game = assigns(:game)

        expect(response.status).to eq(200)
        expect(response).to render_template('show')
        expect(game.finished?).to be_falsey
        expect(game.user).to eq(user)
      end
    end

    context 'user show alien game' do
      it 'status -> 200; game.user -> user; finished? -> true; response -> render_template(show)' do
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
      it 'finished? -> true; prize -> 200; balance -> 200; response -> redirect_to(user_path(user), flash -> true' do
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
      it 'status != 200; flash -> true' do
        get :show, id: game_w_questions.id

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context '#create' do
      it 'status != 200; flash -> true; game -> nil' do
        expect { post :create }.to change(Game, :count).by(0)

        game = assigns(:game)

        expect(game).to be nil
        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context '#answer' do
      it 'status != 200; flash -> true' do
        put :answer, id: game_w_questions.id

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context '#take_money' do
      it 'status != 200; flash -> true' do
        put :take_money, id: game_w_questions.id

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end
  end
end
