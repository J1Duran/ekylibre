# == Schema Information
#
# Table name: inventories
#
#  id                :integer       not null, primary key
#  date              :date          not null
#  comment           :text          
#  changes_reflected :boolean       
#  company_id        :integer       not null
#  created_at        :datetime      not null
#  updated_at        :datetime      not null
#  lock_version      :integer       default(0), not null
#  creator_id        :integer       
#  updater_id        :integer       
#

class Inventory < ActiveRecord::Base
end
