class TaxiRoutesController < ApplicationController
  before_filter :authenticate_user!
  layout 'mobile'
  def index
    if !params[:date]
      date = Date.current
    else
      date = (params[:date][:year].to_s+"-"+params[:date][:month].to_s+"-"+params[:date][:day].to_s).to_date
    end
    params[:date] = date
    @taxi_route = TaxiRoute.find_by_traced(params[:date])
    @back_url = request.url

    @excludes = Log.where("(subject_type = 'ScheduleCell' and body LIKE '%excluded%') OR subject_type = 'TaxiRoute' OR (subject_type = 'User' and body LIKE '<b>Address%')").where("DATE(created_at) = ?", Date.current).order(:created_at)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @taxi_route }
    end
  end

  def create
    @taxi_route = TaxiRoute.new(params[:taxi_route])
    @back_url = params[:back_url]
    respond_to do |format|
      if @taxi_route.save
        Log.add(current_user, @taxi_route, params)
        format.html { redirect_to @back_url, :notice => 'Taxi route was successfully traced.' }
        format.json { render :json => @taxi_route, :status => :created, :location => @back_url }
      else
        format.html { render :action => "new" }
        format.json { render :json => @taxi_route.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @taxi_route = TaxiRoute.find(params[:id])
    @back_url = request.env["HTTP_REFERER"].blank? ? taxi_routes_url : request.env["HTTP_REFERER"]
    Log.add(current_user, @taxi_route, params)
    @taxi_route.destroy

    respond_to do |format|
      format.html { redirect_to @back_url }
      format.json { head :ok }
    end
  end
end
