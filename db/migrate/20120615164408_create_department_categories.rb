class CreateDepartmentCategories < ActiveRecord::Migration
  def change
    create_table :department_categories do |t|
      t.references :department
      t.references :category
      t.timestamps
    end
    add_index "department_categories" , ["department_id", "category_id"], :unique => true
  end
end