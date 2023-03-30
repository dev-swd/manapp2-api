class Api::V1::ApplicationController < ApplicationController

  # ロール一覧
  def index_role_all
    roles = Applicationrole.all.order(:code)
    render json: { status: 200, roles: roles }
  end

  # 機能temp一覧
  def index_temp_all
    temps = Applicationtemp.all.order(:sort_key)
    render json: { status: 200, temps: temps }
  end

  # 機能temp登録
  def update_temp
    ActiveRecord::Base.transaction do
      sort = 0
      apps_params[:temps].map do |temp_param|
        if temp_param[:del].blank? then
          sort += 1
          temp = Applicationtemp.find_or_initialize_by(id: temp_param[:id])
          temp.code = temp_param[:code]
          temp.name = temp_param[:name]
          temp.sort_key = sort
          temp.save!
        else
          if temp_param[:id].present? then
            temp = Applicationtemp.find(temp_param[:id])
            temp.destroy!
          end
        end
      end
    end
    render json: { status:200, message: "Update Success!"}
  rescue => e
    render json: { status:500, message: "Update Error"}
  end

  # ロール新規登録
  def create_role
    ActiveRecord::Base.transaction do
      role = Applicationrole.new
      role.code = apps_params[:code]
      role.name = apps_params[:name]
      role.save!
      apps_params[:apps].map do |app_param|
        app = Application.new
        app.applicationrole_id = role.id
        app.applicationtemp_id = app_param[:applicationtemp_id]
        app.permission = app_param[:permission]
        app.save!
      end
    end
    render json: { status: 200, message: "Create Success!" }
  rescue => e
    render json: { status: 500, message: "Create Error!" }
  end

  # ロール削除（ID指定）
  def destroy_role_where_id
    ActiveRecord::Base.transaction do
      role = Applicationrole.find(params[:id])
      role.destroy!
    end
    render json: { status:200, message: "Delete Success!" }
  rescue => e
    render json: { status:500, message: "Delete Error"}
  end

  # ロール検索（ID取得）
  def show_role_where_id
    role = Applicationrole.find(params[:id])
    apps = Application
      .joins(:applicationtemp)
      .select("applications.*, applicationtemps.code as code, applicationtemps.name as name")
      .where(applicationrole_id: params[:id])
      .order("applicationtemps.sort_key")
    render json: { status: 200, role: role, apps: apps }
  end
  
  # ロール更新（ID指定）
  def update_role_where_id
    ActiveRecord::Base.transaction do
      role = Applicationrole.find(params[:id])
      role.code = apps_params[:code]
      role.name = apps_params[:name]
      role.save!
      apps_params[:apps].map do |app_param|
        app = Application.find(app_param[:id])
        app.permission = app_param[:permission]
        app.save!
      end
    end
    render json: { status:200, message: "Update Success!" }
  rescue => e
    render json: { status:500, message: "Update Error"}  
  end

  private
  # ストロングパラメータ
  def apps_params
    params.permit(:id, :code, :name, 
      apps: [:id, :applicationtemp_id, :permission],
      temps: [:id, :code, :name, :sort_key, :del])
  end
  
end
