module ApplicationHelper
  def path
    "#{controller.controller_name}##{controller.action_name}"
  end
end
