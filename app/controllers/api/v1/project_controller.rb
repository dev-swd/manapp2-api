class Api::V1::ProjectController < ApplicationController

  # プロジェクト一覧（全件）
  def index_project_all
    projects = Project
      .joins("LEFT OUTER JOIN users AS plemps ON plemps.id = projects.pl_id")
      .joins("LEFT OUTER JOIN users AS memps ON memps.id = projects.make_id")
      .joins("LEFT OUTER JOIN users AS uemps ON uemps.id = projects.update_id")
      .joins("LEFT OUTER JOIN divisions ON projects.division_id = divisions.id")
      .joins("LEFT OUTER JOIN departments ON divisions.department_id = departments.id")
      .select("projects.id, projects.number, projects.name, projects.approval_date")
      .select("departments.name as dep_name, divisions.code as div_code, divisions.name as div_name, plemps.name as pl_name")
      .select("projects.status, projects.make_date, memps.name as make_name, projects.update_date, uemps.name as update_name")
      .select("projects.company_name, projects.department_name, projects.personincharge_name")
      .select("projects.development_period_fr, projects.development_period_to, projects.scheduled_to_be_completed")
      .select("projects.created_at, projects.updated_at")
      .order(:number)

    render json: { status: 200, projects: projects }
  end

  # プロジェクト一覧（条件付き）
  def index_project
    where = ""

    # プロジェクト／プロジェクト外
    if params[:not_project].present? then
      if params[:not_project].downcase=="true" then
        # プロジェクト外
        where = "projects.not_project=true "  
      else
        # プロジェクト
        where = "projects.not_project=false "  
      end
    end

    # 承認日
    if params[:approval_date] == "1" then
      # 期日指定
      if params[:approval_date_fr].present? then
        where << "and (projects.approval_date = '#{params[:approval_date_fr]}') "
      end
    elsif params[:approval_date] == "2" then
      # 範囲指定
      if params[:approval_date_fr].present? then
        if params[:approval_date_to].present? then
          where << "and (projects.approval_date between '#{params[:approval_date_fr]}' and '#{params[:approval_date_to]}') "
        else
          where << "and (projects.approval_date >= '#{params[:approval_date_fr]}') "
        end
      else
        if params[:approval_date_to].present? then
          where << "and (projects.approval_date <= '#{params[:approval_date_to]}') "
        end
      end
    end

    # 部門
    div_where = ""
    params[:div].map do |div_param|
      if div_where.present? then
        div_where << ", "
      end
      div_where << div_param.to_s()
    end
    if div_where.present? then
      where << "and (projects.division_id IN (#{div_where})) "
    end

    # PL
    pl_where = ""
    params[:pl].map do |pl_param|
      if pl_where.present? then
        pl_where << ", "
      end
      pl_where << pl_param.to_s()
    end
    if pl_where.present? then
      where << "and (projects.pl_id IN (#{pl_where})) "
    end

    # 状態
    status_where = ""
    params[:status].map do |status_param|
      if status_where.present? then
        status_where << ", "
      end
      status_where << `'#{status_param}'`
    end
    if status_where.present? then
      where << "and (projects.status IN (#{status_where})) "
    end

    # 作成日
    if params[:make_date] == "1" then
      # 期日指定
      if params[:make_date_fr].present? then
        where << "and (projects.make_date = '#{params[:make_date_fr]}') "
      end
    elsif params[:make_date] == "2" then
      # 範囲指定
      if params[:make_date_fr].present? then
        if params[:make_date_to].present? then
          where << "and (projects.make_date between '#{params[:make_date_fr]}' and '#{params[:make_date_to]}') "        
        else
          where << "and (projects.make_date >= '#{params[:make_date_fr]}') "        
        end
      else
        if params[:make_date_to].present? then
          where << "and (projects.make_date <= '#{params[:make_date_to]}') "        
        end
      end
    end

    # 作成者
    make_where = ""
    params[:make].map do |make_param|
      if make_param.present? then
        make_where << ", "
      end
      make_where << make_param.to_s()
    end
    if make_where.present? then
      where << "and (projects.make_id IN (#{make_where})) "
    end

    # 変更日
    if params[:update_date] == "1" then
      # 期日指定
      if params[:update_date_fr].present? then
        where << "and (projects.update_date = '#{params[:update_date_fr]}') "
      end
    elsif params[:update_date] == "2" then
      # 範囲指定
      if params[:update_date_fr].present? then
        if params[:update_date_to].present? then
          where << "and (projects.update_date between '#{params[:update_date_fr]}' and '#{params[:update_date_to]}') "
        else
          where << "and (projects.update_date >= '#{params[:update_date_fr]}') "
        end
      else
        if params[:update_date_to].present? then
          where << "and (projects.update_date <= '#{params[:update_date_to]}') "
        end
      end
    end

    # 変更者
    update_where = ""
    params[:update].map do |update_param|
      if update_param.present? then
        update_where << ", "
      end
      update_where << update_param.to_s()
    end
    if update_where.present? then
      where << "and (projects.update_id IN (#{update_where})) "
    end

    # 完了予定日
    if params[:scheduled_to_be_completed] == "1" then
      # 期日指定
      if params[:scheduled_to_be_completed_fr].present? then
        where << "and (projects.scheduled_to_be_completed = '#{params[:scheduled_to_be_completed_fr]}') "
      end
    elsif params[:scheduled_to_be_completed] == "2" then
      # 範囲指定
      if params[:scheduled_to_be_completed_fr].present? then
        if params[:scheduled_to_be_completed_to].present? then
          where << "and (projects.scheduled_to_be_completed between '#{params[:scheduled_to_be_completed_fr]}' and '#{params[:scheduled_to_be_completed_to]}') "      
        else
          where << "and (projects.scheduled_to_be_completed >= '#{params[:scheduled_to_be_completed_fr]}') "      
        end
      else
        if params[:scheduled_to_be_completed_to].present? then
          where << "and (projects.scheduled_to_be_completed <= '#{params[:scheduled_to_be_completed_to]}') "      
        end
      end
    end

    projects = Project
      .joins("LEFT OUTER JOIN users AS plemps ON plemps.id = projects.pl_id")
      .joins("LEFT OUTER JOIN users AS memps ON memps.id = projects.make_id")
      .joins("LEFT OUTER JOIN users AS uemps ON uemps.id = projects.update_id")
      .joins("LEFT OUTER JOIN divisions ON projects.division_id = divisions.id")
      .joins("LEFT OUTER JOIN departments ON divisions.department_id = departments.id")
      .select("projects.id, projects.number, projects.name, projects.approval_date")
      .select("departments.name as dep_name, divisions.code as div_code, divisions.name as div_name, plemps.name as pl_name")
      .select("projects.status, projects.make_date, memps.name as make_name, projects.update_date, uemps.name as update_name")
      .select("projects.company_name, projects.department_name, projects.personincharge_name")
      .select("projects.development_period_fr, projects.development_period_to, projects.scheduled_to_be_completed")
      .select("projects.created_at, projects.updated_at")
      .where(where)
      .order(:number)

    render json: { status: 200, projects: projects }
  end

  # プロジェクト要素リスト取得
  def index_projectlist

    if params[:not_project].present? then
      # プロジェクト／プトジェクト外の指定あり
      if params[:not_project].downcase=="true" then
        not_project = true
      else
        not_project = false
      end
      pls = Project
            .joins("INNER JOIN users AS plemps ON plemps.id=pl_id")
            .where(not_project: not_project)
            .group(:pl_id)
            .group("plemps.employee_number, plemps.name")
            .select("projects.pl_id as id, plemps.employee_number as number, plemps.name as name")
            .order("plemps.employee_number")
      makes = Project
          .joins("INNER JOIN users AS memps ON memps.id=make_id")
          .where(not_project: not_project)
          .group(:make_id)
          .group("memps.employee_number, memps.name")
          .select("projects.make_id as id, memps.employee_number as number, memps.name as name")
          .order("memps.employee_number")
      updates = Project
          .joins("INNER JOIN users AS uemps ON uemps.id=update_id")
          .where(not_project: not_project)
          .group(:update_id)
          .group("uemps.employee_number, uemps.name")
          .select("projects.update_id as id, uemps.employee_number as number, uemps.name as name")
          .order("uemps.employee_number")

      render json: { status: 200, pls: pls, makes: makes, updates: updates }
    else      
      pls = Project
          .joins("INNER JOIN users AS plemps ON plemps.id=pl_id")
          .group(:pl_id)
          .group("plemps.employee_number, plemps.name")
          .select("projects.pl_id as id, plemps.employee_number as number, plemps.name as name")
          .order("plemps.employee_number")
      makes = Project
          .joins("INNER JOIN users AS memps ON memps.id=make_id")
          .group(:make_id)
          .group("memps.employee_number, memps.name")
          .select("projects.make_id as id, memps.employee_number as number, memps.name as name")
          .order("memps.employee_number")
      updates = Project
          .joins("INNER JOIN users AS uemps ON uemps.id=update_id")
          .group(:update_id)
          .group("uemps.employee_number, uemps.name")
          .select("projects.update_id as id, uemps.employee_number as number, uemps.name as name")
          .order("uemps.employee_number")

      render json: { status: 200, pls: pls, makes: makes, updates: updates }
    end
  end

  # プロジェクト新規登録
  def create_project
    ActiveRecord::Base.transaction do
      prj = Project.new
      prj_param = prj_params[:project]
      prj.number = prj_param[:number]
      prj.name = prj_param[:name]
      prj.division_id = prj_param[:division_id]
      prj.pl_id = prj_param[:pl_id]
      prj.approval_id = prj_param[:approval_id]
      prj.approval_date = prj_param[:approval_date]
      prj.status = prj_param[:status]
      prj.created_id = prj_param[:created_id]
      prj.updated_id = prj_param[:updated_id]
      prj.save!
    end
    render json: { status: 200, message: "Create Success!" }
  rescue => e
    render json: { status: 500, message: "Create Error!" }
  end

  # プロジェクト情報取得（ID指定）
  def show_project_where_id
    project = Project
      .joins("LEFT OUTER JOIN users AS aemps ON aemps.id = projects.approval_id")
      .joins("LEFT OUTER JOIN users AS plemps ON plemps.id = projects.pl_id")
      .joins("LEFT OUTER JOIN users AS memps ON memps.id = projects.make_id")
      .joins("LEFT OUTER JOIN users AS uemps ON uemps.id = projects.update_id")
      .joins("LEFT OUTER JOIN divisions ON projects.division_id = divisions.id")
      .joins("LEFT OUTER JOIN departments ON divisions.department_id = departments.id")
      .select("projects.*, aemps.name as approval_name, memps.name as make_name, uemps.name as update_name, plemps.name as pl_name")
      .select("departments.name as dep_name, divisions.code as div_code, divisions.name as div_name")
      .find(params[:id])
    phases = Phase.where(project_id: params[:id]).order(:number)
    risks = Risk.where(project_id: params[:id]).order(:number)
    qualitygoals = Qualitygoal.where(project_id: params[:id]).order(:number)
    members = Member
      .joins("LEFT OUTER JOIN users ON users.id = members.member_id")
      .select("members.*, users.name as member_name")
      .where(project_id: params[:id])
      .where(level: "emp")
      .order(:number)

    render json: { status: 200, project: project, phases: phases, risks: risks, goals: qualitygoals, members: members }
  end

  # プロジェクト更新（ID指定　工程、リスク、品質目標、メンバー、ログも更新）
  def update_project_where_id
    ActiveRecord::Base.transaction do

      prj = Project.find(params[:id])
      prj_param = prj_params[:project]
      prj.status = prj_param[:status]
      prj.pl_id = prj_param[:pl_id]
      prj.number = prj_param[:number]
      prj.name = prj_param[:name]
      prj.make_date = prj_param[:make_date]
      prj.make_id = prj_param[:make_id]
      prj.update_date = prj_param[:update_date]
      prj.update_id = prj_param[:update_id]
      prj.company_name = prj_param[:company_name]
      prj.department_name = prj_param[:department_name]
      prj.personincharge_name = prj_param[:personincharge_name]
      prj.phone = prj_param[:phone]
      prj.fax = prj_param[:fax]
      prj.email = prj_param[:email]
      prj.development_period_fr = prj_param[:development_period_fr]
      prj.development_period_to = prj_param[:development_period_to]
      prj.scheduled_to_be_completed = prj_param[:scheduled_to_be_completed]
      prj.system_overview = prj_param[:system_overview]
      prj.development_environment = prj_param[:development_environment]
      prj.order_amount = prj_param[:order_amount]
      prj.planned_work_cost = prj_param[:planned_work_cost]
      prj.planned_workload = prj_param[:planned_workload]
      prj.planned_purchasing_cost = prj_param[:planned_purchasing_cost]
      prj.planned_outsourcing_cost = prj_param[:planned_outsourcing_cost]
      prj.planned_outsourcing_workload = prj_param[:planned_outsourcing_workload]
      prj.planned_expenses_cost = prj_param[:planned_expenses_cost]
      prj.gross_profit = prj_param[:gross_profit]
      prj.work_place_kbn = prj_param[:work_place_kbn]
      prj.work_place = prj_param[:work_place]
      prj.customer_property_kbn = prj_param[:customer_property_kbn]
      prj.customer_property = prj_param[:customer_property]
      prj.customer_environment = prj_param[:customer_environment]
      prj.purchasing_goods_kbn = prj_param[:purchasing_goods_kbn]
      prj.purchasing_goods = prj_param[:purchasing_goods]
      prj.outsourcing_kbn = prj_param[:outsourcing_kbn]
      prj.outsourcing = prj_param[:outsourcing]
      prj.customer_requirement_kbn = prj_param[:customer_requirement_kbn]
      prj.customer_requirement = prj_param[:customer_requirement]
      prj.remarks = prj_param[:remarks]
      prj.save!

      phase_num = 0
      prj_params[:phases].map do |phase_param|
        if phase_param[:del].blank? then
          phase_num += 1
          phase = Phase.find_or_initialize_by(id: phase_param[:id])
          phase.project_id = params[:id]
          phase.number = phase_num
          phase.name = phase_param[:name]
          phase.planned_periodfr = phase_param[:planned_periodfr]
          phase.planned_periodto = phase_param[:planned_periodto]
          phase.deliverables = phase_param[:deliverables]
          phase.criteria = phase_param[:criteria]
          phase.save!
        else
          if phase_param[:id].blank? then
          else
            phase = Phase.find(phase_param[:id])
            phase.destroy!
          end
        end
      end

      risk_num = 0
      prj_params[:risks].map do |risk_param|
        if risk_param[:del].blank? then
          risk_num += 1
          risk = Risk.find_or_initialize_by(id: risk_param[:id])
          risk.project_id = params[:id]
          risk.number = risk_num
          risk.contents = risk_param[:contents]
          risk.save!
        else
          if risk_param[:id].blank? then
          else
            risk = Risk.find(risk_param[:id])
            risk.destroy!
          end
        end
      end

      goal_num = 0
      prj_params[:goals].map do |goal_param|
        if goal_param[:del].blank? then
          goal_num += 1
          goal = Qualitygoal.find_or_initialize_by(id: goal_param[:id])
          goal.project_id = params[:id]
          goal.number = goal_num
          goal.contents = goal_param[:contents]
          goal.save!
        else
          if goal_param[:id].blank? then
          else
            goal = Qualitygoal.find(goal_param[:id])
            goal.destroy!
          end
        end
      end

      mem_num = 0
      prj_params[:members].map do |mem_param|
        if mem_param[:del].blank? then
          mem_num += 1
          mem = Member.find_or_initialize_by(id: mem_param[:id])
          mem.project_id = params[:id]
          mem.number = mem_num
          mem.level = mem_param[:level]
          mem.member_id = mem_param[:member_id]
          mem.save!
        else
          if mem_param[:id].present? then
            mem = Member.find(mem_param[:id])
            mem.destroy!
          end
        end
      end

      if prj_params[:log].present? then
        log_param = prj_params[:log]
        if log_param[:changer_id].present? then
          log = Changelog.new()
          log.project_id = params[:id]
          log.changer_id = log_param[:changer_id]
          log.change_date = Date.today
          log.contents = log_param[:contents]
          log.save!
        end
      end

    end

    render json: { status: 200, message: "Update Success!" }

  rescue => e

    render json: { status: 500, message: "Update Error"}
  end

  # 監査記録一覧取得（プロジェクトIDと種別（plan or report）を条件）
  def index_audit_where_project_kinds
    audits = Audit.
      joins("LEFT OUTER JOIN users AS auditemps ON auditemps.id=auditor_id LEFT OUTER JOIN users AS acptemps ON acptemps.id=accept_id")
      .select("audits.*, auditemps.name as auditor_name, acptemps.name as accept_name")
      .where(project_id: params[:id], kinds: params[:kinds])
      .order(:number)
    render json: { status: 200, audits: audits }
  end

  # 監査記録更新処理（プロジェクトID指定）
  # プロジェクト計画書の状態も併せて更新する。
  # プロジェクト計画書への状態更新が承認の場合は、変更記録に「初版」を登録する。
  def update_audits
    ActiveRecord::Base.transaction do

      audit_num = 0
      audit_params[:audits].map do |audit_param|
        if audit_param[:del].blank? then
          audit_num += 1
          audit = Audit.find_or_initialize_by(id: audit_param[:id])
          audit.project_id = params[:id]
          audit.kinds = audit_param[:kinds]
          audit.number = audit_num
          audit.auditor_id = audit_param[:auditor_id]
          audit.audit_date = audit_param[:audit_date]
          audit.title = audit_param[:title]
          audit.contents = audit_param[:contents]
          audit.result = audit_param[:result]
          audit.accept_id = audit_param[:accept_id]
          audit.accept_date = audit_param[:accept_date]
          audit.save!
        else
          if audit_param[:id].present? then
            audit = Audit.find(audit_param[:id])
            audit.destroy!
          end
        end
      end

      if audit_params[:status].present? then
        prj = Project.find(params[:id])
        prj.status = audit_params[:status]
        prj.save!

        if audit_params[:status] == "PJ推進中" then
          changelog = Changelog.new
          changelog.project_id = params[:id]
          changelog.changer_id = prj.make_id
          changelog.change_date = Date.today
          changelog.contents = "初版（監査承認）"
          changelog.save!
        end
      end

    end

    render json: { status: 200, message: "Update Success!" }

  rescue => e

    render json: { status: 500, message: "Update Error"}

  end

  # ログ取得（プロジェクトID指定）
  def index_log_where_project
    changelogs = Changelog
      .joins("LEFT OUTER JOIN users AS emps ON emps.id=changer_id")
      .select("changelogs.*, emps.name as changer_name")
      .where(project_id: params[:id])
      .order(:change_date, :id)
    render json: { status: 200, changelogs: changelogs }
  end

  # 完了報告書情報取得（プロジェクトID指定／プロジェクト情報、工程情報、完了報告書情報を取得）
  def show_report_where_projectid
    project = Project
      .joins("LEFT OUTER JOIN users AS aemps ON aemps.id=approval_id")
      .joins("LEFT OUTER JOIN users AS memps ON memps.id=make_id")
      .joins("LEFT OUTER JOIN users AS uemps ON uemps.id=update_id")
      .joins("LEFT OUTER JOIN users AS plemps ON plemps.id=pl_id")
      .select("projects.*, aemps.name as approval_name, memps.name as make_name, uemps.name as update_name, plemps.name as pl_name")
      .find(params[:id])
    phases = Phase
      .where(project_id: params[:id])
      .order(:number)
    report = Report
      .joins("LEFT OUTER JOIN users AS memps ON memps.id=make_id")
      .select("reports.*, memps.name as make_name")
      .find_by(project_id: params[:id])
    
    render json: { status: 200, project: project, phases: phases, report: report }
  end

  # 完了報告書登録 or 更新（ID指定）
  def update_report_where_id
    ActiveRecord::Base.transaction do
      prj_param = rep_params[:project]
      rep = Report.find_or_initialize_by(id: params[:id])
      rep.project_id = prj_param[:id]
      rep.make_date = rep_params[:make_date]
      rep.make_id = rep_params[:make_id]
      rep.delivery_date = rep_params[:delivery_date]
      rep.actual_work_cost = rep_params[:actual_work_cost]
      rep.actual_workload = rep_params[:actual_workload]
      rep.actual_purchasing_cost = rep_params[:actual_purchasing_cost]
      rep.actual_outsourcing_cost = rep_params[:actual_outsourcing_cost]
      rep.actual_outsourcing_workload = rep_params[:actual_outsourcing_workload]
      rep.actual_expenses_cost = rep_params[:actual_expenses_cost]
      rep.gross_profit = rep_params[:gross_profit]
      rep.customer_property_accept_result = rep_params[:customer_property_accept_result]
      rep.customer_property_accept_remarks = rep_params[:customer_property_accept_remarks]
      rep.customer_property_used_result = rep_params[:customer_property_used_result]
      rep.customer_property_used_remarks = rep_params[:customer_property_used_remarks]
      rep.purchasing_goods_accept_result = rep_params[:purchasing_goods_accept_result]
      rep.purchasing_goods_accept_remarks = rep_params[:purchasing_goods_accept_remarks]
      rep.outsourcing_evaluate1 = rep_params[:outsourcing_evaluate1]
      rep.outsourcing_evaluate_remarks1 = rep_params[:outsourcing_evaluate_remarks1]
      rep.outsourcing_evaluate2 = rep_params[:outsourcing_evaluate2]
      rep.outsourcing_evaluate_remarks2 = rep_params[:outsourcing_evaluate_remarks2]
      rep.communication_count = rep_params[:communication_count]
      rep.meeting_count = rep_params[:meeting_count]
      rep.phone_count = rep_params[:phone_count]
      rep.mail_count = rep_params[:mail_count]
      rep.fax_count = rep_params[:fax_count]
      rep.design_changes_count = rep_params[:design_changes_count]
      rep.specification_change_count = rep_params[:specification_change_count]
      rep.design_error_count = rep_params[:design_error_count]
      rep.others_count = rep_params[:others_count]
      rep.improvement_count = rep_params[:improvement_count]
      rep.corrective_action_count = rep_params[:corrective_action_count]
      rep.preventive_measures_count = rep_params[:preventive_measures_count]
      rep.project_meeting_count = rep_params[:project_meeting_count]
      rep.statistical_consideration = rep_params[:statistical_consideration]
      rep.qualitygoals_evaluate = rep_params[:qualitygoals_evaluate]
      rep.total_report = rep_params[:total_report]
      if params[:id].blank? then
        rep.created_id = rep_params[:created_id]
      end
      rep.updated_id = rep_params[:updated_id]
      rep.save!

      rep_params[:phases].map do |phase_param|
        phase = Phase.find(phase_param[:id])
        phase.review_count = phase_param[:review_count]
        phase.planned_cost = phase_param[:planned_cost]
        phase.actual_cost = phase_param[:actual_cost]
        phase.accept_comp_date = phase_param[:accept_comp_date]
        phase.ship_number = phase_param[:ship_number]
        phase.save!
      end

      if prj_param[:status]==="完了報告書監査中" then
        prj = Project.find(prj_param[:id])
        prj.status = prj_param[:status]
        prj.save!
      end

    end

    render json: { status: 200, message: "Update Success!" }

  rescue => e
  
    render json: { status: 500, message: "Update Error"}
      
  end

  # プロジェクトToDo取得（社員ID指定）
  def index_todo
    # 対象＝PLになっていて、計画未提出、計画書差戻、PJ推進中且つ予定期間（至）経過、完了報告書差戻
    projects = Project
      .where(pl_id: params[:id])
      .where("(status = '計画書未提出') or (status = '計画書差戻') or (status= 'PJ推進中' and development_period_to <= ?) or (status = '完了報告書差戻')", Date.today)
    render json: { status: 200, projects: projects }
  end

  # 内部監査ToDo取得
  def index_audit_todo
    # 対象＝計画書監査中、完了報告書監査中
    projects = Project
      .where(status: ["計画書監査中", "完了報告書監査中"])
    render json: { status: 200, projects: projects }
  end

  private
  def prj_params
    params.permit(project: [:status, :approval_id, :approval_date, :pl_id, :number, :name, :division_id,
      :make_date, :make_id, :update_date, :update_id, :company_name, :department_name, 
      :personincharge_name, :phone, :fax, :email, :development_period_fr, :development_period_to, 
      :scheduled_to_be_completed, :system_overview, :development_environment, 
      :order_amount, :planned_work_cost, :planned_workload, :planned_purchasing_cost, 
      :planned_outsourcing_cost, :planned_outsourcing_workload, :planned_expenses_cost, :gross_profit, 
      :work_place_kbn, :work_place, :customer_property_kbn, :customer_property, :customer_environment, 
      :purchasing_goods_kbn, :purchasing_goods, :outsourcing_kbn, :outsourcing, 
      :customer_requirement_kbn, :customer_requirement, :remarks, :plan_approval, :plan_approval_date,
      :created_id, :updated_id],
      phases: [:id, :project_id, :number, :name, :planned_periodfr, :planned_periodto, :deliverables, :criteria, :del],
      risks: [:id, :project_id, :number, :contents, :del],
      goals: [:id, :project_id, :number, :contents, :del],
      members: [:id, :project_id, :number, :level, :member_id, :del],
      log: [:changer_id, :contents],
      tasks: [:id, :phase_id, :name, :del],
    )
  end
  def project_search_params
    params.permit(:approval_date, :approval_date_fr, :approval_date_to, :div[], :pl[], :status[], 
      :make_date, :make_date_fr, :make_date_to, :make[], :update_date, :update_date_fr, :update_date_to, :update[],
      :scheduled_to_be_completed, :scheduled_to_be_completed_fr, :scheduled_to_be_completed_to)
  end
  def audit_params
    params.permit(:status,
      audits: [:id, :project_id, :kinds, :number, :auditor_id, :audit_date, :title, :contents, :result, :accept_id, :accept_date, :del]
    )
  end
  def rep_params
    params.permit(
      :make_date, :make_id, :delivery_date, 
      :actual_work_cost, :actual_workload, :actual_purchasing_cost, 
      :actual_outsourcing_cost, :actual_outsourcing_workload, :actual_expenses_cost, :gross_profit, 
      :customer_property_accept_result, :customer_property_accept_remarks, 
      :customer_property_used_result, :customer_property_used_remarks, 
      :purchasing_goods_accept_result, :purchasing_goods_accept_remarks, 
      :outsourcing_evaluate1, :outsourcing_evaluate_remarks1, :outsourcing_evaluate2, :outsourcing_evaluate_remarks2, 
      :communication_count, :meeting_count, :phone_count, :mail_count, :fax_count, 
      :design_changes_count, :specification_change_count, :design_error_count, :others_count, 
      :improvement_count, :corrective_action_count, :preventive_measures_count, 
      :project_meeting_count, :statistical_consideration, :qualitygoals_evaluate, :total_report, 
      :created_id, :updated_id,
      project: [:id, :status],
      phases: [:id, :review_count, :planned_cost, :actual_cost,:accept_comp_date, :ship_number]
    )
  end
end
