USE [PolarisDev]
GO
/****** Object:  StoredProcedure [opera].[sp_ivp_polaris_get_audit_details_opera]    Script Date: 06/11/2013 21:00:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [opera].[sp_ivp_polaris_get_comparison_details_opera] 
(
@ReportID INT,
@FundID INT,
@AsOfDate DATETIME,
@SectionId INT,
@SubSectionId INT
)
/****** 
StoredProcedure [opera].[sp_ivp_polaris_get_comparison_details_opera]  14 June 2013 Roopali
To update data to respective loading tables for various tabs AND archive previous entries based ON received xml			

exec [opera].[sp_ivp_polaris_get_comparison_details_opera] 80,29,'2012-08-20',1,3
exec [opera].[sp_ivp_polaris_get_comparison_details_opera] 48,33,'2012-08-20' ,4,33

******/
     
AS    
BEGIN
SET NOCOUNT ON; 

CREATE TABLE #tempOperaComparisonDetails
(
column_referred VARCHAR(200),
grade_1 VARCHAR(500),
grade_2 VARCHAR(500),
grade_3 VARCHAR(500),
sub_section_name VARCHAR(500)
)

INSERT INTO #tempOperaComparisonDetails
SELECT sd.sub_section_data_inner_xml, NULL, NULL, NULL , ss.sub_section_name
FROM opera.ivp_polaris_cfg_sub_section_data sd  WITH (NOLOCK)
JOIN opera.ivp_polaris_cfg_sub_section ss  WITH (NOLOCK) ON ss.id = sd.sub_section_id
WHERE ss.id = @SubSectionId AND ss.is_active =1 AND sd.is_active=1
UNION ALL
SELECT g1d.grade_one_data_inner_xml, g1.grade_one_title, NULL,NULL , ss.sub_section_name
FROM opera.ivp_polaris_cfg_grade_one_data g1d  WITH (NOLOCK)
JOIN opera.ivp_polaris_cfg_grade_one g1  WITH (NOLOCK) ON g1.id = g1d.grade_one_id
JOIN opera.ivp_polaris_cfg_sub_section ss  WITH (NOLOCK) on ss.id = g1.sub_section_id
WHERE ss.id = @SubSectionId AND ss.is_active =1 AND g1.is_active = 1 AND g1d.is_active = 1
UNION ALL
SELECT g2d.grade_two_data_inner_xml, g1.grade_one_title, g2.grade_two_title, NULL , ss.sub_section_name
FROM opera.ivp_polaris_cfg_grade_two_data g2d  WITH (NOLOCK)
JOIN opera.ivp_polaris_cfg_grade_two g2  WITH (NOLOCK) ON g2.id = g2d.grade_two_id
JOIN opera.ivp_polaris_cfg_grade_one g1  WITH (NOLOCK) ON g1.id = g2.grade_one_id
JOIN opera.ivp_polaris_cfg_sub_section ss  WITH (NOLOCK) on ss.id = g1.sub_section_id
WHERE ss.id = @SubSectionId AND ss.is_active =1 AND g1.is_active = 1 AND g2.is_active = 1 AND g2d.is_active = 1
UNION ALL
SELECT g3d.grade_three_data_inner_xml, g1.grade_one_title, g2.grade_two_title, g3.grade_three_title , ss.sub_section_name
FROM opera.ivp_polaris_cfg_grade_three_data g3d  WITH (NOLOCK)
JOIN opera.ivp_polaris_cfg_grade_three g3  WITH (NOLOCK) ON g3.id = g3d.grade_three_id
JOIN opera.ivp_polaris_cfg_grade_two g2  WITH (NOLOCK) ON g2.id = g3.grade_two_id
JOIN opera.ivp_polaris_cfg_grade_one g1  WITH (NOLOCK) ON g1.id = g2.grade_one_id
JOIN opera.ivp_polaris_cfg_sub_section ss  WITH (NOLOCK) on ss.id = g1.sub_section_id
WHERE ss.id = @SubSectionId AND ss.is_active =1 AND g1.is_active = 1 AND g2.is_active = 1 AND g3.is_active = 1 AND g3d.is_active = 1 

CREATE TABLE #tempOperaComparisonDisplay
(
id INT IDENTITY(1,1),
sub_section_name VARCHAR(500),
grade_1 VARCHAR(500),
grade_2 VARCHAR(500),
grade_3 VARCHAR(500),
Attribute VARCHAR(500),
New_Value VARCHAR(1000),
Old_Value VARCHAR(1000)
)

IF (@SectionId IN(2,3,4,5,6,7,12))
BEGIN
CREATE TABLE #tempComparisonNetted
(
grade_1 VARCHAR(500),
grade_2 VARCHAR(500),
grade_3 VARCHAR(500),
[level] INT,
New_Non_Netted_Long NUMERIC(36, 4),
Old_Non_Netted_Long NUMERIC(36, 4),
New_Non_Netted_Short NUMERIC(36, 4),
Old_Non_Netted_Short NUMERIC(36, 4),
New_Values NUMERIC(36, 4),
Old_Values NUMERIC(36, 4),
New_Netted_Long NUMERIC(36, 4),
Old_Netted_Long NUMERIC(36, 4),
New_Netted_Short NUMERIC(36, 4),
Old_Netted_Short NUMERIC(36, 4),
New_Short_Positions INT,
Old_Short_Positions INT,
New_Long_Positions INT,
Old_Long_Positions INT
)
INSERT
INTO  #tempComparisonNetted
EXEC  opera.sp_ivp_polaris_compare_reports @ReportID,@FundID,@AsOfDate,@SectionId,@SubSectionId
INSERT INTO #tempOperaComparisonDisplay
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'netted_long' THEN 'Netted Long'
WHEN 'netted_short' THEN 'Netted Short'
WHEN 'long_positions' THEN 'Long Positions'
WHEN 'short_positions' THEN 'Short Positions'
WHEN 'non_netted_long' THEN 'Non Netted Long'
WHEN 'non_netted_short' THEN 'Non Netted Short'
WHEN 'values' THEN 'Values'
END AS 'Attribute',
CASE (ins.column_referred) 
WHEN 'netted_long' THEN CAST(tn.New_Netted_Long AS VARCHAR(1000))
WHEN 'netted_short' THEN CAST(tn.New_Netted_Short AS VARCHAR(1000))
WHEN 'long_positions' THEN CAST(tn.New_Long_Positions AS VARCHAR(1000))
WHEN 'short_positions' THEN CAST(tn.New_Short_Positions AS VARCHAR(1000))
WHEN 'non_netted_long' THEN CAST(tn.New_Non_Netted_Long AS VARCHAR(1000))
WHEN 'non_netted_short' THEN CAST(tn.New_Non_Netted_Short AS VARCHAR(1000))
WHEN 'values' THEN CAST(tn.New_values AS VARCHAR(1000))
END AS 'New_Value',
CASE (ins.column_referred) 
WHEN 'netted_long' THEN CAST(tn.Old_Netted_Long AS VARCHAR(1000))
WHEN 'netted_short' THEN CAST(tn.Old_Netted_Short AS VARCHAR(1000))
WHEN 'long_positions' THEN CAST(tn.Old_Long_Positions AS VARCHAR(1000))
WHEN 'short_positions' THEN CAST(tn.Old_Short_Positions AS VARCHAR(1000))
WHEN 'non_netted_long' THEN CAST(tn.Old_Non_Netted_Long AS VARCHAR(1000))
WHEN 'non_netted_short' THEN CAST(tn.Old_Non_Netted_Short AS VARCHAR(1000))
WHEN 'values' THEN CAST(tn.Old_values AS VARCHAR(1000))
END AS 'Old_Value'
FROM #tempComparisonNetted tn WITH (NOLOCK) 
JOIN #tempOperaComparisonDetails ins WITH (NOLOCK) 
ON ((tn.grade_1 = ins.grade_1) OR (tn.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((tn.grade_2 = ins.grade_2) OR (tn.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((tn.grade_3 = ins.grade_3) OR (tn.grade_3 IS NULL AND ins.grade_3 IS NULL))
DROP TABLE #tempComparisonNetted
END

IF (@SectionId =1)
BEGIN
CREATE TABLE #tempComparisonFidv
(
id INT,
grade_1 VARCHAR(500),
grade_2 VARCHAR(500),
grade_3 VARCHAR(500),
New_Value NUMERIC(36, 4),
Old_Value NUMERIC(36, 4),
New_Text VARCHAR(200),
Old_Text VARCHAR(200),
New_Month  NUMERIC(36, 4),
Old_Month  NUMERIC(36, 4),
New_QTD  NUMERIC(36, 4),
Old_QTD  NUMERIC(36, 4),
New_YTD  NUMERIC(36, 4),
Old_YTD  NUMERIC(36, 4),
New_ITD  NUMERIC(36, 4),
Old_ITD  NUMERIC(36, 4),
New_Percentage  NUMERIC(36, 4),
Old_Percentage  NUMERIC(36, 4),
New_Amount  NUMERIC(36, 4),
Old_Amount  NUMERIC(36, 4),
New_With_Penalty  NUMERIC(36, 4),
Old_With_Penalty  NUMERIC(36, 4),
New_Without_Penalty  NUMERIC(36, 4),
Old_Without_Penalty  NUMERIC(36, 4)
)
INSERT
INTO  #tempComparisonFidv
EXEC  opera.sp_ivp_polaris_compare_reports @ReportID,@FundID,@AsOfDate,@SectionId,@SubSectionId
INSERT INTO #tempOperaComparisonDisplay
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'dv_fidv' THEN 'Data Value'
WHEN 'dvt_fidv' THEN 'Data Text'
WHEN 'Month_fidv' THEN 'Month'
WHEN 'QTD_fidv' THEN 'QTD'
WHEN 'YTD_fidv' THEN 'YTD'
WHEN 'ITD_fidv' THEN 'ITD'
WHEN 'perc_fidv' THEN 'Percentage'
WHEN 'amt_fidv' THEN 'Amount'
WHEN 'withPen_fidv' THEN 'With Penalty'
WHEN 'withoutPen_fidv' THEN 'Without Penalty'
END AS 'Attribute',
CASE (ins.column_referred) 
WHEN 'dv_fidv' THEN CAST(tn.New_Value AS VARCHAR(1000))
WHEN 'dvt_fidv' THEN  CAST(tn.New_Text AS VARCHAR(1000))
WHEN 'Month_fidv' THEN  CAST(tn.New_Month AS VARCHAR(1000))
WHEN 'QTD_fidv' THEN  CAST(tn.New_QTD AS VARCHAR(1000))
WHEN 'YTD_fidv' THEN  CAST(tn.New_YTD AS VARCHAR(1000))
WHEN 'ITD_fidv' THEN  CAST(tn.New_ITD AS VARCHAR(1000))
WHEN 'perc_fidv' THEN  CAST(tn.New_Percentage AS VARCHAR(1000))
WHEN 'amt_fidv' THEN  CAST(tn.New_Amount AS VARCHAR(1000))
WHEN 'withPen_fidv' THEN  CAST(tn.New_With_Penalty AS VARCHAR(1000))
WHEN 'withoutPen_fidv' THEN  CAST(tn.New_Without_Penalty AS VARCHAR(1000))
END AS 'New_Value',
CASE (ins.column_referred) 
WHEN 'dv_fidv' THEN CAST(tn.Old_Value AS VARCHAR(1000))
WHEN 'dvt_fidv' THEN  CAST(tn.Old_Text AS VARCHAR(1000))
WHEN 'Month_fidv' THEN  CAST(tn.Old_Month AS VARCHAR(1000))
WHEN 'QTD_fidv' THEN  CAST(tn.Old_QTD AS VARCHAR(1000))
WHEN 'YTD_fidv' THEN  CAST(tn.Old_YTD AS VARCHAR(1000))
WHEN 'ITD_fidv' THEN  CAST(tn.Old_ITD AS VARCHAR(1000))
WHEN 'perc_fidv' THEN  CAST(tn.Old_Percentage AS VARCHAR(1000))
WHEN 'amt_fidv' THEN  CAST(tn.Old_Amount AS VARCHAR(1000))
WHEN 'withPen_fidv' THEN  CAST(tn.Old_With_Penalty AS VARCHAR(1000))
WHEN 'withoutPen_fidv' THEN  CAST(tn.Old_Without_Penalty AS VARCHAR(1000))
END AS 'Old_Value'
FROM #tempComparisonFidv tn WITH (NOLOCK) 
JOIN #tempOperaComparisonDetails ins WITH (NOLOCK) 
ON ((tn.grade_1 = ins.grade_1) OR (tn.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((tn.grade_2 = ins.grade_2) OR (tn.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((tn.grade_3 = ins.grade_3) OR (tn.grade_3 IS NULL AND ins.grade_3 IS NULL))
DROP TABLE #tempComparisonFidv
END

IF (@SectionId =8)
BEGIN
CREATE TABLE #tempComparisonRsk
(
id INT,
grade_1 VARCHAR(500),
grade_2 VARCHAR(500),
grade_3 VARCHAR(500),
New_Exposure_Percentage NUMERIC(36, 4),
Old_Exposure_Percentage NUMERIC(36, 4),
New_Var_Percentage NUMERIC(36, 4),
Old_Var_Percentage NUMERIC(36, 4),
New_Cvar_Percentage NUMERIC(36, 4),
Old_Cvar_Percentage NUMERIC(36, 4),
New_Value NUMERIC(36, 4),
Old_Value NUMERIC(36, 4),
New_Text VARCHAR(200),
Old_Text VARCHAR(200)
)
INSERT
INTO  #tempComparisonRsk
EXEC  opera.sp_ivp_polaris_compare_reports @ReportID,@FundID,@AsOfDate,@SectionId,@SubSectionId
INSERT INTO #tempOperaComparisonDisplay
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'exp_rsk' THEN 'Exposure Percentage'
WHEN 'vr_rsk' THEN 'Var Percentage'
WHEN 'cvr_rsk' THEN 'CVar Percentage'
WHEN 'dv_rsk' THEN 'Data Value'
WHEN 'dvt_rsk' THEN 'Data Text'
END AS 'Attribute',
CASE (ins.column_referred) 
WHEN 'exp_rsk' THEN CAST(tn.New_Exposure_Percentage AS VARCHAR(1000))
WHEN 'vr_rsk' THEN CAST(tn.New_Var_Percentage AS VARCHAR(1000))
WHEN 'cvr_rsk' THEN CAST(tn.New_Cvar_Percentage AS VARCHAR(1000))
WHEN 'dv_rsk' THEN CAST(tn.New_Value AS VARCHAR(1000))
WHEN 'dvt_rsk' THEN CAST(tn.New_Text AS VARCHAR(1000))
END AS 'New_Value',
CASE (ins.column_referred) 
WHEN 'exp_rsk' THEN CAST(tn.Old_Exposure_Percentage AS VARCHAR(1000))
WHEN 'vr_rsk' THEN CAST(tn.Old_Var_Percentage AS VARCHAR(1000))
WHEN 'cvr_rsk' THEN CAST(tn.Old_Cvar_Percentage AS VARCHAR(1000))
WHEN 'dv_rsk' THEN CAST(tn.Old_Value AS VARCHAR(1000))
WHEN 'dvt_rsk' THEN CAST(tn.Old_Text AS VARCHAR(1000))
END AS 'Old_Value'
FROM #tempComparisonRsk tn WITH (NOLOCK) 
JOIN #tempOperaComparisonDetails ins WITH (NOLOCK) 
ON ((tn.grade_1 = ins.grade_1) OR (tn.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((tn.grade_2 = ins.grade_2) OR (tn.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((tn.grade_3 = ins.grade_3) OR (tn.grade_3 IS NULL AND ins.grade_3 IS NULL))
DROP TABLE #tempComparisonRsk
END

IF (@SectionId =9)
BEGIN
CREATE TABLE #tempComparisonSns
(
id INT,
grade_1 VARCHAR(500),
grade_2 VARCHAR(500),
grade_3 VARCHAR(500),
New_Gamma NUMERIC(36, 4),
Old_Gamma NUMERIC(36, 4),
New_Delta NUMERIC(36, 4),
Old_Delta NUMERIC(36, 4),
New_Vega NUMERIC(36, 4),
Old_Vega NUMERIC(36, 4),
New_Theta NUMERIC(36, 4),
Old_Theta NUMERIC(36, 4),
New_Beta NUMERIC(36, 4),
Old_Beta NUMERIC(36, 4),
New_CS01 NUMERIC(36, 4),
Old_CS01 NUMERIC(36, 4),
New_DV01 NUMERIC(36, 4),
Old_DV01 NUMERIC(36, 4),
New_Value NUMERIC(36, 4),
Old_Value NUMERIC(36, 4)
)
INSERT
INTO  #tempComparisonSns
EXEC  opera.sp_ivp_polaris_compare_reports @ReportID,@FundID,@AsOfDate,@SectionId,@SubSectionId
INSERT INTO #tempOperaComparisonDisplay
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'bet_sns' THEN 'Beta'
WHEN 'del_sns' THEN 'Delta'
WHEN 'gam_sns' THEN 'Gamma'
WHEN 'veg_sns' THEN 'Vega'
WHEN 'thet_sns' THEN 'Theta'
WHEN 'cs01_sns' THEN 'CS01'
WHEN 'dv01_sns' THEN 'DV01'
WHEN 'dv_sns' THEN 'Data Value'
END AS 'Attribute',
CASE (ins.column_referred) 
WHEN 'bet_sns' THEN CAST(tn.New_beta AS VARCHAR(1000))
WHEN 'del_sns' THEN CAST(tn.New_delta AS VARCHAR(1000))
WHEN 'gam_sns' THEN CAST(tn.New_gamma AS VARCHAR(1000))
WHEN 'veg_sns' THEN CAST(tn.New_vega AS VARCHAR(1000))
WHEN 'thet_sns' THEN CAST(tn.New_theta AS VARCHAR(1000))
WHEN 'cs01_sns' THEN CAST(tn.New_cs01 AS VARCHAR(1000))
WHEN 'dv01_sns' THEN CAST(tn.New_dv01 AS VARCHAR(1000))
WHEN 'dv_sns' THEN CAST(tn.New_Value AS VARCHAR(1000))
END AS 'New_Value',
CASE (ins.column_referred) 
WHEN 'bet_sns' THEN CAST(tn.Old_beta AS VARCHAR(1000))
WHEN 'del_sns' THEN CAST(tn.Old_delta AS VARCHAR(1000))
WHEN 'gam_sns' THEN CAST(tn.Old_gamma AS VARCHAR(1000))
WHEN 'veg_sns' THEN CAST(tn.Old_vega AS VARCHAR(1000))
WHEN 'thet_sns' THEN CAST(tn.Old_theta AS VARCHAR(1000))
WHEN 'cs01_sns' THEN CAST(tn.Old_cs01 AS VARCHAR(1000))
WHEN 'dv01_sns' THEN CAST(tn.Old_dv01 AS VARCHAR(1000))
WHEN 'dv_sns' THEN CAST(tn.Old_Value AS VARCHAR(1000))
END AS 'Old_Value'
FROM #tempComparisonSns tn WITH (NOLOCK) 
JOIN #tempOperaComparisonDetails ins WITH (NOLOCK) 
ON ((tn.grade_1 = ins.grade_1) OR (tn.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((tn.grade_2 = ins.grade_2) OR (tn.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((tn.grade_3 = ins.grade_3) OR (tn.grade_3 IS NULL AND ins.grade_3 IS NULL))
DROP TABLE #tempComparisonSns
END

IF (@SectionId =10)
BEGIN
CREATE TABLE #tempComparisonSt
(
id INT,
grade_1 VARCHAR(500),
grade_2 VARCHAR(500),
grade_3 VARCHAR(500),
New_Return NUMERIC(36, 4),
Old_Return NUMERIC(36, 4),
New_Long_Percentage NUMERIC(36, 4),
Old_Long_Percentage NUMERIC(36, 4),
New_Short_Percentage NUMERIC(36, 4),
Old_Short_Percentage NUMERIC(36, 4),
New_Start_Date DATETIME,
Old_Start_Date DATETIME
)
INSERT
INTO  #tempComparisonSt
EXEC  opera.sp_ivp_polaris_compare_reports @ReportID,@FundID,@AsOfDate,@SectionId,@SubSectionId
INSERT INTO #tempOperaComparisonDisplay
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'pr_st' THEN 'Portfolio Return'
WHEN 'plng_st' THEN 'Long Percentage'
WHEN 'psht_st' THEN 'Short Percentage'
WHEN 'dt_st' THEN 'Start Date'
END AS 'Attribute',
CASE (ins.column_referred) 
WHEN 'pr_st' THEN CAST(tn.New_Return AS VARCHAR(1000))
WHEN 'plng_st' THEN CAST(tn.New_Long_Percentage AS VARCHAR(1000))
WHEN 'psht_st' THEN CAST(tn.New_Short_Percentage AS VARCHAR(1000))
WHEN 'dt_st' THEN CAST(tn.New_Start_Date AS VARCHAR(1000))
END AS 'New_Value',
CASE (ins.column_referred) 
WHEN 'pr_st' THEN CAST(tn.Old_Return AS VARCHAR(1000))
WHEN 'plng_st' THEN CAST(tn.Old_Long_Percentage AS VARCHAR(1000))
WHEN 'psht_st' THEN CAST(tn.Old_Short_Percentage AS VARCHAR(1000))
WHEN 'dt_st' THEN CAST(tn.Old_Start_Date AS VARCHAR(1000))
END AS 'Old_Value'
FROM #tempComparisonSt tn WITH (NOLOCK) 
JOIN #tempOperaComparisonDetails ins WITH (NOLOCK) 
ON ((tn.grade_1 = ins.grade_1) OR (tn.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((tn.grade_2 = ins.grade_2) OR (tn.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((tn.grade_3 = ins.grade_3) OR (tn.grade_3 IS NULL AND ins.grade_3 IS NULL))
DROP TABLE #tempComparisonSt
END

IF (@SectionId =11)
BEGIN
CREATE TABLE #tempComparisonCp
(
id INT,
grade_1 VARCHAR(500),
grade_2 VARCHAR(500),
grade_3 VARCHAR(500),
New_Count NUMERIC(36, 4),
Old_Count NUMERIC(36, 4),
New_Equity NUMERIC(36, 4),
Old_Equity NUMERIC(36, 4),
New_LMV NUMERIC(36, 4),
Old_LMV NUMERIC(36, 4),
New_SMV NUMERIC(36, 4),
Old_SMV NUMERIC(36, 4),
New_Cash NUMERIC(36, 4),
Old_Cash NUMERIC(36, 4),
New_OTE NUMERIC(36, 4),
Old_OTE NUMERIC(36, 4),
New_Liquidity NUMERIC(36, 4),
Old_Liquidity NUMERIC(36, 4),
New_Margin NUMERIC(36, 4),
Old_Margin NUMERIC(36, 4),
New_Long_Exposure NUMERIC(36, 4),
Old_Long_Exposure NUMERIC(36, 4),
New_Short_Exposure NUMERIC(36, 4),
Old_Short_Exposure NUMERIC(36, 4),
New_Text VARCHAR(200),
Old_Text VARCHAR(200)
)
INSERT
INTO  #tempComparisonCp
EXEC  opera.sp_ivp_polaris_compare_reports @ReportID,@FundID,@AsOfDate,@SectionId,@SubSectionId
INSERT INTO #tempOperaComparisonDisplay
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'cnt_cp' THEN 'Number Of Counterparties'
WHEN 'Eq_cp' THEN 'Equity'
WHEN 'LMV_cp' THEN 'LMV'
WHEN 'SMV_cp' THEN 'SMV'
WHEN 'Cash_cp' THEN 'Cash'
WHEN 'OTE_cp' THEN 'OTE_MTM'
WHEN 'Liq__cp' THEN 'Available Liquidity'
WHEN 'Mrg_cp' THEN 'Required Margin'
WHEN 'elng_cp' THEN 'Long Exposure'
WHEN 'esht_cp' THEN 'Short Exposure'
WHEN 'dvt_cp' THEN 'Data Text'
END AS 'Attribute',
CASE (ins.column_referred) 
WHEN 'cnt_cp' THEN CAST(tn.New_Count AS VARCHAR(1000))
WHEN 'Eq_cp' THEN CAST(tn.New_Equity AS VARCHAR(1000))
WHEN 'LMV_cp' THEN CAST(tn.New_LMV AS VARCHAR(1000))
WHEN 'SMV_cp' THEN CAST(tn.New_SMV AS VARCHAR(1000))
WHEN 'Cash_cp' THEN CAST(tn.New_Cash AS VARCHAR(1000))
WHEN 'OTE_cp' THEN CAST(tn.New_OTE AS VARCHAR(1000))
WHEN 'Liq__cp' THEN CAST(tn.New_Liquidity AS VARCHAR(1000))
WHEN 'Mrg_cp' THEN CAST(tn.New_Margin AS VARCHAR(1000))
WHEN 'elng_cp' THEN CAST(tn.New_Long_Exposure AS VARCHAR(1000))
WHEN 'esht_cp' THEN CAST(tn.New_Short_Exposure AS VARCHAR(1000))
WHEN 'dvt_cp' THEN CAST(tn.New_text AS VARCHAR(1000))
END AS 'New_Value',
CASE (ins.column_referred) 
WHEN 'cnt_cp' THEN CAST(tn.Old_Count AS VARCHAR(1000))
WHEN 'Eq_cp' THEN CAST(tn.Old_Equity AS VARCHAR(1000))
WHEN 'LMV_cp' THEN CAST(tn.Old_LMV AS VARCHAR(1000))
WHEN 'SMV_cp' THEN CAST(tn.Old_SMV AS VARCHAR(1000))
WHEN 'Cash_cp' THEN CAST(tn.Old_Cash AS VARCHAR(1000))
WHEN 'OTE_cp' THEN CAST(tn.Old_OTE AS VARCHAR(1000))
WHEN 'Liq__cp' THEN CAST(tn.Old_Liquidity AS VARCHAR(1000))
WHEN 'Mrg_cp' THEN CAST(tn.Old_Margin AS VARCHAR(1000))
WHEN 'elng_cp' THEN CAST(tn.Old_Long_Exposure AS VARCHAR(1000))
WHEN 'esht_cp' THEN CAST(tn.Old_Short_Exposure AS VARCHAR(1000))
WHEN 'dvt_cp' THEN CAST(tn.Old_text AS VARCHAR(1000))
END AS 'Old_Value'
FROM #tempComparisonCp tn WITH (NOLOCK) 
JOIN #tempOperaComparisonDetails ins WITH (NOLOCK) 
ON ((tn.grade_1 = ins.grade_1) OR (tn.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((tn.grade_2 = ins.grade_2) OR (tn.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((tn.grade_3 = ins.grade_3) OR (tn.grade_3 IS NULL AND ins.grade_3 IS NULL))
DROP TABLE #tempComparisonCp
END

SELECT id,
(
CAST(ISNULL(grade_1,'') AS VARCHAR(200))+
CASE WHEN grade_2 IS NULL THEN '' ELSE  ' >> ' END +
CAST(ISNULL(grade_2,'') AS VARCHAR(200))+
CASE WHEN grade_3 IS NULL THEN '' ELSE  ' >> ' END +
CAST(ISNULL(grade_3,'') AS VARCHAR(200))+
CASE WHEN (Attribute='Data Text' OR Attribute='Data Value') THEN '' ELSE ' >> ' END +
CASE WHEN (Attribute='Data Text' OR Attribute='Data Value') THEN '' ELSE Attribute END
+ CASE WHEN grade_1 IS NULL AND grade_2 IS NULL AND grade_3 IS NULL AND (Attribute='Data Text' OR Attribute='Data Value') THEN sub_section_name ELSE '' END
)  AS 'Attribute'
,Old_Value,New_Value FROM  #tempOperaComparisonDisplay WITH (NOLOCK) 
WHERE ((New_Value <> Old_Value) OR (New_Value IS NOT NULL AND Old_Value IS NULL) OR  (New_Value IS  NULL AND Old_Value IS NOT NULL))
DROP TABLE #tempOperaComparisonDetails
DROP TABLE #tempOperaComparisonDisplay
END





