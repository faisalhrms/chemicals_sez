class HomeController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    if authenticated?
      redirect_to workspace_root_for(Current.user)
    else
      redirect_to new_session_path
    end
  end
end
