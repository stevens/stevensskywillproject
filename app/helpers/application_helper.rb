require 'iconv'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	include TagsHelper

	def tab_css_class(current_tab_type, tab_type)
		if current_tab_type == tab_type
			'active'
		else
			''
		end
	end
        
	def yes_no(bool)
    if bool == true
       "yes"
    else
       "no"
    end
	end
        
	def page_title(info1, info2)
		if info1 == '' && info2 == ''
			SITE_NAME_CN
		elsif info1 !='' && info2 == ''
			"#{SITE_NAME_CN} | #{info1}"
		elsif info1 !='' && info2 != ''
			"#{SITE_NAME_CN} | #{info1} #{TITLE_LINKER} #{info2}"
		end
	end
	
	def model_for(obj_type)
		obj_type.camelize.constantize
		rescue NameError
			nil
	end
	
	def name_for(obj_type)
		"#{obj_type.upcase}_CN".constantize
		rescue NameError
			nil
	end
	
#	def unit_for(obj_type)
#		"UNIT_#{obj_type.upcase}_CN".constantize
#		rescue NameError
#			nil
#	end

  def unit_for(item_type)
    case
    when ['User', 'Player'].include?(item_type)
      '位'
    when ['Recipe', 'Favorite', 'Match', 'Award', 'Tag'].include?(item_type)
      '个'
    when ['Rate', 'See'].include?(item_type)
      '次'
    when ['Photo'].include?(item_type)
      '张'
    when ['Review'].include?(item_type)
      '条'
    when ['Entry'].include?(item_type)
      '件'
    when ['Vote', 'rate_stats'].include?(item_type)
      '票'
    when ['Menu', 'default_course_unit'].include?(item_type)
      '份'
    when ['Course'].include?(item_type)
      '道'
    when ['favorite_stats', 'number_of_persons'].include?(item_type)
      '人'
    when ['favorite_s'].include?(item_type)
      '尝'
    when ['review_s'].include?(item_type)
      '评'
    when ['currency'].include?(item_type)
      '元'
    else
      "UNIT_#{item_type.upcase}_CN".constantize
    end
    rescue NameError
			nil
  end
	
	def code_for(obj_type)
		"CODE_#{obj_type.upcase}_CN".constantize
		rescue NameError
			nil
	end
	
	def id_for(obj_type)
		obj_type.downcase.foreign_key
	end
	
	def type_for(obj)
		obj.class.to_s
	end
	
	def item_manageable?(item)
		(@current_user && item.user == @current_user) ? true : false
	end
	
	def item_published?(item)
		item.published?
		rescue NoMethodError
			false
	end
	
	def item_entrying?(item)
		item.entrying?
		rescue NoMethodError
			false
	end
	
	def item_draftable?(item)
		item.attribute_present?('is_draft') ? true : false
	end
	
	def item_id(item)
		id_for(type_for(item))
	end
	
	def controller_name(obj_type)
		obj_type.downcase.pluralize
	end
	
	def item_username(item)
		user_username(item.user)
	end
	
	def item_title(item)
		case type_for(item)
		when 'User'
			user_username(item)
		else
			item.title.strip
		end
	end

  def subitem_type(item_type)
    case item_type
    when 'Menu'
      'Course'
    end
  end
	
	def itemname_suffix(item)
		if item
			" < #{item_title(item)}"
		else
			nil
		end
	end

	def item_url(item_type, item_id)
		"#{root_url}#{item_type.pluralize}/#{item_id}"
	end
	
	def item_html_id(item_type, item_id = nil)
		if item_id
			"#{item_type.downcase}_#{item_id}"
		else
			item_type.downcase
		end
	end
	
	def item_first_link(item, include_profile = false, only_path = false)
		if item
			suffix = '/profile' if include_profile
			prefix = root_url if !only_path
			"#{prefix}#{controller_name(type_for(item))}/#{item.id}#{suffix}"
		end
	end
	
	def real_item(item)
		case type_for(item)
		when 'Entry'
			item.entriable
		else
			item
		end
	end
	
	def item_link_url(item)
		case type_for(item)
		when 'User'
			user_first_link(item, true)
		when 'Match'
			item_first_link(item, true)
    when 'Course'
      "#{menu_courses_path(item.menu)}#course_#{item.id}_line"
		else
			item
		end
	end
	
	def items_html_id(item_type, itemable_type = nil, itemable_id = nil)
		if itemable_type
			"#{item_html_id(itemable_type, itemable_id)}_#{controller_name(item_type)}"
		else
			"all_#{controller_name(item_type)}"
		end
	end
	
	def user_items_html_id(item_type, itemable_type = nil, itemable_id = nil, user = nil)
		"#{items_html_id(item_type, itemable_type, itemable_id)}_of_#{user_html_id(user)}"
	end
	
	def classified_items(items, classify_by)
		items.group_by { |item| (item[classify_by.to_sym]) }.sort { |a, b| a <=> b }
	end
	
	def random_items(items, count)
		random_items = []
		1.upto(count) do |i|
			random_items << items.rand
			random_items.uniq!
			if random_items.size < i
				count += 1
			end
		end
		random_items
	end
	
	#比较当前时间与起止时间获得相应的时间状态参数
	def time_status(current, start_at, end_at)
		case
		when current < start_at
			[ 10, 'todo', '未开始' ]
		when current >= start_at && current <= end_at
			[ 20, 'doing', '进行中' ]
		when current > end_at
			[ 30, 'done', '已结束' ]
		end
	end

	def second_to_hms(second)
		h = second/3600
		m = second%3600/60
		s = second%60
		{:h => h, :m => m, :s => s}
	end
	
	def time_display(second, time_style, h_text, m_text, s_text)
		h = second_to_hms(second)[:h]
 		m = second_to_hms(second)[:m]
 		s = second_to_hms(second)[:s]
		t = ''
		case time_style
		when 'h'
			t += "#{h}#{h_text}" if h>0
		when 'hm'
			if h>0
				t += "#{h}#{h_text}"
				if m>0
					t += " #{m}#{m_text}"
				end
			else
				if m>0
					t += "#{m}#{m_text}"
				end
			end
		when 'hms'
			if h>0
				t += "#{h}#{h_text}"
				if s>0
					t += " #{m}#{m_text} #{s}#{s_text}"					
				elsif m>0
					t += " #{m}#{m_text}"
				end
			else
				if m>0
					t += "#{m}#{m_text}"
					if s>0
						t += " #{s}#{s_text}"
					end
				else
					if s>0
						t += "#{s}#{s_text}"
					end
				end
			end
		end
	end
	
	def time_iso_format(time, better = false, only_date = false, include_second = true)
		if better
			i = Time.now - time
			case 
			when i < 60
				"#{i.floor}秒钟前"
			when i >= 60 && i < 60*60
				"#{(i/60).floor}分钟前"
			when i >= 60*60 && i < 60*60*24
				"#{(i/(60*60)).floor}小时前"
			when i >= 60*60*24 && i < 60*60*24*7
				"#{(i/(60*60*24)).floor}天前"
			else
				time.strftime("%Y-%m-%d")
			end
		elsif only_date
			time.strftime("%Y-%m-%d")
		else
			if include_second
				time.strftime("%Y-%m-%d %H:%M:%S")
			else
				time.strftime("%Y-%m-%d %H:%M")
			end
		end
	end
	
	def better_date(date)
		case
		when date == Date.today
			'今天'
		when date == Date.yesterday
			'昨天'
		when date == Date.yesterday - 1
			'前天'
		else
			date
		end
	end
	
	def items_rows_count(items_count, items_count_per_row)
		rc = items_count/items_count_per_row
		rc = items_count%items_count_per_row == 0 ? rc : rc+1
	end
	
	def select_number_options(max, selected) # min <= selected <= max
		options = ''
		1.upto(max+1) do |i|
			n = i-1
			if n == selected
				options += "<option selected='selected'>#{n}</option> "
			else
				options += "<option>#{n}</option> "
			end
		end
		options
	end
	
	def text_summary(text, min_length = TEXT_SUMMARY_LENGTH_M)
		text.chars.length > min_length ? text.to(min_length-1) + '...' : text
	end
	
	def str_squish(str, space_count = 1, convert_space = true)
		space = ''
		1.upto(space_count) do
			if convert_space
				space += '&nbsp;'
			else
				space += ' '
			end
		end
		if str && !str.blank?
			str.strip.gsub(/\s+/, space)
		else
			nil
		end
	end
	
	def str_keep_space(str)
		if str && !str.blank?
			str.rstrip.gsub(/\s/, '&nbsp;')
		else
			nil
		end
	end
	
	def paragraphs(text, keep_blank_line = false, keep_left_space = false, min_paras_count = nil)
		paragraphs = []
		if text && !text.blank?
			ps = auto_link(text, :all, :target => "_blank").split(/\n/)
			for p in ps
				p = sanitize(p.strip, :tags => %w[a img], :attributes => %w[href target src title alt])
				if keep_blank_line
					p = '&nbsp;' if p.blank?
					if p.starts_with?('[') && p.ends_with?(']')
						paragraphs << "<span class='subtitle'>#{p}</span>"
					else
						paragraphs << "<li><span class='text'>#{p}</span></li>"
					end
				elsif !p.blank?
					if p.starts_with?('[') && p.ends_with?(']')
						paragraphs << "<span class='subtitle'>#{p}</span>"
					else
						paragraphs << "<li><span class='text'>#{p}</span></li>"
					end
				end
			end
		end
		if min_paras_count && paragraphs.size > min_paras_count
			paragraphs[0..min_paras_count-1] + ["<li><span class='none'>...</span></li>"]
		else
			paragraphs
		end
	end
	
	def restfu_url_for(namespace, parent_obj, self_obj, action)
		ns = "#{namespace}/" if namespace
		po = "#{controller_name(parent_obj[:type])}/#{parent_obj[:id]}/" if parent_obj && parent_obj[:type] && parent_obj[:id]
		if self_obj
			if self_obj[:type]
				if self_obj[:id]
					so = "#{controller_name(self_obj[:type])}/#{self_obj[:id]}"
				else
					so = "#{controller_name(self_obj[:type])}"
				end
			end
		end
		ac = "/#{action}" if action
		"#{root_url}#{ns}#{po}#{so}#{ac}"
	end
	
	def add_brackets(str, left_mark = '[', right_mark = ']')
		if str && !str.blank?
			"#{left_mark}#{str}#{right_mark}"
		else
			''
		end
	end
	
	def itemable_type(item, itemable_sym)
		item["#{itemable_sym}_type".to_sym]
	end
	
	def itemable_id(item, itemable_sym)
		item["#{itemable_sym}_id".to_sym]
	end
	
	def itemable(item, itemable_sym)
		if itemable = model_for(itemable_type(item, itemable_sym)).find(itemable_id(item, itemable_sym))
			itemable
		else
			nil
		end
	end
	
	def count_per_row(count = MATRIX_ITEMS_COUNT_PER_ROW_M)
		count
	end
	
	def items_paginate(items_set, count_per_page = LIST_ITEMS_COUNT_PER_PAGE_S)
		items_set.paginate :page => params[:page], 
 											 :per_page => count_per_page		
	end
	
	def sort_by_gbk(items, method=:name) 
		conv = Iconv.new("GBK", "utf-8") 
		items.sort {|x, y| conv.iconv(x[method]) <=> conv.iconv(y[method])} 
	end
	
	def gbk_for(str)
		Iconv.iconv('GBK', 'utf-8', str)
	end
	
	def page_for(current_page, items_set_count, items_count_per_page = LIST_ITEMS_COUNT_PER_PAGE_S)
		if current_page && (current_page > 1) && (items_set_count <= (current_page - 1) * items_count_per_page)
			current_page - 1
		else
			current_page
		end
	end
	
	def conditions_for(item_type, item_conds)
		if item_type && item_conds
			case item_type
			when 'Recipe'
				recipe_conditions(item_conds)
			end
		end
	end
	
	# --------------与数字处理相关的方法--------------
	
	# i 原始数, n 要保留的小数位数, flag=1 四舍五入 flag=0 不四舍五入
	def f(i, n=1, flag=1)
	  y = 1  
	  n.times do |x|   
	  	y = y*10  
	  end   
	  if flag==1  
	  	(i*y).round/(y*1.0)   
	  else  
	  	(i*y).floor/(y*1.0)   
	  end   
	end 
	
	# 获得用户的ip地址
	def item_client_ip(item)
		item.client_ip = request.env["HTTP_X_FORWARDED_FOR"]
	end

  # 判断item是否可以发布
  def item_publishable?(item)
  	(item.is_draft == '1' && !item.cover_photo_id.nil?) ? true : false
  end

  # 判断item是否已经发布
  def item_published?(item)
  	(item.is_draft == '0' && !item.published_at.nil?) ? true : false
  end

  # 判断item是否可以访问
  def item_accessible?(item, someuser = nil)
  	if someuser
  		if someuser == item.user
  			true
  		else
  			(item.is_draft == '0' && item.privacy <= '11') ? true : false
  		end
  	else
  		(item.is_draft == '0' && item.privacy == '10') ? true : false
  	end
  end

  # 按railsapi里介绍的增加此函数
  def grouped_options_for_select(grouped_options, selected_key = nil, prompt = nil)
    body = ''
    body << content_tag(:option, prompt, :value => "") if prompt

    grouped_options = grouped_options.sort if grouped_options.is_a?(Hash)

    grouped_options.each do |group|
       body << content_tag(:optgroup, options_for_select(group[1], selected_key), :label => group[0])
    end

    body
  end

  # 分组的区域选项
  def grouped_options_of_area
    grouped_options = [ [ '中国', options_of_area('china') ], [ '海外', options_of_area('abroad') ] ]
  end

  # 区域选项
  def options_of_area(area_type)
    case area_type
    when 'china'
      options = [
                  [ '北京', '110000' ], [ '天津', '120000' ], [ '河北', '130000' ], [ '山西', '140000' ], [ '内蒙古', '150000' ],
                  [ '辽宁', '210000' ], [ '吉林', '220000' ], [ '黑龙江', '230000' ], [ '上海', '310000' ], [ '江苏', '320000' ],
                  [ '浙江', '330000' ], [ '安徽', '340000' ], [ '福建', '350000' ], [ '江西', '360000' ], [ '山东', '370000' ],
                  [ '河南', '410000' ], [ '湖北', '420000' ], [ '湖南', '430000' ], [ '广东', '440000' ], [ '广西', '450000' ],
                  [ '海南', '460000' ], [ '重庆', '500000' ], [ '四川', '510000' ], [ '贵州', '520000' ], [ '云南', '530000' ],
                  [ '西藏', '540000' ], [ '陕西', '610000' ], [ '甘肃', '620000' ], [ '青海', '630000' ], [ '宁夏', '640000' ],
                  [ '新疆', '650000' ], [ '台湾', '710000' ], [ '香港', '810000' ], [ '澳门', '820000' ]
                ]
    when 'abroad'
      options = [
                  [ '亚洲', '100' ], [ '非洲', '200' ], [ '欧洲', '300' ], [ '拉丁美洲', '400' ], [ '北美洲', '500' ], [ '大洋洲', '600' ]
                ]
    end
  end

  # 子区域选项
  def options_of_subarea(area)
    case area
    when '110000'
      options = [ 
                  [ '北京市', '110000' ]
                ]
    when '120000'
      options = [ 
                  [ '天津市', '120000' ]
                ]
    when '130000'
      options = [ 
                  [ '石家庄市', '130100' ], [ '唐山市', '130200' ], [ '秦皇岛市', '130300' ], [ '邯郸市', '130400' ], [ '邢台市', '130500' ],
                  [ '保定市', '130600' ], [ '张家口市', '130700' ], [ '承德市', '130800' ], [ '沧州市', '130900' ], [ '廊坊市', '131000' ],
                  [ '衡水市', '131100' ]
                ]
    when '140000'
      options = [
                  [ '太原市', '140100' ], [ '大同市', '140200' ], [ '阳泉市', '140300' ], [ '长治市', '140400' ], [ '晋城市', '140500' ],
                  [ '朔州市', '140600' ], [ '晋中市', '140700' ], [ '运城市', '140800' ], [ '忻州市', '140900' ], [ '临汾市', '141000' ],
                  [ '吕梁市', '141100' ]
                ]
    when '150000'
      options = [
                  [ '呼和浩特市', '150100' ], [ '包头市', '150200' ], [ '乌海市', '150300' ], [ '赤峰市', '150400' ], [ '通辽市', '150500' ],
                  [ '鄂尔多斯市', '150600' ], [ '呼伦贝尔市', '150700' ], [ '巴彦淖尔市', '150800' ], [ '乌兰察布市', '150900' ], [ '兴安盟', '152200' ],
                  [ '锡林郭勒盟', '152500' ], [ '阿拉善盟', '152900' ]
                ]
    when '210000'
      options = [
                  [ '沈阳市', '210100' ], [ '大连市', '210200' ], [ '鞍山市', '210300' ], [ '抚顺市', '210400' ], [ '本溪市', '210500' ],
                  [ '丹东市', '210600' ], [ '锦州市', '210700' ], [ '营口市', '210800' ], [ '阜新市', '210900' ], [ '辽阳市', '211000' ],
                  [ '盘锦市', '211100' ], [ '铁岭市', '211200' ], [ '朝阳市', '211300' ], [ '葫芦岛市', '211400' ]
                ]
    when '220000'
      options = [
                  [ '长春市', '220100' ], [ '吉林市', '220200' ], [ '四平市', '220300' ], [ '辽源市', '220400' ], [ '通化市', '220500' ],
                  [ '白山市', '220600' ], [ '松原市', '220700' ], [ '白城市', '220800' ], [ '延边州', '222400' ]
                ]
    when '230000'
      options = [
                  [ '哈尔滨市', '230100' ], [ '齐齐哈尔市', '230200' ], [ '鸡西市', '230300' ], [ '鹤岗市', '230400' ], [ '双鸭山市', '230500' ],
                  [ '大庆市', '230600' ], [ '伊春市', '230700' ], [ '佳木斯市', '230800' ], [ '七台河市', '230900' ], [ '牡丹江市', '231000' ],
                  [ '黑河市', '231100' ], [ '绥化市', '231200' ], [ '大兴安岭地区', '232700' ]
                ]
    when '310000'
      options = [ 
                  [ '上海市', '310000' ]
                ]
    when '320000'
      options = [
                  [ '南京市', '320100' ], [ '无锡市', '320200' ], [ '徐州市', '320300' ], [ '常州市', '320400' ], [ '苏州市', '320500' ],
                  [ '南通市', '320600' ], [ '连云港市', '320700' ], [ '淮安市', '320800' ], [ '盐城市', '320900' ], [ '扬州市', '321000' ],
                  [ '镇江市', '321100' ], [ '泰州市', '321200' ], [ '宿迁市', '321300' ]
                ]
    when '330000'
      options = [
                  [ '杭州市', '330100' ], [ '宁波市', '330200' ], [ '温州市', '330300' ], [ '嘉兴市', '330400' ], [ '湖州市', '330500' ],
                  [ '绍兴市', '330600' ], [ '金华市', '330700' ], [ '衢州市', '330800' ], [ '舟山市', '330900' ], [ '台州市', '331000' ],
                  [ '丽水市', '331100' ]
                ]
    when '340000'
      options = [
                  [ '合肥市', '340100' ], [ '芜湖市', '340200' ], [ '蚌埠市', '340300' ], [ '淮南市', '340400' ], [ '马鞍山市', '340500' ],
                  [ '淮北市', '340600' ], [ '铜陵市', '340700' ], [ '安庆市', '340800' ], [ '黄山市', '341000' ], [ '滁州市', '341100' ],
                  [ '阜阳市', '341200' ], [ '宿州市', '341300' ], [ '巢湖市', '341400' ], [ '六安市', '341500' ], [ '亳州市', '341600' ],
                  [ '池州市', '341700' ], [ '宣城市', '341800' ]
                ]	
    when '350000'
      options = [
                  [ '福州市', '350100' ], [ '厦门市', '350200' ], [ '莆田市', '350300' ], [ '三明市', '350400' ], [ '泉州市', '350500' ],
                  [ '漳州市', '350600' ], [ '南平市', '350700' ], [ '龙岩市', '350800' ], [ '宁德市', '350900' ]
                ]
    when '360000'
      options = [
                  [ '南昌市', '360100' ], [ '景德镇市', '360200' ], [ '萍乡市', '360300' ], [ '九江市', '360400' ], [ '新余市', '360500' ],
                  [ '鹰潭市', '360600' ], [ '赣州市', '360700' ], [ '吉安市', '360800' ], [ '宜春市', '360900' ], [ '抚州市', '361000' ],
                  [ '上饶市', '361100' ]
                ]
    when '370000'
      options = [
                  [ '济南市', '370100' ], [ '青岛市', '370200' ], [ '淄博市', '370300' ], [ '枣庄市', '370400' ], [ '东营市', '370500' ],
                  [ '烟台市', '370600' ], [ '潍坊市', '370700' ], [ '济宁市', '370800' ], [ '泰安市', '370900' ], [ '威海市', '371000' ],
                  [ '日照市', '371100' ], [ '莱芜市', '371200' ], [ '临沂市', '371300' ], [ '德州市', '371400' ], [ '聊城市', '371500' ],
                  [ '滨州市', '371600' ], [ '菏泽市', '371700' ]
                ]
    when '410000'
      options = [
                  [ '郑州市', '410100' ], [ '开封市', '410200' ], [ '洛阳市', '410300' ], [ '平顶山市', '410400' ], [ '安阳市', '410500' ],
                  [ '鹤壁市', '410600' ], [ '新乡市', '410700' ], [ '焦作市', '410800' ], [ '濮阳市', '410900' ], [ '许昌市', '411000' ],
                  [ '漯河市', '411100' ], [ '三门峡市', '411200' ], [ '南阳市', '411300' ], [ '商丘市', '411400' ], [ '信阳市', '411500' ],
                  [ '周口市', '411600' ], [ '驻马店市', '411700' ]
                ]
    when '420000'
      options = [
                  [ '武汉市', '420100' ], [ '黄石市', '420200' ], [ '十堰市', '420300' ], [ '宜昌市', '420500' ], [ '襄樊市', '420600' ],
                  [ '鄂州市', '420700' ], [ '荆门市', '420800' ], [ '孝感市', '420900' ], [ '荆州市', '421000' ], [ '黄冈市', '421100' ],
                  [ '咸宁市', '421200' ], [ '随州市', '421300' ], [ '恩施州', '422800' ], [ '其他', '429000' ]
                ]
    when '430000'
      options = [
                  [ '长沙市', '430100' ], [ '株洲市', '430200' ], [ '湘潭市', '430300' ], [ '衡阳市', '430400' ], [ '邵阳市', '430500' ],
                  [ '岳阳市', '430600' ], [ '常德市', '430700' ], [ '张家界市', '430800' ], [ '益阳市', '430900' ], [ '郴州市', '431000' ],
                  [ '永州市', '431100' ], [ '怀化市', '431200' ], [ '娄底市', '431300' ], [ '湘西州', '433100' ]
                ]
    when '440000'
      options = [
                  [ '广州市', '440100' ], [ '韶关市', '440200' ], [ '深圳市', '440300' ], [ '珠海市', '440400' ], [ '汕头市', '440500' ],
                  [ '佛山市', '440600' ], [ '江门市', '440700' ], [ '湛江市', '440800' ], [ '茂名市', '440900' ], [ '肇庆市', '441200' ],
                  [ '惠州市', '441300' ], [ '梅州市', '441400' ], [ '汕尾市', '441500' ], [ '河源市', '441600' ], [ '阳江市', '441700' ],
                  [ '清远市', '441800' ], [ '东莞市', '441900' ], [ '中山市', '442000' ], [ '潮州市', '445100' ], [ '揭阳市', '445200' ],
                  [ '云浮市', '445300' ]
                ]	
    when '450000'
      options = [
                  [ '南宁市', '450100' ], [ '柳州市', '450200' ], [ '桂林市', '450300' ], [ '梧州市', '450400' ], [ '北海市', '450500' ],
                  [ '防城港市', '450600' ], [ '钦州市', '450700' ], [ '贵港市', '450800' ], [ '玉林市', '450900' ], [ '百色市', '451000' ],
                  [ '贺州市', '451100' ], [ '河池市', '451200' ], [ '来宾市', '451300' ], [ '崇左市', '451400' ]
                ]
    when '460000'
      options = [ 
                  [ '海口', '460100' ], [ '三亚', '460200' ], [ '其他', '469000' ]
                ]
    when '500000'
      options = [ 
                  [ '重庆市', '500000' ]
                ]
    when '510000'
      options = [
                  [ '成都市', '510100' ], [ '自贡市', '510300' ], [ '攀枝花市', '510400' ], [ '泸州市', '510500' ], [ '德阳市', '510600' ],
                  [ '绵阳市', '510700' ], [ '广元市', '510800' ], [ '遂宁市', '510900' ], [ '内江市', '511000' ], [ '乐山市', '511100' ],
                  [ '南充市', '511300' ], [ '眉山市', '511400' ], [ '宜宾市', '511500' ], [ '广安市', '511600' ], [ '达州市', '511700' ],
                  [ '雅安市', '511800' ], [ '巴中市', '511900' ], [ '资阳市', '512000' ], [ '阿坝州', '513200' ], [ '甘孜州', '513300' ],
                  [ '凉山州', '513400' ]
                ]
    when '520000'
      options = [
                  [ '贵阳市', '520100' ], [ '六盘水市', '520200' ], [ '遵义市', '520300' ], [ '安顺市', '520400' ], [ '铜仁地区', '522200' ],
                  [ '黔西南州', '522300' ], [ '毕节地区', '522400' ], [ '黔东南州', '522600' ], [ '黔南州', '522700' ]
                ]
    when '530000'
      options = [
                  [ '昆明市', '530100' ], [ '曲靖市', '530300' ], [ '玉溪市', '530400' ], [ '保山市', '530500' ], [ '昭通市', '530600' ],
                  [ '丽江市', '530700' ], [ '普洱市', '530800' ], [ '临沧市', '530900' ], [ '楚雄州', '532300' ], [ '红河州', '532500' ],
                  [ '文山州', '532600' ], [ '西双版纳州', '532800' ], [ '大理州', '532900' ], [ '德宏州', '533100' ], [ '怒江州', '533300' ],
                  [ '迪庆州', '533400' ]
                ]
    when '540000'
      options = [
                  [ '拉萨市', '540100' ], [ '昌都地区', '542100' ], [ '山南地区', '542200' ], [ '日喀则地区', '542300' ], [ '那曲地区', '542400' ],
                  [ '阿里地区', '542500' ], [ '林芝地区', '542600' ]
                ]
    when '610000'
      options = [
                  [ '西安市', '610100' ], [ '铜川市', '610200' ], [ '宝鸡市', '610300' ], [ '咸阳市', '610400' ], [ '渭南市', '610500' ],
                  [ '延安市', '610600' ], [ '汉中市', '610700' ], [ '榆林市', '610800' ], [ '安康市', '610900' ], [ '商洛市', '611000' ]
                ]
    when '620000'
      options = [
                  [ '兰州市', '620100' ], [ '嘉峪关市', '620200' ], [ '金昌市', '620300' ], [ '白银市', '620400' ], [ '天水市', '620500' ],
                  [ '武威市', '620600' ], [ '张掖市', '620700' ], [ '平凉市', '620800' ], [ '酒泉市', '620900' ], [ '庆阳市', '621000' ],
                  [ '定西市', '621100' ], [ '陇南市', '621200' ], [ '临夏州', '622900' ], [ '甘南州', '623000' ]
                ]
    when '630000'
      options = [
                  [ '西宁市', '630100' ], [ '海东地区', '632100' ], [ '海北州', '632200' ], [ '黄南州', '632300' ], [ '海南州', '632500' ],
                  [ '果洛州', '632600' ], [ '玉树州', '632700' ], [ '海西州', '632800' ]
                ]
    when '640000'
      options = [
                  [ '银川市', '640100' ], [ '石嘴山市', '640200' ], [ '吴忠市', '640300' ], [ '固原市', '640400' ], [ '中卫市', '640500' ]
                ]
    when '650000'
      options = [
                  [ '乌鲁木齐市', '650100' ], [ '克拉玛依市', '650200' ], [ '吐鲁番地区', '652100' ], [ '哈密地区', '652200' ], [ '昌吉州', '652300' ],
                  [ '博尔塔拉州', '652700' ], [ '巴音郭楞州', '652800' ], [ '阿克苏地区', '652900' ], [ '克孜勒苏州', '653000' ], [ '喀什地区', '653100' ],
                  [ '和田地区', '653200' ], [ '伊犁州', '654000' ], [ '塔城地区', '654200' ], [ '阿勒泰地区', '654300' ], [ '其他', '659000' ]
                ]
    when '710000'
      options = [ 
                  [ '台北市', '710100' ], [ '高雄市', '710200' ], [ '基隆市', '710300' ], [ '台中市', '710400' ], [ '台南市', '710500' ],
                  [ '新竹市', '710600' ], [ '嘉义市', '710700' ], [ '台北县', '712100' ], [ '宜兰县', '712200' ], [ '桃园县', '712300' ],
                  [ '新竹县', '712400' ], [ '苗栗县', '712500' ], [ '台中县', '712600' ], [ '彰化县', '712700' ], [ '南投县', '712800' ],
                  [ '云林县', '712900' ], [ '嘉义县', '713000' ], [ '台南县', '713100' ], [ '高雄县', '713200' ], [ '屏东县', '713300' ],
                  [ '台东县', '713400' ], [ '花莲县', '713500' ], [ '澎湖县', '713600' ]
                ]
    when '810000'
      options = [ 
                  [ '香港', '110000' ]
                ]
    when '820000'
      options = [
                  [ '澳门', '110000' ]
                ]
    when '100'
      options = [
                  [ '阿富汗', '101' ],
                  [ '巴林', '102' ],
                  [ '孟加拉国', '103' ],
                  [ '不丹', '104' ],
                  [ '文莱', '105' ],
                  [ '缅甸', '106' ],
                  [ '柬埔寨', '107' ],
                  [ '塞浦路斯', '108' ],
                  [ '朝鲜', '109' ],
                  [ '印度', '111' ],
                  [ '印度尼西亚', '112' ],
                  [ '伊朗', '113' ],
                  [ '伊拉克', '114' ],
                  [ '以色列', '115' ],
                  [ '日本', '116' ],
                  [ '约旦', '117' ],
                  [ '科威特', '118' ],
                  [ '老挝', '119' ],
                  [ '黎巴嫩', '120' ],
                  [ '马来西亚', '122' ],
                  [ '马尔代夫', '123' ],
                  [ '蒙古', '124' ],
                  [ '尼泊尔', '125' ],
                  [ '阿曼', '126' ],
                  [ '巴基斯坦', '127' ],
                  [ '巴勒斯坦', '128' ],
                  [ '菲律宾', '129' ],
                  [ '卡塔尔', '130' ],
                  [ '沙特阿拉伯', '131' ],
                  [ '新加坡', '132' ],
                  [ '韩国', '133' ],
                  [ '斯里兰卡', '134' ],
                  [ '叙利亚', '135' ],
                  [ '泰国', '136' ],
                  [ '土耳其', '137' ],
                  [ '阿联酋', '138' ],
                  [ '也门', '139' ],
                  [ '越南', '141' ],
                  [ '东帝汶', '144' ],
                  [ '哈萨克斯坦', '145' ],
                  [ '吉尔吉斯斯坦', '146' ],
                  [ '塔吉克斯坦', '147' ],
                  [ '土库曼斯坦', '148' ],
                  [ '乌兹别克斯坦', '149' ],
                  [ '亚洲其他', '199' ]
                ]
    when '200'
      options = [
                  [ '阿尔及利亚', '201' ],
                  [ '安哥拉', '202' ],
                  [ '贝宁', '203' ],
                  [ '博茨瓦那', '204' ],
                  [ '布隆迪', '205' ],
                  [ '喀麦隆', '206' ],
                  [ '加那利群岛', '207' ],
                  [ '佛得角', '208' ],
                  [ '中非', '209' ],
                  [ '塞卜泰', '210' ],
                  [ '乍得', '211' ],
                  [ '科摩罗', '212' ],
                  [ '刚果', '213' ],
                  [ '吉布提', '214' ],
                  [ '埃及', '215' ],
                  [ '赤道几内亚', '216' ],
                  [ '埃塞俄比亚', '217' ],
                  [ '加蓬', '218' ],
                  [ '冈比亚', '219' ],
                  [ '加纳', '220' ],
                  [ '几内亚', '221' ],
                  [ '几内亚比绍', '222' ],
                  [ '科特迪瓦', '223' ],
                  [ '肯尼亚', '224' ],
                  [ '利比里亚', '225' ],
                  [ '利比亚', '226' ],
                  [ '马达加斯加', '227' ],
                  [ '马拉维', '228' ],
                  [ '马里', '229' ],
                  [ '毛里塔尼亚', '230' ],
                  [ '毛里求斯', '231' ],
                  [ '摩洛哥', '232' ],
                  [ '莫桑比克', '233' ],
                  [ '纳米比亚', '234' ],
                  [ '尼日尔', '235' ],
                  [ '尼日利亚', '236' ],
                  [ '留尼汪', '237' ],
                  [ '卢旺达', '238' ],
                  [ '圣多美和普林西比', '239' ],
                  [ '塞内加尔', '240' ],
                  [ '塞舌尔', '241' ],
                  [ '塞拉利昂', '242' ],
                  [ '索马里', '243' ],
                  [ '南非', '244' ],
                  [ '西撒哈拉', '245' ],
                  [ '苏丹', '246' ],
                  [ '坦桑尼亚', '247' ],
                  [ '多哥', '248' ],
                  [ '突尼斯', '249' ],
                  [ '乌干达', '250' ],
                  [ '布基纳法索', '251' ],
                  [ '民主刚果', '252' ],
                  [ '赞比亚', '253' ],
                  [ '津巴布韦', '254' ],
                  [ '莱索托', '255' ],
                  [ '梅利利亚', '256' ],
                  [ '斯威士兰', '257' ],
                  [ '厄立特里亚', '258' ],
                  [ '马约特岛', '259' ],
                  [ '非洲其他', '299' ]
                ]
    when '300'
      options = [
                  [ '比利时', '301' ],
                  [ '丹麦', '302' ],
                  [ '英国', '303' ],
                  [ '德国', '304' ],
                  [ '法国', '305' ],
                  [ '爱尔兰', '306' ],
                  [ '意大利', '307' ],
                  [ '卢森堡', '308' ],
                  [ '荷兰', '309' ],
                  [ '希腊', '310' ],
                  [ '葡萄牙', '311' ],
                  [ '西班牙', '312' ],
                  [ '阿尔巴尼亚', '313' ],
                  [ '安道尔', '314' ],
                  [ '奥地利', '315' ],
                  [ '保加利亚', '316' ],
                  [ '芬兰', '318' ],
                  [ '直布罗陀', '320' ],
                  [ '匈牙利', '321' ],
                  [ '冰岛', '322' ],
                  [ '列支敦士登', '323' ],
                  [ '马耳他', '324' ],
                  [ '摩纳哥', '325' ],
                  [ '挪威', '326' ],
                  [ '波兰', '327' ],
                  [ '罗马尼亚', '328' ],
                  [ '圣马力诺', '329' ],
                  [ '瑞典', '330' ],
                  [ '瑞士', '331' ],
                  [ '爱沙尼亚', '334' ],
                  [ '拉脱维亚', '335' ],
                  [ '立陶宛', '336' ],
                  [ '格鲁吉亚', '337' ],
                  [ '亚美尼亚', '338' ],
                  [ '阿塞拜疆', '339' ],
                  [ '白俄罗斯', '340' ],
                  [ '摩尔多瓦', '343' ],
                  [ '俄罗斯联邦', '344' ],
                  [ '乌克兰', '347' ],
                  [ '斯洛文尼亚', '350' ],
                  [ '克罗地亚', '351' ],
                  [ '捷克', '352' ],
                  [ '斯洛伐克', '353' ],
                  [ '马其顿', '354' ],
                  [ '波斯尼亚-黑塞哥维那', '355' ],
                  [ '梵蒂冈', '356' ],
                  [ '法罗群岛', '357' ],
                  [ '塞尔维亚', '358' ],
                  [ '黑山', '359' ],
                  [ '欧洲其他', '399' ]
                ]
    when '400'
      options = [
                  [ '安提瓜和巴布达', '401' ],
                  [ '阿根廷', '402' ],
                  [ '阿鲁巴岛', '403' ],
                  [ '巴哈马', '404' ],
                  [ '巴巴多斯', '405' ],
                  [ '伯利兹', '406' ],
                  [ '玻利维亚', '408' ],
                  [ '博内尔', '409' ],
                  [ '巴西', '410' ],
                  [ '开曼群岛', '411' ],
                  [ '智利', '412' ],
                  [ '哥伦比亚', '413' ],
                  [ '多米尼亚', '414' ],
                  [ '哥斯达黎加', '415' ],
                  [ '古巴', '416' ],
                  [ '库腊索岛', '417' ],
                  [ '多米尼加', '418' ],
                  [ '厄瓜多尔', '419' ],
                  [ '法属圭亚那', '420' ],
                  [ '格林纳达', '421' ],
                  [ '瓜德罗普', '422' ],
                  [ '危地马拉', '423' ],
                  [ '圭亚那', '424' ],
                  [ '海地', '425' ],
                  [ '洪都拉斯', '426' ],
                  [ '牙买加', '427' ],
                  [ '马提尼克', '428' ],
                  [ '墨西哥', '429' ],
                  [ '蒙特塞拉特', '430' ],
                  [ '尼加拉瓜', '431' ],
                  [ '巴拿马', '432' ],
                  [ '巴拉圭', '433' ],
                  [ '秘鲁', '434' ],
                  [ '波多黎各', '435' ],
                  [ '萨巴', '436' ],
                  [ '圣卢西亚', '437' ],
                  [ '圣马丁岛', '438' ],
                  [ '圣文森特和格林纳丁斯', '439' ],
                  [ '萨尔瓦多', '440' ],
                  [ '苏里南', '441' ],
                  [ '特立尼达和多巴哥', '442' ],
                  [ '特克斯和凯科斯群岛', '443' ],
                  [ '乌拉圭', '444' ],
                  [ '委内瑞拉', '445' ],
                  [ '英属维尔京群岛', '446' ],
                  [ '圣其茨-尼维斯', '447' ],
                  [ '圣皮埃尔和密克隆', '448' ],
                  [ '荷属安地列斯群岛', '449' ],
                  [ '拉丁美洲其他', '499' ]
                ]
    when '500'
      options = [
                  [ '加拿大', '501' ],
                  [ '美国', '502' ],
                  [ '格陵兰', '503' ],
                  [ '百慕大', '504' ],
                  [ '北美洲其他', '599' ]
                ]
    when '600'
      options = [
                  [ '澳大利亚', '601' ],
                  [ '库克群岛', '602' ],
                  [ '斐济', '603' ],
                  [ '盖比群岛', '604' ],
                  [ '马克萨斯群岛', '605' ],
                  [ '瑙鲁', '606' ],
                  [ '新喀里多尼亚', '607' ],
                  [ '瓦努阿图', '608' ],
                  [ '新西兰', '609' ],
                  [ '诺福克岛', '610' ],
                  [ '巴布亚新几内亚', '611' ],
                  [ '社会群岛', '612' ],
                  [ '所罗门群岛', '613' ],
                  [ '汤加', '614' ],
                  [ '土阿莫土群岛', '615' ],
                  [ '土布艾群岛', '616' ],
                  [ '萨摩亚', '617' ],
                  [ '基里巴斯', '618' ],
                  [ '图瓦卢', '619' ],
                  [ '密克罗尼西亚', '620' ],
                  [ '马绍尔群岛', '621' ],
                  [ '帕劳', '622' ],
                  [ '法属波利尼西亚', '623' ],
                  [ '瓦利斯和浮图纳', '625' ],
                  [ '大洋洲其他', '699' ]
                ]
    else
      options = [ [ '请选择', nil ] ]
    end
  end

  # 根据区域代码获得区域名称
  def area_title(area_code)
    case area_code.length
    when 6
      options = options_of_area('china')
    when 3
      options = options_of_area('abroad')
    end
    for option in options
      if area_code == option[1]
        return option[0]
      end
    end
  end

  # 根据区域代码和子区域代码获得子区域名称
  def subarea_title(area_code, subarea_code)
    options = options_of_subarea(area_code)
    for option in options
      if subarea_code == option[1]
        return option[0]
      end
    end
  end

  # 生成常用的item过滤器SQL条件
  def common_filter_conditions(filter, item_type, someuser)
    db_table_name = controller_name(item_type)
    conditions = []
    case filter
    when 'published'
      conditions << "#{db_table_name}.is_draft = 0"
      conditions << "#{db_table_name}.published_at IS NOT NULL"
    when 'draft'
      conditions << "#{db_table_name}.is_draft = 1"
    when 'original'
      conditions << "#{db_table_name}.from_type = 1"
    when 'repaste'
      conditions << "#{db_table_name}.from_type = 2"
    when 'choice'
      conditions << "#{db_table_name}.roles LIKE '%11%'"
    end
    if filter.blank? || [ 'original', 'repaste', 'choiced' ].include?(filter)
      conditions << "#{db_table_name}.#{item_is_draft_condition(someuser)}" if !item_is_draft_condition(someuser).blank?
      conditions << "#{db_table_name}.#{item_privacy_condition(someuser)}"
    end
    conditions
  end

  # item的草稿/已发布属性的SQL条件
  def item_is_draft_condition(someuser = nil)
    if @current_user
      if someuser && someuser = @current_user
        condition = ''
      else
        condtion = "is_draft = 0"
      end
    else
      condition = "is_draft = 0"
    end
  end

  # item的隐私属性的SQL条件
  def item_privacy_condition(someuser = nil)
  	if @current_user
  		if someuser && someuser == @current_user
  			condition = "privacy <= 90"
  		else
  			condition = "privacy <= 11"
  		end
  	else
  		condition = "privacy <= 10"
  	end
  end
		
end
