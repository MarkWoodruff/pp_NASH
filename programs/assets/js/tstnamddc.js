$(document).ready(function(){
  $('#lbcc').find('.alanineaminotransferase').closest('tr').addClass('alanineaminotransferase tstnamddc-all');
  $('#lbcc').find('.albumin').closest('tr').addClass('albumin tstnamddc-all');
  $('#lbcc').find('.alkalinephosphatase').closest('tr').addClass('alkalinephosphatase tstnamddc-all');
  $('#lbcc').find('.amylase').closest('tr').addClass('amylase tstnamddc-all');
  $('#lbcc').find('.aspartateaminotransferase').closest('tr').addClass('aspartateaminotransferase tstnamddc-all');
  $('#lbcc').find('.bilirubin').closest('tr').addClass('bilirubin tstnamddc-all');
  $('#lbcc').find('.calcium').closest('tr').addClass('calcium tstnamddc-all');
  $('#lbcc').find('.creatinine').closest('tr').addClass('creatinine tstnamddc-all');
  $('#lbcc').find('.directbilirubin').closest('tr').addClass('directbilirubin tstnamddc-all');
  $('#lbcc').find('.glucose').closest('tr').addClass('glucose tstnamddc-all');
  $('#lbcc').find('.lipase').closest('tr').addClass('lipase tstnamddc-all');
  $('#lbcc').find('.potassium').closest('tr').addClass('potassium tstnamddc-all');
  $('#lbcc').find('.protein').closest('tr').addClass('protein tstnamddc-all');
  $('#lbcc').find('.sodium').closest('tr').addClass('sodium tstnamddc-all');
  $('#lbcc').find('.ureanitrogen').closest('tr').addClass('ureanitrogen tstnamddc-all');
   });

$(document).ready(function(){
     $("#tstnamddc").change(function(){
        var textselected =  document.getElementById("tstnamddc").value ;
            target = '.' + textselected;
         $('#lbcc tbody tr').hide();
        $(target).show();
     });
   });