$(document).ready(function(){
  $('#lbco').find('.c-peptide').closest('tr').addClass('c-peptide catnamddo-all');
  $('#lbco').find('.crp').closest('tr').addClass('crp catnamddo-all');
  $('#lbco').find('.ctx').closest('tr').addClass('ctx catnamddo-all');
  $('#lbco').find('.coagulation').closest('tr').addClass('coagulation catnamddo-all');
  $('#lbco').find('.cortisol').closest('tr').addClass('cortisol catnamddo-all');
  $('#lbco').find('.covid-19').closest('tr').addClass('covid-19 catnamddo-all');
  $('#lbco').find('.egfr').closest('tr').addClass('egfr catnamddo-all');
  $('#lbco').find('.estradiol').closest('tr').addClass('estradiol catnamddo-all');
  $('#lbco').find('.fsh').closest('tr').addClass('fsh catnamddo-all');
  $('#lbco').find('.glucagon').closest('tr').addClass('glucagon catnamddo-all');
  $('#lbco').find('.hba1c').closest('tr').addClass('hba1c catnamddo-all');
  $('#lbco').find('.insulin').closest('tr').addClass('insulin catnamddo-all');
  $('#lbco').find('.lipidpanel').closest('tr').addClass('lipidpanel catnamddo-all');
  $('#lbco').find('.meldscore').closest('tr').addClass('meldscore catnamddo-all');
  $('#lbco').find('.osteocalcin').closest('tr').addClass('osteocalcin catnamddo-all');
  $('#lbco').find('.pinp').closest('tr').addClass('pinp catnamddo-all');
  $('#lbco').find('.pthintact').closest('tr').addClass('pthintact catnamddo-all');
  $('#lbco').find('.patientcomments').closest('tr').addClass('patientcomments catnamddo-all');
  $('#lbco').find('.serology').closest('tr').addClass('serology catnamddo-all');
  $('#lbco').find('.serumpregnancy').closest('tr').addClass('serumpregnancy catnamddo-all');
  $('#lbco').find('.thyroidpanel').closest('tr').addClass('thyroidpanel catnamddo-all');
  $('#lbco').find('.vitamind').closest('tr').addClass('vitamind catnamddo-all');
   });

$(document).ready(function(){
     $("#catnamddo").change(function(){
        var textselected =  document.getElementById("catnamddo").value ;
            target = '.' + textselected;
         $('#lbco tbody tr').hide();
        $(target).show();
     });
   });