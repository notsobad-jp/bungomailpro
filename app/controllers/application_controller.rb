class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound,   with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  private

  def render_404(error = nil)
    logger.info "[404] Rendering 404 with exception: #{error.message}" if error
    render file: Rails.root.join("public", "404.html"), layout: false, status: :not_found
  end
end
