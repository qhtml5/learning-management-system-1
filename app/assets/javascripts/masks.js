$(function($){
	$("._date").mask("99/99/9999");
	$("._phone_number").mask("(99) 9999-9999?9", { placeholder: "" });
	$("._cpf").mask("999.999.999-99", { placeholder: "" });
	$("._zip_code").mask("99999-999", { placeholder: "" });
	$("#payment_credit_card_number").mask("99999999999?99999999", { placeholder: ""});
	$("._price").mask("999,99", { placeholder: "" });
});