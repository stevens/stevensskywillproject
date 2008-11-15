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
	
	def unit_for(obj_type)
		"UNIT_#{obj_type.upcase}_CN".constantize
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
	
	def item_id(item)
		id_for(type_for(item))
	end
	
	def controller_name(obj_type)
		obj_type.downcase.pluralize
	end
	
	def item_username(item)
		if @current_user && item.user == @current_user
		 '我'
		else
			item.user.login
		end
	end
	
	def itemname_suffix(item)
		if item
			" < #{item_title(item)}"
		else
			nil
		end
	end
	
	def item_html_id(item_type, item_id = nil)
		if item_id
			"#{item_type.downcase}_#{item_id}"
		else
			item_type.downcase
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
	
	def item_title(item)
		case type_for(item)
		when 'User'
			user_username(item)
		else
			item.title
		end
	end
	
	def item_url(item_type, item_id)
		"#{root_url}#{item_type.pluralize}/#{item_id}"
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
	
	def time_iso_format(time)
		time.strftime("%Y-%m-%d %H:%M:%S")
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
		text.chars.length > min_length ? text.to(min_length-1) + '......' : text
	end
	
	def str_squish(str, space_count = 1)
		space = ''
		1.upto(space_count) do
			space += '&nbsp;'
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
	
	def paragraphs(text, keep_space = false, space_count = 1, min_paras_count = nil)
		paragraphs = []
		if text && !text.blank?
			ps = text.split(/\n/)
			for p in ps
				if keep_space
					p = str_keep_space(p)
				else
					p = str_squish(p, space_count)
				end
				if !p.blank?
					paragraphs << "<li>#{strip_tags(p)}</li>"
				end
			end
		end
		if min_paras_count && paragraphs.size > min_paras_count
			paragraphs[0..min_paras_count-1] + ["<li>......</li>"]
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
	def f(i, n=2, flag=1)
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
		
end
