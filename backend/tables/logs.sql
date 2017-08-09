create table logs (
  logs_id      number(10) not null,
  erstellt_am  timestamp(6) not null,
  erstellt_von varchar2(30) not null,
  stufe        varchar2(5) not null,
  meldung      varchar2(32767) not null,
  objekt_name  varchar2(30) not null,
  modul_name   varchar2(61) not null, --hier will ich auch sehen: <package.procedure|function>
  zeile        number(6) not null
)
/

comment on table logsaetze is 'Tabelle Logsaetze zum Festhalten der Log-Meldungen.'
/
comment on column logsaetze.logs_id is 'Primärschlüssel.'
/
comment on column logsaetze.erstellt_am is 'Zeitpunkt an dem die Log-Meldung erstellt wurde.'
/
comment on column logsaetze.erstellt_von is 'Aktuelle Benutzer zur Zeit der Erstellung der Log-Meldung.'
/
comment on column logsaetze.stufe is 'Log-Stufe (INFO, DEBUG, WARN, ERROR, FATAL).'
/
comment on column logsaetze.meldung is 'Log-Meldung.'
/
comment on column logsaetze.schema_name is 'Aktuelles DB-Schema.'
/
comment on column logsaetze.objekt_name is 'Typ des Objekts in dem sich die Programmeinheit befindet z.B. FUNCTION, PACKAGE BODY, TYPE, usw.'
/
comment on column logsaetze.modul_name is 'Programmeinheit z.B. eine konkrete Prozedur oder Funktion in der die Log-Meldung ausgelöst wurde.'
/
comment on column logsaetze.zeile is 'Zeilennummer in der die Log-Meldung ausgelöst wurde.'
/

