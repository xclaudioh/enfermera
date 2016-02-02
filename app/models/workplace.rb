class Workplace < ActiveRecord::Base
	has_many :wpdocument, dependent: :destroy
	has_many :people, dependent: :destroy


 
  def self.workplaces_option_for_select
  	# filtrar por ciudad
    Workplace.all.order(nombre: :asc).map {|t| [t.nombre, t.id]}
  end  
 

end
