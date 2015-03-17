#coding: utf-8
class SupportMailer < ActionMailer::Base
  default to: ["rafael@bizstart.com.br", "augusto@bizstart.com.br"],
          :from => "Rafael - Edools <contato@edools.com>"
  helper :mailer
  layout 'school_mail'

  def checkout_failure(cart, user, response)
    @response = response
    @cart = cart
    @user = user
    @courses = @cart.cart_items.map(&:course)
    @school = @cart.school

    mail(:subject => "[Edools ERROR] Falha no Checkout")
  end

  def payment_credit_card_failure(purchase, credit_card)
    @credit_card = credit_card
    @purchase = purchase
    @user = @purchase.user
    @courses = @purchase.cart_items.map(&:course)
    @school = @purchase.school

    mail(:subject => "[Edools ERROR] Falha no Pagamento")
  end  

  def checkout_exception(cart, user, exception)
    @exception = exception
    @cart = cart
    @user = user
    @courses = @cart.cart_items.map(&:course)
    @school = @cart.school

    mail(:subject => "[Edools ERROR] Exceção no Checkout")
  end

end