# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @user = UserPresenter.new(current_user)
    render :show
  end

  def show; end
end
