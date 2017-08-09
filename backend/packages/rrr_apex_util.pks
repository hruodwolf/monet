/* Formatted on 20.12.2012 11:08:23 (QP5 v5.185.11230.41888) */
CREATE OR REPLACE PACKAGE rrr_apex_utl
IS
   /*
   || Name      : ets_auth
   ||
   || Aufgabe   :
   ||
   || Autor     : 26.09.2012, ARR
   || Updates   :
   */
   -------------------------------------------------------------------
   sbodydate       VARCHAR2 (80)
                      := '$Date: 2012-10-05 15:00:30 +0200 (Fr, 05 Okt 2012) $';
   sbodyrevision   VARCHAR2 (80) := '$Revision: 99 $';
   sbodyauthor     VARCHAR2 (80) := '$Author: PTO $';

   -------------------------------------------------------------------

   FUNCTION loesche_letztes_element (in_col_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION gib_letzte_seiten_nr
      RETURN PLS_INTEGER;

   PROCEDURE setze_seiten_nr;

   PROCEDURE navigiere_auf_letzte_seite;
END rrr_apex_utl;