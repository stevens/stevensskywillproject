class JudgesController < ApplicationController

#  before_filter :admin_protect
  before_filter :protect, :except => [:index, :show]

  def index
    load_judgein

    @item_for_bar = @judgein

    load_item_groups
    load_invited_judge_stats
    
    # show_sidebar

    judgein_type = type_for(@judgein)
    judgein_name = name_for(judgein_type)
    judgein_title = item_title(@judgein)
    judgein_username = user_username(@judgein.user, true, true)
    judges_link_url = "#{item_first_link(@judgein)}/judges"

    info = "特邀#{JUDGE_CN} - #{judgein_title}"
    set_page_title(info)
    set_block_title(info)
    @meta_description = "这是#{judgein_title}的#{judgein_name}特邀#{JUDGE_CN}信息, 来自#{judgein_username}."
    set_meta_keywords
    @meta_keywords = [ judgein_name, judgein_title, judgein_username, judges_link_url ] + @meta_keywords
    @meta_keywords << @judgein.tag_list if !@judgein.tag_list.blank?

    @show_user_description = true

    respond_to do |format|
      format.html
    end
  end

  def show

  end

  def new
  	respond_to do |format|
			format.js do
        judgein = Election.find_by_id(1)

        load_assigned_judges(@user, judgein)

        @judge = @user.judges.build

				render :update do |page|
		      page.replace_html "overlay",
		      									:partial => "judges/judge_overlay",
		      									:locals => { :user => @user,
		      															 :judge => @judge,
                                         :judgein => judgein,
                                         :assigned_judges => @assigned_judges, 
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
    @judge = @user.judges.build(params[:judge])

    unless @judge.duplicated?
      if @judge.save
        @notice = "你已经#{ADD_CN}了1#{UNIT_JUDGE_CN}#{JUDGE_CN}！"
        @user = @judge.user
        @judgein = @judge.judgein
        after_todo_ok('create')
      else
        @notice = "#{SORRY_CN}，#{ADD_CN}#{JUDGE_CN}失败，请重新#{ADD_CN}！"
        after_todo_error('create')
      end
    else
      @notice = "#{SORRY_CN}，同一#{JUDGE_CN}类别不可以重复#{ADD_CN}#{JUDGE_CN}，请选择其他#{JUDGE_CN}类别！"
      after_todo_error('create')
    end
  end

  def update

  end

  def destroy
		load_judge
    @user = @judge.user
    @judgein = @judge.judgein

    if @judge.destroy
      @notice = "你已经#{DELETE_CN}了1#{UNIT_JUDGE_CN}#{JUDGE_CN}！"
      after_todo_ok('destroy')
    end
  end

  private

  def set_meta_keywords
		@meta_keywords = [ JUDGE_CN, "特邀#{JUDGE_CN}" ]
	end

  def load_judge
    @judge = @user.judges.find(@self_id)
  end

  def load_judgein
    if %w[ Election ].include?(@parent_type)
      @judgein = @parent_obj
    end
  end

  def load_item_groups_cache_id
    @item_groups_cache_id = "#{type_for(@judgein).tableize.singularize}_#{@judgein.id}_judges_item_groups"
  end

  def load_item_groups
    load_item_groups_cache_id
    begin
      @item_groups = CACHE.get(@item_groups_cache_id)
    rescue Memcached::NotFound
      @item_groups = judge_groups(@judgein)
      CACHE.set(@item_groups_cache_id, @item_groups)
    end
  end

  def load_invited_judge_stats
    if @current_user && @current_user.is_role_of?('admin')
      @invited_judge_stats_groups = invited_judge_stats_groups(@judgein, invited_judge_stats(@judgein))
    end
  end

  def load_assigned_judges(user, judgein)
    @assigned_judges = user.judges.find(:all, :conditions => { :judgein_type => type_for(judgein), :judgein_id => judgein.id })
  end
  
  def after_todo_ok(name)
		respond_to do |format|
			format.js do
        load_assigned_judges(@user, @judgein)
        load_item_groups_cache_id
        cache_delete(@item_groups_cache_id)

				render :update do |page|
          page.replace_html "notice_for_judge",
                            :partial => 'layouts/notice',
                            :locals => { :notice => @notice }
          page.show "notice_for_judge"
          page.visual_effect :fade, "notice_for_judge", :duration => 1
          page.replace_html "assigned_judges",
                            :partial => 'judges/assigned_judges',
                            :locals => { :judges => @assigned_judges }
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
            page.replace_html "notice_for_judge",
															:partial => 'layouts/notice',
															:locals => { :notice => @notice }
						page.show "notice_for_judge"
            page.visual_effect :fade, "notice_for_judge", :duration => 1
          end
				end
			end
		end
  end
  
end
