# frozen_string_literal: true

class HomeController < InertiaController
  skip_before_action :authenticate_user!

  def index
  end
end
