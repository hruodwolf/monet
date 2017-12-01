create or replace package plog
is

  /* 
      Hinweis: plog ist nur eine fassade, daher werden hier keine abhängigkeiten zum datenmodel hergestellt.
      z.B. meldung in logbuch.meldung%type darf nicht gemacht werden. varchar2 ist abstrakter!
  */

  procedure error (meldung in varchar2);
  
  procedure warn (meldung in varchar2);
  
  procedure info (meldung in varchar2);
  
  procedure debug (meldung in varchar2);

end plog;