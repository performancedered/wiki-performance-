IF CUR_NSN_DIRECT_NQI_HOUR%NOTFOUND THEN

   FORALL I IN UMTS_NSN_NQI_VOZ_HOU2.FIRST .. PCNT
   INSERT INTO CLDD_NQI_1ST_AUX_HOUR VALUES UMTS_NSN_NQI_VOZ_HOU2(I);

   EXIT;

ELSE

   FORALL I IN UMTS_NSN_NQI_VOZ_HOU2.FIRST .. UMTS_NSN_NQI_VOZ_HOU2.LAST
   INSERT INTO CLDD_NQI_1ST_AUX_HOUR VALUES UMTS_NSN_NQI_VOZ_HOU2(I);

END IF;

PCNT := 0;

END LOOP;

COMMIT;

END P_UMTS_CLDD_NQI_1ST_AUX_INS;
