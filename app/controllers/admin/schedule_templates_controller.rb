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

  def default_norms
    @template = ScheduleTemplate.find params[:id]
    @norms = Norm.norms_defaults(@template.year, @template.month)
    render :layout => false
  end

  def update_default_norms
    @template = ScheduleTemplate.find params[:id]
    @users = User.find_all_by_department_id_and_active @template.department_id, 1

    @users.each do |u|
      Norm.set_norms(u, @template,  params[:norm])
    end
    #if !@norm.errors.full_messages.empty?
    #  message = '<p>' + @norm.errors.full_messages.join('</p><p>') + '</p>'
    #  render(:update) do |page|
    #    page['#norms_flash'].parents(0).show
    #    page['#norms_flash'].html message
    #  end
    #else
      render(:update) do |p|
        p.call 'app.show_users_admin'
      #end
    end
  end

  def set_user_norm

  end
end
