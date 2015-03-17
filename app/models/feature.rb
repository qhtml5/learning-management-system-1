#coding: utf-8

class Feature < ActiveRecord::Base
  attr_accessible :enabled
  extend Flip::Declarable

  strategy Flip::CookieStrategy
  strategy Flip::DatabaseStrategy
  strategy Flip::DeclarationStrategy
  default false

  #####################
  # Course pulic page #
  #####################

  feature :teacher_bio,
    default: true,
    description: "[Curso: página de venda] Exibe um box com a Bio do professor"
      
  feature :content_and_goals,
    default: true,
    description: "[Curso: página de venda] Exibe os conteúdos e objetivos que o aluno aprenderá"
  
  feature :how_course_works,
    default: true,
    description: "[Curso: página de venda] Exibe bom explicando como funcionam os cursos online"

  feature :how_easy_enroll_is,
    default: true,
    description: "[Curso: página de venda] Exibe box mostrando como é fácil fazer matrícula"
     
  feature :course_faq,
    default: true,
    description: "[Curso: página de venda] Exibe um Faq"
      
  feature :course_testimonials,
    default: true,
    description: "[Curso: página de venda] Exibe um box com depoimentos"
    
  feature :course_who_attend,
    default: true,
    description: "[Curso: página de venda] Box com público alvo"
  
  # Course Edit Page #

  feature :course_invite_students,
    default: true,
    description: "Exibe o formulario para convidar alunos"

  #######################  
  # Course Content Page #
  #######################
  
  feature :course_downloads,
    default: true,
    description: "[Curso: consumir conteúdo] Box com conteúdo para download" 
  
  feature :course_curriculum,
    default: true,
    description: "[Curso: consumir conteúdo] Exibe a ementa do curso"
    
  feature :course_progress,
    default: true,
    description: "[Curso: consumir conteúdo] Exibe progesso do aluno nos conteúdos do curso"
  
  feature :course_questions,
    default: true,
    description: "[Curso: consumir conteúdo] Box para aluno fazer perguntas"
  
  feature :course_evaluation,
    default: true,
    description: "[Curso: consumir conteúdo] Box para fazer avaliação do curso"

  feature :alumni,
    default: true,
    description: "[Curso: consumir conteúdo] Box para alunos que já fizeram o curso"
  

  ########
  # Home #
  ########

  feature :home_values,
    default: true,
    description: "[Home] Lista com principais valores do Edools"
  
  feature :home_features_list,
    default: true,
    description: "[Home] Lista de features"
    
  feature :home_image_features,
    default: false,
    description: "[Home] Lista de features com telas"

  feature :home_icone_features,
    default: true,
    description: "[Home] Lista de features com icones"

  feature :home_pricing,
    default: true,
    description: "[Home] Box com planos e preços"

  feature :home_schools,
    default: true,
    description: "[Home] Lista de escolas que usam o Edools"

  
  #########
  # Geral #
  #########
  
  feature :feedback,
    default: false,
    description: "[Geral] Botão lateral e modal para usuário dar feedback"
  
  feature :princing_page,
    default: true,
    description: "[Geral] Página com planos e preços"
  
  feature :secure_info,
    default: true,
    description: '[Geral] Informações de segurança no checkout'
    
  feature :school_bandwidth,
    default: true,
    description: '[Geral] Exibe o consumo de dados mensal da escola'

  feature :school_students,
    default: true,
    description: '[Geral] Exibe os alunos da escola'

  feature :school_user_profile,
    default: true,
    description: '[Geral] Exibe o perfil do aluno da escola'

  #########  
  # Admin #
  #########
  
  feature :admin_show_schools,
    default: true,
    description: "[Admin] Exibe dados sobre as escolas"
    
end
