/* Formatted on 14.12.2012 12:18:52 (QP5 v5.185.11230.41888) */
SET SERVEROUTPUT ON;

declare
  --l_datum date := TO_DATE ('30.05.2013');
  l_datum date := null;
BEGIN
   IF kalender.ist_feiertag (l_datum, kalender.c_he)
   THEN
      DBMS_OUTPUT.put_line ('ist feiertag...');
   ELSE
      DBMS_OUTPUT.put_line ('ist KEIN feiertag...');
   END IF;
END;

/* Formatted on 14.12.2012 13:00:12 (QP5 v5.185.11230.41888) */
DECLARE
   tab_feiertage   KALENDER.T_FEIERTAG_TABELLE;
BEGIN
   tab_feiertage := kalender.gib_feiertag_bezeichnungen (kalender.c_bb);

   FOR l_idx IN tab_feiertage.FIRST .. tab_feiertage.LAST
   LOOP
      DBMS_OUTPUT.put_line (TO_CHAR (tab_feiertage (l_idx).feiertag));
   END LOOP;
END;
/* Formatted on 14.12.2012 13:05:37 (QP5 v5.185.11230.41888) */
DECLARE
   l_datum   DATE;
BEGIN
   l_datum := KALENDER.GIB_OSTERDATUM (2013);
   DBMS_OUTPUT.put_line (TO_CHAR (l_datum, 'DD/MM/YYYY'));
END;

declare
  l_datum date := TO_DATE ('02.01.2013');

BEGIN
   IF kalender.ist_werktag (l_datum, kalender.c_he)
   THEN
      DBMS_OUTPUT.put_line (to_char(l_datum) || 'ist ein werktag...');
   ELSE
      DBMS_OUTPUT.put_line (to_char(l_datum) || 'ist KEIN werktag...');
   END IF;
END;



declare
  e_test exception;
  PRAGMA EXCEPTION_INIT (e_test, -20000);  -- assign error code to exception
begin
 RAISE_APPLICATION_ERROR(-20000, 'Account past due.');
 
 exception
 when e_test
 then
     raise;
 
end;


declare
  l_jahr constant pls_integer := null;
  l_osterdatum date;
begin
  l_osterdatum := kalender.gib_osterdatum(l_jahr);
  dbms_output.put_line(to_char(l_osterdatum));
end;


DECLARE
   tab_feiertage   KALENDER.T_FEIERTAG_TABELLE;
   l_datum varchar(20);
   l_feiertag varchar(25);
BEGIN
   tab_feiertage := kalender.gib_feiertage (2013, kalender.c_au);

   FOR l_idx IN tab_feiertage.FIRST .. tab_feiertage.LAST
   LOOP
       l_datum := TO_CHAR (tab_feiertage (l_idx).datum, 'DD/MM/YYYY HH24:MI:SS');
       l_feiertag :=  TO_CHAR (tab_feiertage (l_idx).feiertag); 
   
      DBMS_OUTPUT.put_line (to_char(l_idx) || '. ' || l_datum || ' - ' || l_feiertag);
   END LOOP;
END;


select order_date, case when kalender.ist_feiertag_sql(order_date) = 1 then ' ist feiertag ' else 'kein feiertag' end from oehr_orders;


DECLARE
   tab_we_datum   KALENDER.t_we_datum_tabelle;
   l_datum varchar(20);
   
BEGIN
   tab_we_datum := kalender.gib_monend_am_wochend_tab (null);

   FOR l_idx IN tab_we_datum.FIRST .. tab_we_datum.LAST
   LOOP
       l_datum := TO_CHAR (tab_we_datum (l_idx), 'DD/MM/YYYY');
       
   
      DBMS_OUTPUT.put_line (to_char(l_idx) || '. ' || l_datum);
   END LOOP;
END;

declare
  l_datum constant date := null;
begin
  IF kalender.ist_arbeitstag (l_datum, kalender.c_he)
   THEN
      DBMS_OUTPUT.put_line (to_char(l_datum) || 'ist ein arbeitstag...');
   ELSE
      DBMS_OUTPUT.put_line (to_char(l_datum) || 'ist KEIN arbeitstag...');
   END IF;
end;


declare
 l_var date;
begin

 --l_var := to_date('25.02.2013');
 l_var := sysdate;
 dbms_output.put_line(to_char(l_var, 'DD/MM/YYYY HH24:MI:SS'));

end;