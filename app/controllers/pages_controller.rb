class PagesController < ApplicationController
  before_action :require_login, only: [:mypage]
  
  def pro
  end

  def mypage
    @courses = policy_scope current_user.own_courses
  end
end
