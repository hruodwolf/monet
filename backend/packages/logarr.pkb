create or replace package body logarr
is
  -- ZUTUN: und was ist mit autonomous transaction???

  LOG_ERROR   constant logs.stufe%type := 'ERROR';
  LOG_WARN    constant logs.stufe%type := 'WARN';
  LOG_INFO    constant logs.stufe%type := 'INFO';
  LOG_DEBUG   constant logs.stufe%type := 'DEBUG';

    PROCEDURE INS_LOGS
    (
     in_LOGS_ID       IN LOGS.LOGS_ID%TYPE
    ,in_ERSTELLT_AM   IN LOGS.ERSTELLT_AM%TYPE
    ,in_ERSTELLT_VON  IN LOGS.ERSTELLT_VON%TYPE
    ,in_GEAENDERT_AM  IN LOGS.GEAENDERT_AM%TYPE
    ,in_GEAENDERT_VON IN LOGS.GEAENDERT_VON%TYPE
    ,in_VERSION       IN LOGS.VERSION%TYPE
    ,in_ZEITSTEMPEL   IN LOGS.ZEITSTEMPEL%TYPE
    ,in_STUFE         IN LOGS.STUFE%TYPE
    ,in_MODUL         IN LOGS.MODUL%TYPE
    ,in_ZEILE         IN LOGS.ZEILE%TYPE
    ,in_MELDUNG       IN LOGS.MELDUNG%TYPE
    ) IS
  BEGIN
    INSERT INTO LOGS
      (
       LOGS_ID
      ,ERSTELLT_AM
      ,ERSTELLT_VON
      ,GEAENDERT_AM
      ,GEAENDERT_VON
      ,VERSION
      ,ZEITSTEMPEL
      ,STUFE
      ,MODUL
      ,ZEILE
      ,MELDUNG
      )
    VALUES
      (
       in_LOGS_ID
      ,in_ERSTELLT_AM
      ,in_ERSTELLT_VON
      ,in_GEAENDERT_AM
      ,in_GEAENDERT_VON
      ,in_VERSION
      ,in_ZEITSTEMPEL
      ,in_STUFE
      ,in_MODUL
      ,in_ZEILE
      ,in_MELDUNG
      );
  END INS_LOGS;
  
  function aufrufer return varchar2
  is
  
  begin
    return Utl_Call_Stack.Concatenate_Subprogram (Utl_Call_Stack.Subprogram (Utl_Call_Stack.Dynamic_Depth () - 4));
  end aufrufer;

  procedure error (meldung in logs.meldung%type) is
  begin
    null;
  end error;

  procedure warn (meldung in logs.meldung%type) is
  begin
    null;
  end warn;

  procedure info (meldung in logs.meldung%type) is
  begin
    null;
  end info;

  procedure debug (meldung in logs.meldung%type) is
  begin
    
    INS_LOGS (   in_LOGS_ID => 1
                ,in_ERSTELLT_AM => systimestamp
                ,in_ERSTELLT_VON => user
                ,in_GEAENDERT_AM  => systimestamp
                ,in_GEAENDERT_VON => user
                ,in_VERSION => 1
                ,in_ZEITSTEMPEL   => systimestamp
                ,in_STUFE  => LOG_DEBUG
                ,in_MODUL  => aufrufer
                ,in_ZEILE  => 1
                ,in_MELDUNG => meldung
              );
  end debug;

end logarr;

show err