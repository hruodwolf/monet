/*
CREATE TYPE FEIERTAG_T AS OBJECT (
 FEIERTAG_NAME VARCHAR2(25),
 FEIERTAG_DATUM DATE
 );
 
 create or replace type feiertag_tab is varray (2) of feiertag_t;
 */
 
 set serveroutput on;
 Declare
   Type Feiertag_T Is Record
    ( Name Varchar2(25),
      Datum Date
    );
    
    Type Feiertag_Tab Is Varray(2) of feiertag_t;
   FEIERTAGE FEIERTAG_TAB := FEIERTAG_TAB ();
   
   V_Feiertag Feiertag_T;
   v_temp number;
 BEGIN
   Feiertage.Extend (2);
   
   V_Feiertag.Name := 'mai';
   v_feiertag.datum := sysdate;

   FEIERTAGE(1) := v_feiertag;
   
   V_Feiertag.Name := 'juni';
   V_Feiertag.Datum := Sysdate-1;

   FEIERTAGE(2) := v_feiertag;
 
   
   FOR I IN feiertage.first..feiertage.last LOOP
    DBMS_OUTPUT.PUT_LINE(FEIERTAGE(I).name || ' - ' || FEIERTAGE(I).datum);
   END LOOP;
   
   v_temp := 1;
   Case 
   When V_Temp = 1 Then
    Dbms_Output.Put_Line('erster..');
    When V_Temp = 1 And 1=1 Then
     Dbms_Output.Put_Line('zweiter..');
     Else
     DBMS_OUTPUT.PUT_LINE('else..');
     end case;
   
 /*
   SELECT * INTO V_FEIERTAG FROM TABLE(FEIERTAGE) T where t.datum = trunc(sysdate) - 2;
   
   DBMS_OUTPUT.PUT_LINE(V_FEIERTAG.name || ' - ' || V_FEIERTAG.datum);
   */
   
 end;