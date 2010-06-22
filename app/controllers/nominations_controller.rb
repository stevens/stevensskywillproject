class NominationsController < ApplicationController

  before_filter :preload_models
#  before_filter :admin_protect
  before_filter :protect, :except => [:index, :show]

  def index
    load_nominatein

    @item_for_bar = @nominatein

    load_item_groups
    load_ballots(@current_user, 'ElectAward') if @current_user

    @nomination_published_at = '今晚21点'

    # show_sidebar

    nominatein_type = type_for(@nominatein)
    nominatein_name = name_for(nominatein_type)
    nominatein_title = item_title(@nominatein)
    nominatein_username = user_username(@nominatein.user, true, true)
    nominations_link_url = "#{item_first_link(@nominatein)}/nominations"

    info = "#{NOMINATION_CN}名单 - #{nominatein_title}"
    set_page_title(info)
    set_block_title(info)
    @meta_description = "这是#{nominatein_title}的#{nominatein_name}#{NOMINATION_CN}名单, 来自#{nominatein_username}."
    set_meta_keywords
    @meta_keywords = [ nominatein_name, nominatein_title, nominatein_username, nominations_link_url ] + @meta_keywords
    @meta_keywords << @nominatein.tag_list if !@nominatein.tag_list.blank?

    respond_to do |format|
      format.html do
        if !params[:group_by].blank? && @current_user && @current_user.is_role_of?('admin')
          render :template => "nominations/index_gb_#{params[:group_by]}"
        else
          render :template => 'nominations/index'
        end
      end
    end
  end

  def show

  end

  def new
  	respond_to do |format|
			format.js do
        nominateable = @parent_obj
        nominateby = @current_user
        nominatein = Election.find_by_id(1)
        nominatefor_type = 'ElectAward'

        load_nominateds(nominateable, nominateby, nominatein, nominatefor_type)

        @nomination = nominateable.nominations.build

				render :update do |page|
		      page.replace_html "overlay",
		      									:partial => "nominations/nomination_overlay",
		      									:locals => { :nominateable => nominateable,
		      															 :nomination => @nomination,
                                         :nominatein => nominatein,
                                         :nominatefor_type => nominatefor_type,
                                         :nominateby => nominateby,
                                         :nominateds => @nominateds,
		      															 :filter => params[:filter],
		      															 :ref => params[:ref] }
					page.show "overlay"
				end
			end
  	end
  end

  def edit

  end

  def create
    @nomination = @parent_obj.nominations.build(params[:nomination])

    unless @nomination.duplicated?
      if @nomination.save
        @notice = "你已经#{ADD_CN}了1项#{@parent_name}#{NOMINATION_CN}！"
        @nominateable = @nomination.nominateable
        @nominateby = @nomination.nominateby
        @nominatein = @nomination.nominatein
        @nominatefor_type = @nomination.nominatefor_type
        after_todo_ok('create')
      else
        @notice = "#{SORRY_CN}，#{ADD_CN}#{@parent_name}#{NOMINATION_CN}失败，请重新#{ADD_CN}！"
        after_todo_error('create')
      end
    else
      @notice = "#{SORRY_CN}，同一#{AWARD_CN}不可以重复#{ADD_CN}#{NOMINATION_CN}，请选择其他#{AWARD_CN}！"
      after_todo_error('create')
    end
  end

  def update

  end

  def destroy
		load_nomination
    @nominateable = @nomination.nominateable
    @nominateby = @nomination.nominateby
    @nominatein = @nomination.nominatein
    @nominatefor_type = @nomination.nominatefor_type

    if @nomination.destroy
      @notice = "你已经#{DELETE_CN}了1项#{@parent_name}#{NOMINATION_CN}！"
      after_todo_ok('destroy')
    end
  end

  private

  def preload_models()
    ElectAward
    Recipe
    User
  end

  def set_meta_keywords
		@meta_keywords = [ NOMINATION_CN ]
	end

  def load_nomination
    @nomination = @parent_obj.nominations.find(@self_id)
  end

  def load_nominatein
    if %w[ Election ].include?(@parent_type)
      @nominatein = @parent_obj
    end
  end

  def load_item_groups_cache_id(group_by = nil)
    @item_groups_cache_id = "#{type_for(@nominatein).tableize.singularize}_#{@nominatein.id}_nominations_item_groups"
    @item_groups_cache_id += "_gb_#{group_by}" if !group_by.blank?
  end

  def load_item_groups
    load_item_groups_cache_id(params[:group_by])
    begin
      @item_groups = CACHE.get(@item_groups_cache_id)
    rescue Memcached::NotFound
      @item_groups = nomination_groups(@nominatein, { :group_by => params[:group_by] } )
      CACHE.set(@item_groups_cache_id, @item_groups)
    end
  end

  def load_ballots(user, ballotfor_type)
    @ballots = @nominatein.ballots.find(:all, :conditions => { :user_id => user.id, :ballotfor_type => ballotfor_type }, :order => 'ballotfor_id')

  end

  def load_nominateds(nominateable, nominateby, nominatein, nominatefor_type)
    @nominateds = nominateable.nominations.find(:all, :conditions => { :nominateby_type => type_for(nominateby), :nominateby_id => nominateby.id,
                                                                      :nominatein_type => type_for(nominatein), :nominatein_id => nominatein.id,
                                                                      :nominatefor_type => nominatefor_type })
  end

  def after_todo_ok(name)
		respond_to do |format|
			format.js do
        load_nominateds(@nominateable, @nominateby, @nominatein, @nominatefor_type)
        load_item_groups_cache_id
        cache_delete(@item_groups_cache_id)

				render :update do |page|
          page.replace_html "notice_for_nomination",
                            :partial => 'layouts/notice',
                            :locals => { :notice => @notice }
          page.show "notice_for_nomination"
          page.visual_effect :fade, "notice_for_nomination", :duration => 1
          page.replace_html "nomination_nominateds",
                            :partial => 'nominations/nomination_nominateds',
                            :locals => { :nominateds => @nominateds }
				end
			end
		end
  end

  def after_todo_error(name)
		respond_to do |format|
			format.js do
				render :update do |page|
          case name
          when 'create'
            page.replace_html "notice_for_nomination",
															:partial => 'layouts/notice',
															:locals => { :notice => @notice }
            page.show "notice_for_nomination"
            page.visual_effect :fade, "notice_for_nomination", :duration => 1
          end
				end
			end
		end
  end

end
