class Preference < ActiveRecord::Base
  validates :name, uniqueness: true
  def self.[](name)
    Preference.find_by_name(name).try(:value)
  end

  def self.[]=(name, value)
    Preference.find_or_initialize_by_name(name).update_attributes!(value: value)
  end
end