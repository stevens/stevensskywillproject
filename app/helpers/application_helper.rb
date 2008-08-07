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
		object_type.camelize.constantize
		rescue NameError
			nil
	end
	
	def name_for(object_type)
		"#{object_type.upcase}_CN".constantize
		rescue NameError
			nil
	end
	
	def unit_for(object_type)
		"UNIT_#{object_type.upcase}_CN".constantize
		rescue NameError
			nil
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
	
end
