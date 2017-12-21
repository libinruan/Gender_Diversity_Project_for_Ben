clear
set more off
cd "E:\Dropbox\gender\NSF Data\LiPinJuan\1966-2014_mark"

capture program drop sub1
program define sub1
args fn
clear
insheet using `fn'.csv, comma
drop if v1==""

generate code =  2 if v1 == "Agricultural sciences and natural resources"
replace code =  4 if v1 == "Biological, biomedical sciences"
replace code = 16 if v1 == "Health sciences"
replace code =  7 if v1 == "Chemistry"
replace code = 10 if v1 == "Computer and information sciences"
replace code = 15 if v1 == "Geosciences"
replace code = 21 if v1 == "Mathematics"
replace code = 27 if v1 == "Physics and astronomy"
replace code =  3 if v1 == "Anthropology"
replace code = 11 if v1 == "Economics"
replace code = 28 if v1 == "Political science"
replace code = 29 if v1 == "Psychology"
replace code = 30 if v1 == "Sociology"
replace code = 24 if v1 == "Other social sciences"
replace code =  1 if v1 == "Aerospace, aeronautical, and astronautical engineering"
replace code =  6 if v1 == "Chemical engineering"
replace code =  8 if v1 == "Civil engineering"
replace code = 13 if v1 == "Electrical, electronics, and communication engineering"
replace code = 18 if v1 == "Industrial and manufacturing engineering"
replace code = 20 if v1 == "Materials science engineering"
replace code = 22 if v1 == "Mechanical engineering"
replace code = 25 if v1 == "Other engineering"
replace code = 12 if v1 == "Education administration"
replace code = 31 if v1 == "Teaching fields"
replace code = 14 if v1 == "Foreign languages and literature"
replace code = 17 if v1 == "History"
replace code = 19 if v1 == "Letters"
replace code = 26 if v1 == "Other humanities"
replace code =  5 if v1 == "Business management and administration"
replace code =  9 if v1 == "Communication"
replace code = 23 if v1 == "Non-S&E fields not elsewhere classified"
drop if code==.

generate idx = [_n]
generate type = "All" if _n<=31
replace type = "USPermResi" if 32<=_n & _n<=62
replace type = "Hispanic" if 63<=_n & _n<=93
replace type = "AmInd" if 94<=_n & _n<=124
replace type = "Asian" if 125<=_n & _n<=155
replace type = "Black" if 156<=_n & _n<=186
replace type = "White" if 187<=_n & _n<=217
replace type = "MultiRace" if 218<=_n & _n<=248
replace type = "DKrace" if 249<=_n & _n<=279
replace type = "DKethinicity" if 280<=_n & _n<=310
replace type = "TempVisa" if 311<=_n & _n<=341

generate tcode = 1 if type == "All"
replace tcode = 2 if type ==  "USPermResi"
replace tcode = 3 if type ==  "Hispanic"
replace tcode = 4 if type ==  "AmInd"
replace tcode = 5 if type ==  "Asian"
replace tcode = 6 if type ==  "Black"
replace tcode = 7 if type ==  "White"
replace tcode = 8 if type ==  "MultiRace"
replace tcode = 9 if type ==  "DKrace"
replace tcode = 10 if type == "DKethinicity"
replace tcode = 11 if type == "TempVisa"

drop idx
rename v1 fl_d
drop type
order fl_d code tcode
reshape long v, i(code tcode) j(year)

generate gcode = .
replace gcode = 1 if "`fn'" == "Total"|"`fn'"=="total"
replace  gcode = 2 if "`fn'" == "Men"|"`fn'"=="men"
replace  gcode = 3 if "`fn'" == "Women"|"`fn'"=="women"

reshape wide v, i(year fl_d) j(tcode)

foreach i of var *v*{
	local new = substr("`i'",2,length("`i'"))
	rename `i' `fn'`new'
}

sort year fl_d
save `fn'.dta, replace
end

#delimit ;
local filename
Total
Women
Men;
#delimit cr

local n: word count `filename'
forvalues i = 1/`n'{
	local temp : word `i' of `filename'
	sub1 `temp'
}

use Total.dta, replace
merge 1:1 year fl_d using Women
drop _merge
merge 1:1 year fl_d using Men
drop _merge

order year fl_d code Total1-Total11 Women1-Women11 Men1-Men11 gcode

! del Total.dta
! del Women.dta
! del Men.dta

generate new1 = Women1/(Women1+Men1)
generate new2 = Total1-Men1-Women1
generate new3 = Total1-Total2-Total11
generate new4 = Total2-Men2-Women2
generate new5 = Total11-Men11-Women11
generate new6 = new2-new4-new5
generate new7 = Women1-Women2-Women11
generate new8 = Men1-Men2-Men11
generate new9  = Total8 + Total9 + Total10 + Total11
generate new10 = Men8 + Men9 + Men10 + Men11
generate new11 = Women8 + Women9 + Women10 + Women11

sort year fl_d
order year fl_d Total1 new2 Women1 Men1 new1 Total2 new3 Total11 new4 new6 new5 Women2 new7 Women11 Men2 new8 Men11 new9 Total3-Total7 new11 Women3-Women7 new10 Men3-Men7
outsheet using "data1966to2014mark.csv", comma replace 
