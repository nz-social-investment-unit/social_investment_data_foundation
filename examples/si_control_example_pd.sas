﻿/*********************************************************************************************************
TITLE: si_control_example_pd.sas

DESCRIPTION: File where you can specify arguments needed to build the social investment data foundation
Since this is an example of a control file all the arguments have been populated below.
Users will have to specify the arguments that they want for their data foundation in
sasprogs/si_control.sas

INPUT:
INPUT:
si_sandpit_libname     = the libname you use to access IDI_Sandpit ( eg: sand )
si_proj_schema         = your project schema name ( eg: DL-MAA2016-XX )
si_debug               = Only use for troubleshooting. This retains all the temporary datasets {True | False} 
si_pop_table_out       = Name of the table that you intend to create in si_get_cohort.sas (with the individual IDs 
						 and as-at dates)
si_id_col              = name of the ID column in the "&si_pop_table_out" table, most likely to be "snz_uid"
si_asat_date           = name of date column date in this table. (All data foundation variables are created with 
						 respect to this date)
si_period_duration     = Specify the time counting mechanism while creating variables. For example, if this value is
						 "Month", all duration/cost variables will be rolled up on a monthly basis before and after 
						 the as-at date. {Year | Quarter | Month | Week | <integer>}
si_num_periods_before  = number of periods before the as-at date for which variables are to be generated. For example,
						 if si_period_duration is "Month" and this parameter is "-5", then variables will be rolled up 
						 for each of the 5 months before the as-at date.
si_num_periods_after   = number of periods after the as-at date for which the variables will be rolled up. The usage
						 is similar to si_num_periods_before parameter.
si_amount_type         = Specify if the amount type is (L)ump sum, (D)aily or NA if there is no amount {L, D, NA}.
						 Use "L", since all SIAL tables use a Lumpsum cost.
si_sial_amount_col     = name of the column in SIAL tables that has the dollars in it {cost | revenue}. 
						 Use "cost" as all SIAL tables call this column as "cost".
si_price_index_type    = type of inflation adjustment to be performed on dollar amounts {CPI | PPI | QEX}
si_price_index_qtr     = Reference Quarter to which Inflation adjustment is to be done. {For example, 2016Q2 }
si_discount            = specify if discounting is to be done {True | False}
si_discount_rate       = specify discounting rate e.g. 3 means 3% (value is ignored if si_discount = False)
si_use_acc             = include ACC data in rollups {True | False} 
si_use_cor             = include Corrections data in rollups {True | False} 
si_use_hnz             = include Housing NZ data in rollups {True | False}   
si_use_ird             = include IRD data in rollups {True | False}
si_use_mix             = include MIX data in rollups {True | False}  
si_use_moe             = include MOE data in rollups {True | False} 
si_use_moh             = include MOH data in rollups {True | False} 
si_use_moj             = include MOJ data in rollups {True | False} 
si_use_msd             = include MSD data in rollups {True | False} 
si_use_pol             = include Police data in rollups {True | False} 
si_rollup_output_type  = type of rolled up table you would like{Long | Wide | Both}
						 "Long" would give tables with one row per individual per variable.
						 "Wide" gives rollup tables with one row per individual, and each variable as a separate column.
si_rollup_agg_cols     = rollup level - currently not implemented, rollup is harded coded at subject area level.
						 For advanced users, just use the data foundations macros directly if the aggregation grain of rollup 
						 is to be changed.
si_rollup_cost         = produce cost service metrics {True | False}
si_rollup_duration     = produce duration service metrics {True | False}
si_rollup_count        = produce count of events based on period duration. Each event will be counted in each period 
						 that the event spans.{True | False}
si_rollup_count_sdate  = produce count of events based on the start date of the event. Each event is counted only in the 
						 period that the start_date of the event falls in. {True | False}
si_rollup_dayssince    = produce days since the last event in the profile window and days since the first 
						 event in the forecast window  {True | False}
si_idi_clean_version   = IDI Clean release to use. e.g. IDI_CLEAN_20190420;

OUTPUT:
work.control_file = sas dataset specifying every variable needed to run the si data foundation
                    all of column names are also global macro variables that can be used throughout the code

AUTHOR: E Walsh

DATE: 12 May 2017

DEPENDENCIES: 


HISTORY: 
12 May 2017 EW v1
jun2019 - SIAL views now have to be stored in IDI_USERcode schema -PNH
Jul 2019 the sial name are not used anywhere. - reference is done using the project Schema
*********************************************************************************************************/

data work.control_file_long;
	attrib si_var_name  length=$32;
	attrib si_value     length=$30;
	input si_var_name $ si_value $;

	/* specify your variables after the comma do not put a space after the comma */
	/* do not leave spaces after variables specified */
	/* note that because this is an example the arguments have already been populated */;
	infile datalines dlm="," dsd missover;
	datalines;
si_sandpit_libname,sand
si_proj_schema,DL-MAA2016-15
si_debug,True
si_pop_table_out,SIDF_example_dataset
si_id_col,snz_uid
si_asat_date,as_at_date
si_num_periods_before,-4
si_num_periods_after,0
si_period_duration,Year
si_amount_type,L
si_sial_amount_col,cost
si_price_index_type,NA
si_price_index_qtr,NA
si_discount,False
si_discount_rate,3
si_use_acc,True
si_use_cor,True
si_use_hnz,True
si_use_ird,True
si_use_mix,True
si_use_moe,True
si_use_moh,True
si_use_moj,True
si_use_msd,True
si_use_pol,True
si_use_cyf,True
si_rollup_output_type,Wide
si_rollup_cost,False
si_rollup_duration,False
si_rollup_count,True
si_rollup_count_sdate,False
si_rollup_dayssince,False
si_idi_clean_version,IDI_Clean_20190420
;
run;

/* we did it in long form first so it is easier on the eye and you are less likely to put the wrong argument in */
/* the wrong macro variable */
/* tip table on its side so each column can be mapped to a macro variable */
proc transpose data= work.control_file_long
	out = work.control_file_wide (drop=_name_);
	id si_var_name;
	var si_value;
run;

/* make sure these variables are available to all macros */
%global 
	si_sandpit_libname    si_proj_schema 
	si_sial_libname
	si_debug
	si_id_col             si_asat_date     
	si_num_periods_before si_num_periods_after si_period_duration
	si_amount_type        si_sial_amount_col
	si_price_index_type   si_price_index_qtr 
	si_discount           si_discount_rate
	si_use_acc            si_use_cor           si_use_hnz     
    si_use_ird            si_use_mix
	si_use_moe            si_use_moh           si_use_msd 
	si_use_moj            si_use_pol si_use_cyf
	si_rollup_output_type
	si_rollup_cost        si_rollup_duration   si_rollup_count
	si_rollup_count_sdate si_rollup_dayssince si_idi_dsnname si_idi_clean_version;

data _null_;
	set work.control_file_wide;

	/* populate the global variables */
	call symput('si_sandpit_libname',left(trim(si_sandpit_libname)));
	call symput('si_proj_schema',left(trim(si_proj_schema)));
	call symput('si_debug',left(trim(si_debug)));
	call symput('si_pop_table_out',left(trim(si_pop_table_out)));
	call symput('si_id_col',left(trim(si_id_col)));
	call symput('si_asat_date',left(trim(si_asat_date)));
	call symput('si_num_periods_before',left(trim(si_num_periods_before)));
	call symput('si_num_periods_after',left(trim(si_num_periods_after)));
	call symput('si_period_duration',left(trim(si_period_duration)));
	call symput('si_amount_type',left(trim(si_amount_type)));
	call symput('si_sial_amount_col',left(trim(si_sial_amount_col)));
	call symput('si_price_index_type',left(trim(si_price_index_type)));
	call symput('si_price_index_qtr',left(trim(si_price_index_qtr)));
	call symput('si_discount',left(trim(si_discount)));
	call symput('si_discount_rate',left(trim(si_discount_rate)));
	call symput('si_use_acc',left(trim(si_use_acc)));
	call symput('si_use_cor',left(trim(si_use_cor)));
	call symput('si_use_hnz',left(trim(si_use_hnz)));
	call symput('si_use_ird',left(trim(si_use_ird)));
    call symput('si_use_mix',left(trim(si_use_mix)));
	call symput('si_use_moe',left(trim(si_use_moe)));
	call symput('si_use_moh',left(trim(si_use_moh)));
	call symput('si_use_moj',left(trim(si_use_moj)));
	call symput('si_use_msd',left(trim(si_use_msd)));
	call symput('si_use_pol',left(trim(si_use_pol)));
	call symput('si_use_cyf',left(trim(si_use_cyf)));
	call symput('si_rollup_output_type',left(trim(si_rollup_output_type)));
	call symput('si_rollup_cost',left(trim(si_rollup_cost)));
	call symput('si_rollup_duration',left(trim(si_rollup_duration)));
	call symput('si_rollup_count',left(trim(si_rollup_count)));
	call symput('si_rollup_count_sdate',left(trim(si_rollup_count_sdate)));
	call symput('si_rollup_dayssince',left(trim(si_rollup_dayssince)));
	call symput('si_idi_dsnname',cats(left(trim(si_idi_clean_version)),"_srvprd"));
	call symput('si_idi_clean_version',left(trim(si_idi_clean_version)));
	
run;

/* we no longer require the long version */
proc sql;
	drop table control_file_long;
quit;

/************************************************************************/
/* do not modify below here */

/* libname to write to db via implicit passthrough */
libname &si_sandpit_libname ODBC dsn= idi_sandpit_srvprd schema="&si_proj_schema" /*bulkload=yes PNH:Bulkload nolonger supported under SAS-GRID*/;


/* software information */
%global si_version si_license;
%let si_version = 1.0.0;
%let si_license = GNU GPLv3;
%global si_bigdate;

data _null_;
	call symput('si_bigdate', "31Dec9999"D);
run;

%put ********************************************************************;
%put --------------------------------------------------------------------;
%put ----------------------SI Data Foundation----------------------------;
%put ............si_version: &si_version;
%put ............si_license: &si_license;
%put ............si_runtime: %sysfunc(datetime(),datetime20.);

/* general info */
%put --------------------------------------------------------------------;
%put -------------si_control: General info-------------------------------;
%put ....si_sandpit_libname: &si_sandpit_libname;
%put ....si_sial_libname: &si_sial_libname;
%put ........si_proj_schema: &si_proj_schema;
%put ..............si_debug: &si_debug;
%put ..............si_idi_dsnname: &si_idi_dsnname;
%put ..............si_idi_clean_version: &si_idi_clean_version;


/* population cohort info */
%put ---------------------------------------------------------------------;
%put ------------si_control: Population cohort parameters-----------------;
%put ......si_pop_table_out: &si_pop_table_out;
%put .............si_id_col: &si_id_col;
%put ..........si_asat_date: &si_asat_date;

/* windowing parameters */
%put ----------------------------------------------------------------------;
%put ------------si_control: Windowing parameters--------------------------;
%put .si_num_periods_before: &si_num_periods_before;
%put ..si_num_periods_after: &si_num_periods_after;
%put ....si_period_duration: &si_period_duration;
%put ----------------------------------------------------------------------;

/* cost related parameters */
%put ---------------------------------------------------------------------;
%put ------------si_control: Cost Related Parameters----------------------;
%put ........si_amount_type: &si_amount_type;
%put ....si_sial_amount_col: &si_sial_amount_col;
%put ...si_price_index_type: &si_price_index_type;
%put ....si_price_index_qtr: &si_price_index_qtr;
%put ...........si_discount: &si_discount;
%put ......si_discount_rate: &si_discount_rate;

/* agency data use flags */
%put ----------------------------------------------------------------------;
%put ------------si_control: Agency data use flags-------------------------;
%put ............si_use_acc: &si_use_acc;
%put ............si_use_cor: &si_use_cor;
%put ............si_use_hnz: &si_use_hnz;
%put ............si_use_ird: &si_use_ird;
%put ............si_use_mix: &si_use_mix;
%put ............si_use_moe: &si_use_moe;
%put ............si_use_moh: &si_use_moh;
%put ............si_use_moj: &si_use_moj;
%put ............si_use_msd: &si_use_msd;
%put ............si_use_pol: &si_use_pol;

/* rollup flags */
%put ----------------------------------------------------------------------;
%put ------------si_control: Rollup flags ---------------------------------;
%put ........si_rollup_cost: &si_rollup_cost;
%put ....si_rollup_duration: &si_rollup_duration;
%put .......si_rollup_count: &si_rollup_count;
%put .si_rollup_count_sdate: &si_rollup_count_sdate;
%put ...si_rollup_dayssince: &si_rollup_dayssince;
%put ********************************************************************;