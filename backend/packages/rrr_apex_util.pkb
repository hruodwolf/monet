/* Formatted on 20.12.2012 11:22:52 (QP5 v5.185.11230.41888) */
CREATE OR REPLACE PACKAGE BODY rrr_apex_utl
IS
   /*
   || Name      : ets_apex_utl
   ||
   || Aufgabe   :
   ||
   || Autor     : 26.09.2012, ARR
   || Updates   :
   */
   -------------------------------------------------------------------
   sbodydate                       VARCHAR2 (80)
                                      := '$Date: 2012-10-05 15:00:30 +0200 (Fr, 05 Okt 2012) $';
   sbodyrevision                   VARCHAR2 (80) := '$Revision: 99 $';
   sbodyauthor                     VARCHAR2 (80) := '$Author: PTO $';

   -- Konstanten für die Page_id
   c_app_page_id          CONSTANT VARCHAR2 (11) := 'APP_PAGE_ID';
   c_app_id               CONSTANT VARCHAR2 (6) := 'APP_ID';
   c_f_letzte_seiten_nr   CONSTANT VARCHAR2 (18) := 'F_LETZTE_SEITEN_NR';
   -- Konstanten für die Seiten-Navigation
   c_nav_col              CONSTANT VARCHAR2 (11) := 'RNAVIGATION';



   FUNCTION loesche_letztes_element (in_col_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_existiert       BOOLEAN NOT NULL := FALSE;
      l_ist_geloescht   BOOLEAN NOT NULL := FALSE;
      l_seq_id          PLS_INTEGER;
      l_anzahl          PLS_INTEGER;
   BEGIN
      -- Prüfen ob die Collection existiert
      l_existiert :=
         apex_collection.collection_exists (p_collection_name => in_col_name);

      IF l_existiert
      THEN
         -- Höchste Sequence in der Collection ermitteln
         SELECT MAX (TO_NUMBER (seq_id)), COUNT (1)
           INTO l_seq_id, l_anzahl
           FROM apex_collections
          WHERE collection_name = in_col_name;

         IF l_anzahl = 1
         THEN
            -- Beim letzten Elementen in der Collection, die Collection ganz löschen
            apex_collection.delete_collection (
               p_collection_name => in_col_name);
         ELSE
            -- Fall mehr wie ein Elemente vorhandne, dann nur den letzten löschen
            apex_collection.delete_member (p_collection_name   => in_col_name,
                                           p_seq               => l_seq_id);
         END IF;

         l_ist_geloescht := TRUE;
      END IF;

      RETURN l_ist_geloescht;
   END loesche_letztes_element;

   FUNCTION gib_letzte_seiten_nr
      RETURN PLS_INTEGER
   IS
      l_letzte_seiten_nr   PLS_INTEGER := NULL;
      l_existiert          BOOLEAN := FALSE;
   BEGIN
      -- Prüfen ob die Collection existiert
      l_existiert :=
         apex_collection.collection_exists (p_collection_name => c_nav_col);


      IF l_existiert
      THEN
         -- Letzte Seite ermitteln
         SELECT col.n001
           INTO l_letzte_seiten_nr
           FROM    (SELECT seq_id, n001
                      FROM apex_collections
                     WHERE collection_name = c_nav_col) col
                JOIN
                   (SELECT MAX (TO_NUMBER (seq_id)) seq_id
                      FROM apex_collections
                     WHERE collection_name = c_nav_col) max_seq
                ON (col.seq_id = max_seq.seq_id);
      END IF;

      RETURN l_letzte_seiten_nr;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END gib_letzte_seiten_nr;

   PROCEDURE setze_seiten_nr
   IS
      /*
      || Name      : letzte_seite_speichern
      ||
      || Aufgabe   : Prozedur zum Verwalten der Rückwärtsnavigation.
      ||             In einer Collection werden Seiten gespeichert.
      ||
      || Parameter :
      ||
      || Returnwert:
      ||
      ||
      || Autor     : 26.09.2012, ARR
      || Updates   :
      */
      l_existiert            BOOLEAN := FALSE;
      l_aktuelle_seiten_nr   PLS_INTEGER;
      l_aktuelle_app_nr      PLS_INTEGER;
      l_seiten_titel         VARCHAR2 (100);
   BEGIN
      l_aktuelle_seiten_nr :=
         TO_NUMBER (APEX_UTIL.get_session_state (p_item => c_app_page_id));
      l_aktuelle_app_nr :=
         TO_NUMBER (APEX_UTIL.get_session_state (p_item => c_app_id));

      IF l_aktuelle_seiten_nr IS NOT NULL
      THEN
         -- Prüfen ob die Collection existiert
         l_existiert :=
            apex_collection.collection_exists (p_collection_name => c_nav_col);

         -- Falls nicht dann eine neue Apex-Collection anlegen
         IF NOT l_existiert
         THEN
            apex_collection.create_collection (p_collection_name => c_nav_col);
         END IF;

         -- Prüfen ob das letzte Element aus der Collection mit der
         -- aktuellen Seite übereinstimmt, wenn ja, dann wird die Seite nicht gespeichert
         BEGIN
            SELECT col.n001
              INTO l_aktuelle_seiten_nr
              FROM    (SELECT seq_id, n001
                         FROM apex_collections
                        WHERE collection_name = c_nav_col) col
                   JOIN
                      (SELECT MAX (TO_NUMBER (seq_id)) seq_id
                         FROM apex_collections
                        WHERE collection_name = c_nav_col) max_seq
                   ON     (col.seq_id = max_seq.seq_id)
                      AND col.n001 = l_aktuelle_seiten_nr;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- Seiten Titel ermitteln
               SELECT page_title
                 INTO l_seiten_titel
                 FROM APEX_APPLICATION_PAGES
                WHERE     page_id = l_aktuelle_seiten_nr
                      AND application_id = l_aktuelle_app_nr;

               -- Aktuelle Seiteninformationen in der Collection speichern
               apex_collection.add_member (
                  p_collection_name   => c_nav_col,
                  p_c001              => l_seiten_titel,
                  p_n001              => l_aktuelle_seiten_nr);
         END;
      END IF;
   END setze_seiten_nr;

   ----------------------------------------------------------------------

   PROCEDURE navigiere_auf_letzte_seite
   IS
      /*
      || Name      : UEBERARBEITEN!!!!!!!!!!!!!!!!
      ||
      || Aufgabe   : Funktion gib letzte SeitenNr aus der Navi-Collection zurück.
      ||             Verwendung für Rückwärtsnavigation.
      ||
      || Parameter :
      ||
      || Returnwert:
      ||
      ||
      || Autor     : 26.09.2012, ARR
      || Updates   :
      */
      l_letzte_seiten_nr   PLS_INTEGER := NULL;
      l_ist_geloescht      BOOLEAN := FALSE;
   BEGIN
      -- Letztes Element aus der Tabelle entfernen. Weiter machen wenn Rückwert TRUE ist.
      l_ist_geloescht := loesche_letztes_element (in_col_name => c_nav_col);

      IF l_ist_geloescht
      THEN
         -- Letzte Seiten Nr. ermitteln
         l_letzte_seiten_nr := gib_letzte_seiten_nr ();
      END IF;

      -- Letzte Seite dem Anwendungselement zuweisen
      APEX_UTIL.SET_SESSION_STATE (p_name    => c_f_letzte_seiten_nr,
                                   p_value   => l_letzte_seiten_nr);
   END navigiere_auf_letzte_seite;
END rrr_apex_utl;