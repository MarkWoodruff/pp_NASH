$(document).ready(function(){
  $('#lbh').find('.basophils--').closest('tr').addClass('basophils-- tstnamddh-all');
  $('#lbh').find('.basophils-abs').closest('tr').addClass('basophils-abs tstnamddh-all');
  $('#lbh').find('.eosinophils--').closest('tr').addClass('eosinophils-- tstnamddh-all');
  $('#lbh').find('.eosinophils-abs').closest('tr').addClass('eosinophils-abs tstnamddh-all');
  $('#lbh').find('.erythrocytes-rbc').closest('tr').addClass('erythrocytes-rbc tstnamddh-all');
  $('#lbh').find('.hematocrit').closest('tr').addClass('hematocrit tstnamddh-all');
  $('#lbh').find('.hemoglobin').closest('tr').addClass('hemoglobin tstnamddh-all');
  $('#lbh').find('.leukocytes-wbc').closest('tr').addClass('leukocytes-wbc tstnamddh-all');
  $('#lbh').find('.lymphocytes--').closest('tr').addClass('lymphocytes-- tstnamddh-all');
  $('#lbh').find('.lymphocytes-abs').closest('tr').addClass('lymphocytes-abs tstnamddh-all');
  $('#lbh').find('.mch').closest('tr').addClass('mch tstnamddh-all');
  $('#lbh').find('.mcv').closest('tr').addClass('mcv tstnamddh-all');
  $('#lbh').find('.monocytes--').closest('tr').addClass('monocytes-- tstnamddh-all');
  $('#lbh').find('.monocytes-abs').closest('tr').addClass('monocytes-abs tstnamddh-all');
  $('#lbh').find('.neutrophils--').closest('tr').addClass('neutrophils-- tstnamddh-all');
  $('#lbh').find('.neutrophils-abs').closest('tr').addClass('neutrophils-abs tstnamddh-all');
  $('#lbh').find('.percentreticulocyte').closest('tr').addClass('percentreticulocyte tstnamddh-all');
  $('#lbh').find('.platelets').closest('tr').addClass('platelets tstnamddh-all');
   });

$(document).ready(function(){
     $("#tstnamddh").change(function(){
        var textselected =  document.getElementById("tstnamddh").value ;
            target = '.' + textselected;
         $('#lbh tbody tr').hide();
        $(target).show();
     });
   });