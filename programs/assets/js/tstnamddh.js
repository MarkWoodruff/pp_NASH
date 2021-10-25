$(document).ready(function(){
  $('#lbch').find('.basophils').closest('tr').addClass('basophils tstnamddh-all');                       
  $('#lbch').find('.basophils-leukocytes').closest('tr').addClass('basophils-leukocytes tstnamddh-all');            
  $('#lbch').find('.eosinophils').closest('tr').addClass('eosinophils tstnamddh-all');                     
  $('#lbch').find('.eosinophils-leukocytes').closest('tr').addClass('eosinophils-leukocytes tstnamddh-all');          
  $('#lbch').find('.ery-meancorpuscularhemoglobin').closest('tr').addClass('ery-meancorpuscularhemoglobin tstnamddh-all');
  $('#lbch').find('.ery-meancorpuscularvolume').closest('tr').addClass('ery-meancorpuscularvolume tstnamddh-all');    
  $('#lbch').find('.erythrocytes').closest('tr').addClass('erythrocytes tstnamddh-all');                    
  $('#lbch').find('.hematocrit').closest('tr').addClass('hematocrit tstnamddh-all');                      
  $('#lbch').find('.hemoglobin').closest('tr').addClass('hemoglobin tstnamddh-all');                      
  $('#lbch').find('.leukocytes').closest('tr').addClass('leukocytes tstnamddh-all');                      
  $('#lbch').find('.lymphocytes').closest('tr').addClass('lymphocytes tstnamddh-all');                     
  $('#lbch').find('.lymphocytes-leukocytes').closest('tr').addClass('lymphocytes-leukocytes tstnamddh-all');          
  $('#lbch').find('.monocytes').closest('tr').addClass('monocytes tstnamddh-all');                       
  $('#lbch').find('.monocytes-leukocytes').closest('tr').addClass('monocytes-leukocytes tstnamddh-all');            
  $('#lbch').find('.neutrophils').closest('tr').addClass('neutrophils tstnamddh-all');                     
  $('#lbch').find('.neutrophils-leukocytes').closest('tr').addClass('neutrophils-leukocytes tstnamddh-all');          
  $('#lbch').find('.platelets').closest('tr').addClass('platelets tstnamddh-all');                       
  $('#lbch').find('.reticulocyte-erythrocytes').closest('tr').addClass('reticulocyte-erythrocytes tstnamddh-all');
   });

$(document).ready(function(){
     $("#tstnamddh").change(function(){
        var textselected =  document.getElementById("tstnamddh").value ;
            target = '.' + textselected;
         $('#lbch tbody tr').hide();
        $(target).show();
     });
   });