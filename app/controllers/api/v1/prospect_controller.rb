class Api::V1::ProspectController < ApplicationController

  # リードレベル一覧
  def index_lead
    leads = Lead.all.order(:sort_key)
    render json: { status: 200, leads: leads }
  end

  # リードレベル登録
  def update_lead
    ActiveRecord::Base.transaction do
      sort = 0
      lead_params[:leads].map do |lead_param|
        if lead_param[:del].blank? then
          sort += 1
          lead = Lead.find_or_initialize_by(id: lead_param[:id])
          lead.name = lead_param[:name]
          lead.period_kbn = lead_param[:period_kbn]
          lead.period = lead_param[:period]
          lead.color_r = lead_param[:color_r]
          lead.color_g = lead_param[:color_g]
          lead.color_b = lead_param[:color_b]
          lead.color_a = lead_param[:color_a]
          lead.sort_key = sort
          lead.save!
        else
          if lead_param[:id].present? then
            lead = Lead.find(lead_param[:id])
            lead.destroy!
          end
        end
      end
    end
    render json: { status: 200, message: "Update Success!" }
  rescue => e
    render json: { status: 500, message: "Update Error!" }
  end

  # アクション一覧
  def index_salesaction
    salesactions = Salesaction.all.order(:sort_key)
    render json: { status: 200, salesactions: salesactions }
  end

  # アクション登録
  def update_salesaction
    ActiveRecord::Base.transaction do
      sort = 0
      salesaction_params[:salesactions].map do |salesaction_param|
        if salesaction_param[:del].blank? then
          sort += 1
          salesaction = Salesaction.find_or_initialize_by(id: salesaction_param[:id])
          salesaction.name = salesaction_param[:name]
          salesaction.color_r = salesaction_param[:color_r]
          salesaction.color_g = salesaction_param[:color_g]
          salesaction.color_b = salesaction_param[:color_b]
          salesaction.color_a = salesaction_param[:color_a]
          salesaction.sort_key = sort
          salesaction.save!
        else
          if salesaction_param[:id].present? then
            salesaction = Salesaction.find(salesaction_param[:id])
            salesaction.destroy!
          end
        end
      end
    end
    render json: { status: 200, message: "Update Success!" }
  rescue => e
    render json: { status: 500, message: "Update Error!" }
  end

  # 見込み案件情報一覧
  def index_prospect_all
    prospects = Prospect
      .joins("LEFT OUTER JOIN divisions ON prospects.division_id = divisions.id")
      .joins("LEFT OUTER JOIN departments ON divisions.department_id = departments.id")
      .joins("LEFT OUTER JOIN users AS makeusers ON prospects.make_id = makeusers.id")
      .joins("LEFT OUTER JOIN users AS updateusers ON prospects.update_id = updateusers.id")
      .joins("LEFT OUTER JOIN products ON prospects.product_id = products.id")
      .joins("LEFT OUTER JOIN leads ON prospects.lead_id = leads.id")
      .joins("LEFT OUTER JOIN users AS mainusers ON prospects.main_person_id = mainusers.id")
      .select("prospects.id, prospects.name, departments.name as dep_name, divisions.code as div_code, divisions.name as div_name, prospects.company_name")
      .select("products.name as product_name, leads.name as lead_name, leads.period_kbn as lead_period_kbn, leads.period as lead_period")
      .select("prospects.period_fr, prospects.period_to, mainusers.name as main_person_name, prospects.order_amount")
      .select("prospects.sales_channels, prospects.sales_person, prospects.closing_date, prospects.created_at, prospects.updated_at")
      .order(updated_at: "DESC")
    render json: { status: 200, prospects: prospects }
  end

  # 見込み案件情報一覧（条件付き）
  def index_prospect
    where1 = ""
    where2 = ""
    where = ""

    # 確定／未確定／両方
    if params[:confirmed]==true then
      if params[:unconfirmed]==true then
        # 両方の場合
        where1 = "(prospects.closing_date IS NOT NULL) "
        where2 = "(prospects.closing_date IS NULL) "

        # 登録日（確定）
        if params[:created_at] == "1" then
          # 期日指定
          if params[:created_at_fr].present? then
            where1 << "and (prospects.created_at between '#{params[:created_at_fr]} 0:00:00' and '#{params[:created_at_fr]} 23:59:59') "
          end
        elsif params[:created_at] == "2" then
          # 範囲指定
          if params[:created_at_fr].present? then
            if params[:created_at_to].present? then
              where1 << "and (prospects.created_at between '#{params[:created_at_fr]} 0:00:00' and '#{params[:created_at_to]} 23:59:59') "
            else
              where1 << "and (prospects.created_at >= '#{params[:created_at_fr]} 0:00:00') "
            end
          else
            if params[:created_at_to].present? then
              where1 << "and (prospects.created_at <= '#{params[:created_at_to]} 23:59:59') "
            end
          end
        end
        # 登録日（未確定）
        if params[:un_created_at] == "1" then
          # 期日指定
          if params[:un_created_at_fr].present? then
            where2 << "and (prospects.created_at between '#{params[:un_created_at_fr]} 0:00:00' and '#{params[:un_created_at_fr]} 23:59:59') "
          end
        elsif params[:un_created_at] == "2" then
          # 範囲指定
          if params[:un_created_at_fr].present? then
            if params[:un_created_at_to].present? then
              where2 << "and (prospects.created_at between '#{params[:un_created_at_fr]} 0:00:00' and '#{params[:un_created_at_to]} 23:59:59') "
            else
              where2 << "and (prospects.created_at >= '#{params[:un_created_at_fr]} 0:00:00') "
            end
          else
            if params[:un_created_at_to].present? then
              where2 << "and (prospects.created_at <= '#{params[:un_created_at_to]} 23:59:59') "
            end
          end
        end

        # リード（確定）
        lead_where = ""
        params[:lead].map do |lead_param|
          if lead_where.present? then
            lead_where << ", "
          end
          lead_where << lead_param.to_s()
        end
        if lead_where.present? then
          where1 << "and (prospects.lead_id IN (#{lead_where})) "
        end
        # リード（未確定）
        lead_where = ""
        params[:un_lead].map do |lead_param|
          if lead_where.present? then
            lead_where << ", "
          end
          lead_where << lead_param.to_s()
        end
        if lead_where.present? then
          where2 << "and (prospects.lead_id IN (#{lead_where})) "
        end

        # 確定日
        if params[:closing_date] == "1" then
          # 期日指定
          if params[:closing_date_fr].present? then
            where1 << "and (prospects.closing_date = '#{params[:closing_date_fr]}') "
          end
        elsif params[:closing_date] == "2" then
          # 範囲指定
          if params[:closing_date_fr].present? then
            if params[:closing_date_to].present? then
              where1 << "and (prospects.closing_date between '#{params[:closing_date_fr]}' and '#{params[:closing_date_to]}') "
            else
              where1 << "and (prospects.closing_date >= '#{params[:closing_date_fr]}') "
            end
          else
            if params[:closing_date_to].present? then
              where1 << "and (prospects.closing_date <= '#{params[:closing_date_to]}') "
            end
          end
        end

        where = "(#{where1}) or (#{where2})"

      else
        # 確定のみの場合
        where = "(prospects.closing_date IS NOT NULL) "
        
        # 登録日
        if params[:created_at] == "1" then
          # 期日指定
          if params[:created_at_fr].present? then
            where << "and (prospects.created_at between '#{params[:created_at_fr]} 0:00:00' and '#{params[:created_at_fr]} 23:59:59') "
          end
        elsif params[:created_at] == "2" then
          # 範囲指定
          if params[:created_at_fr].present? then
            if params[:created_at_to].present? then
              where << "and (prospects.created_at between '#{params[:created_at_fr]} 0:00:00' and '#{params[:created_at_to]} 23:59:59') "
            else
              where << "and (prospects.created_at >= '#{params[:created_at_fr]} 0:00:00') "
            end
          else
            if params[:created_at_to].present? then
              where << "and (prospects.created_at <= '#{params[:created_at_to]} 23:59:59') "
            end
          end
        end

        # リード
        params[:lead].map do |lead_param|
          if lead_where.present? then
            lead_where << ", "
          end
          lead_where << lead_param.to_s()
        end
        if lead_where.present? then
          where << "and (prospects.lead_id IN (#{lead_where})) "
        end

        # 確定日
        if params[:closing_date] == "1" then
          # 期日指定
          if params[:closing_date_fr].present? then
            where << "and (prospects.closing_date = '#{params[:closing_date_fr]}') "
          end
        elsif params[:closing_date] == "2" then
          # 範囲指定
          if params[:closing_date_fr].present? then
            if params[:closing_date_to].present? then
              where << "and (prospects.closing_date between '#{params[:closing_date_fr]}' and '#{params[:closing_date_to]}') "
            else
              where << "and (prospects.closing_date >= '#{params[:closing_date_fr]}') "
            end
          else
            if params[:closing_date_to].present? then
              where << "and (prospects.closing_date <= '#{params[:closing_date_to]}') "
            end
          end
        end
      end

    else

      if params[:unconfirmed]==true then
        # 未確定のみの場合
        where = "(prospects.closing_date IS NULL) "
        
        # 登録日
        if params[:un_created_at] == "1" then
          # 期日指定
          if params[:un_created_at_fr].present? then
            where << "and (prospects.created_at between '#{params[:un_created_at_fr]} 0:00:00' and '#{params[:un_created_at_fr]} 23:59:59') "
          end
        elsif params[:un_created_at] == "2" then
          # 範囲指定
          if params[:un_created_at_fr].present? then
            if params[:un_created_at_to].present? then
              where << "and (prospects.created_at between '#{params[:un_created_at_fr]} 0:00:00' and '#{params[:un_created_at_to]} 23:59:59') "
            else
              where << "and (prospects.created_at >= '#{params[:un_created_at_fr]} 0:00:00') "
            end
          else
            if params[:un_created_at_to].present? then
              where << "and (prospects.created_at <= '#{params[:un_created_at_to]} 23:59:59') "
            end
          end
        end

        # リード
        lead_where = ""
        params[:un_lead].map do |lead_param|
          if lead_where.present? then
            lead_where << ", "
          end
          lead_where << lead_param.to_s()
        end
        if lead_where.present? then
          where << "and (prospects.lead_id IN (#{lead_where})) "
        end

      else
        # 両方OFFの場合（０件になるようなでたらめな条件をセット）
        where = "prospects.id < 0"
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
      where << "and (prospects.division_id IN (#{div_where})) "
    end

    # 商材
    product_where = ""
    params[:product].map do |product_param|
      if product_where.present? then
        product_where << ", "
      end
      product_where << product_param.to_s()
    end
    if product_where.present? then
      where << "and (prospects.product_id IN (#{product_where})) "
    end

    prospects = Prospect
      .joins("LEFT OUTER JOIN divisions ON prospects.division_id = divisions.id")
      .joins("LEFT OUTER JOIN departments ON divisions.department_id = departments.id")
      .joins("LEFT OUTER JOIN users AS makeusers ON prospects.make_id = makeusers.id")
      .joins("LEFT OUTER JOIN users AS updateusers ON prospects.update_id = updateusers.id")
      .joins("LEFT OUTER JOIN products ON prospects.product_id = products.id")
      .joins("LEFT OUTER JOIN leads ON prospects.lead_id = leads.id")
      .joins("LEFT OUTER JOIN users AS mainusers ON prospects.main_person_id = mainusers.id")
      .select("prospects.id, prospects.name, departments.name as dep_name, divisions.code as div_code, divisions.name as div_name, prospects.company_name")
      .select("products.name as product_name, leads.name as lead_name, leads.period_kbn as lead_period_kbn, leads.period as lead_period")
      .select("prospects.period_fr, prospects.period_to, mainusers.name as main_person_name, prospects.order_amount")
      .select("prospects.sales_channels, prospects.sales_person, prospects.closing_date, prospects.created_at, prospects.updated_at")
      .where(where)
      .order(updated_at: "DESC")
      render json: { status: 200, prospects: prospects }
  end

  # 見込み案件情報登録
  def create_prospect
    ActiveRecord::Base.transaction do
      prospect = Prospect.new
      prospect.name = prospect_params[:name]
      prospect.division_id = prospect_params[:division_id]
      prospect.make_id = prospect_params[:make_id]
      prospect.update_id = prospect_params[:update_id]
      prospect.company_name = prospect_params[:company_name]
      prospect.department_name = prospect_params[:department_name]
      prospect.person_in_charge_name = prospect_params[:person_in_charge_name]
      prospect.phone = prospect_params[:phone]
      prospect.fax = prospect_params[:fax]
      prospect.email = prospect_params[:email]
      prospect.product_id = prospect_params[:product_id]
      prospect.lead_id = prospect_params[:lead_id]
      prospect.content = prospect_params[:content]
      prospect.period_fr = prospect_params[:period_fr]
      prospect.period_to = prospect_params[:period_to]
      prospect.main_person_id = prospect_params[:main_person_id]
      prospect.order_amount = prospect_params[:order_amount]
      prospect.sales_channels = prospect_params[:sales_channels]
      prospect.sales_person = prospect_params[:sales_person]
      prospect.save!
      leadlog = Leadlog.new
      leadlog.prospect_id = prospect.id
      leadlog.lead_id = prospect.lead_id
      leadlog.save!
    end
    render json: { status: 200, message: "Create Success!" }
  rescue => e
    render json: { status: 500, message: "Create Error!" }
  end

  # 見込み案件情報更新（ID指定）
  def update_prospect_where_id
    ActiveRecord::Base.transaction do
      prospect = Prospect.find(params[:id])
      # リードレベルが変更されている場合、履歴を残す
      if prospect.lead_id != prospect_params[:lead_id] then
        leadlog = Leadlog.new
        leadlog.prospect_id = params[:id]
        leadlog.lead_id = prospect_params[:lead_id]
        leadlog.save!
      end
      prospect.name = prospect_params[:name]
      prospect.division_id = prospect_params[:division_id]
      prospect.update_id = prospect_params[:update_id]
      prospect.company_name = prospect_params[:company_name]
      prospect.department_name = prospect_params[:department_name]
      prospect.person_in_charge_name = prospect_params[:person_in_charge_name]
      prospect.phone = prospect_params[:phone]
      prospect.fax = prospect_params[:fax]
      prospect.email = prospect_params[:email]
      prospect.product_id = prospect_params[:product_id]
      prospect.lead_id = prospect_params[:lead_id]
      prospect.content = prospect_params[:content]
      prospect.period_fr = prospect_params[:period_fr]
      prospect.period_to = prospect_params[:period_to]
      prospect.main_person_id = prospect_params[:main_person_id]
      prospect.order_amount = prospect_params[:order_amount]
      prospect.sales_channels = prospect_params[:sales_channels]
      prospect.sales_person = prospect_params[:sales_person]
      prospect.save!
    end
    render json: { status: 200, message: "Update Success!" }
  rescue => e
    render json: { status: 500, message: "Update Error!" }
  end

  # 見込み案件情報成約更新（ID指定）
  def closing_prospect_where_id
    ActiveRecord::Base.transaction do
      prospect = Prospect.find(params[:id])
      prospect.closing_date = prospect_params[:closing_date]
      prospect.update_id = prospect_params[:update_id]
      prospect.save!
    end
    render json: { status: 200, message: "Update Success!" }
  rescue => e
    render json: { status: 500, message: "Update Error!" }
  end

  # 見込み案件情報削除（ID指定）
  def destroy_prospect_where_id
    ActiveRecord::Base.transaction do
      prospect = Prospect.find(params[:id])
      prospect.destroy!
    end
    render json: { status:200, message: "Delete Success!" }
  rescue => e
    render json: { status:500, message: "Delete Error"}
  end

  # 見込み案件情報検索（ID取得）
  def show_prospect_where_id
    prospect = Prospect
      .joins("LEFT OUTER JOIN divisions ON prospects.division_id = divisions.id")
      .joins("LEFT OUTER JOIN departments ON divisions.department_id = departments.id")
      .joins("LEFT OUTER JOIN users AS makeusers ON prospects.make_id = makeusers.id")
      .joins("LEFT OUTER JOIN users AS updateusers ON prospects.update_id = updateusers.id")
      .joins("LEFT OUTER JOIN products ON prospects.product_id = products.id")
      .joins("LEFT OUTER JOIN leads ON prospects.lead_id = leads.id")
      .joins("LEFT OUTER JOIN users AS mainusers ON prospects.main_person_id = mainusers.id")
      .select("prospects.id, prospects.name, departments.name as dep_name, divisions.code as div_code, divisions.name as div_name")
      .select("prospects.make_id, makeusers.name as make_name")
      .select("prospects.update_id, updateusers.name as update_name")
      .select("prospects.company_name, prospects.department_name, prospects.person_in_charge_name")
      .select("prospects.phone, prospects.fax, prospects.email, prospects.product_id, products.name as product_name")
      .select("prospects.lead_id, leads.name as lead_name, leads.period_kbn as lead_period_kbn, leads.period as lead_period")
      .select("prospects.content, prospects.period_fr, prospects.period_to, prospects.main_person_id, mainusers.name as main_person_name")
      .select("prospects.order_amount, prospects.sales_channels, prospects.sales_person")
      .select("prospects.closing_date, prospects.created_at, prospects.updated_at")
      .find(params[:id])
      render json: { status: 200, prospect: prospect }
  end

  # 月別商材別確定件数
  def count_closing_by_month_product
    # 年月配列指定
    ym = []
    _date_fr = params[:date_fr].to_date
    _date_to = params[:date_to].to_date
    date_fr = _date_fr.beginning_of_month
    date_to = _date_to.end_of_month
    date_terget = date_fr
    while date_terget < date_to do
      #　年月をゼロ詰で出力
      year = date_terget.year
      month = date_terget.month
      ym << format("%04d", year) + "年" + format("%02d", month) + "月"
      # 翌月セット
      date_terget = date_terget.next_month
    end

    datas = {}
    products = Product.order(:sort_key)
    products.map do |p|
      # data生成
      data = []
      date_terget = date_fr
      while date_terget < date_to do
        prospect = Prospect
          .where(product_id: p.id)
          .where("prospects.closing_date >= ? and prospects.closing_date <= ?", date_terget, date_terget.end_of_month)
          .select("count(prospects.id) as cnt")
        cnt = 0
        prospect.map do |pr|
          cnt = pr.cnt
        end
        data << cnt
        # 翌月セット
        date_terget = date_terget.next_month
      end
      datas[p.id] = data
    end
    render json: { status: 200, ym: ym, products: products, datas: datas }
  end

  # 月別リード数
  def count_lead_by_month
    # 年月配列指定
    ym = []
    _date_fr = params[:date_fr].to_date
    _date_to = params[:date_to].to_date
    date_fr = _date_fr.beginning_of_month
    date_to = _date_to.end_of_month
    date_terget = date_fr
    while date_terget < date_to do
      #　年月をゼロ詰で出力
      year = date_terget.year
      month = date_terget.month
      ym << format("%04d", year) + "年" + format("%02d", month) + "月"
      # 翌月セット
      date_terget = date_terget.next_month
    end

    datas = {}
    leads = Lead.order(:sort_key)
    leads.map do |l|
      # data生成
      data = []
      date_terget = date_fr
      while date_terget < date_to do
        terget_leads = Leadlog
          .joins("INNER JOIN prospects ON leadlogs.prospect_id = prospects.id")
#          .where("prospects.created_at <= ?", date_terget.end_of_month)
          .where("leadlogs.created_at <= ?", date_terget.end_of_month)
          .where("prospects.closing_date IS NULL OR prospects.closing_date > ?", date_terget.end_of_month)
          .select("leadlogs.prospect_id as prospect_id, MAX(leadlogs.created_at) as created_at")
          .group("leadlogs.prospect_id")
        count_leads = Leadlog
          .joins("INNER JOIN (#{terget_leads.to_sql}) terget_leads ON leadlogs.prospect_id = terget_leads.prospect_id AND leadlogs.created_at = terget_leads.created_at")
          .where(lead_id: l.id)
          .select("count(leadlogs.id) as cnt")
        cnt = 0
        count_leads.map do |cl|
          cnt = cl.cnt
        end
        data << cnt
          # 翌月セット
        date_terget = date_terget.next_month
      end
      datas[l.id] = data
    end
    render json: { status: 200, ym: ym, leads: leads, datas: datas }
  end

  # 営業報告一覧（見込み案件ID指定）
  def index_salesreport_where_prospect
    salesreports = Salesreport.where(prospect_id: params[:id])
      .joins("LEFT OUTER JOIN users as makeuser ON salesreports.make_id = makeuser.id")
      .joins("LEFT OUTER JOIN users as updateuser ON salesreports.update_id = updateuser.id")
      .joins("LEFT OUTER JOIN salesactions ON salesreports.salesaction_id = salesactions.id")
      .select("salesreports.id, salesreports.report_date, salesreports.make_id, makeuser.name as make_name")
      .select("salesreports.update_id, updateuser.name as update_name, salesreports.salesaction_id, salesactions.name as salesaction_name")
      .select("salesreports.topics, salesreports.created_at, salesreports.updated_at")
      .order(:report_date, updated_at: :DESC)
    render json: { status: 200, salesreports: salesreports }
  end

  # 営業報告登録
  def create_salesreport
    ActiveRecord::Base.transaction do
      salesreport = Salesreport.new
      salesreport.prospect_id = params[:id]
      salesreport.report_date = salesreport_params[:report_date]
      salesreport.make_id = salesreport_params[:make_id]
      salesreport.update_id = salesreport_params[:update_id]
      salesreport.salesaction_id = salesreport_params[:salesaction_id]
      salesreport.topics = salesreport_params[:topics]
      salesreport.content = salesreport_params[:content]
      salesreport.save!
    end
    render json: { status: 200, message: "Create Success!" }
  rescue => e
    render json: { status: 500, message: "Create Error!" }
  end

  # 営業報告更新（ID指定）
  def update_salesreport_where_id
    ActiveRecord::Base.transaction do
      salesreport = Salesreport.find(params[:id])
      salesreport.report_date = salesreport_params[:report_date]
      salesreport.update_id = salesreport_params[:update_id]
      salesreport.salesaction_id = salesreport_params[:salesaction_id]
      salesreport.topics = salesreport_params[:topics]
      salesreport.content = salesreport_params[:content]
      salesreport.save!
    end
    render json: { status: 200, message: "Update Success!" }
  rescue => e
    render json: { status: 500, message: "Update Error!" }
  end

  # 営業報告検索（ID指定）
  def show_salesreport_where_id
    salesreport = Salesreport
      .joins("LEFT OUTER JOIN users as makeuser ON salesreports.make_id = makeuser.id")
      .joins("LEFT OUTER JOIN users as updateuser ON salesreports.update_id = updateuser.id")
      .joins("LEFT OUTER JOIN salesactions ON salesreports.salesaction_id = salesactions.id")
      .select("salesreports.id, salesreports.report_date, salesreports.make_id, makeuser.name as make_name")
      .select("salesreports.update_id, updateuser.name as update_name, salesreports.salesaction_id, salesactions.name as salesaction_name")
      .select("salesreports.topics, salesreports.content, salesreports.created_at, salesreports.updated_at")
      .find(params[:id])
    render json: { status: 200, salesreport: salesreport }
  end

  # 営業報告Action別月別集計（見込み案件ID指定）
  def count_by_action_month_where_prospect
    err = false

    # 期間取得
    report_date = Salesreport
      .where(prospect_id: params[:id])
      .select("count(id) as cnt, Min(report_date) as date_fr, Max(report_date) as date_to")
    date_fr = nil
    date_to = nil
    report_date.map do |d|
      if d.cnt > 0 then
        date_fr = d.date_fr.beginning_of_month
        date_to = d.date_to.end_of_month
      else
        err = true
      end
    end

    # 年月配列生成
    ym = []
    date_terget = date_fr
    if err == false then
      while date_terget < date_to do
        #　年月をゼロ詰で出力
        year = date_terget.year
        month = date_terget.month
        ym << format("%04d", year) + "年" + format("%02d", month) + "月"
        # 翌月セット
        date_terget = date_terget.next_month
      end
    end

    target_reports = Salesreport
      .where(prospect_id: params[:id])
      .select("salesaction_id, count(id) as cnt")
      .group(:salesaction_id)
    actions = Salesaction
      .joins("LEFT OUTER JOIN (#{target_reports.to_sql}) target_reports ON salesactions.id = target_reports.salesaction_id")
      .select("salesactions.id, salesactions.name, salesactions.sort_key")
      .select("salesactions.color_r, salesactions.color_g, salesactions.color_b, salesactions.color_a")
      .select("COALESCE(target_reports.cnt,0) as cnt")
      .order(:sort_key)
#    actions = Salesaction
#      .joins("LEFT OUTER JOIN salesreports ON salesactions.id = salesreports.salesaction_id")
#      .select("salesactions.id, salesactions.name, salesactions.sort_key")
#      .select("salesactions.color_r, salesactions.color_g, salesactions.color_b, salesactions.color_a")
#      .select("count(salesreports.id) as cnt")
#      .group("salesactions.id, salesactions.name, salesactions.sort_key")
#      .group("salesactions.color_r, salesactions.color_g, salesactions.color_b, salesactions.color_a")
#      .order(:sort_key)
    
    datas = {}
    if err == false then
      actions.map do |a|
        # data生成
        data = []
        date_terget = date_fr
        while date_terget < date_to do
          report = Salesreport
            .where(prospect_id: params[:id])
            .where(salesaction_id: a.id)
            .where("salesreports.report_date >= ? and salesreports.report_date <= ?", date_terget, date_terget.end_of_month)
            .select("count(salesreports.id) as cnt")
          cnt = 0
          report.map do |r|
            cnt = r.cnt
          end
          data << cnt
          # 翌月セット
          date_terget = date_terget.next_month
        end
        datas[a.id] = data
      end
    end
    render json: { status: 200, ym: ym, actions: actions, datas: datas }
  end

  private
  # ストロングパラメータ
  def prospect_params
    params.permit(:id, :name, :division_id, :make_id, :update_id, 
      :company_name, :department_name, :person_in_charge_name, :phone, :fax, :email, 
      :product_id, :lead_id, :content, :period_fr, :period_to, :main_person_id, 
      :order_amount, :sales_channels, :sales_person, :closing_date
    )
  end
  def lead_params
    params.permit(leads: [:id, :name, :period_kbn, :period, :color_r, :color_g, :color_b, :color_a, :del])
  end
  def salesaction_params
    params.permit(salesactions: [:id, :name, :color_r, :color_g, :color_b, :color_a, :del])
  end
  def salesreport_params
    params.permit(:prospect_id, :report_date, :make_id, :update_id, :salesaction_id, :topics, :content)
  end
  def prospect_search_params
    params.permit(:confirmed, :created_at, :created_at_fr, :created_at_to, :lead[], :closing_date, :closing_date_fr, :closing_date_to, :unconfirmed, :un_created_at, :un_created_at_fr, :un_created_at_to, :un_lead[], :div[], :product[])
  end
end
