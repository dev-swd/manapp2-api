class Api::V1::OrganizationController < ApplicationController

  # 事業部一覧取得（無条件）
  def index_dep_all
    deps = Department.all.order(:code)
    render json: { status: 200, deps: deps }
  end

  # 事業部新規作成
  def create_dep

    ActiveRecord::Base.transaction do
      #事業部登録
      dep = Department.new(dep_params)
      dep.save!

      #課（ダミー）
      div = Division.new()
      div.department_id = dep.id
      div.code = "dep"
      div.name = dep_params[:name]
      div.level = 0
      div.save!
    end

    render json: { status: 200, message: "Create Success!" }

  rescue => e

    render json: { status: 500, message: "Create Error!" }

  end
    
  # 事業部取得（ID指定）
  def show_dep_where_id
    dep = Department.find(params[:id])
    render json: { status: 200, dep: dep }
  end

  # 事業部更新（ID指定）
  def update_dep_where_id
    dep = Department.find(params[:id])
    if dep.update(dep_params)
      render json: { status: 200, message: "Update Success!", dep: dep }
    else
      render json: { status: 500, message: "Update Error" }
    end
  end

  # 事業部削除（ID指定）
  def destroy_dep_where_id
    ActiveRecord::Base.transaction do
      dep = Department.find(params[:id])
      dep.destroy!
    end
    render json: { status:200, message: "Delete Success!" }
  rescue => e
    render json: { status:500, message: "Delete Error"}
  end

  # 課一覧取得（無条件）
  def index_div_all
    divs = Division
      .joins(:department)
      .select("departments.code AS dep_code, departments.name AS dep_name, divisions.*")
      .order("departments.code, divisions.level, divisions.code")
    render json: { status: 200, divs: divs }
  end

  # 課一覧取得（事業部条件）
  def index_div_where_dep
    divs = Division
      .joins(:department)
      .select("departments.code AS dep_code, departments.name AS dep_name, divisions.*")
      .where(department_id: params[:id])
      .where.not(code: 'dep')
      .order(:code)
    render json: { status: 200, divs: divs }
  end

  # 課新規作成
  def create_div
    ActiveRecord::Base.transaction do
      #課登録
      div = Division.new(div_params)
      div.level = 1
      div.save!
    end
    render json: { status: 200, message: "Create Success!" }
  rescue => e
    render json: { status: 500, message: "Create Error!" }
  end

  # 課取得（ID指定）
  def show_div_where_id
    div = Division
      .joins(:department)
      .select("departments.code AS dep_code, departments.name AS dep_name, divisions.*")
      .find(params[:id])
    render json: { status: 200, div: div }
  end

  # 課更新（ID指定）
  def update_div_where_id
    ActiveRecord::Base.transaction do
      div = Division.find(params[:id])
      div.code = div_params[:code]
      div.name = div_params[:name]
      div.save!
    end

    render json: { status: 200, message: "Update Success!", div: div }

  rescue => e

    render json: { status: 500, message: "Update Error" }

  end

  # 課削除（ID指定）
  def destroy_div_where_id
    ActiveRecord::Base.transaction do
      div = Division.find(params[:id])
      div.destroy!
    end
    render json: { status:200, message: "Delete Success!" }
  rescue => e
    render json: { status:500, message: "Delete Error"}
  end

  # 課取得（事業部ダミー課1件のみ／事業部ID指定）
  def show_div_where_depdummy
    div = Division.find_by(department_id: params[:id], code: 'dep')
    render json: { status: 200, div: div }
  end

  # 社員一覧取得（全件）
  def index_emp_all
    emps = User
            .joins("LEFT OUTER JOIN divisions AS divs ON divs.id=division_id LEFT OUTER JOIN departments AS deps ON deps.id=divs.department_id")
            .select("users.id, users.employee_number, users.name, users.division_id, divs.code as div_code, divs.name as div_name, deps.code as dep_code, deps.name as dep_name")
            .order(:employee_number)
    render json: { status: 200, emps: emps }
  end

  # 社員一覧取得（未所属）
  def index_emp_where_not_assign
    emps = User
      .select("users.id, users.employee_number, users.name")
      .where(division_id: nil)
      .order(:employee_number)
    render json: { status: 200, emps: emps }
  end

  # 社員一覧取得（事業部直轄=事業部ID指定）
  def index_emp_where_dep_direct
    emps = Division
      .joins(:users)
      .select("users.id, users.employee_number, users.name")
      .where(department_id: params[:id])
      .where(code: 'dep')
      .order("users.employee_number")
    render json: { status: 200, emps: emps }
  end

  # 社員一覧取得（課所属=課ID指定）
  def index_emp_where_div
    emps = Division
      .joins(:department, :users)
      .select("departments.name AS dep_name, divisions.name As div_name, users.id, users.employee_number, users.name")
      .where(id: params[:id])
      .order("users.employee_number")
    render json: { status: 200, emps: emps }
  end

  # 社員情報取得（ID指定）
  def show_emp_where_id
    emp = User
      .joins("LEFT OUTER JOIN applicationroles ON users.authority_id = applicationroles.id")
      .select("users.id, users.employee_number, users.name, users.name_kana, users.birthday, users.address, users.phone, users.joining_date, users.authority_id, applicationroles.name as role_name ")
      .find(params[:id])
    render json: { status: 200, emp: emp }
  end


  # 社員情報更新（ID指定）
  def update_emp_where_id
    user = User.find(params[:id])
    if user.update(emp_params)
      render json: { status: 200, message: "Update Success!" }
    else
      render json: { status: 500, message: "Update Error" }
    end
  end

  # 承認者一覧取得（事業部直轄=事業部ID指定）
  def index_approval_where_dep_direct
    approvals = Division
      .joins(approvalauths: :user)
      .select("users.employee_number, users.name AS employee_name, approvalauths.*")
      .where(department_id: params[:id])
      .where(code: 'dep')
      .order("users.employee_number")
    render json: { status: 200, approvals: approvals }
  end

  # 承認者一覧取得（課所属=課ID指定）
  def index_approval_where_div
    approvals = Approvalauth
      .joins(:user)
      .select("users.employee_number, users.name AS employee_name, approvalauths.*")
      .where(division_id: params[:id])
      .order("users.employee_number")
    render json: { status: 200, approvals: approvals }
  end

  # 承認権限登録
  def create_approval
    approval = Approvalauth.new(approval_params)
    if approval.save
      render json: { status: 200, message: "Insert Success!" }
    else
      render json: {status: 500, message: "Insert Error" }
    end  
  end

  # 承認権限削除（ID指定）
  def destroy_approval_where_id
    ActiveRecord::Base.transaction do
      approval = Approvalauth.find(params[:id])
      approval.destroy!
    end
    render json: { status:200, message: "Delete Success!" }
  rescue => e
    render json: { status:500, message: "Delete Error"}  
  end

  # Deviseパスワード変更(empId指定／password無)
  def update_password_without_currentpassword
    user = User.find(params[:id]);
    if user.update_without_current_password(
      password: emp_params[:password],
      password_confirmation: emp_params[:password_confirmation],
    ) then
      render json: { status: 200, message: "Update Success!" }
    else
      render json: { status: 500, message: "Update Error" }
    end
  end

  private
  # ストロングパラメータ
  def dep_params
    params.permit(:code, :name)
  end
  def div_params
    params.permit(:department_id, :code, :name, :level)
  end
  def emp_params
    params.permit(:employee_number, :name, :name_kana, :address, :phone, :birthday, :joining_date, :division_id, :authority_id, :password, :password_confirmation)
  end
  def approval_params
    params.permit(:user_id, :division_id)
  end
end
