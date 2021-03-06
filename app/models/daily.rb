class Daily < ActiveRecord::Base
  belongs_to :head_daily
  belongs_to :cost_center
  belongs_to :account
  belongs_to :office
  belongs_to :income
  belongs_to :expense

  scope :with_cuenta, -> with_cuenta { where(account_id: with_cuenta) if with_cuenta.present?}
  scope :with_numero, -> with_numero { where(numero: with_numero) if with_numero.present?}
  scope :with_tipo, -> with_tipo { joins(:head_daily).where(head_dailies: {tipo: with_tipo}) if with_tipo.present?}

  def self.import(file)
    CSV.foreach(file.path, col_sep: ';', headers: true, encoding: "ISO-8859-1" ) do |row|
      rowHash = row.to_hash
      cost_center = CostCenter.where(codigo: rowHash["centro_costo"]).first
      account = Account.where(codigo: rowHash["cuenta"]).first
      head_daily = HeadDaily.where(numero: rowHash["numero"]).first
      office = Office.where(codigo: rowHash["region"]).first
      workplace = Workplace.where(cod_wp: rowHash["wp"]).first

        d = Daily.new
        if cost_center.present?
          d.cost_center_id = cost_center.id
        end  
        d.account_id = account.id
        d.head_daily_id = head_daily.id

        d.tipo = "EGRESO"
        d.office_id = office.present? ? office.id : nil
        d.workplace_id = workplace.present? ? workplace.id : nil
        d.numero = rowHash["numero"]
        d.fecha = Date.parse(rowHash["fecha"]) 
        d.debe = rowHash["debe"]  
        d.haber = rowHash["haber"] 
        d.paguesea = rowHash["paguesea"]  
        d.por = rowHash["glosa"] 
        d.save
 
    end
  end
end
