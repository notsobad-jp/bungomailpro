class En::ApplicationController < ApplicationController
  layout 'en/layouts/application'
  before_action :require_login
end
