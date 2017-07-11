CREATE OR REPLACE PROCEDURE P_UMTS_CLDD_NQI_3RD_AUX_INS (P_FECHA_DESDE IN CHAR, P_FECHA_HASTA IN CHAR, P_OSSRC IN CHAR) IS

-- Autor: Monica Pellegrini. Fecha: 30.11.2016.
-- Actualizacion: Mario Heredia. Fecha: 17.05.2017. Motivo: Incluir otros KPIs.
-- Actualizacion: Mario Heredia. Fecha: 31.05.2017. Motivo: Migracion a Falda.

CURSOR CUR_NSN_NE_HOUR (FECHA_DESDE VARCHAR2, FECHA_HASTA VARCHAR2, RC VARCHAR2) IS
SELECT PERIOD_START_TIME,
       OSSRC,
       WCELL_GID,
       WBTS_GID,
       RNC_GID,
       NUMERADOR   USER_THROUGHPUT_NUM,
       DENOMINADOR USER_THROUGHPUT_DEN,
       --ROUND(NUMERADOR / DENOMINADOR, 2) USER_THROUGHPUT
       DLR99MACDMB,
       HSDPAMACDMB,
       ULR99MACDMB,
       HSUPAMACESMB
  FROM (
SELECT PERIOD_START_TIME,
       OSSRC,
       WCELL_GID,
       WBTS_GID,
       RNC_GID,
       USER_THP,
       CASE WHEN USER_THP >= 400 THEN 100 ELSE 0 END NUMERADOR,
       1 DENOMINADOR,
       DLR99MACDMB,
       HSDPAMACDMB,
       ULR99MACDMB,
       HSUPAMACESMB
  FROM (
SELECT PERIOD_START_TIME,
       OSSRC,
       WCELL_GID,
       WBTS_GID,
       RNC_GID,
       ROUND(DECODE(USER_THP_DEN, 0, 0,
         (0.5 * 8 * USER_THP_NUM) / USER_THP_DEN), 2) USER_THP,
       DLR99MACDMB,
       HSDPAMACDMB,
       ULR99MACDMB,
       HSUPAMACESMB
  FROM (
SELECT A.PERIOD_START_TIME,
       A.OSSRC,
       A.WCELL_GID,
       A.WBTS_GID,
       A.RNC_GID,
       HS_DSCH_DATA_VOL                                      USER_THP_NUM,
       (HSDPA_BUFF_WITH_DATA_PER_TTI +
        TTI_DC_HSDPA_USER_SECONDARY_1C +
        TTI_DC_HSDPA_USER_SECONDARY_2C)                      USER_THP_DEN,
       ROUND(NRT_DCH_DL_DATA_VOL / (1024 * 1024), 2)         DLR99MACDMB,
       ROUND(HS_DSCH_DATA_VOL / (1024 * 1024), 2)            HSDPAMACDMB,
       ROUND((NRT_DCH_UL_DATA_VOL / (1024 * 1024)) +
             (NRT_DCH_HSDPA_UL_DATA_VOL / (1024 * 1024)), 2) ULR99MACDMB,
       ROUND (NRT_EDCH_UL_DATA_VOL / (1024 * 1024), 2)       HSUPAMACESMB
  FROM UMTS_C_NSN_CELLTP_MNC1_RAW@SMART.WORLD A,
       UMTS_C_NSN_HSDPAW_MNC1_RAW@SMART.WORLD B
 WHERE A.PERIOD_START_TIME = B.PERIOD_START_TIME
   AND A.OSSRC = B.OSSRC
   AND A.WCELL_GID = B.WCELL_GID
   AND A.PERIOD_START_TIME BETWEEN TO_DATE(FECHA_DESDE, 'DD.MM.YYYY HH24')
                               AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY HH24')
   AND A.OSSRC = RC
       )
       )
       );

TYPE TYP_NSN_NQI_VOZ_HOUR IS TABLE OF CUR_NSN_NE_HOUR%ROWTYPE INDEX BY BINARY_INTEGER;
NSN_NQI_VOZ_HOUR TYP_NSN_NQI_VOZ_HOUR;

TYPE T_UMTS_NSN_NQI_VOZ_HOUR IS TABLE OF CLDD_NQI_3RD_AUX_HOUR%ROWTYPE INDEX BY PLS_INTEGER;
UMTS_NSN_NQI_VOZ_HOU2 T_UMTS_NSN_NQI_VOZ_HOUR;

C_LIMIT PLS_INTEGER := 1000;
PCNT    NUMBER := 0;

BEGIN

--EXECUTE IMMEDIATE 'TRUNCATE TABLE SCOTT.CLDD_NQI_3RD_AUX_HOUR';
-- Open | Fetch | Close

OPEN CUR_NSN_NE_HOUR (P_FECHA_DESDE, P_FECHA_HASTA, P_OSSRC);

LOOP

FETCH CUR_NSN_NE_HOUR BULK COLLECT INTO NSN_NQI_VOZ_HOUR LIMIT C_LIMIT;

FOR I IN 1 .. NSN_NQI_VOZ_HOUR.COUNT LOOP

  PCNT := PCNT + 1;

  UMTS_NSN_NQI_VOZ_HOU2(I).FECHA                                 := NSN_NQI_VOZ_HOUR(I).PERIOD_START_TIME             ;
  UMTS_NSN_NQI_VOZ_HOU2(I).OSSRC                                 := NSN_NQI_VOZ_HOUR(I).OSSRC                         ;
  UMTS_NSN_NQI_VOZ_HOU2(I).WCELL_GID                             := NSN_NQI_VOZ_HOUR(I).WCELL_GID                     ;
  UMTS_NSN_NQI_VOZ_HOU2(I).WBTS_GID                              := NSN_NQI_VOZ_HOUR(I).WBTS_GID                      ;
  UMTS_NSN_NQI_VOZ_HOU2(I).RNC_GID                               := NSN_NQI_VOZ_HOUR(I).RNC_GID                       ;
  UMTS_NSN_NQI_VOZ_HOU2(I).USER_THROUGHPUT_NUM                   := NSN_NQI_VOZ_HOUR(I).USER_THROUGHPUT_NUM           ;
  UMTS_NSN_NQI_VOZ_HOU2(I).USER_THROUGHPUT_DEN                   := NSN_NQI_VOZ_HOUR(I).USER_THROUGHPUT_DEN           ;

  UMTS_NSN_NQI_VOZ_HOU2(I).DLR99MACDMB                           := NSN_NQI_VOZ_HOUR(I).DLR99MACDMB                   ;
  UMTS_NSN_NQI_VOZ_HOU2(I).HSDPAMACDMB                           := NSN_NQI_VOZ_HOUR(I).HSDPAMACDMB                   ;
  UMTS_NSN_NQI_VOZ_HOU2(I).ULR99MACDMB                           := NSN_NQI_VOZ_HOUR(I).ULR99MACDMB                   ;
  UMTS_NSN_NQI_VOZ_HOU2(I).HSUPAMACESMB                          := NSN_NQI_VOZ_HOUR(I).HSUPAMACESMB                  ;

END LOOP;

IF CUR_NSN_NE_HOUR%NOTFOUND THEN

   FORALL I IN UMTS_NSN_NQI_VOZ_HOU2.FIRST .. PCNT
   INSERT INTO CLDD_NQI_3RD_AUX_HOUR VALUES UMTS_NSN_NQI_VOZ_HOU2(I);

   EXIT;
ELSE

   FORALL I IN UMTS_NSN_NQI_VOZ_HOU2.FIRST .. UMTS_NSN_NQI_VOZ_HOU2.LAST
   INSERT INTO CLDD_NQI_3RD_AUX_HOUR VALUES UMTS_NSN_NQI_VOZ_HOU2(I);

END IF;

PCNT := 0;

END LOOP;

COMMIT;

END P_UMTS_CLDD_NQI_3RD_AUX_INS;
