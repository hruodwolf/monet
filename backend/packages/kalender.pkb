/* Formatted on 05.04.2013 15:56:54 (QP5 v5.185.11230.41888) */
CREATE OR REPLACE PACKAGE BODY kalender
IS

-- ZUTUN:
-- Statt eine Liste mit Feiertagen generieren, k�nnte man eine tab. Funktion erstellen. Diese
-- dann hinter einer DB-Ansicht verstecken und auch von au�en aufrufen.
-- funktion feiertage (pi_jahr in number default null) wenn kein parameter eingegeben ist dann f�r
-- das aktuell jahr berechnen.
-- Weitere Ideen:
-- 1. Funktion die mir den n�chsten Br�ckentag errechnet.
-- 2. Funktion die mir den n�chsten Feiertag errechnet.
-- 3. Funktion die mir anzahl der Arbeitstage im Monat errechnet.
-- 4. Funktion die mir Tage, Monate, Jare bis zur Rente errechnet
-- 4. Doku anlegen mit dem Hinweis dass es sich um einen deutschen Kaleder handelt

   FUNCTION ist_werktag (in_datum         DATE,
                         in_bundesland    t_bland_kurz DEFAULT NULL)
      RETURN BOOLEAN
   IS
      /*
      || Name      : ist_werktag
      ||
      || Aufgabe   : Funktion ermittelt ob das Abfrage-Datum ein Werktag ist.
      ||             Optional kann ein Bundesland angegeben werden um dessen
      ||             Feiertage bei der Ermittlung zu ber�cksichtigen. Ansonsten
      ||             werden nur Bundeseinheitliche Feiertage in Betracht gezogen.
      ||             Nach Paragraph 3 Abs. 2 Bundesurlaubsgesetz (BUrlG) gelten
      ||             als Werktag alle Kalendertage, die nicht Sonn- oder
      ||             gesetzliche Feiertage sind.
      ||
      || Parameter : in_datum: Abfrage-Datum
      ||             in_bundesland: Bundesland z.B. c_he (Hessen)
      ||
      || R�ckwert  : l_ist_werktag: Ist Abfrage-Datum ein Feiertag wird TRUE
      ||                            zur�ckgegeben, ansonsten FALSE.
      ||
      || Autor     : 18.12.2012, ARR
      ||
      || Updates   :
      */
      l_ist_werktag    BOOLEAN NOT NULL := FALSE;
      l_ist_feiertag   BOOLEAN NOT NULL := FALSE;
      l_wochentag_nr   PLS_INTEGER;
   BEGIN
      IF in_datum IS NOT NULL
      THEN
         -- Wochentag Nummer ermitteln z.B. 7 f�r Sonntag, 1 f�r Montag
         l_wochentag_nr :=
            TO_NUMBER (TO_CHAR (in_datum, 'D', 'NLS_DATE_LANGUAGE=GERMAN'));
         -- Ermitteln ob das Datum ein Feiertag ist
         l_ist_feiertag :=
            ist_feiertag (in_datum => in_datum, in_bundesland => in_bundesland);

         -- Ermitteln ob das Datum ein Werktag ist
         l_ist_werktag :=
            NVL (l_wochentag_nr <> 7 AND NOT l_ist_feiertag, FALSE);
      ELSE
         raise_application_error (-20201,
                                  'Abfrage-Datum ist nicht definiert!');
      END IF;

      RETURN l_ist_werktag;
   END ist_werktag;

   FUNCTION ist_feiertag (in_datum        IN DATE,
                          in_bundesland   IN t_bland_kurz DEFAULT NULL)
      RETURN BOOLEAN
   IS
      /*
      || Name      : ist_feiertag
      ||
      || Aufgabe   : Funktion ermittelt ob das Abfrage-Datum ein Feiertag ist.
      ||             Optional kann ein Bundesland angegeben werden um dessen
      ||             Feiertage bei der Ermittlung zu ber�cksichtigen. Ansonsten
      ||             werden nur Bundeseinheitliche Feiertage in Betracht gezogen.
      ||
      || Parameter : in_datum: Abfrage-Datum
      ||             in_bundesland: Bundesland z.B. c_he (Hessen)
      ||
      || R�ckwert  : l_ist_feiertag: Ist Abfrage-Datum ein Werktag wird TRUE
      ||                             zur�ckgegeben, ansonsten FALSE.
      ||
      || Autor     : 19.12.2012, ARR
      ||
      || Updates   :
      */

      tab_jahres_feiertage   t_feiertag_tabelle;
      l_jahr                 PLS_INTEGER;
      l_ist_feiertag         BOOLEAN NOT NULL := FALSE;
      l_datum                DATE;
      l_in_datum             DATE;
   BEGIN
      IF in_datum IS NOT NULL
      THEN
         l_in_datum := TRUNC (in_datum);
         l_jahr := TO_NUMBER (TO_CHAR (l_in_datum, 'YYYY'));
         tab_jahres_feiertage :=
            gib_feiertage (in_jahr => l_jahr, in_bundesland => in_bundesland);

         FOR l_idx IN tab_jahres_feiertage.FIRST .. tab_jahres_feiertage.LAST
         LOOP
            l_datum := tab_jahres_feiertage (l_idx).datum;

            IF l_datum = l_in_datum
            THEN
               l_ist_feiertag := TRUE;
               EXIT;
            END IF;
         END LOOP;
      ELSE
         raise_application_error (-20201,
                                  'Abfrage-Datum ist nicht definiert!');
      END IF;

      RETURN l_ist_feiertag;
   END ist_feiertag;

   FUNCTION ist_feiertag_sql (in_datum        IN DATE,
                              in_bundesland   IN t_bland_kurz DEFAULT NULL)
      RETURN NUMBER
   IS
      /*
      || Name      : ist_feiertag_sql
      ||
      || Aufgabe   : Funktion ermittelt ob das Abfrage-Datum ein Feiertag ist.
      ||             Optional kann ein Bundesland angegeben werden um dessen
      ||             Feiertage bei der Ermittlung zu ber�cksichtigen. Ansonsten
      ||             werden nur Bundeseinheitliche Feiertage in Betracht gezogen.
      ||             Verwendung im SQL-Kontex z.B. in einer SQL-Abfrage.
      ||
      || Parameter : in_datum: Abfrage-Datum
      ||             in_bundesland: Bundesland z.B. c_he (Hessen)
      ||
      || R�ckwert  : l_ist_feiertag: Ist Abfrage-Datum ein Werktag wird 1
      ||                             zur�ckgegeben, ansonsten 0.
      ||
      || Autor     : 19.12.2012, ARR
      ||
      || Updates   :
      */
      l_ist_feiertag   BOOLEAN;
   BEGIN
      l_ist_feiertag :=
         ist_feiertag (in_datum => in_datum, in_bundesland => in_bundesland);

      RETURN CASE WHEN l_ist_feiertag THEN 1 ELSE 0 END;
   END ist_feiertag_sql;

   FUNCTION ist_wochenende (in_datum IN DATE)
      RETURN BOOLEAN
   IS
      /*
      || Name      : ist_wochenende
      ||
      || Aufgabe   : Funktion ermittelt ob das Abfrage-Datum am Wochenende liegt.
      ||
      || Parameter : in_datum: Abfrage-Datum
      ||
      || R�ckwert  : l_ist_wochenende: Liegt Abfrage-Datum am Wochenende wird TRUE
      ||                               zur�ckgegeben, ansonsten FALSE.
      ||
      || Autor     : 19.12.2012, ARR
      ||
      || Updates   :
      */
      l_ist_wochenende   BOOLEAN := NULL;
      l_wochentag_nr     PLS_INTEGER;
   BEGIN
      IF in_datum IS NOT NULL
      THEN
         --Wochentag Nummer ermitteln 1-7
         l_wochentag_nr :=
            TO_NUMBER (TO_CHAR (in_datum, 'D', 'NLS_DATE_LANGUAGE=GERMAN'));

         -- 6 Samstag und 7 Sonntag dann ist Wochenende
         l_ist_wochenende := NVL (l_wochentag_nr IN (6, 7), FALSE);
      ELSE
         raise_application_error (-20201,
                                  'Abfrage-Datum ist nicht definiert!');
      END IF;

      RETURN l_ist_wochenende;
   END ist_wochenende;


   FUNCTION ist_arbeitstag (in_datum        IN DATE,
                            in_bundesland   IN t_bland_kurz DEFAULT NULL)
      RETURN BOOLEAN
   IS
      /*
      || Name      : ist_arbeitstag
      ||
      || Aufgabe   : Funktion ermittelt ob das Abfrage-Datum ein Arbeitstag ist.
      ||             Wobei hier von einer 5-Tage Woche d.h. Montag bis
      ||             einschliesslich Freitag ausgegangen wird.
      ||             Optional kann ein Bundesland angegeben werden um dessen
      ||             Feiertage bei der Ermittlung zu ber�cksichtigen. Ansonsten
      ||             werden nur Bundeseinheitliche Feiertage in Betracht gezogen.
      ||
      || Parameter : in_datum:      Abfrage-Datum
      ||             in_bundesland: Bundesland z.B. c_he (Hessen)
      ||
      || R�ckwert  : l_ist_arbeitstag: Ist Abfrage-Datum ein Arbeitstag so wird TRUE
      ||                               zur�ckgegeben, ansonsten FALSE.
      ||
      || Autor     : 19.12.2012, ARR
      ||
      || Updates   :
      */
      l_ist_wochenende   BOOLEAN;
      l_ist_feiertag     BOOLEAN;
      l_ist_arbeitstag   BOOLEAN;
   BEGIN
      IF in_datum IS NOT NULL
      THEN
         l_ist_wochenende := ist_wochenende (in_datum => in_datum);
         l_ist_feiertag :=
            ist_feiertag (in_datum => in_datum, in_bundesland => in_bundesland);

         l_ist_arbeitstag :=
            NVL (NOT l_ist_wochenende AND NOT l_ist_feiertag, FALSE);
      ELSE
         raise_application_error (-20201,
                                  'Abfrage-Datum ist nicht definiert!');
      END IF;

      RETURN l_ist_arbeitstag;
   END ist_arbeitstag;

   FUNCTION gib_osterdatum (in_jahr PLS_INTEGER)
      RETURN DATE
   IS
      /*
      || Name      : gib_osterdatum
      ||
      || Aufgabe   : Funktion ermittelt zum Abfrage-Jahr das Osterdatum.
      ||             Formel von Kinkelin und Zeller
      ||             1. die S�kularzahl:                                       K(X) = X div 100
      ||             2. die s�kulare Mondschaltung:                            M(K) = 15 + (3K + 3) div 4 - (8K + 13) div 25
      ||             3. die s�kulare Sonnenschaltung:                          S(K) = 2 - (3K + 3) div 4
      ||             4. den Mondparameter:                                     A(X) = X mod 19
      ||             5. den Keim f�r den ersten Vollmond im Fr�hling:          D(A,M) = (19A + M) mod 30
      ||             6. die kalendarische Korrekturgr��e:                      R(D,A) = D div 29 + (D div 28 - D div 29) (A div 11)
      ||             7. die Ostergrenze:                                       OG(D,R) = 21 + D - R
      ||             8. den ersten Sonntag im M�rz:                            SZ(X,S) = 7 - (X + X div 4 + S) mod 7
      ||             9. die Entfernung des Ostersonntags von der
      ||                Ostergrenze (Osterentfernung in Tagen):                OE(OG,SZ) = 7 - (OG - SZ) mod 7
      ||             10.das Datum des Ostersonntags als M�rzdatum
      ||                (32. M�RZ = 1. APRIL USW.):                            OS = OG + OE
      ||
      || Parameter : in_jahr     :  Abfrage-Jahr
      ||
      || R�ckwert  : l_osterdatum:  Osterdatum.
      ||
      || Autor     : 19.12.2012, ARR
      ||
      || Updates   :
      */
      k              PLS_INTEGER;
      m              PLS_INTEGER;
      s              PLS_INTEGER;
      a              PLS_INTEGER;
      d              PLS_INTEGER;
      r              PLS_INTEGER;
      og             PLS_INTEGER;
      sz             PLS_INTEGER;
      oe             PLS_INTEGER;
      os             PLS_INTEGER;
      l_ostermonat   PLS_INTEGER := c_maerz; -- Standardm�ssig auf M�rz gesetzt
      l_osterdatum   DATE;
   BEGIN
      IF in_jahr IS NOT NULL
      THEN
         k := TRUNC (in_jahr / 100);
         m := 15 + TRUNC ( (3 * k + 3) / 4) - TRUNC ( (8 * k + 13) / 25);
         s := 2 - TRUNC ( (3 * k + 3) / 4);
         a := MOD (in_jahr, 19);
         d := MOD ( (19 * a + m), 30);
         r :=
              TRUNC (d / 29)
            + (TRUNC (d / 28) - TRUNC (d / 29)) * TRUNC (a / 11);
         og := 21 + d - r;
         sz := 7 - MOD ( (in_jahr + TRUNC (in_jahr / 4) + s), 7);
         oe := 7 - MOD ( (og - sz), 7);
         os := og + oe;

         -- Wenn die ermittelte Zahl gr�sser als 31 ist, dann liegt das Osterdatum im April
         IF os > 31
         THEN
            l_ostermonat := c_april;
            os := os - 31;
         END IF;

         l_osterdatum :=
            TO_DATE (
                  TO_CHAR (os)
               || '.'
               || TO_CHAR (l_ostermonat)
               || '.'
               || TO_CHAR (in_jahr));
      ELSE
         raise_application_error (-20202,
                                  'Abfrage-Jahr ist nicht definiert!');
      END IF;

      RETURN l_osterdatum;
   END gib_osterdatum;

   FUNCTION gib_feiertag_bezeichnungen (
      in_bundesland IN t_bland_kurz DEFAULT NULL)
      RETURN t_feiertag_tabelle
   IS
      /*
      || Name      : gib_feiertag_bezeichnungen
      ||
      || Aufgabe   : Funktion gibt eine Tabelle mit allen Feiertag-Bezeichnungen
      ||             f�r ein Bundesland zur�ck. Wird kein Bundesland angegeben,
      ||             so werden nur bundeseinheitliche Feiertage ermittelt.
      ||
      ||
      || Parameter : in_bundesland: Bundesland z.B. c_he (Hessen)
      ||
      || R�ckwert  : tab_feiertag_bez: Tabelle mit Feiertag-Bezeichnungen.
      ||
      || Autor     : 19.12.2012, ARR
      ||
      || Updates   :
      */
      tab_feiertag_bez   t_feiertag_tabelle := t_feiertag_tabelle ();
   BEGIN
      /*
      || Bundeseinheitliche Feiertage. Das sind zugleich alle Feiertage f�r
      || folgende Bundesl�nder: Berlin, Bremen, Hamburg, Niedersachsen und
      || Schleswig-Holstein
      */
      tab_feiertag_bez.EXTEND (9);
      tab_feiertag_bez (1).feiertag := c_neujahrstag;
      tab_feiertag_bez (2).feiertag := c_karfreitag;
      tab_feiertag_bez (3).feiertag := c_ostermontag;
      tab_feiertag_bez (4).feiertag := c_tag_der_arbeit;
      tab_feiertag_bez (5).feiertag := c_christi_himmelfahrt;
      tab_feiertag_bez (6).feiertag := c_pfingstmontag;
      tab_feiertag_bez (7).feiertag := c_tag_der_deutschen_einheit;
      tab_feiertag_bez (8).feiertag := c_erster_weihnachtstag;
      tab_feiertag_bez (9).feiertag := c_zweiter_weihnachtstag;

      -- Bundeslandabh�ngige Feiertage
      IF in_bundesland IN (c_bw, c_by, c_au)
      THEN                                       --Baden-W�rtemberg und Bayern
         tab_feiertag_bez.EXTEND (3);
         tab_feiertag_bez (10).feiertag := c_heilige_drei_konige;
         tab_feiertag_bez (11).feiertag := c_fronleichnam;
         tab_feiertag_bez (12).feiertag := c_allerheiligen;

         IF in_bundesland = c_au
         THEN                                                 --Stadt Augsburg
            tab_feiertag_bez.EXTEND (1);
            tab_feiertag_bez (13).feiertag := c_augsburger_friedensfest;
         END IF;
      ELSIF in_bundesland = c_he
      THEN                                                            --Hessen
         tab_feiertag_bez.EXTEND (1);
         tab_feiertag_bez (10).feiertag := c_fronleichnam;
      ELSIF in_bundesland = c_bb
      THEN                                                      -- Brandenburg
         tab_feiertag_bez.EXTEND (3);
         tab_feiertag_bez (10).feiertag := c_ostersonntag;
         tab_feiertag_bez (11).feiertag := c_pfingstsonntag;
         tab_feiertag_bez (12).feiertag := c_reformationstag;
      ELSIF in_bundesland IN (c_mv, c_th)
      THEN                                -- Mecklenburg-Vorpommern, Th�ringen
         tab_feiertag_bez.EXTEND (1);
         tab_feiertag_bez (10).feiertag := c_reformationstag;
      ELSIF in_bundesland IN (c_nw, c_rp)
      THEN                             -- Nordrhein-Westfalen, Rheinland-Pfalz
         tab_feiertag_bez.EXTEND (2);
         tab_feiertag_bez (10).feiertag := c_fronleichnam;
         tab_feiertag_bez (11).feiertag := c_allerheiligen;
      ELSIF in_bundesland = c_sl
      THEN                                                          --Saarland
         tab_feiertag_bez.EXTEND (3);
         tab_feiertag_bez (10).feiertag := c_fronleichnam;
         tab_feiertag_bez (11).feiertag := c_maria_himmelfahrt;
         tab_feiertag_bez (12).feiertag := c_allerheiligen;
      ELSIF in_bundesland = c_sn
      THEN                                                          -- Sachsen
         tab_feiertag_bez.EXTEND (2);
         tab_feiertag_bez (10).feiertag := c_reformationstag;
         tab_feiertag_bez (11).feiertag := c_buss_und_bettag;
      ELSIF in_bundesland = c_st
      THEN                                                   -- Sachsen-Anhalt
         tab_feiertag_bez.EXTEND (2);
         tab_feiertag_bez (10).feiertag := c_heilige_drei_konige;
         tab_feiertag_bez (11).feiertag := c_reformationstag;
      END IF;

      RETURN tab_feiertag_bez;
   END gib_feiertag_bezeichnungen;

   FUNCTION gib_feiertage (in_jahr         IN PLS_INTEGER,
                           in_bundesland   IN t_bland_kurz DEFAULT NULL)
      RETURN t_feiertag_tabelle
   IS
      /*
      || Name      : gib_feiertage
      ||
      || Aufgabe   : Funktion ermittelt f�r ein Abfrage-Jahr alle Feiertage.
      ||             Neben Feiertag-Bezeichnung erfolgt die Berechnung der
      ||             Feiertag-Datums. Optional kann ein Bundesland angegeben
      ||             werden um dessen Feiertage bei der Ermittlung zu
      ||             ber�cksichtigen. Ansonsten werden nur bundeseinheitliche
      ||             Feiertage in Betracht gezogen.
      ||
      || Parameter : in_jahr      : Abfrage-Jahr
      ||             in_bundesland: Bundesland z.B. c_he (Hessen)
      ||
      || R�ckwert  : tab_feiertage: Tabelle mit Feiertagen.
      ||
      || Autor     : 19.12.2012, ARR
      ||
      || Updates   :
      */
      tab_feiertage   t_feiertag_tabelle;
      l_osterdatum    DATE;

      -- Tempor�re Variablen
      l_feiertag      t_feiertag_bez;
      l_datum         DATE;
   BEGIN
      --Feiertag-Bezeichnungen ermitteln (ohne Datum)
      tab_feiertage :=
         gib_feiertag_bezeichnungen (in_bundesland => in_bundesland);
      --F�r bewegliche Feiertage Osterdatum ermitteln
      l_osterdatum := gib_osterdatum (in_jahr => in_jahr);

     -- Datum f�r Feiertage ermitteln
     <<definiere_jahres_feiertage>>
      FOR l_idx IN tab_feiertage.FIRST .. tab_feiertage.LAST
      LOOP
         l_feiertag := tab_feiertage (l_idx).feiertag;

         CASE l_feiertag
            WHEN c_neujahrstag
            THEN
               l_datum := TO_DATE (TO_CHAR ('01.01.' || in_jahr));
            WHEN c_karfreitag
            THEN
               l_datum := l_osterdatum - 2;
            WHEN c_ostersonntag -- Ostersonntag ist kein gesetzlicher Feiertag - ausnahme ist das Bundesland Brandenburg.
            THEN
               l_datum := l_osterdatum;
            WHEN c_ostermontag
            THEN
               l_datum := l_osterdatum + 1;
            WHEN c_tag_der_arbeit
            THEN
               l_datum := TO_DATE (TO_CHAR ('01.05.' || in_jahr));
            WHEN c_christi_himmelfahrt
            THEN
               l_datum := l_osterdatum + 39;
            WHEN c_pfingstsonntag
            THEN
               l_datum := l_osterdatum + 49;
            WHEN c_pfingstmontag
            THEN
               l_datum := l_osterdatum + 50;
            WHEN c_tag_der_deutschen_einheit
            THEN
               l_datum := TO_DATE (TO_CHAR ('03.10.' || in_jahr));
            WHEN c_erster_weihnachtstag
            THEN
               l_datum := TO_DATE (TO_CHAR ('25.12.' || in_jahr));
            WHEN c_zweiter_weihnachtstag
            THEN
               l_datum := TO_DATE (TO_CHAR ('26.12.' || in_jahr));
            WHEN c_heilige_drei_konige
            THEN
               l_datum := TO_DATE (TO_CHAR ('06.01.' || in_jahr));
            WHEN c_grundonnerstag
            THEN
               l_datum := l_osterdatum - 3;
            WHEN c_fronleichnam
            THEN
               l_datum := l_osterdatum + 60;
            WHEN c_augsburger_friedensfest
            THEN
               l_datum := TO_DATE (TO_CHAR ('08.08.' || in_jahr));
            WHEN c_maria_himmelfahrt
            THEN
               l_datum := TO_DATE (TO_CHAR ('15.08.' || in_jahr));
            WHEN c_reformationstag
            THEN
               l_datum := TO_DATE (TO_CHAR ('31.10.' || in_jahr));
            WHEN c_allerheiligen
            THEN
               l_datum := TO_DATE (TO_CHAR ('01.11.' || in_jahr));
            WHEN c_buss_und_bettag
            THEN
               l_datum := gib_buss_und_bettag (in_jahr => in_jahr);
         END CASE;

         tab_feiertage (l_idx).datum := l_datum;
      END LOOP definiere_jahres_feiertage;

      RETURN tab_feiertage;
   END gib_feiertage;

   FUNCTION gib_buss_und_bettag (in_jahr IN PLS_INTEGER)
      RETURN DATE
   IS
      /*
      || Name      : gib_buss_und_bettag
      ||
      || Aufgabe   : Funktion ermittelt f�r ein Abfrage-Jahr den Buss und Bettag.
      ||             F�r den Bu�- und Bettag m�ssen vom vierten Advent 32 Tage
      ||             abgezogen werden. Vierter Advent liegt am letzten Sonntag
      ||             vor dem 25.12. also: 4.Advent = 25.12. - tageszahl(25.12);
      ||
      || Parameter : in_jahr             : Abfrage-Jahr
      ||
      || R�ckwert  : l_buss_und_bettag   : Bu�- und Bettag f�r das Abfrage-Jahr.
      ||
      || Autor     : 19.12.2012, ARR
      ||
      || Updates   :
      */
      l_buss_und_bettag                 DATE := NULL;
      l_vierter_advent                  DATE := NULL;
      l_erster_weihnachtstag   CONSTANT DATE
         := TO_DATE (TO_CHAR ('25.12.' || in_jahr)) ;
   BEGIN
      IF in_jahr IS NOT NULL
      THEN
         --Vierten Advent ermitteln
         l_vierter_advent :=
              l_erster_weihnachtstag
            - TO_NUMBER (
                 TO_CHAR (l_erster_weihnachtstag,
                          'D',
                          'NLS_DATE_LANGUAGE=GERMAN'));
         --Bu�- und Bettag ermitteln
         l_buss_und_bettag := l_vierter_advent - 32;
      ELSE
         raise_application_error (-20202,
                                  'Abfrage-Jahr ist nicht definiert!');
      END IF;

      RETURN l_buss_und_bettag;
   END gib_buss_und_bettag;

   FUNCTION gib_monend_am_wochend (in_jahr IN PLS_INTEGER)
      RETURN t_we_datum_tabelle
   IS
      /*
      || Name      : gib_monend_am_wochend
      ||
      || Aufgabe   : Funktion ermittelt f�r ein Abfrage-Jahr alle Monatsend-Tage
      ||             die an einem Wochenende liegen. Tage werde in einer Tabelle
      ||             gespeichert und als R�ckgabewert geliefert.
      ||
      || Parameter : in_jahr : Abfrage-Jahr
      ||
      || R�ckwert  : tab_datum   : Tabelle f�r Monantsend-Tage die am Wochenende
      ||                           liegen.
      ||
      || Autor     : 19.12.2012, ARR
      ||
      || Updates   :
      */
      l_monatsend_datum   DATE;
      l_idx               PLS_INTEGER NOT NULL := 1;
      tab_datum           t_we_datum_tabelle := t_we_datum_tabelle ();
   BEGIN
      -- Pr�fen ob Parameter validen Wert aufweist
      IF in_jahr IS NOT NULL
      THEN
        <<iteration_durch_jahr>>
         FOR l_monats_nr IN c_januar .. c_dezember
         LOOP
            l_monatsend_datum :=
               LAST_DAY (
                  TO_DATE (TO_CHAR (in_jahr) || TO_CHAR (l_monats_nr),
                           'YYYYMM'));

            IF ist_wochenende (in_datum => l_monatsend_datum)
            THEN
               tab_datum.EXTEND;
               tab_datum (l_idx) := l_monatsend_datum;
               l_idx := l_idx + 1;
            END IF;
         END LOOP iteration_durch_jahr;
      ELSE
         raise_application_error (-20202,
                                  'Abfrage-Jahr ist nicht definiert!');
      END IF;

      RETURN tab_datum;
   END gib_monend_am_wochend;

   FUNCTION gib_nchst_arbeitstag (in_datum         DATE,
                                  in_bundesland    VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      /*
      ||
      || Aufgabe   : Funktion ermittelt den n�chsten Arbeitstag inklusive des �bergebenen Datums.
      ||             Ist das �bergebene Datum ein Arbeitstag, so wird dieser zur�ckgegeben.
      ||             Falls nicht, wird der n�chste Arbeitstag in der Zukunft ermittelt.
      ||
      || Parameter :  in_datum: Der Tag ausgehend von dem der n�chste Arbeitstag ermittelt wird.
      ||              in_bundesland: Bundesland. Relevant in weiteren Aufrufen f�r die Feiertagspr�fung.
      ||
      || R�ckgabe  : l_datum: N�chster Arbeitstag.
      */
      l_datum   DATE;
   BEGIN
      l_datum := in_datum;

      /* Falls das �bergebene Datum kein Arbeitstag ist, dann suche den n�chsten in der Zukunft.
      /*  In diesem Fall wird ein Tag addiert bis der n�chste Arbeitstag gefunden wird.
      */
      WHILE NOT ist_arbeitstag (in_datum        => l_datum,
                                in_bundesland   => in_bundesland)
      LOOP
         l_datum := l_datum + 1;
      END LOOP;

      RETURN l_datum;
   END gib_nchst_arbeitstag;
END kalender;
/