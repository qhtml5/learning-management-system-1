$(document).ready(function(){
  $("#widget-notice").delay(4000).fadeOut();

	$("#course_price").maskMoney({
		symbol:"R$ ", decimal:",", thousands: "."
	});

	$("._date").datepicker({
		altFormat:"dd/mm/yy",
	  dateFormat:"dd/mm/yy",changeMonth:!0,changeYear:!0,
	  closeText:"Pronto",prevText:"<",nextText:">",currentText:"Hoje",
	  monthNames:["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"],
	  monthNamesShort:["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"],
	  dayNames:["Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"],dayNamesShort:["Dom","Seg","Ter","Qua","Qui","Sex","Sáb"],
	  dayNamesMin:["Do","Se","Te","Qa","Qu","Sx","Sa"]
	});

	$("._date_minimum").datepicker({
		altFormat:"dd/mm/yy",
	  dateFormat:"dd/mm/yy",changeMonth:!0,changeYear:!0,
	  closeText:"Pronto",prevText:"<",nextText:">",currentText:"Hoje",
	  monthNames:["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"],
	  monthNamesShort:["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"],
	  dayNames:["Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"],dayNamesShort:["Dom","Seg","Ter","Qua","Qui","Sex","Sáb"],
	  dayNamesMin:["Do","Se","Te","Qa","Qu","Sx","Sa"],
		minDate: new Date(2013, 7, 29),
		maxDate: 0
	});

	$("._btn-loading, .btn-loading").click(function () {
		$(this).after('<button class="btn disabled">Enviando...</button>');
		$(this).hide();
	})
});
