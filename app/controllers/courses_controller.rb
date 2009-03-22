class CoursesController < ApplicationController

  before_filter :protect, :except => [:index, :show]
	before_filter :store_location, :only => [:index, :show, :mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show]

  def index
    if @parent_obj.accessible?(@current_user)
      load_courses_set

      @show_todo = true
      @show_manage = true

#      if item_manageable?(@parent_obj)
#        @show_photo_todo = true
#      end

      info = "#{name_for(@parent_type)}#{COURSE_CN}#{itemname_suffix(@parent_obj)}"
      set_page_title(info)
      set_block_title(info)

      respond_to do |format|
        format.html
        # format.xml  { render :xml => @courses_set }
      end
    end
  end

  def new
    if @parent_obj.accessible?(@current_user) && item_manageable?(@parent_obj)
      @course = @parent_obj.courses.build

      info = "新#{name_for(@parent_type)}#{COURSE_CN}#{itemname_suffix(@parent_obj)}"
      set_page_title(info)
      set_block_title(info)

      respond_to do |format|
        format.html
        # format.xml  { render :xml => @course }
      end
    end
  end

  def edit
    if @parent_obj.accessible?(@current_user) && item_manageable?(@parent_obj)
      load_course(@current_user)

      if score = @course.score
        params[:score_taste] = score.taste
        params[:score_shape] = score.shape
        params[:score_creative] = score.creative
        params[:score_nutrition] = score.nutrition
        params[:score_cost_performance] = score.cost_performance
      end

      info = "#{EDIT_CN}#{name_for(@parent_type)}#{COURSE_CN} - #{item_title(@course)}"
      set_page_title(info)
      set_block_title(info)

      respond_to do |format|
        format.html
      end
    end
  end

  def create
    if @parent_obj.accessible?(@current_user) && item_manageable?(@parent_obj)
      set_tag_list

      @course = @parent_obj.courses.build(params[:course])
      @course.user_id = @current_user.id
      item_client_ip(@course)

      ActiveRecord::Base.transaction do
        if @course.save
#				reg_homepage(@course)
          @score = @current_user.scores.build
          set_score
          if @score.update_attributes(params[:score])
            after_create_ok
          else
            after_create_error
          end
        else
          after_create_error
        end
  		end
    end
  end

  def update
    if @parent_obj.accessible?(@current_user) && item_manageable?(@parent_obj)
      load_course(@current_user)
      params[:course][:original_updated_at] = Time.now

      set_tag_list

      ActiveRecord::Base.transaction do
        if @course.update_attributes(params[:course])
  #				reg_homepage(@menu, 'update')
          @score = @course.score ? @course.score : @current_user.scores.build
          set_score
          if @score.update_attributes(params[:score])
            after_update_ok
          else
            after_update_error
          end
        else
          after_update_error
        end
  	  end
    end
  end

  def destroy
    if @parent_obj.accessible?(@current_user) && item_manageable?(@parent_obj)
      load_course(@current_user)

  #    ActiveRecord::Base.transaction do
        if @course.destroy
  #        reg_homepage(@menu, 'destroy')
          after_destroy_ok
        end
  #    end
    end
  end

  private

  def set_score
    @score.user_id = @current_user.id
    @score.scoreable_type = 'Course'
    @score.scoreable_id = @course.id
    @score.taste = params[:score_taste]
    @score.shape = params[:score_shape]
    @score.creative = params[:score_creative]
    @score.nutrition = params[:score_nutrition]
    @score.cost_performance = params[:score_cost_performance]
  end

  def set_tag_list
    if !params[:course][:tag_list].strip.blank?
    	params[:course][:tag_list] = clean_tags(params[:course][:tag_list])
    end
  end

  def load_course(user = nil)
  	if user
 			@course = @parent_obj.courses.find_by_user_id_and_id(user.id, @self_id)
 		else
 			@course = @parent_obj.courses.find_by_id(@self_id)
 		end
  end

  def load_courses_set
    @courses_set = @parent_obj.courses.find(:all, :order => 'course_type, created_at')
    @courses_set_count = @courses_set.size
  end

  def after_create_ok
  	respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{ADD_CN}了1#{@self_unit}新#{@self_name}!"
				redirect_to :action => 'index'
			end
			# format.xml  { render :xml => @course, :status => :created, :location => @course }
		end
  end

  def after_create_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"

				info = "新#{name_for(@parent_type)}#{COURSE_CN}#{itemname_suffix(@parent_obj)}"
				set_page_title(info)
				set_block_title(info)

				render :action => "new"
				clear_notice
			end
			# format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
		end
  end

  def after_update_ok
  	respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"
#				redirect_to [@parent_obj, @course]
        redirect_to :action => "index"
			end
			# format.xml  { head :ok }
		end
  end

  def after_update_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"

				info = "#{EDIT_CN}#{name_for(@parent_type)}#{COURSE_CN} - #{item_title(@course)}"
				set_page_title(info)
				set_block_title(info)

				render :action => "edit"
				clear_notice
			end
			# format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
		end
  end

  def after_destroy_ok
		respond_to do |format|
		  format.html do
		  	flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"
		  	redirect_to :action => 'index'
		  end
		  # format.xml  { head :ok }
		end
  end

end
