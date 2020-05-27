program RiverRaid;

uses
  Vcl.Forms,
  RiverRide in 'RiverRide.pas' {FormJogo};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormJogo, FormJogo);
  Application.Run;
end.
