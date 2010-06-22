class ProfilesController < ApplicationController

  before_filter :protect

  def new
    unless @current_user.profile
      @profile = Profile.new

      info = "档案#{SETTING_CN}"
      set_page_title(info)
      set_block_title(info)

      @meta_description = "这是档案#{SETTING_CN}的界面，通过这个界面可以在#{SITE_NAME_CN}编辑和修改用户档案信息。"

      respond_to do |format|
        format.html
      end
    end
  end

  def edit
    if profile = @current_user.profile
      @profile = profile if profile == Profile.find_by_id(@self_id)

      info = "档案#{SETTING_CN}"
      set_page_title(info)
      set_block_title(info)

      @meta_description = "这是档案#{SETTING_CN}的界面，通过这个界面可以在#{SITE_NAME_CN}编辑和修改用户档案信息。"

      respond_to do |format|
        format.html
      end
    end
  end

  def create
    @edit_info = params[:edit_info]
    @profile = Profile.new(params[:profile])
    unless @edit_info
      @profile.user = @current_user
      @profile.taobao = str_squish(params[:profile][:taobao], 0, false)
      perform_validation = true
    end
    @profile.blog = url_without_protocol(params[:profile][:blog])
    item_client_ip(@profile)

    if @profile.save(perform_validation)
      after_todo_ok('create')
    else
      after_todo_error('create')
    end
  end

  def update
    @edit_info = params[:edit_info]
    @profile = Profile.find(params[:id])
    unless @edit_info
      params[:profile][:taobao] = str_squish(params[:profile][:taobao], 0, false)
    end
    params[:profile][:blog] = url_without_protocol(params[:profile][:blog])

    if @edit_info
      @profile.blog = params[:profile][:blog]
      @profile.description = params[:profile][:description]
      @profile.any_else = params[:profile][:any_else]
      if @profile.save(false)
        after_todo_ok('update')
      else
        after_todo_error('update')
      end
    else
      if @profile.update_attributes(params[:profile])
        after_todo_ok('update')
      else
        after_todo_error('update')
      end
    end
  end

  def edit_info #编辑用户档案中的描述信息
  	respond_to do |format|
			format.js do
        user = User.find_by_id(params[:user_id])
        profile = user.profile || Profile.new

				render :update do |page|
		      page.replace_html "overlay",
		      									:partial => "profiles/edit_info_overlay",
		      									:locals => { :user => user,
                                         :profile => profile }
					page.show "overlay"
				end
			end
  	end
  end

  private

  def after_todo_ok(name)
    notice = "你已经成功设置了档案信息！"
    respond_to do |format|
      if @edit_info
        format.js do
          render :update do |page|
            page.replace_html "notice_for_profile",
                              :partial => 'layouts/notice',
                              :locals => { :notice => notice }
            page.show "notice_for_profile"
            page.visual_effect :fade, "notice_for_profile", :duration => 1
            user = Profile.find_by_id(@profile.id).user
            page.replace_html "input_form_for_profile",
                              :partial => 'profiles/info_input',
                              :locals => { :user => user,
                                          :profile => user.profile }
          end
        end
      else
        format.html do
          flash[:notice] = notice
          redirect_to "/profiles/#{@profile.id}/edit"
        end
      end
    end
  end

  def after_todo_error(name)
    notice = "#{SORRY_CN}，你#{INPUT_CN}的档案信息有#{ERROR_CN}，请重新#{INPUT_CN}！"
    respond_to do |format|
      if @edit_info
        format.js do
          render :update do |page|
            page.replace_html "notice_for_profile",
                              :partial => 'layouts/notice',
                              :locals => { :notice => notice }
            page.show "notice_for_profile"
            page.visual_effect :fade, "notice_for_profile", :duration => 1
          end
        end
      else
        format.html do
          info = "档案#{SETTING_CN}"
          set_page_title(info)
          set_block_title(info)

          flash[:notice] = notice

          case name
          when 'create'
            render :action => 'new'
          when 'update'
            render :action => 'edit'
          end

          clear_notice
        end
      end
    end
  end

end
