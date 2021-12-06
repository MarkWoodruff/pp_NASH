/*****************************************************************************************/
* Program Name  : SF_listing_Listing of Screen Failures.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-13
* Description   : report Screen Failures in a listing and table
*
* Revision History
* Date       By            Description of Change
* 2021-12-06 Mark Woodruff include ieenroll_dec now that populated.  remove circuit breaker for it.
******************************************************************************************;

data sf_;
	set pp_final_elig;
	where ieorres_dec="No";
run;

data sf;
	set sf_;

	if ieorres_dec^='No' then put "ER" "ROR: update SF_listing_Screen Failures.sas to populate ieorres_dec values of Yes.";
	if ieenroll_dec not in ('','No') then put "ER" "ROR: update SF_listing_Screen Failures.sas to populate ieenroll_dec values of Yes.";

	length iec $10000;
	iec=strip(ietestcd_dec);

	iec=tranwrd(iec,', ','FRCBRK');

	iec=tranwrd(iec,'IN01','IN01: Subject is either male or female and 18 to 75 years of age inclusive, at the time of signing the informed consent.');
	iec=tranwrd(iec,'IN02','IN02: Obese subjects with BMI within the range of 30 to 45 kg/m2 (inclusive).');
	iec=tranwrd(iec,'IN03','IN03: Liver fat assessment based on VCTE controlled attenuation parameter (CAP) Score > 300 dB/m, subjects who meet CAP criterion will have HFF measured by MRI-PDFF and require = 10% for eligibility.');
	iec=tranwrd(iec,'IN04','IN04: Liver injury and fibrosis assessment based on VCTE LSM score between 7 and 9.9 kPa and AST > 20 U/L.');
	iec=tranwrd(iec,'IN05','IN05: Subject must agree to contraception requirements (see protocol section 10.3).');
	iec=tranwrd(iec,'IN06','IN06: Able to communicate well with the Investigator, and to understand and comply with the requirements of the study.');
	iec=tranwrd(iec,'EX01','EX01: Documented clinical, laboratory or radiologic evidence of cirrhosis (compensated or decompensated which may include symptoms such as bleeding varices, ascites, or hepatic encephalopathy, etc.).');
	iec=tranwrd(iec,'EX02','EX02: History of cholecystitis or cholecystectomy in the 24 weeks prior to Screening.');
	iec=tranwrd(iec,'EX03','EX03: Subjects with gallstones or biliary sludge and a history of symptoms consistent with biliary disease (e.g., abdominal pain in the epigastrium, jaundice, etc.). Subjects without symptoms of biliary disease are eligible but must be monitored as described in Section 8.5.6.');
	iec=tranwrd(iec,'EX04','EX04: History of pancreatic injury or pancreatitis, or other pancreatic disease.');
	iec=tranwrd(iec,'EX05','EX05: Confirmed abnormalities in any of the following hepatic biomarkers: ALT, Albumin, INR, Alkaline phosphatase, Total bilirubin, Triglycerides, Platelet count, MELD Score.');
	iec=tranwrd(iec,'EX06','EX06: Change in body weight (more than 5% self-reported OR 5 kg self-reported change during the previous 3 months from Screening).');
	iec=tranwrd(iec,'EX07','EX07: History of type 1 diabetes, diabetic ketoacidosis, or positive glutamic acid decarboxylase (GAD) auto-antibodies (latent autoimmune diabetes in adults).');
	iec=tranwrd(iec,'EX08','EX08: Subjects with type 2 diabetes mellitus (T2DM) with a history of diabetic complications that suggest poorly controlled disease per Investigator discretion (such as, but not limited to: severe gastroparesis, autonomic neuropathy, etc.).');
	iec=tranwrd(iec,'EX09','EX09: Any prior or known history of significant bone disease such as osteoporosis, or osteomalacia.');
	iec=tranwrd(iec,'EX10','EX10: History of bone fracture or bone surgery (i.e., hardware placement, joint replacement, bone grafting or amputation) within 12 weeks prior to Screening.');
	iec=tranwrd(iec,'EX11','EX11: Cushing’s disease or Cushing’s syndrome.');
	iec=tranwrd(iec,'EX12','EX12: Thyroid stimulating hormone (TSH) outside the normal reference range (unless the free T4 is within the normal reference range).');
	iec=tranwrd(iec,'EX13','EX13: Hemoglobin A1c > 9.5%.');
	iec=tranwrd(iec,'EX14','EX14: Confirmed positive polymerase chain reaction (PCR)-based coronavirus disease 2019 (COVID-19) test during the Screening period.');
	iec=tranwrd(iec,'EX15','EX15: Poorly controlled hypertension (systolic BP of 160 mm Hg or more or diastolic BP of 100 mm Hg or more). Blood pressure should be measured as described in Section 8.5.2.');
	iec=tranwrd(iec,'EX16','EX16: Significant illness which has not resolved within 2 weeks prior to first dose.');
	iec=tranwrd(iec,'EX17','EX17: Chronic infection with hepatitis B virus (HBV) or hepatitis C virus (HCV).');
	iec=tranwrd(iec,'EX18','EX18: Known immunocompromised status, including but not limited to, individuals who have undergone organ transplantation or who are positive for human immunodeficiency virus (HIV) (enzyme-linked immunosorbent assay [ELISA] and Western blot) test result.');
	iec=tranwrd(iec,'EX19','EX19: Compromised renal estimated glomerular filtration rate (eGFR) < 60 mL/min/1.73 m2 by Chronic Kidney Disease Epidemiology Collaboration (CKD-EPI) equation.');
	iec=tranwrd(iec,'EX20','EX20: History or current diagnosis of ECG abnormalities indicating significant risk of safety for subjects participating in the study.');
	iec=tranwrd(iec,'EX21','EX21: History of malignancy of any organ system (other than localized basal cell carcinoma of the skin or in situ cervical cancer), treated or untreated, within the past 5 years, regardless of whether there is evidence of local recurrence of metastases.');
	iec=tranwrd(iec,'EX22','EX22: Any bariatric surgery or biliary diversion (e.g., gastric bypass, gastric banding, Roux-en-Y, etc.).');
	iec=tranwrd(iec,'EX23','EX23: Any major surgery within 6 weeks of Screening, or surgical or medical condition which might jeopardize the subject’s safety; any planned surgery during the course of the study.');
	iec=tranwrd(iec,'EX24','EX24: Any disorder which in the Investigator’s opinion might jeopardize subject’s safety or compliance with the protocol.');
	iec=tranwrd(iec,'EX25','EX25: History of hypersensitivity (such as anaphylaxis or hepatotoxicity) to drugs of similar biological class, fibroblast growth factor (FGF) 21 protein analog, or fragment crystallizable (Fc) fusion proteins or other protein-based therapeutics.');
	iec=tranwrd(iec,'EX26','EX26: Subjects with contraindications to MRI.');
	iec=tranwrd(iec,'EX27','EX27: Waist circumference > 57 inches or other reasons which could interfere with obtaining MRI imaging at any of the specified timepoints.');
	iec=tranwrd(iec,'EX28','EX28: Females who are pregnant or breastfeeding. All female subjects must have a negative pregnancy test (minimum sensitivity 25 IU/L or equivalent units of human chorionic gonadotropin [hCG]) at Screening and Day 1 prior to the start of study drug administration.');
	iec=tranwrd(iec,'EX29','EX29: History of drug abuse within the 12 months prior to dosing or evidence of such abuse as indicated by the laboratory assays conducted during Screening.');
	iec=tranwrd(iec,'EX30','EX30: History of excessive alcohol intake (> 14 units of alcohol per week for males and > 7 units of alcohol per week for females for 2 years prior to enrollment, where a “unit” of alcohol is equivalent to a 12-ounce beer, 4-ounce glass of wine, or 1-ounce shot of hard liquor).');
	iec=tranwrd(iec,'EX31','EX31: Heavy smoking as defined by self-report of use of 20 cigarettes or more per day.');
	iec=tranwrd(iec,'EX32','EX32: Donation or loss of 450 mL or more of blood within 8 weeks prior to initial dosing, or longer if required by local regulation.');
	iec=tranwrd(iec,'EX33','EX33: Prisoners or subjects who are involuntarily incarcerated.');
	iec=tranwrd(iec,'EX34','EX34: Subjects who are compulsorily detained for treatment of either a psychiatric or physical (e.g., infectious disease) illness.');
	iec=tranwrd(iec,'EX35','EX35: Any vaccination in the 2 weeks prior to randomization (vaccinations during the course of the study are allowed but must be discussed and approved by the Investigator).');
	iec=tranwrd(iec,'EX36','EX36: Use of Vitamin E (at a dose = 800 IU/day) or pioglitazone within 90 days prior to first dose.');
	iec=tranwrd(iec,'EX37','EX37: The use of insulin, GLP-1 receptor agonists, or dipeptidyl peptidase-4 (DPP-4) antagonists. Other non-insulin antidiabetic medications including insulin secretagogues (i.e., sulfonylureas and meglitinides) are permitted if the subject has been on a stable regimen for at least 12 weeks prior to randomization.');
	iec=tranwrd(iec,'EX38','EX38: Anti-lipid medication (for example, statins, bile acid resin/sequestrants, proprotein convertase subtilisin kexin 9 [PCSK9] inhibitors, niacin, fibrates) doses should be stable for at least 12 weeks prior to randomization.');
	iec=tranwrd(iec,'EX39','EX39: Drugs associated with induced steatosis such as methotrexate, amiodarone, tamoxifen, nifedipine, valproate.');
	iec=tranwrd(iec,'EX40','EX40: Use of other investigational drugs at the time of enrollment, or within 5 half-lives of enrollment, or within 90 days, whichever is longer; or longer if required by local regulations.');
	iec=tranwrd(iec,'EX41','EX41: Use of weight loss drugs, currently or in the past 12 weeks.');
	iec=tranwrd(iec,'EX42','EX42: Acetaminophen taken at doses of > 2 g per day for 5 consecutive days in the previous 30 days prior to dosing.');
	iec=tranwrd(iec,'EX43','EX43: Pharmacotherapy for osteoporosis within 90 days prior to dosing (with the exception of calcium or Vitamin D, or hormone replacement in postmenopausal females).');
	iec=tranwrd(iec,'EX44','EX44: Use of oral or injected corticosteroids for more than 7 consecutive days, within 90 days prior to dosing. Inhaled, nasal or topical steroids used at the registered dose strengths are permitted.');
run; 

data domain_data;
	set sf;
run;

%macro report_domain;

	options orientation=portrait nodate nonumber nobyline;

	proc report data=domain_data nowd headline headskip missing spacing=1 split="|" center formchar(2)='_'
		style(header)=[just=l asis=on] 
		style(column)=[just=l asis=on] 
		style(lines) =[just=l asis=on];

		column subnum iestdat visitid visname iestdat_c iec sf_mri mostdat_c;
		define subnum       /order order=internal "Patient" style=[htmlclass='patient-link sf min-width-0-75'];
		define iestdat      /order order=internal noprint;
		define visitid      /order order=internal noprint;
		define visname      /display "Visit";
		define iestdat_c    /display "Eligibility|Assessment|Date" style=[htmlclass='min-width-1-0'];
		*define ieorres_dec  /display "Eligible|for|Study?";
		*define ieenroll_dec /display "Enrolled without meeting|all IE requirements?|(include as PD)";
		define iec          /display "Inclusion and/or Exclusion Criteria Not Met" style=[htmlclass='max-width-7-5'];
		define sf_mri       /display "Screen Fail|and MRI|Performed?";
		define mostdat_c    /display "Date of MRI" style=[htmlclass='min-width-1-0'];

		*compute foldername;
			*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
		*endcomp;

		*compute age_raw;
			*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
		*endcomp;

		*footnote "dm-footnote";

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Listing of Screen Failures";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
