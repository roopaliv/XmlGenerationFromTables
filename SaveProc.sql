USE [PolarisDev]
GO
/****** Object:  StoredProcedure [opera].[sp_ivp_polaris_save_opera_xml]    Script Date: 06/11/2013 21:00:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [opera].[sp_ivp_polaris_save_opera_xml] 
(
@xml XML,
@UserName VARCHAR(200),
@ReportID INT,
@FundID INT,
@AsOfDate DATETIME
)
/****** 
StoredProcedure [opera].[sp_ivp_polaris_save_opera_xml]  27 May 2013 Roopali
To update data to respective loading tables for various tabs AND archive previous entries based ON received xml			

exec [opera].[sp_ivp_polaris_save_opera_xml] 
'<datanode id="6057" col="long_positions" value="4" sectionid="2" subsectionid="14" grade1="Materials" grade2="Chemicals" grade3="Commodity Chemicals"/>
<datanode id="6056" col="long_positions" value="3" sectionid="2" subsectionid="14" grade1="Materials" grade2="Chemicals" grade3=""/>
<datanode id="6055" col="long_positions" value="4" sectionid="2" subsectionid="14" grade1="Materials" grade2="" grade3=""/>
<datanode id="6057" col="short_positions" value="3" sectionid="2" subsectionid="14" grade1="Materials" grade2="Chemicals" grade3="Commodity Chemicals"/>
<datanode id="6056" col="short_positions" value="3" sectionid="2" subsectionid="14" grade1="Materials" grade2="Chemicals" grade3=""/>
<datanode id="6055" col="short_positions" value="3" sectionid="2" subsectionid="14" grade1="Materials" grade2="" grade3=""/>
<datanode id="0" col="non_netted_long" value="1" sectionid="3" subsectionid="22" grade1="Asia and Oceania" grade2="Developing Economies" grade3="Georgia"/>
<datanode id="0" col="non_netted_long" value="1.00" sectionid="3" subsectionid="22" grade1="Asia and Oceania" grade2="Developing Economies" grade3=""/>
<datanode id="6125" col="non_netted_long" value="3.34" sectionid="3" subsectionid="22" grade1="Asia and Oceania" grade2="" grade3=""/>
',
'rvij' , 33, 21, '2012-08-20'
******/
     
AS    
BEGIN
SET NOCOUNT ON; 
BEGIN TRY  
BEGIN TRAN TransactionOperaSave

DECLARE @FundName VARCHAR(100)
SELECT @FundName = fund_name FROM opera.ivp_polaris_funds WITH (NOLOCK) WHERE id  = @FundID  


SELECT r.c.value('@sectionid', 'INT') AS section_id, r.c.value('@subsectionid', 'INT') AS sub_section_id,

CASE r.c.value('@grade1', 'VARCHAR(200)') WHEN 'dbnull' THEN NULL ELSE r.c.value('@grade1', 'VARCHAR(200)') END AS grade_1,
CASE r.c.value('@grade2', 'VARCHAR(200)') WHEN 'dbnull' THEN NULL ELSE r.c.value('@grade2', 'VARCHAR(200)') END AS grade_2,
CASE r.c.value('@grade3', 'VARCHAR(200)') WHEN 'dbnull' THEN NULL ELSE r.c.value('@grade3', 'VARCHAR(200)') END AS grade_3,
CASE 
WHEN (r.c.value('@grade1', 'VARCHAR(200)') ='dbnull' AND r.c.value('@grade2', 'VARCHAR(200)') ='dbnull' AND r.c.value('@grade3', 'VARCHAR(200)') ='dbnull') THEN CAST(0 AS INT)
WHEN (r.c.value('@grade1', 'VARCHAR(200)') <>'dbnull' AND r.c.value('@grade2', 'VARCHAR(200)') ='dbnull' AND r.c.value('@grade3', 'VARCHAR(200)') ='dbnull') THEN CAST(1 AS INT)
WHEN (r.c.value('@grade1', 'VARCHAR(200)') <>'dbnull' AND r.c.value('@grade2', 'VARCHAR(200)') <>'dbnull' AND r.c.value('@grade3', 'VARCHAR(200)') ='dbnull') THEN CAST(2 AS INT)
ELSE CAST(3 AS INT) END AS [level],

r.c.value('@col', 'VARCHAR(200)') AS column_name,

CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'non_netted_long' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS non_netted_long,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'non_netted_short' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS non_netted_short,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'values' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS [values],

CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'netted_long' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS netted_long,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'netted_short' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS netted_short,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'long_positions' THEN r.c.value('@value', '[int]')  ELSE NULL END AS long_positions,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'short_positions' THEN r.c.value('@value', '[int]')  ELSE NULL END AS short_positions,

CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'dv_fidv' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS dv_fidv,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'dvt_fidv' THEN r.c.value('@value', '[varchar](200)')  ELSE NULL END AS dvt_fidv,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'Month_fidv' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS Month_fidv,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'QTD_fidv' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS QTD_fidv,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'YTD_fidv' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS YTD_fidv,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'ITD_fidv' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS ITD_fidv,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'perc_fidv' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS perc_fidv,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'amt_fidv' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS amt_fidv,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'withPen_fidv' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS withPen_fidv,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'withoutPen_fidv' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS withoutPen_fidv,

CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'bet_sns' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS bet_sns,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'del_sns' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS del_sns,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'gam_sns' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS gam_sns,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'veg_sns' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS veg_sns,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'thet_sns' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS thet_sns,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'cs01_sns' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS cs01_sns,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'dv01_sns' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS dv01_sns,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'dv_sns' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS dv_sns,

CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'pr_st' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS pr_st,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'plng_st' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS plng_st,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'psht_st' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS psht_st,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'dt_st' THEN r.c.value('@value', '[datetime]')  ELSE NULL END AS dt_st,

CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'cnt_cp' THEN r.c.value('@value', '[int]')  ELSE NULL END AS cnt_cp,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'Eq_cp' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS Eq_cp,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'LMV_cp' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS LMV_cp,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'SMV_cp' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS SMV_cp,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'Cash_cp' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS Cash_cp,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'OTE_cp' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS OTE_cp,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'Liq__cp' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS Liq__cp,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'Mrg_cp' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS Mrg_cp,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'elng_cp' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS elng_cp,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'esht_cp' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS esht_cp,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'dvt_cp' THEN r.c.value('@value', 'VARCHAR(200)')  ELSE NULL END AS dvt_cp,

CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'exp_rsk' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS exp_rsk,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'vr_rsk' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS vr_rsk,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'cvr_rsk' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS cvr_rsk,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'dv_rsk' THEN r.c.value('@value', '[numeric](36, 4)')  ELSE NULL END AS dv_rsk,
CASE r.c.value('@col', 'VARCHAR(200)') WHEN 'dvt_rsk' THEN r.c.value('@value', 'VARCHAR(200)')  ELSE NULL END AS dvt_rsk


INTO #DataToBeInsertedForOpera
FROM @xml.nodes('datanode') r(c)

SELECT ISNULL(nni.id, 0) AS id,  opd.section_id AS section_id, opd.sub_section_id AS sub_section_id,
opd.grade_1 AS grade_1, opd.grade_2  AS grade_2, opd.grade_3  AS grade_3, opd.[level] AS [level],
CASE WHEN SUM(opd.non_netted_long) IS NULL THEN CAST(SUM(nni.non_netted_long)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.non_netted_long) AS NUMERIC(36, 4)) END AS non_netted_long,
CASE WHEN  SUM(opd.non_netted_short)  IS NULL THEN CAST(SUM(nni.non_netted_short)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.non_netted_short) AS NUMERIC(36, 4)) END AS non_netted_short,
CASE WHEN  SUM(opd.[values])IS NULL THEN CAST(SUM(nni.[values])/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.[values]) AS NUMERIC(36, 4)) END AS [values]
INTO #DataToBeInsertedForOperaNonNetted
FROM #DataToBeInsertedForOpera opd WITH (NOLOCK)
LEFT OUTER JOIN [opera].[ivp_polaris_report_non_netted_values] nni  WITH (NOLOCK)
ON nni.report_id = @ReportID AND nni.fund_id = @FundID AND nni.reporting_date = @AsOfDate 
AND nni.section_id = opd.section_id AND nni.sub_section_id = opd.sub_section_id
AND (nni.grade_1 = opd.grade_1 OR (opd.grade_1 IS NULL AND nni.grade_1 IS NULL))
AND (nni.grade_2 = opd.grade_2 OR (opd.grade_2 IS NULL AND nni.grade_2 IS NULL))
AND (nni.grade_3 = opd.grade_3 OR (opd.grade_3 IS NULL AND nni.grade_3 IS NULL))
AND nni.is_active = 1
WHERE opd.column_name IN ('non_netted_long','non_netted_short', 'values')
GROUP BY opd.grade_1, opd.grade_2, opd.grade_3, opd.section_id, opd.sub_section_id, opd.[level], nni.id

SELECT ISNULL(nni.id, 0) AS id,  opd.section_id AS section_id, opd.sub_section_id AS sub_section_id,
opd.grade_1 AS grade_1, opd.grade_2  AS grade_2, opd.grade_3  AS grade_3, opd.[level] AS [level],
CASE WHEN SUM(opd.netted_long) IS NULL THEN CAST(SUM(nni.netted_long)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.netted_long) AS NUMERIC(36, 4)) END AS netted_long,
CASE WHEN SUM(opd.netted_short) IS NULL THEN CAST(SUM(nni.netted_short)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.netted_short) AS NUMERIC(36, 4)) END AS netted_short,
CASE WHEN SUM(opd.long_positions) IS NULL THEN CAST(SUM(nni.long_positions)/COUNT(opd.sub_section_id) AS INT) ELSE  CAST(SUM(opd.long_positions) AS INT) END AS long_positions,
CASE WHEN SUM(opd.short_positions) IS NULL THEN CAST(SUM(nni.short_positions)/COUNT(opd.sub_section_id) AS INT) ELSE  CAST(SUM(opd.short_positions) AS INT) END AS short_positions
INTO #DataToBeInsertedForOperaNetted
FROM #DataToBeInsertedForOpera opd WITH (NOLOCK)
LEFT OUTER JOIN [opera].[ivp_polaris_report_netted_values] nni  WITH (NOLOCK)
ON nni.report_id = @ReportID AND nni.fund_id = @FundID AND nni.reporting_date = @AsOfDate 
AND nni.section_id = opd.section_id AND nni.sub_section_id = opd.sub_section_id
AND (nni.grade_1 = opd.grade_1 OR (opd.grade_1 IS NULL AND nni.grade_1 IS NULL))
AND (nni.grade_2 = opd.grade_2 OR (opd.grade_2 IS NULL AND nni.grade_2 IS NULL))
AND (nni.grade_3 = opd.grade_3 OR (opd.grade_3 IS NULL AND nni.grade_3 IS NULL))
AND nni.is_active = 1
WHERE opd.column_name IN ('netted_long','netted_short','long_positions','short_positions')
GROUP BY opd.grade_1, opd.grade_2, opd.grade_3, opd.section_id, opd.sub_section_id, opd.[level], nni.id

SELECT ISNULL(nni.id, 0) AS id,  opd.section_id AS section_id, opd.sub_section_id AS sub_section_id,
opd.grade_1 AS grade_1, opd.grade_2  AS grade_2, opd.grade_3  AS grade_3, opd.[level] AS [level],
CASE WHEN SUM(opd.dv_fidv) IS NULL THEN CAST(SUM(nni.data_value)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.dv_fidv) AS NUMERIC(36, 4)) END AS data_value,
CASE WHEN MAX(opd.dvt_fidv) IS NULL THEN MAX(nni.data_value_text) ELSE  MAX(opd.dvt_fidv) END AS data_value_text,
CASE WHEN SUM(opd.Month_fidv) IS NULL THEN  CAST(SUM(nni.[Month]) /COUNT(opd.sub_section_id) AS NUMERIC(36, 4))ELSE  CAST(SUM(opd.Month_fidv) AS NUMERIC(36, 4)) END AS [Month],
CASE WHEN SUM(opd.QTD_fidv) IS NULL THEN  CAST(SUM(nni.QTD)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.QTD_fidv) AS NUMERIC(36, 4)) END AS QTD,
CASE WHEN SUM(opd.YTD_fidv) IS NULL THEN  CAST(SUM(nni.YTD)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.YTD_fidv) AS NUMERIC(36, 4)) END AS YTD,
CASE WHEN SUM(opd.ITD_fidv) IS NULL THEN  CAST(SUM(nni.ITD)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.ITD_fidv) AS NUMERIC(36, 4)) END AS ITD,
CASE WHEN SUM(opd.perc_fidv) IS NULL THEN  CAST(SUM(nni.percentage)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.perc_fidv) AS NUMERIC(36, 4)) END AS percentage,
CASE WHEN SUM(opd.amt_fidv) IS NULL THEN  CAST(SUM(nni.amount)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.amt_fidv) AS NUMERIC(36, 4)) END AS amount,
CASE WHEN SUM(opd.withPen_fidv) IS NULL THEN  CAST(SUM(nni.with_penality)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.withPen_fidv) AS NUMERIC(36, 4)) END AS with_penality,
CASE WHEN SUM(opd.withoutPen_fidv) IS NULL THEN  CAST(SUM(nni.without_penality) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.withoutPen_fidv) AS NUMERIC(36, 4)) END AS without_penality
INTO #DataToBeInsertedForOperaFidv
FROM #DataToBeInsertedForOpera opd WITH (NOLOCK)
LEFT OUTER JOIN [opera].[ivp_polaris_report_fund_investor_details] nni  WITH (NOLOCK)
ON nni.report_id = @ReportID AND nni.fund_id = @FundID AND nni.reporting_date = @AsOfDate 
AND nni.section_id = opd.section_id AND nni.sub_section_id = opd.sub_section_id
AND (nni.grade_1 = opd.grade_1 OR (opd.grade_1 IS NULL AND nni.grade_1 IS NULL))
AND (nni.grade_2 = opd.grade_2 OR (opd.grade_2 IS NULL AND nni.grade_2 IS NULL))
AND (nni.grade_3 = opd.grade_3 OR (opd.grade_3 IS NULL AND nni.grade_3 IS NULL))
AND nni.is_active = 1
WHERE opd.column_name IN ('dv_fidv' , 'dvt_fidv' , 'Month_fidv' , 'QTD_fidv' , 'YTD_fidv' , 'ITD_fidv' , 'perc_fidv' , 'amt_fidv' , 'withPen_fidv' ,'withoutPen_fidv') 
GROUP BY opd.grade_1, opd.grade_2, opd.grade_3, opd.section_id, opd.sub_section_id, opd.[level], nni.id

SELECT ISNULL(nni.id, 0) AS id,  opd.section_id AS section_id, opd.sub_section_id AS sub_section_id,
opd.grade_1 AS grade_1, opd.grade_2  AS grade_2, opd.grade_3  AS grade_3, opd.[level] AS [level],
CASE WHEN SUM(opd.bet_sns) IS NULL THEN  CAST(SUM(nni.beta)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE   CAST(SUM(opd.bet_sns) AS NUMERIC(36, 4)) END AS beta,
CASE WHEN SUM(opd.del_sns) IS NULL THEN  CAST(SUM(nni.delta)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE   CAST(SUM(opd.del_sns) AS NUMERIC(36, 4)) END AS delta,
CASE WHEN SUM(opd.gam_sns) IS NULL THEN  CAST(SUM(nni.gamma)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE   CAST(SUM(opd.gam_sns) AS NUMERIC(36, 4)) END AS gamma,
CASE WHEN SUM(opd.veg_sns) IS NULL THEN  CAST(SUM(nni.vega)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE   CAST(SUM(opd.veg_sns) AS NUMERIC(36, 4)) END AS vega,
CASE WHEN SUM(opd.thet_sns) IS NULL THEN  CAST(SUM(nni.theta)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE   CAST(SUM(opd.thet_sns) AS NUMERIC(36, 4)) END AS theta,
CASE WHEN SUM(opd.cs01_sns) IS NULL THEN  CAST(SUM(nni.cs01)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE   CAST(SUM(opd.cs01_sns) AS NUMERIC(36, 4)) END AS cs01,
CASE WHEN SUM(opd.dv01_sns) IS NULL THEN  CAST(SUM(nni.dv01)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE   CAST(SUM(opd.dv01_sns) AS NUMERIC(36, 4)) END AS dv01,
CASE WHEN SUM(opd.dv_sns) IS NULL THEN  CAST(SUM(nni.dataValue)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE   CAST(SUM(opd.dv_sns) AS NUMERIC(36, 4)) END AS data_value
INTO #DataToBeInsertedForOperaSns
FROM #DataToBeInsertedForOpera opd WITH (NOLOCK)
LEFT OUTER JOIN [opera].[ivp_polaris_report_fund_sensitivity_details] nni  WITH (NOLOCK)
ON nni.report_id = @ReportID AND nni.fund_id = @FundID AND nni.reporting_date = @AsOfDate 
AND nni.section_id = opd.section_id AND nni.sub_section_id = opd.sub_section_id
AND (nni.grade_1 = opd.grade_1 OR (opd.grade_1 IS NULL AND nni.grade_1 IS NULL))
AND (nni.grade_2 = opd.grade_2 OR (opd.grade_2 IS NULL AND nni.grade_2 IS NULL))
AND (nni.grade_3 = opd.grade_3 OR (opd.grade_3 IS NULL AND nni.grade_3 IS NULL))
AND nni.is_active = 1
WHERE opd.column_name IN ('bet_sns','del_sns','gam_sns','veg_sns','thet_sns','cs01_sns','dv01_sns','dv_sns') 
GROUP BY opd.grade_1, opd.grade_2, opd.grade_3, opd.section_id, opd.sub_section_id, opd.[level], nni.id

SELECT ISNULL(nni.id, 0) AS id,  opd.section_id AS section_id, opd.sub_section_id AS sub_section_id,
opd.grade_1 AS grade_1, opd.grade_2  AS grade_2, opd.grade_3  AS grade_3, opd.[level] AS [level],
CASE WHEN SUM(opd.pr_st) IS NULL THEN CAST(SUM(nni.portfolio_return)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.pr_st) AS NUMERIC(36, 4)) END AS portfolio_return,
CASE WHEN SUM(opd.plng_st) IS NULL THEN CAST(SUM(nni.percentage_long)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.plng_st) AS NUMERIC(36, 4)) END AS percentage_long,
CASE WHEN SUM(opd.psht_st) IS NULL THEN CAST(SUM(nni.percentage_short)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.psht_st) AS NUMERIC(36, 4)) END AS percentage_short,
CASE WHEN MAX(opd.dt_st) IS NULL THEN MAX([start_date]) ELSE  MAX(opd.dt_st) END AS [start_date]
INTO #DataToBeInsertedForOperaSt
FROM #DataToBeInsertedForOpera opd WITH (NOLOCK)
LEFT OUTER JOIN [opera].[ivp_polaris_report_fund_stress_test] nni  WITH (NOLOCK)
ON nni.report_id = @ReportID AND nni.fund_id = @FundID AND nni.reporting_date = @AsOfDate 
AND nni.section_id = opd.section_id AND nni.sub_section_id = opd.sub_section_id
AND (nni.grade_1 = opd.grade_1 OR (opd.grade_1 IS NULL AND nni.grade_1 IS NULL))
AND (nni.grade_2 = opd.grade_2 OR (opd.grade_2 IS NULL AND nni.grade_2 IS NULL))
AND (nni.grade_3 = opd.grade_3 OR (opd.grade_3 IS NULL AND nni.grade_3 IS NULL))
AND nni.is_active = 1
WHERE opd.column_name IN ('pr_st','plng_st','psht_st','dt_st') 
GROUP BY opd.grade_1, opd.grade_2, opd.grade_3, opd.section_id, opd.sub_section_id, opd.[level], nni.id

SELECT ISNULL(nni.id, 0) AS id,  opd.section_id AS section_id, opd.sub_section_id AS sub_section_id,
opd.grade_1 AS grade_1, opd.grade_2  AS grade_2, opd.grade_3  AS grade_3, opd.[level] AS [level],
CASE WHEN SUM(opd.cnt_cp) IS NULL THEN CAST(SUM(nni.number_count)/COUNT(opd.sub_section_id) AS INT) ELSE  CAST(SUM(opd.cnt_cp) AS INT) END AS number_count,
CASE WHEN SUM(opd.Eq_cp) IS NULL THEN CAST(SUM(nni.Equity)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.Eq_cp) AS NUMERIC(36, 4)) END AS Equity,
CASE WHEN SUM(opd.LMV_cp) IS NULL THEN CAST(SUM(nni.LMV)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.LMV_cp) AS NUMERIC(36, 4)) END AS LMV,
CASE WHEN SUM(opd.SMV_cp) IS NULL THEN CAST(SUM(nni.SMV)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.SMV_cp) AS NUMERIC(36, 4)) END AS SMV,
CASE WHEN SUM(opd.Cash_cp) IS NULL THEN CAST(SUM(nni.Cash)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.Cash_cp) AS NUMERIC(36, 4)) END AS Cash,
CASE WHEN SUM(opd.OTE_cp) IS NULL THEN CAST(SUM(nni.OTE_MTM)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.OTE_cp) AS NUMERIC(36, 4)) END AS OTE_MTM,
CASE WHEN SUM(opd.Liq__cp) IS NULL THEN CAST(SUM(nni.Available_Liquidity)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.Liq__cp) AS NUMERIC(36, 4)) END AS Available_Liquidity,
CASE WHEN SUM(opd.Mrg_cp) IS NULL THEN CAST(SUM(nni.Required_Margin)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.Mrg_cp) AS NUMERIC(36, 4)) END AS Required_Margin,
CASE WHEN SUM(opd.elng_cp) IS NULL THEN CAST(SUM(nni.Long_Exposure)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.elng_cp) AS NUMERIC(36, 4)) END AS Long_Exposure,
CASE WHEN SUM(opd.esht_cp) IS NULL THEN CAST(SUM(nni.Short_Exposure)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.esht_cp) AS NUMERIC(36, 4)) END AS Short_Exposure,
CASE WHEN MAX(opd.dvt_cp) IS NULL THEN MAX(nni.data_value_text) ELSE  MAX(opd.dvt_cp) END AS data_value_text
INTO #DataToBeInsertedForOperaCp
FROM #DataToBeInsertedForOpera opd WITH (NOLOCK)
LEFT OUTER JOIN [opera].[ivp_polaris_report_counterparty_details] nni  WITH (NOLOCK)
ON nni.report_id = @ReportID AND nni.fund_id = @FundID AND nni.reporting_date = @AsOfDate 
AND nni.section_id = opd.section_id AND nni.sub_section_id = opd.sub_section_id
AND (nni.grade_1 = opd.grade_1 OR (opd.grade_1 IS NULL AND nni.grade_1 IS NULL))
AND (nni.grade_2 = opd.grade_2 OR (opd.grade_2 IS NULL AND nni.grade_2 IS NULL))
AND (nni.grade_3 = opd.grade_3 OR (opd.grade_3 IS NULL AND nni.grade_3 IS NULL))
AND nni.is_active = 1
WHERE opd.column_name IN ('cnt_cp' ,'Eq_cp','LMV_cp','SMV_cp','Cash_cp','OTE_cp','Liq__cp','Mrg_cp','elng_cp','esht_cp','dvt_cp') 
GROUP BY opd.grade_1, opd.grade_2, opd.grade_3, opd.section_id, opd.sub_section_id, opd.[level], nni.id

SELECT ISNULL(nni.id, 0) AS id,  opd.section_id AS section_id, opd.sub_section_id AS sub_section_id,
opd.grade_1 AS grade_1, opd.grade_2  AS grade_2, opd.grade_3  AS grade_3, opd.[level] AS [level],
CASE WHEN SUM(opd.exp_rsk) IS NULL THEN CAST(SUM(nni.exposure_per)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.exp_rsk) AS NUMERIC(36, 4)) END AS exposure_per,
CASE WHEN SUM(opd.vr_rsk) IS NULL THEN CAST(SUM(nni.var_per)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.vr_rsk) AS NUMERIC(36, 4)) END AS var_per,
CASE WHEN SUM(opd.cvr_rsk) IS NULL THEN CAST(SUM(nni.cvar_per)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.cvr_rsk) AS NUMERIC(36, 4)) END AS cvar_per,
CASE WHEN SUM(opd.dv_rsk) IS NULL THEN CAST(SUM(nni.data_value)/COUNT(opd.sub_section_id) AS NUMERIC(36, 4)) ELSE  CAST(SUM(opd.dv_rsk) AS NUMERIC(36, 4)) END AS data_value,
CASE WHEN MAX(opd.dvt_rsk) IS NULL THEN MAX(nni.data_value_text) ELSE  MAX(opd.dvt_rsk) END AS data_value_text
INTO #DataToBeInsertedForOperaRsk
FROM #DataToBeInsertedForOpera opd WITH (NOLOCK)
LEFT OUTER JOIN [opera].[ivp_polaris_report_value_at_risk] nni  WITH (NOLOCK)
ON nni.report_id = @ReportID AND nni.fund_id = @FundID AND nni.reporting_date = @AsOfDate 
AND nni.section_id = opd.section_id AND nni.sub_section_id = opd.sub_section_id
AND (nni.grade_1 = opd.grade_1 OR (opd.grade_1 IS NULL AND nni.grade_1 IS NULL))
AND (nni.grade_2 = opd.grade_2 OR (opd.grade_2 IS NULL AND nni.grade_2 IS NULL))
AND (nni.grade_3 = opd.grade_3 OR (opd.grade_3 IS NULL AND nni.grade_3 IS NULL))
AND nni.is_active = 1
WHERE opd.column_name IN ('exp_rsk','vr_rsk','cvr_rsk','dv_rsk','dvt_rsk') 
GROUP BY opd.grade_1, opd.grade_2, opd.grade_3, opd.section_id, opd.sub_section_id, opd.[level], nni.id

DROP TABLE #DataToBeInsertedForOpera

SELECT nnv.[id], nnv.[report_id],[fund_id],[fund_name],nnv.[section_id],nnv.[sub_section_id] ,nnv.[reporting_date],nnv.[grade_1],nnv.[grade_2] ,nnv.[grade_3]          
,nnv.[non_netted_long],nnv.[non_netted_short]  ,nnv.[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active]           
,nnv.[values] INTO #deletedOperaRowsForArchiveNonNetted FROM [opera].[ivp_polaris_report_non_netted_values] nnv WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaNonNetted tnnv WITH (NOLOCK) on tnnv.id = nnv.id 

UPDATE [opera].[ivp_polaris_report_non_netted_values] 
SET 
non_netted_long =  tnnv.non_netted_long,
non_netted_short =  tnnv.non_netted_short,
[values] = tnnv.[values],
knowledge_date = GETDATE(), modified_by = @UserName, modified_on = GETDATE(), is_user_edited = 1
FROM [opera].[ivp_polaris_report_non_netted_values] nnv WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaNonNetted tnnv WITH (NOLOCK) on tnnv.id = nnv.id 
 
UPDATE [opera].[ivp_polaris_report_non_netted_values_archive] SET is_active = 0
FROM #deletedOperaRowsForArchiveNonNetted d  WITH (NOLOCK)
WHERE  [opera].[ivp_polaris_report_non_netted_values_archive].Report_id = d.report_id 
AND [opera].[ivp_polaris_report_non_netted_values_archive].fund_id = d.fund_id
AND [opera].[ivp_polaris_report_non_netted_values_archive].reporting_date = d.reporting_date
AND [opera].[ivp_polaris_report_non_netted_values_archive].section_id = d.section_id
AND [opera].[ivp_polaris_report_non_netted_values_archive].sub_section_id = d.sub_section_id
AND ([opera].[ivp_polaris_report_non_netted_values_archive].grade_1 = d.grade_1 OR ([opera].[ivp_polaris_report_non_netted_values_archive].grade_1 IS NULL AND d.grade_1 IS NULL))
AND ([opera].[ivp_polaris_report_non_netted_values_archive].grade_2 = d.grade_2 OR ([opera].[ivp_polaris_report_non_netted_values_archive].grade_2 IS NULL AND d.grade_2 IS NULL))
AND ([opera].[ivp_polaris_report_non_netted_values_archive].grade_3 = d.grade_3 OR ([opera].[ivp_polaris_report_non_netted_values_archive].grade_3 IS NULL AND d.grade_3 IS NULL))

INSERT INTO [opera].[ivp_polaris_report_non_netted_values_archive]
([report_id] ,[fund_id] ,[fund_name] ,[section_id] ,[sub_section_id]
,[reporting_date] ,[grade_1]  ,[grade_2]  ,[grade_3] ,[non_netted_long]
,[non_netted_short] ,[level] ,[is_user_edited] ,[loading_date]  ,[knowledge_date]
,[created_on]   ,[created_by]  ,[modified_on] ,[modified_by]  ,[is_active] ,[values])
SELECT report_id, fund_id, fund_name, section_id, sub_section_id,
reporting_date, grade_1, grade_2, grade_3, non_netted_long, 
non_netted_short, [level], is_user_edited, loading_date, knowledge_date,
created_on, created_by, modified_on, modified_by, 1, [values]
FROM #deletedOperaRowsForArchiveNonNetted  WITH (NOLOCK)

DROP TABLE #deletedOperaRowsForArchiveNonNetted

SELECT nv.[id], nv.[report_id],[fund_id],[fund_name],nv.[section_id],nv.[sub_section_id] ,nv.[reporting_date],nv.[grade_1],nv.[grade_2] ,nv.[grade_3]          
,nv.[netted_long] ,nv.[netted_short],nv.[long_positions] ,nv.[short_positions]  ,nv.[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active]           
INTO #deletedOperaRowsForArchiveNetted FROM [opera].[ivp_polaris_report_netted_values] nv WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaNetted tnv WITH (NOLOCK) ON tnv.id = nv.id

UPDATE [opera].[ivp_polaris_report_netted_values] 
SET 
netted_long = tnv.netted_long,
netted_short = tnv.netted_short ,
long_positions = tnv.long_positions ,
short_positions = tnv.short_positions ,
knowledge_date = GETDATE(), modified_by = @UserName, modified_on = GETDATE(), is_user_edited = 1
FROM [opera].[ivp_polaris_report_netted_values] nv WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaNetted tnv WITH (NOLOCK) ON tnv.id = nv.id

UPDATE [opera].[ivp_polaris_report_netted_values_archive] SET is_active = 0
FROM #deletedOperaRowsForArchiveNetted d  WITH (NOLOCK)
WHERE  [opera].[ivp_polaris_report_netted_values_archive].Report_id = d.report_id 
AND [opera].[ivp_polaris_report_netted_values_archive].fund_id = d.fund_id
AND [opera].[ivp_polaris_report_netted_values_archive].reporting_date = d.reporting_date
AND [opera].[ivp_polaris_report_netted_values_archive].section_id = d.section_id
AND [opera].[ivp_polaris_report_netted_values_archive].sub_section_id = d.sub_section_id
AND ([opera].[ivp_polaris_report_netted_values_archive].grade_1 = d.grade_1 OR ([opera].[ivp_polaris_report_netted_values_archive].grade_1 IS NULL AND d.grade_1 IS NULL))
AND ([opera].[ivp_polaris_report_netted_values_archive].grade_2 = d.grade_2 OR ([opera].[ivp_polaris_report_netted_values_archive].grade_2 IS NULL AND d.grade_2 IS NULL))
AND ([opera].[ivp_polaris_report_netted_values_archive].grade_3 = d.grade_3 OR ([opera].[ivp_polaris_report_netted_values_archive].grade_3 IS NULL AND d.grade_3 IS NULL))

INSERT INTO [opera].[ivp_polaris_report_netted_values_archive]
([report_id],[fund_id],[fund_name] ,[section_id] ,[sub_section_id]
,[reporting_date],[grade_1] ,[grade_2],[grade_3] ,[netted_long] ,[netted_short]
,[long_positions] ,[short_positions] ,[level] ,[is_user_edited] ,[loading_date]
,[knowledge_date] ,[created_on] ,[created_by] ,[modified_on]  ,[modified_by] ,[is_active])
SELECT report_id, fund_id, fund_name, section_id, sub_section_id,
reporting_date, grade_1, grade_2, grade_3, netted_long, netted_short, 
long_positions, short_positions, [level], is_user_edited, loading_date, 
knowledge_date, created_on, created_by, modified_on, modified_by, 1
FROM #deletedOperaRowsForArchiveNetted  WITH (NOLOCK)

DROP TABLE #deletedOperaRowsForArchiveNetted

SELECT fidv.[id], fidv.[report_id],[fund_id],[fund_name],fidv.[section_id],fidv.[sub_section_id] ,fidv.[reporting_date],fidv.[grade_1],fidv.[grade_2] ,fidv.[grade_3]          
,fidv.[data_value] ,fidv.[data_value_text] ,fidv.[Month] ,fidv.QTD ,fidv.YTD,fidv.ITD,fidv.percentage,fidv.amount,fidv.with_penality,fidv.without_penality
,fidv.[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active]           
INTO #deletedOperaRowsForArchiveFidv FROM [opera].[ivp_polaris_report_fund_investor_details] fidv WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaFidv tfidv WITH (NOLOCK) on tfidv.id = fidv.id

UPDATE [opera].[ivp_polaris_report_fund_investor_details] 
SET 
data_value = tfidv.data_value ,
data_value_text = tfidv.data_value_text ,
[Month] = tfidv.[Month] ,
QTD = tfidv.QTD ,
YTD = tfidv.YTD ,
ITD = tfidv.ITD ,
percentage = tfidv.percentage ,
amount = tfidv.amount ,
with_penality = tfidv.with_penality ,
without_penality = tfidv.without_penality ,
knowledge_date = GETDATE(), modified_by = @UserName, modified_on = GETDATE(), is_user_edited = 1
FROM [opera].[ivp_polaris_report_fund_investor_details] fidv WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaFidv tfidv WITH (NOLOCK) on tfidv.id = fidv.id

UPDATE [opera].[ivp_polaris_report_fund_investor_details_archive] SET is_active = 0
FROM #deletedOperaRowsForArchiveFidv d  WITH (NOLOCK)
WHERE  [opera].[ivp_polaris_report_fund_investor_details_archive].Report_id = d.report_id 
AND [opera].[ivp_polaris_report_fund_investor_details_archive].fund_id = d.fund_id
AND [opera].[ivp_polaris_report_fund_investor_details_archive].reporting_date = d.reporting_date
AND [opera].[ivp_polaris_report_fund_investor_details_archive].section_id = d.section_id
AND [opera].[ivp_polaris_report_fund_investor_details_archive].sub_section_id = d.sub_section_id
AND ([opera].[ivp_polaris_report_fund_investor_details_archive].grade_1 = d.grade_1 OR ([opera].[ivp_polaris_report_fund_investor_details_archive].grade_1 IS NULL AND d.grade_1 IS NULL))
AND ([opera].[ivp_polaris_report_fund_investor_details_archive].grade_2 = d.grade_2 OR ([opera].[ivp_polaris_report_fund_investor_details_archive].grade_2 IS NULL AND d.grade_2 IS NULL))
AND ([opera].[ivp_polaris_report_fund_investor_details_archive].grade_3 = d.grade_3 OR ([opera].[ivp_polaris_report_fund_investor_details_archive].grade_3 IS NULL AND d.grade_3 IS NULL))

INSERT INTO [opera].[ivp_polaris_report_fund_investor_details_archive]
([report_id],[fund_id],[fund_name] ,[section_id] ,[sub_section_id]
,[reporting_date],[grade_1] ,[grade_2],[grade_3] ,
[data_value] ,[data_value_text] ,[Month] ,QTD ,YTD,ITD,percentage,amount,with_penality,without_penality,
[level] ,[is_user_edited] ,[loading_date]
,[knowledge_date] ,[created_on] ,[created_by] ,[modified_on]  ,[modified_by] ,[is_active])
SELECT report_id, fund_id, fund_name, section_id, sub_section_id,
reporting_date, grade_1, grade_2, grade_3, 
[data_value] ,[data_value_text] ,[Month] ,QTD ,YTD,ITD,percentage,amount,with_penality,without_penality,
[level], is_user_edited, loading_date, 
knowledge_date, created_on, created_by, modified_on, modified_by, 1
FROM #deletedOperaRowsForArchiveFidv WITH (NOLOCK)

DROP TABLE #deletedOperaRowsForArchiveFidv

SELECT sns.[id], sns.[report_id],[fund_id],[fund_name],sns.[section_id],sns.[sub_section_id] ,sns.[reporting_date],sns.[grade_1],sns.[grade_2] ,sns.[grade_3]          
,sns.beta ,sns.delta ,sns.gamma ,sns.vega ,sns.theta,sns.cs01,sns.dv01,sns.dataValue  ,sns.[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active]           
INTO #deletedOperaRowsForArchiveSns FROM [opera].[ivp_polaris_report_fund_sensitivity_details] sns WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaSns tsns WITH (NOLOCK) on tsns.id = sns.id  

UPDATE [opera].[ivp_polaris_report_fund_sensitivity_details] 
SET 
beta = tsns.beta ,
delta = tsns.delta ,
gamma = tsns.gamma ,
vega = tsns.vega ,
theta = tsns.theta ,
cs01 = tsns.cs01 ,
dv01 = tsns.dv01 ,
dataValue = tsns.data_value,
knowledge_date = GETDATE(), modified_by = @UserName, modified_on = GETDATE(), is_user_edited = 1
FROM [opera].[ivp_polaris_report_fund_sensitivity_details] sns WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaSns tsns WITH (NOLOCK) on tsns.id = sns.id 

UPDATE [opera].[ivp_polaris_report_fund_sensitivity_details_archive]  SET is_active = 0
FROM #deletedOperaRowsForArchiveSns d  WITH (NOLOCK)
WHERE  [opera].[ivp_polaris_report_fund_sensitivity_details_archive].Report_id = d.report_id 
AND [opera].[ivp_polaris_report_fund_sensitivity_details_archive].fund_id = d.fund_id
AND [opera].[ivp_polaris_report_fund_sensitivity_details_archive].reporting_date = d.reporting_date
AND [opera].[ivp_polaris_report_fund_sensitivity_details_archive].section_id = d.section_id
AND [opera].[ivp_polaris_report_fund_sensitivity_details_archive].sub_section_id = d.sub_section_id
AND ([opera].[ivp_polaris_report_fund_sensitivity_details_archive].grade_1 = d.grade_1 OR ([opera].[ivp_polaris_report_fund_sensitivity_details_archive].grade_1 IS NULL AND d.grade_1 IS NULL))
AND ([opera].[ivp_polaris_report_fund_sensitivity_details_archive].grade_2 = d.grade_2 OR ([opera].[ivp_polaris_report_fund_sensitivity_details_archive].grade_2 IS NULL AND d.grade_2 IS NULL))
AND ([opera].[ivp_polaris_report_fund_sensitivity_details_archive].grade_3 = d.grade_3 OR ([opera].[ivp_polaris_report_fund_sensitivity_details_archive].grade_3 IS NULL AND d.grade_3 IS NULL))

INSERT INTO [opera].[ivp_polaris_report_fund_sensitivity_details_archive]
([report_id],[fund_id],[fund_name] ,[section_id] ,[sub_section_id]
,[reporting_date],[grade_1] ,[grade_2],[grade_3] ,
beta ,delta ,gamma ,vega ,theta,cs01,dv01,dataValue,
[level] ,[is_user_edited] ,[loading_date]
,[knowledge_date] ,[created_on] ,[created_by] ,[modified_on]  ,[modified_by] ,[is_active])
SELECT report_id, fund_id, fund_name, section_id, sub_section_id,
reporting_date, grade_1, grade_2, grade_3, 
beta ,delta ,gamma ,vega ,theta,cs01,dv01,dataValue,
[level], is_user_edited, loading_date, 
knowledge_date, created_on, created_by, modified_on, modified_by, 1
FROM #deletedOperaRowsForArchiveSns WITH (NOLOCK)

DROP TABLE #deletedOperaRowsForArchiveSns

SELECT st.[id], st.[report_id],[fund_id],[fund_name],st.[section_id],st.[sub_section_id] ,st.[reporting_date],st.[grade_1],st.[grade_2] ,st.[grade_3]          
,st.portfolio_return ,st.percentage_long ,st.percentage_short , st.[start_date]  ,st.[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active]           
INTO #deletedOperaRowsForArchiveSt FROM [opera].[ivp_polaris_report_fund_stress_test] st WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaSt tst WITH (NOLOCK) on tst.id = st.id 

UPDATE [opera].[ivp_polaris_report_fund_stress_test] 
SET 
portfolio_return = tst.portfolio_return ,
percentage_long = tst.percentage_long ,
percentage_short =  tst.percentage_short ,
[start_date]  = tst.[start_date] ,
knowledge_date = GETDATE(), modified_by = @UserName, modified_on = GETDATE(), is_user_edited = 1
FROM [opera].[ivp_polaris_report_fund_stress_test] st WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaSt tst WITH (NOLOCK) on tst.id = st.id 

UPDATE [opera].[ivp_polaris_report_fund_stress_test_archive]  SET is_active = 0
FROM #deletedOperaRowsForArchiveSt d WITH (NOLOCK)
WHERE  [opera].[ivp_polaris_report_fund_stress_test_archive].Report_id = d.report_id 
AND [opera].[ivp_polaris_report_fund_stress_test_archive].fund_id = d.fund_id
AND [opera].[ivp_polaris_report_fund_stress_test_archive].reporting_date = d.reporting_date
AND [opera].[ivp_polaris_report_fund_stress_test_archive].section_id = d.section_id
AND [opera].[ivp_polaris_report_fund_stress_test_archive].sub_section_id = d.sub_section_id
AND ([opera].[ivp_polaris_report_fund_stress_test_archive].grade_1 = d.grade_1 OR ([opera].[ivp_polaris_report_fund_stress_test_archive].grade_1 IS NULL AND d.grade_1 IS NULL))
AND ([opera].[ivp_polaris_report_fund_stress_test_archive].grade_2 = d.grade_2 OR ([opera].[ivp_polaris_report_fund_stress_test_archive].grade_2 IS NULL AND d.grade_2 IS NULL))
AND ([opera].[ivp_polaris_report_fund_stress_test_archive].grade_3 = d.grade_3 OR ([opera].[ivp_polaris_report_fund_stress_test_archive].grade_3 IS NULL AND d.grade_3 IS NULL))

INSERT INTO [opera].[ivp_polaris_report_fund_stress_test_archive]
([report_id],[fund_id],[fund_name] ,[section_id] ,[sub_section_id]
,[reporting_date],[grade_1] ,[grade_2],[grade_3] ,
portfolio_return ,percentage_long ,percentage_short , [start_date],
[level] ,[is_user_edited] ,[loading_date]
,[knowledge_date] ,[created_on] ,[created_by] ,[modified_on]  ,[modified_by] ,[is_active])
SELECT report_id, fund_id, fund_name, section_id, sub_section_id,
reporting_date, grade_1, grade_2, grade_3, 
portfolio_return ,percentage_long ,percentage_short , [start_date],
[level], is_user_edited, loading_date, 
knowledge_date, created_on, created_by, modified_on, modified_by, 1
FROM #deletedOperaRowsForArchiveSt WITH (NOLOCK)

DROP TABLE #deletedOperaRowsForArchiveSt

SELECT cp.[id], cp.[report_id],[fund_id],[fund_name],cp.[section_id],cp.[sub_section_id] ,cp.[reporting_date],cp.[grade_1],cp.[grade_2] ,cp.[grade_3]          
,cp.number_count ,cp.Equity ,cp.LMV , cp.SMV,cp.Cash,cp.OTE_MTM,cp.Available_Liquidity,cp.Required_Margin,cp.Long_Exposure,cp.Short_Exposure,cp.data_value_text 
,cp.[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active]           
INTO #deletedOperaRowsForArchiveCp FROM [opera].[ivp_polaris_report_counterparty_details] cp WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaCp tbcp WITH (NOLOCK) on tbcp.id = cp.id 

UPDATE [opera].[ivp_polaris_report_counterparty_details] 
SET 
number_count = tbcp.number_count ,
Equity = tbcp.Equity ,
LMV = tbcp.LMV ,
SMV = tbcp.SMV ,
Cash = tbcp.Cash ,
OTE_MTM =tbcp.OTE_MTM ,
Available_Liquidity = tbcp.Available_Liquidity ,
Required_Margin = tbcp.Required_Margin ,
Long_Exposure = tbcp.Long_Exposure ,
Short_Exposure = tbcp.Short_Exposure ,
data_value_text = tbcp.data_value_text ,
knowledge_date = GETDATE(), modified_by = @UserName, modified_on = GETDATE(), is_user_edited = 1
FROM [opera].[ivp_polaris_report_counterparty_details] cp WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaCp tbcp WITH (NOLOCK) on tbcp.id = cp.id 

UPDATE [opera].[ivp_polaris_report_counterparty_details_archive]  SET is_active = 0
FROM #deletedOperaRowsForArchiveCp d WITH (NOLOCK)
WHERE  [opera].[ivp_polaris_report_counterparty_details_archive].Report_id = d.report_id 
AND [opera].[ivp_polaris_report_counterparty_details_archive].fund_id = d.fund_id
AND [opera].[ivp_polaris_report_counterparty_details_archive].reporting_date = d.reporting_date
AND [opera].[ivp_polaris_report_counterparty_details_archive].section_id = d.section_id
AND [opera].[ivp_polaris_report_counterparty_details_archive].sub_section_id = d.sub_section_id
AND ([opera].[ivp_polaris_report_counterparty_details_archive].grade_1 = d.grade_1 OR ([opera].[ivp_polaris_report_counterparty_details_archive].grade_1 IS NULL AND d.grade_1 IS NULL))
AND ([opera].[ivp_polaris_report_counterparty_details_archive].grade_2 = d.grade_2 OR ([opera].[ivp_polaris_report_counterparty_details_archive].grade_2 IS NULL AND d.grade_2 IS NULL))
AND ([opera].[ivp_polaris_report_counterparty_details_archive].grade_3 = d.grade_3 OR ([opera].[ivp_polaris_report_counterparty_details_archive].grade_3 IS NULL AND d.grade_3 IS NULL))

INSERT INTO [opera].[ivp_polaris_report_counterparty_details_archive]
([report_id],[fund_id],[fund_name] ,[section_id] ,[sub_section_id]
,[reporting_date],[grade_1] ,[grade_2],[grade_3] ,
number_count ,Equity ,LMV , SMV,Cash,OTE_MTM,Available_Liquidity,Required_Margin,Long_Exposure,Short_Exposure,data_value_text,
[level] ,[is_user_edited] ,[loading_date]
,[knowledge_date] ,[created_on] ,[created_by] ,[modified_on]  ,[modified_by] ,[is_active])
SELECT report_id, fund_id, fund_name, section_id, sub_section_id,
reporting_date, grade_1, grade_2, grade_3, 
number_count ,Equity ,LMV , SMV,Cash,OTE_MTM,Available_Liquidity,Required_Margin,Long_Exposure,Short_Exposure,data_value_text,
[level], is_user_edited, loading_date, 
knowledge_date, created_on, created_by, modified_on, modified_by, 1
FROM #deletedOperaRowsForArchiveCp WITH (NOLOCK)

DROP TABLE #deletedOperaRowsForArchiveCp

SELECT rsk.[id], rsk.[report_id],[fund_id],[fund_name],rsk.[section_id],rsk.[sub_section_id] ,rsk.[reporting_date],rsk.[grade_1],rsk.[grade_2] ,rsk.[grade_3]          
,rsk.exposure_per ,rsk.var_per ,rsk.cvar_per ,rsk.data_value, rsk.data_value_text,  rsk.[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active]           
INTO #deletedOperaRowsForArchiveRsk FROM [opera].[ivp_polaris_report_value_at_risk] rsk WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaRsk trsk WITH (NOLOCK) on trsk.id = rsk.id

UPDATE [opera].[ivp_polaris_report_value_at_risk] 
SET 
exposure_per = trsk.exposure_per,
var_per = trsk.var_per,
cvar_per = trsk.cvar_per,
data_value = trsk.data_value,
data_value_text = trsk.data_value_text,
knowledge_date = GETDATE(), modified_by = @UserName, modified_on = GETDATE(), is_user_edited = 1
FROM [opera].[ivp_polaris_report_value_at_risk] rsk WITH (NOLOCK)
JOIN #DataToBeInsertedForOperaRsk trsk WITH (NOLOCK) on trsk.id = rsk.id

UPDATE [opera].[ivp_polaris_report_value_at_risk_archive]  SET is_active = 0
FROM #deletedOperaRowsForArchiveRsk d WITH (NOLOCK)
WHERE  [opera].[ivp_polaris_report_value_at_risk_archive].Report_id = d.report_id 
AND [opera].[ivp_polaris_report_value_at_risk_archive].fund_id = d.fund_id
AND [opera].[ivp_polaris_report_value_at_risk_archive].reporting_date = d.reporting_date
AND [opera].[ivp_polaris_report_value_at_risk_archive].section_id = d.section_id
AND [opera].[ivp_polaris_report_value_at_risk_archive].sub_section_id = d.sub_section_id
AND ([opera].[ivp_polaris_report_value_at_risk_archive].grade_1 = d.grade_1 OR ([opera].[ivp_polaris_report_value_at_risk_archive].grade_1 IS NULL AND d.grade_1 IS NULL))
AND ([opera].[ivp_polaris_report_value_at_risk_archive].grade_2 = d.grade_2 OR ([opera].[ivp_polaris_report_value_at_risk_archive].grade_2 IS NULL AND d.grade_2 IS NULL))
AND ([opera].[ivp_polaris_report_value_at_risk_archive].grade_3 = d.grade_3 OR ([opera].[ivp_polaris_report_value_at_risk_archive].grade_3 IS NULL AND d.grade_3 IS NULL))

INSERT INTO [opera].[ivp_polaris_report_value_at_risk_archive]
([report_id],[fund_id],[fund_name] ,[section_id] ,[sub_section_id]
,[reporting_date],[grade_1] ,[grade_2],[grade_3] ,
exposure_per ,var_per ,cvar_per ,data_value, data_value_text,
[level] ,[is_user_edited] ,[loading_date]
,[knowledge_date] ,[created_on] ,[created_by] ,[modified_on]  ,[modified_by] ,[is_active])
SELECT report_id, fund_id, fund_name, section_id, sub_section_id,
reporting_date, grade_1, grade_2, grade_3, 
exposure_per ,var_per ,cvar_per ,data_value, data_value_text,
[level], is_user_edited, loading_date, 
knowledge_date, created_on, created_by, modified_on, modified_by, 1
FROM #deletedOperaRowsForArchiveRsk WITH (NOLOCK)

DROP TABLE #deletedOperaRowsForArchiveRsk

INSERT INTO [opera].[ivp_polaris_report_non_netted_values]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]          
,[non_netted_long],[non_netted_short]  
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active]           
,[values])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate,[grade_1],[grade_2] ,[grade_3],          
[non_netted_long],[non_netted_short]  ,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1, 
[values]
FROM #DataToBeInsertedForOperaNonNetted iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_non_netted_values_archive]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]          
,[non_netted_long],[non_netted_short]  
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active]           
,[values])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate,[grade_1],[grade_2] ,[grade_3],          
[non_netted_long],[non_netted_short]  ,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1, 
[values]
FROM #DataToBeInsertedForOperaNonNetted iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_netted_values]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
, [netted_long] ,[netted_short],[long_positions] ,[short_positions] 
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate,[grade_1],[grade_2] ,[grade_3] , 
[netted_long] ,[netted_short],[long_positions] ,[short_positions] ,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaNetted iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_netted_values_archive]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
, [netted_long] ,[netted_short],[long_positions] ,[short_positions] 
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate,[grade_1],[grade_2] ,[grade_3] , 
[netted_long] ,[netted_short],[long_positions] ,[short_positions] ,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaNetted iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_fund_investor_details]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
, [data_value] ,[data_value_text] ,[Month] ,QTD ,YTD,ITD,percentage,amount,with_penality,without_penality
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate, [grade_1],[grade_2] ,[grade_3],
[data_value] ,[data_value_text] ,[Month] ,QTD ,YTD,ITD,percentage,amount,with_penality,without_penality,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaFidv iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_fund_investor_details_archive]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
, [data_value] ,[data_value_text] ,[Month] ,QTD ,YTD,ITD,percentage,amount,with_penality,without_penality
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate, [grade_1],[grade_2] ,[grade_3],
[data_value] ,[data_value_text] ,[Month] ,QTD ,YTD,ITD,percentage,amount,with_penality,without_penality,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaFidv iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_fund_sensitivity_details]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
, beta ,delta ,gamma ,vega ,theta,cs01,dv01,dataValue
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate, [grade_1],[grade_2] ,[grade_3],
beta ,delta ,gamma ,vega ,theta,cs01,dv01,data_value,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaSns iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_fund_sensitivity_details_archive]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
, beta ,delta ,gamma ,vega ,theta,cs01,dv01,dataValue
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate, [grade_1],[grade_2] ,[grade_3],
beta ,delta ,gamma ,vega ,theta,cs01,dv01,data_value,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaSns iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_fund_stress_test]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
,portfolio_return ,percentage_long ,percentage_short , [start_date]
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate, [grade_1],[grade_2] ,[grade_3],
portfolio_return ,percentage_long ,percentage_short , [start_date],
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaSt iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_fund_stress_test_archive]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
,portfolio_return ,percentage_long ,percentage_short , [start_date]
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate, [grade_1],[grade_2] ,[grade_3],
portfolio_return ,percentage_long ,percentage_short , [start_date],
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaSt iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_counterparty_details]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
,number_count ,Equity ,LMV , SMV,Cash,OTE_MTM,Available_Liquidity,Required_Margin,Long_Exposure,Short_Exposure,data_value_text
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate, [grade_1],[grade_2] ,[grade_3]  ,
number_count ,Equity ,LMV , SMV,Cash,OTE_MTM,Available_Liquidity,Required_Margin,Long_Exposure,Short_Exposure,data_value_text,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaCp iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_counterparty_details_archive]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
,number_count ,Equity ,LMV , SMV,Cash,OTE_MTM,Available_Liquidity,Required_Margin,Long_Exposure,Short_Exposure,data_value_text
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate, [grade_1],[grade_2] ,[grade_3]  ,
number_count ,Equity ,LMV , SMV,Cash,OTE_MTM,Available_Liquidity,Required_Margin,Long_Exposure,Short_Exposure,data_value_text,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaCp iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_value_at_risk]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
,exposure_per ,var_per ,cvar_per ,data_value, data_value_text
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate,[grade_1],[grade_2] ,[grade_3] ,    
exposure_per ,var_per ,cvar_per ,data_value, data_value_text,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaRsk iop WITH (NOLOCK)
WHERE iop.id = 0

INSERT INTO [opera].[ivp_polaris_report_value_at_risk_archive]
([report_id],[fund_id],[fund_name],[section_id],[sub_section_id] ,[reporting_date],[grade_1],[grade_2] ,[grade_3]           
,exposure_per ,var_per ,cvar_per ,data_value, data_value_text
,[level] ,[is_user_edited],[loading_date],[knowledge_date],[created_on],[created_by] ,[modified_on],[modified_by],[is_active])
SELECT @ReportID, @FundID, @FundName, section_id, sub_section_id,@AsOfDate,[grade_1],[grade_2] ,[grade_3] ,    
exposure_per ,var_per ,cvar_per ,data_value, data_value_text,
iop.[level],1,GETDATE(), GETDATE(), GETDATE(), @UserName, GETDATE(), @UserName, 1
FROM #DataToBeInsertedForOperaRsk iop WITH (NOLOCK)
WHERE iop.id = 0


DROP TABLE #DataToBeInsertedForOperaNetted
DROP TABLE #DataToBeInsertedForOperaNonNetted
DROP TABLE #DataToBeInsertedForOperaFidv
DROP TABLE #DataToBeInsertedForOperaSns
DROP TABLE #DataToBeInsertedForOperaSt
DROP TABLE #DataToBeInsertedForOperaCp
DROP TABLE #DataToBeInsertedForOperaRsk
COMMIT TRAN TransactionOperaSave

END TRY

BEGIN CATCH
IF(@@TRANCOUNT > 0)
BEGIN
ROLLBACK TRAN TransactionOperaSave
END

END CATCH
END





