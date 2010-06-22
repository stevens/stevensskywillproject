class ElectWinnersController < ApplicationController

  before_filter :preload_models
#  before_filter :admin_protect
  before_filter :protect, :except => [:index, :show]

  def index
    load_winnerin

    @item_for_bar = @winnerin

    load_item_groups

    @winner_published_at = '今天晚上'

    # show_sidebar

    winnerin_type = type_for(@winnerin)
    winnerin_name = name_for(winnerin_type)
    winnerin_title = item_title(@winnerin)
    winnerin_username = user_username(@winnerin.user, true, true)
    elect_winners_link_url = "#{item_first_link(@winnerin)}/elect_winners"

    info = "#{ELECTWINNER_CN}名单 - #{winnerin_title}"
    set_page_title(info)
    set_block_title(info)
    @meta_description = "这是#{winnerin_title}的#{winnerin_name}#{ELECTWINNER_CN}名单, 来自#{winnerin_username}."
    set_meta_keywords
    @meta_keywords = [ winnerin_name, winnerin_title, winnerin_username, elect_winners_link_url ] + @meta_keywords
    @meta_keywords << @winnerin.tag_list if !@winnerin.tag_list.blank?

    respond_to do |format|
      format.html
    end
  end

  def show

  end

  def new

  end

  def edit

  end

  def create

  end

  def update
    @edit_speech = params[:edit_speech]
    @winner = @user.winner_users.find_by_id(@self_id)
    if @edit_speech
      if @winner.update_attribute('speech', params[:elect_winner][:speech])
        after_todo_ok('update')
      else
        after_todo_error('update')
      end
    end
  end

  def destroy

  end

  def edit_speech
  	respond_to do |format|
			format.js do
        user = User.find_by_id(params[:user_id])
        winner = user.winner_users.find_by_id(params[:id])

				render :update do |page|
		      page.replace_html "overlay",
		      									:partial => "elect_winners/edit_speech_overlay",
		      									:locals => { :user => user,
                                         :winner => winner }
					page.show "overlay"
				end
			end
  	end
  end

  private

  def preload_models()
    ElectAward
    Recipe
    User
  end

  def set_meta_keywords
		@meta_keywords = [ '获奖','获奖者', '获奖作品' ]
	end

  def load_winners
    @winner = @parent_obj.winners.find(@self_id)
  end

  def load_winnerin
    if %w[ Election ].include?(@parent_type)
      @winnerin = @parent_obj
    end
  end

  def load_item_groups_cache_id
    @item_groups_cache_id = "#{type_for(@winnerin).tableize.singularize}_#{@winnerin.id}_elect_winners_item_groups"
  end

  def load_item_groups
    load_item_groups_cache_id
    begin
      @item_groups = CACHE.get(@item_groups_cache_id)
    rescue Memcached::NotFound
      @item_groups = elect_winner_groups(@winnerin)
      CACHE.set(@item_groups_cache_id, @item_groups)
    end
  end

  def after_todo_ok(name)
    notice = "你已经成功发表了获奖感言！"
    respond_to do |format|
      if @edit_speech
        format.js do
          render :update do |page|
			  		page.hide "overlay" if name != 'destroy'            
						page.replace_html "flash_wrapper",
															:partial => 'layouts/flash',
													 		:locals => { :notice => notice }
						page.show "flash_wrapper"
            page.replace_html "winner_speech",
                              :partial => 'elect_winners/speech',
                              :locals => { :winner => @winner }
            page.visual_effect :highlight, "winner_speech", :duration => 3
          end
        end
      end
    end
  end

  def after_todo_error(name)
    notice = "#{SORRY_CN}，你#{INPUT_CN}的获奖感言有#{ERROR_CN}，请重新#{INPUT_CN}！"
    respond_to do |format|
      if @edit_speech
        format.js do
          render :update do |page|
            page.replace_html "notice_for_winner",
                              :partial => 'layouts/notice',
                              :locals => { :notice => notice }
            page.show "notice_for_winner"
            page.visual_effect :fade, "notice_for_winner", :duration => 1
          end
        end
      end
    end
  end

end
