class Log < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true

  def author
    if author_type == 'Admin'
      Admin.find(author_id).email
    else
      User.find(author_id).full_name
    end
  end

  def self.add(author, obj, params)
    subject_id = obj.id
    subject_type = obj.class.name
    case subject_type
      when "Contact", "Profile", "Address" then
        record_type = "User"
        subject_id = obj.user.id
      else
        record_type = subject_type
    end
    filter(params[subject_type.downcase.to_sym], [:password, :password_confirmation]) unless params[subject_type.downcase.to_sym].nil?
    convert_date(params[subject_type.downcase.to_sym], "birthdate") unless params[subject_type.downcase.to_sym].nil?
    body = case params[:action]
             when "create" then
               subject_type+' '+params[:action]+"\r\n"+params[subject_type.downcase.to_sym].to_a.map { |k, v| k+":"+v.to_s }.join("; ")
             when "update" then
               filter(params[:previous_attributes], [:password, :password_confirmation])
               h = params[:previous_attributes]
               h.map do |k, v|
                 h[k] = "0" if v == false
                 h[k] = "1" if v == true
                 h[k] = h[k].to_s
               end
               a1 = h.to_a
               a2 = h.merge!(params[subject_type.downcase.to_sym]).to_a
               subject_type+' '+params[:action]+"\r\n"+(a2 - a1).map { |k, v| k+":"+v.to_s }.join("; ")
             when "update_data" then
               filter(params[:previous_attributes], [:password, :password_confirmation])
               h = params[:previous_attributes]
               h.map do |k, v|
                 h[k] = "0" if v == false
                 h[k] = "1" if v == true
                 h[k] = h[k].to_s
               end
               a1 = h.to_a
               a2 = h.merge!(params[subject_type.downcase.to_sym]).to_a
               subject_type+' '+params[:action]+"\r\n"+(a2 - a1).map { |k, v| k+":"+v.to_s }.join("; ")
             when "destroy" then
               subject_type+' '+params[:action]+"\r\n"+obj.attributes.to_a.map { |k, v| k+":"+v.to_s }.join("; ")
             when "make_primary" then
               subject_type+' '+params[:action]+"\r\n"+obj.attributes.to_a.map { |k, v| k+":"+v.to_s }.join("; ")
             else
               'test'
           end
    author.logs_entered.create(
        :body => body,
        :subject_id => subject_id,
        :subject_type => record_type)
  end

  private

  def self.filter(h, keys)
    keys.each do |key|
      h[key] = "*filtered*" unless h[key].nil?
    end
  end

  def self.convert_date(h, key)
    if !h[key+"(1i)"].nil?
      h[key] = h[key+"(1i)"]+"-"+h[key+"(2i)"].rjust(2, "0")+"-"+h[key+"(3i)"].rjust(2, "0")
      h.delete(key+"(1i)")
      h.delete(key+"(2i)")
      h.delete(key+"(3i)")
    end
  end
end
