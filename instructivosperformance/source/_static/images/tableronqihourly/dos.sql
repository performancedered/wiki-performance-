CREATE OR REPLACE PROCEDURE P_UMTS_CLDD_NQI_2ND_AUX_INS (P_FECHA_DESDE IN CHAR, P_FECHA_HASTA IN CHAR, P_OSSRC IN CHAR) IS

-- Autor: Monica Pellegrini. Fecha: 30.11.2016.
-- Actualizacion: Mario Heredia. Fecha: 17.05.2017. Motivo: Incluir otros KPIs.
-- Actualizacion: Mario Heredia. Fecha: 31.05.2017. Motivo: Migracion a Falda.

CURSOR CUR_NSN_NE_HOUR (FECHA_DESDE VARCHAR2, FECHA_HASTA VARCHAR2, RC VARCHAR2) IS
SELECT PERIOD_START_TIME,
       OSSRC,
       WCELL_GID,
       WBTS_GID,
       RNC_GID,
       PERIOD_DURATION,
       HSDPA_USERS_RATIO_NUM,
       HSDPA_USERS_RATIO_DEN,
       AVAILABILITY_NUM,
       AVAILABILITY_DEN,
       ACCESIBILITY_NUM,
       ACCESIBILITY_DEN,
       RETENIBILITY_NUM,
       RETENIBILITY_DEN,
       ACCESIBILITY_PS,
       RETENIBILITY_PS,
       CASE WHEN ACCESIBILITY_PS < 98.5 THEN 0
                                        ELSE ACCESIBILITY_DEN END QDA_NUM,
       ACCESIBILITY_DEN QDA_DEN,
       CASE WHEN RETENIBILITY_PS < 98.5 THEN 0
                                        ELSE RETENIBILITY_DEN END QDR_NUM,
       RETENIBILITY_DEN QDR_DEN,
       CELL_WO_STATE_USR_NUM,
       CELL_WO_STATE_USR_DEN,
       CELL_WO_STATE_NET_NUM,
       CELL_WO_STATE_NET_DEN
  FROM (
SELECT PERIOD_START_TIME,
       OSSRC,
       WCELL_GID,
       WBTS_GID,
       RNC_GID,
       PERIOD_DURATION,
       ROUND(DECODE(DENOM_HSDPA_USERS_PER_CELL, 0, 0,
                    SUM_HSDPA_USERS_IN_CELL / DENOM_HSDPA_USERS_PER_CELL), 2)                    HSDPA_USERS_RATIO_NUM,
       ROUND(DECODE(DENOM_HSDPA_USERS_PER_CELL, 0, PS_R99_USERS,
                   ((SUM_HSDPA_USERS_IN_CELL / DENOM_HSDPA_USERS_PER_CELL) + PS_R99_USERS)), 2)  HSDPA_USERS_RATIO_DEN,
       AVAILABILITY_NUM,
       AVAILABILITY_DEN,
       CASE WHEN ACCESIBILITY_DEN = 0 THEN 1
                                      ELSE ROUND(100 * ACCESIBILITY_NUM / ACCESIBILITY_DEN, 2) END ACCESIBILITY_PS,

       CASE WHEN RETENIBILITY_DEN = 0 THEN 1
                                      ELSE ROUND(100 * RETENIBILITY_NUM / RETENIBILITY_DEN, 2) END RETENIBILITY_PS,
       ACCESIBILITY_NUM,
       ACCESIBILITY_DEN,
       RETENIBILITY_NUM,
       RETENIBILITY_DEN,
       CELL_WO_STATE_USR_NUM,
       CELL_WO_STATE_USR_DEN,
       CELL_WO_STATE_NET_NUM,
       CELL_WO_STATE_NET_DEN
  FROM (
SELECT A.PERIOD_START_TIME,
       A.OSSRC,
       A.WCELL_GID,
       A.WBTS_GID,
       A.RNC_GID,
       A.PERIOD_DURATION,
       SUM_HSDPA_USERS_IN_CELL,
       DENOM_HSDPA_USERS_PER_CELL,
       ROUND((
       NVL(DUR_PS_INTERA_8_DL_IN_SRNC, 0) +
       NVL(DUR_PS_INTERA_16_DL_IN_SRNC, 0) +
       NVL(DUR_PS_INTERA_32_DL_IN_SRNC, 0) +
       NVL(DUR_PS_INTERA_64_DL_IN_SRNC, 0) +
       NVL(DUR_PS_INTERA_128_DL_IN_SRNC, 0) +
       NVL(DUR_PS_INTERA_256_DL_IN_SRNC, 0) +
       NVL(DUR_PS_INTERA_320_DL_IN_SRNC, 0) +
       NVL(DUR_PS_INTERA_384_DL_IN_SRNC, 0) +
       NVL(DUR_PS_BACKG_8_DL_IN_SRNC, 0) +
       NVL(DUR_PS_BACKG_16_DL_IN_SRNC, 0) +
       NVL(DUR_PS_BACKG_32_DL_IN_SRNC, 0) +
       NVL(DUR_PS_BACKG_64_DL_IN_SRNC, 0) +
       NVL(DUR_PS_BACKG_128_DL_IN_SRNC, 0) +
       NVL(DUR_PS_BACKG_256_DL_IN_SRNC, 0) +
       NVL(DUR_PS_BACKG_320_DL_IN_SRNC, 0) +
       NVL(DUR_PS_BACKG_384_DL_IN_SRNC, 0) +
       NVL(DUR_PS_STREAM_8_DL_IN_SRNC, 0) +
       NVL(DUR_PS_STREAM_16_DL_IN_SRNC, 0) +
       NVL(DUR_PS_STREAM_32_DL_IN_SRNC, 0) +
       NVL(DUR_PS_STREAM_64_DL_IN_SRNC, 0) +
       NVL(DUR_PS_STREAM_128_DL_IN_SRNC, 0) +
       NVL(DUR_PS_STREAM_256_DL_IN_SRNC, 0) +
       NVL(DUR_PS_STREAM_320_DL_IN_SRNC, 0) +
       NVL(DUR_PS_STREAM_384_DL_IN_SRNC, 0)) / (1.35 * 3600 * 100), 2) PS_R99_USERS,
       (AVAIL_WCELL_BLOCKED_BY_USER +
        AVAIL_WCELL_IN_WO_STATE)                                       AVAILABILITY_NUM,
       AVAIL_WCELL_EXISTS_IN_RNW_DB                                    AVAILABILITY_DEN,
       (ALLO_HS_DSCH_FLOW_INT +
        ALLO_HS_DSCH_FLOW_BGR)                                         ACCESIBILITY_NUM,
       (ALLO_HS_DSCH_FLOW_INT +
        ALLO_HS_DSCH_FLOW_BGR +
        REJ_HS_DSCH_RET_INT +
        REJ_HS_DSCH_RET_BGR +
        SETUP_FAIL_RNC_HS_DSCH_INT +
        SETUP_FAIL_BTS_HS_DSCH_INT +
        SETUP_FAIL_IUB_HS_TOTAL_INT +
        SETUP_FAIL_RNC_HS_DSCH_BGR +
        SETUP_FAIL_BTS_HS_DSCH_BGR +
        SETUP_FAIL_IUB_HS_TOTAL_BGR +
        SETUP_FAIL_UE_HS_DSCH_INT +
        SETUP_FAIL_UE_HS_DSCH_BGR +
        DCH_SEL_MAX_HSDPA_USERS_INT +
        DCH_SEL_MAX_HSDPA_USERS_BGR)                                   ACCESIBILITY_DEN,
       (REL_ALLO_NORM_HS_DSCH_INT +
        REL_ALLO_NORM_HS_DSCH_BGR)                                     RETENIBILITY_NUM,
       (REL_ALLO_NORM_HS_DSCH_INT +
        REL_ALLO_NORM_HS_DSCH_BGR +
        REL_ALLO_OTH_FAIL_HSDSCH_INT +
        REL_ALLO_OTH_FAIL_HSDSCH_BGR +
        REL_ALLO_RL_FAIL_HS_DSCH_INT +
        REL_ALLO_RL_FAIL_HS_DSCH_BGR)                                  RETENIBILITY_DEN,
       AVAIL_WCELL_IN_WO_STATE                                         CELL_WO_STATE_USR_NUM,
       AVAIL_WCELL_EXISTS_IN_RNW_DB                                    CELL_WO_STATE_USR_DEN,
       AVAIL_WCELL_IN_WO_STATE                                         CELL_WO_STATE_NET_NUM,
       (AVAIL_WCELL_EXISTS_IN_RNW_DB -
        AVAIL_WCELL_BLOCKED_BY_USER)                                   CELL_WO_STATE_NET_DEN
  FROM UMTS_C_NSN_CELLRES_MNC1_RAW@SMART.WORLD A,
       UMTS_C_NSN_TRAFFIC_MNC1_RAW@SMART.WORLD B
 WHERE A.PERIOD_START_TIME = B.PERIOD_START_TIME
   AND A.OSSRC = B.OSSRC
   AND A.WCELL_GID = B.WCELL_GID
   AND A.PERIOD_START_TIME BETWEEN TO_DATE(FECHA_DESDE, 'DD.MM.YYYY HH24')
                               AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY HH24')
   AND A.OSSRC = RC
       )
       );

TYPE TYP_NSN_NQI_VOZ_HOUR IS TABLE OF CUR_NSN_NE_HOUR%ROWTYPE INDEX BY BINARY_INTEGER;
NSN_NQI_VOZ_HOUR TYP_NSN_NQI_VOZ_HOUR;

TYPE T_UMTS_NSN_NQI_VOZ_HOUR IS TABLE OF CLDD_NQI_2ND_AUX_HOUR%ROWTYPE INDEX BY PLS_INTEGER;
UMTS_NSN_NQI_VOZ_HOU2 T_UMTS_NSN_NQI_VOZ_HOUR;

C_LIMIT PLS_INTEGER := 1000;
PCNT    NUMBER := 0;

BEGIN

-- EXECUTE IMMEDIATE 'TRUNCATE TABLE CLDD_NQI_2ND_AUX_HOUR';
-- Open | Fetch | Close

OPEN CUR_NSN_NE_HOUR  (P_FECHA_DESDE, P_FECHA_HASTA, P_OSSRC);

LOOP

FETCH CUR_NSN_NE_HOUR BULK COLLECT INTO NSN_NQI_VOZ_HOUR LIMIT C_LIMIT;

FOR I IN 1 .. NSN_NQI_VOZ_HOUR.COUNT LOOP

  PCNT := PCNT + 1;

  UMTS_NSN_NQI_VOZ_HOU2(I).FECHA                      := NSN_NQI_VOZ_HOUR(I).PERIOD_START_TIME               ;
  UMTS_NSN_NQI_VOZ_HOU2(I).OSSRC                      := NSN_NQI_VOZ_HOUR(I).OSSRC                           ;
  UMTS_NSN_NQI_VOZ_HOU2(I).WCELL_GID                  := NSN_NQI_VOZ_HOUR(I).WCELL_GID                       ;
  UMTS_NSN_NQI_VOZ_HOU2(I).WBTS_GID                   := NSN_NQI_VOZ_HOUR(I).WBTS_GID                        ;
  UMTS_NSN_NQI_VOZ_HOU2(I).RNC_GID                    := NSN_NQI_VOZ_HOUR(I).RNC_GID                         ;

  UMTS_NSN_NQI_VOZ_HOU2(I).HSDPA_USERS_RATIO_NUM      := NSN_NQI_VOZ_HOUR(I).HSDPA_USERS_RATIO_NUM           ;
  UMTS_NSN_NQI_VOZ_HOU2(I).HSDPA_USERS_RATIO_DEN      := NSN_NQI_VOZ_HOUR(I).HSDPA_USERS_RATIO_DEN           ;
  UMTS_NSN_NQI_VOZ_HOU2(I).AVAILABILITY_NUM           := NSN_NQI_VOZ_HOUR(I).AVAILABILITY_NUM                ;
  UMTS_NSN_NQI_VOZ_HOU2(I).AVAILABILITY_DEN           := NSN_NQI_VOZ_HOUR(I).AVAILABILITY_DEN                ;
  UMTS_NSN_NQI_VOZ_HOU2(I).ACCESIBILITY_NUM           := NSN_NQI_VOZ_HOUR(I).ACCESIBILITY_NUM                ;
  UMTS_NSN_NQI_VOZ_HOU2(I).ACCESIBILITY_DEN           := NSN_NQI_VOZ_HOUR(I).ACCESIBILITY_DEN                ;
  UMTS_NSN_NQI_VOZ_HOU2(I).RETENIBILITY_NUM           := NSN_NQI_VOZ_HOUR(I).RETENIBILITY_NUM                ;
  UMTS_NSN_NQI_VOZ_HOU2(I).RETENIBILITY_DEN           := NSN_NQI_VOZ_HOUR(I).RETENIBILITY_DEN                ;
  UMTS_NSN_NQI_VOZ_HOU2(I).ACCESIBILITY_PS            := NSN_NQI_VOZ_HOUR(I).ACCESIBILITY_PS                 ;
  UMTS_NSN_NQI_VOZ_HOU2(I).RETENIBILITY_PS            := NSN_NQI_VOZ_HOUR(I).RETENIBILITY_PS                 ;
  UMTS_NSN_NQI_VOZ_HOU2(I).QDA_NUM                    := NSN_NQI_VOZ_HOUR(I).QDA_NUM                         ;
  UMTS_NSN_NQI_VOZ_HOU2(I).QDA_DEN                    := NSN_NQI_VOZ_HOUR(I).QDA_DEN                         ;
  UMTS_NSN_NQI_VOZ_HOU2(I).QDR_NUM                    := NSN_NQI_VOZ_HOUR(I).QDR_NUM                         ;
  UMTS_NSN_NQI_VOZ_HOU2(I).QDR_DEN                    := NSN_NQI_VOZ_HOUR(I).QDR_DEN                         ;

  UMTS_NSN_NQI_VOZ_HOU2(I).PERIOD_DURATION_CELLRES    := NSN_NQI_VOZ_HOUR(I).PERIOD_DURATION                 ;

  UMTS_NSN_NQI_VOZ_HOU2(I).CELL_WO_STATE_USR_NUM      := NSN_NQI_VOZ_HOUR(I).CELL_WO_STATE_USR_NUM           ;
  UMTS_NSN_NQI_VOZ_HOU2(I).CELL_WO_STATE_USR_DEN      := NSN_NQI_VOZ_HOUR(I).CELL_WO_STATE_USR_DEN           ;
  UMTS_NSN_NQI_VOZ_HOU2(I).CELL_WO_STATE_NET_NUM      := NSN_NQI_VOZ_HOUR(I).CELL_WO_STATE_NET_NUM           ;
  UMTS_NSN_NQI_VOZ_HOU2(I).CELL_WO_STATE_NET_DEN      := NSN_NQI_VOZ_HOUR(I).CELL_WO_STATE_NET_DEN           ;

END LOOP;

IF CUR_NSN_NE_HOUR%NOTFOUND THEN

   FORALL I IN UMTS_NSN_NQI_VOZ_HOU2.FIRST .. PCNT
   INSERT INTO CLDD_NQI_2ND_AUX_HOUR VALUES UMTS_NSN_NQI_VOZ_HOU2(I);

   EXIT;

ELSE

   FORALL I IN UMTS_NSN_NQI_VOZ_HOU2.FIRST .. UMTS_NSN_NQI_VOZ_HOU2.LAST
   INSERT INTO CLDD_NQI_2ND_AUX_HOUR VALUES UMTS_NSN_NQI_VOZ_HOU2(I);

END IF;

PCNT := 0;

END LOOP;

COMMIT;

END P_UMTS_CLDD_NQI_2ND_AUX_INS;
