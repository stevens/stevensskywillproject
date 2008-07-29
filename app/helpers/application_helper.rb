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
	
	def model_for(object_type)
		case object_type
		when 'user'
			User
		when 'recipe'
			Recipe
		when 'photo'
			Photo
		when 'review'
			Review
		end
	end
	
	def name_for(object_type)
		case object_type
		when 'user'
			USER_CN
		when 'recipe'
			RECIPE_CN
		when 'photo'
			PHOTO_CN
		when 'review'
			REVIEW_CN
		when 'tag'
			TAG_CN
		end	
	end
	
	def unit_for(object_type)
		case object_type
		when 'user'
			UNIT_USER_CN
		when 'recipe'
			UNIT_RECIPE_CN
		when 'photo'
			UNIT_PHOTO_CN
		when 'review'
			UNIT_REVIEW_CN
		end
	end
	
	def item_title(item_type, item)
		case item_type
		when 'user'
			item.login
		else
			item.title
		end
	end
	
	def item_url(item_type, item_id)
		"#{root_url}#{item_type.pluralize}/#{item_id}"
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
	
	def text_summary(text, summary_length)
		text.length > summary_length ? text.to(summary_length-1) + '......' : text
	end

	def text_squish(text)
		if text && text != ''
			text.strip.gsub(/\s+/, ' ')
		else
			nil
		end
	end
	
	def conditions_id(text)
		if text && text != ''
			text.gsub(' ', '+')
		else
			nil
		end
	end
	
	def conditions(text)
		if text && text != ''
			text.gsub('+', ' ')
		else
			nil
		end
	end
	
	def keywords(text)
		if text && text != ''
			text.split('+')
		else
			[]
		end
	end	
	
	def paragraphs(text)
		if text && text != ''
			ps = text.split(/\n/)
			1.upto(ps.size) do |i|
				ps[i-1] = "<li>#{h text_squish(ps[i-1])}</li>"
			end
			ps
		else
			[]
		end
	end
	
	def restfu_url_for(namespace, parent_obj, self_obj, action)
		ns = "#{namespace}/" if namespace
		po = "#{parent_obj[:type].pluralize}/#{parent_obj[:id]}/" if parent_obj && parent_obj[:type] && parent_obj[:id]
		if self_obj
			if self_obj[:type]
				if self_obj[:id]
					so = "#{self_obj[:type].pluralize}/#{self_obj[:id]}"
				else
					so = "#{self_obj[:type].pluralize}"
				end
			end
		end
		ac = "/#{action}" if action
		"#{root_url}#{ns}#{po}#{so}#{ac}"
	end
	
	def tagged_items(user, item_type, tag, order)
		if user
			model_for(item_type).find_tagged_with(tag, :order => order, :conditions => {:user_id => user.id})
		else
			model_for(item_type).find_tagged_with(tag, :order => order)
		end
	end
	
	#---------------------------------------------------------------------------------------
	def sysinfo(code, todo, belong_to, option, object)
		case code
		
		# Notice 1xxxxx
		when '100001'  # e.g 你已经成功创建了1个新食谱!
			"#{YOU_CN}已经成功#{todo}了#{object[:count]}#{object[:unit]}#{option}#{object[:type]}!"
		when '100002'  # e.g 你输入的食谱信息有错误，请重新输入!
			"#{YOU_CN}#{todo}的#{object[:type]}#{INFO_CN}有#{ERROR_CN}, 请#{REDO_CN}#{todo}!"
		when '100003'  # e.g 你确定要删除这个食谱吗？
			if object[:count] == 1
				"#{YOU_CN}确定要#{todo}这#{object[:unit]}#{object[:type]}吗?"
			else
				"#{YOU_CN}确定要#{todo}这#{object[:count]}#{object[:unit]}#{object[:type]}吗?"
			end
		when '100004'  # e.g 请你先登录厨猫！
			"请#{YOU_CN}先#{todo}#{object[:type]}!"
		when '100005'
			"#{YOU_CN}#{HAS_NO_CN}#{object[:type]}, 现在就来#{todo}#{YOUR_CN}第一#{object[:unit]}#{object[:type]}吧!"
		
		# Error 2xxxxx
		when '200001'
		
		# Guide 3xxxxx
		when '300001'
			"#{todo}#{option}#{object[:type]}"
		when '300002'
			"#{todo}#{belong_to[:type]}#{belong_to[:title]}的#{option}#{object[:type]}"
		when '300003'
			if object[:count] == 1
				"#{todo}这#{object[:unit]}#{option}#{object[:type]}"
			else
				"#{todo}这#{object[:count]}#{object[:unit]}#{option}#{object[:type]}"
			end
		when '300004'
			if object[:count] == 1
				"#{todo}#{belong_to[:type]}#{belong_to[:title]}的这#{object[:unit]}#{option}#{object[:type]}"		
			else
				"#{todo}#{belong_to[:type]}#{belong_to[:title]}的这#{object[:count]}#{object[:unit]}#{option}#{object[:type]}"		
			end
		when '300005'
			if object[:title]
				"#{todo}#{option}#{object[:type]}: #{object[:title]}"
			elsif object[:count] >= 0
				"#{todo}#{option}#{object[:type]}(#{object[:count]})"
			end
		when '300006'
			if object[:title]
				"#{todo}#{belong_to[:type]}#{belong_to[:title]}的#{option}#{object[:type]}: #{object[:title]}"
			elsif object[:count] >= 0
				"#{todo}#{belong_to[:type]}#{belong_to[:title]}的#{option}#{object[:type]}(#{object[:count]})"
			end
		when '300007'
			"#{I_CN}先#{todo}#{belong_to[:type]}#{belong_to[:title]}的#{option}#{object[:type]}"
		when '300008'
			if object[:count] == 1
				"这#{object[:unit]}#{object[:type]}是#{belong_to[:type]}#{belong_to[:title]}的#{option}"
			else
				"这#{object[:count]}#{object[:unit]}#{object[:type]}是#{belong_to[:type]}#{belong_to[:title]}的#{option}"
			end
		when '300009'
			if object[:count] == 1
				"用这#{object[:unit]}#{object[:type]}#{todo}#{belong_to[:type]}#{belong_to[:title]}的#{option}"
			else
				"用这#{object[:count]}#{object[:unit]}#{object[:type]}#{todo}#{belong_to[:type]}#{belong_to[:title]}的#{option}"
			end
		end
	end
	
end
