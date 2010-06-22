module SystemHelper

  # 系统消息
  def system_notice
#    system_notice = "号外1: <em>“蜂人(测试版)”栏目</em>新出锅, 大家可以<em>互相加为伙伴</em>啦！<br /><br/>
#                     号外2: 大家可以到<em>帐户设置</em>里添加<em>自己的blog</em>啦！"
#    system_notice = "号外: <em>“蜂厨”</em>与新浪著名美食圈子<em>“美食·人生”</em>结成<em>友情合作伙伴</em>!"
#    system_notice = "号外: <em>金蜂·美食人生 大赛 (第一季) 即将开锅喽, 请密切关注比赛动态喔!</em>"
#    system_notice = "号外: <em>金蜂·美食人生 大赛 (第一季) 明天凌晨零点正式开锅!</em>"
#    system_notice = "<span class='bold'>金蜂·美食人生 大赛 (第一季) 正式开锅, 大伙儿快来参赛呵! <em class='l3' style='font-weight: bold;'>(报名和作品征集截止时间延后至2月15日)</em><br /><br />
#                     请要参赛的蜂友前往 <em class='l0'><a href='#{url_for(:controller => 'matches', :action => 'profile', :id => 1)}'>比赛页面</a></em> 报名参赛,
#                     并且查看 <em class='l2'><a href='#{url_for(:controller => 'matches', :action => 'show', :id => 1)}'>比赛详情</a></em> 和 <em class='l3'><a href='#{url_for(:controller => 'matches', :action => 'help')}'>比赛指南</a></em><br /><br />
#                     <em class='l1'><a href='#{url_for(:match_id => 1, :controller => 'entries', :action => 'index')}'>快来投票啦! 投票也有幸运奖呵!</a></em> 参赛的蜂友们快使用<em class='l3' style='font-weight: bold;'> 食谱分享 </em>为自己的作品拉票呵！</span>"
#    system_notice = "<a href='#{url_for(:controller => 'matches', :action => 'profile', :id => 1)}'>金蜂·美食人生 大赛（第一季）</a> 快要结束啦，<em class='l3'>报名、征集和投票截止时间是2月15日（今天）23时59分59秒！</em><br /><br />
#                     请还没有提交参赛作品的选手们抓紧时间提交，<em class='l3'>报名并提交参赛作品的选手都有机会获得“参赛幸运奖”！</em><br />
#                     <em class='l3'>如果参赛作品有至少3位投票者投票，还可以参与“主奖项（金蜂奖、银蜂奖、铜蜂奖）”和“金蜂食单入围奖”的评选！</em><br />
#                     请蜂友们抓紧时间为你喜爱的作品投票，<em class='l3'>投票的蜂友都有机会获得“投票幸运奖”！</em>"
#    system_notice = "<a href='#{url_for(:controller => 'matches', :action => 'profile', :id => 1)}'>金蜂·美食人生 大赛（第一季）</a> <em class='l3'><a href='#{url_for(:match_id => 1, :controller => 'winners', :action => 'index')}'>获奖名单</a></em> 和 <em class='l3'><a href='http://beecook2008.blogspot.com/2009/02/blog-post.html' target='_blank'>金蜂食单</a></em> 揭晓啦，恭喜获奖的作品和蜂友们！<br /><br />
#                     蜂厨服务生已经给获奖的蜂友发出了奖品，请各位注意查收喔！"
#    system_notice = "<em class='l3'><a href='#{menus_path}'>餐单</a></em> 新鲜出炉啦！欢迎蜂友们抢先试用，快来跟大家分享你的美味餐单呵！"
#    system_notice = "蜂厨慈善创意活动—— <em class='l3'><a href='http://blog.sina.com.cn/s/blog_5eb976840100eifm.html' target='_blank'>爱心食谱行动</a></em> 第一季进行中... 美味无敌快乐PK赛—— <em class='l3'><a href='http://blog.sina.com.cn/s/blog_5eb976840100f04b.html' target='_blank'>中西点心对对碰</a></em> 也在进行中..."
#                     <em class='l2'><a href='http://www.photobuddha.net/magazine.asp' target='_blank'>佛图网《觉·得》杂志</a></em> 举办的 <em class='l2'><a href='http://www.beecook.com/matches/2/profile'>〖草木甦活的滋味〗——2010年春季生养身心的素食美味比赛</a></em> 获奖名单新鲜出炉！<br /><br />
#                     <em class='l2'><a href='http://bbs.soufun.com/board/1010234143/95_1' target='_blank'>搜房星河苑业主论坛美人美食分论坛</a></em> 正在举办 <em class='l2'><a href='http://www.beecook.com/matches/3/profile'>“迎玉虎•贺新春”—星河苑社区首届网络美食比赛</a></em> ！"
#                     快来 <em class='l3'><a href='http://www.beecook.com/users/invite'>邀请朋友</a></em> 一起做慈善！合作伙伴 <em class='l3'><a href='http://spooon.taobao.com' target='_blank'>SPOOON</a></em> 带来源自丹麦的独创设计！<br /><br />
    system_notice = ''
#    if @current_user && @current_user.is_role_of?('admin')
#      system_notice = "<em class='l3'><a href=''>【#{item_title(Election.find_by_id(1))}】光荣绽放——用心灵创作最美的味道！</a></em> <br /><br />"
#    end 
    winners = [User.find_by_id(2429), User.find_by_id(2297), User.find_by_id(2486)]
    system_notice += " <em class='l3'><a href='http://blog.sina.com.cn/s/blog_5eb976840100j7b7.html' target='_blank'>蜂厨爱心义卖——支持中国扶贫基金会爱心包裹项目</a></em>正在进行中……！<br /><br />
                      <em class='l2'><a href='http://blog.sina.com.cn/s/blog_5eb976840100eifm.html' target='_blank'>爱心食谱行动</a></em> （第一季）进行中，恭喜 <em class='l2'><a href='#{user_first_link(winners[0])}' target='_blank'>#{user_username(winners[0], true, true)}</a></em>、<em class='l2'><a href='#{user_first_link(winners[1])}' target='_blank'>#{user_username(winners[1], true, true)}</a></em>、<em class='l2'><a href='#{user_first_link(winners[2])}' target='_blank'>#{user_username(winners[2], true, true)}</a></em> 获得第10月度爱心奖！<br /><br />
                      <em class='l2'><a href='http://blog.sina.com.cn/s/blog_5eb976840100h0xm.html' target='_blank'>叶一鹏，你的未来喊你一起踢球！</a></em> ——让爱的网络助叶一鹏坚守永不放弃的信念！"
  end

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
