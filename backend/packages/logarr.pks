create or replace package logarr
is

  procedure error (meldung in logs.meldung%type);

  procedure warn (meldung in logs.meldung%type);

  procedure info (meldung in logs.meldung%type);

  procedure debug (meldung in logs.meldung%type);

end logarr;

show err