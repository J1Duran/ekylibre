# == Schema Information
#
# Table name: deliveries
#
#  amount            :decimal(16, 2 default(0.0), not null
#  amount_with_taxes :decimal(16, 2 default(0.0), not null
#  comment           :text          
#  company_id        :integer       not null
#  contact_id        :integer       
#  created_at        :datetime      not null
#  creator_id        :integer       
#  currency_id       :integer       
#  id                :integer       not null, primary key
#  invoice_id        :integer       
#  lock_version      :integer       default(0), not null
#  mode_id           :integer       
#  moved_on          :date          
#  order_id          :integer       not null
#  planned_on        :date          
#  transport_id      :integer       
#  transporter_id    :integer       
#  updated_at        :datetime      not null
#  updater_id        :integer       
#  weight            :decimal(, )   
#

require 'test_helper'

class DeliveryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
