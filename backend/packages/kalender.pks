/* Formatted on 05.04.2013 15:54:29 (QP5 v5.185.11230.41888) */
CREATE OR REPLACE PACKAGE kalender
AS
   -- Feiertagsbezeichnung z.B. NEUJAHRSTAG.
   SUBTYPE t_feiertag_bez IS VARCHAR2 (25 CHAR);

   -- Kurze Bundesland-Bezeichnung.
   SUBTYPE t_bland_kurz IS CHAR (2 CHAR);

   -- Typ Feiertag. Besteht aus der Feiertagsbezeichning und einem Datum.
   TYPE t_feiertag IS RECORD
   (
      feiertag   t_feiertag_bez,
      datum      DATE
   );

   TYPE t_feiertag_tabelle IS VARRAY (13) OF t_feiertag;

   /*
    Typ "t_we_datum_tabelle" für das Speichern der Monatsend-Tage welche auf
    Wochenende fallen. Maximal können, was sehr unwahrscheinlich ist,
    12 Werte gespeichert werden.
   */
   TYPE t_we_datum_tabelle IS VARRAY (12) OF DATE;



   c_bw                          CONSTANT t_bland_kurz := 'BW'; --BADEN-WÜRTTEMBERG
   c_by                          CONSTANT t_bland_kurz := 'BY';       --BAYERN
   c_be                          CONSTANT t_bland_kurz := 'BE';       --BERLIN
   c_bb                          CONSTANT t_bland_kurz := 'BB';  --BRANDENBURG
   c_hb                          CONSTANT t_bland_kurz := 'HB';       --BREMEN
   c_hh                          CONSTANT t_bland_kurz := 'HH';      --HAMBURG
   c_he                          CONSTANT t_bland_kurz := 'HE';       --HESSEN
   c_mv                          CONSTANT t_bland_kurz := 'MV'; --MECKLENBURG-VORPOMMERN
   c_ni                          CONSTANT t_bland_kurz := 'NI'; --NIEDERSACHSEN
   c_nw                          CONSTANT t_bland_kurz := 'NW'; --NORDRHEIN-WESTFALEN
   c_rp                          CONSTANT t_bland_kurz := 'RP'; --RHEINLAND-PFALZ
   c_sl                          CONSTANT t_bland_kurz := 'SL';     --SAARLAND
   c_sn                          CONSTANT t_bland_kurz := 'SN';      --SACHSEN
   c_st                          CONSTANT t_bland_kurz := 'ST'; --SACHSEN-ANHALT
   c_sh                          CONSTANT t_bland_kurz := 'SH'; --SCHLESWIG-HOLSTEIN
   c_th                          CONSTANT t_bland_kurz := 'TH';    --THÜRINGEN
   c_au                          CONSTANT t_bland_kurz := 'AU'; -- AUGSBURG/BAYERN

   c_neujahrstag                 CONSTANT t_feiertag_bez := 'NEUJAHRSTAG';
   c_heilige_drei_konige         CONSTANT t_feiertag_bez := 'HEILIGE_DREI_KONIGE';
   c_grundonnerstag              CONSTANT t_feiertag_bez := 'GRUNDONNERSTAG';
   c_karfreitag                  CONSTANT t_feiertag_bez := 'KARFREITAG';
   c_ostermontag                 CONSTANT t_feiertag_bez := 'OSTERMONTAG';
   c_ostersonntag                CONSTANT t_feiertag_bez := 'OSTERSONNTAG';
   c_tag_der_arbeit              CONSTANT t_feiertag_bez := 'TAG_DER_ARBEIT';
   c_christi_himmelfahrt         CONSTANT t_feiertag_bez := 'CHRISTI_HIMMELFAHRT';
   c_pfingstsonntag              CONSTANT t_feiertag_bez := 'PFINGSTSONNTAG';
   c_pfingstmontag               CONSTANT t_feiertag_bez := 'PFINGSTMONTAG';
   c_fronleichnam                CONSTANT t_feiertag_bez := 'FRONLEICHNAM';
   c_augsburger_friedensfest     CONSTANT t_feiertag_bez
                                             := 'AUGSBURGER_FRIEDENSFEST' ;
   c_maria_himmelfahrt           CONSTANT t_feiertag_bez := 'MARIA_HIMMELFAHRT';
   c_tag_der_deutschen_einheit   CONSTANT t_feiertag_bez
                                             := 'TAG_DER_DEUTSCHEN_EINHEIT' ;
   c_reformationstag             CONSTANT t_feiertag_bez := 'REFORMATIONSTAG';
   c_allerheiligen               CONSTANT t_feiertag_bez := 'ALLERHEILIGEN';
   c_buss_und_bettag             CONSTANT t_feiertag_bez := 'BUSS_UND_BETTAG';
   c_erster_weihnachtstag        CONSTANT t_feiertag_bez
                                             := 'ERSTER_WEIHNACHTSTAG' ;
   c_zweiter_weihnachtstag       CONSTANT t_feiertag_bez
                                             := 'ZWEITER_WEIHNACHTSTAG' ;
   c_januar                      CONSTANT PLS_INTEGER := 1;
   c_februar                     CONSTANT PLS_INTEGER := 2;
   c_maerz                       CONSTANT PLS_INTEGER := 3;
   c_april                       CONSTANT PLS_INTEGER := 4;
   c_mai                         CONSTANT PLS_INTEGER := 5;
   c_juni                        CONSTANT PLS_INTEGER := 6;
   c_juli                        CONSTANT PLS_INTEGER := 7;
   c_august                      CONSTANT PLS_INTEGER := 8;
   c_september                   CONSTANT PLS_INTEGER := 9;
   c_oktober                     CONSTANT PLS_INTEGER := 10;
   c_november                    CONSTANT PLS_INTEGER := 11;
   c_dezember                    CONSTANT PLS_INTEGER := 12;



   FUNCTION ist_werktag (in_datum         DATE,
                         in_bundesland    t_bland_kurz DEFAULT NULL)
      RETURN BOOLEAN;

   FUNCTION ist_feiertag (in_datum        IN DATE,
                          in_bundesland   IN t_bland_kurz DEFAULT NULL)
      RETURN BOOLEAN;

   FUNCTION ist_feiertag_sql (in_datum        IN DATE,
                              in_bundesland   IN t_bland_kurz DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION ist_wochenende (in_datum IN DATE)
      RETURN BOOLEAN;

   FUNCTION ist_arbeitstag (in_datum        IN DATE,
                            in_bundesland   IN t_bland_kurz DEFAULT NULL)
      RETURN BOOLEAN;

   FUNCTION gib_osterdatum (in_jahr IN PLS_INTEGER)
      RETURN DATE;

   FUNCTION gib_feiertag_bezeichnungen (
      in_bundesland IN t_bland_kurz DEFAULT NULL)
      RETURN t_feiertag_tabelle;

   FUNCTION gib_feiertage (in_jahr         IN PLS_INTEGER,
                           in_bundesland   IN t_bland_kurz DEFAULT NULL)
      RETURN t_feiertag_tabelle;

   FUNCTION gib_buss_und_bettag (in_jahr IN PLS_INTEGER)
      RETURN DATE;

   FUNCTION gib_monend_am_wochend (in_jahr IN PLS_INTEGER)
      RETURN t_we_datum_tabelle;

   FUNCTION gib_nchst_arbeitstag (in_datum         DATE,
                                  in_bundesland    VARCHAR2 DEFAULT NULL)
      RETURN DATE;
END kalender;