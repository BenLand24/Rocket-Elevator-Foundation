class InterventionsController < ApplicationController
  before_action :authenticate_user!

  def new
      @clients = Customer.order(:company_name)
      puts @clients.collect{ |c| c.company_name }

      @employee = Employee.order(:last_name)
      puts @employee.collect{ |e| e.first_name + e.last_name }
  end

  def show
  
  end
  
  def get_building
      id_client = params[:id]
      @buildings = Building.where(customer_id: id_client)
      arr = []
      @buildings.each do |building|
        @address = Address.find_by_id(building.address_id)
         arr << @address.city
      end
      render json: { buildings: @buildings, address: arr }
  end    
  
  def get_battery
    id_building = params[:id]
    @batteries = Battery.where(building_id: id_building)
      render json: @batteries
  end

  def get_column
      @columns = Column.where(battery_id: params[:battery_id])
      render json: @columns
  end

  def get_elevator
      @elevators = Elevator.where(column_id: params[:column_id])
      render json: @elevators
  end 


  def create_intervention
    @intervention = Intervention.new(intervention_params)
    
    if @intervention.save
      flash[:notice] = "add new intervention successful"
      redirect_to :root
    else
      logger.error "failed to save intervention, missing params"
      flash[:notice] = "add new intervention not successful"
      redirect_to action:"new"
    end
  end

  private
  def intervention_params
    params[:intervention][:author_id] = current_user.id
    if params[:intervention][:column_id] == "nulltest"
      params[:intervention][:column_id] = nil
    end
    if params[:intervention][:elevator_id] == "nulltest"
      params[:intervention][:elevator_id] = nil
    end
    if params[:intervention][:employee_id] == "None"
      params[:intervention][:employee_id] = nil
    end
    # params[:intervention][:result] = nil
    # params[:intervention][:status] = nil
    params.require(:intervention).permit(:customer_id, :employee_id, :building_id, :battery_id, :column_id, :elevator_id, :report, :author_id, :date_started, :date_ended, :result, :status)
  end
end