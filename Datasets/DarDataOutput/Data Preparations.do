**** Data preparartions
import excel ".\Mbagala\sample.xlsx",clear first
tempfile mbagala
save `mbagala'

import excel ".\Temeke\sample.xlsx",clear first
tempfile temeke
save `temeke'

import excel ".\Tandika\sample.xlsx",clear first
tempfile tandika
save `tandika'
clear
ap using `mbagala' `temeke' `tandika'
ren respondent_index respondentid
tostring respondentid,replace
keep respondentid respondent_name wardID villageID
tempfile all_sample
save `all_sample'

** replacement
import excel ".\Mbagala\sample_replacement.xlsx",clear first

tempfile mbagala_r
save `mbagala_r'

import excel ".\Temeke\sample_replacement.xlsx",clear first
tempfile temeke_r
save `temeke_r'

import excel ".\Tandika\sample_replacement.xlsx",clear first
tempfile tandika_r
save `tandika_r'
clear
ap using `mbagala_r' `temeke_r' `tandika_r'
ren (respondent_index respondent_name) (respondentid replacement_name)
tostring respondentid,replace
keep respondentid replacement_name wardID villageID
tempfile all_sample_r
save `all_sample_r'
mer 1:1 respondentid using `all_sample',nogen
order respondent_name,after(villageID)
ren (respondent_name replacement_name) (org_resp rep_resp)
destring respondentid,replace
save `all_sample',replace


** Main Data
**# Mbagala
u ".\Mbagala\Returning results (RCT participants) - Mbagala.dta",clear
tempfile Mbagala
save `Mbagala'

**# Tandika
u ".\Tandika\Returning results (RCT participants) - Tandika.dta",clear
tostring v188,replace
tempfile Tandika
save `Tandika'

**# Temeke
u ".\Temeke\Returning results (RCT participants) - Temeke.dta",clear
tostring v188,replace
tempfile Temeke
save `Temeke'

**# Combine Main Table
clear
ap using `Mbagala' `Tandika' `Temeke'
save "./raw/RR-RCT",replace


** Main Data
**# Mbagala
u ".\Mbagala\Returning results (RCT participants) - Mbagala-consented-section8-dce_game.dta",clear
tempfile Mbagala_dce
save `Mbagala_dce'

**# Tandika
u ".\Tandika\Returning results (RCT participants) - Tandika-consented-section8-dce_game.dta",clear
tempfile Tandika_dce
save `Tandika_dce'

**# Temeke
u ".\Temeke\Returning results (RCT participants) - Temeke-consented-section8-dce_game.dta",clear
tempfile Temeke_dce
save `Temeke_dce'

**# Combine DCE Table
clear
ap using `Mbagala_dce' `Tandika_dce' `Temeke_dce'
save "./raw/RR-RCT-DCE",replace

*** Data cleaning
**# Copy raw files to cleaning folder
loc files : dir "./raw/" files "*.dta",respect nofail
foreach file in `files'{
	copy "./raw/`file'" "./cleaning/`file'",replace
}

**# Drop Duplicates
foreach file in `files'{
	u "./cleaning/`file'",clear
	drop if regexm(key,"uuid:f2e21426-2d77-4cec-a97a-05092f8056af")
	drop if regexm(key,"uuid:daa602ec-f689-4d57-974c-44c147f26aac")
	drop if regexm(key,"uuid:d013f7b2-0890-4c7d-9fbb-5c52fa2dc00d")
	drop if regexm(key,"uuid:24d2233a-aeb7-4c51-9c42-4cbccc8769d7")
	drop if regexm(key,"uuid:0e4ff022-0da6-4665-9410-69ff0cd2c79f")
	drop if regexm(key,"uuid:f9888f5c-8ba1-4ca8-9326-6cd4a61bd0bf")
	drop if regexm(key,"uuid:5572bde7-2458-4b91-bce0-2f589f3a51d1")
	save "./cleaning/`file'",replace
}

** Main table
u "./cleaning/RR-RCT",clear
**# Format Date and time
findname,any(ustrregexm(@,"([0-9]){4}-([A-Za-z]){3}-([0-9]){1,2} ([0-9]){2}:([0-9]){2}:([0-9]){2}")) loc(ts)
foreach var of varlist `ts'{
	g double `var'2=clock(`var',"YMDhms"),after(`var')
	format `var'2 %tcDay__DD/NN/YY__Hh:MMAM
	drop `var'
	ren `var'2 `var'
}

**# Labelling
**# Study Activities
mrsplit study_activities,valsep(" ") manlabel(1 "a.  interviewed" 2 "b. recieved a voucher or coupon" 3 "c. had blood drawn" 4 "d. participated in a meeting or focus group" 5 "e. received training" 6 "f. received a document" 7 "g. received a cash transfer" 8 "h. played a game (with prizes)" 9 "i. took a survey" 10 "j. took a pill" 11 "k. provided a bodily sample (such as urine, cheek swab)" 12 "l. received a product for household use" 13 "m. other (specify)") ln(study_activities)
order study_activities1 study_activities3 study_activities5 study_activities7 study_activities9  study_activities11,after(study_activities)


loc i=1
foreach var of varlist v178-v187{
	replace `var'=`i' if `var'==1
	replace `var'=. if `var'==0
	loc i = `i'+1
}
la de past_study_challenges_addressed_ 1 "a. compensation" 2 "b. confidentiality breach" 3 "c. unable to contact team" 4 "d. upset about not recieving intervention (control group assignment)" 5 "e. disrespectful or negative experience with research team or implementer" 6 "f. difficulty understanding consent process" 7 "g. no challenges" 8 "h. Difficult with finding childcare" 9 "i. missed wages from needing to skip work" 10 "h. other (specify)"
la val v178-v187 past_study_challenges_addressed_


loc i=1
foreach var of varlist v190-v199{
	replace `var'=`i' if `var'==1
	replace `var'=. if `var'==0
	loc i = `i'+1
}
la de other_participant_challenges_hea 1 "a. Research staff members" 2 "b. Police" 3 "c. Local implementer (NGOs, etc)" 4 "d. Community political leader" 5 "e. Religious leader" 6 "f. Other community participants" 7 "g. Elders" 8 "h. Head teacher/schoolmaster" 9 "No one addressed these concers" 10 "i. Other (please specify)"
la val v190-v199 other_participant_challenges_hea

loc i=1
foreach var of varlist v203-v212{
	replace `var'=`i' if `var'==1
	replace `var'=. if `var'==0
	loc i = `i'+1
}
la de other_participant_challenges_add 1 "a. compensation" 2 "b. confidentiality breach" 3 "c. unable to contact team" 4 "d. upset about not recieving intervention (control group assignment)" 5 "e. disrespectful or negative experience with research team or implementer" 6 "f. difficulty understanding consent process" 7 "g. no challenges" 8 "h. Difficult with finding childcare" 9 "i. missed wages from needing to skip work" 10 "h. other (specify)"
la val v203-v212 other_participant_challenges_add


loc i=1
foreach var of varlist who_involved_1-who_involved_10{
	replace `var'=`i' if `var'==1
	replace `var'=. if `var'==0
	loc i = `i'+1
}
la de who_involved 1 "a. Research staff members" 2 "b. Police" 3 "c. Local implementer (NGOs, etc)" 4 "d. Community political leader" 5 "e. Religious leader" 6 "f. Other community participants" 7 "g. Elders" 8 "h. Head teacher/schoolmaster" 9 "No one addressed these concers" 10 "i. Other (please specify)"
la val  who_involved_1-who_involved_10 who_involved

**# Rank Methods
split rank_results_methods,p(" ")
order rank_results_methods1-rank_results_methods9,after(rank_results_methods)
destring rank_results_methods1-rank_results_methods9,replace
la de rank_results_methods 1"a. audio message" 2"b. SMS" 3"c. Website" 4"d. Flyer (delivered to an individual)" 5"e. Flyer (posted to a public space)" 6"f. Social Media Post" 7"g. Video" 8"h. Public meeting with a local authority" 9"i. Private meeting with a person"
la val rank_results_methods1-rank_results_methods9 rank_results_methods

**# Rank personal preference
split rank_results_preference,p(" ")
order rank_results_preference1-rank_results_preference3,after(rank_results_preference)
destring rank_results_preference1-rank_results_preference3,replace
la de rank_results_preference 1"Video" 2"SMS message" 3"Audio message"
la val rank_results_preference1-rank_results_preference3 rank_results_preference

split v279,p(" ")
order v2791-v2793,after(v279)
destring v2791-v2793,replace
la de v279 1"Video" 2"SMS message" 3"Audio message"
la val v2791-v2793 v279

split v283,p(" ")
order v2831-v2833,after(v283)
destring v2831-v2833,replace
la de v283 1"Video" 2"SMS message" 3"Audio message"
la val v2831-v2833 v283

split v287,p(" ")
order v2871-v2873,after(v287)
destring v2871-v2873,replace
la de v287 1"Video" 2"SMS message" 3"Audio message"
la val v2871-v2873 v287





**# Rank clear information
split rank_formats_preference,p(" ")
order rank_formats_preference1-rank_formats_preference3,after(rank_formats_preference)
destring rank_formats_preference1-rank_formats_preference3,replace
la de rank_formats_preference 1"Video" 2"SMS message" 3"Audio message"
la val rank_formats_preference1-rank_formats_preference3 rank_formats_preference

**# Rank community preference
split rank_formats_clarity,p(" ")
order rank_formats_clarity1-rank_formats_clarity3,after(rank_formats_clarity)
destring rank_formats_clarity1-rank_formats_clarity3,replace
la de rank_formats_clarity 1"Video" 2"SMS message" 3"Audio message"
la val rank_formats_clarity1-rank_formats_clarity3 rank_formats_clarity

**# decode location
encode districtid,gen(districtID)
order districtID,after(districtid)
encode wardid,gen(wardID)
order wardID,after(wardid)
encode villageid,gen(villageID)
order villageID,after(villageid)


**# destring numeric values
destring respondentid rand_interested_receive_result sec_7_8_random random random_choice hh_size_calc,replace

**# Resposndent of this survey
mer 1:1 respondentid using `all_sample',keepusing(org_resp rep_resp) nogen keep(3)
replace replacement_respondent=rep_resp if !mi(replacement_respondent)

ge final_respondent=cond(!mi(replacement_respondent2),replacement_respondent2,cond(!mi(replacement_respondent),replacement_respondent,respondent_name)),before(consent)
la var final_respondent "Respondent respondended to this survey"

**# Format string Vars
foreach var of varlist respondent_name replacement_respondent replacement_respondent2 final_respondent{
	replace `var'=proper(`var')
}


**# Wrongly recorded 0 other adults for maried respondent_index
replace hh_adults=1 if key=="uuid:950d02ea-8558-4c86-9a9d-19e80a5c142f"
replace hh_adults=1 if key=="uuid:101fb8c4-7e3c-4f2e-9950-f68efdb9828d"
replace hh_adults=1 if key=="uuid:8005a187-fd2d-4e94-909a-527ea543ddd4"
replace hh_adults=1 if key=="uuid:18cce15b-7d44-4a3d-ab7b-6dd437347dae"


**clean other specify
replace hear_study=5 if key=="uuid:afd3486f-f4e9-447f-a024-a25d149eafe1"
replace hear_study_oth="" if key=="uuid:afd3486f-f4e9-447f-a024-a25d149eafe1"


**# drop unwanted variables
drop deviceid devicephonenum device_info duration caseid int_name text_audit light_level movement sound_level sound_pitch conversation comments username districtid wardid villageid respondent_index replacement_name study_activities_1-study_activities_13 rank_results_methods_1-rank_results_methods_9 org_resp rep_resp rank_results_preference_1 rank_results_preference_2 rank_results_preference_3 rank_formats_preference_1 rank_formats_preference_2 rank_formats_preference_3 rank_formats_clarity_1 rank_formats_clarity_2 rank_formats_clarity_3 rank_results_preference_2_1 rank_results_preference_2_2 rank_results_preference_2_3 rank_formats_preference_2_1 rank_formats_preference_2_2 rank_formats_preference_2_3 rank_formats_clarity_2_1 rank_formats_clarity_2_2 rank_formats_clarity_2_3

**# save cleaned dataset
save "./cleaning/RR-RCT",replace

**# DCE Table
u "./cleaning/RR-RCT-DCE"
destring game_index choicenumber,replace
ren (parent_key key) (key parent_key)
mer m:1 key using "./cleaning/RR-RCT",keep(3) nogen keepusing(districtID wardID villageID respondentid)
order districtID wardID villageID respondentid,first
sort respondentid game_index
save "./cleaning/RR-RCT-DCE",replace
