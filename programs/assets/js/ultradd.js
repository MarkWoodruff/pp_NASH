$(document).ready(function(){
  $('#ultralist').find('.yes').closest('tr').addClass('yes ultradd-all');
  $('#ultralist').find('.no').closest('tr').addClass('no ultradd-all');
  $('#ultralist').find('.miss').closest('tr').addClass('miss ultradd-all');
   });

$(document).ready(function(){
     $("#ultradd").change(function(){
        var textselected =  document.getElementById("ultradd").value ;
            target = '.' + textselected;
         $('#ultralist tbody tr').hide();
        $(target).show();
     });
   });