create table logs (
  logs_id       number(15)    not null,
  erstellt_am   timestamp(6)  not null,
  erstellt_von  varchar2(32)  not null,
  geaendert_am  timestamp(6)  not null,
  geaendert_von varchar2(32)  not null,
  version       number(10)    not null,
  zeitstempel   timestamp(6)  not null,
  stufe         varchar2(5)   not null,
  modul         varchar2(256)  not null,
  zeile         number(6)     not null,
  meldung       varchar2(512) not null
)
/

comment on table logs is 'Tabelle logsaetze zum Festhalten der Log-Meldungen.'
/
comment on column logs.logs_id is 'Primärschlüssel.'
/
comment on column logs.erstellt_am is 'Zeitpunkt an dem der Eintrag erstellt wurde.'
/
comment on column logs.erstellt_von is 'Aktuelle Benutzer zur Zeit der Erstellung des Eintrags.'
/
comment on column logs.geaendert_am is 'Zeitpunkt an dem der Eintrag geändert wurde.'
/
comment on column logs.geaendert_von is 'Aktuelle Benutzer zur Zeit der Änderung des Eintrags.'
/
comment on column logs.version is 'Version des Eintrags.'
/
comment on column logs.zeitstempel is 'Zeitpunkt an dem der Log-Eintrag erstellt wurde.'
/
comment on column logs.stufe is 'Log-Stufe (INFO, DEBUG, WARN, ERROR).'
/
comment on column logs.modul is 'Programmeinheit z.B. eine konkrete Prozedur oder Funktion in der die Log-Meldung ausgelöst wurde.'
/
comment on column logs.zeile is 'Zeilennummer in der die Log-Meldung ausgelöst wurde.'
/
comment on column logs.meldung is 'Log-Meldung.'
/
