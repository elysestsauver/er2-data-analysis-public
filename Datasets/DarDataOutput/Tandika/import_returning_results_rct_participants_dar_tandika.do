* import_returning_results_rct_participants_dar_tandika.do
*
* 	Imports and aggregates "Returning results (RCT participants) - Tandika" (ID: returning_results_rct_participants_dar_tandika) data.
*
*	Inputs:  "./Returning results (RCT participants) - Tandika.csv"
*	Outputs: "./Returning results (RCT participants) - Tandika.dta"
*
*	Output by SurveyCTO June 3, 2025 6:44 AM.

* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "./Returning results (RCT participants) - Tandika.csv"
local dtafile "./Returning results (RCT participants) - Tandika.dta"
local corrfile "./Returning results (RCT participants) - Tandika_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid text_audit light_level movement sound_level sound_pitch conversation comments start_time int_name districtid district_name wardid ward_name"
local text_fields2 "villageid village_name respondentid control respondent_name respondent_index replacement_respondent replacement_respondent2 rand_interested_receive_result replacement_name start_sec1 hh_size_calc"
local text_fields3 "resp_education_oth start_sec2 hear_study_oth enrol_study_oth lasting_impacts_description challenges_description_oth2 start_sec3 start_sec4 study_activities study_activities_oth"
local text_fields4 "other_results_received_oth past_study_challenges_addressed_ past_study_challenges_addressed_ other_participant_challenges_hea other_participant_challenges_hea other_participant_challenges_add"
local text_fields5 "who_involved start_sec6 rank_results_methods start_sec7 random random_choice first_position second_position third_position sec_7_8_random rank_results_preference rank_formats_preference"
local text_fields6 "rank_formats_clarity start_sec8 game_size dce_game_count exercise_comment_oth start_sec9 rank_results_preference_2 rank_formats_preference_2 rank_formats_clarity_2 interview_result_oth end_commet"
local text_fields7 "end_time instanceid instancename"
local date_fields1 ""
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable interviewer "0.1 Select your name"
	note interviewer: "0.1 Select your name"
	label define interviewer 1 "Ancelem Kadala" 2 "Dorah Kolowa" 3 "David Lumato" 4 "Mariam Masala" 5 "Deborah Mushi" 6 "Seif Ally"
	label values interviewer interviewer

	label variable districtid "0.2 Select district"
	note districtid: "0.2 Select district"

	label variable wardid "0.3 Select ward"
	note wardid: "0.3 Select ward"

	label variable villageid "0.4 Select village"
	note villageid: "0.4 Select village"

	label variable respondentid "0.5 Select Respondent"
	note respondentid: "0.5 Select Respondent"

	label variable gpslatitude "0.6 Reocrd GPS (latitude)"
	note gpslatitude: "0.6 Reocrd GPS (latitude)"

	label variable gpslongitude "0.6 Reocrd GPS (longitude)"
	note gpslongitude: "0.6 Reocrd GPS (longitude)"

	label variable gpsaltitude "0.6 Reocrd GPS (altitude)"
	note gpsaltitude: "0.6 Reocrd GPS (altitude)"

	label variable gpsaccuracy "0.6 Reocrd GPS (accuracy)"
	note gpsaccuracy: "0.6 Reocrd GPS (accuracy)"

	label variable respo_confirm "0.7 Please confirm that you have found the respondent with the name \${responden"
	note respo_confirm: "0.7 Please confirm that you have found the respondent with the name \${respondent_name} and you are ready to proceed with consenting process?"
	label define respo_confirm 1 "Yes" 0 "No"
	label values respo_confirm respo_confirm

	label variable part_study_1 "0.9 Do you or any other household member remember being part of this study?"
	note part_study_1: "0.9 Do you or any other household member remember being part of this study?"
	label define part_study_1 1 "Yes" 0 "No"
	label values part_study_1 part_study_1

	label variable who_participated_1 "0.10 Was that you or another household member?"
	note who_participated_1: "0.10 Was that you or another household member?"
	label define who_participated_1 1 "Myself" 2 "Another household member"
	label values who_participated_1 who_participated_1

	label variable speak_othermember_1 "0.11 Can I speak with this household member who participated in the study?"
	note speak_othermember_1: "0.11 Can I speak with this household member who participated in the study?"
	label define speak_othermember_1 1 "Yes" 0 "No"
	label values speak_othermember_1 speak_othermember_1

	label variable replacement_respondent "0.12 Please select replacement for \${respondent_name} who is ready to proceed w"
	note replacement_respondent: "0.12 Please select replacement for \${respondent_name} who is ready to proceed with consenting process"

	label variable part_study_2 "0.14 Do you or any other household member remember being part of this study?"
	note part_study_2: "0.14 Do you or any other household member remember being part of this study?"
	label define part_study_2 1 "Yes" 0 "No"
	label values part_study_2 part_study_2

	label variable who_participated_2 "0.15 was that you or another household member?"
	note who_participated_2: "0.15 was that you or another household member?"
	label define who_participated_2 1 "Myself" 2 "Another household member"
	label values who_participated_2 who_participated_2

	label variable speak_othermember_2 "0.16 Can I speak with this household member who participated in the study?"
	note speak_othermember_2: "0.16 Can I speak with this household member who participated in the study?"
	label define speak_othermember_2 1 "Yes" 0 "No"
	label values speak_othermember_2 speak_othermember_2

	label variable replacement_respondent2 "Please write the name of Other replacement respondent that you have found within"
	note replacement_respondent2: "Please write the name of Other replacement respondent that you have found within the same mtaa"

	label variable part_study_3 "0.14 Do you or any other household member remember being part of this study?"
	note part_study_3: "0.14 Do you or any other household member remember being part of this study?"
	label define part_study_3 1 "Yes" 0 "No"
	label values part_study_3 part_study_3

	label variable who_participated_3 "0.15 was that you or another household member?"
	note who_participated_3: "0.15 was that you or another household member?"
	label define who_participated_3 1 "Myself" 2 "Another household member"
	label values who_participated_3 who_participated_3

	label variable speak_othermember_3 "0.16 Can I speak with this household member who participated in the study?"
	note speak_othermember_3: "0.16 Can I speak with this household member who participated in the study?"
	label define speak_othermember_3 1 "Yes" 0 "No"
	label values speak_othermember_3 speak_othermember_3

	label variable consent "0.19 Do you consent to participate in the study?"
	note consent: "0.19 Do you consent to participate in the study?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable resp_age "1.1 What is your age?"
	note resp_age: "1.1 What is your age?"

	label variable resp_gender "1.2 Respondent Gender Observe don't ask"
	note resp_gender: "1.2 Respondent Gender Observe don't ask"
	label define resp_gender 1 "Male" 2 "Female"
	label values resp_gender resp_gender

	label variable resp_marital "1.3 What is your marital status?"
	note resp_marital: "1.3 What is your marital status?"
	label define resp_marital 1 "Single/Never Married" 2 "Married" 3 "Separated" 4 "Divorced" 5 "Widow/widower"
	label values resp_marital resp_marital

	label variable hh_adults "1.4 How many adults (aged 18+) other than you live in your household?"
	note hh_adults: "1.4 How many adults (aged 18+) other than you live in your household?"

	label variable hh_children "1.5 How many children age 0-6 live with you?"
	note hh_children: "1.5 How many children age 0-6 live with you?"

	label variable hh_teen "1.6 How many children aged 7-17 live with you?"
	note hh_teen: "1.6 How many children aged 7-17 live with you?"

	label variable hh_size_confirm "[Check hh_size] Please confirm that this is the total number of household member"
	note hh_size_confirm: "[Check hh_size] Please confirm that this is the total number of household members \${hh_size_calc}?"
	label define hh_size_confirm 1 "Yes" 0 "No"
	label values hh_size_confirm hh_size_confirm

	label variable resp_education "1.7 What is the highest level of education you have received?"
	note resp_education: "1.7 What is the highest level of education you have received?"
	label define resp_education 1 "a. No formal education" 2 "b. Primary education" 3 "c. Secondary education" 4 "d. certificate" 5 "e. Diploma" 6 "g. Trade School" -96 "h. Other"
	label values resp_education resp_education

	label variable resp_education_oth "1.7a Please specify other level of education"
	note resp_education_oth: "1.7a Please specify other level of education"

	label variable work_seven_days "1.8 Did you work in the past seven days?"
	note work_seven_days: "1.8 Did you work in the past seven days?"
	label define work_seven_days 1 "Yes" 0 "No"
	label values work_seven_days work_seven_days

	label variable work_three_month "1.9 Did you work in the past three months?"
	note work_three_month: "1.9 Did you work in the past three months?"
	label define work_three_month 1 "Yes" 0 "No"
	label values work_three_month work_three_month

	label variable resp_busy "1.10 On a scale of 1-5, how busy would you say the rest of your day is?"
	note resp_busy: "1.10 On a scale of 1-5, how busy would you say the rest of your day is?"
	label define resp_busy 1 "Not busy at all" 2 "2" 3 "3" 4 "4" 5 "Very busy"
	label values resp_busy resp_busy

	label variable remember_study "2.3 Can you confirm that you remember being part of this study?"
	note remember_study: "2.3 Can you confirm that you remember being part of this study?"
	label define remember_study 1 "Yes" 2 "No" 3 "I don't recall"
	label values remember_study remember_study

	label variable hear_study "2.4 How did you first hear about the study?"
	note hear_study: "2.4 How did you first hear about the study?"
	label define hear_study 1 "Direct communication with research team - in person" 2 "Phone call" 3 "Social Media (Facebook, Twitter, WhatsApp)" 4 "Online News/Websites/Apps" 5 "Television" 6 "Radio" 7 "Print Media (newspaper, magazines)" 8 "Word of Mouth (Friends, Family, Colleagues)" 9 "Community Leader" 10 "Religious Leader" -96 "Other (Please specify)"
	label values hear_study hear_study

	label variable hear_study_oth "2.5 Please Specify how did you hear about the study"
	note hear_study_oth: "2.5 Please Specify how did you hear about the study"

	label variable enrol_study "2.6 What was your primary reason for enrolling in the study?"
	note enrol_study: "2.6 What was your primary reason for enrolling in the study?"
	label define enrol_study 1 "a. community influence/encouragement" 2 "b. curiosity about the study's results" 3 "c. desire to assist" 4 "d. financial compensation" 5 "e. contacted by the interviewer" 6 "f. forced to participate" 7 "g. afraid of consequences for not participating" 8 "I do not recall" -96 "h. other - please describe"
	label values enrol_study enrol_study

	label variable enrol_study_oth "2.7 Please Specify other primary reason to enroll"
	note enrol_study_oth: "2.7 Please Specify other primary reason to enroll"

	label variable receive_result "2.8 Did you expect to recieve results when you enrolled in the study?"
	note receive_result: "2.8 Did you expect to recieve results when you enrolled in the study?"
	label define receive_result 1 "Yes" 2 "No" 3 "I don't recall"
	label values receive_result receive_result

	label variable explain_study "2.9 The first time you met the interviewer, did they explain to you what the obj"
	note explain_study: "2.9 The first time you met the interviewer, did they explain to you what the objectives of the study were?"
	label define explain_study 1 "Yes" 2 "No" 3 "I don't recall"
	label values explain_study explain_study

	label variable understand_study "2.10 Did you understand what the study was about from their description?"
	note understand_study: "2.10 Did you understand what the study was about from their description?"
	label define understand_study 1 "Yes" 2 "No" 3 "I don't recall"
	label values understand_study understand_study

	label variable study_documentation "2.11 Did the interviewer give you a written document with information about the "
	note study_documentation: "2.11 Did the interviewer give you a written document with information about the study?"
	label define study_documentation 1 "Yes" 2 "No" 3 "I don't recall"
	label values study_documentation study_documentation

	label variable keep_documentation "2.12 Did you keep the document after the initial interview?"
	note keep_documentation: "2.12 Did you keep the document after the initial interview?"
	label define keep_documentation 1 "Yes" 2 "No" 3 "I don't recall"
	label values keep_documentation keep_documentation

	label variable have_documentation "2.13 Do you still have it?"
	note have_documentation: "2.13 Do you still have it?"
	label define have_documentation 1 "Yes" 0 "No"
	label values have_documentation have_documentation

	label variable researchers_names "2.14 Were you given names of researchers that you could contact if you ever run "
	note researchers_names: "2.14 Were you given names of researchers that you could contact if you ever run into a problem with your involvement in the study?"
	label define researchers_names 1 "Yes" 2 "No" 3 "I don't recall"
	label values researchers_names researchers_names

	label variable contact_research "2.15 Did you ever try to contact them?"
	note contact_research: "2.15 Did you ever try to contact them?"
	label define contact_research 1 "Yes" 2 "No" 3 "I don't recall"
	label values contact_research contact_research

	label variable informed_consent "2.16 Were you given the option to not participate in the study?"
	note informed_consent: "2.16 Were you given the option to not participate in the study?"
	label define informed_consent 1 "Yes" 2 "No" 3 "I don't recall"
	label values informed_consent informed_consent

	label variable informed_study_results "2.18 Were you informed of plans to return results directly to participants at th"
	note informed_study_results: "2.18 Were you informed of plans to return results directly to participants at the conclusion of the study?"
	label define informed_study_results 1 "Yes" 2 "No" 3 "I don't recall"
	label values informed_study_results informed_study_results

	label variable clear_plans "2.19 Were these plans made clear to you?"
	note clear_plans: "2.19 Were these plans made clear to you?"
	label define clear_plans 1 "Yes" 2 "No" 3 "I don't recall"
	label values clear_plans clear_plans

	label variable ask_results "2.20 Did you ask if results would be returned?"
	note ask_results: "2.20 Did you ask if results would be returned?"
	label define ask_results 1 "Yes" 2 "No" 3 "I don't recall"
	label values ask_results ask_results

	label variable interviewer_interaction "2.22 How would you describe your interactions with the interviewer during your i"
	note interviewer_interaction: "2.22 How would you describe your interactions with the interviewer during your interviews for the study? Positve, somewhat positive, netural, somewhat negative, negative?"
	label define interviewer_interaction 1 "Positive" 2 "Somewhat Positive" 3 "Neutral" 4 "Somewhat Negative" 5 "Negative"
	label values interviewer_interaction interviewer_interaction

	label variable activity_1 "2.24 Activity 1: participants received vouchers for buying yogurt, eggs, and mil"
	note activity_1: "2.24 Activity 1: participants received vouchers for buying yogurt, eggs, and milk"
	label define activity_1 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_1 activity_1

	label variable activity_1b "2.25 Where you or your household personally involved in this activity?"
	note activity_1b: "2.25 Where you or your household personally involved in this activity?"
	label define activity_1b 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_1b activity_1b

	label variable activity_2 "2.26 Activity 2: participants received a discount to connect their home to the e"
	note activity_2: "2.26 Activity 2: participants received a discount to connect their home to the electric grid"
	label define activity_2 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_2 activity_2

	label variable activity_2b "2.27 Where you or your household personally involved in this activity?"
	note activity_2b: "2.27 Where you or your household personally involved in this activity?"
	label define activity_2b 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_2b activity_2b

	label variable activity_3 "2.28 Activity 3: participants were provided business listings in a paper or onli"
	note activity_3: "2.28 Activity 3: participants were provided business listings in a paper or online directory"
	label define activity_3 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_3 activity_3

	label variable activity_3b "2.29 Where you or your household personally involved in this activity?"
	note activity_3b: "2.29 Where you or your household personally involved in this activity?"
	label define activity_3b 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_3b activity_3b

	label variable activity_4 "2.30 Activity 4: participants recieved vouchers for free healthcare services at "
	note activity_4: "2.30 Activity 4: participants recieved vouchers for free healthcare services at local clinics."
	label define activity_4 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_4 activity_4

	label variable activity_4b "2.31 Where you or your household personally involved in this activity?"
	note activity_4b: "2.31 Where you or your household personally involved in this activity?"
	label define activity_4b 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_4b activity_4b

	label variable activity_5 "2.312Activity 5: participants were given free access to online education courses"
	note activity_5: "2.312Activity 5: participants were given free access to online education courses"
	label define activity_5 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_5 activity_5

	label variable activity_5b "2.33 Where you or your household personally involved in this activity?"
	note activity_5b: "2.33 Where you or your household personally involved in this activity?"
	label define activity_5b 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_5b activity_5b

	label variable activity_6 "2.34 Activity 6: participants were provided with clean water filters for househo"
	note activity_6: "2.34 Activity 6: participants were provided with clean water filters for household use"
	label define activity_6 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_6 activity_6

	label variable activity_6b "2.35 Where you or your household personally involved in this activity?"
	note activity_6b: "2.35 Where you or your household personally involved in this activity?"
	label define activity_6b 1 "Yes" 2 "No" 3 "I don't know"
	label values activity_6b activity_6b

	label variable satisfied_compensation "2.37 Compensation received for participating"
	note satisfied_compensation: "2.37 Compensation received for participating"
	label define satisfied_compensation 1 "not satisfied" 2 "somewhat satisfied" 3 "satisfied" 4 "4" 5 "very satisfied" 6 "Did not receive Compensation"
	label values satisfied_compensation satisfied_compensation

	label variable satisfied_time "2.38 Amount of time spent participating in the research"
	note satisfied_time: "2.38 Amount of time spent participating in the research"
	label define satisfied_time 1 "not satisfied" 2 "2" 3 "3" 4 "4" 5 "very satisfied" 6 "Did not receive Compensation"
	label values satisfied_time satisfied_time

	label variable satisfied_interaction "2.39 Interactions with interviewers"
	note satisfied_interaction: "2.39 Interactions with interviewers"
	label define satisfied_interaction 1 "not satisfied" 2 "2" 3 "3" 4 "4" 5 "very satisfied" 6 "Did not receive Compensation"
	label values satisfied_interaction satisfied_interaction

	label variable satisfied_information "2.40 Amount of relevant information you received when deciding to participate"
	note satisfied_information: "2.40 Amount of relevant information you received when deciding to participate"
	label define satisfied_information 1 "not satisfied" 2 "2" 3 "3" 4 "4" 5 "very satisfied" 6 "Did not receive Compensation"
	label values satisfied_information satisfied_information

	label variable info_received_during_study "2.41 Amount of relevant information received during the study"
	note info_received_during_study: "2.41 Amount of relevant information received during the study"
	label define info_received_during_study 1 "not satisfied" 2 "2" 3 "3" 4 "4" 5 "very satisfied" 6 "Did not receive Compensation"
	label values info_received_during_study info_received_during_study

	label variable info_received_end_study "2.42 Amount of relevant information received when the study ended"
	note info_received_end_study: "2.42 Amount of relevant information received when the study ended"
	label define info_received_end_study 1 "not satisfied" 2 "2" 3 "3" 4 "4" 5 "very satisfied" 6 "Did not receive Compensation"
	label values info_received_end_study info_received_end_study

	label variable clarity_timelines "2.43 Clarity about timelines (start and end dates of study)"
	note clarity_timelines: "2.43 Clarity about timelines (start and end dates of study)"
	label define clarity_timelines 1 "not satisfied" 2 "2" 3 "3" 4 "4" 5 "very satisfied" 6 "Did not receive Compensation"
	label values clarity_timelines clarity_timelines

	label variable relevance_personal "2.44 Relevance of the research to you personally"
	note relevance_personal: "2.44 Relevance of the research to you personally"
	label define relevance_personal 1 "not satisfied" 2 "2" 3 "3" 4 "4" 5 "very satisfied" 6 "Did not receive Compensation"
	label values relevance_personal relevance_personal

	label variable relevance_community "2.45 Relevance of the research to your community"
	note relevance_community: "2.45 Relevance of the research to your community"
	label define relevance_community 1 "not satisfied" 2 "2" 3 "3" 4 "4" 5 "very satisfied" 6 "Did not receive Compensation"
	label values relevance_community relevance_community

	label variable lasting_impacts "2.46 Did you see any lasting impacts of the project?"
	note lasting_impacts: "2.46 Did you see any lasting impacts of the project?"
	label define lasting_impacts 1 "Yes" 0 "No"
	label values lasting_impacts lasting_impacts

	label variable lasting_impacts_description "2.47 What were they?"
	note lasting_impacts_description: "2.47 What were they?"

	label variable future_participation_interest "2.48 On a scale of 1 to 5, with 1 being the least interested and 5 being the mos"
	note future_participation_interest: "2.48 On a scale of 1 to 5, with 1 being the least interested and 5 being the most interested, how interested would you be to participte if there was a similar study in the future?"
	label define future_participation_interest 1 "Least interested" 2 "2" 3 "3" 4 "4" 5 "Most interested"
	label values future_participation_interest future_participation_interest

	label variable challenges_encountered "2.49 Did you or others in the study run into challenges with your involvement in"
	note challenges_encountered: "2.49 Did you or others in the study run into challenges with your involvement in the study?"
	label define challenges_encountered 1 "yes, me or someone in my household" 2 "yes, a community member did" 3 "no"
	label values challenges_encountered challenges_encountered

	label variable challenges_description_oth2 "2.50 If yes, can you describe the challenge?"
	note challenges_description_oth2: "2.50 If yes, can you describe the challenge?"

	label variable challenges_resolution "2.51 How was the challenge resolved?"
	note challenges_resolution: "2.51 How was the challenge resolved?"
	label define challenges_resolution 1 "communication with local research representative" 2 "communication with community leader" 3 "withdrawl from the study" 4 "it was never resolved"
	label values challenges_resolution challenges_resolution

	label variable interested_receive_result_1 "2.52 Are you interested in receiving the results of this study? Please bear in m"
	note interested_receive_result_1: "2.52 Are you interested in receiving the results of this study? Please bear in mind that we do not know how long it will take for the researchers to complete the study and get the results."
	label define interested_receive_result_1 1 "Yes" 0 "No"
	label values interested_receive_result_1 interested_receive_result_1

	label variable egg_voucher "3.3 To purchase eggs?"
	note egg_voucher: "3.3 To purchase eggs?"

	label variable milk_voucher "3.4 To purchase milk?"
	note milk_voucher: "3.4 To purchase milk?"

	label variable yogurt_voucher "3.5 To purchase yogurt?"
	note yogurt_voucher: "3.5 To purchase yogurt?"

	label variable egg_quantity "3.7 Eggs"
	note egg_quantity: "3.7 Eggs"
	label define egg_quantity 1 "Larger Quantity" 2 "Smaller quantity" 3 "No change"
	label values egg_quantity egg_quantity

	label variable milk_quantity "3.8 Milk"
	note milk_quantity: "3.8 Milk"
	label define milk_quantity 1 "Larger Quantity" 2 "Smaller quantity" 3 "No change"
	label values milk_quantity milk_quantity

	label variable yogurt_quantity "3.9 Yogurt"
	note yogurt_quantity: "3.9 Yogurt"
	label define yogurt_quantity 1 "Larger Quantity" 2 "Smaller quantity" 3 "No change"
	label values yogurt_quantity yogurt_quantity

	label variable soda_quantity "3.10 Soda"
	note soda_quantity: "3.10 Soda"
	label define soda_quantity 1 "Larger Quantity" 2 "Smaller quantity" 3 "No change"
	label values soda_quantity soda_quantity

	label variable sugar_quantity "3.11 Sugar"
	note sugar_quantity: "3.11 Sugar"
	label define sugar_quantity 1 "Larger Quantity" 2 "Smaller quantity" 3 "No change"
	label values sugar_quantity sugar_quantity

	label variable chicken_quantity "3.12 Chicken"
	note chicken_quantity: "3.12 Chicken"
	label define chicken_quantity 1 "Larger Quantity" 2 "Smaller quantity" 3 "No change"
	label values chicken_quantity chicken_quantity

	label variable after_voucher "3.12 What do you think will happen to the consumption of milk 2 weeks after all "
	note after_voucher: "3.12 What do you think will happen to the consumption of milk 2 weeks after all vouchers are used up? Do people consume more than before the voucher, less than before the voucher, or the same as before the voucher?"
	label define after_voucher 1 "Consume more" 2 "Consume less" 3 "No change"
	label values after_voucher after_voucher

	label variable past_study_participation "4.3 Did you or any other member of your household participate in other projects "
	note past_study_participation: "4.3 Did you or any other member of your household participate in other projects that fill this definition of a research study in the past 5 years? Please exclude your households' involvement with the study we just discussed."
	label define past_study_participation 1 "Yes" 0 "No"
	label values past_study_participation past_study_participation

	label variable num_past_studies "4.4 how many studies, excluding the one we just talked about?"
	note num_past_studies: "4.4 how many studies, excluding the one we just talked about?"

	label variable study_activities "4.5 Thinking about the last \${num_past_studies} OTHER research studies you were"
	note study_activities: "4.5 Thinking about the last \${num_past_studies} OTHER research studies you were involved in, which of the following activities did you participate in? NUMBER IS MAX[3, ANSWER TO QUESTION 2]"

	label variable study_activities_oth "4.6 Please specify other activities"
	note study_activities_oth: "4.6 Please specify other activities"

	label variable studies_returned_info "4.7 How many of these \${num_past_studies} other research studies returned infor"
	note studies_returned_info: "4.7 How many of these \${num_past_studies} other research studies returned information to you?"

	label variable audio_results_received "4.9 Did you recieve results through an audio message?"
	note audio_results_received: "4.9 Did you recieve results through an audio message?"
	label define audio_results_received 1 "Yes" 0 "No"
	label values audio_results_received audio_results_received

	label variable audio_message_listened "4.10 Did you listen to the audio message?"
	note audio_message_listened: "4.10 Did you listen to the audio message?"
	label define audio_message_listened 1 "Yes" 0 "No"
	label values audio_message_listened audio_message_listened

	label variable audio_results_understandable "4.11 For you personally, were the results very understandable, somewhat understa"
	note audio_results_understandable: "4.11 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define audio_results_understandable 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values audio_results_understandable audio_results_understandable

	label variable sms_results_received "4.12 Did you recieve results through an SMS?"
	note sms_results_received: "4.12 Did you recieve results through an SMS?"
	label define sms_results_received 1 "Yes" 0 "No"
	label values sms_results_received sms_results_received

	label variable sms_message_read "4.13 Did you read the SMS?"
	note sms_message_read: "4.13 Did you read the SMS?"
	label define sms_message_read 1 "Yes" 0 "No"
	label values sms_message_read sms_message_read

	label variable sms_results_understandable "4.14 For you personally, were the results very understandable, somewhat understa"
	note sms_results_understandable: "4.14 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define sms_results_understandable 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values sms_results_understandable sms_results_understandable

	label variable website_results_received "4.15 Did you receive results through a link to a website?"
	note website_results_received: "4.15 Did you receive results through a link to a website?"
	label define website_results_received 1 "Yes" 0 "No"
	label values website_results_received website_results_received

	label variable website_link_clicked "4.16 Did you click through the website?"
	note website_link_clicked: "4.16 Did you click through the website?"
	label define website_link_clicked 1 "Yes" 0 "No"
	label values website_link_clicked website_link_clicked

	label variable website_results_understandable "4.17 For you personally, were the results very understandable, somewhat understa"
	note website_results_understandable: "4.17 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define website_results_understandable 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values website_results_understandable website_results_understandable

	label variable flyer_results_received "4.18 Did you recieve results through a flyer?"
	note flyer_results_received: "4.18 Did you recieve results through a flyer?"
	label define flyer_results_received 1 "Yes" 0 "No"
	label values flyer_results_received flyer_results_received

	label variable flyer_read "4.19 Did you read the flyer?"
	note flyer_read: "4.19 Did you read the flyer?"
	label define flyer_read 1 "Yes" 0 "No"
	label values flyer_read flyer_read

	label variable flyer_results_understandable "4.20 For you personally, were the results very understandable, somewhat understa"
	note flyer_results_understandable: "4.20 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define flyer_results_understandable 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values flyer_results_understandable flyer_results_understandable

	label variable posted_flyer_results_received "4.21 Did you receive results through a publicly posted flyer on a community boar"
	note posted_flyer_results_received: "4.21 Did you receive results through a publicly posted flyer on a community board?"
	label define posted_flyer_results_received 1 "Yes" 0 "No"
	label values posted_flyer_results_received posted_flyer_results_received

	label variable posted_flyer_read "4,22 Did you read the posted flyer?"
	note posted_flyer_read: "4,22 Did you read the posted flyer?"
	label define posted_flyer_read 1 "Yes" 0 "No"
	label values posted_flyer_read posted_flyer_read

	label variable posted_flyer_results_understanda "4.23 For you personally, were the results very understandable, somewhat understa"
	note posted_flyer_results_understanda: "4.23 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define posted_flyer_results_understanda 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values posted_flyer_results_understanda posted_flyer_results_understanda

	label variable social_media_results_seen "4.24 Did you see results shared on a social media post?"
	note social_media_results_seen: "4.24 Did you see results shared on a social media post?"
	label define social_media_results_seen 1 "Yes" 0 "No"
	label values social_media_results_seen social_media_results_seen

	label variable social_media_interacted "4.25 Did you interact with the social media post?"
	note social_media_interacted: "4.25 Did you interact with the social media post?"
	label define social_media_interacted 1 "Yes" 0 "No"
	label values social_media_interacted social_media_interacted

	label variable social_media_results_understanda "4.26 For you personally, were the results very understandable, somewhat understa"
	note social_media_results_understanda: "4.26 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define social_media_results_understanda 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values social_media_results_understanda social_media_results_understanda

	label variable video_results_received "4.27 Did you recieve results through a video?"
	note video_results_received: "4.27 Did you recieve results through a video?"
	label define video_results_received 1 "Yes" 0 "No"
	label values video_results_received video_results_received

	label variable video_watched "4.28 Did you watch the video?"
	note video_watched: "4.28 Did you watch the video?"
	label define video_watched 1 "Yes" 0 "No"
	label values video_watched video_watched

	label variable video_results_understandable "4.29 For you personally, were the results very understandable, somewhat understa"
	note video_results_understandable: "4.29 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define video_results_understandable 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values video_results_understandable video_results_understandable

	label variable public_meeting_invited "4.30 Were you invited to hear about the results at a public meeting?"
	note public_meeting_invited: "4.30 Were you invited to hear about the results at a public meeting?"
	label define public_meeting_invited 1 "Yes" 0 "No"
	label values public_meeting_invited public_meeting_invited

	label variable public_meeting_attended "4.31 Did you attend the public meeting?"
	note public_meeting_attended: "4.31 Did you attend the public meeting?"
	label define public_meeting_attended 1 "Yes" 0 "No"
	label values public_meeting_attended public_meeting_attended

	label variable public_meeting_results_understan "4.32 For you personally, were the results very understandable, somewhat understa"
	note public_meeting_results_understan: "4.32 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define public_meeting_results_understan 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values public_meeting_results_understan public_meeting_results_understan

	label variable private_meeting_invited "4.33 Were you invited to hear about the results at a private meeting?"
	note private_meeting_invited: "4.33 Were you invited to hear about the results at a private meeting?"
	label define private_meeting_invited 1 "Yes" 0 "No"
	label values private_meeting_invited private_meeting_invited

	label variable private_meeting_attended "4.34 Did you attend the private meeting?"
	note private_meeting_attended: "4.34 Did you attend the private meeting?"
	label define private_meeting_attended 1 "Yes" 0 "No"
	label values private_meeting_attended private_meeting_attended

	label variable private_meeting_results_understa "4.35 For you personally, were the results very understandable, somewhat understa"
	note private_meeting_results_understa: "4.35 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define private_meeting_results_understa 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values private_meeting_results_understa private_meeting_results_understa

	label variable phone_call_results_heard "4.36 Did you hear about the results through a phone call?"
	note phone_call_results_heard: "4.36 Did you hear about the results through a phone call?"
	label define phone_call_results_heard 1 "Yes" 0 "No"
	label values phone_call_results_heard phone_call_results_heard

	label variable phone_call_answered "4.37 Did you answer the phone call?"
	note phone_call_answered: "4.37 Did you answer the phone call?"
	label define phone_call_answered 1 "Yes" 0 "No"
	label values phone_call_answered phone_call_answered

	label variable phone_call_results_understandabl "4.38 For you personally, were the results very understandable, somewhat understa"
	note phone_call_results_understandabl: "4.38 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define phone_call_results_understandabl 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values phone_call_results_understandabl phone_call_results_understandabl

	label variable other_results_received "4.39 Did you recieve results in any other form not listed?"
	note other_results_received: "4.39 Did you recieve results in any other form not listed?"
	label define other_results_received 1 "Yes" 0 "No"
	label values other_results_received other_results_received

	label variable other_results_received_oth "4.40 Please specify"
	note other_results_received_oth: "4.40 Please specify"

	label variable other_results_understandable "4.41 For you personally, were the results very understandable, somewhat understa"
	note other_results_understandable: "4.41 For you personally, were the results very understandable, somewhat understandable, or not understandable?"
	label define other_results_understandable 1 "Very understandable" 2 "somewhat understandable" 3 "not understandable"
	label values other_results_understandable other_results_understandable

	label variable results_wait_time_perception "4.42 Thinking about when the LAST study that returned results to you concluded a"
	note results_wait_time_perception: "4.42 Thinking about when the LAST study that returned results to you concluded and when the results were returned. Did this time waiting for results seem short, long, or as expected to you?"
	label define results_wait_time_perception 1 "a. shorter than expected" 2 "b. as expected" 3 "c. longer than expected"
	label values results_wait_time_perception results_wait_time_perception

	label variable results_return_time_satisfaction "4.413Were you satisfied with how long it took for results to be returned to you?"
	note results_return_time_satisfaction: "4.413Were you satisfied with how long it took for results to be returned to you?"
	label define results_return_time_satisfaction 1 "not satisfied" 2 "somewhat satisfied" 3 "satisfied" 4 "4" 5 "very satisfied" 6 "Did not receive Compensation"
	label values results_return_time_satisfaction results_return_time_satisfaction

	label variable future_study_willingness "4.44 Has your past experience with research studies made you more or less willin"
	note future_study_willingness: "4.44 Has your past experience with research studies made you more or less willing to participate in future studies?"
	label define future_study_willingness 1 "more willing" 2 "No change" 3 "Less willing"
	label values future_study_willingness future_study_willingness

	label variable past_study_challenges_details "4.46 In your past experiences with these \${num_past_studies} research studies, "
	note past_study_challenges_details: "4.46 In your past experiences with these \${num_past_studies} research studies, did you experience any challenges?"
	label define past_study_challenges_details 1 "Yes" 0 "No"
	label values past_study_challenges_details past_study_challenges_details

	label variable past_study_challenges_addressed_ "4.47 What were they?"
	note past_study_challenges_addressed_: "4.47 What were they?"

	label variable past_study_challenges_addressed_ "4.48 Please specify"
	note past_study_challenges_addressed_: "4.48 Please specify"

	label variable other_participant_challenges_hea "4.49 Who was involved in addressing those challenges and concerns?"
	note other_participant_challenges_hea: "4.49 Who was involved in addressing those challenges and concerns?"

	label variable other_participant_challenges_hea "4.50 Please specify Other"
	note other_participant_challenges_hea: "4.50 Please specify Other"

	label variable other_participant_challenges_det "4.51 In your past experiences with these \${num_past_studies} research studies, "
	note other_participant_challenges_det: "4.51 In your past experiences with these \${num_past_studies} research studies, did you hear about other participants having challenges?"
	label define other_participant_challenges_det 1 "Yes" 0 "No"
	label values other_participant_challenges_det other_participant_challenges_det

	label variable other_participant_challenges_add "4.52 What were they?"
	note other_participant_challenges_add: "4.52 What were they?"

	label variable who_involved "4.53 Who was involved in addressing those challenges and concerns?"
	note who_involved: "4.53 Who was involved in addressing those challenges and concerns?"

	label variable important_to_return_results_reso "6.2 It is important for researchers to spend resources, such as time and money, "
	note important_to_return_results_reso: "6.2 It is important for researchers to spend resources, such as time and money, to return research results to participants like yourself and other people in this community."
	label define important_to_return_results_reso 1 "Agree" 2 "Disagree"
	label values important_to_return_results_reso important_to_return_results_reso

	label variable returning_results_shows_respect "6.3 Returning research results to participants/community is the way for research"
	note returning_results_shows_respect: "6.3 Returning research results to participants/community is the way for researchers to show respect to the community"
	label define returning_results_shows_respect 1 "Agree" 2 "Disagree"
	label values returning_results_shows_respect returning_results_shows_respect

	label variable participants_right_to_results "6.4 Participants have a right to be given the results of research they participa"
	note participants_right_to_results: "6.4 Participants have a right to be given the results of research they participated in."
	label define participants_right_to_results 1 "Agree" 2 "Disagree"
	label values participants_right_to_results participants_right_to_results

	label variable importance_of_results_returned "6.5 When deciding to participate in a research project, how important is it that"
	note importance_of_results_returned: "6.5 When deciding to participate in a research project, how important is it that results are returned to you at the end of the study?"
	label define importance_of_results_returned 1 "Very Important" 2 "Not Important"
	label values importance_of_results_returned importance_of_results_returned

	label variable preferred_results_return_method "6.6 In general, what would you prefer of these four choices: Please read out lou"
	note preferred_results_return_method: "6.6 In general, what would you prefer of these four choices: Please read out loud the options"
	label define preferred_results_return_method 1 "1. Receive results one time at the conclusion of the project" 2 "2. Receive updates in the middle and results at the end of the project" 3 "3. Receive multiple update throughout the project and results at the end" 4 "4. Do not receive any updates or results."
	label values preferred_results_return_method preferred_results_return_method

	label variable study_participants "6.8 Study participants"
	note study_participants: "6.8 Study participants"
	label define study_participants 1 "Yes" 2 "No" 3 "Unsure"
	label values study_participants study_participants

	label variable non_participants_research_commun "6.9 Non participants in communities where research took place"
	note non_participants_research_commun: "6.9 Non participants in communities where research took place"
	label define non_participants_research_commun 1 "Yes" 2 "No" 3 "Unsure"
	label values non_participants_research_commun non_participants_research_commun

	label variable local_community_leaders "6.10 Local community leaders where research took place"
	note local_community_leaders: "6.10 Local community leaders where research took place"
	label define local_community_leaders 1 "Yes" 2 "No" 3 "Unsure"
	label values local_community_leaders local_community_leaders

	label variable local_government_officials "6.11 Local governmental officials"
	note local_government_officials: "6.11 Local governmental officials"
	label define local_government_officials 1 "Yes" 2 "No" 3 "Unsure"
	label values local_government_officials local_government_officials

	label variable foreign_government_officials "6.12 Foreign governmental officials"
	note foreign_government_officials: "6.12 Foreign governmental officials"
	label define foreign_government_officials 1 "Yes" 2 "No" 3 "Unsure"
	label values foreign_government_officials foreign_government_officials

	label variable religious_leaders "6.13 Religious leaders"
	note religious_leaders: "6.13 Religious leaders"
	label define religious_leaders 1 "Yes" 2 "No" 3 "Unsure"
	label values religious_leaders religious_leaders

	label variable other_researchers "6.14 Other researchers"
	note other_researchers: "6.14 Other researchers"
	label define other_researchers 1 "Yes" 2 "No" 3 "Unsure"
	label values other_researchers other_researchers

	label variable result_timeline "6.15 In the event that results for this study are shared with you, what is your "
	note result_timeline: "6.15 In the event that results for this study are shared with you, what is your expected timeline for receiving them?"
	label define result_timeline 1 "a. less than 4 weeks" 2 "b. 1-6 months" 3 "c. 7 months - 11 months" 4 "d. 1-3 years" 5 "e. 4-6 years" 6 "f. 7+ years"
	label values result_timeline result_timeline

	label variable rank_results_methods "6.16 Imagine you are receiving results for this study. Rank each way of receivin"
	note rank_results_methods: "6.16 Imagine you are receiving results for this study. Rank each way of receiving results according to your preference, from most preferred to least preffered: [Programmer note: multiple selection, ranking of choices, allow same ranking.]"

	label variable rank_results_preference "7.11 Rank the three formats by your overall personal preference"
	note rank_results_preference: "7.11 Rank the three formats by your overall personal preference"

	label variable rank_formats_preference "7.12 Rank the three formats by how clear the information was to you personally"
	note rank_formats_preference: "7.12 Rank the three formats by how clear the information was to you personally"

	label variable rank_formats_clarity "7.13 Rank the three formats by how effective they would be in your community"
	note rank_formats_clarity: "7.13 Rank the three formats by how effective they would be in your community"

	label variable likelihood_watch_video_results "7.14 How likely are you to spend your own time and data to watch video results f"
	note likelihood_watch_video_results: "7.14 How likely are you to spend your own time and data to watch video results for the study you are currently a participant of?"
	label define likelihood_watch_video_results 1 "Very likely" 2 "Likely" 3 "Not likely"
	label values likelihood_watch_video_results likelihood_watch_video_results

	label variable likelihood_read_sms_results "7.15 How likely are you to spend your own time and data to read SMS results for "
	note likelihood_read_sms_results: "7.15 How likely are you to spend your own time and data to read SMS results for the study you are currently a participant of?"
	label define likelihood_read_sms_results 1 "Very likely" 2 "Likely" 3 "Not likely"
	label values likelihood_read_sms_results likelihood_read_sms_results

	label variable likelihood_listen_audio_results "7.16 How likely are you to spend your own time and data to listen to audio resul"
	note likelihood_listen_audio_results: "7.16 How likely are you to spend your own time and data to listen to audio results for the study you are currently a participant of?"
	label define likelihood_listen_audio_results 1 "Very likely" 2 "Likely" 3 "Not likely"
	label values likelihood_listen_audio_results likelihood_listen_audio_results

	label variable read_sms "7.17 Enumerator: did you read out loud the SMS messages, or did the participant "
	note read_sms: "7.17 Enumerator: did you read out loud the SMS messages, or did the participant read it individually/independently?"
	label define read_sms 1 "a. participant read entirely independently" 3 "b. enumerator read out loud"
	label values read_sms read_sms

	label variable understood_exercise "8.5[ENUMERATOR]: Do you think the respondent understood the exercise?"
	note understood_exercise: "8.5[ENUMERATOR]: Do you think the respondent understood the exercise?"
	label define understood_exercise 1 "Yes, fully" 2 "Yes, somewhat" 3 "not really"
	label values understood_exercise understood_exercise

	label variable exercise_comment "8.6[ENUMERATOR]: Do you think the respondent paid attention to the choices in fr"
	note exercise_comment: "8.6[ENUMERATOR]: Do you think the respondent paid attention to the choices in front of him/her?"
	label define exercise_comment 1 "Paid full attention" 2 "paid some attention" 3 "paid little attention" 4 "paid no attention"
	label values exercise_comment exercise_comment

	label variable exercise_comment_oth "8.7[ENUMERATOR]: Do you have any comments about this exercise?"
	note exercise_comment_oth: "8.7[ENUMERATOR]: Do you have any comments about this exercise?"

	label variable rank_results_preference_2 "7.11 Rank the three formats by your overall personal preference"
	note rank_results_preference_2: "7.11 Rank the three formats by your overall personal preference"

	label variable rank_formats_preference_2 "7.12 Rank the three formats by how clear the information was to you personally"
	note rank_formats_preference_2: "7.12 Rank the three formats by how clear the information was to you personally"

	label variable rank_formats_clarity_2 "7.13 Rank the three formats by how effective they would be in your community"
	note rank_formats_clarity_2: "7.13 Rank the three formats by how effective they would be in your community"

	label variable likelihood_watch_video_results_2 "7.14 How likely are you to spend your own time and data to watch video results f"
	note likelihood_watch_video_results_2: "7.14 How likely are you to spend your own time and data to watch video results for the study you are currently a participant of?"
	label define likelihood_watch_video_results_2 1 "Very likely" 2 "Likely" 3 "Not likely"
	label values likelihood_watch_video_results_2 likelihood_watch_video_results_2

	label variable likelihood_read_sms_results_2 "7.15 How likely are you to spend your own time and data to read SMS results for "
	note likelihood_read_sms_results_2: "7.15 How likely are you to spend your own time and data to read SMS results for the study you are currently a participant of?"
	label define likelihood_read_sms_results_2 1 "Very likely" 2 "Likely" 3 "Not likely"
	label values likelihood_read_sms_results_2 likelihood_read_sms_results_2

	label variable likelihood_listen_audio_results_ "7.16 How likely are you to spend your own time and data to listen to audio resul"
	note likelihood_listen_audio_results_: "7.16 How likely are you to spend your own time and data to listen to audio results for the study you are currently a participant of?"
	label define likelihood_listen_audio_results_ 1 "Very likely" 2 "Likely" 3 "Not likely"
	label values likelihood_listen_audio_results_ likelihood_listen_audio_results_

	label variable read_sms_2 "7.17 Enumerator: did you read out loud the SMS messages, or did the participant "
	note read_sms_2: "7.17 Enumerator: did you read out loud the SMS messages, or did the participant read it individually/independently?"
	label define read_sms_2 1 "a. participant read entirely independently" 3 "b. enumerator read out loud"
	label values read_sms_2 read_sms_2

	label variable own_mobile_phone "9.2 Do you currently own a mobile phone?"
	note own_mobile_phone: "9.2 Do you currently own a mobile phone?"
	label define own_mobile_phone 1 "Yes" 0 "No"
	label values own_mobile_phone own_mobile_phone

	label variable own_smartphone "9.3 Is it a smartphone?"
	note own_smartphone: "9.3 Is it a smartphone?"
	label define own_smartphone 1 "Yes" 2 "No" 3 "I don't know"
	label values own_smartphone own_smartphone

	label variable received_messages_30days "9.6 In the past 30 days, did you receive any messages in your phone?"
	note received_messages_30days: "9.6 In the past 30 days, did you receive any messages in your phone?"
	label define received_messages_30days 1 "Yes" 0 "No"
	label values received_messages_30days received_messages_30days

	label variable interested_receive_result "9.7 Are you interested in receiving the results of this study? Please bear in mi"
	note interested_receive_result: "9.7 Are you interested in receiving the results of this study? Please bear in mind that we do not know how long it will take for the researchers to complete the study and get the results."
	label define interested_receive_result 1 "Yes" 0 "No"
	label values interested_receive_result interested_receive_result

	label variable resp_number "9.8 Can you share a phone number we can reach you to share the results?"
	note resp_number: "9.8 Can you share a phone number we can reach you to share the results?"

	label variable resp_number_own "9.9 Is this your number?"
	note resp_number_own: "9.9 Is this your number?"
	label define resp_number_own 1 "Yes" 0 "No"
	label values resp_number_own resp_number_own

	label variable connected_smartphone "9.10 Is this number connected to a smartphone or regular phone?"
	note connected_smartphone: "9.10 Is this number connected to a smartphone or regular phone?"
	label define connected_smartphone 1 "Smartphone" 2 "Regular phone" 3 "I don't know"
	label values connected_smartphone connected_smartphone

	label variable gps2latitude "9.12 Reocrd GPS (latitude)"
	note gps2latitude: "9.12 Reocrd GPS (latitude)"

	label variable gps2longitude "9.12 Reocrd GPS (longitude)"
	note gps2longitude: "9.12 Reocrd GPS (longitude)"

	label variable gps2altitude "9.12 Reocrd GPS (altitude)"
	note gps2altitude: "9.12 Reocrd GPS (altitude)"

	label variable gps2accuracy "9.12 Reocrd GPS (accuracy)"
	note gps2accuracy: "9.12 Reocrd GPS (accuracy)"

	label variable interview_result "9.13 Select interview result"
	note interview_result: "9.13 Select interview result"
	label define interview_result 1 "Complete" 2 "Refusal" 3 "Respondent not available" -96 "Other Specify"
	label values interview_result interview_result

	label variable interview_result_oth "9.13a Please specify"
	note interview_result_oth: "9.13a Please specify"

	label variable end_commet "9.14 [ENUMERATOR]: Please write any comment about this survey"
	note end_commet: "9.14 [ENUMERATOR]: Please write any comment about this survey"






	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  ./Returning results (RCT participants) - Tandika_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes

capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}


* launch .do files to process repeat groups

do "import_returning_results_rct_participants_dar_tandika-consented-section8-dce_game.do"
