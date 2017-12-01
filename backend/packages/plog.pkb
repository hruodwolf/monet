create or replace package body plog is

  procedure error (meldung in varchar2) is
  begin
    logarr.error(meldung);
  end error;

  procedure warn (meldung in varchar2) is
  begin
    logarr.warn(meldung);
  end warn;

  procedure info (meldung in varchar2) is
  begin
    logarr.info(meldung);
  end info;

  procedure debug (meldung in varchar2) is
  begin
    logarr.debug(meldung);
  end debug;
end plog;