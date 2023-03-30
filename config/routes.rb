Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      mount_devise_token_auth_for 'User', at: 'auth'

      # 組織管理
      resources :organization do
        collection do
          get :index_dep_all
          post :create_dep
          get :index_div_all
          post :create_div
          get :index_emp_all
          get :index_emp_where_not_assign
          post :create_approval
        end
        member do
          get :index_div_where_dep
          get :show_dep_where_id
          patch :update_dep_where_id
          get :show_div_where_id
          patch :update_div_where_id
          delete :destroy_dep_where_id
          delete :destroy_div_where_id
          get :show_emp_where_id
          patch :update_emp_where_id
          patch :update_password_without_currentpassword
          get :index_emp_where_dep_direct
          get :index_emp_where_div
          get :index_approval_where_dep_direct
          get :index_approval_where_div
          get :show_div_where_depdummy
          delete :destroy_approval_where_id
        end
      end

      # 機能権限
      resources :application do
        collection do
          get :index_role_all
          get :index_temp_all
          post :update_temp
          post :create_role
        end
        member do
          get :index_app_where_role
          delete :destroy_role_where_id
          get :show_role_where_id
          patch :update_role_where_id
        end
      end

      # マスタメンテ
      resources :master do
        collection do
          get :index_product
          post :update_product
        end
      end

      # プロジェクト
      resources :project do
        collection do
          get :index_project_all
          patch :index_project
          post :create_project
          get :index_projectlist
          get :index_audit_todo
        end
        member do
          get :show_project_where_id
          patch :update_project_where_id
          get :index_audit_where_project_kinds
          patch :update_audits
          get :index_log_where_project
          get :show_report_where_projectid
          patch :update_report_where_id
          get :index_todo
        end
      end

      # 見込み案件
      resources :prospect do
        collection do
          get :index_lead
          post :update_lead
          get :index_salesaction
          post :update_salesaction
          get :index_prospect_all
          post :index_prospect
          post :create_prospect
          get :count_closing_by_month_product
          get :count_lead_by_month
        end
        member do
          patch :update_prospect_where_id
          patch :closing_prospect_where_id
          delete :destroy_prospect_where_id
          get :show_prospect_where_id
          get :index_salesreport_where_prospect
          post :create_salesreport
          patch :update_salesreport_where_id
          get :show_salesreport_where_id
          get :count_by_action_month_where_prospect
        end
      end

    end
  end
end
