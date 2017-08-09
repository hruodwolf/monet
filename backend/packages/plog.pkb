CREATE OR REPLACE PACKAGE BODY Plog IS
  -- ZUTUN: und was ist mit autonomous transaction???
  --        schema_name als spalte entfernen - unsinnig
  --        plog soll lediglich als fasade dienen, die logik wird in "logarr" umgesetzt

  -- Rumpf-Konstanten d.h. diese sind nur innerhalb des Rumpfes sichtbar. Momentan besteht keine Notwendigkeit diese als Global zu deklarieren.
  C_Off     CONSTANT Logsaetze.Stufe%TYPE := 'OFF';
  C_Fatal   CONSTANT Logsaetze.Stufe%TYPE := 'FATAL';
  C_Error   CONSTANT Logsaetze.Stufe%TYPE := 'ERROR';
  C_Warn    CONSTANT Logsaetze.Stufe%TYPE := 'WARN';
  C_Info    CONSTANT Logsaetze.Stufe%TYPE := 'INFO';
  C_Debug   CONSTANT Logsaetze.Stufe%TYPE := 'DEBUG';
  C_All     CONSTANT Logsaetze.Stufe%TYPE := 'ALL';

  ---------------<lokale funktionen>---------------------------------
  PROCEDURE Loggen (Pi_Logsatz IN Logsaetze%ROWTYPE) IS
  BEGIN
    -- ZUTUN: 1. pi als typ von logsaetze übergeben. 2. log-objekt vorher in einer zwischen prozedur aufbereiten.
    --        hier erfolg ein reiner insert ohne jegliche logik und aufbreitung.

    INSERT INTO Logsaetze
         VALUES Pi_Logsatz;
  /*
  insert into logsaetze
    (
     logs_id
    ,erstellt_am
    ,erstellt_von
    ,stufe
    ,meldung
    ,schema_name
    ,objekt_name
    ,modul_name
    ,zeile
    )
    values
    (
     -1 -- hier kommt die sequenz
     ,systimestamp
     ,user -- hier kommt später utl.gib_benutzer
     ,pi_stufe
     ,pi_meldung
     ,'<LEER>'
     ,'<LEER>'
     ,'<LEER>'
     ,-1
    );

*/
  END Loggen;

  PROCEDURE Aufbereiten_Und_Loggen (Pi_Meldung   IN Logsaetze.Meldung%TYPE
                                  , Pi_Stufe     IN Logsaetze.Stufe%TYPE) IS
  BEGIN
    -- ZUTUN: hier werden zusätzliche werte ermittelt wie modul_name, zeile usw. und anschließend die proc loggen aufgerufen.
    NULL;
  END Aufbereiten_Und_Loggen;

  FUNCTION Modul_Ermitteln (Pi_Name IN User_Source.Name%TYPE, Pi_Line IN User_Source.Line%TYPE)
    RETURN VARCHAR2 IS
    /*
    || Ticket    : ?
    ||
    || Aufgabe   : Ermitteln eines Moduls anhand des Objekt-Namens und Quelltext-Linie.
    ||
    ||
    || Parameter : Pi_Name: Name des Objekts. In diesem Fall immer nur Paket-Name.
    ||             Pi_Line: Zeile.
    ||
    || Autor     : 22.12.2015, hruodwolf
    || Updates   :
    */
    L_Modul                        VARCHAR2 (92);
    C_Type_Package_Body   CONSTANT VARCHAR2 (12) := 'PACKAGE BODY';
  BEGIN
    SELECT Name || '.' || Proc
      INTO L_Modul
      FROM (SELECT Name
                 , TYPE
                 , Line
                 , Text
                 , REGEXP_REPLACE (Text
                                 , '^ *(function|procedure) +([_0-9a-z]*).*'
                                 , '\2'
                                 , 1
                                 , 0
                                 , 'i')
                     Proc
                 , RANK () OVER (ORDER BY Line DESC) Rang
              FROM User_Source
             WHERE REGEXP_LIKE (Text, '^ *(function|procedure) +[_0-9a-z]*.*', 'i')
               AND Name = Pi_Name
               AND TYPE = C_Type_Package_Body
               AND Line < Pi_Line)
     WHERE Rang = 1;

    RETURN L_Modul;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '-';
  END;

  ---------------</lokale funktionen>---------------------------------

  PROCEDURE Fatal (Pi_Meldung IN Logsaetze.Meldung%TYPE) IS
  BEGIN
    Aufbereiten_Und_Loggen (Pi_Meldung => Pi_Meldung, Pi_Stufe => C_Fatal);
  END Fatal;

  PROCEDURE Error (Pi_Meldung IN Logsaetze.Meldung%TYPE) IS
  BEGIN
    Aufbereiten_Und_Loggen (Pi_Meldung => Pi_Meldung, Pi_Stufe => C_Error);
  END Error;

  PROCEDURE Warn (Pi_Meldung IN Logsaetze.Meldung%TYPE) IS
  BEGIN
    Aufbereiten_Und_Loggen (Pi_Meldung => Pi_Meldung, Pi_Stufe => C_Warn);
  END Warn;

  PROCEDURE Info (Pi_Meldung IN Logsaetze.Meldung%TYPE) IS
  BEGIN
    Aufbereiten_Und_Loggen (Pi_Meldung => Pi_Meldung, Pi_Stufe => C_Info);
  END Info;

  PROCEDURE Debug (Pi_Meldung IN Logsaetze.Meldung%TYPE) IS
  BEGIN
    Aufbereiten_Und_Loggen (Pi_Meldung => Pi_Meldung, Pi_Stufe => C_Debug);
  END Debug;
END Plog;