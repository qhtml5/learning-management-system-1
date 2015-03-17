// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require bootstrap-wysihtml5
//= require bootstrap-wysihtml5/locales/pt-BR
//= require best_in_place
//= require_tree .
//= require application_custom
//= require highcharts
//= require jquery-ui-timepicker-addon
//= require_self

// if(Object.keys(window.opener).length > 0) {
// 	if(window.location == window.opener.location.href + "#_=_") {
// 		window.opener.location.reload(true);
// 	} else {
// 	  window.opener.location.href = window.location;
//   }
//   window.close();
// }

// $(".best_in_place").best_in_place();

$(document).ready(function() {
  jQuery(".best_in_place").best_in_place();

	// $('.wysihtml5').each(function(i, elem) {
	//   $(elem).wysihtml5({locale: "pt-BR"});
	// });
});