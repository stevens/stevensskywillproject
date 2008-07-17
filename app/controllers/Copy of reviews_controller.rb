class ReviewsController < ApplicationController
	include ReviewsHelper
	
	before_filter :protect, :except => [:index, :show]
  before_filter :load_user
  before_filter :load_parent_obj
  before_filter :load_self_obj
  before_filter :load_review_urls
	before_filter :load_parent_reviews

  # GET /reviews
  # GET /reviews.xml
  def index
    @reviews = Review.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reviews }
    end
  end

  # GET /reviews/1
  # GET /reviews/1.xml
  def show
    @review = Review.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @review }
    end
  end

  # GET /reviews/new
  # GET /reviews/new.xml
  def new
    @review = @user.reviews.build
		
 		info = "添加#{@reviewable_type_name}#{@reviewable_title}的新#{@object_name}"
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @review }
    end
  end

  # GET /reviews/1/edit
  def edit
    @review = Review.find(params[:id])
  end

  # POST /reviews
  # POST /reviews.xml
  def create
    @review = @user.reviews.build(params[:review])
		@review.reviewable_type = @reviewable_type
		@review.reviewable_id = @reviewable_id

    respond_to do |format|
      if @review.save
        flash[:notice] = "你已经成功添加了1#{@object_unit}新#{@object_name}!"
        format.html { redirect_to(@review) }
        format.xml  { render :xml => @review, :status => :created, :location => @review }
      else
      	flash[:notice] = "你输入的#{@object_name}信息有错误, 请重新输入!"
        format.html { render :action => "new" }
        format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
				
 				info = "添加#{@reviewable_type_name}#{@reviewable_title}的新#{@object_name}"	
				set_page_title(info)
				set_block_title(info)
      end
    end
  end

  # PUT /reviews/1
  # PUT /reviews/1.xml
  def update
    @review = Review.find(params[:id])

    respond_to do |format|
      if @review.update_attributes(params[:review])
        flash[:notice] = 'Review was successfully updated.'
        format.html { redirect_to(@review) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.xml
  def destroy
    @review = Review.find(params[:id])
    @review.destroy

    respond_to do |format|
      format.html { redirect_to(reviews_url) }
      format.xml  { head :ok }
    end
  end
  
	private
  
  def load_review_urls
  	load_self_urls	
  	@reviews_url = @selfs_url
  	@review_url = @self_url
		@new_review_url = @new_self_url
		@edit_review_url = @edit_self_url
	end
	
	def load_parent_reviews
		if @parent_id
			if @parent_type == 'user'
				@parent_reviews = @parent.reviews
			else
				@parent_reviews = reviews_all(@parent_type, @parent_id, nil)
			end
			@parent_reviews_count = @parent_reviews.size
		end
	end
	
end
