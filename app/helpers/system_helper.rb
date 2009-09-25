module SystemHelper

  # 获取时间点所在周的结束时间点
  def end_of_week(time)
    days_to_sunday = time.wday!=0 ? 7-time.wday : 0
    (time + days_to_sunday.days).end_of_day
  end

  # 获取时间点所在年的结束时间点
  def end_of_year(time)
    time.change(:month => 12,:day => 31,:hour => 23, :min => 59, :sec => 59)
  end

  # 获取时间跨度名称
  def span_title(span_type)
    case span_type
    when 'day'
      '日'
    when 'week'
      '周'
    when 'month'
      '月'
    when 'year'
      '年'
    end
  end

  # 获取单位时间跨度
  def unit_span(span_type)
    case span_type
    when 'day'
      1.day
    when 'week'
      1.week
    when 'month'
      1.month
    when 'year'
      1.year
    end
  end

  # 获取阶段结束时间点
  def phase_end(span_type, time)
    case span_type
    when 'day'
      time.end_of_day
    when 'week'
      end_of_week(time)
    when 'month'
      time.end_of_month
    when 'year'
      end_of_year(time)
    end
  end

  # 网站指标计算
  def site_metrics(phase_start, phase_end)
    phase_start = phase_start.strftime("%Y-%m-%d %H:%M:%S")
    phase_end = phase_end.strftime("%Y-%m-%d %H:%M:%S")
    user_metrics = User.find_by_sql("SELECT COUNT(id) AS created_users , COUNT(activated_at) AS activated_users
                                    FROM users
                                    WHERE (users.created_at >=  '#{phase_start}'
                                    AND users.created_at <=  '#{phase_end}')
                                    OR (users.activated_at >=  '#{phase_start}'
                                    AND users.activated_at <=  '#{phase_end}')")
    recipe_metrics = Recipe.find_by_sql("SELECT COUNT(id) AS created_recipes , COUNT(published_at) AS published_recipes, COUNT(DISTINCT user_id) AS recipe_users
                                        FROM recipes
                                        WHERE (recipes.created_at >=  '#{phase_start}'
                                        AND recipes.created_at <=  '#{phase_end}')
                                        OR (recipes.published_at >=  '#{phase_start}'
                                        AND recipes.published_at <=  '#{phase_end}')")
    review_metrics = Review.find_by_sql("SELECT COUNT(id) AS created_reviews , COUNT(DISTINCT user_id) AS review_users
                                        FROM reviews
                                        WHERE reviews.created_at >=  '#{phase_start}'
                                        AND reviews.created_at <=  '#{phase_end}'")
    rating_metrics = Rating.find_by_sql("SELECT COUNT(id) AS created_ratings , COUNT(DISTINCT user_id) AS rating_users
                                        FROM ratings
                                        WHERE ratings.created_at >=  '#{phase_start}'
                                        AND ratings.created_at <=  '#{phase_end}'")
    favorite_metrics = Favorite.find_by_sql("SELECT COUNT(id) AS created_favorites , COUNT(DISTINCT user_id) AS favorite_users
                                            FROM favorites
                                            WHERE favorites.created_at >=  '#{phase_start}'
                                            AND favorites.created_at <=  '#{phase_end}'")
    { :user => user_metrics.first, :recipe => recipe_metrics.first, :review => review_metrics.first, :rating => rating_metrics.first, :favorite => favorite_metrics.first }
  end

  # 比较两组指标，获得较大的指标的索引序列
  def site_metrics_most_indexes(site_stats_set, most_indexes, current_index)
    most_indexes.each do |key, value|
      value.each do |k, v|
        current_metric = site_stats_set[current_index][1][key][k].to_i
        most_metric = site_stats_set[v][1][key][k].to_i
        most_indexes[key][k] = current_index if current_metric > most_metric
      end
    end
    most_indexes
  end

  # 根据最大指标的索引序列，获得最大指标的值序列
  def site_metrics_most_values(site_stats_set, most_indexes)
    most_metrics = {}
    most_indexes.each do |key, value|
      most_metrics[key] = {}
      value.each do |k, v|
        most_metrics[key][k] = site_stats_set[v][1][key][k].to_i
      end
    end
    most_metrics
  end

end
