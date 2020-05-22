class Intervention < ApplicationRecord
  belongs_to :author, class_name: "Employee"
  belongs_to :employee, optional: true
  belongs_to :customer
  belongs_to :building
  belongs_to :battery
  belongs_to :column, optional: true
  belongs_to :elevator, optional: true

  after_save :create_intervention_ticket

  def create_intervention_ticket
      client = ZendeskAPI::Client.new do |config|
          config.url = ENV['ZENDESK_URL']
          config.username = ENV['ZENDESK_USERNAME']
          config.token = ENV['ZENDESK_TOKEN']
      end

      text = "The contact company #{self.customer.company_name} has a problem in building ##{self.building_id}.\n"

      if (self.elevator_id != nil)
          text.concat("The problem is in: elevator ##{self.elevator_id}, which is in column ##{self.column_id}, in battery ##{self.battery_id}.\n")
      elsif (self.column_id != nil)
          text.concat("The problem is in: column ##{self.column_id}, which is in battery ##{self.battery_id}.\n")
      else
          text.concat("The problem is in: battery ##{self.battery_id}.\n")
      end

      if (self.employee_id != nil)
          text.concat("#{self.employee.first_name} #{self.employee.last_name} is assigned to this intervention.\n")
      else
          text.concat("no employees is currently assigned to this intervention.\n")
      end

      text.concat("\nDescription:\n#{self.report}")
      puts text
      ZendeskAPI::Ticket.create!(client, 
          :subject => "#{self.author.first_name} #{self.author.last_name}", 
          :comment => { 
              :value => text
          }, 
          :requester => { 
              "name": self.author.first_name,
              "email": "testemail@hotmail.com" 
          },
          :priority => "normal",
          :type => "problem"
      )
  end
end