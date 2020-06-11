unit RiverRide;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.MPlayer,PngImage, Jpeg,
  Vcl.StdCtrls, Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc;

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
    mensagemFimJogo: TLabel;
    fase: TLabel;

    trilha: TMediaPlayer;
    levelUp: TMediaPlayer;
    carregarJogo: TPanel;
    Label2: TLabel;
    btnNovoJogo: TButton;
    btnCarregarJogo: TButton;
    lblnomeJogador: TLabel;
    pontosJogador: TLabel;
    initJogo: TPanel;
    Label3: TLabel;
    txtNomeJogador: TEdit;
    btnIniciarJogo: TButton;
    salvarXML: TXMLDocument;
    Label4: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure atirar();
    procedure criarTiro();
    procedure criarInimigo(Sender: TObject);

    procedure tempoTiroTimer(Sender: TObject);
    procedure tempoInimigoTimer(Sender: TObject);

    procedure declararVitoria();
    procedure mudarNivel();

    procedure iniciaJogo();
    function  VerificaColisao(O1, O2 : TControl):boolean;

    procedure exibeBatida();
    procedure FormCreate(Sender: TObject);
    procedure btnIniciarJogoClick(Sender: TObject);
    procedure btnNovoJogoClick(Sender: TObject);
    procedure btnCarregarJogoClick(Sender: TObject);
    procedure jogarNaoClick(Sender: TObject);
    procedure salvar();
    procedure carregarJogoSalvo(nomeJogador :string);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormJogo: TFormJogo;

  numInimigosMatados, nivel: Integer;
  bateu : Boolean;
  nomeJogador: string;

implementation

{$R *.dfm}

procedure TFormJogo.FormCreate(Sender: TObject);
begin
  trilha.FileName := 'D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\sons\trilha.mp3';
  trilha.Open;
  trilha.Play;

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


procedure TFormJogo.iniciaJogo;
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


procedure TFormJogo.jogarNaoClick(Sender: TObject);
begin
  salvar();
  FormJogo.Close();
end;


procedure TFormJogo.atirar();
 begin
    criarTiro();
    tempoTiro.Enabled := True;
 end;


procedure TFormJogo.criarTiro();
var tiro: TPanel;
tiroSom : TMediaPlayer ;
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

//      tiroSom := TMediaPlayer.Create(FormJogo);
//      tiroSom.Parent   := FormJogo;
//      tiroSom.Visible  := false;
//      tiroSom.FileName := 'D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\sons\tiro.mp3';
//      tiroSom.Open;
//      tiroSom.Play;
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
          // Verificando se é o tiro
          if TPanel(FormJogo.Components[i]).Tag = 1 then
          begin
            // Movendo o tiro pra cima
            TPanel(FormJogo.Components[i]).Top := TPanel(FormJogo.Components[i]).Top - 15;

            // verificando se o tiro acertou um dos inimigos
            for j := 0 to FormJogo.ComponentCount-1 do
            begin
              if FormJogo.Components[j] is TImage then
              begin
                // Verificando se é o navio ou ajato ou helicoptero
                if (TImage(FormJogo.Components[j]).Tag = 2) or (TImage(FormJogo.Components[j]).Tag = 3) or (TImage(FormJogo.Components[j]).Tag = 4) then
                begin
                  //Verificando se o Tiro acertou o inimigo
                  if VerificaColisao(TPanel(FormJogo.Components[i]), TImage(FormJogo.Components[j])) then
                   begin
                      numInimigosMatados := numInimigosMatados + 1;
                      pontosJogador.Caption := 'Pontos: ' + inttostr(numInimigosMatados);
                      // sumir com o Tiro
                      TPanel(FormJogo.Components[i]).Visible := False;
                      TPanel(FormJogo.Components[i]).Left := 1000;
                      // sumir com o Inimigo
                      TImage(FormJogo.Components[j]).Visible := false;
                      TImage(FormJogo.Components[j]).Left := 1000;

                      // aumentando o nível do Jogo
                      if (numInimigosMatados = 20) then
                      begin
                        nivel := 2;
                        mudarNivel();
                        fase.Caption := 'Fase: ' + inttostr(nivel);
                        fase.Font.Color := clFuchsia;
                        criaInimigo.Interval := 2500;
                      end;

                      if (numInimigosMatados = 40) then
                      begin
                        nivel := 3;
                        mudarNivel();
                        fase.Caption := 'Fase: ' + inttostr(nivel);
                        fase.Font.Color := clRed;
                        criaInimigo.Interval := 2000;
                      end;

                      if (numInimigosMatados = 60) then
                      begin
                        bateu:= true;
                        declararVitoria();
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


procedure TFormJogo.btnIniciarJogoClick(Sender: TObject);
begin
  nomeJogador := txtNomeJogador.Text;
  lblnomeJogador.Caption := nomeJogador;
  initJogo.Visible := False;
  carregarJogo.Visible:= true;
end;


procedure TFormJogo.btnCarregarJogoClick(Sender: TObject);
begin
  iniciaJogo();
  carregarJogoSalvo(nomeJogador);
  carregarJogo.Visible := False;
end;


procedure TFormJogo.btnNovoJogoClick(Sender: TObject);
begin
  iniciaJogo();
  carregarJogo.Visible := False;
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

     // ativa a movimentação dos inimigos
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

          // Verificando se é o NAVIO
          if TPanel(FormJogo.Components[i]).Tag = 2 then
          begin
            // Movendo o NAVIO pra baixo
            TPanel(FormJogo.Components[i]).Top := TPanel(FormJogo.Components[i]).Top + 2 * nivel;

            //Verificando se o NAVIO acertou A NAVE
            if VerificaColisao(TPanel(FormJogo.Components[i]), nave) then
             begin
                bateu := true;
                exibeBatida();
             end;
          end;

          // Verificando se é o HELICOPTERO
          if TPanel(FormJogo.Components[i]).Tag = 3 then
          begin
            // Movendo o HELICOPTERO pra baixo
            TPanel(FormJogo.Components[i]).Top := TPanel(FormJogo.Components[i]).Top + 5 * nivel;

            //Verificando se o HELICOPTERO acertou A NAVE
            if VerificaColisao(TPanel(FormJogo.Components[i]), nave) then
             begin
                bateu := true;
                exibeBatida();
             end;
          end;

          // Verificando se é o AJATO
          if TPanel(FormJogo.Components[i]).Tag = 4 then
          begin
            // Movendo o AJATO pra baixo
            TPanel(FormJogo.Components[i]).Top := TPanel(FormJogo.Components[i]).Top + 7 * nivel;

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
var explosao: TImage;
explosaoSom : TMediaPlayer ;
begin
     explosao := TImage.Create(FormJogo);
     explosao.Parent := FormJogo;
     explosao.Picture.LoadFromFile('D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\explosao.png');
     explosao.Height := 50;
     explosao.Width  := 50;
     explosao.Stretch := true;
     explosao.Proportional := true;

     explosao.Left := nave.Left;
     explosao.Top := nave.Top;
     explosao.Visible := True;

     trilha.Close;

     explosaoSom := TMediaPlayer.Create(FormJogo);
     explosaoSom.Parent   := FormJogo;
     explosaoSom.Visible  := false;
     explosaoSom.FileName := 'D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\sons\explosao.mp3';
     explosaoSom.Open;
     explosaoSom.Play;

     mensagemPerdeu.Visible := True;
     explosao.Visible := false;
end;


procedure TFormJogo.declararVitoria;
var somVitoria: TMediaPlayer;
begin
    trilha.Close;

    somVitoria := TMediaPlayer.Create(FormJogo);
    somVitoria.Parent   := FormJogo;
    somVitoria.Visible  := false;
    somVitoria.FileName := 'D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\sons\vitoria.mp3';
    somVitoria.Open;
    somVitoria.Play;

    mensagemFimJogo.Caption := 'VOCÊ GANHOU!';
    mensagemFimJogo.Font.Color := clGreen;

    mensagemPerdeu.Visible := true;
end;


procedure TFormJogo.mudarNivel;
begin
    levelUp.Close;
    levelUp.FileName := 'D:\Documentos\Desktop\01 - Jogo\Rive Rider\img\sons\levelup.mp3';
    levelUp.Open;
    levelUp.Play;

end;


procedure TFormJogo.salvar;
  var riverRide, jogadores, player, naveIcon: IXMLNode;
  i: integer;
  jaJogou: Boolean;
begin
  if FileExists('riverride.xml') then   //verificando se o arquivo existe
  begin
    jaJogou := False;
    salvarXML.LoadFromFile('riverride.xml');
    // se existir lê até a lista de jogadores
    riverRide := salvarXML.ChildNodes.FindNode('riverride');

    jogadores := riverRide.ChildNodes.FindNode('jogadores');

      // percorrendo os jogadores
    for i := 0 to jogadores.ChildNodes.Count-1 do
    begin
      // verificando se é o jogador já jogou antes. Se jogou sobreEscreva a ultima jogada dele
      if jogadores.ChildNodes[i].Attributes['nome'] = lblnomeJogador.Caption then
      begin
        jaJogou := True;
        player := jogadores.ChildNodes[i];

        naveIcon := player.ChildNodes.FindNode('nave');

        naveIcon.ChildValues['left'] := intToStr(nave.Left);;
        naveIcon.ChildValues['top'] := intToStr(nave.Top);;

        player.ChildValues['pontos'] := intToStr(numInimigosMatados);
        player.ChildValues['fase'] := intToStr(nivel);

      end;
    end;

    if not jaJogou then
    begin
      // adiciona um node jogador
      player := jogadores.AddChild('jogador');

      player.Attributes['nome'] := lblnomeJogador.Caption;

      naveicon := player.AddChild('nave');
      naveicon.AddChild('left').Text := intToStr(nave.Left);
      naveicon.AddChild('top').Text := intToStr(nave.Top);
      player.AddChild('pontos').Text := intToStr(numInimigosMatados);
      player.AddChild('fase').Text := intToStr(nivel);
    end;
  end
  else
  begin

    // se não existir cria o nó riverride e jogadores
    salvarXML.Active := True;
    riverRide := salvarXML.AddChild('riverride');

    jogadores := riverRide.AddChild('jogadores');

    // adiciona um node jogador
    player := jogadores.AddChild('jogador');

    player.Attributes['nome'] := lblnomeJogador.Caption;

    naveicon := player.AddChild('nave');
    naveicon.AddChild('left').Text := intToStr(nave.Left);
    naveicon.AddChild('top').Text := intToStr(nave.Top);
    player.AddChild('pontos').Text := intToStr(numInimigosMatados);
    player.AddChild('fase').Text := intToStr(nivel);
  end;

  salvarXML.SaveToFile('riverride.xml');

end;


procedure TFormJogo.carregarJogoSalvo(nomeJogador :string);
var riverRide, jogadores, player, naveIcon: IXMLNode;
  i, left, top :Integer;
  jogadorExiste: Boolean;
begin
  jogadorExiste := false;
  if FileExists('riverride.xml') then   //verificando se o arquivo existe
  begin
    salvarXML.LoadFromFile('riverride.xml');

    riverRide := salvarXML.ChildNodes.FindNode('riverride');

    jogadores := riverRide.ChildNodes.FindNode('jogadores');

    // percorrendo os jogadores
    for i := 0 to jogadores.ChildNodes.Count-1 do
    begin
      // verificando se é o jogador a jogar
      if jogadores.ChildNodes[i].Attributes['nome'] = nomeJogador then
      begin
        jogadorExiste := true;

        player := jogadores.ChildNodes[i];
        naveIcon := player.ChildNodes.FindNode('nave');

        left := StrtoInt(naveIcon.ChildValues['left']);
        top := StrtoInt(naveIcon.ChildValues['top']);

        nave.Top := top;
        nave.Left := left;

        numInimigosMatados := StrToInt(player.ChildValues['pontos']);
        nivel := StrToInt(player.ChildValues['fase']);

        fase.Caption := 'Fase: ' + inttostr(nivel);
        pontosJogador.Caption := 'Pontos: ' + inttostr(numInimigosMatados);
      end;
    end;
  end
  else
  begin
    showmessage('Você não possui nenhum jogo salvo, então iniciará um novo jogo');
    jogadorExiste := true;
  end;

  if not jogadorExiste then
    showmessage('Você não possui nenhum jogo salvo, então iniciará um novo jogo');
end;


//FIM
end.
