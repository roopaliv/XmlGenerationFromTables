USE [PolarisDev]
GO
/****** Object:  StoredProcedure [opera].[generate_xml] Script Date: 06/11/2013 21:00:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [opera].[generate_xml] 
(
@ReportID INT,
@FundID INT,
@AsOfDate DATETIME = NULL,
@TabId INT = NULL
)
/****** 
StoredProcedure [opera].[generate_xml] 21 Apr 2013 Roopali
To generate xml from data loading tables based on the configuration setup for the particular report
if the tab id is not passed full xml for all tabs is returned	

 
exec [opera].[generate_xml] 33,21, '2012-08-20', 6
exec [opera].[generate_xml] 75,29, '2012-08-23', 1
******/
     
AS    
BEGIN    

SET NOCOUNT ON; 

IF (@AsOfDate IS NULL)
BEGIN
SELECT @AsOfDate = report_date FROM opera.ivp_polaris_reports WITH (NOLOCK) WHERE id = @ReportID and is_active = 1
END

CREATE TABLE #DataValuesForOpera
(
[Table_Name] [varchar](1000) NULL,
[DataId] [int] NULL,
[netted_long] [numeric](36, 4) NULL,
[netted_short] [numeric](36, 4) NULL,
[long_positions] [int] NULL,
[short_positions] [int] NULL,
[non_netted_long] [numeric](36, 4) NULL,
[non_netted_short] [numeric](36, 4) NULL,
[values] [numeric](36, 4) NULL,
[dv_fidv] [numeric](36, 4) NULL,
[dvt_fidv] [varchar](200) NULL,
[Month_fidv] [numeric](36, 4) NULL,
[QTD_fidv] [numeric](36, 4) NULL,
[YTD_fidv] [numeric](36, 4) NULL,
[ITD_fidv] [numeric](36, 4) NULL,
[perc_fidv] [numeric](36, 4) NULL,
[amt_fidv] [numeric](36, 4) NULL,
[withPen_fidv] [numeric](36, 4) NULL,
[withoutPen_fidv] [numeric](36, 4) NULL,
[bet_sns] [numeric](36, 4) NULL,
[del_sns] [numeric](36, 4) NULL,
[gam_sns] [numeric](36, 4) NULL,
[veg_sns] [numeric](36, 4) NULL,
[thet_sns] [numeric](36, 4) NULL,
[cs01_sns] [numeric](36, 4) NULL,
[dv01_sns] [numeric](36, 4) NULL,
[dv_sns] [numeric](36, 4) NULL,
[pr_st] [numeric](36, 4) NULL,
[plng_st] [numeric](36, 4) NULL,
[psht_st] [numeric](36, 4) NULL,
[dt_st] [datetime] NULL,
[cnt_cp] [int] NULL,
[Eq_cp] [numeric](36, 4) NULL,
[LMV_cp] [numeric](36, 4) NULL,
[SMV_cp] [numeric](36, 4) NULL,
[Cash_cp] [numeric](36, 4) NULL,
[OTE_cp] [numeric](36, 4) NULL,
[Liq__cp] [numeric](36, 4) NULL,
[Mrg_cp] [numeric](36, 4) NULL,
[elng_cp] [numeric](36, 4) NULL,
[esht_cp] [numeric](36, 4) NULL,
[dvt_cp] [varchar](200) NULL,
[exp_rsk] [numeric](36, 4) NULL,
[vr_rsk] [numeric](36, 4) NULL,
[cvr_rsk] [numeric](36, 4) NULL,
[dv_rsk] [numeric](36, 4) NULL,
[dvt_rsk] [varchar](200) NULL,
[section_id] [int]  NULL,
[sub_section_id] [int]  NULL,
[grade_1] [varchar](200) NULL,
[grade_2] [varchar](200) NULL,
[grade_3] [varchar](200) NULL,	
[level] [int] NULL,
)

DECLARE @Insert AS VARCHAR(MAX)
SET @Insert = 'INSERT INTO #DataValuesForOpera (
[Table_Name],[DataId],
[netted_long] ,[netted_short] ,[long_positions] ,[short_positions] ,
[non_netted_long] ,[non_netted_short],[values],
[dv_fidv] ,[dvt_fidv] ,[Month_fidv] ,[QTD_fidv] ,[YTD_fidv] ,[ITD_fidv] ,[perc_fidv] ,[amt_fidv] ,[withPen_fidv] ,[withoutPen_fidv] ,
[bet_sns],[del_sns] ,[gam_sns] ,[veg_sns] ,[thet_sns] ,[cs01_sns] ,[dv01_sns] ,[dv_sns] ,
[pr_st] ,[plng_st] ,[psht_st] ,[dt_st] ,
[cnt_cp] ,[Eq_cp] ,[LMV_cp] ,[SMV_cp] ,[Cash_cp] ,[OTE_cp] ,[Liq__cp] ,[Mrg_cp] ,[elng_cp] ,[esht_cp] ,[dvt_cp] ,
[exp_rsk] ,[vr_rsk] ,[cvr_rsk] ,[dv_rsk],[dvt_rsk], 
[section_id],[sub_section_id],[grade_1],[grade_2],[grade_3],[level] )'
SET @Insert = CAST(@Insert AS VARCHAR(700)) +CAST(
(
CASE 
WHEN @TabId IN (2,3,4,5,6,7,12) THEN
'SELECT ''[opera].[ivp_polaris_report_non_netted_values]'', nnv.id, 
NULL,NULL,NULL,NULL,
nnv.[non_netted_long],nnv.[non_netted_short],[values],
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,NULL,
nnv.[section_id],nnv.[sub_section_id],nnv.[grade_1],nnv.[grade_2],nnv.[grade_3],nnv.[level]
FROM [opera].[ivp_polaris_report_non_netted_values] nnv WITH (NOLOCK)
WHERE nnv.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' and nnv.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' and nnv.is_active = 1 and nnv.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +'''
UNION ALL
SELECT ''[opera].[ivp_polaris_report_netted_values]'' , nv.id,
nv.[netted_long],nv.[netted_short],nv.[long_positions],nv.[short_positions],
NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,NULL,
nv.[section_id],nv.[sub_section_id],nv.[grade_1],nv.[grade_2],nv.[grade_3],nv.[level]
FROM [opera].[ivp_polaris_report_netted_values] nv WITH (NOLOCK)
WHERE nv.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND nv.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND nv.is_active = 1 AND nv.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))   +''''
WHEN @TabId = 1 THEN 
'SELECT ''[opera].[ivp_polaris_report_fund_investor_details]'', fidv.id,  
NULL,NULL,NULL,NULL,
NULL,NULL,NULL,
fidv.data_value, fidv.data_value_text,fidv.[Month], fidv.QTD, fidv.YTD, fidv.ITD, fidv.percentage, fidv.amount, fidv.with_penality,fidv.without_penality,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,NULL,
fidv.[section_id],fidv.[sub_section_id],fidv.[grade_1],fidv.[grade_2],fidv.[grade_3],fidv.[level]
FROM [opera].[ivp_polaris_report_fund_investor_details] fidv WITH (NOLOCK)
WHERE fidv.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND fidv.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND fidv.is_active = 1 AND fidv.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +''''
WHEN @TabId = 8 THEN 
'SELECT ''[opera].[ivp_polaris_report_value_at_risk]'', rsk.id,  
NULL,NULL,NULL,NULL,
NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
rsk.exposure_per ,rsk.var_per ,rsk.cvar_per ,rsk.data_value,rsk.data_value_text,
rsk.[section_id],rsk.[sub_section_id],rsk.[grade_1],rsk.[grade_2],rsk.[grade_3],rsk.[level]
FROM  [opera].[ivp_polaris_report_value_at_risk] rsk WITH (NOLOCK)
WHERE rsk.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND rsk.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND rsk.is_active = 1 AND rsk.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +''''
WHEN @TabId = 9 THEN 
'SELECT ''[opera].[ivp_polaris_report_fund_sensitivity_details]'', sns.id,  
NULL,NULL,NULL,NULL,
NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
sns.beta,sns.delta ,sns.gamma ,sns.vega ,sns.theta ,sns.cs01 ,sns.dv01 ,sns.dataValue,
NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,NULL,
sns.[section_id],sns.[sub_section_id],sns.[grade_1],sns.[grade_2],sns.[grade_3],sns.[level]
FROM  [opera].[ivp_polaris_report_fund_sensitivity_details] sns WITH (NOLOCK)
WHERE sns.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND sns.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND sns.is_active = 1 AND sns.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +''''
WHEN @TabId = 10 THEN 
'SELECT ''[opera].[ivp_polaris_report_fund_stress_test]'', st.id,  
NULL,NULL,NULL,NULL,
NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
st.portfolio_return ,st.percentage_long ,st.percentage_short ,st.[start_date] ,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,NULL,
st.[section_id],st.[sub_section_id],st.[grade_1],st.[grade_2],st.[grade_3],st.[level]
FROM  [opera].[ivp_polaris_report_fund_stress_test] st WITH (NOLOCK)
WHERE st.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND st.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND st.is_active = 1 AND st.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +''''
WHEN @TabId = 11 THEN 
'SELECT ''[opera].[ivp_polaris_report_counterparty_details]'', cp.id,  
NULL,NULL,NULL,NULL,
NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,
cp.number_count ,cp.Equity ,cp.LMV ,cp.SMV ,cp.Cash ,cp.OTE_MTM ,cp.Available_Liquidity ,cp.Required_Margin ,cp.Long_Exposure ,cp.Short_Exposure ,cp.data_value_text ,
NULL ,NULL ,NULL ,NULL,NULL,
cp.[section_id],cp.[sub_section_id],cp.[grade_1],cp.[grade_2],cp.[grade_3],cp.[level]
FROM  [opera].[ivp_polaris_report_counterparty_details] cp WITH (NOLOCK)
WHERE cp.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND cp.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND cp.is_active = 1 AND cp.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +''''
ELSE 
'SELECT ''[opera].[ivp_polaris_report_non_netted_values]'', nnv.id, 
NULL,NULL,NULL,NULL,
nnv.[non_netted_long],nnv.[non_netted_short],[values],
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,NULL,
nnv.[section_id],nnv.[sub_section_id],nnv.[grade_1],nnv.[grade_2],nnv.[grade_3],nnv.[level]
FROM [opera].[ivp_polaris_report_non_netted_values] nnv WITH (NOLOCK)
WHERE nnv.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' and nnv.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' and nnv.is_active = 1 and nnv.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +'''
UNION ALL
SELECT ''[opera].[ivp_polaris_report_netted_values]'' , nv.id,
nv.[netted_long],nv.[netted_short],nv.[long_positions],nv.[short_positions],
NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,NULL,
nv.[section_id],nv.[sub_section_id],nv.[grade_1],nv.[grade_2],nv.[grade_3],nv.[level]
FROM [opera].[ivp_polaris_report_netted_values] nv WITH (NOLOCK)
WHERE nv.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND nv.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND nv.is_active = 1 AND nv.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +'''
UNION ALL
SELECT ''[opera].[ivp_polaris_report_fund_investor_details]'', fidv.id,  
NULL,NULL,NULL,NULL,
NULL,NULL,NULL,
fidv.data_value, fidv.data_value_text,fidv.[Month], fidv.QTD, fidv.YTD, fidv.ITD, fidv.percentage, fidv.amount, fidv.with_penality,fidv.without_penality,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,NULL,
fidv.[section_id],fidv.[sub_section_id],fidv.[grade_1],fidv.[grade_2],fidv.[grade_3],fidv.[level]
FROM [opera].[ivp_polaris_report_fund_investor_details] fidv WITH (NOLOCK)
WHERE fidv.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND fidv.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND fidv.is_active = 1 AND fidv.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +'''
UNION ALL
SELECT ''[opera].[ivp_polaris_report_fund_sensitivity_details]'', sns.id,  
NULL,NULL,NULL,NULL,
NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
sns.beta,sns.delta ,sns.gamma ,sns.vega ,sns.theta ,sns.cs01 ,sns.dv01 ,sns.dataValue,
NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,NULL,
sns.[section_id],sns.[sub_section_id],sns.[grade_1],sns.[grade_2],sns.[grade_3],sns.[level]
FROM  [opera].[ivp_polaris_report_fund_sensitivity_details] sns WITH (NOLOCK)
WHERE sns.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND sns.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND sns.is_active = 1 AND sns.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +'''
UNION ALL
SELECT ''[opera].[ivp_polaris_report_fund_stress_test]'', st.id,  
NULL,NULL,NULL,NULL,
NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
st.portfolio_return ,st.percentage_long ,st.percentage_short ,st.[start_date] ,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,NULL,
st.[section_id],st.[sub_section_id],st.[grade_1],st.[grade_2],st.[grade_3],st.[level]
FROM  [opera].[ivp_polaris_report_fund_stress_test] st WITH (NOLOCK)
WHERE st.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND st.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND st.is_active = 1 AND st.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +'''
UNION ALL
SELECT ''[opera].[ivp_polaris_report_counterparty_details]'', cp.id,  
NULL,NULL,NULL,NULL,
NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,
cp.number_count ,cp.Equity ,cp.LMV ,cp.SMV ,cp.Cash ,cp.OTE_MTM ,cp.Available_Liquidity ,cp.Required_Margin ,cp.Long_Exposure ,cp.Short_Exposure ,cp.data_value_text ,
NULL ,NULL ,NULL ,NULL,NULL,
cp.[section_id],cp.[sub_section_id],cp.[grade_1],cp.[grade_2],cp.[grade_3],cp.[level]
FROM  [opera].[ivp_polaris_report_counterparty_details] cp WITH (NOLOCK)
WHERE cp.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND cp.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND cp.is_active = 1 AND cp.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +'''
UNION ALL
SELECT ''[opera].[ivp_polaris_report_value_at_risk]'', rsk.id,  
NULL,NULL,NULL,NULL,
NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
NULL ,NULL ,NULL ,NULL,
NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
rsk.exposure_per ,rsk.var_per ,rsk.cvar_per ,rsk.data_value,rsk.data_value_text,
rsk.[section_id],rsk.[sub_section_id],rsk.[grade_1],rsk.[grade_2],rsk.[grade_3],rsk.[level]
FROM  [opera].[ivp_polaris_report_value_at_risk] rsk WITH (NOLOCK)
WHERE rsk.Report_id = '+ CAST(@ReportID AS VARCHAR(200)) +' AND rsk.fund_id = '+ CAST(@FundID AS VARCHAR(200)) +' AND rsk.is_active = 1 AND rsk.reporting_date = '''+ CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) +'-'+ RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) +'-'+ RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX))  +''''
END
) AS VARCHAR(MAX))
PRINT @Insert
exec(@Insert)

IF EXISTS (SELECT * FROM #DataValuesForOpera)
BEGIN
SELECT t.section_name AS '@title',t.section_description AS '@header',t.id AS '@id',
(
	SELECT   s.sub_section_name AS '@title',s.id AS '@id',
	 (
		SELECT sh.sub_section_header_row AS '@row', sh.sub_section_header_colspan AS '@colspan',sh.sub_section_header_rowspan AS '@rowspan', sh.sub_section_header_index AS '@index' ,sh.id AS '@id',
		(SELECT sh.sub_section_header_inner_xml WHERE sh.[is_active] =1 and sh.sub_section_id =  s.id) 
		FROM [opera].[ivp_polaris_cfg_sub_section_header] sh WITH (NOLOCK)
		WHERE sh.[is_active] =1 AND sh.sub_section_id= s.id
		ORDER BY sh.[sort_order]
		FOR  XML PATH('Header'), TYPE
	 ),
	 (
		SELECT  sd.sub_section_data_type AS '@type', sd.sub_section_data_title AS '@title', sd.sub_section_data_format AS '@format', sd.id AS '@id', sd.sub_section_data_headerindex AS '@headerindex',
		ISNULL(sdv.DataId,0) as '@DataId',							
		sd.sub_section_data_inner_xml  AS '@col' ,
		(
			SELECT CASE sd.sub_section_data_inner_xml 
			WHEN 'netted_long' THEN CAST(sdv.netted_long AS VARCHAR(MAX))
			WHEN 'netted_short' THEN CAST(sdv.netted_short AS VARCHAR(MAX))
			WHEN 'long_positions' THEN CAST(sdv.long_positions AS VARCHAR(MAX))
			WHEN 'short_positions' THEN CAST(sdv.short_positions AS VARCHAR(MAX))
			WHEN 'non_netted_long' THEN CAST(sdv.non_netted_long AS VARCHAR(MAX))
			WHEN 'non_netted_short' THEN CAST(sdv.non_netted_short AS VARCHAR(MAX))
			WHEN 'values' THEN CAST(sdv.[values] AS VARCHAR(MAX))
			WHEN 'RepDate' THEN CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
			WHEN 'dv_fidv' THEN CAST(sdv.dv_fidv AS VARCHAR(MAX))
			WHEN 'dvt_fidv' THEN CAST(sdv.dvt_fidv AS VARCHAR(MAX))
			WHEN 'Month_fidv' THEN CAST(sdv.Month_fidv AS VARCHAR(MAX))
			WHEN 'QTD_fidv' THEN CAST(sdv.QTD_fidv AS VARCHAR(MAX))
			WHEN 'YTD_fidv' THEN CAST(sdv.YTD_fidv AS VARCHAR(MAX))
			WHEN 'ITD_fidv' THEN CAST(sdv.ITD_fidv AS VARCHAR(MAX))
			WHEN 'perc_fidv' THEN CAST(sdv.perc_fidv AS VARCHAR(MAX))
			WHEN 'amt_fidv' THEN CAST(sdv.amt_fidv AS VARCHAR(MAX))
			WHEN 'withPen_fidv' THEN CAST(sdv.withPen_fidv AS VARCHAR(MAX))
			WHEN 'withoutPen_fidv' THEN CAST(sdv.withoutPen_fidv AS VARCHAR(MAX))	
			WHEN 'bet_sns'  THEN CAST(sdv.bet_sns AS VARCHAR(MAX))
			WHEN 'del_sns'  THEN CAST(sdv.del_sns AS VARCHAR(MAX))
			WHEN 'gam_sns'  THEN CAST(sdv.gam_sns AS VARCHAR(MAX))
			WHEN 'veg_sns'  THEN CAST(sdv.veg_sns AS VARCHAR(MAX))
			WHEN 'thet_sns'  THEN CAST(sdv.thet_sns AS VARCHAR(MAX))
			WHEN 'cs01_sns'  THEN CAST(sdv.cs01_sns AS VARCHAR(MAX))
			WHEN 'dv01_sns'  THEN CAST(sdv.dv01_sns AS VARCHAR(MAX))
			WHEN 'dv_sns'  THEN CAST(sdv.dv_sns AS VARCHAR(MAX))
			WHEN 'pr_st'  THEN CAST(sdv.pr_st AS VARCHAR(MAX))
			WHEN 'plng_st'  THEN CAST(sdv.plng_st AS VARCHAR(MAX))
			WHEN 'psht_st'  THEN CAST(sdv.psht_st AS VARCHAR(MAX))
			WHEN 'dt_st'  THEN CAST(CAST(YEAR(sdv.dt_st) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(sdv.dt_st) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(sdv.dt_st) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
			WHEN 'cnt_cp'  THEN CAST(sdv.cnt_cp AS VARCHAR(MAX))
			WHEN 'Eq_cp'  THEN CAST(sdv.Eq_cp AS VARCHAR(MAX))
			WHEN 'LMV_cp'  THEN CAST(sdv.LMV_cp AS VARCHAR(MAX))
			WHEN 'SMV_cp'  THEN CAST(sdv.SMV_cp AS VARCHAR(MAX))
			WHEN 'Cash_cp'  THEN CAST(sdv.Cash_cp AS VARCHAR(MAX))
			WHEN 'OTE_cp'  THEN CAST(sdv.OTE_cp AS VARCHAR(MAX))
			WHEN 'Liq__cp'  THEN CAST(sdv.Liq__cp AS VARCHAR(MAX))
			WHEN 'Mrg_cp'  THEN CAST(sdv.Mrg_cp AS VARCHAR(MAX))
			WHEN 'elng_cp'  THEN CAST(sdv.elng_cp AS VARCHAR(MAX))
			WHEN 'esht_cp'  THEN CAST(sdv.esht_cp AS VARCHAR(MAX))
			WHEN 'dvt_cp'  THEN CAST(sdv.dvt_cp AS VARCHAR(MAX))
			WHEN 'exp_rsk'  THEN CAST(sdv.exp_rsk AS VARCHAR(MAX))
			WHEN 'vr_rsk'  THEN CAST(sdv.vr_rsk AS VARCHAR(MAX))
			WHEN 'cvr_rsk'  THEN CAST(sdv.cvr_rsk AS VARCHAR(MAX))
			WHEN 'dv_rsk'  THEN CAST(sdv.dv_rsk AS VARCHAR(MAX))
			WHEN 'dvt_rsk' THEN CAST(sdv.dvt_rsk AS VARCHAR(MAX))
			WHEN 'today' THEN CAST(CAST(YEAR(GETDATE()) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(GETDATE()) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(GETDATE()) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
			ELSE  sd.sub_section_data_inner_xml
			END 		 
		 )
		 FROM [opera].[ivp_polaris_cfg_sub_section_data] sd WITH (NOLOCK)
		 LEFT OUTER JOIN #DataValuesForOpera sdv  WITH (NOLOCK)
		 on sdv.sub_section_id = s.id AND sdv.section_id = t.id 
		 AND sdv.grade_1 IS NULL AND sdv.grade_2 IS NULL AND sdv.grade_3 IS NULL
		 AND sdv.Table_Name =	(
								CASE 
									WHEN sd.sub_section_data_inner_xml IN ('non_netted_long','non_netted_short','values') 
									THEN '[opera].[ivp_polaris_report_non_netted_values]'
									WHEN sd.sub_section_data_inner_xml IN ('netted_long','netted_short','long_positions','short_positions') 
									THEN '[opera].[ivp_polaris_report_netted_values]'
									WHEN sd.sub_section_data_inner_xml IN ('dv_fidv' , 'dvt_fidv' , 'Month_fidv' , 'QTD_fidv' , 'YTD_fidv' , 'ITD_fidv' , 'perc_fidv' , 'amt_fidv' , 'withPen_fidv' ,'withoutPen_fidv') 
									THEN '[opera].[ivp_polaris_report_fund_investor_details]'
									WHEN sd.sub_section_data_inner_xml IN ('bet_sns','del_sns','gam_sns','veg_sns','thet_sns','cs01_sns','dv01_sns','dv_sns') 
									THEN '[opera].[ivp_polaris_report_fund_sensitivity_details]'
									WHEN sd.sub_section_data_inner_xml IN ('pr_st','plng_st','psht_st','dt_st') 
									THEN '[opera].[ivp_polaris_report_fund_stress_test]'
									WHEN sd.sub_section_data_inner_xml IN ('cnt_cp' ,'Eq_cp','LMV_cp','SMV_cp','Cash_cp','OTE_cp','Liq__cp','Mrg_cp','elng_cp','esht_cp','dvt_cp') 
									THEN '[opera].[ivp_polaris_report_counterparty_details]'
									WHEN sd.sub_section_data_inner_xml IN ('exp_rsk','vr_rsk','cvr_rsk','dv_rsk','dvt_rsk') 
									THEN '[opera].[ivp_polaris_report_value_at_risk]'
								END	
								)
		 WHERE sd .[is_active]=1 AND sd.sub_section_id =  s.id
		 ORDER BY sd.[sort_order]
		 FOR XML PATH('Data'), TYPE
	 ),
	
	 (
		 SELECT lone.grade_one_title AS '@title',lone.id AS '@id', CASE  COUNT(distinct g2rSpan.id) WHEN 0 THEN NULL ELSE (COUNT(distinct g2rSpan.id)+ COUNT(distinct g3rSpan.id) + 1) END AS '@rowspans',
		 (
			SELECT ldone.grade_one_data_type AS '@type',  ldone.grade_one_data_title AS '@title',  ldone.grade_one_data_format AS '@format', ldone.grade_one_data_headerindex AS '@headerindex', ldone.id AS '@id',
			ISNULL(ldonev.DataId,0) AS '@DataId',
			ldone.grade_one_data_inner_xml AS '@col' ,
			(
				SELECT CASE ldone.grade_one_data_inner_xml 
				WHEN 'netted_long' THEN CAST(ldonev.netted_long AS VARCHAR(MAX))
				WHEN 'netted_short' THEN CAST(ldonev.netted_short AS VARCHAR(MAX))
				WHEN 'long_positions' THEN CAST(ldonev.long_positions AS VARCHAR(MAX))
				WHEN 'short_positions' THEN CAST(ldonev.short_positions AS VARCHAR(MAX))
				WHEN 'non_netted_long' THEN CAST(ldonev.non_netted_long AS VARCHAR(MAX))
				WHEN 'non_netted_short' THEN CAST(ldonev.non_netted_short AS VARCHAR(MAX))
				WHEN 'values' THEN CAST(ldonev.[values] AS VARCHAR(MAX))
				WHEN 'RepDate' THEN CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
				WHEN 'dv_fidv' THEN CAST(ldonev.dv_fidv AS VARCHAR(MAX))
				WHEN 'dvt_fidv' THEN CAST(ldonev.dvt_fidv AS VARCHAR(MAX))
				WHEN 'Month_fidv' THEN CAST(ldonev.Month_fidv AS VARCHAR(MAX))
				WHEN 'QTD_fidv' THEN CAST(ldonev.QTD_fidv AS VARCHAR(MAX))
				WHEN 'YTD_fidv' THEN CAST(ldonev.YTD_fidv AS VARCHAR(MAX))
				WHEN 'ITD_fidv' THEN CAST(ldonev.ITD_fidv AS VARCHAR(MAX))
				WHEN 'perc_fidv' THEN CAST(ldonev.perc_fidv AS VARCHAR(MAX))
				WHEN 'amt_fidv' THEN CAST(ldonev.amt_fidv AS VARCHAR(MAX))
				WHEN 'withPen_fidv' THEN CAST(ldonev.withPen_fidv AS VARCHAR(MAX))
				WHEN 'withoutPen_fidv' THEN CAST(ldonev.withoutPen_fidv AS VARCHAR(MAX))	
				WHEN 'bet_sns'  THEN CAST(ldonev.bet_sns AS VARCHAR(MAX))
				WHEN 'del_sns'  THEN CAST(ldonev.del_sns AS VARCHAR(MAX))
				WHEN 'gam_sns'  THEN CAST(ldonev.gam_sns AS VARCHAR(MAX))
				WHEN 'veg_sns'  THEN CAST(ldonev.veg_sns AS VARCHAR(MAX))
				WHEN 'thet_sns'  THEN CAST(ldonev.thet_sns AS VARCHAR(MAX))
				WHEN 'cs01_sns'  THEN CAST(ldonev.cs01_sns AS VARCHAR(MAX))
				WHEN 'dv01_sns'  THEN CAST(ldonev.dv01_sns AS VARCHAR(MAX))
				WHEN 'dv_sns'  THEN CAST(ldonev.dv_sns AS VARCHAR(MAX))
				WHEN 'pr_st'  THEN CAST(ldonev.pr_st AS VARCHAR(MAX))
				WHEN 'plng_st'  THEN CAST(ldonev.plng_st AS VARCHAR(MAX))
				WHEN 'psht_st'  THEN CAST(ldonev.psht_st AS VARCHAR(MAX))
				WHEN 'dt_st'  THEN CAST(CAST(YEAR(ldonev.dt_st) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(ldonev.dt_st) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(ldonev.dt_st) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
				WHEN 'cnt_cp'  THEN CAST(ldonev.cnt_cp AS VARCHAR(MAX))
				WHEN 'Eq_cp'  THEN CAST(ldonev.Eq_cp AS VARCHAR(MAX))
				WHEN 'LMV_cp'  THEN CAST(ldonev.LMV_cp AS VARCHAR(MAX))
				WHEN 'SMV_cp'  THEN CAST(ldonev.SMV_cp AS VARCHAR(MAX))
				WHEN 'Cash_cp'  THEN CAST(ldonev.Cash_cp AS VARCHAR(MAX))
				WHEN 'OTE_cp'  THEN CAST(ldonev.OTE_cp AS VARCHAR(MAX))
				WHEN 'Liq__cp'  THEN CAST(ldonev.Liq__cp AS VARCHAR(MAX))
				WHEN 'Mrg_cp'  THEN CAST(ldonev.Mrg_cp AS VARCHAR(MAX))
				WHEN 'elng_cp'  THEN CAST(ldonev.elng_cp AS VARCHAR(MAX))
				WHEN 'esht_cp'  THEN CAST(ldonev.esht_cp AS VARCHAR(MAX))
				WHEN 'dvt_cp'  THEN CAST(ldonev.dvt_cp AS VARCHAR(MAX))
				WHEN 'exp_rsk'  THEN CAST(ldonev.exp_rsk AS VARCHAR(MAX))
				WHEN 'vr_rsk'  THEN CAST(ldonev.vr_rsk AS VARCHAR(MAX))
				WHEN 'cvr_rsk'  THEN CAST(ldonev.cvr_rsk AS VARCHAR(MAX))
				WHEN 'dv_rsk'  THEN CAST(ldonev.dv_rsk AS VARCHAR(MAX))
				WHEN 'dvt_rsk' THEN CAST(ldonev.dvt_rsk AS VARCHAR(MAX))	
				WHEN 'today' THEN CAST(CAST(YEAR(GETDATE()) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(GETDATE()) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(GETDATE()) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
				ELSE  grade_one_data_inner_xml
				END 
			)
			FROM [opera].[ivp_polaris_cfg_grade_one_data] ldone WITH (NOLOCK)
			LEFT OUTER JOIN #DataValuesForOpera ldonev  WITH (NOLOCK)
			on ldonev.sub_section_id = s.id AND ldonev.section_id = t.id AND ldonev.grade_1 = lone.grade_one_title 
			AND ldonev.grade_2 IS NULL AND ldonev.grade_3 IS NULL	 
			AND ldonev.Table_Name = (	
									CASE 
										WHEN ldone.grade_one_data_inner_xml IN ('non_netted_long','non_netted_short','values') 
										THEN '[opera].[ivp_polaris_report_non_netted_values]'
										WHEN ldone.grade_one_data_inner_xml IN ('netted_long','netted_short','long_positions','short_positions') 
										THEN '[opera].[ivp_polaris_report_netted_values]'
										WHEN ldone.grade_one_data_inner_xml IN ('dv_fidv' , 'dvt_fidv' , 'Month_fidv' , 'QTD_fidv' , 'YTD_fidv' , 'ITD_fidv' , 'perc_fidv' , 'amt_fidv' , 'withPen_fidv' ,'withoutPen_fidv') 
										THEN '[opera].[ivp_polaris_report_fund_investor_details]'
										WHEN ldone.grade_one_data_inner_xml IN ('bet_sns','del_sns','gam_sns','veg_sns','thet_sns','cs01_sns','dv01_sns','dv_sns') 
										THEN '[opera].[ivp_polaris_report_fund_sensitivity_details]'
										WHEN ldone.grade_one_data_inner_xml IN ('pr_st','plng_st','psht_st','dt_st') 
										THEN '[opera].[ivp_polaris_report_fund_stress_test]'
										WHEN ldone.grade_one_data_inner_xml IN ('cnt_cp' ,'Eq_cp','LMV_cp','SMV_cp','Cash_cp','OTE_cp','Liq__cp','Mrg_cp','elng_cp','esht_cp','dvt_cp') 
										THEN '[opera].[ivp_polaris_report_counterparty_details]'
										WHEN ldone.grade_one_data_inner_xml IN ('exp_rsk','vr_rsk','cvr_rsk','dv_rsk','dvt_rsk') 
										THEN '[opera].[ivp_polaris_report_value_at_risk]'
									END	
									)	 
			WHERE ldone .[is_active]=1 AND ldone.grade_one_id =  lone.id
			ORDER BY ldone.[sort_order]
			FOR XML PATH('Data'), TYPE
		 ),
		  CASE
			WHEN sr.sub_section_grade_id >=2 THEN
			(
			SELECT ltwo.grade_two_title AS '@title',ltwo.id AS '@id',CASE  COUNT(g3rSpanInner.id) WHEN 0 THEN NULL ELSE (COUNT(distinct g3rSpanInner.id) + 1) END AS '@rowspans',
			 (
				SELECT  ldtwo.grade_two_data_type AS '@type',  ldtwo.grade_two_data_title AS '@title',  ldtwo.grade_two_data_format AS '@format', ldtwo.grade_two_data_headerindex AS '@headerindex', ldtwo.id AS '@id',			
				ISNULL(ldtwov.DataId,0) AS '@DataId',
				ldtwo.grade_two_data_inner_xml  AS '@col' ,
				(
					SELECT CASE ldtwo.grade_two_data_inner_xml 
					WHEN 'netted_long' THEN CAST(ldtwov.netted_long AS VARCHAR(MAX))
					WHEN 'netted_short' THEN CAST(ldtwov.netted_short AS VARCHAR(MAX))
					WHEN 'long_positions' THEN CAST(ldtwov.long_positions AS VARCHAR(MAX))
					WHEN 'short_positions' THEN CAST(ldtwov.short_positions AS VARCHAR(MAX))
					WHEN 'non_netted_long' THEN CAST(ldtwov.non_netted_long AS VARCHAR(MAX))
					WHEN 'non_netted_short' THEN CAST(ldtwov.non_netted_short AS VARCHAR(MAX))
					WHEN 'values' THEN CAST(ldtwov.[values] AS VARCHAR(MAX))
					WHEN 'RepDate' THEN CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
					WHEN 'dv_fidv' THEN CAST(ldtwov.dv_fidv AS VARCHAR(MAX))
					WHEN 'dvt_fidv' THEN CAST(ldtwov.dvt_fidv AS VARCHAR(MAX))
					WHEN 'Month_fidv' THEN CAST(ldtwov.Month_fidv AS VARCHAR(MAX))
					WHEN 'QTD_fidv' THEN CAST(ldtwov.QTD_fidv AS VARCHAR(MAX))
					WHEN 'YTD_fidv' THEN CAST(ldtwov.YTD_fidv AS VARCHAR(MAX))
					WHEN 'ITD_fidv' THEN CAST(ldtwov.ITD_fidv AS VARCHAR(MAX))
					WHEN 'perc_fidv' THEN CAST(ldtwov.perc_fidv AS VARCHAR(MAX))
					WHEN 'amt_fidv' THEN CAST(ldtwov.amt_fidv AS VARCHAR(MAX))
					WHEN 'withPen_fidv' THEN CAST(ldtwov.withPen_fidv AS VARCHAR(MAX))
					WHEN 'withoutPen_fidv' THEN CAST(ldtwov.withoutPen_fidv AS VARCHAR(MAX))	
					WHEN 'bet_sns'  THEN CAST(ldtwov.bet_sns AS VARCHAR(MAX))
					WHEN 'del_sns'  THEN CAST(ldtwov.del_sns AS VARCHAR(MAX))
					WHEN 'gam_sns'  THEN CAST(ldtwov.gam_sns AS VARCHAR(MAX))
					WHEN 'veg_sns'  THEN CAST(ldtwov.veg_sns AS VARCHAR(MAX))
					WHEN 'thet_sns'  THEN CAST(ldtwov.thet_sns AS VARCHAR(MAX))
					WHEN 'cs01_sns'  THEN CAST(ldtwov.cs01_sns AS VARCHAR(MAX))
					WHEN 'dv01_sns'  THEN CAST(ldtwov.dv01_sns AS VARCHAR(MAX))
					WHEN 'dv_sns'  THEN CAST(ldtwov.dv_sns AS VARCHAR(MAX))
					WHEN 'pr_st'  THEN CAST(ldtwov.pr_st AS VARCHAR(MAX))
					WHEN 'plng_st'  THEN CAST(ldtwov.plng_st AS VARCHAR(MAX))
					WHEN 'psht_st'  THEN CAST(ldtwov.psht_st AS VARCHAR(MAX))
					WHEN 'dt_st'  THEN CAST(CAST(YEAR(ldtwov.dt_st) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(ldtwov.dt_st) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(ldtwov.dt_st) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
					WHEN 'cnt_cp'  THEN CAST(ldtwov.cnt_cp AS VARCHAR(MAX))
					WHEN 'Eq_cp'  THEN CAST(ldtwov.Eq_cp AS VARCHAR(MAX))
					WHEN 'LMV_cp'  THEN CAST(ldtwov.LMV_cp AS VARCHAR(MAX))
					WHEN 'SMV_cp'  THEN CAST(ldtwov.SMV_cp AS VARCHAR(MAX))
					WHEN 'Cash_cp'  THEN CAST(ldtwov.Cash_cp AS VARCHAR(MAX))
					WHEN 'OTE_cp'  THEN CAST(ldtwov.OTE_cp AS VARCHAR(MAX))
					WHEN 'Liq__cp'  THEN CAST(ldtwov.Liq__cp AS VARCHAR(MAX))
					WHEN 'Mrg_cp'  THEN CAST(ldtwov.Mrg_cp AS VARCHAR(MAX))
					WHEN 'elng_cp'  THEN CAST(ldtwov.elng_cp AS VARCHAR(MAX))
					WHEN 'esht_cp'  THEN CAST(ldtwov.esht_cp AS VARCHAR(MAX))
					WHEN 'dvt_cp'  THEN CAST(ldtwov.dvt_cp AS VARCHAR(MAX))
					WHEN 'exp_rsk'  THEN CAST(ldtwov.exp_rsk AS VARCHAR(MAX))
					WHEN 'vr_rsk'  THEN CAST(ldtwov.vr_rsk AS VARCHAR(MAX))
					WHEN 'cvr_rsk'  THEN CAST(ldtwov.cvr_rsk AS VARCHAR(MAX))
					WHEN 'dv_rsk'  THEN CAST(ldtwov.dv_rsk AS VARCHAR(MAX))
					WHEN 'dvt_rsk' THEN CAST(ldtwov.dvt_rsk AS VARCHAR(MAX))	
					WHEN 'today' THEN CAST(CAST(YEAR(GETDATE()) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(GETDATE()) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(GETDATE()) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
					ELSE   grade_two_data_inner_xml
					END 
				)
				FROM [opera].[ivp_polaris_cfg_grade_two_data] ldtwo WITH (NOLOCK)
				LEFT OUTER JOIN #DataValuesForOpera ldtwov  WITH (NOLOCK)
				on ldtwov.sub_section_id = s.id AND ldtwov.section_id = t.id AND ldtwov.grade_1 = lone.grade_one_title 
				AND ldtwov.grade_2 = ltwo.grade_two_title AND ldtwov.grade_3 IS NULL
				AND ldtwov.Table_Name = (	
										CASE 
											WHEN ldtwo.grade_two_data_inner_xml IN ('non_netted_long','non_netted_short','values') 
											THEN '[opera].[ivp_polaris_report_non_netted_values]'
											WHEN ldtwo.grade_two_data_inner_xml IN ('netted_long','netted_short','long_positions','short_positions') 
											THEN '[opera].[ivp_polaris_report_netted_values]'
											WHEN ldtwo.grade_two_data_inner_xml IN ('dv_fidv' , 'dvt_fidv' , 'Month_fidv' , 'QTD_fidv' , 'YTD_fidv' , 'ITD_fidv' , 'perc_fidv' , 'amt_fidv' , 'withPen_fidv' ,'withoutPen_fidv') 
											THEN '[opera].[ivp_polaris_report_fund_investor_details]'
											WHEN ldtwo.grade_two_data_inner_xml IN ('bet_sns','del_sns','gam_sns','veg_sns','thet_sns','cs01_sns','dv01_sns','dv_sns') 
											THEN '[opera].[ivp_polaris_report_fund_sensitivity_details]'
											WHEN ldtwo.grade_two_data_inner_xml IN ('pr_st','plng_st','psht_st','dt_st') 
											THEN '[opera].[ivp_polaris_report_fund_stress_test]'
											WHEN ldtwo.grade_two_data_inner_xml IN ('cnt_cp' ,'Eq_cp','LMV_cp','SMV_cp','Cash_cp','OTE_cp','Liq__cp','Mrg_cp','elng_cp','esht_cp','dvt_cp') 
											THEN '[opera].[ivp_polaris_report_counterparty_details]'
											WHEN ldtwo.grade_two_data_inner_xml IN ('exp_rsk','vr_rsk','cvr_rsk','dv_rsk','dvt_rsk') 
											THEN '[opera].[ivp_polaris_report_value_at_risk]'
										END	
										)	 	 
				WHERE ldtwo .[is_active]=1 AND ldtwo.grade_two_id =  ltwo.id
				ORDER BY ldtwo.[sort_order]
				FOR XML PATH('Data'), TYPE
			 ),
			 CASE
			 WHEN sr.sub_section_grade_id = 3 THEN
			 (
				 SELECT lthree.grade_three_title AS '@title',lthree.id AS '@id',
				 (
					SELECT  ldthree.grade_three_data_type AS '@type',  ldthree.grade_three_data_title AS '@title',  ldthree.grade_three_data_format AS '@format', ldthree.grade_three_data_headerindex AS '@headerindex',ldthree.id AS '@id', 
					ISNULL(ldthreev.DataId,0) AS '@DataId',
					ldthree.grade_three_data_inner_xml AS '@col' ,
					(
						SELECT CASE ldthree.grade_three_data_inner_xml 
						WHEN 'netted_long' THEN CAST(ldthreev.netted_long AS VARCHAR(MAX))
						WHEN 'netted_short' THEN CAST(ldthreev.netted_short AS VARCHAR(MAX))
						WHEN 'long_positions' THEN CAST(ldthreev.long_positions AS VARCHAR(MAX))
						WHEN 'short_positions' THEN CAST(ldthreev.short_positions AS VARCHAR(MAX))
						WHEN 'non_netted_long' THEN CAST(ldthreev.non_netted_long AS VARCHAR(MAX))
						WHEN 'non_netted_short' THEN CAST(ldthreev.non_netted_short AS VARCHAR(MAX))
						WHEN 'values' THEN CAST(ldthreev.[values] AS VARCHAR(MAX))
						WHEN 'RepDate' THEN CAST(CAST(YEAR(@AsOfDate) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(@AsOfDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(@AsOfDate) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
						WHEN 'dv_fidv' THEN CAST(ldthreev.dv_fidv AS VARCHAR(MAX))
						WHEN 'dvt_fidv' THEN CAST(ldthreev.dvt_fidv AS VARCHAR(MAX))
						WHEN 'Month_fidv' THEN CAST(ldthreev.Month_fidv AS VARCHAR(MAX))
						WHEN 'QTD_fidv' THEN CAST(ldthreev.QTD_fidv AS VARCHAR(MAX))
						WHEN 'YTD_fidv' THEN CAST(ldthreev.YTD_fidv AS VARCHAR(MAX))
						WHEN 'ITD_fidv' THEN CAST(ldthreev.ITD_fidv AS VARCHAR(MAX))
						WHEN 'perc_fidv' THEN CAST(ldthreev.perc_fidv AS VARCHAR(MAX))
						WHEN 'amt_fidv' THEN CAST(ldthreev.amt_fidv AS VARCHAR(MAX))
						WHEN 'withPen_fidv' THEN CAST(ldthreev.withPen_fidv AS VARCHAR(MAX))
						WHEN 'withoutPen_fidv' THEN CAST(ldthreev.withoutPen_fidv AS VARCHAR(MAX))
						WHEN 'bet_sns'  THEN CAST(ldthreev.bet_sns AS VARCHAR(MAX))
						WHEN 'del_sns'  THEN CAST(ldthreev.del_sns AS VARCHAR(MAX))
						WHEN 'gam_sns'  THEN CAST(ldthreev.gam_sns AS VARCHAR(MAX))
						WHEN 'veg_sns'  THEN CAST(ldthreev.veg_sns AS VARCHAR(MAX))
						WHEN 'thet_sns'  THEN CAST(ldthreev.thet_sns AS VARCHAR(MAX))
						WHEN 'cs01_sns'  THEN CAST(ldthreev.cs01_sns AS VARCHAR(MAX))
						WHEN 'dv01_sns'  THEN CAST(ldthreev.dv01_sns AS VARCHAR(MAX))
						WHEN 'dv_sns'  THEN CAST(ldthreev.dv_sns AS VARCHAR(MAX))
						WHEN 'pr_st'  THEN CAST(ldthreev.pr_st AS VARCHAR(MAX))
						WHEN 'plng_st'  THEN CAST(ldthreev.plng_st AS VARCHAR(MAX))
						WHEN 'psht_st'  THEN CAST(ldthreev.psht_st AS VARCHAR(MAX))
						WHEN 'dt_st'  THEN CAST(CAST(YEAR(ldthreev.dt_st) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(ldthreev.dt_st) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(ldthreev.dt_st) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
						WHEN 'cnt_cp'  THEN CAST(ldthreev.cnt_cp AS VARCHAR(MAX))
						WHEN 'Eq_cp'  THEN CAST(ldthreev.Eq_cp AS VARCHAR(MAX))
						WHEN 'LMV_cp'  THEN CAST(ldthreev.LMV_cp AS VARCHAR(MAX))
						WHEN 'SMV_cp'  THEN CAST(ldthreev.SMV_cp AS VARCHAR(MAX))
						WHEN 'Cash_cp'  THEN CAST(ldthreev.Cash_cp AS VARCHAR(MAX))
						WHEN 'OTE_cp'  THEN CAST(ldthreev.OTE_cp AS VARCHAR(MAX))
						WHEN 'Liq__cp'  THEN CAST(ldthreev.Liq__cp AS VARCHAR(MAX))
						WHEN 'Mrg_cp'  THEN CAST(ldthreev.Mrg_cp AS VARCHAR(MAX))
						WHEN 'elng_cp'  THEN CAST(ldthreev.elng_cp AS VARCHAR(MAX))
						WHEN 'esht_cp'  THEN CAST(ldthreev.esht_cp AS VARCHAR(MAX))
						WHEN 'dvt_cp'  THEN CAST(ldthreev.dvt_cp AS VARCHAR(MAX))
						WHEN 'exp_rsk'  THEN CAST(ldthreev.exp_rsk AS VARCHAR(MAX))
						WHEN 'vr_rsk'  THEN CAST(ldthreev.vr_rsk AS VARCHAR(MAX))
						WHEN 'cvr_rsk'  THEN CAST(ldthreev.cvr_rsk AS VARCHAR(MAX))
						WHEN 'dv_rsk'  THEN CAST(ldthreev.dv_rsk AS VARCHAR(MAX))
						WHEN 'dvt_rsk' THEN CAST(ldthreev.dvt_rsk AS VARCHAR(MAX))		
						WHEN 'today' THEN CAST(CAST(YEAR(GETDATE()) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(GETDATE()) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(GETDATE()) AS VARCHAR(2)), 2) AS VARCHAR(MAX)) 
						ELSE grade_three_data_inner_xml
						END 
					)
					FROM [opera].[ivp_polaris_cfg_grade_three_data] ldthree WITH (NOLOCK)
					LEFT OUTER JOIN #DataValuesForOpera ldthreev WITH (NOLOCK)
					on ldthreev.sub_section_id = s.id AND ldthreev.section_id = t.id AND ldthreev.grade_1 = lone.grade_one_title 
					AND ldthreev.grade_2 = ltwo.grade_two_title AND ldthreev.grade_3 = lthree.grade_three_title 
					AND ldthreev.Table_Name = (	
												CASE 
													WHEN ldthree.grade_three_data_inner_xml IN ('non_netted_long','non_netted_short','values') 
													THEN '[opera].[ivp_polaris_report_non_netted_values]'
													WHEN ldthree.grade_three_data_inner_xml IN ('netted_long','netted_short','long_positions','short_positions') 
													THEN '[opera].[ivp_polaris_report_netted_values]'
													WHEN ldthree.grade_three_data_inner_xml IN ('dv_fidv' , 'dvt_fidv' , 'Month_fidv' , 'QTD_fidv' , 'YTD_fidv' , 'ITD_fidv' , 'perc_fidv' , 'amt_fidv' , 'withPen_fidv' ,'withoutPen_fidv') 
													THEN '[opera].[ivp_polaris_report_fund_investor_details]'
													WHEN ldthree.grade_three_data_inner_xml IN ('bet_sns','del_sns','gam_sns','veg_sns','thet_sns','cs01_sns','dv01_sns','dv_sns') 
													THEN '[opera].[ivp_polaris_report_fund_sensitivity_details]'
													WHEN ldthree.grade_three_data_inner_xml IN ('pr_st','plng_st','psht_st','dt_st') 
													THEN '[opera].[ivp_polaris_report_fund_stress_test]'
													WHEN ldthree.grade_three_data_inner_xml IN ('cnt_cp' ,'Eq_cp','LMV_cp','SMV_cp','Cash_cp','OTE_cp','Liq__cp','Mrg_cp','elng_cp','esht_cp','dvt_cp') 
													THEN '[opera].[ivp_polaris_report_counterparty_details]'
													WHEN ldthree.grade_three_data_inner_xml IN ('exp_rsk','vr_rsk','cvr_rsk','dv_rsk','dvt_rsk') 
													THEN '[opera].[ivp_polaris_report_value_at_risk]'
												END	
											 )	 	
					WHERE ldthree .[is_active]=1 AND ldthree.grade_three_id =  lthree.id
					ORDER BY ldthree.[sort_order]
					FOR XML PATH('Data'), TYPE
				)
				FROM [opera].[ivp_polaris_cfg_grade_three] lthree WITH (NOLOCK)
				WHERE lthree.[is_active]=1 AND lthree.grade_two_id =  ltwo.id
				ORDER BY lthree.[sort_order]
				FOR XML PATH('Level'), TYPE
			 )
			 ELSE '' END
			FROM [opera].[ivp_polaris_cfg_grade_two] ltwo WITH (NOLOCK)
			LEFT OUTER JOIN opera.ivp_polaris_cfg_grade_three g3rSpanInner WITH (NOLOCK) on ltwo.id = g3rSpanInner.grade_two_id AND sr.sub_section_grade_id = 3 
			WHERE ltwo.[is_active]=1 AND ltwo.grade_one_id =  lone.id
			GROUP BY ltwo.id, ltwo.grade_two_title, ltwo.[sort_order]
			ORDER BY ltwo.[sort_order]
			FOR XML PATH('Level'), TYPE
		 )
		 ELSE '' END
		FROM [opera].[ivp_polaris_cfg_grade_one] lone WITH (NOLOCK)
		LEFT OUTER JOIN opera.ivp_polaris_cfg_grade_two g2rSpan WITH (NOLOCK) on lone.id =  g2rSpan.grade_one_id AND sr.sub_section_grade_id >=2
		LEFT OUTER JOIN opera.ivp_polaris_cfg_grade_two g2ForRowSpans WITH (NOLOCK) on g2ForRowSpans.grade_one_id = lone.id AND sr.sub_section_grade_id = 3 
		LEFT OUTER JOIN opera.ivp_polaris_cfg_grade_three g3rSpan WITH (NOLOCK) on g2ForRowSpans.id = g3rSpan.grade_two_id AND sr.sub_section_grade_id = 3 
		WHERE lone.[is_active]=1 AND lone.sub_section_id =  s.id
		GROUP BY lone.id, lone.grade_one_title, lone.[sort_order]
		ORDER BY lone.[sort_order]
		FOR XML PATH('Level'), TYPE
	 )
	 FROM [opera].[ivp_polaris_cfg_sub_section] s WITH (NOLOCK)
	 JOIN opera.ivp_polaris_report_sub_section sr WITH (NOLOCK) on s.id = sr.sub_section_id 
	 WHERE  s.[is_active]=1 and s.section_id = t.id AND sr.report_id = @ReportID AND sr.fund_id = @FundID AND sr.is_active=1
	 AND (@TabId IS NULL OR t.id = @TabId)
	 ORDER BY s.[sort_order]
	 FOR XML PATH('Section'), TYPE
 ),
 (
		SELECT (SELECT  ISNULL(ssComm.sub_section_name, CAST(t.id AS VARCHAR(10)) + ' ' + t.section_name ) + ' - '+  comm.comment) 
		FROM [opera].[ivp_polaris_comments] comm WITH (NOLOCK)
		LEFT OUTER JOIN [opera].[ivp_polaris_cfg_sub_section] ssComm WITH (NOLOCK) on ssComm.id = comm.sub_section_id 
		WHERE comm.[is_active] =1 AND t.id= comm.section_id AND comm.fund_id = @FundID AND comm.report_id = @ReportID
		AND (@TabId IS NULL OR t.id = @TabId)
		ORDER BY t.id, sscomm.id
		FOR  XML PATH('Comment'), ROOT('Comments'), TYPE
)
FROM [opera].[ivp_polaris_cfg_section]  t WITH (NOLOCK)
JOIN opera.ivp_polaris_report_section tr WITH (NOLOCK) on t.id = tr.section_id
WHERE t.[is_active]=1 AND tr.report_id = @ReportID AND tr.fund_id = @FundID AND tr.is_active=1 
ORDER BY t.[sort_order]
FOR XML PATH('Tab'), ROOT('Opera'), TYPE 
END
ELSE 
BEGIN
SELECT t.section_name AS '@title',t.section_description AS '@header',t.id AS '@id'
FROM [opera].[ivp_polaris_cfg_section]  t WITH (NOLOCK)
JOIN opera.ivp_polaris_report_section tr WITH (NOLOCK) on t.id = tr.section_id
WHERE t.[is_active]=1 AND tr.report_id = @ReportID AND tr.fund_id = @FundID AND tr.is_active=1 
ORDER BY t.[sort_order]
FOR XML PATH('Tab'), ROOT('Opera'), TYPE 
END

SELECT @AsOfDate AS 'Repoting Date'

DROP TABLE #DataValuesForOpera

END
