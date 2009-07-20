# == Schema Information
#
# Table name: entries
#
#  id              :integer       not null, primary key
#  record_id       :integer       not null
#  account_id      :integer       not null
#  name            :string(255)   not null
#  currency_id     :integer       not null
#  currency_rate   :decimal(16, 6 not null
#  editable        :boolean       default(TRUE)
#  currency_debit  :decimal(16, 2 default(0.0), not null
#  currency_credit :decimal(16, 2 default(0.0), not null
#  debit           :decimal(16, 2 default(0.0), not null
#  credit          :decimal(16, 2 default(0.0), not null
#  intermediate_id :integer       
#  statement_id    :integer       
#  letter          :string(8)     
#  expired_on      :date          
#  position        :integer       
#  comment         :text          
#  company_id      :integer       not null
#  created_at      :datetime      not null
#  updated_at      :datetime      not null
#  lock_version    :integer       default(0), not null
#  creator_id      :integer       
#  updater_id      :integer       
#


class Entry < ActiveRecord::Base
  belongs_to :account
  belongs_to :company
  belongs_to :currency
  belongs_to :record, :class_name=>"JournalRecord"
  belongs_to :intermediate, :class_name=>"BankAccountStatement"
  belongs_to :statement, :class_name=>"BankAccountStatement"

  acts_as_list :scope=>:record

  after_destroy  :update_record
  after_create   :update_record
  after_update   :update_record

  attr_readonly :company_id, :record_id
  

  #
  def before_validation 
    # computes the values depending on currency rate
    # for debit and credit.
    self.currency_debit  ||= 0
    self.currency_credit ||= 0
    unless self.currency.nil?
      self.currency_rate = self.currency.rate
      if self.editable 
        self.debit  = self.currency_debit * self.currency_rate 
        self.credit = self.currency_credit * self.currency_rate
      end
    end
  end
  
  #
  def validate
    errors.add :debit, tc(:error_amount_balance1) unless self.debit.zero? ^ self.credit.zero?
    errors.add :debit, tc(:error_amount_balance2) unless self.debit + self.credit >= 0  
     
    if self.record.closed
      self.record.entries.each do |entry|
        errors.add_to_base tc(:error_closed_entry, entry.name) unless entry.close? 
      end
    end
  end
  
  # 
  def close?
    return (not self.editable)
  end


  # updates the amounts to the debit and the credit 
  # for the matching record.
  def update_record
    # raise Exception.new(self.record)
    self.record.refresh
  end

  
  # this method allows to lock the entry. 
  def close
    self.update_attribute(:editable, false)
    #Entry.update_all("editable = false", {:record_id => self.record.id})
  end
  
  # this method allows to verify if the entry is lettered or not.
  def letter?
    not self.letter.blank?
  end

  #
  def balanced_letter?(letter=nil) 
    letter ||= self.letter
    return false if letter.blank?
    self.account.balanced_letter?(letter)
  end

 end
