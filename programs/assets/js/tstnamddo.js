$(document).ready(function(){
  $('#lbco').find('.-disclaimertext').closest('tr').addClass('-disclaimertext tstnamddo-all');
  $('#lbco').find('.25-hydroxyvitamind').closest('tr').addClass('25-hydroxyvitamind tstnamddo-all');
  $('#lbco').find('.amcortisol').closest('tr').addClass('amcortisol tstnamddo-all');
  $('#lbco').find('.beta-crosslapsb-ctx').closest('tr').addClass('beta-crosslapsb-ctx tstnamddo-all');
  $('#lbco').find('.c-peptide').closest('tr').addClass('c-peptide tstnamddo-all');
  $('#lbco').find('.cholesterol').closest('tr').addClass('cholesterol tstnamddo-all');
  $('#lbco').find('.choriogonadotropinbeta-qualitative').closest('tr').addClass('choriogonadotropinbeta-qualitative tstnamddo-all');
  $('#lbco').find('.coritsol').closest('tr').addClass('coritsol tstnamddo-all');
  $('#lbco').find('.cortisolcollectiontime').closest('tr').addClass('cortisolcollectiontime tstnamddo-all');
  $('#lbco').find('.creactiveprotein').closest('tr').addClass('creactiveprotein tstnamddo-all');
  $('#lbco').find('.estimatedglomerularfiltrationrate').closest('tr').addClass('estimatedglomerularfiltrationrate tstnamddo-all');
  $('#lbco').find('.estradiol').closest('tr').addClass('estradiol tstnamddo-all');
  $('#lbco').find('.folliclestimulatinghormone').closest('tr').addClass('folliclestimulatinghormone tstnamddo-all');
  $('#lbco').find('.glucagon').closest('tr').addClass('glucagon tstnamddo-all');
  $('#lbco').find('.hdlcholesterol').closest('tr').addClass('hdlcholesterol tstnamddo-all');
  $('#lbco').find('.hemoglobina1c').closest('tr').addClass('hemoglobina1c tstnamddo-all');
  $('#lbco').find('.hepatitisbsurfaceantigen').closest('tr').addClass('hepatitisbsurfaceantigen tstnamddo-all');
  $('#lbco').find('.hepatitiscantibody').closest('tr').addClass('hepatitiscantibody tstnamddo-all');
  $('#lbco').find('.hiv1-2').closest('tr').addClass('hiv1-2 tstnamddo-all');
  $('#lbco').find('.insulin').closest('tr').addClass('insulin tstnamddo-all');
  $('#lbco').find('.ldlcholesterol').closest('tr').addClass('ldlcholesterol tstnamddo-all');
  $('#lbco').find('.meldscore').closest('tr').addClass('meldscore tstnamddo-all');
  $('#lbco').find('.midnightcortisol').closest('tr').addClass('midnightcortisol tstnamddo-all');
  $('#lbco').find('.osteocalcin').closest('tr').addClass('osteocalcin tstnamddo-all');
  $('#lbco').find('.parathyroidhormoneintact').closest('tr').addClass('parathyroidhormoneintact tstnamddo-all');
  $('#lbco').find('.patientcomments').closest('tr').addClass('patientcomments tstnamddo-all');
  $('#lbco').find('.pmcortisol').closest('tr').addClass('pmcortisol tstnamddo-all');
  $('#lbco').find('.procollageniintactn-terminal').closest('tr').addClass('procollageniintactn-terminal tstnamddo-all');
  $('#lbco').find('.prothrombinintl-normalizedratio').closest('tr').addClass('prothrombinintl-normalizedratio tstnamddo-all');
  $('#lbco').find('.prothrombintime').closest('tr').addClass('prothrombintime tstnamddo-all');
  $('#lbco').find('.testresult').closest('tr').addClass('testresult tstnamddo-all');
  $('#lbco').find('.thyroidstimulatinghormone').closest('tr').addClass('thyroidstimulatinghormone tstnamddo-all');
  $('#lbco').find('.triglycerides').closest('tr').addClass('triglycerides tstnamddo-all');
  $('#lbco').find('.wasdetected').closest('tr').addClass('wasdetected tstnamddo-all');
   });

$(document).ready(function(){
     $("#tstnamddo").change(function(){
        var textselected =  document.getElementById("tstnamddo").value ;
            target = '.' + textselected;
         $('#lbco tbody tr').hide();
        $(target).show();
     });
   });