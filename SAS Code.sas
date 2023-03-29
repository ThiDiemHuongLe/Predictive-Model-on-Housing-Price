*-------------------------------*
|BAN210 - Predictive Analysis   |
|Work done by Thi Diem Huong Le |
|House Price Dataset            |
|Date 10th Dec 2022             | 
*-------------------------------*;

/*DATA UPLOADING------------------------------------------------------------------------------*/
/*Import dataset into Sas---------------------------------------------------------------------*/
proc import datafile="/home/u61488433/BAN210/Housing_Prices.xlsx" 
			dbms=xlsx
			out=HousePrice
			replace;
run;

/*First 5lines of our dataset-----------------------------------------------------------------*/
proc print data=HousePrice (obs=5);
run;

/*Total number of numeric variables-----------------------------------------------------------*/
proc means data=HousePrice; 
   var _NUMERIC_;          
run;

/*Total number of categorical variables-------------------------------------------------------*/
proc freq data=HousePrice; 
   tables _CHARACTER_;         
run;

/*DATA CLEANING/PREPARATION AND FEATURE ENGINEERING-------------------------------------------*/
/*We deal with numeric variables--------------------------------------------------------------*/
/*Check correlation between numeric variable with target variable-----------------------------*/
proc corr data=HousePrice ; 
var
SalePrice
Lot_Area
Overall_Qual
Overall_Cond
Year_Built
Gr_Liv_Area
Bedroom_AbvGr
Fireplaces
Garage_Area
Mo_Sold
Yr_Sold
Basement_Area
Full_Bathroom
Half_Bathroom
Total_Bathroom
Deck_Porch_Area
Age_Sold
Season_Sold
Overall_Qual2
Overall_Cond2
Log_Price
Bonus;
run;
/*=> Based on this table, we will select 11 num variable as having >50% coefficient-----------*/

/*Next, we deal with categorical variables----------------------------------------------------*/
/*Dummy coding for categorical variables - I select House_style2 for this part----------------*/;
/*Use proc freq to check the frequency*/
proc freq data=HousePrice;
table House_Style2;
run;
/*Create dummy coding for all categories of House_Style2*/
data HousePrice;
set HousePrice;
If House_Style2 = "1Story" then House_Style2_1 = 1; else House_Style2_1 = 0;
If House_Style2 = "1.5Fin" then House_Style2_2 = 2; else House_Style2_2 = 0;
If House_Style2 = "2Story" then House_Style2_3 = 3; else House_Style2_3 = 0;
If House_Style2 = "SFoyer" then House_Style2_4 = 4; else House_Style2_4 = 0;
If House_Style2 = "SLvl" then House_Style2_5 = 5; else House_Style2_5 = 0;
run;

/*Next is to deal with missing values---------------------------------------------------------*/
proc means data=HousePrice  n nmiss ; /*numeric var*/
run;
/*=> no missing value for all numeric variables*/

proc freq data=HousePrice; /*categorical var*/
table House_Style2 Heating_QC Central_Air Garage_Type_2 Foundation_2 Masonry_Veneer Lot_Shape_2
Bonus	score;
run;
/*=> for any missing or NA values for categorical variables, we replace them by mode. It does not 
make sense to replace them with median or mean for categorical variables*/
/*Replace NA and missing values by mode for the following variables*/
data HousePrice;
set HousePrice;
if Garage_Type_2="NA" then Garage_Type_2="Attached";
if Garage_Type_2="" then Garage_Type_2="Attached";
run;

proc freq data=HousePrice;/*check to see if NA and missing variables are replaced*/
table Garage_Type_2;
run;

data HousePrice;
set HousePrice;
if Masonry_Veneer="" then Masonry_Veneer="N";
run;

proc freq data=HousePrice;/*check to see if NA and missing variables are replaced*/
table Masonry_Veneer;
run;

data HousePrice;
set HousePrice;
if Lot_Shape_2="" then Lot_Shape_2="Regular";
run;

proc freq data=HousePrice;/*check to see if NA and missing variables are replaced*/
table Lot_Shape_2;
run;

/*Next we drop PID column as it is just ID number - not adding any info; we drop House_style
column as it is included in simpler manner in column House_Style2; we drop score as it does
not contain any values; we drop log_Price as we dont wish to release values of variables
that we are trying to predict*/

data HousePrice;
set HousePrice (drop = PID House_Style score Log_Price);
run;

/*Numeric variables - Removing outliers-----------------------------------------------------*/
title "Box plot of year built";
proc sgplot data = HousePrice;
vbox Year_Built;
run;

title "Box plot of living area";
proc sgplot data = HousePrice;
vbox Gr_Liv_Area;
run;

title "Box plot of grarage area";
proc sgplot data = HousePrice;
vbox Garage_Area;
run;

/*=> possible outliers*/
proc means data = HousePrice noprint;
   var Year_Built;
   output out=houseQ
          Q1=
          Q3=
          QRange= / autoname;
run;

data HousePrice;
   set HousePrice;
   if _n_ = 1 then set houseQ;
   if Year_Built le Year_Built_Q1 - 1.5*Year_Built_QRange and not missing(Year_Built) or
      Year_Built ge Year_Built_Q3 + 1.5*Year_Built_QRange then
      outlier = 'x';
run;

proc freq data=HousePrice;
table outlier;
run;

data HousePrice;
set HousePrice;
if outlier ne 'x';
run;

proc means data = HousePrice noprint;
   var Gr_Liv_Area;
   output out=houseQ
          Q1=
          Q3=
          QRange= / autoname;
run;

data HousePrice;
   set HousePrice;
   if _n_ = 1 then set houseQ;
   if Gr_Liv_Area le Gr_Liv_Area_Q1 - 1.5*Gr_Liv_Area_QRange and not missing(Gr_Liv_Area) or
     Gr_Liv_Area ge Gr_Liv_Area_Q3 + 1.5*Gr_Liv_Area_QRange then
      outlier = 'x';
run;

proc freq data=HousePrice;
table outlier;
run;

data HousePrice;
set HousePrice;
if outlier ne 'x';
run;

proc means data = HousePrice noprint;
   var Garage_Area;
   output out=houseQ
          Q1=
          Q3=
          QRange= / autoname;
run;

data HousePrice;
   set HousePrice;
   if _n_ = 1 then set houseQ;
   if Garage_Area le Garage_Area_Q1 - 1.5*Garage_Area_QRange and not missing(Garage_Area) or
     Garage_Area ge Garage_Area_Q3 + 1.5*Garage_Area_QRange then
      outlier = 'x';
run;

proc freq data=HousePrice;
table outlier;
run;

data HousePrice;
set HousePrice;
if outlier ne 'x';
run;

/*EXPLORATORY DATA-------------------------------------------------------------------------*/
proc sgplot data=HousePrice;
scatter x=Overall_Qual y=SalePrice; 	
ellipse x=Overall_Qual y=SalePrice; 	
reg x=Overall_Qual y=SalePrice/cli clm;
run;

proc sgplot data=HousePrice;
scatter x=Year_Built y=SalePrice; 	
ellipse x=Year_Built y=SalePrice; 	
reg x=Year_Built y=SalePrice/cli clm;
run;

proc sgplot data=HousePrice;
scatter x=Gr_Liv_Area y=SalePrice; 	
ellipse x=Gr_Liv_Area y=SalePrice; 	
reg x=Gr_Liv_Area y=SalePrice/cli clm;
run;

proc sgplot data=HousePrice;
scatter x=Garage_Area y=SalePrice; 	
ellipse x=Garage_Area y=SalePrice; 	
reg x=Garage_Area y=SalePrice/cli clm;
run;

proc sgplot data=HousePrice;
scatter x=Basement_Area y=SalePrice; 	
ellipse x=Basement_Area y=SalePrice; 	
reg x=Basement_Area y=SalePrice/cli clm;
run;

proc sgplot data=HousePrice;
scatter x=Full_Bathroom y=SalePrice; 	
ellipse x=Full_Bathroom y=SalePrice; 	
reg x=Full_Bathroom y=SalePrice/cli clm;
run;

proc sgplot data=HousePrice;
scatter x=Total_Bathroom y=SalePrice; 	
ellipse x=Total_Bathroom y=SalePrice; 	
reg x=Total_Bathroom y=SalePrice/cli clm;
run;

proc sgplot data=HousePrice;
scatter x=Age_Sold y=SalePrice; 	
ellipse x=Age_Sold y=SalePrice; 	
reg x=Age_Sold y=SalePrice/cli clm;
run;

/*DATA SPLIT-------------------------------------------------------------------------------*/
data temp; 
set HousePrice; 
n=ranuni(100); 
run; 
  
proc sort data=temp; by n;
run;

data training testing; 
set temp nobs=nobs; 
if _n_<=.8*nobs then output training; 
else output testing; 
run;

/*BUILDING PREDICTIVE MODEL USING LINEAR REGRESSION ON TRAINING DATASET---------------------*/
/*Forward method*/
proc reg data = training outest = stepwise_summary;
model SalePrice = Overall_Qual Year_Built Gr_Liv_Area Garage_Area Basement_Area Full_Bathroom Total_Bathroom
Age_sold Overall_Qual2  Bonus House_Style2_1 House_Style2_2 House_Style2_3 House_Style2_4
House_Style2_5 / selection = forward slentry=0.01 slstay=0.01 AIC VIF BIC MSE; 
output out=stepwise_out pred=yhat residual = resid ucl=ucl lcl=lcl cookd=cook  
covratio=cov dffits=dfits press=prss;
run;

/*Backward method*/
proc reg data = training outest = stepwise_summary;
model SalePrice = Overall_Qual Year_Built Gr_Liv_Area Garage_Area Basement_Area Full_Bathroom Total_Bathroom
Age_sold Overall_Qual2 Bonus House_Style2_1 House_Style2_2 House_Style2_3 House_Style2_4
House_Style2_5/ selection = backward slentry=0.01 slstay=0.01 AIC VIF BIC MSE; 
output out=stepwise_out pred=yhat residual = resid ucl=ucl lcl=lcl cookd=cook  
covratio=cov dffits=dfits press=prss;
run;
/*=>Model from Backward method is more reliable with higher Rsquare*/

/*VALIDATION FRAMEWORK*/
/*Predict house price in 'test' dataset to check accuracy of model----*/
proc score data=testing score=stepwise_summary type=parms predict out=test_1;
   var Overall_Qual Year_Built Gr_Liv_Area Garage_Area Basement_Area Full_Bathroom Total_Bathroom
Age_sold Overall_Qual2 Bonus House_Style2_1 House_Style2_2 House_Style2_3 House_Style2_4
House_Style2_5;
run;

data test_1;
set test_1 (keep=SalePrice Model1);
if Model1 >= (SalePrice *0.9) and Model1 <= (SalePrice *1.1) then
                Prediction_Grade="Grade 1"; else Prediction_Grade="Grade 2" ;
run;

proc freq data=test_1;
table Prediction_Grade;
run; /*70% of predicted price on test dataset are within 10% error of actual price*/

