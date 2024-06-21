/*Code - A Cross-National Examination of the Effect of Temperature Change on Homicide Trends: A Macro-Level Test of the Temperature-Aggression Effect
Version Date: April 24, 2024

-World Bank's Climate Change Knowledge Portal (CCKP)
https://climateknowledgeportal.worldbank.org/download-data

-Observed temperature: CRU TS v.4.05
Citable as: Harris, I., Osborn, T. J., Jones, P., & Lister, D. (2020). Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. Scientific data, 7(1), Article Number 109. https://doi.org/10.1038/s41597-020-0453-3

-Projected temperature: Coupled Model Intercomparison Project Phase 6 (CMIP6)
*/

**# Read
use "Manuscript Replication Data", clear
xtset eCountry Year


**# Descriptives
sum HomRate ln_HomRate Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, sep(0)
sum HomRate ln_HomRate Temp_Annual if esample == 1, detail

sum GDP_PerCap if esample == 1, detail
global val1 = r(p5)
global val2 = r(p50)
global val3 = r(p95)

// Min & Max
global measure PerMale
sum $measure if esample == 1
list Country Year $measure if ($measure == r(max) | $measure == r(min)) & esample == 1


**# Models
// Cross-sectional
reg ln_HomRate Temp_Annual if esample == 1, cluster(eCountry)
reg ln_HomRate Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, cluster(eCountry)
reg ln_HomRate Temp_Annual SWIID_Gini if esample == 1, cluster(eCountry)

reg ln_HomRate c.Temp_Annual##c.Temp_Annual if esample == 1, cluster(eCountry)
reg ln_HomRate c.Temp_Annual##c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, cluster(eCountry)
reg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, cluster(eCountry)

// Longitudinal
xtreg ln_HomRate Temp_Annual if esample == 1, fe cluster(eCountry)
xtreg ln_HomRate Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, fe cluster(eCountry)
xtreg ln_HomRate Temp_Annual GDP_PerCap if esample == 1, fe cluster(eCountry)

xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual if esample == 1, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, fe cluster(eCountry)


**# Predicted Values (Margins)
* Figure. Predicted Homicide Rate by Temperature
// Panel A - Pooled Cross-Sectional Models
reg ln_HomRate c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, cluster(eCountry)
margins, at(Temp_Annual = (0(5)30)) expression(exp(predict(xb)))
marginsplot

reg ln_HomRate c.Temp_Annual##c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, cluster(eCountry)
margins, at(Temp_Annual = (0(5)30)) expression(exp(predict(xb)))
marginsplot

// Panel B – Fixed Effects Models
xtreg ln_HomRate c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, fe cluster(eCountry)
margins, at(Temp_Annual = (0(5)30)) expression(exp(predict(xb)))
marginsplot

xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, fe cluster(eCountry)
margins, at(Temp_Annual = (0(5)30)) expression(exp(predict(xb)))
marginsplot

* Figure 4 - Predicted Homicide Rate by Temperature and GDP per Capita
// Moderation GDP
reg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, cluster(eCountry)
margins, at(Temp_Annual = (0(5)30) GDP_PerCap = ($val1 $val2 $val3)) expression(exp(predict(xb)))
marginsplot

xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1, fe cluster(eCountry)
margins, at(Temp_Annual = (0(5)30) GDP_PerCap = ($val1 $val2 $val3)) expression(exp(predict(xb)))
marginsplot


**# Other Figures
// Note: Final manuscript figures were developed in excel

**## Figure. Mean Land Temperature of the World and By Region – Observed from 1901 to 2021 And Forecasted from 2022 to 2100
* World
use "Manuscript Replication Data", clear

// Generate
gen Represent = 1
gen Countries = 1 / Land2020 if Temp_Annual ~= .

// Collapse
collapse (mean) Temp_Annual tas (sum) Countries Represent [pweight=Land2020], by(Year)
gen Region = "World"
label var Temp_Annual "Observed"
label var tas "Projected"

// Graph
twoway (line Temp_Annual Year, color(black)) (line tas Year if Year >= 2021, color(black) lpattern(shortdash)) if Region == "World", ytitle("Mean Temperature (Celsius)")

* Regions
use "Manuscript Replication Data", clear

// Generate
gen Represent = 1
gen Countries = 1 / Land2020 if Temp_Annual ~= .

// Collapse
collapse (mean) Temp_Annual tas (sum) Countries Represent [pweight=Land2020], by(Region Year)
label var Temp_Annual "Observed"
label var tas "Projected"

// Graph
twoway (line Temp_Annual Year, color(black)) (line tas Year if Year >= 2021, color(black) lpattern(shortdash)), ytitle("Mean Temperature (Celsius)") by(Region)


**## Figure. Choropleth World Map of Average Temperature by Country
// Reproduce the values only; The map was developed using MapChart at https://www.mapchart.net/world.html
use "Manuscript Replication Data", clear

gsort Temp_Annual
list Short Temp_Annual if Year == 2018, sep(0)


**# Appendices
frames reset
use "Manuscript Replication Data", clear

**## Appendix. List of Countries, Years, and Variable's Means in the Analytic Sample
frame copy default AppendixA, replace
frame change AppendixA

keep if esample == 1
gen Num = 1
collapse (mean) HomRate ln_HomRate Temp_Annual GDP_PerCap Pop2024 (min) MinYear = Year (max) MaxYear = Year (sum) Num, by(Region Short Total_Score)
sort Region Short
list Region Short MinYear MaxYear HomRate Total_Score Temp_Annual GDP_PerCap Pop2024, sep(0) // Appendix. List of Countries, Years, and Variable's Means in the Analytic Sample
list Region Temp_Annual ln_HomRate, sep(0) // Figure. Bivariate Scatterplot of the Homicide Rate (ln) by Temperature
graph twoway (scatter ln_HomRate Temp_Annual, color(black) msymbol(Oh)) (lfit ln_HomRate Temp_Annual, color(gray) lpattern(shortdash)), xtitle("Mean Temperature (Celsius)") ytitle("(ln) Homcide Rate") xlabel(-5(5)30) ylabel(-1(1)5) legend(off) 
cor ln_HomRate Temp_Annual

frame change default
frame drop AppendixA

**## Appendix. Excluding countries with Low Data Reliability
xtreg ln_HomRate Temp_Annual if esample == 1 & (Total_Score == "Good" | Total_Score == "Fair"), fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & (Total_Score == "Good" | Total_Score == "Fair"), fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual if esample == 1 & (Total_Score == "Good" | Total_Score == "Fair"), fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & (Total_Score == "Good" | Total_Score == "Fair"), fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & (Total_Score == "Good" | Total_Score == "Fair"), fe cluster(eCountry)

// Margins
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & (Total_Score == "Good" | Total_Score == "Fair"), fe cluster(eCountry)
margins, at(Temp_Annual = (0(5)30) GDP_PerCap = ($val1 $val2 $val3)) expression(exp(predict(xb)))

// Descriptives
gen esample_quality = esample
replace esample_quality = 0 if Total_Score ~= "Good" & Total_Score ~= "Fair"
sum HomRate ln_HomRate Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample_quality == 1, sep(0)

**## Appendix. Excluding countries with less than 10 years of data
xtreg ln_HomRate Temp_Annual if esample == 1 & Years >= 10, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & Years >= 10, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual if esample == 1 & Years >= 10, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & Years >= 10, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & Years >= 10, fe cluster(eCountry)

// Margins
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & Years >= 10, fe cluster(eCountry)
margins, at(Temp_Annual = (0(5)30) GDP_PerCap = ($val1 $val2 $val3)) expression(exp(predict(xb)))

// Descriptives
gen esample_years = esample
replace esample_years = 0 if Years < 10
sum HomRate ln_HomRate Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample_years == 1, sep(0)

**## Appendix. Excluding Larger Countries
xtreg ln_HomRate c.Temp_Annual if esample == 1 & Land2020 < 1000000, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & Land2020 < 1000000, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual if esample == 1 & Land2020 < 1000000, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & Land2020 < 1000000, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & Land2020 < 1000000, fe cluster(eCountry)

// Margins
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample == 1 & Land2020 < 1000000, fe cluster(eCountry)
margins, at(Temp_Annual = (0(5)30) GDP_PerCap = ($val1 $val2 $val3)) expression(exp(predict(xb)))

// Descriptives
gen esample_large = esample
replace esample_large = 0 if Land2020 >= 1000000
sum HomRate ln_HomRate Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 if esample_large == 1, sep(0)

**## Appendix. Two-Way Fixed Effects
xtreg ln_HomRate Temp_Annual i.Year if esample == 1, fe cluster(eCountry)
xtreg ln_HomRate Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 i.Year if esample == 1, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual i.Year if esample == 1, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 i.Year if esample == 1, fe cluster(eCountry)
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 i.Year if esample == 1, fe cluster(eCountry)

// Margins
xtreg ln_HomRate c.Temp_Annual##c.Temp_Annual##c.GDP_PerCap SWIID_Gini Inflation InfantMort Unemployment Per15_29 PerMale PerUrban polity2 i.Year if esample == 1, fe cluster(eCountry)
margins, at(Temp_Annual = (0(5)30) GDP_PerCap = ($val1 $val2 $val3)) expression(exp(predict(xb)))