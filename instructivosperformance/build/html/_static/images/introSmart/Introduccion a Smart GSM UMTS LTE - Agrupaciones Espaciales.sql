select * from objects_sp_gsm
where BTS_NAME like 'CO008%'
and BTS_VALID_FINISH_DATE > SYSDATE;


select BTS_ID,BTS_NAME,BTS_ADDRESS,BCF_ID,BCF_NAME,BSC_ID,BSC_NAME,OSSRC,ALM,ALM_NOMBRE,LOCALIDAD,MERCADO,PAIS from objects_sp_gsm
where BTS_NAME like 'CO008%'
and BTS_VALID_FINISH_DATE > SYSDATE;

select * from objects_sp_umts
where WCELL_NAME like '%CO008%'
and WCELL_VALID_FINISH_DATE > SYSDATE;

select WCELL_ID,WCELL_NAME,WBTS_ADDRESS,WBTS_ID,WBTS_NAME,RNC_ID,RNC_NAME,OSSRC,ALM,ALM_NOMBRE,LOCALIDAD,MERCADO,PAIS from objects_sp_umts
where WCELL_NAME like '%CO008%'
and WCELL_VALID_FINISH_DATE > SYSDATE;

select * from objects_sp_lte
where lncel_name like '%CO008%'
and LNCEL_VALID_FINISH_DATE > SYSDATE;

select LNCEL_ID,LNCEL_NAME,LNCEL_ADDRESS,LNBTS_ID,LNBTS_NAME,OSSRC,ALM,ALM_NOMBRE,LOCALIDAD,MERCADO,PAIS from objects_sp_lte
where lncel_name like '%CO008%'
and LNCEL_VALID_FINISH_DATE > SYSDATE;