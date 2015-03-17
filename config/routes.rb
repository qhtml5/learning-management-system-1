Edools::Application.routes.draw do

  constraints(Subdomain) do
    root to: 'schools#home', constraints: { format: /(html)/}

    resources :courses, :path => "curso", :only => [:show] do
      member do
        post 'request_certificate', path: 'solicitar_certificado'
        get 'add_to_cart', :path => "adicionar_ao_carrinho"
        get 'remove_from_cart', :path => "remover_do_carrinho"
        get 'content', :path => "conteudo" 
        post 'submit_message'
        post ':message_id/submit_answer' => "courses#submit_answer", as: :submit_answer
        delete ':message_id' => "courses#destroy_message", as: :destroy_message
        post ':cart_item_id/remove_coupon' => "courses#remove_coupon", as: :remove_coupon
        post ':cart_item_id/add_coupon' => "courses#add_coupon", as: :add_coupon
        get 'checkout_free', path: "matricule-se"
        get 'checkout_restrict', path: "restrito"
        get 'checkout_invitation/:user_email' => "courses#checkout_invitation", as: :checkout_invitation, path: "convite"
        post "create_lead"
        get 'coupon_sent', path: "cupom_enviado"
        get 'affiliate/:coupon' => "courses#affiliate", path: "afiliado/:coupon", as: :affiliate
      end
      resources :medias, only: [:show] do
        member do
          post :ended
        end
      end
    end     

    resources :schools, only: [] do
      member do
        get 'home'
      end
    end

    resources :checkouts, :path => '/checkout', :only => [] do
      collection do
        get 'cart', path: 'carrinho'
        post 'social', :path => "conecte-se"
        get 'social', :path => "conecte-se"
        get 'register', :path => "completar_cadastro"
        get 'payment', :path => "pagamento"
        get 'finish', :path => "sucesso"
        get 'finish_coupon', :path => "concluido"
        get 'failure', :path => "erro_pagamento"
        get 'finish_online_payment', :path => "sucesso_pagamento"
        get 'failure', :path => "erro_pagamento"
        get 'exception', :path => "overload"
        post 'pay_credit_card'
        post 'pay_online_debit'
        post 'pay_billet'
      end
    end   

    resources :purchases, :only => [:create] do
      collection do
        get "finances_billing_graphic"
        get "finances_billing_graphic_summary"
        get "affiliate_graphic"
      end
    end

    namespace :dashboard do 
      root :to => 'pages#index'
      
      resources :layout_configurations, :path => '/layout', only: [:index, :update]

      resources :courses do
        member do
          get 'library', path: 'biblioteca'
          get 'invite_students', path: 'convidar_alunos'
          get 'edit_links_downloads'
          get 'edit_basic_info'
          get 'edit_detailed_info'
          get 'edit_image'
          get 'edit_promo_video'
          get 'edit_available_time'
          get 'edit_instructor'
          post 'update_promo_video'
          get 'edit_privacy'
          get 'edit_teachers'
          get 'edit_price_and_coupon'
          get 'edit_certificate'
          post 'publish'
          post 'unpublish'
          get 'notifications'
          post 'create_lead'
        end
        collection do
          get 'leads'
          get "conversion_graphic"
          get 'index_teaching'
          get 'course_categories', path: "categorias"
          post 'sort_course_categories'
          put 'rename_course_category'
        end

        resources :lessons, :only => [:index] do
          member do
            put 'rename'
          end

          collection do
            post 'sort'
          end
        end
        resources :medias, only: [] do 
          member do
            put 'rename'
          end

          collection do
            post 'sort'
          end
        end
        resources :coupons
      end
      
      resources :schools, only: [:create, :update] do
        collection do
          get 'configurations_integrations', path: 'configuracoes/integracoes'
          get 'configurations_general', path: 'configuracoes/gerais'
          get 'configurations_plan', path: 'configuracoes/plano'
          get 'configurations_moip', path: 'configuracoes/moip'
          get 'configurations_domain', path: 'configuracoes/dominio'
          get 'configurations_notifications', path: 'configuracoes/notificacoes'
          get 'library', path: 'biblioteca'
          get 'team', path: 'equipe'
          get 'edit_basic_info', path: 'informacoes'
          get 'finances', path: 'financeiro'
          get 'conversions', path: 'conversoes'
          get 'course_evaluations', path: 'avaliacoes'
          get 'certificate'
          get 'coupons', path: 'cupons'
          get ':course/:student/certificate' => 'schools#show_certificate', as: :show_certificate, defaults: { format: "pdf" }
        end
      end
      
      resources :users, as: "students", path: "aluno", only: [:show, :index]
    end    
  end

  constraints(NotSubdomain) do
    root :to => "pages#index"

    namespace :admin do 
      root :to => 'pages#index'
      
      resources :pages, only: [] do
        collection do
          get :courses
          get :switch_to_school
        end
      end

      resources :feedbacks, :only => [:index]
      
      resources :features, only: [ :index ] do
        resources :feature_strategies, only: [ :update, :destroy ]
      end
    end

    namespace :dashboard do
      resources :schools, only: [:create, :update] do
        collection do
          get 'wizard_basic_info'
          get 'wizard_choose_plans'
        end
      end    
    end

    mount Flip::Engine => "/admin/features"

    match '/ensinar' => 'pages#teach', :as => :teach_page
    match '/aprender' => 'pages#learn', :as => :learn_page
    match '/planos' => 'pages#pricing', :as => :pricing_page
    match '/funcionalidades' => 'pages#features', :as => :features_page
  end

  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions", passwords: "users/passwords" }, :path => "usuarios"
  devise_scope :users do
    get 'perfil/pedidos' => 'users#purchases', :as => :purchases_user
    get 'perfil/editar' => 'users#edit_profile', :as => :edit_profile_user
    get 'perfil/mensagens' => 'users#messages', :as => :messages_user
    get 'dashboard/notifications' => 'users#notifications', as: :notifications_user, path: 'dashboard/notificacoes'
    post 'dashboard/mark_all_notifications_as_read' => 'users#mark_all_notifications_as_read', as: :mark_all_notifications_as_read_user
  end
  
  resources :pages, :only => [] do
    collection do
      post 'new_feedback'
    end
  end

  post 'moip/notification' => 'purchases#notification'
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'

end
