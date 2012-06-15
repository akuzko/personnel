class ImportExistentCategoryDepartments < ActiveRecord::Migration
  def up
    DepartmentCategory.delete_all
    Category.all.each do |cat|
      DepartmentCategory.create(:category => cat, :department_id => cat.department_id)
    end
    remove_column :categories, :department_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
