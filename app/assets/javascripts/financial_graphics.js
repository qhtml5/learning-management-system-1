function purchases_billing(){
  var start_date = $("#start_date").val();
  var end_date = $("#end_date").val();

  $.ajax({
    url: "/purchases/finances_billing_graphic/" + "?start_date=" + start_date + "&end_date=" + end_date,
    dataType: "json",
    success: function(graphicData){
      if(graphicData.error) {
        $("#container_highchart").html("<div class='alert alert-error' style='margin-left: 10px;'><strong>" + graphicData.error + "</strong></span>");
        return false;
      } else {
        $("#container_highchart, #busca_estatistica, #hr_busca_estatistica").show();
        splineGraphic("container_highchart", "", graphicData.categories, graphicData.data, 'line');
      }
    }
  });
}

function school_purchases(){
  $.ajax({
    url: "/purchases/finances_billing_graphic_summary/",
    dataType: "json",
    success: function(graphicData){
      splineGraphic("container_highchart_summary", "", graphicData.categories, graphicData.data, 'spline');
    }
  });
}

function graficoBarra(container, title, categories, data){
  new Highcharts.Chart({
    chart: {
      renderTo: container,
      type: 'column',
      // backgroundColor:'rgba(0, 0, 0, 0.05)'
    },
    title: {
      text: title,
    },
    xAxis: {
      categories: categories,
      labels: {
        rotation: -45,
        align: 'right',
        style: {
          fontSize: '13px',
          fontFamily: 'Verdana, sans-serif'
        }
      }
    },
    yAxis: {
      min: 0,            
      title: {
        text: 'Faturamento',
        fontSize: '18px'
      },
      // labels: {
      //     enabled: true
      // }
      stackLabels: {
        enabled: true,
        formatter: function() {
          return 'R$ ' + this.total;
        },
        style: {
          fontWeight: 'bold',
          color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
        }
      }
    },
    tooltip: {
      formatter: function() {
        return '<b>'+ this.x +'</b><br/>'+
        'Total: '+ 'R$ ' + this.point.stackTotal;
      }
    },
    plotOptions: {
      column: {
        stacking: "normal",
        dataLabels: {
          enabled: false
        }
      }
      // area: {
      //         stacking: 'normal',
      //         lineColor: '#666666',
      //         lineWidth: 1,
      //         marker: {
      //             lineWidth: 1,
      //             lineColor: '#666666'
      //         }
      //     }
    },
    series: data
  });
}

function splineGraphic(container, title, categories, data, type){
  new Highcharts.Chart({
    chart: {
      renderTo: container,
      type: type,
      // backgroundColor:'rgba(0, 0, 0, 0.05)'
    },
    title: {
      text: title,
    },
    xAxis: {
      categories: categories,
      labels: {
        rotation: -45,
        align: 'right',
        style: {
          fontSize: '13px',
          fontFamily: 'Verdana, sans-serif'
        }
      }
    },
    yAxis: {
      min: 0,            
      title: {
        text: 'Faturamento',
        fontSize: '18px'
      },
      // labels: {
      //     enabled: true
      // }
      stackLabels: {
        enabled: true,
        formatter: function() {
          return 'R$ ' + this.total;
        },
        style: {
          fontWeight: 'bold',
          color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
        }
      }
    },
    tooltip: {
      formatter: function() {
        return '<b>'+ this.x +'</b><br/>'+
        'Total: '+ 'R$ ' + this.y;
      }
    },
    plotOptions: {
      
      spline: {
        dataLabels: {
          enabled: true,
          formatter: function() {
            return 'R$ ' + this.y;
          }
        },
        // enableMouseTracking: false
      },

      line: {
        dataLabels: {
          enabled: true,
          formatter: function() {
            return 'R$ ' + this.y;
          }
        },
        // enableMouseTracking: false
      }
      // area: {
      //         stacking: 'normal',
      //         lineColor: '#666666',
      //         lineWidth: 1,
      //         marker: {
      //             lineWidth: 1,
      //             lineColor: '#666666'
      //         }
      //     }
    },
    series: data
  });
}