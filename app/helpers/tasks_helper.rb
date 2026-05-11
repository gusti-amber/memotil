module TasksHelper
  def updated_ago_label(updated_at, now = Time.current)
    "#{time_ago_label(updated_at, now)}に更新"
  end
end
