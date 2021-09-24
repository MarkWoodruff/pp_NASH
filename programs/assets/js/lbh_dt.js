

$(document).ready( function () {
  $('#lbh').DataTable( {

        initComplete: function () {
            this.api().columns().every( function () {
                var column = this;
                var select = $('<select><option value=""></option></select>')
                    .appendTo( $(column.footer()).empty() )
                    .on( 'change', function () {
                        var val = $.fn.dataTable.util.escapeRegex(
                            $(this).val()
                        );
 
                        column
                            .search( val ? '^'+val+'$' : '', true, false )
                            .draw();
                    } );
 
                column.data().unique().sort().each( function ( d, j ) {
                    select.append( '<option value="'+d+'">'+d+'</option>' )
                } );
            } );
        },

  		"autoWidth": true,
  		"ordering": false,
  		"paging": false,
  		"pageLength": 25,
  		"scrollY": "75vh",
  		"scrollX": true,
  		"info": false,
  		"filter": false,
  		"scrollCollapse": true,
      "language": {
        "emptyTable": " "
      }
  });
} );