/*****************************************************************************************/
* Program Name  : LBCPLOT_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2022-03-17
* Description   : build temporary dataset for LBCPLOT domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

%include "&macros.\LBC_build.sas";

data pp_final_lbcplot;
	set pp_final_lbc(rename=(lbstrescn=lbstresn));

	** create study day **;
	length lbdyc $30;
	if lbdat>=rfstdt>.z then lbdy=(lbdat-rfstdt)+1;
		else if rfstdt>lbdat>.z then lbdy=(lbdat-rfstdt);
	if lbdy>.z then lbdyc='Day '||strip(put(lbdy,best.));

	if .z<lbstresn<lbstnrlon then lbstresn_y=lbstresn;
		else if .z<lbstnrhin<lbstresn then lbstresn_y=lbstresn;

	if lbtest in ('Midnight Cortisol','Coritsol') then lbtest='Cortisol';
	if lbtest='Estimated Glomerular Filtration Rate' then lbtest='EGFR';
	if lbtest='Procollagen I Intact N-Terminal' then lbtest='PINP';
	if lbtest='Parathyroid Hormone Intact' then lbtest='PTH Intact';
	if lbtest='Thyroid Stimulating Hormone' then lbtest='TSH';
	if lbtest='Prothrombin Intl. Normalized Ratio' then lbtest='Prothrombin INR';
	if lbtest='Beta-CrossLaps B-CTx' then lbtest='CTX';
	if lbtest='C Reactive Protein' then lbtest='CRP';

	if lbcat not in ('Chemistry','Hematology') and lbtest in ('C-Peptide','CRP','CTX','Prothrombin INR',
		'Prothrombin Time','Cortisol','EGFR','Glucagon','Hemoglobin A1C','Insulin','Triglycerides','Cholesterol','HDL Cholesterol','LDL Cholesterol',
		'MELD Score','Osteocalcin','PINP','PTH Intact','TSH') then other_plot=1;

	label lbstresc='Value'
		  lbstresu='Units'
		  lbstnrlon='Normal Range Low'
		  lbstnrhin='Normal Range High';
run;
