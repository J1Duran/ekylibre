# == Schema Information
#
# Table name: shapes
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  polygon      :string(255)   not null
#  master       :boolean       default(TRUE), not null
#  description  :text          
#  parent_id    :integer       
#  company_id   :integer       not null
#  created_at   :datetime      not null
#  updated_at   :datetime      not null
#  lock_version :integer       default(0), not null
#  creator_id   :integer       
#  updater_id   :integer       
#

class Shape < ActiveRecord::Base

  belongs_to :company
  has_many :shape_operations
  has_many :shapes

  acts_as_tree

end
