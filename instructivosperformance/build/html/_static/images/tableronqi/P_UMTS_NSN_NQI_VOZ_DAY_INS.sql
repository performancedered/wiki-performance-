create or replace PROCEDURE P_UMTS_NSN_NQI_VOZ_DAY_INS (P_FECHA_DESDE IN CHAR, P_FECHA_HASTA IN CHAR) IS
-- Autor:  Monica Pellegrin. Fecha:27.06.2016.

CURSOR CUR_NSN_NQI_VOZ_DAY (FECHA_DESDE VARCHAR2, FECHA_HASTA VARCHAR2) IS
SELECT FECHA,
       OSSRC,
       WCELL_GID,
       WBTS_GID,
       RNC_GID,
       WCELL_NAME,
       WBTS_NAME,
       RNC_NAME,
       ALM,
       MERCADO,
       PAIS,
       QDA_NUM,
       QDA_DEN,
       QDR_NUM,
       QDR_DEN
  FROM(
SELECT trunc(A.FECHA) FECHA ,
       A.OSSRC, 
       A.WCELL_GID, 
       A.WBTS_GID, 
       A.RNC_GID,
       B.WCELL_NAME, 
       B.WBTS_NAME, 
       B.RNC_NAME, 
       B.ALM, 
       B.MERCADO,
       B.PAIS,
       SUM(QDA_NUM) QDA_NUM,
       SUM(QDA_DEN) QDA_DEN,
       SUM(QDR_NUM) QDR_NUM,
       SUM(QDR_DEN) QDR_DEN,
       ROW_NUMBER()OVER(PARTITION BY A.WCELL_GID,A.WBTS_GID, A.RNC_GID  ORDER BY trunc(A.FECHA) DESC ) ORDEN
  FROM (
SELECT FECHA, 
       OSSRC, 
       WCELL_GID, 
       WBTS_GID, 
       RNC_GID,
       SUM(CS_ERL) CS_ERL,
       SUM(QDA_NUM) QDA_NUM,
       SUM(QDA_DEN) QDA_DEN,
       SUM(QDR_NUM) QDR_NUM,
       SUM(QDR_DEN) QDR_DEN
  FROM (
SELECT FECHA , 
       OSSRC, 
       WCELL_GID, 
       WBTS_GID, 
       RNC_GID,
       CS_ERL,
       ROUND(100 * ACCESIBILIDAD_CS, 2) ACCESIBILIDAD_CS,
       ROUND(100 * RETENIBILIDAD_CS, 2) RETENIBILIDAD_CS,
       CASE WHEN 100 * ACCESIBILIDAD_CS < 98.5 THEN 0
                                               ELSE RRC_CSS_VOZ_DEN * RAB_CSS_VOZ_DEN END QDA_NUM,
       RRC_CSS_VOZ_DEN * RAB_CSS_VOZ_DEN   QDA_DEN,
       CASE WHEN 100 * RETENIBILIDAD_CS < 98.5 THEN 0
                                               ELSE RAB_DROP_VOZ_USR_DEN END QDR_NUM,
       RAB_DROP_VOZ_USR_DEN QDR_DEN,
       RRC_CSS_VOZ_NUM,
       RRC_CSS_VOZ_DEN,
       RAB_CSS_VOZ_NUM,
       RAB_CSS_VOZ_DEN,
       RAB_DROP_VOZ_USR_NUM,
       RAB_DROP_VOZ_USR_DEN
  FROM (
SELECT PERIOD_START_TIME FECHA, 
       OSSRC, 
       WCELL_GID, 
       WBTS_GID, 
       RNC_GID,
       SUM(CS_ERL) CS_ERL,
       ROUND(
       CASE WHEN SUM(RRC_CSS_VOZ_DEN) = 0 THEN 1
            WHEN SUM(RAB_CSS_VOZ_DEN) = 0 THEN (SUM(RRC_CSS_VOZ_NUM) / SUM(RRC_CSS_VOZ_DEN))
                                     ELSE (SUM(RRC_CSS_VOZ_NUM) / SUM(RRC_CSS_VOZ_DEN)) *
                                          (SUM(RAB_CSS_VOZ_NUM) / SUM(RAB_CSS_VOZ_DEN)) END, 6) ACCESIBILIDAD_CS,
       SUM(RRC_CSS_VOZ_NUM) RRC_CSS_VOZ_NUM,
       SUM(RRC_CSS_VOZ_DEN) RRC_CSS_VOZ_DEN,
       SUM(RAB_CSS_VOZ_NUM) RAB_CSS_VOZ_NUM,
       SUM(RAB_CSS_VOZ_DEN) RAB_CSS_VOZ_DEN,
       ROUND(1 - DECODE(NVL(SUM(RAB_DROP_VOZ_USR_DEN), 0), 0, 0,
                            SUM(RAB_DROP_VOZ_USR_NUM) / SUM(RAB_DROP_VOZ_USR_DEN)), 6) RETENIBILIDAD_CS,
       SUM(RAB_DROP_VOZ_USR_NUM) RAB_DROP_VOZ_USR_NUM,
       SUM(RAB_DROP_VOZ_USR_DEN) RAB_DROP_VOZ_USR_DEN
  FROM UMTS_NSN_SERVICE_WCEL_HOU2
 WHERE PERIOD_START_TIME IN
       (
SELECT FECHA
  FROM CALIDAD_STATUS_REFERENCES
 WHERE FECHA BETWEEN TO_DATE(FECHA_DESDE, 'DD.MM.YYYY')
                         AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY') + 86399/86400 
   AND HORA NOT IN ('00', '01', '02', '03', '04', '05', '06', '23')
       )
GROUP BY PERIOD_START_TIME, 
         OSSRC, 
         WCELL_GID,
         WBTS_GID, 
         RNC_GID
       )
       )
GROUP BY FECHA, 
         OSSRC, 
         WCELL_GID, 
         WBTS_GID, 
         RNC_GID
       ) A, OBJECTS_SP_UMTS B
WHERE A.WCELL_GID = B.WCELL_ID (+)
   AND A.OSSRC = B.OSSRC (+) 
GROUP BY trunc(A.FECHA),
       A.OSSRC, 
       A.WCELL_GID, 
       A.WBTS_GID, 
       A.RNC_GID,
       B.WCELL_NAME, 
       B.WBTS_NAME, 
       B.RNC_NAME, 
       B.ALM, 
       B.MERCADO,
       B.PAIS
ORDER BY trunc(A.FECHA), 
         WCELL_NAME
         )
 WHERE ORDEN = 1;

TYPE TYP_NSN_NQI_VOZ_DAY IS TABLE OF CUR_NSN_NQI_VOZ_DAY%ROWTYPE INDEX BY BINARY_INTEGER;
 NSN_NQI_VOZ_DAY TYP_NSN_NQI_VOZ_DAY;

 TYPE T_UMTS_NSN_NQI_VOZ_DAY IS TABLE OF  UMTS_NSN_NQI_VOZ_DAY%ROWTYPE INDEX BY PLS_INTEGER;
 UMTS_NSN_NQI_VOZ_DA2 T_UMTS_NSN_NQI_VOZ_DAY;


C_LIMIT PLS_INTEGER := 1000;
PCNT    NUMBER := 0;

BEGIN

-- Open | Fetch | Close

OPEN CUR_NSN_NQI_VOZ_DAY  (P_FECHA_DESDE, P_FECHA_HASTA);

LOOP

FETCH CUR_NSN_NQI_VOZ_DAY BULK COLLECT INTO NSN_NQI_VOZ_DAY LIMIT C_LIMIT;

FOR I IN 1 .. NSN_NQI_VOZ_DAY.COUNT LOOP

  PCNT := PCNT + 1;

UMTS_NSN_NQI_VOZ_DA2(I).FECHA                                 := NSN_NQI_VOZ_DAY(I).FECHA          ;
UMTS_NSN_NQI_VOZ_DA2(I).OSSRC                                 := NSN_NQI_VOZ_DAY(I).OSSRC          ;
UMTS_NSN_NQI_VOZ_DA2(I).WCELL_GID                             := NSN_NQI_VOZ_DAY(I).WCELL_GID      ;
UMTS_NSN_NQI_VOZ_DA2(I).WBTS_GID                              := NSN_NQI_VOZ_DAY(I).WBTS_GID       ;
UMTS_NSN_NQI_VOZ_DA2(I).RNC_GID                               := NSN_NQI_VOZ_DAY(I).RNC_GID        ;
UMTS_NSN_NQI_VOZ_DA2(I).WCELL_NAME                            := NSN_NQI_VOZ_DAY(I).WCELL_NAME     ;
UMTS_NSN_NQI_VOZ_DA2(I).WBTS_NAME                             := NSN_NQI_VOZ_DAY(I).WBTS_NAME      ;
UMTS_NSN_NQI_VOZ_DA2(I).RNC_NAME                              := NSN_NQI_VOZ_DAY(I).RNC_NAME       ;
UMTS_NSN_NQI_VOZ_DA2(I).ALM                                   := NSN_NQI_VOZ_DAY(I).ALM            ;
UMTS_NSN_NQI_VOZ_DA2(I).MERCADO                               := NSN_NQI_VOZ_DAY(I).MERCADO        ;
UMTS_NSN_NQI_VOZ_DA2(I).PAIS                                  := NSN_NQI_VOZ_DAY(I).PAIS           ;
UMTS_NSN_NQI_VOZ_DA2(I).QDA_NUM                               := NSN_NQI_VOZ_DAY(I).QDA_NUM        ;
UMTS_NSN_NQI_VOZ_DA2(I).QDA_DEN                               := NSN_NQI_VOZ_DAY(I).QDA_DEN        ;
UMTS_NSN_NQI_VOZ_DA2(I).QDR_NUM                               := NSN_NQI_VOZ_DAY(I).QDR_NUM        ;
UMTS_NSN_NQI_VOZ_DA2(I).QDR_DEN                               := NSN_NQI_VOZ_DAY(I).QDR_DEN        ;

END LOOP;

IF CUR_NSN_NQI_VOZ_DAY%NOTFOUND THEN
 FORALL I IN UMTS_NSN_NQI_VOZ_DA2.FIRST .. PCNT
 INSERT INTO UMTS_NSN_NQI_VOZ_DAY VALUES UMTS_NSN_NQI_VOZ_DA2(I);

   EXIT;
ELSE

   FORALL I IN UMTS_NSN_NQI_VOZ_DA2.FIRST .. UMTS_NSN_NQI_VOZ_DA2.LAST
   INSERT INTO UMTS_NSN_NQI_VOZ_DAY VALUES UMTS_NSN_NQI_VOZ_DA2(I);

END IF;

PCNT := 0;

END LOOP;

COMMIT;

END P_UMTS_NSN_NQI_VOZ_DAY_INS;
