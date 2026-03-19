module TasksHelper
  def updated_ago_label(updated_at, now = Time.current)
    elapsed_seconds = [ (now - updated_at).to_i, 0 ].max

    case elapsed_seconds
    when 0...60
      "#{elapsed_seconds}秒前に更新"
    when 60...(60 * 60)
      "#{elapsed_seconds / 60}分前に更新"
    when (60 * 60)...(60 * 60 * 24)
      "#{elapsed_seconds / (60 * 60)}時間前に更新"
    when (60 * 60 * 24)...(60 * 60 * 24 * 30)
      "#{elapsed_seconds / (60 * 60 * 24)}日前に更新"
    when (60 * 60 * 24 * 30)...(60 * 60 * 24 * 365)
      "#{elapsed_seconds / (60 * 60 * 24 * 30)}ヶ月前に更新"
    else
      "#{elapsed_seconds / (60 * 60 * 24 * 365)}年前に更新"
    end
  end
end
