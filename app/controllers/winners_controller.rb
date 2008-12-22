class WinnersController < ApplicationController
  # GET /winners
  # GET /winners.xml
  def index
    @winners = Winner.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @winners }
    end
  end

  # GET /winners/1
  # GET /winners/1.xml
  def show
    @winner = Winner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @winner }
    end
  end

  # GET /winners/new
  # GET /winners/new.xml
  def new
    @winner = Winner.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @winner }
    end
  end

  # GET /winners/1/edit
  def edit
    @winner = Winner.find(params[:id])
  end

  # POST /winners
  # POST /winners.xml
  def create
    @winner = Winner.new(params[:winner])

    respond_to do |format|
      if @winner.save
        flash[:notice] = 'Winner was successfully created.'
        format.html { redirect_to(@winner) }
        format.xml  { render :xml => @winner, :status => :created, :location => @winner }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @winner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /winners/1
  # PUT /winners/1.xml
  def update
    @winner = Winner.find(params[:id])

    respond_to do |format|
      if @winner.update_attributes(params[:winner])
        flash[:notice] = 'Winner was successfully updated.'
        format.html { redirect_to(@winner) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @winner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /winners/1
  # DELETE /winners/1.xml
  def destroy
    @winner = Winner.find(params[:id])
    @winner.destroy

    respond_to do |format|
      format.html { redirect_to(winners_url) }
      format.xml  { head :ok }
    end
  end
end
