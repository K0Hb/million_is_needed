require 'rails_helper'

RSpec.feature 'user_views_profle_alien_user', type: :feature do
  let(:user1) { create :user, name: 'Вася'}
  let!(:user2) { create :user, name: 'Петя'}

  let!(:games) do
    [
      create(
      :game,
      user_id: user2.id,
      created_at: Time.now,
      current_level: 1,
    ),
    create(
      :game,
      user_id: user2.id,
      created_at: Time.parse('2022.08.09, 9:00'),
      finished_at: Time.parse('2022.08.09, 9:15'),
      current_level: 5,
      prize: 1000
    ),
    create(
      :game,
      user_id: user2.id,
      created_at: Time.parse('2022.08.09, 9:15'),
      finished_at: Time.parse('2022.08.09, 9:45'),
      current_level: 16,
      prize: 1000000
    )
  ]
end

  before(:each) do
    login_as user1
  end

  scenario 'view alien profile' do
    visit "/users/#{user2.id}"

    expect(page).not_to match 'Сменить имя и пароль'

    expect(page).to have_content games[0].id
    expect(page).to have_content 'в процессе'
    expect(page).to have_content '1'
    expect(page).to have_content '0 ₽'
    expect(page).to have_content '50/50'

    expect(page).to have_content games[1].id
    expect(page).to have_content 'деньги'
    expect(page).to have_content '09 авг., 09:00'
    expect(page).to have_content '5'
    expect(page).to have_content '1 000 ₽'
    expect(page).to have_content '50/50'

    expect(page).to have_content games[2].id
    expect(page).to have_content 'победа'
    expect(page).to have_content '09 авг., 09:15'
    expect(page).to have_content '16'
    expect(page).to have_content '1 000 000 ₽'
    expect(page).to have_content '50/50'
  end
end