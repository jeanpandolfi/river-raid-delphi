unit RiverRide;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.MPlayer,PngImage, Jpeg,
  Vcl.StdCtrls;

type
  TFormJogo = class(TForm)
    painelEsq: TPanel;
    painelDir: TPanel;

    nave: TImage;
    navio: TImage;
    helicoptero: TImage;
    ajato: TImage;

    tempoInimigo: TTimer;
    tempoTiro: TTimer;
    criaInimigo: TTimer;

    mensagemPerdeu: TPanel;
    jogarNao: TButton;
    jogarSim: TButton;
    Label1: TLabel;
    Label2: TLabel;


    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure atirar();
    procedure criarTiro();
    procedure criarInimigo(Sender: TObject);

    procedure tempoTiroTimer(Sender: TObject);
    procedure tempoInimigoTimer(Sender: TObject);

    function  VerificaColisao(O1, O2 : TControl):boolean;

    procedure exibeBatida();
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormJogo: TFormJogo;

  numInimigosMatados, nivel: Integer;
  bateu : Boolean;

implementation

{$R *.dfm}

procedure TFormJogo.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  nave.Picture.LoadFromFile('D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\eu.png');

  navio.Picture.LoadFromFile('D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\inimigo\port.png');
  helicoptero.Picture.LoadFromFile('D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\inimigo\helicoptero-militar.png');
  ajato.Picture.LoadFromFile('D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\inimigo\plane2.png');


  navio.Visible := False;
  helicoptero.Visible := False;
  ajato.Visible := False;

  bateu := false;
  numInimigosMatados := 0;
  nivel := 1;

  criaInimigo.OnTimer := criarInimigo;
  criaInimigo.Enabled := true;
  end;

procedure TFormJogo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
 var incremento : integer;
begin
  incremento := 10;

  case key of
    VK_LEFT  : if (nave.Left >= painelEsq.Width) then
                  nave.Left := nave.Left - incremento;
    VK_RIGHT : if (nave.Left <= 352) then
                  nave.Left := nave.Left + incremento;
    VK_UP    : nave.Top := nave.Top - incremento;
    VK_DOWN  : nave.Top := nave.Top + incremento;
    VK_SPACE:  atirar();
  end;
 end;


procedure TFormJogo.atirar();
 begin
    criarTiro();
    tempoTiro.Enabled := True;
 end;

 procedure TFormJogo.criarTiro();
var tiro: TPanel;
 begin

    if not bateu then
    begin
      tiro := TPanel.Create(FormJogo);
      tiro.Parent := FormJogo;
      tiro.Left := nave.Left + 22;
      tiro.Top := nave.Top;
      tiro.Width := 5;
      tiro.Height := 5;
      tiro.Color := clYellow;
      tiro.ParentBackground := False;
      tiro.ParentColor := False;
      tiro.Caption := '';
      tiro.Visible := True;
      tiro.Tag := 1;
    end;

 end;


procedure TFormJogo.tempoTiroTimer(Sender: TObject);
var  i, j: Integer;
begin
    if not bateu then
    begin

      for i := 0 to FormJogo.ComponentCount-1 do
      begin
        if FormJogo.Components[i] is TPanel then
        begin
          // Verificando se � o tiro
          if TPanel(FormJogo.Components[i]).Tag = 1 then
          begin
            // Movendo o tiro pra cima
            TPanel(FormJogo.Components[i]).Top := TPanel(FormJogo.Components[i]).Top - 15;

            // verificando se o tiro acertou um dos inimigos
            for j := 0 to FormJogo.ComponentCount-1 do
            begin
              if FormJogo.Components[j] is TImage then
              begin
                // Verificando se � o novio ou ajato ou helicoptero
                if (TImage(FormJogo.Components[j]).Tag = 2) or (TImage(FormJogo.Components[j]).Tag = 3) or (TImage(FormJogo.Components[j]).Tag = 4) then
                begin
                  //Verificando se o Tiro acertou o inimigo
                  if VerificaColisao(TPanel(FormJogo.Components[i]), TImage(FormJogo.Components[j])) then
                   begin
                      inc(numInimigosMatados);

                      TImage(FormJogo.Components[j]).Visible := false;
                      TImage(FormJogo.Components[j]).Left := 500;

                      // aumentando o n�vel do Jogo
                      if (numInimigosMatados = 10) or (numInimigosMatados = 20) or (numInimigosMatados = 30) then
                      begin
                        inc(nivel);
                      end;
                   end;
                end;
              end;
            end;
          end;
        end;
      end;

    end;

end;


procedure TFormJogo.criarInimigo(Sender: TObject);
var inimigoNavio, inimigoHelicoptero, inimigoAjato : TImage;
begin

  if not bateu then
   begin
      // NAVIO
     inimigoNavio := TImage.Create(FormJogo);
     inimigoNavio.Parent := FormJogo;
     inimigoNavio.Picture.LoadFromFile('D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\inimigo\port.png');
     inimigoNavio.Height := 33;
     inimigoNavio.Width  := 33;
     inimigoNavio.Stretch := true;
     inimigoNavio.Proportional := true;

     inimigoNavio.Left := random(painelDir.Left-painelEsq.Left);;
     inimigoNavio.Top := 0;
     inimigoNavio.Visible := True;
     inimigoNavio.Tag := 2;

     // AJATO
     inimigoAjato := TImage.Create(FormJogo);
     inimigoAjato.Parent := FormJogo;
     inimigoAjato.Picture.LoadFromFile('D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\inimigo\plane2.png');
     inimigoAjato.Height := 41;
     inimigoAjato.Width  := 39;
     inimigoAjato.Stretch := true;
     inimigoAjato.Proportional := true;

     inimigoAjato.Left := random(painelDir.Left-painelEsq.Left);
     inimigoAjato.Top := 0;
     inimigoAjato.Visible := True;
     inimigoAjato.Tag := 4;

     // HELICOPTERO
     inimigoHelicoptero := TImage.Create(FormJogo);
     inimigoHelicoptero.Parent := FormJogo;
     inimigoHelicoptero.Picture.LoadFromFile('D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\inimigo\helicoptero-militar.png');
     inimigoHelicoptero.Height := 40;
     inimigoHelicoptero.Width  := 46;
     inimigoHelicoptero.Stretch := true;
     inimigoHelicoptero.Proportional := true;

     inimigoHelicoptero.Left := random(painelDir.Left-painelEsq.Left);
     inimigoHelicoptero.Top := 0;
     inimigoHelicoptero.Visible := True;
     inimigoHelicoptero.Tag := 3;

     // ativa a movimenta��o dos inimigos
     tempoInimigo.Enabled := True;
   end;
end;


procedure TFormJogo.tempoInimigoTimer(Sender: TObject);
var i: Integer;
begin
  if not bateu then
    begin

      for i := 0 to FormJogo.ComponentCount-1 do
      begin
        if FormJogo.Components[i] is TImage then
        begin

          // Verificando se � o NAVIO
          if TPanel(FormJogo.Components[i]).Tag = 2 then
          begin
            // Movendo o NAVIO pra baixo
            TPanel(FormJogo.Components[i]).Top := TPanel(FormJogo.Components[i]).Top + 5 * nivel;

            //Verificando se o NAVIO acertou A NAVE
            if VerificaColisao(TPanel(FormJogo.Components[i]), nave) then
             begin
                bateu := true;
                exibeBatida();
             end;
          end;

          // Verificando se � o HELICOPTERO
          if TPanel(FormJogo.Components[i]).Tag = 3 then
          begin
            // Movendo o HELICOPTERO pra baixo
            TPanel(FormJogo.Components[i]).Top := TPanel(FormJogo.Components[i]).Top + 10 * nivel;

            //Verificando se o HELICOPTERO acertou A NAVE
            if VerificaColisao(TPanel(FormJogo.Components[i]), nave) then
             begin
                bateu := true;
                exibeBatida();
             end;
          end;

          // Verificando se � o AJATO
          if TPanel(FormJogo.Components[i]).Tag = 4 then
          begin
            // Movendo o AJATO pra baixo
            TPanel(FormJogo.Components[i]).Top := TPanel(FormJogo.Components[i]).Top + 15 * nivel;

            //Verificando se o AJATO acertou A NAVE
            if VerificaColisao(TPanel(FormJogo.Components[i]), nave) then
             begin
                bateu := true;
                exibeBatida();
             end;
          end;
        end;
      end;

    end;

end;


function TFormJogo.VerificaColisao(O1, O2 : TControl): boolean;
var topo, baixo, esquerda, direita : boolean;
begin
    topo     := false;
    baixo    := false;
    esquerda := false;
    direita  := false;

    if (O1.Top >= O2.top ) and (O1.top  <= O2.top  + O2.Height) then
    begin
       topo := true;
    end;

    if (O1.left >= O2.left) and (O1.left <= O2.left + O2.Width ) then
    begin
      esquerda := true;
    end;

    if (O1.top + O1.Height >= O2.top ) and (O1.top + O1.Height  <= O2.top + O2.Height) then
    begin
      baixo := true;
    end;

    if (O1.left + O1.Width >= O2.left ) and (O1.left + O1.Width  <= O2.left + O2.Width) then
    begin
      direita := true;
    end;

    if (topo or baixo) and (esquerda or direita) then
       o2.Visible := false;

    VerificaColisao := (topo or baixo) and (esquerda or direita);

end;


procedure TFormJogo.exibeBatida;
begin
    mensagemPerdeu.Visible := True;
end;
 end.
