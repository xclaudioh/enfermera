# encoding: utf-8
class Person < ActiveRecord::Base

  require 'csv'
  require 'prawn'
  require 'prawn/table'

  before_save :log_changed

  belongs_to :workplace

  has_many :previousjob, dependent: :destroy
  has_many :persondocuments, dependent: :destroy
  has_many :fees, dependent: :destroy

  mount_uploader :picture, PictureUploader
  mount_uploader :certificado_file, FileUploader

  auto_increment :nro_registro

  validates :nombres, :apellido_paterno, presence: true
  validates :rut, :rut_format => true

  scope :this_month, -> fecha { where(created_at: fecha.beginning_of_month..fecha.end_of_month) }
  scope :update_this_month, -> { where(updated_at: fecha.beginning_of_month..fecha.end_of_month) }


  scope :padron, -> estado { where("id IN (?) OR  workplace_id IN (?)" ,Fee.select(:person_id).where("mescuota > ? ", 6.month.ago), HeadDaily.select(:workplace_id).where(id: Daily.select(:head_daily_id).where(account_id: Account.where(codigo:'2040105')))) } 
  scope :active, ->estado { where.not(rut: nil) if estado=='A' }
  scope :workplace, -> workplace { where('workplace_id = ?', workplace) if workplace.present?}

  scope :office, -> office { where(workplace_id: Office.find(office).workplaces.pluck(:id)) if office.present?}

  scope :with_paterno, -> with_paterno { where('lower(apellido_paterno) = ?', with_paterno.downcase  ) if with_paterno.present?}
  scope :with_materno, -> with_materno { where('lower(apellido_materno) = ?', with_materno.downcase) if with_materno.present?}
  scope :with_rut, -> with_rut { where(rut: with_rut) if with_rut.present?}
  scope :with_registro, -> with_registro { where(nro_registro: with_registro) if with_registro.present?}
  scope :member, -> member { where.not(nro_registro: nil) if member }

  ESTADOS = { "A" => "Con Rut"}

  def fullname
    fullname = "#{self.apellido_paterno} #{self.apellido_materno} #{self.nombres} "
  end

  GENDERS      = ['Masculino', 'Femenino']
  def self.gender_options_for_select
    #GENDERS.to_enum.with_index(0).to_a
    GENDERS.each.map { |t| [t, t.upcase.gsub(' ', '_')] }
  end 


  NACIONALIDAD      = ['Chilena', 'Extranjero']
  def self.nacionalidad_options_for_select
    #GENDERS.to_enum.with_index(0).to_a
    NACIONALIDAD.each.map { |t| [t, t.upcase.gsub(' ', '_')] }
  end 

  TIPOCONTRATO      = ['Planta', 'Palzo Fijo', 'Honorarios']
  def self.tipocontrato_options_for_select
    #GENDERS.to_enum.with_index(0).to_a
    TIPOCONTRATO.each.map { |t| [t, t.upcase.gsub(' ', '_')] }
  end 

  FORMAPAGO  = ['Pago Directo', 'Descuento por planilla']
  def self.formapago_options_for_select
    #GENDERS.to_enum.with_index(0).to_a
    FORMAPAGO.each.map { |t| [t, t.upcase.gsub(' ', '_')] }
  end 

  def self.regional_admin_for_select
    admins = Person.where(email:User.where('roles_mask >= 4').pluck(:email))
    admins.map {|p| [p.fullname, p.id]}
  end


  def self.import(file)
    CSV.foreach(file.path, col_sep: ';', headers: true, encoding: "ISO-8859-1" ) do |row|
      rowHash = row.to_hash
      @person = Person.where(rut: rowHash["rut"]).first
      if ! @person.present?
        person = Person.new
        person.nro_registro = rowHash["nro_registro"] 
        person.rut = rowHash["rut"]        
        person.nombres = rowHash["nombres"]
        person.apellido_paterno = rowHash["apellido_paterno"]
        person.apellido_materno = rowHash["apellido_materno"]
        person.sexo = rowHash["sexo"]
        person.direccion = rowHash["direccion"]
        person.ciudad = rowHash["ciudad"]
        person.universidad = rowHash["universidad"]
        person.fecha_titulo = rowHash["fecha_titulo"]
        person.phone = rowHash["fono"]
        if person.save
        else
          puts "************************"  
          puts "************************"  
          puts   rowHash
          puts "************************"  
          puts "************************"  
        end
      else
        @person.nro_registro = rowHash["nro_registro"] 
        @person.save
      end

    end    
  end    


  def self.import_update(file)
    CSV.foreach(file.path, col_sep: ';', headers: true, encoding: "ISO-8859-1" ) do |row|
      rowHash = row.to_hash
      
      if rowHash["nro_registro"].present?
        person = Person.where(nro_registro: rowHash["nro_registro"]).first
        if person.present?

          person.lugar_trabajo = rowHash["lugar_trabajo"]    
          if rowHash["rut"].present? 
            if rowHash["rut"] != "N/R-"
              person.rut = rowHash["rut"]
            end
          end  
        end  
      else
        person = Person.where(rut: rowHash["rut"]).first
        if person.present?
          person.lugar_trabajo = rowHash["lugar_trabajo"]
        end
      end 

      if person.present?
        person.save
      else
        puts "************************"  
        puts "************************"  
        puts   rowHash
        puts "************************"  
        puts "************************"  
      end    
    end 
    Person.where.not(lugar_trabajo: nil).map {|p| p.workplace_id=Workplace.find_by_cod_wp(p.lugar_trabajo).id if Workplace.find_by_cod_wp(p.lugar_trabajo).present?; p.save}
  end    



  def self.import_update_email(file)
    CSV.foreach(file.path, col_sep: ';', headers: true, encoding: "ISO-8859-1" ) do |row|
      rowHash = row.to_hash
      
      if rowHash["rut"].present?
        person = Person.where(rut: rowHash["rut"]).first
        if person.present?
          person.email = rowHash["email"]    

          user = User.where(rut: rowHash["rut"]).first
          if user.present?
            user.email = rowHash["email"] 
            user.save
          end
        end  
      end 

      if person.present?
        person.save
        # PersonMailer.send_user(person.rut).deliver
      else
        puts "************************"  
        puts "************************"  
        puts   rowHash
        puts "************************"  
        puts "************************"  
      end    
    end 
    Person.where.not(lugar_trabajo: nil).map {|p| p.workplace_id=Workplace.find_by_cod_wp(p.lugar_trabajo).id if Workplace.find_by_cod_wp(p.lugar_trabajo).present?; p.save}
  end  

  def self.create_user(file)

      CSV.foreach(file.path, col_sep: ';', headers: true, encoding: "ISO-8859-1" ) do |row|
      rowHash = row.to_hash
        p = Person.where(rut: rowHash["rut"]).first
        u = User.where(rut: rowHash["rut"]).first
        if !u.present?
          u=User.new
          u.rut=p.rut 
          u.email=p.email.present? ? p.email : "#{p.rut}sin@mail.cl"
          u.password = p.rut
          u.password_confirmation = p.rut
          u.roles_mask=3 
          u.save
        end  
      end
  end

  def usernew
    u = User.where(rut: self.rut).first
    if !u.present?
      u=User.new
      u.rut=self.rut 
      u.email=self.email.present? ? self.email : "#{self.rut}sin@mail.cl"
      u.password = self.rut
      u.password_confirmation = self.rut
      u.roles_mask=4
      u.save
    end  
  end

  DIA = ['Lunes', 'Martes','Miercoles','Jueves', 'Vierne', 'Sabado', 'Domingo'] 
  def dia(numdia)
    dia = DIA[numdia-1]
  end

  MES = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  def mes(nummes)
    mes = MES[nummes-1]
  end

  def workplace
    workplace = Workplace.where(id: self.workplace_id).first || nil
  end

  def workplace_name
    Workplace.find(self.workplace_id).nombre
  end

  def to_pasive
    if self.workplace_id.present?
      wp = Workplace.where(codigo: self.workplace.codigo).where("cod_wp like '888%'").first
    else
      wp = Workplace.where(cod_wp: '888-13').first
    end    
    self.workplace_id = wp.id
    self.save
  end

  def office
    w = self.workplace
    w.office
  end


  def log_changed
    if self.changed?
      PersonMailer.update_user(self, self.changed ).deliver
    end
  end  


end
