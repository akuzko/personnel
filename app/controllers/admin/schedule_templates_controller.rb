class Admin::ScheduleTemplatesController < ApplicationController
  def set_visibility
    @schedule_template = ScheduleTemplate.find params[:id]
    @schedule_template.visible = params[:visible]
    @schedule_template.save
    render :nothing => true
  end

  def check_day
    @shift = ScheduleShift.find params[:id]
    @schedule_template = ScheduleTemplate.find @shift.schedule_template_id
    images = {
        '1' => 'error.png',
        '0' => 'accept.png',
        '-1' => 'cancel.png'
    }
    render(:update) do |page|
      id = "#day_#{params[:day]}"
      page[id].attr('src', '/images/web-app-theme/icons/' + images[(@schedule_template.check_day(params[:day])) . to_s])
    end
  end

  def check_month
    @schedule_template = ScheduleTemplate.find params[:id]
    @days_in_month = Time.days_in_month(@schedule_template.month, @schedule_template.year)
    images = {
        '1' => 'error.png',
        '0' => 'accept.png',
        '-1' => 'cancel.png'
    }
    render(:update) do |page|
      @days_in_month.times do |day|
        id = "#day_#{day+1}"
        page[id].attr('src', '/images/web-app-theme/icons/' + images[(@schedule_template.check_day(day+1)) . to_s])
      end
    end
  end
end
