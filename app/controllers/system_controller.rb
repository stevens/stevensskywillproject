class SystemController < ApplicationController

  before_filter :protect, :only => :site_stats

  # 图片关联photoable的子项
  def photo_relating_subitem
  	respond_to do |format|
			format.js do
				render :update do |page|
          if params[:photoable_type] == 'menu' && params[:photo_type] == '11'
            page.show "photo_related_subitem_text"
            page.show "photo_related_subitem_input"
          else
            page.hide "photo_related_subitem_text"
            page.hide "photo_related_subitem_input"
          end
				end
			end
  	end
  end

  # 对item的发布
  def publish
    @publishable_type = params[:publishable_type].camelize
    @publishable_id = params[:publishable_id]
    @publishable = model_for(@publishable_type).find_by_id(@publishable_id)
    publishable_name = name_for(@publishable_type)
    publishable_unit = unit_for(@publishable_type)
    
		if @publishable && item_manageable?(@publishable) && @publishable.publishable?
			current = Time.now
			new_attrs = { :is_draft => '0', :published_at => current, :original_updated_at => current }
			@notice = "你已经发布了1#{publishable_unit}#{publishable_name}!"

			if @publishable.update_attributes(new_attrs)
				reg_homepage(@publishable, 'update')
				after_publish_ok
			end
		end
  end

  # 对item的加为精选和删除精选
	def choice
		if @current_user && @current_user.is_role_of?('admin')
      @choiceable_type = params[:choiceable_type].camelize
      @choiceable_id = params[:choiceable_id]
      @choiceable = model_for(@choiceable_type).find_by_id(@choiceable_id)
      choiceable_name = name_for(@choiceable_type)
      choiceable_unit = unit_for(@choiceable_type)
      
      if @choiceable
        respond_to do |format|
          format.html do
            current_roles = @choiceable.roles || ''

            if params[:to_choice]
              new_roles = current_roles.gsub('11', '') + ' 11'
              @notice = "你已经将1#{choiceable_unit}#{choiceable_name}加为精选#{choiceable_name}了!"
            else
              new_roles = current_roles.gsub('11', '')
              @notice = "你已经将1#{choiceable_unit}#{choiceable_name}从精选#{choiceable_name}中#{DELETE_CN}了!"
            end

            new_roles = new_roles.strip.gsub(/\s+/, ' ')

            if @choiceable.update_attribute(:roles, new_roles)
              after_choice_ok
            end
          end
        end
      end
		end
	end

  # 联动更新子区域下拉列表的选项
  def update_options_of_subarea
  	respond_to do |format|
			format.js do
				render :update do |page|
          page.replace "#{params[:area_for]}_place_subarea",
                       :partial => 'layouts/subarea_select',
                       :locals => { :area_for => params[:area_for], 
                                    :area => params[:area] }
				end
			end
  	end
	end

  # 更改item的来源后的处理
	def change_from_type
  	respond_to do |format|
			format.js do
				render :update do |page|
					if params[:from_type] == '1'
						page.hide "from_where_wrapper"
						page.hide "from_where_errors"
						page.replace_html "from_where_wrapper",
															:partial => 'layouts/item_from_where',
                              :locals => { :item_type => params[:item_type] }
					else
						page.replace_html "from_where_wrapper",
															:partial => 'layouts/item_from_where',
                              :locals => { :item_type => params[:item_type] }
						page.show "from_where_wrapper"
					end
				end
			end
  	end
	end

	def index
		@page_title = "#{SITE_NAME_CN} | 系统维护中......"
	end

  # 网站指标数据统计
  def site_stats
    span_type = params[:type]

    current = Time.now
    range = params[:range].split('-')
    range_start = range[0].to_time.getlocal.beginning_of_day
    range_end = range[1].to_time.getlocal.end_of_day < current.end_of_day ? range[1].to_time.getlocal.end_of_day : current.end_of_day

    @site_stats_set = []
    phase_start = range_start
    until phase_start > range_end do
      phase_end = phase_end(span_type, phase_start) < range_end ? phase_end(span_type, phase_start) : range_end
      phase_metrics = site_metrics(phase_start, phase_end)
      @site_stats_set << [ { :phase_start => phase_start, :phase_end => phase_end }, phase_metrics ]
      phase_start = phase_end + 1
    end

    range_metrics = site_metrics(range_start, range_end)
    @site_stats_set << [ { :phase_start => range_start, :phase_end => range_end }, range_metrics ]
    
    info = "网站指标（#{span_title(span_type)}）数据统计"
    set_page_title(info)
		set_block_title(info)
  end

  private

  def after_choice_ok
  	respond_to do |format|
  		format.js do
  			render :update do |page|
					page.replace_html "flash_wrapper",
														:partial => "layouts/flash",
														:locals => { :notice => @notice }
					page.replace_html "#{@choiceable_type.downcase}_#{@choiceable_id}_title",
														:partial => "layouts/item_basic",
														:locals => { :item => @choiceable,
								 												 :show_icon => true,
								 												 :show_title => true,
								 												 :show_link => true }
					page.replace_html "#{@choiceable_type.downcase}_#{@choiceable_id}_admin",
														:partial => "system/item_admin_bar",
														:locals => { :item => @choiceable,
									 											 :ref => 'show' }
  			end
  		end
  	end
  end

  def after_publish_ok
  	respond_to do |format|
#  		format.html do
#  			flash[:notice] = @notice
#  			redirect_back_or_default('mine')
#  		end
			format.js do
				render :update do |page|
          publishable_type = params[:publishable_type]
          publishable_id = params[:publishable_id]
          publishable_controller_name = controller_name(publishable_type.camelize)
					case params[:ref]
					when 'show'
						page.replace_html "flash_wrapper",
															:partial => "layouts/flash",
															:locals => { :notice => @notice }
						page.replace_html "#{publishable_type}_#{publishable_id}_title",
															:partial => "layouts/item_basic",
															:locals => { :item => @publishable,
									 												 :show_icon => true,
									 												 :show_title => true,
									 												 :show_link => true }
						page.replace_html "#{publishable_type}_#{publishable_id}_manage",
															:partial => "#{publishable_controller_name}/#{publishable_type}_manage",
															:locals => { :item => @publishable,
										 											 :ref => 'show' }
					when 'index'
		  			flash[:notice] = @notice
		  			page.redirect_to :controller => publishable_controller_name , :action => 'mine', :filter => params[:filter]
					end
				end
			end
  	end
  end

end
