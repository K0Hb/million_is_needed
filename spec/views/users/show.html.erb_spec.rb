require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  context 'watch view log_in user' do
    before(:each) do
      user = FactoryGirl.create(:user, name: 'Вася', email: 'mail@mail.ru', balance: 100)
      sign_in user

      assign(:user, user)
      assign(:games, [FactoryGirl.build_stubbed(:game, id: 1, created_at: Time.now, current_level: 1)])
      render
    end

    it 'render :name ' do
      expect(rendered).to match 'Вася'
    end

    it 'render table elements' do
      expect(rendered).to match /#.*Дата.*Вопрос.*Выигрыш.*Подсказки/m
    end

    it 'render link to edit password' do
      expect(rendered).to match 'Сменить имя и пароль'
    end
  end

  context 'watch view not log_in user' do
    before(:each) do
      user = FactoryGirl.build_stubbed(:user, name: 'Вася-анонинм', email: 'mail@mail.ru', balance: 100)

      assign(:user, user)
      assign(:games, [FactoryGirl.build_stubbed(:game, id: 1, created_at: Time.now, current_level: 1)])
      render
    end

    it 'render :name ' do
      expect(rendered).to match 'Вася-анонинм'
    end

    it 'render table elements' do
      expect(rendered).to match /#.*Дата.*Вопрос.*Выигрыш.*Подсказки/m
    end

    it 'not render link to edit password' do
      expect(rendered).to_not match 'Сменить имя и пароль'
    end
  end
end