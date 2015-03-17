$(document).ready(function() {
  $("#search-student, #school-filters a").click(function() {
    var opts = {
      lines: 13, // The number of lines to draw
      length: 10, // The length of each line
      width: 3, // The line thickness
      radius: 5, // The radius of the inner circle
      corners: 1, // Corner roundness (0..1)
      rotate: 0, // The rotation offset
      direction: 1, // 1: clockwise, -1: counterclockwise
      color: '#000', // #rgb or #rrggbb
      speed: 0.5, // Rounds per second
      trail: 60, // Afterglow percentage
      shadow: false, // Whether to render a shadow
      hwaccel: false, // Whether to use hardware acceleration
      className: 'spinner', // The CSS class to assign to the spinner
      zIndex: 2e9, // The z-index (defaults to 2000000000)
      top: 'auto', // Top position relative to parent in px
      left: 'auto' // Left position relative to parent in px
    };
    var spinner = new Spinner(opts).spin();
    $("#students-table").html(spinner.el);
  }); 

  $('#students_leads_tags').keydown(function(e) {
    if (e.keyCode == 32) {
        return false;
    }
  });

  $(".cancel-btn").click(function(e) {
    $("#action-buttons").show();
    $("#action-forms").hide();
    e.preventDefault();
  });

  $("#cancel-btn-message").click(function(e) {
    $("#students_leads_message").val("");
  });

  $("#cancel-btn-tags").click(function(e) {
    $("#students_leads_tags").val("");
  });

  $(".check-box").change(function() {
    if($(".check-box:checked").length > 0) {
      $("#action-buttons a").removeClass("disabled");
    } else {
      $("#action-buttons a").addClass("disabled");
      $("#action-buttons").show();
      $("#action-forms").hide();
    }
  });

  $("#add-tags-button").click(function(e) {
    if(!$(this).hasClass('disabled')) {
      $("#action-buttons").hide();
      $("#message-form").hide();
      $("#action-forms").show();
      $("#tag-form").show();
    }
    e.preventDefault();
  });

  $("#add-message-button").click(function(e) {
    if(!$(this).hasClass('disabled')) {
      $("#action-buttons").hide();
      $("#tag-form").hide();
      $("#action-forms").show();
      $("#message-form").show();
    }
    e.preventDefault();
  });
  
  $('#check_all').on('click', function() {
    $('.check-box').prop('checked', $(this).is(":checked"));

    if($(this).is(":checked")) {
      $("#action-buttons a").removeClass("disabled");
    } else {
      $("#action-buttons a").addClass("disabled");
      $("#action-buttons").show();
      $("#action-forms").hide();
    }
  });

  $('#tags').on("mouseenter", "p", function() {
    $(this).find(".destroy-tag").show();
  }).on("mouseleave", "p", function() {
    $(this).find(".destroy-tag").hide();
  });

  $('#students, #tags').on("mouseenter", ".label", function() {
    $(this).find(".delete-tag-user").css('visibility', 'visible');
  }).on("mouseleave", ".label", function() {
    $(this).find(".delete-tag-user").css('visibility', 'hidden');
  });
});