# == Schema Information
#
# Table name: shape_operation_natures
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  description  :text          
#  company_id   :integer       not null
#  created_at   :datetime      not null
#  updated_at   :datetime      not null
#  lock_version :integer       default(0), not null
#  creator_id   :integer       
#  updater_id   :integer       
#

class ShapeOperationNature < ActiveRecord::Base

  belongs_to :company
  has_many :shape_operations

end
