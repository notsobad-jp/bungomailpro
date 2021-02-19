module ApplicationHelper
  def beginning_of_next_month
    Time.current.next_month.beginning_of_month
  end

  def end_of_next_month
    Time.current.next_month.end_of_month
  end
end
