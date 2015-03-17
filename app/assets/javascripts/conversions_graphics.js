function conversions_graphic(){
  course_ids = $("#conversions-course-ids").html().split(";");
  var start_date = $("#start_date").val();
  var end_date = $("#end_date").val();

  $.ajax({
    url: "/dashboard/courses/conversion_graphic?course_ids=" + course_ids + "&start_date=" + start_date + "&end_date=" + end_date,
    dataType: "json",
    success: function(chartData){
      $("#conversion-disclaimer").removeClass("hidden");
      for(i=0; i<chartData.length; i++) {
        $("#container-highchart-course-" + i).removeClass("hidden");
        funnelChart("container-highchart-course-" + i, chartData[i].title, chartData[i].data);
      }
    }
  });
}

function funnelChart(container, title, data){
  new Highcharts.Chart({
    chart: {
      renderTo: container,
      type: 'funnel',
      marginRight: 100
    },
    title: {
      text: title,
      x: -50
    },
    plotOptions: {
      series: {
        dataLabels: {
          enabled: true,
          format: '<b>{point.name}</b> ({point.y:,.0f})',
          color: 'black',
          softConnector: true
        },
        neckWidth: '30%',
        neckHeight: '25%'
        //-- Other available options
        // height: pixels or percent
        // width: pixels or percent
      }
    },
    legend: {
      enabled: false
    },
    series: data
  });
}