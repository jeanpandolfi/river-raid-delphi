unit RiverRide;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.MPlayer,PngImage, Jpeg;

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

    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure atirar();
    procedure criarTiro();
    procedure criarInimigo();

    procedure tempoTiroTimer(Sender: TObject);
    procedure tempoInimigoTimer(Sender: TObject);

    function  VerificaColisao(O1, O2 : TControl):boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormJogo: TFormJogo;

  NumTiros: Integer;
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
  NumTiros := 1;

  criarInimigo();
  end;

procedure TFormJogo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
 var incremento : integer;
begin
  incremento := 7;

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
    inc(NumTiros);

    if not(bateu) and (NumTiros < 50 ) then
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

procedure TFormJogo.criarInimigo();
var inimigoNavio, inimigoHelicoptero, inimigoAjato : Integer;
begin
   inimigoNavio := random(painelDir.Left-painelEsq.Left);
   inimigoHelicoptero := random(painelDir.Left-painelEsq.Left);
   inimigoAjato := random(painelDir.Left-painelEsq.Left);

   navio.Left := inimigoNavio;
   navio.Top := 0;
   navio.Visible := True;

   ajato.Left := inimigoAjato;
   ajato.Top := 0;
   ajato.Visible := True;

   helicoptero.Left := inimigoHelicoptero;
   helicoptero.Top := 0;
   helicoptero.Visible := True;

   // ativa a movimentação dos inimigos
   tempoInimigo.Enabled := True;

end;

procedure TFormJogo.tempoInimigoTimer(Sender: TObject);
begin
  navio.Top :=  navio.Top + 5;
  helicoptero.Top := helicoptero.Top + 6;
  ajato.Top := ajato.Top + 8;
end;

procedure TFormJogo.tempoTiroTimer(Sender: TObject);
var i: Integer;
begin
    if not bateu then
    begin

      for i := 0 to FormJogo.ComponentCount-1 do
      begin
        if FormJogo.Components[i] is TPanel then
        begin
          // Verificando se é o tiro
          if TPanel(FormJogo.Components[i]).Tag = 1 then
          begin
            // Movendo o tiro pra cima
            TPanel(FormJogo.Components[i]).Top := TPanel(FormJogo.Components[i]).Top - 3;

            // Movendo o tiro para baixo quando ele passar do limite da tela
            if TPanel(FormJogo.Components[i]).Top > FormJogo.Height then
            begin
              TPanel(FormJogo.Components[i]).Top := nave.Top;
              TPanel(FormJogo.Components[i]).Left := nave.Left + 22;
            end;

            //Verificando se o Tiro acertou o inimigo
            if VerificaColisao(TPanel(FormJogo.Components[i]), navio) then
             begin
                bateu := True;
                showmessage('Se fodeu');
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

    //label2.Caption := '';

    if (O1.Top >= O2.top ) and (O1.top  <= O2.top  + O2.Height) then
    begin
       topo := true;
       //label2.Caption := label2.Caption+ 'Topo, ';
    end;

    if (O1.left >= O2.left) and (O1.left <= O2.left + O2.Width ) then
    begin
      esquerda := true;
      //label2.Caption := label2.Caption+ ' Esquerda, ';
    end;

    if (O1.top + O1.Height >= O2.top ) and (O1.top + O1.Height  <= O2.top + O2.Height) then
    begin
      baixo := true;
      //label2.Caption := label2.Caption+ ' Baixo, ';
    end;

    if (O1.left + O1.Width >= O2.left ) and (O1.left + O1.Width  <= O2.left + O2.Width) then
    begin
      direita := true;
      //label2.Caption := label2.Caption+ ' Direita ';
    end;

    if (topo or baixo) and (esquerda or direita) then
       o2.Visible := false;

    VerificaColisao := (topo or baixo) and (esquerda or direita);

end;

 end.
