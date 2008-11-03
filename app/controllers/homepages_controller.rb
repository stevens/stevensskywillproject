class HomepagesController < ApplicationController
  # GET /homepages
  # GET /homepages.xml
  def index
    @homepages = Homepage.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @homepages }
    end
  end

  # GET /homepages/1
  # GET /homepages/1.xml
  def show
    @homepage = Homepage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @homepage }
    end
  end

  # GET /homepages/new
  # GET /homepages/new.xml
  def new
    @homepage = Homepage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @homepage }
    end
  end

  # GET /homepages/1/edit
  def edit
    @homepage = Homepage.find(params[:id])
  end

  # POST /homepages
  # POST /homepages.xml
  def create
    @homepage = Homepage.new(params[:homepage])

    respond_to do |format|
      if @homepage.save
        flash[:notice] = 'Homepage was successfully created.'
        format.html { redirect_to(@homepage) }
        format.xml  { render :xml => @homepage, :status => :created, :location => @homepage }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @homepage.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /homepages/1
  # PUT /homepages/1.xml
  def update
    @homepage = Homepage.find(params[:id])

    respond_to do |format|
      if @homepage.update_attributes(params[:homepage])
        flash[:notice] = 'Homepage was successfully updated.'
        format.html { redirect_to(@homepage) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @homepage.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /homepages/1
  # DELETE /homepages/1.xml
  def destroy
    @homepage = Homepage.find(params[:id])
    @homepage.destroy

    respond_to do |format|
      format.html { redirect_to(homepages_url) }
      format.xml  { head :ok }
    end
  end
end
