$(document).ready(function() {
  cells = $('.td-sortable').find('li').length;

  // desired_width = 940 / cells + 'px';
  // $('.table td').css('width', desired_width);

  $(".td-sortable").sortable({
    stop: function(e, ui) {
      ui.item.children('li').effect('highlight', {}, 1000);
    },
    update: function(e, ui) {
      item_id = ui.item.data('item-id');
      order_position = ui.item.index();
      $.ajax({
        type: 'POST',
        url: $(this).data('update-url'),
        dataType: 'json',
        data: { id: item_id, position: order_position }
      })
    }
  });
});