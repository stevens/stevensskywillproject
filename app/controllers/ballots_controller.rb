class BallotsController < ApplicationController

#  before_filter :preload_models
  before_filter :admin_protect, :only => [:index]
  before_filter :protect

  def index
    @ballotin = @parent_obj

    @item_for_bar = @ballotin

    load_judge_user_groups if params[:group_by].blank?
    load_item_groups
    
    ballotin_type = type_for(@ballotin)
    ballotin_name = name_for(ballotin_type)
    ballotin_title = item_title(@ballotin)

    info = "#{BALLOT_CN}管理 - #{ballotin_title}"
    set_page_title(info)
    set_block_title(info)

    respond_to do |format|
      format.html do
        if !params[:group_by].blank? && @current_user && @current_user.is_role_of?('admin')
          render :template => "ballots/index_gb_#{params[:group_by]}"
        else
          render :template => 'ballots/index'
        end
      end
    end
  end
  
  def new
  	respond_to do |format|
			format.js do
        load_ballotby
        load_ballotin
        load_ballotfor
        @ballot = @ballotby.ballots.build
        show_input('new')
			end
  	end
  end

  def edit
  	respond_to do |format|
			format.js do
        load_ballotby
        load_ballot
        show_input('edit')
			end
  	end
  end

  def create
    load_ballotby
    @ballot = @ballotby.ballots.build(params[:ballot])
    item_client_ip(@ballot)

    do_input('create')
  end

  def update
    load_ballotby
    load_ballot
    @ballot.ballot_content = params[:ballot][:ballot_content]
    @ballot.remark = params[:ballot][:remark]
    do_input('update')
  end

  private

#  def preload_models()
#
#  end

  def show_input(name)
    load_ballotables
    load_html_id
    
    render :update do |page|
      page.hide "#{@html_id}_show"
      page.hide "#{@html_id}_todo_bar"
      page.replace_html "#{@html_id}_ballot",
                        :partial => 'ballots/ballot_input',
                        :locals => { :ballot => @ballot, :user => @ballotby, :ballotin => @ballotin, :ballotfor => @ballotfor, :ballotables => @ballotables, :html_id => @html_id}
      page.show "#{@html_id}_ballot"
      page.redirect_to "##{@html_id}_wrapper"
    end
  end

  def do_input(name)
    load_html_id
    unless @ballot.ballot_content.blank?
      unless name == 'create' && @ballot.duplicated?
        if @ballot.save
          load_ballotables
          @notice = "你已经提交了1#{UNIT_BALLOT_CN}#{BALLOT_CN}，谢谢！"
          after_todo_ok(name)
        else
          @notice = "#{SORRY_CN}，#{VOTE_CN}失败，请重新#{VOTE_CN}！"
          after_todo_error(name)
        end
      else
        @notice = "#{SORRY_CN}，同一#{AWARD_CN}不可以重复#{VOTE_CN}！"
        after_todo_error(name)
      end
    else
      @notice = "#{SORRY_CN}，请问你要将选票投给谁？"
      after_todo_error(name)
    end
  end

  def load_ballot
    @ballot = @ballotby.ballots.find(@self_id) if @ballotby
  end

  def load_ballotby
    @ballotby = @user if @user && @current_user && @user = @current_user
  end

  def load_ballotin
    @ballotin = model_for(params[:ballotin_type]).find_by_id(params[:ballotin_id])
  end

  def load_ballotfor
    @ballotfor = model_for(params[:ballotfor_type]).find_by_id(params[:ballotfor_id])
  end

  def load_ballotables
    ballotable_ids = params[:ballotable_ids].split(',')
    ballotable_model = model_for(params[:ballotable_type])
    @ballotables = []
    for ballotable_id in ballotable_ids
      @ballotables << ballotable_model.find_by_id(ballotable_id)
    end
  end

  def load_html_id
    @html_id = params[:html_id]
  end

  def load_judge_user_groups
    @judge_user_groups = judge_user_groups(@ballotin)
  end

#  def load_item_groups_cache_id(group_by = nil)
#    @item_groups_cache_id = "#{type_for(@ballotin).tableize.singularize}_#{@ballotin.id}_ballots_item_groups"
#    @item_groups_cache_id += "_gb_#{group_by}" if !group_by.blank?
#  end
#
#  def load_item_groups
#    load_item_groups_cache_id(params[:group_by])
#    begin
#      @item_groups = CACHE.get(@item_groups_cache_id)
#    rescue Memcached::NotFound
#      @item_groups = ballot_groups(@ballotin, @judge_user_groups, { :group_by => params[:group_by] } )
#      CACHE.set(@item_groups_cache_id, @item_groups)
#    end
#  end

  def load_item_groups
    @item_groups = ballot_groups(@ballotin, @judge_user_groups, { :group_by => params[:group_by] } )
  end

  def after_todo_ok(name)
		respond_to do |format|
			format.js do
				render :update do |page|
          page.replace_html "#{@html_id}_notice",
                            :partial => 'layouts/notice',
                            :locals => { :notice => @notice }
          page.show "#{@html_id}_notice"
          page.hide "#{@html_id}_ballot"
          page.show "#{@html_id}_show"
          page.replace_html "#{@html_id}_todo_bar",
                            :partial => 'nominations/nominations_todo_bar',
                            :locals => { :nominatein => @ballot.ballotin,
                                        :nominatefor => @ballot.ballotfor,
                                        :nominateables => @ballotables,
                                        :user => @ballotby,
                                        :ballots => [@ballot],
                                        :options => { :html_id => @html_id }}
          page.show "#{@html_id}_todo_bar"
          page.visual_effect :fade, "#{@html_id}_notice", :duration => 3
          page.redirect_to "##{@html_id}_wrapper"
				end
			end
		end
  end

  def after_todo_error(name)
		respond_to do |format|
			format.js do
				render :update do |page|
          page.replace_html "#{@html_id}_notice",
                            :partial => 'layouts/notice',
                            :locals => { :notice => @notice }
          page.show "#{@html_id}_notice"
          page.visual_effect :fade, "#{@html_id}_notice", :duration => 3
          page.redirect_to "##{@html_id}_wrapper"
				end
			end
		end
  end

end
