create or replace package plog
is

procedure fatal (pi_meldung varchar2);

procedure error (pi_meldung varchar2);

procedure warn (pi_meldung varchar2);

procedure info (pi_meldung varchar2);

procedure debug (pi_meldung varchar2);

end plog;