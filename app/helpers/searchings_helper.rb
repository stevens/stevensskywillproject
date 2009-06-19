module SearchingsHelper

	def keywords_line_to_search_id(keywords_line)
		if keywords_line && !str_squish(keywords_line).blank?
			keywords_line.gsub('&nbsp;', '+')
		else
			nil
		end
	end
	
	def search_id_to_keywords(search_id)
		if search_id && !search_id.strip.blank?
			search_id.split('+')
		else
			[]
		end
	end

	def keywords_to_conditions(keywords, title_field = 'title')
		conditions = []
		if keywords && keywords != []
			for keyword in keywords
				conditions << "#{title_field} LIKE '%#{keyword}%'"
			end
		end
		conditions.join(' OR ')
	end
	
	def searchables_for(user = nil, searchable_type = nil, keywords = [], searchable_conditions = nil, exclude = false, match_all = false, limit = nil, order = 'created_at DESC')
		# conditions = searchable_type == 'User' ? ["(#{keywords_to_conditions(keywords, 'login')})"] : ["(#{keywords_to_conditions(keywords)})"]
		
		case searchable_type
		when 'User'
			conditions = ["(#{keywords_to_conditions(keywords, 'login')})"]
		when 'Recipe'
			conditions = ["(#{keywords_to_conditions(keywords)} OR #{keywords_to_conditions(keywords, 'common_title')})"]
		else
			conditions = ["(#{keywords_to_conditions(keywords)})"]
		end
		
		conditions << "#{controller_name(searchable_type)}.user_id = #{user.id}" if user
		conditions << searchable_conditions if searchable_conditions
		
		searchables_set_1 = model_for(searchable_type).find(:all, :limit => limit, :order => order, 
																												:conditions => conditions.join(' AND '))
																												
		if searchable_type != 'User'
			searchables_set_2 = taggables_for(user, searchable_type, keywords, searchable_conditions, exclude, match_all, limit, order)
			searchables_set = searchables_set_1 | searchables_set_2
		else
			searchables_set = searchables_set_1
		end
		
		if limit
			searchables_set = searchables_set[0..limit-1]
		end
		
		if searchable_type != 'User'
			searchables_set.sort! {|a,b| b[:created_at] <=> a[:created_at]}
		end
		
		searchables_set
	end

  # 搜索商品
  def shop_items_searched(where, options = {})
    case where
    when 'taobao'
      taobao_items_searched(options)
    end
  end

  # 在淘宝搜索商品
  def taobao_items_searched(options = {})
    require 'rubygems'
    require 'net/http'
    require 'uri'
    require 'md5'
#    require 'json'

    url = URI.parse('http://sip.alisoft.com/sip/rest')
    params = { 'sip_appkey' => '19652',
              'sip_appsecret' => '8e4b63f0ca9b11ddb671a3c295a1562b',
              'sip_apiname' => 'taobao.items.get',
              'sip_timestamp' => time_iso_format(Time.now),
              'format' => 'json',
              'v' => '1.0',
              'q' => options[:q],
              'cid' => options[:cid], 
              'page_no' => '1',
              'page_size' => '20',
              'ww_status' => true, 
              'fields' => 'iid,title,pic_path,price,cid,nick',
              'order_by' => 'seller_credit:desc' }
    params["sip_sign"] = MD5.hexdigest('8e4b63f0ca9b11ddb671a3c295a1562b' + params.sort.flatten.join).upcase
    resp  = Net::HTTP.post_form(url, params)
    items = ActiveSupport::JSON.decode(resp.body)['rsp']['items']
#    result = JSON.parse(resp.body)
  end

  # 根据搜索对象确定淘宝的商品种类
  def shop_item_category(where, searchable_type, q) #q:搜索关键词
    case where
    when 'taobao'
      case searchable_type
      when 'ingredient'
        '50002766' # 食品/茶叶/零食/特产 50002766
      when 'tool'
        case
        when q.include?('冰箱') || q.include?('冷柜')
          '50018931' # 冰箱/冷柜 50018930-50018931
        when q.include?('燃气灶') || q.include?('油烟机')
          '50018932' # 燃气灶/油烟机 50018930-50018932
        when q.include?('电烤箱') || q.include?('烤箱')
          '50018933' # 电烤箱 50018930-50018933
        when q.include?('微波炉') || q.include?('光波炉') || q.include?('热波炉')
          '50018934' # 微/光/热波炉 50018930-50018934
        when q.include?('消毒柜')
          '50018935' # 消毒柜 50018930-50018935
        when q.include?('电饭煲') || q.include?('电压力锅') || q.include?('电炖锅') || q.include?('电蒸锅') || q.include?('电热锅') || q.include?('电火锅') || q.include?('煮粥锅') || q.include?('文火炉')
          '50018936' # 电饭/粥/汤/压力/锅/煲/炖 50018930-50018936
        when q.include?('电磁炉')
          '50018937' # 电磁炉 50018930-50018937
        when q.include?('饮水机')
          '50018938' # 饮水机 50018930-50018938
        when q.include?('豆浆机')
          '50018939' # 豆浆机 50018930-50018939
        when q.include?('面包机') || q.include?('多士炉')
          '50018940' # 面包机/多士炉 50018930-50018940
        when q.include?('咖啡机')
          '50018941' # 咖啡机 50018930-50018941
        when q.include?('电水壶') || q.include?('电热杯') || q.include?('电热水壶') || q.include?('电热水瓶')
          '50018942' # 电水壶 50018930-50018942
        when q.include?('酸奶机')
          '50018943' # 酸奶机 50018930-50018943
        when q.include?('煮蛋器') || q.include?('蒸蛋器')
          '50018944' # 煮/蒸蛋器 50018930-50018944
        when q.include?('电饼铛') || q.include?('烤饼机')
          '50018945' # 电饼铛/烤饼机 50018930-50018945
        when q.include?('净水器')
          '50018979' # 净水器 50018930-50018979
        when q.include?('榨汁机') || q.include?('搅拌机') || q.include?('料理机')
          '50019266' # 榨汁/搅拌/料理机 50018930-50019266
        when q.include?('定时器') || q.include?('提醒器')
          '50019267' # 定时器/提醒器 50018930-50019267
        else
          '21' # 居家日用/厨房餐饮/卫浴洗浴 21
        end
      end
    end
  end
  
end
