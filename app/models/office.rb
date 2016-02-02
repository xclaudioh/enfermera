class Office < ActiveRecord::Base
  has_many :workplaces

  def self.office_option_for_select
    # filtrar por ciudad
    Office.all.order(nombre: :asc).map {|t| t.nombre}
  end 


  def self.region_options_for_select
    #GENDERS.to_enum.with_index(0).to_a
    Region.all.map { |r| [r.nombre, r.nombre] }
  end            
 
end
