class Log < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true

  def author
    if author_type == 'Admin'
      Admin.find(author_id).email
    else
      User.find(author_id).full_name
    end
  end
end
