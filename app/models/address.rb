#coding: utf-8

class Address < ActiveRecord::Base
  attr_accessible :city, :complement, :number, :state, :street, :zip_code, :user_id, :district

  belongs_to :user
  
  before_validation :remove_masks

  validates :street, :number, :district, :city, :state, :zip_code, :presence => true, if: :purchasing?
  validates :street, :district, :city, :length => { :in => 3..200 }, if: :purchasing?
  validates :number, :length => { :in => 1..50 }, :numericality => true, if: :purchasing?
  validates :state, :length => { :is => 2 }, if: :purchasing?
  validates :zip_code, :length => { :is => 8 }, if: :purchasing?

  def remove_masks
    self.zip_code.gsub!(/\D+/, "") if self.zip_code
  end

  def purchasing?
    User.current_status == :purchasing
  end

  def to_extensive
    "Rua #{self.street}, nº #{self.number}, #{self.complement} <br>
      #{self.city}/#{self.state} - CEP #{self.zip_code}".html_safe
  end
  
end
