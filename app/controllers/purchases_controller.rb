#coding: utf-8

class PurchasesController < ApplicationController
  before_filter :authenticate_user!, only: [:finances_billing_graphic, :finances_billing_graphic_summary]
	def notification
		@purchase = Purchase.unscoped.find_by_identificator(params["id_transacao"])

    if @purchase && @purchase.cart_items.present?
      old_purchase_status = @purchase.payment_status
      School.current_id = @purchase.school.id

			@purchase.payment_status = Purchase::PAYMENT_STATUS[params["status_pagamento"]]
			@purchase.moip_code = params["cod_moip"]

      if Rails.env.production? && params["valor"].present?
  			@purchase.amount_paid = params["valor"]
      elsif params["valor"].present?
        @purchase.amount_paid = (params["valor"].to_f * 100).to_i
      end
      
			@purchase.payment_type = params["tipo_pagamento"]
			@purchase.save!

      if @purchase.authorized?
        @purchase.save_validity_date
        @purchase.create_confirmed_notification
        @purchase.register_on_rdstation "confirmado"
      end
		end
	
		render :nothing => true
	end

	def finances_billing_graphic
    begin
      @start_date = unless params[:start_date].empty?
        Date.strptime(params[:start_date], "%d/%m/%Y").to_datetime
      else
        Time.now
      end

      @end_date = if params[:end_date].chars.any?
  			Date.strptime(params[:end_date], "%d/%m/%Y").to_datetime.change(:hour => 23, :min => 59, :sec => 59)
      else
        Time.now.change(:hour => 23, :min => 59, :sec => 59)
      end
    rescue
      @graphic = {}
      @graphic[:error] = "Data inválida"
      render :json => @graphic and return
    end

    @purchases = current_user.school.purchases.payment_confirmed.between(@start_date, @end_date)

    @graphic = {}
    @graphic[:categories] = []
    purchases_on_graphic = {}
    case graphic_categories[:unidade]
    when :hours
	    @purchases = @purchases.group_by { |a| a.created_at.hour }
      @graphic[:categories] = (0..23).to_a
      @graphic[:categories].each { |categoria| purchases_on_graphic[categoria] = @purchases[categoria].nil? ? 0 : (@purchases[categoria].sum(&:amount_paid).to_f / 100) }
      @graphic[:categories].map! { |hora| "#{hora}h"}
      purchases_on_graphic = purchases_on_graphic.sort_by {|k,v| k }.map {|e| e[1]}
    when :days
      @purchases = @purchases.group_by { |a| a.created_at.strftime("%d/%m") } 
      graphic_categories[:interval].times { |n| @graphic[:categories] << (@end_date - n.days).strftime("%d/%m") }
      @graphic[:categories] = @graphic[:categories].sort_by {|k,v| Date.strptime(k, "%d/%m")}
      @graphic[:categories].each { |categoria| purchases_on_graphic[categoria] = @purchases[categoria].nil? ? 0 : (@purchases[categoria].sum(&:amount_paid).to_f / 100) }
      @graphic[:categories].map! do |c| 
        c.gsub(/\/\d{2}/, "/01" => "/Jan", "/02" => "/Fev", "/03" => "/Mar", 
                          "/04" => "/Abr", "/05" => "/Mai", "/06" => "/Jun",
                          "/07" => "/Jul", "/08" => "/Ago", "/09" => "/Set",
                          "/10" => "/Out", "/11" => "/Nov", "/12" => "/Dez")
      end
      purchases_on_graphic = purchases_on_graphic.sort_by {|k,v| Date.strptime(k, "%d/%m") }.map {|e| e[1]}
    when :months
      @purchases = @purchases.group_by { |a| a.created_at.strftime("%m/%Y") }
      graphic_categories[:interval].times { |n| @graphic[:categories] << (@end_date - n.months).strftime("%m/%Y") }
      @graphic[:categories] = @graphic[:categories].sort_by {|k,v| Date.strptime(k, "%m/%Y")}
      @graphic[:categories].each { |categoria| purchases_on_graphic[categoria] = @purchases[categoria].nil? ? 0 : (@purchases[categoria].sum(&:amount_paid).to_f / 100) }
      @graphic[:categories].map! do |c| 
        c.gsub(/\d{2}\//, "01/" => "Jan/", "02/" => "Fev/", "03/" => "Mar/", 
                          "04/" => "Abr/", "05/" => "Mai/", "06/" => "Jun/",
                          "07/" => "Jul/", "08/" => "Ago/", "09/" => "Set/",
                          "10/" => "Out/", "11/" => "Nov/", "12/" => "Dez/")
      end
      purchases_on_graphic = purchases_on_graphic.sort_by {|k,v| Date.strptime(k, "%m/%Y") }.map {|e| e[1]}
    when :years
      @purchases = @purchases.group_by { |a| a.created_at.year }
      graphic_categories[:interval].times { |n| @graphic[:categories] << (@end_date - n.years).year }
      @graphic[:categories] = @graphic[:categories].sort_by {|k,v| k}
      @graphic[:categories].each { |categoria| purchases_on_graphic[categoria] = @purchases[categoria].nil? ? 0 : (@purchases[categoria].sum(&:amount_paid).to_f / 100) }
      purchases_on_graphic = purchases_on_graphic.sort_by {|k,v| k}.map {|e| e[1]}
    end

    if purchases_on_graphic.any?
      @graphic[:data] = [ { :name => "Total", :data => purchases_on_graphic } ]                                                                
    else
      @graphic[:data] = [ { :name => "Total", :data => [["Nenhum", 0]] } ]
    end

    render :json => @graphic
  end

  def finances_billing_graphic_summary 
    @start_date = (Time.now - 5.months).beginning_of_month
    @end_date = Time.now.change(:hour => 23, :min => 59, :sec => 59)

    @purchases = current_user.school.purchases.payment_confirmed.between(@start_date, @end_date)

    @graphic = {}
    @graphic[:categories] = [] 
    purchases_on_graphic = {}

    @purchases = @purchases.group_by { |a| a.created_at.strftime("%m/%Y") }
    graphic_categories[:interval].times { |n| @graphic[:categories] << (@end_date - n.months).strftime("%m/%Y") }
    @graphic[:categories] = @graphic[:categories].sort_by {|k,v| Date.strptime(k, "%m/%Y")}
    @graphic[:categories].each { |categoria| purchases_on_graphic[categoria] = @purchases[categoria].nil? ? 0 : (@purchases[categoria].sum(&:amount_paid).to_f / 100) }
    @graphic[:categories].map! do |c| 
      c.gsub(/\d{2}\//, "01/" => "Jan/", "02/" => "Fev/", "03/" => "Mar/", 
                        "04/" => "Abr/", "05/" => "Mai/", "06/" => "Jun/",
                        "07/" => "Jul/", "08/" => "Ago/", "09/" => "Set/",
                        "10/" => "Out/", "11/" => "Nov/", "12/" => "Dez/")
    end
    purchases_on_graphic = purchases_on_graphic.sort_by {|k,v| Date.strptime(k, "%m/%Y") }.map {|e| e[1]}    

    if purchases_on_graphic.any?
      @graphic[:data] = [ { :name => "Total", :data => purchases_on_graphic } ]                                                                
    else
      @graphic[:data] = [ { :name => "Total", :data => [["Nenhum", 0]] } ]
    end

    render :json => @graphic
  end

  def affiliate_graphic
    @start_date = (Time.now - 5.months).beginning_of_month
    @end_date = Time.now.change(:hour => 23, :min => 59, :sec => 59)

    @course = Course.find(params[:course_id])
    @coupon = @course.coupons.find_by_name(params[:coupon_name])

    @cart_items = CartItem.with_purchase.with_price.where(coupon_id: @coupon.id).payment_confirmed.between(@start_date, @end_date).includes(:purchase)

    @graphic = {}
    @graphic[:categories] = [] 
    purchases_on_graphic = {}

    @cart_items = @cart_items.group_by { |ci| ci.purchase.created_at.strftime("%m/%Y") }
    graphic_categories[:interval].times { |n| @graphic[:categories] << (@end_date - n.months).strftime("%m/%Y") }
    @graphic[:categories] = @graphic[:categories].sort_by {|k,v| Date.strptime(k, "%m/%Y")}
    @graphic[:categories].each { |categoria| purchases_on_graphic[categoria] = @cart_items[categoria].nil? ? 0 : (@cart_items[categoria].sum(&:price).to_f / 100) }
    @graphic[:categories].map! do |c| 
      c.gsub(/\d{2}\//, "01/" => "Jan/", "02/" => "Fev/", "03/" => "Mar/", 
                        "04/" => "Abr/", "05/" => "Mai/", "06/" => "Jun/",
                        "07/" => "Jul/", "08/" => "Ago/", "09/" => "Set/",
                        "10/" => "Out/", "11/" => "Nov/", "12/" => "Dez/")
    end
    purchases_on_graphic = purchases_on_graphic.sort_by {|k,v| Date.strptime(k, "%m/%Y") }.map {|e| e[1]}    

    if purchases_on_graphic.any?
      @graphic[:data] = [ { :name => "Total", :data => purchases_on_graphic } ]                                                                
    else
      @graphic[:data] = [ { :name => "Total", :data => [["Nenhum", 0]] } ]
    end

    render :json => @graphic
  end

	private
  def graphic_categories
    graphic_categories = {}
    graphic_categories[:unidade] = :years
    graphic_categories[:interval] = (@end_date.year - @start_date.year) + 1

    if @start_date.year == @end_date.year
      graphic_categories[:unidade] = :months
      graphic_categories[:interval] = (@end_date.month - @start_date.month) + 1

      if @start_date.month == @end_date.month
        graphic_categories[:unidade] = :days
        graphic_categories[:interval] = (@end_date.day - @start_date.day) + 1

        if @start_date.day == @end_date.day
          graphic_categories[:unidade] = :hours
        end
      end
    end

    graphic_categories
  end
end