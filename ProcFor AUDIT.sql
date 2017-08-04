USE [PolarisDev]
GO
/****** Object:  StoredProcedure [opera].[sp_ivp_polaris_get_audit_details_opera]    Script Date: 06/11/2013 21:00:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [opera].[sp_ivp_polaris_get_audit_details_opera] 
(
@ReportID INT,
@FundID INT,
@AsOfDate DATETIME,
@SectionId INT,
@SubSectionId INT
)
/****** 
StoredProcedure [opera].[sp_ivp_polaris_get_audit_details_opera]  07 June 2013 Roopali
To update data to respective loading tables for various tabs AND archive previous entries based ON received xml			

exec [opera].[sp_ivp_polaris_get_audit_details_opera]  33, 21, '2012-08-20', 2, 14

******/
     
AS    
BEGIN
SET NOCOUNT ON; 

CREATE TABLE #tempOperaAudit
(
column_referred VARCHAR(200),
grade_1 VARCHAR(500),
grade_2 VARCHAR(500),
grade_3 VARCHAR(500),
sub_section_name VARCHAR(500)
)
INSERT INTO #tempOperaAudit
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
CREATE TABLE #tempOperaAuditValueDisplay
(
id INT IDENTITY(1,1),
sub_section_name VARCHAR(500),
grade_1 VARCHAR(500),
grade_2 VARCHAR(500),
grade_3 VARCHAR(500),
Attribute VARCHAR(500),
New_Value VARCHAR(1000),
Old_Value VARCHAR(1000),
Knowledge_Date DATETIME,
Modified_By VARCHAR(200),
is_user_edited  BIT,
[Action] VARCHAR(50),
is_archive BIT,
created_on DATETIME,
modified_on DATETIME
)

IF (@SectionId IN(2,3,4,5,6,7,12))
BEGIN
INSERT INTO  #tempOperaAuditValueDisplay
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'netted_long' THEN 'Netted Long'
WHEN 'netted_short' THEN 'Netted Short'
WHEN 'long_positions' THEN 'Long Positions'
WHEN 'short_positions' THEN 'Short Positions'
END AS 'Attribute', 
CASE (ins.column_referred) 
WHEN 'netted_long' THEN CAST(nv.netted_long AS VARCHAR(1000))
WHEN 'netted_short' THEN CAST(nv.netted_long AS VARCHAR(1000))
WHEN 'long_positions' THEN CAST(nv.long_positions AS VARCHAR(1000))
WHEN 'short_positions' THEN CAST(nv.short_positions AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,
CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action',0 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_netted_values nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.is_active = 1 AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('netted_long','netted_short','long_positions','short_positions') 
UNION ALL 
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'netted_long' THEN 'Netted Long'
WHEN 'netted_short' THEN 'Netted Short'
WHEN 'long_positions' THEN 'Long Positions'
WHEN 'short_positions' THEN 'Short Positions'
END AS 'Attribute', 
CASE (ins.column_referred) 
WHEN 'netted_long' THEN CAST(nv.netted_long AS VARCHAR(1000))
WHEN 'netted_short' THEN CAST(nv.netted_long AS VARCHAR(1000))
WHEN 'long_positions' THEN CAST(nv.long_positions AS VARCHAR(1000))
WHEN 'short_positions' THEN CAST(nv.short_positions AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,
CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 1 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_netted_values_archive nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('netted_long','netted_short','long_positions','short_positions') 
UNION ALL
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'non_netted_long' THEN 'Non Netted Long'
WHEN 'non_netted_short' THEN 'Non Netted Short'
WHEN 'values' THEN 'Values'
END AS 'Attribute', 
CASE (ins.column_referred) 
WHEN 'non_netted_long' THEN CAST(nv.non_netted_long AS VARCHAR(1000))
WHEN 'non_netted_short' THEN CAST(nv.non_netted_short AS VARCHAR(1000))
WHEN 'values' THEN CAST(nv.[values] AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,
CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 0 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_non_netted_values nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.is_active = 1 AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('non_netted_long','non_netted_short','values') 
UNION ALL 
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'non_netted_long' THEN 'Non Netted Long'
WHEN 'non_netted_short' THEN 'Non Netted Short'
WHEN 'values' THEN 'Values'
END AS 'Attribute', 
CASE (ins.column_referred) 
WHEN 'non_netted_long' THEN CAST(nv.non_netted_long AS VARCHAR(1000))
WHEN 'non_netted_short' THEN CAST(nv.non_netted_short AS VARCHAR(1000))
WHEN 'values' THEN CAST(nv.[values] AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 1 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_non_netted_values_archive nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('non_netted_long','non_netted_short','values') 
ORDER BY sub_section_name,grade_1,grade_2,grade_3,attribute,knowledge_date desc
END

IF (@SectionId =1)
BEGIN
INSERT INTO  #tempOperaAuditValueDisplay
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
WHEN 'dv_fidv' THEN CAST(nv.data_value AS VARCHAR(1000))
WHEN 'dvt_fidv' THEN  CAST(nv.data_value_text AS VARCHAR(1000))
WHEN 'Month_fidv' THEN  CAST(nv.[Month] AS VARCHAR(1000))
WHEN 'QTD_fidv' THEN  CAST(nv.QTD AS VARCHAR(1000))
WHEN 'YTD_fidv' THEN  CAST(nv.YTD AS VARCHAR(1000))
WHEN 'ITD_fidv' THEN  CAST(nv.ITD AS VARCHAR(1000))
WHEN 'perc_fidv' THEN  CAST(nv.percentage AS VARCHAR(1000))
WHEN 'amt_fidv' THEN  CAST(nv.amount AS VARCHAR(1000))
WHEN 'withPen_fidv' THEN  CAST(nv.with_penality AS VARCHAR(1000))
WHEN 'withoutPen_fidv' THEN  CAST(nv.without_penality AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 0 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_fund_investor_details nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.is_active = 1 AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('dv_fidv' , 'dvt_fidv' , 'Month_fidv' , 'QTD_fidv' , 'YTD_fidv' , 'ITD_fidv' , 'perc_fidv' , 'amt_fidv' , 'withPen_fidv' ,'withoutPen_fidv')  
UNION ALL 
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
WHEN 'dv_fidv' THEN CAST(nv.data_value AS VARCHAR(1000))
WHEN 'dvt_fidv' THEN  CAST(nv.data_value_text AS VARCHAR(1000))
WHEN 'Month_fidv' THEN  CAST(nv.[Month] AS VARCHAR(1000))
WHEN 'QTD_fidv' THEN  CAST(nv.QTD AS VARCHAR(1000))
WHEN 'YTD_fidv' THEN  CAST(nv.YTD AS VARCHAR(1000))
WHEN 'ITD_fidv' THEN  CAST(nv.ITD AS VARCHAR(1000))
WHEN 'perc_fidv' THEN  CAST(nv.percentage AS VARCHAR(1000))
WHEN 'amt_fidv' THEN  CAST(nv.amount AS VARCHAR(1000))
WHEN 'withPen_fidv' THEN  CAST(nv.with_penality AS VARCHAR(1000))
WHEN 'withoutPen_fidv' THEN  CAST(nv.without_penality AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 1 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_fund_investor_details_archive nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('dv_fidv' , 'dvt_fidv' , 'Month_fidv' , 'QTD_fidv' , 'YTD_fidv' , 'ITD_fidv' , 'perc_fidv' , 'amt_fidv' , 'withPen_fidv' ,'withoutPen_fidv')  
ORDER BY sub_section_name,grade_1,grade_2,grade_3,attribute,knowledge_date desc
END

IF (@SectionId =8)
BEGIN
INSERT INTO  #tempOperaAuditValueDisplay
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'exp_rsk' THEN 'Exposure Percentage'
WHEN 'vr_rsk' THEN 'Var Percentage'
WHEN 'cvr_rsk' THEN 'CVar Percentage'
WHEN 'dv_rsk' THEN 'Data Value'
WHEN 'dvt_rsk' THEN 'Data Text'
END AS 'Attribute', 
CASE (ins.column_referred) 
WHEN 'exp_rsk' THEN CAST(nv.exposure_per AS VARCHAR(1000))
WHEN 'vr_rsk' THEN CAST(nv.var_per AS VARCHAR(1000))
WHEN 'cvr_rsk' THEN CAST(nv.cvar_per AS VARCHAR(1000))
WHEN 'dv_rsk' THEN CAST(nv.data_value AS VARCHAR(1000))
WHEN 'dvt_rsk' THEN CAST(nv.data_value_text AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 0 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_value_at_risk nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.is_active = 1 AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('exp_rsk','vr_rsk','cvr_rsk','dv_rsk','dvt_rsk') 
UNION ALL 
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'exp_rsk' THEN 'Exposure Percentage'
WHEN 'vr_rsk' THEN 'Var Percentage'
WHEN 'cvr_rsk' THEN 'CVar Percentage'
WHEN 'dv_rsk' THEN 'Data Value'
WHEN 'dvt_rsk' THEN 'Data Text'
END AS 'Attribute', 
CASE (ins.column_referred) 
WHEN 'exp_rsk' THEN CAST(nv.exposure_per AS VARCHAR(1000))
WHEN 'vr_rsk' THEN CAST(nv.var_per AS VARCHAR(1000))
WHEN 'cvr_rsk' THEN CAST(nv.cvar_per AS VARCHAR(1000))
WHEN 'dv_rsk' THEN CAST(nv.data_value AS VARCHAR(1000))
WHEN 'dvt_rsk' THEN CAST(nv.data_value_text AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 1 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_value_at_risk_archive nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('exp_rsk','vr_rsk','cvr_rsk','dv_rsk','dvt_rsk') 
ORDER BY sub_section_name,grade_1,grade_2,grade_3,attribute,knowledge_date desc
END

IF (@SectionId =9)
BEGIN
INSERT INTO  #tempOperaAuditValueDisplay
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
WHEN 'bet_sns' THEN CAST(nv.beta AS VARCHAR(1000))
WHEN 'del_sns' THEN CAST(nv.delta AS VARCHAR(1000))
WHEN 'gam_sns' THEN CAST(nv.gamma AS VARCHAR(1000))
WHEN 'veg_sns' THEN CAST(nv.vega AS VARCHAR(1000))
WHEN 'thet_sns' THEN CAST(nv.theta AS VARCHAR(1000))
WHEN 'cs01_sns' THEN CAST(nv.cs01 AS VARCHAR(1000))
WHEN 'dv01_sns' THEN CAST(nv.dv01 AS VARCHAR(1000))
WHEN 'dv_sns' THEN CAST(nv.dataValue AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 0 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_fund_sensitivity_details nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.is_active = 1 AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('bet_sns','del_sns','gam_sns','veg_sns','thet_sns','cs01_sns','dv01_sns','dv_sns') 
UNION ALL 
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
WHEN 'bet_sns' THEN CAST(nv.beta AS VARCHAR(1000))
WHEN 'del_sns' THEN CAST(nv.delta AS VARCHAR(1000))
WHEN 'gam_sns' THEN CAST(nv.gamma AS VARCHAR(1000))
WHEN 'veg_sns' THEN CAST(nv.vega AS VARCHAR(1000))
WHEN 'thet_sns' THEN CAST(nv.theta AS VARCHAR(1000))
WHEN 'cs01_sns' THEN CAST(nv.cs01 AS VARCHAR(1000))
WHEN 'dv01_sns' THEN CAST(nv.dv01 AS VARCHAR(1000))
WHEN 'dv_sns' THEN CAST(nv.dataValue AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 1 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_fund_sensitivity_details_archive nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('bet_sns','del_sns','gam_sns','veg_sns','thet_sns','cs01_sns','dv01_sns','dv_sns') 
ORDER BY sub_section_name,grade_1,grade_2,grade_3,attribute,knowledge_date desc
END

IF (@SectionId =10)
BEGIN
INSERT INTO  #tempOperaAuditValueDisplay
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'pr_st' THEN 'Portfolio Return'
WHEN 'plng_st' THEN 'Long Percentage'
WHEN 'psht_st' THEN 'Short Percentage'
WHEN 'dt_st' THEN 'Start Date'
END AS 'Attribute', 
CASE (ins.column_referred) 
WHEN 'pr_st' THEN CAST(nv.portfolio_return AS VARCHAR(1000))
WHEN 'plng_st' THEN CAST(nv.percentage_long AS VARCHAR(1000))
WHEN 'psht_st' THEN CAST(nv.percentage_short AS VARCHAR(1000))
WHEN 'dt_st' THEN CAST(nv.[start_date] AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 0 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_fund_stress_test nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.is_active = 1 AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('pr_st','plng_st','psht_st','dt_st') 
UNION ALL 
SELECT ins.sub_section_name, ins.grade_1,ins.grade_2,ins.grade_3,
CASE (ins.column_referred) 
WHEN 'pr_st' THEN 'Portfolio Return'
WHEN 'plng_st' THEN 'Long Percentage'
WHEN 'psht_st' THEN 'Short Percentage'
WHEN 'dt_st' THEN 'Start Date'
END AS 'Attribute', 
CASE (ins.column_referred) 
WHEN 'pr_st' THEN CAST(nv.portfolio_return AS VARCHAR(1000))
WHEN 'plng_st' THEN CAST(nv.percentage_long AS VARCHAR(1000))
WHEN 'psht_st' THEN CAST(nv.percentage_short AS VARCHAR(1000))
WHEN 'dt_st' THEN CAST(nv.[start_date] AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 1 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_fund_stress_test_archive nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('pr_st','plng_st','psht_st','dt_st') 
ORDER BY sub_section_name,grade_1,grade_2,grade_3,attribute,knowledge_date desc
END

IF (@SectionId =11)
BEGIN
INSERT INTO  #tempOperaAuditValueDisplay
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
WHEN 'cnt_cp' THEN CAST(nv.number_count AS VARCHAR(1000))
WHEN 'Eq_cp' THEN CAST(nv.Equity AS VARCHAR(1000))
WHEN 'LMV_cp' THEN CAST(nv.LMV AS VARCHAR(1000))
WHEN 'SMV_cp' THEN CAST(nv.SMV AS VARCHAR(1000))
WHEN 'Cash_cp' THEN CAST(nv.Cash AS VARCHAR(1000))
WHEN 'OTE_cp' THEN CAST(nv.OTE_MTM AS VARCHAR(1000))
WHEN 'Liq__cp' THEN CAST(nv.Available_Liquidity AS VARCHAR(1000))
WHEN 'Mrg_cp' THEN CAST(nv.Required_Margin AS VARCHAR(1000))
WHEN 'elng_cp' THEN CAST(nv.Long_Exposure AS VARCHAR(1000))
WHEN 'esht_cp' THEN CAST(nv.Short_Exposure AS VARCHAR(1000))
WHEN 'dvt_cp' THEN CAST(nv.data_value_text AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 0 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_counterparty_details nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.is_active = 1 AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('cnt_cp' ,'Eq_cp','LMV_cp','SMV_cp','Cash_cp','OTE_cp','Liq__cp','Mrg_cp','elng_cp','esht_cp','dvt_cp') 
UNION ALL 
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
WHEN 'cnt_cp' THEN CAST(nv.number_count AS VARCHAR(1000))
WHEN 'Eq_cp' THEN CAST(nv.Equity AS VARCHAR(1000))
WHEN 'LMV_cp' THEN CAST(nv.LMV AS VARCHAR(1000))
WHEN 'SMV_cp' THEN CAST(nv.SMV AS VARCHAR(1000))
WHEN 'Cash_cp' THEN CAST(nv.Cash AS VARCHAR(1000))
WHEN 'OTE_cp' THEN CAST(nv.OTE_MTM AS VARCHAR(1000))
WHEN 'Liq__cp' THEN CAST(nv.Available_Liquidity AS VARCHAR(1000))
WHEN 'Mrg_cp' THEN CAST(nv.Required_Margin AS VARCHAR(1000))
WHEN 'elng_cp' THEN CAST(nv.Long_Exposure AS VARCHAR(1000))
WHEN 'esht_cp' THEN CAST(nv.Short_Exposure AS VARCHAR(1000))
WHEN 'dvt_cp' THEN CAST(nv.data_value_text AS VARCHAR(1000))
END AS 'New_Value',
NULL AS 'Old_Value',
nv.knowledge_date, nv.modified_by, nv.is_user_edited,CASE nv.is_user_edited
WHEN 1 THEN 'USER'
ELSE 'SYSTEM'
END AS 'Action', 
 1 AS 'is_archive', nv.created_on,nv.modified_on
FROM opera.ivp_polaris_report_counterparty_details_archive nv WITH (NOLOCK)
JOIN #tempOperaAudit ins WITH (NOLOCK)
ON ((nv.grade_1 = ins.grade_1) OR (nv.grade_1 IS NULL AND ins.grade_1 IS NULL))
AND ((nv.grade_2 = ins.grade_2) OR (nv.grade_2 IS NULL AND ins.grade_2 IS NULL))
AND ((nv.grade_3 = ins.grade_3) OR (nv.grade_3 IS NULL AND ins.grade_3 IS NULL))
AND nv.fund_id = @FundID AND nv.reporting_date = @AsOfDate AND nv.report_id = @ReportID
AND nv.section_id = @SectionId AND nv.sub_section_id = @SubSectionId
WHERE ins.column_referred IN ('cnt_cp' ,'Eq_cp','LMV_cp','SMV_cp','Cash_cp','OTE_cp','Liq__cp','Mrg_cp','elng_cp','esht_cp','dvt_cp') 
ORDER BY sub_section_name,grade_1,grade_2,grade_3,attribute,knowledge_date desc
END

UPDATE  rt SET Old_Value =  tr.New_Value 
FROM #tempOperaAuditValueDisplay rt  WITH (NOLOCK)
JOIN #tempOperaAuditValueDisplay tr WITH (NOLOCK) ON tr.Attribute =  rt.Attribute 
and ((rt.grade_1 = tr.grade_1) OR (rt.grade_1 IS NULL AND tr.grade_1 IS NULL))
AND ((rt.grade_2 = tr.grade_2) OR (rt.grade_2 IS NULL AND tr.grade_2 IS NULL))
AND ((rt.grade_3 = tr.grade_3) OR (rt.grade_3 IS NULL AND tr.grade_3 IS NULL))
WHERE tr.id = CAST((CAST(rt.id AS INT) + 1) AS INT)

SELECT id,
(
CAST(ISNULL(grade_1,'') AS VARCHAR(200))+
CASE WHEN grade_2 IS NULL THEN '' ELSE  ' >> ' END +
CAST(ISNULL(grade_2,'') AS VARCHAR(200))+
CASE WHEN grade_3 IS NULL THEN '' ELSE  ' >> ' END +
CAST(ISNULL(grade_3,'') AS VARCHAR(200))+
CASE WHEN (Attribute='Data Text' OR Attribute='Data Value') THEN '' ELSE ' >> ' END +
CASE WHEN (Attribute='Data Text' OR Attribute='Data Value') THEN '' ELSE Attribute END
+ CASE WHEN grade_1 IS NULL AND grade_2 IS NULL AND grade_3 IS NULL AND (Attribute='Data Text' OR Attribute='Data Value') THEN sub_section_name ELSE ''  END
)  AS 'Attribute'
,Old_Value,New_Value,Modified_By,Knowledge_Date,is_archive FROM  
#tempOperaAuditValueDisplay WITH (NOLOCK) 
WHERE ((New_Value <> Old_Value) OR (New_Value IS NOT NULL AND Old_Value IS NULL) OR  (New_Value IS  NULL AND Old_Value IS NOT NULL))
AND created_on<>modified_on
  
DROP TABLE #tempOperaAudit
DROP TABLE #tempOperaAuditValueDisplay
END





