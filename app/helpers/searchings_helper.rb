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
  def cid_for(obj_type)
    case obj_type
    when 'ingredients'
      '50002766'
    when 'tools'
      '21'
    end
  end
	
end
