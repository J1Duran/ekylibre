# = Informations
#
# == License
#
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2009 Brice Texier, Thibaud Merigon
# Copyright (C) 2010-2012 Brice Texier
# Copyright (C) 2012-2016 Brice Texier, David Joulin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# == Table: intervention_parameters
#
#  created_at              :datetime         not null
#  creator_id              :integer
#  event_participation_id  :integer
#  group_id                :integer
#  id                      :integer          not null, primary key
#  intervention_id         :integer          not null
#  lock_version            :integer          default(0), not null
#  new_container_id        :integer
#  new_group_id            :integer
#  new_variant_id          :integer
#  outcoming_product_id    :integer
#  position                :integer          not null
#  product_id              :integer
#  quantity_handler        :string
#  quantity_indicator_name :string
#  quantity_population     :decimal(19, 4)
#  quantity_unit_name      :string
#  quantity_value          :decimal(19, 4)
#  reference_name          :string           not null
#  type                    :string
#  updated_at              :datetime         not null
#  updater_id              :integer
#  variant_id              :integer
#  working_zone            :geometry({:srid=>4326, :type=>"multi_polygon"})
#
class InterventionParameter < Ekylibre::Record::Base
  attr_readonly :reference_name
  belongs_to :group, class_name: 'InterventionGroupParameter'
  belongs_to :intervention, inverse_of: :parameters

  # [VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_numericality_of :quantity_population, :quantity_value, allow_nil: true
  validates_presence_of :intervention, :reference_name
  # ]VALIDATORS]
  validates_presence_of :position

  scope :of_activity, lambda { |activity|
    where(intervention_id: InterventionTarget.select(:intervention_id).of_activity(activity))
  }
  scope :of_activity_production, lambda { |production|
    where(intervention_id: InterventionTarget.select(:intervention_id).of_activity_production(production))
  }
  scope :of_generic_role, lambda { |role|
    role = role.to_s
    unless %w(doer input output target tool).include?(role)
      fail ArgumentError, "Invalid role: #{role}"
    end
    where(type: "Intervention#{role.camelize}")
  }

  before_validation do
    self.intervention ||= group.intervention if group
    if reference
      self.position = reference.position
    elsif position.blank?
      precision = 10**8
      now = Time.zone.now
      self.position = (precision * now.to_f).round - (precision * now.to_i)
    end
  end

  # Returns a Procedo::Parameter corresponding to its reference_name
  # in the current procedure
  def reference
    if @reference.blank? && intervention
      @reference = procedure.find(reference_name)
    end
    @reference
  end

  def runnable?
    true
  end

  def cost_amount_computation
    AmountComputation.none
  end

  def cost
    cost_amount_computation.amount
  end

  def earn_amount_computation
    AmountComputation.none
  end

  def earn
    earn_amount_computation.amount
  end
end
