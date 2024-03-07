unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.WinXCtrls, dOPCIntf, dOPCComn, dOPCDA, Vcl.Imaging.pngimage;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    ToggleSwitchServer: TToggleSwitch;
    StaticText1: TStaticText;
    TopicCombo: TComboBox;
    bBegin: TButton;
    OPCClient: TdOPCDAClient;
    StatusMemo: TMemo;
    ControlPanel: TPanel;
    StartPanel: TPanel;
    Image1: TImage;
    StopPanel: TPanel;
    Image2: TImage;
    ResetPanel: TPanel;
    Image3: TImage;
    StaticText2: TStaticText;
    Panel3: TPanel;
    Image4: TImage;
    Image7: TImage;
    vastago1A: TImage;
    Image5: TImage;
    Image6: TImage;
    vastago2A: TImage;
    Image10: TImage;
    Image11: TImage;
    vastago3A: TImage;
    Image13: TImage;
    Image14: TImage;
    vastago4A: TImage;
    Image16: TImage;
    Image17: TImage;
    vastago5A: TImage;
    se2_indicator: TPanel;
    sc2_indicator: TPanel;
    Panel9: TPanel;
    se1_indicator: TPanel;
    Panel4: TPanel;
    sc1_indicator: TPanel;
    Panel6: TPanel;
    se3_indicator: TPanel;
    Panel5: TPanel;
    sc3_indicator: TPanel;
    Panel7: TPanel;
    count_pre_edit: TEdit;
    StaticText3: TStaticText;
    bCount_pre_ok: TButton;
    Piston1AOut: TTimer;
    Piston1AIn: TTimer;
    Piston2AOut: TTimer;
    Piston2AIn: TTimer;
    Piston3AOut: TTimer;
    Piston3AIn: TTimer;
    Piston4AOut: TTimer;
    PistonesNeumDelay: TTimer;
    Piston5AOut: TTimer;
    PistonesNeumIn: TTimer;
    StaticText4: TStaticText;
    timer_pre_edit: TEdit;
    bTimer_pre_ok: TButton;
    procedure ToggleSwitchServerClick(Sender: TObject);
    procedure TopicComboDropDown(Sender: TObject);
    procedure OPCClientConnect(Sender: TObject);
    procedure OPCClientDisconnect(Sender: TObject);
    procedure StartPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StartPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StopPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StopPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ResetPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ResetPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bBeginClick(Sender: TObject);
    procedure OPCClientDatachange(Sender: TObject; ItemList: TdOPCItemList);
    procedure bCount_pre_okClick(Sender: TObject);
    procedure Piston1AOutTimer(Sender: TObject);
    procedure Piston1AInTimer(Sender: TObject);
    procedure Piston2AOutTimer(Sender: TObject);
    procedure Piston2AInTimer(Sender: TObject);
    procedure Piston3AOutTimer(Sender: TObject);
    procedure Piston3AInTimer(Sender: TObject);
    procedure Piston4AOutTimer(Sender: TObject);
    procedure PistonesNeumDelayTimer(Sender: TObject);
    procedure Piston5AOutTimer(Sender: TObject);
    procedure PistonesNeumInTimer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  TAGS : tdOPCGroup;
  start_rem, stop_rem, reset_rem : tdOPCItem;                 // botones remotos
  sc1, se1, sc2, se2, sc3, se3 : tdOPCItem;                   // sensores de exp/comp
  ev_e1, ev_c1, ev_e2, ev_c2, ev_e3, ev_c3 : tdOPCItem;       // electrovalvulas
  count_pre, count_acc : tdOPCItem;                           // variables del contador
  timer_neum_en, timer_neum_pre, timer_neum_dn : tdOPCItem;   // variables timer (ultimo)
  selectedTopic : string;
  prev_ev_e1: string;
  prev_ev_c1: string;
  prev_ev_e2: string;
  prev_ev_c2: string;
  prev_ev_e3: string;
  prev_ev_c3: string;

implementation

{$R *.dfm}

// ************** Configuracion de servidor OPC ********************************
// Event OPCServer->OnConnect
procedure TForm1.OPCClientConnect(Sender: TObject);
begin
    StatusMemo.Clear;
    TopicCombo.Enabled := true;                    // enable topicCombo
    bBegin.Enabled := true;                        // enable begin button
    StatusMemo.Lines.Add(format('Connected to server: %s',[OPCClient.Servername]));
end;
// Event OPCServer->OnDisConnect
procedure TForm1.OPCClientDisconnect(Sender: TObject);
begin
  StatusMemo.Clear;
  //OPCClient.OPCGroups[0].OPCItems.RemoveAll;  // remove all Items
  TopicCombo.Enabled := false;            // disable topicCombo
  bBegin.Enabled := false;                // disable begin button
  ControlPanel.Enabled := false;
  StatusMemo.Lines.Add(format('Disconnected from server: %s',[OPCClient.Servername]));
end;
// Event OPCServer -> OnDataChange
procedure TForm1.OPCClientDatachange(Sender: TObject; ItemList: TdOPCItemList);
begin
    // *************************** Animaciones *************************************
    // Piston 1A
    if ((prev_ev_e1 = '0') and (ev_e1.ValueStr = '1')) or ((sc1.ValueStr = '0') and (se1.ValueStr = '1')) then begin
        Piston1AOut.Enabled := true;
        Piston1AIn.Enabled := false;
        prev_ev_e1 := ev_e1.ValueStr;
    end
    else if ((prev_ev_e1 = '1') and (ev_e1.ValueStr = '0')) or ((sc1.ValueStr = '1') and (se1.ValueStr = '0')) then begin
        Piston1AOut.Enabled := false;
        Piston1AIn.Enabled := true;
        prev_ev_c1 := ev_c1.ValueStr;
    end;
    // Piston 2A
    if ((prev_ev_e2 = '0') and (ev_e2.ValueStr = '1')) or ((sc2.ValueStr = '0') and (se2.ValueStr = '1')) then begin
        Piston2AOut.Enabled := true;
        Piston2AIn.Enabled := false;
        prev_ev_e2 := ev_e2.ValueStr;
    end
    else if ((prev_ev_e2 = '1') and (ev_e2.ValueStr = '0')) or ((sc2.ValueStr = '1') and (se2.ValueStr = '0')) then begin
        Piston2AOut.Enabled := false;
        Piston2AIn.Enabled := true;
        prev_ev_c2 := ev_c2.ValueStr;
    end;
    // Piston 3A
    if ((prev_ev_e3 = '0') and (ev_e3.ValueStr = '1')) or ((sc3.ValueStr = '0') and (se3.ValueStr = '1')) then begin
        Piston3AOut.Enabled := true;
        Piston3AIn.Enabled := false;
        prev_ev_e3 := ev_e3.ValueStr;
    end
    else if ((prev_ev_e3 = '1') and (ev_e3.ValueStr = '0')) or ((sc3.ValueStr = '1') and (se3.ValueStr = '0')) then begin
        Piston3AOut.Enabled := false;
        Piston3AIn.Enabled := true;
        prev_ev_c3 := ev_c3.ValueStr;
    end;
    // Sale Piston 4A
    if timer_neum_en.ValueStr = '1' then begin
      Piston4AOut.Enabled := true;
      PistonesNeumDelay.Enabled := true;
      PistonesNeumIn.Enabled := false;
    end
    else begin
      Piston4AOut.Enabled := false;
      PistonesNeumDelay.Enabled := false;
      PistonesNeumIn.Enabled := true;
    end;
    // Regresan ambos pistones
    if timer_neum_dn.ValueStr = '1' then
      PistonesNeumIn.Enabled := true;

    // ------------ Valores del contador -----------------------------------
    count_pre_edit.Text := count_pre.ValueStr;
    // ------------ Checar los valores de los sensores ---------------------
    // SC1
    if sc1.ValueStr = '1' then
        sc1_indicator.Color := clRed
    else
        sc1_indicator.Color := clGray;
    // SE1
    if se1.ValueStr = '1' then
        se1_indicator.Color := clRed
    else
        se1_indicator.Color := clGray;
    // SC2
    if sc2.ValueStr = '1' then
        sc2_indicator.Color := clRed
    else
        sc2_indicator.Color := clGray;
    // SE2
    if se2.ValueStr = '1' then
        se2_indicator.Color := clRed
    else
        se2_indicator.Color := clGray;
    // SC3
    if sc3.ValueStr = '1' then
        sc3_indicator.Color := clRed
    else
        sc3_indicator.Color := clGray;
    // SE3
    if se3.ValueStr = '1' then
        se3_indicator.Color := clRed
    else
        se3_indicator.Color := clGray;
end;
// procedure para buscar la lista de topicos de la conexion opc
procedure TopicosList(Browser: TdOPCBrowser; ItemList: TStrings; Level:integer=0);
  var
     i:integer;
     Items: TdOPCBrowseItems;
     BrowseItem: TdOPCBrowseItem;
  begin
    Browser.Browse;
    Items:=TdOPCBrowseItems.Create;
    Items.Assign(Browser.Items);

    for i := 0 to Level do
      ITemList.Add(Browser.CurrentPosition.Name);
      for i := 0 to Items.Count-1 do
      begin
          BrowseItem:=Items[i];
          if BrowseItem.IsFolder then
          iTEMlIST.Add(BrowseItem.ItemID)
      end;
end;

// boton Toggle para conectar/desconectar
procedure TForm1.ToggleSwitchServerClick(Sender: TObject);
begin
  if ToggleSwitchServer.State = tssOn then  // Estado = ON
  begin
    ToggleSwitchServer.Color := clGreen;     // Cambia el color del interruptor a verde cuando esta en ON
    OpcClient.ServerName := 'RSLinx OPC Server';   // set Servername
    OpcClient.Active     := true;                  // connect to Server
  end
  else                                      // Estado = OFF
  begin
    ToggleSwitchServer.Color := clMaroon;      // Cambia el color del interruptor a rojo cuando est� en OFF
    OpcClient.Active := false;              // disconnect from server
  end;
end;

// procedure para topic drop down
procedure TForm1.TopicComboDropDown(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  TopicosList(OPCClient.Browser,TopicCombo.Items);
  Screen.Cursor :=crDefault;
end;
// begin button inicia todos los tags del plc
procedure TForm1.bBeginClick(Sender: TObject);
begin
   selectedTopic :=  TopicCombo.Text;
   StatusMemo.Lines.Add('Selected Topic: ' + selectedTopic);
   TAGS := OPCClient.OPCGroups.Add('tags_plc');

   ControlPanel.Enabled := true;
   // inicializa variables del plc
   // botones remotos
   start_rem := TAGS.OPCItems.AddItem('[' + selectedTopic + ']B3:0/12');
   stop_rem := TAGS.OPCItems.AddItem('[' + selectedTopic + ']B3:0/13');
   reset_rem := TAGS.OPCItems.AddItem('[' + selectedTopic + ']B3:0/14');
   // sensores de expulsion y compresion
   
   sc1 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']I:1/2');
   se1 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']I:1/3');
   sc2 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']I:1/4');
   se2 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']I:1/5');
   sc3 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']I:1/6');
   se3 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']I:1/7');
   // electrovalvulas
   ev_e1 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']O:3/0');
   ev_c1 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']O:3/1');
   ev_e2 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']O:3/2');
   ev_c2 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']O:3/3');
   ev_e3 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']O:3/4');
   ev_c3 := TAGS.OPCItems.AddItem('[' + selectedTopic + ']O:3/5');
   // contadores y timers
   count_pre := TAGS.OPCItems.AddItem('[' + selectedTopic + ']C5:0.PRE');
   count_acc := TAGS.OPCItems.AddItem('[' + selectedTopic + ']C5:0.ACC');
   timer_neum_en := TAGS.OPCItems.AddItem('[' + selectedTopic + ']T4:0/EN');
   timer_neum_dn := TAGS.OPCItems.AddItem('[' + selectedTopic + ']T4:0/DN');
   timer_neum_pre := TAGS.OPCItems.AddItem('[' + selectedTopic + ']T4:0.PRE');

   // ininializa memorias de electrovalvulas
    prev_ev_e1 := ev_e1.ValueStr;
    prev_ev_c1 := ev_c1.ValueStr;
    prev_ev_e2 := ev_e2.ValueStr;
    prev_ev_c2 := ev_c2.ValueStr;
    prev_ev_e3 := ev_e3.ValueStr;
    prev_ev_c3 := ev_c3.ValueStr;

end;

// *****************************************************************************

// ************* CONFIGURACION DE BOTONES **************************************
// boton START
procedure TForm1.StartPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  StartPanel.Color :=   clBtnFace;
  start_rem.WriteAsync(1);
end;
procedure TForm1.StartPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  StartPanel.Color :=   clBtnHighlight;
  start_rem.WriteAsync(0);
end;


// boton STOP
procedure TForm1.StopPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     StopPanel.Color :=   clBtnFace;
     stop_rem.WriteAsync(1);
end;
procedure TForm1.StopPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   StopPanel.Color :=   clBtnHighlight;
   stop_rem.WriteAsync(0);
end;

// boton RESET
procedure TForm1.ResetPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   ResetPanel.Color :=   clBtnFace;
   reset_rem.WriteAsync(1);
end;
procedure TForm1.ResetPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ResetPanel.Color :=   clBtnHighlight;
  reset_rem.WriteAsync(0);
end;
// *****************************************************************************

procedure TForm1.bCount_pre_okClick(Sender: TObject);
begin
    count_pre.WriteAsync(strToInt(count_pre_edit.Text));
    statusMemo.Lines.Add('Changed counter preset to: ' + count_pre_edit.Text);
end;


// **************************** Timers *****************************************
// Piston 1A
  procedure TForm1.Piston1AOutTimer(Sender: TObject);
  begin
      if vastago1A.Left > 30 then
         vastago1A.Left := vastago1A.Left - 4
      else
        Piston1AOut.Enabled := false;
  end;

procedure TForm1.Piston1AInTimer(Sender: TObject);
  begin
      if vastago1A.Left < 160 then
         vastago1A.Left := vastago1A.Left + 4
      else
        Piston1AIn.Enabled := false;
  end;
// Piston 2A
procedure TForm1.Piston2AOutTimer(Sender: TObject);
begin
   if vastago2A.Left > 30 then
         vastago2A.Left := vastago2A.Left - 4
   else
        Piston2AOut.Enabled := false;
end;

procedure TForm1.Piston2AInTimer(Sender: TObject);
begin
    if vastago2A.Left < 160 then
         vastago2A.Left := vastago2A.Left + 4
    else
        Piston2AIn.Enabled := false;
end;
// Piston 3A
procedure TForm1.Piston3AOutTimer(Sender: TObject);
begin
    if vastago3A.Left > 30 then
         vastago3A.Left := vastago3A.Left - 4
   else
        Piston3AOut.Enabled := false;
end;

procedure TForm1.Piston3AInTimer(Sender: TObject);
begin
   if vastago3A.Left < 160 then
         vastago3A.Left := vastago3A.Left + 4
    else
        Piston3AIn.Enabled := false;
end;
// Pistones neumaticos
// Sale Piston 4A
procedure TForm1.Piston4AOutTimer(Sender: TObject);
begin
  if vastago4A.Left > 112 then
         vastago4A.Left := vastago4A.Left - 4
   else
        Piston4AOut.Enabled := false;
end;
// Espera para Piston 5A
procedure TForm1.PistonesNeumDelayTimer(Sender: TObject);
begin
   PistonesNeumDelay.Enabled := false;
   Piston5AOut.Enabled := true;
end;
 // Sale Piston 5A
procedure TForm1.Piston5AOutTimer(Sender: TObject);
begin
     if vastago5A.Left > 112 then
         vastago5A.Left := vastago5A.Left - 4
   else
        Piston5AOut.Enabled := false;
end;
// Regresan los dos pistones
procedure TForm1.PistonesNeumInTimer(Sender: TObject);
begin
      if vastago4A.Left < 208 then  begin
         vastago4A.Left := vastago4A.Left + 4;
         vastago5A.Left := vastago4A.Left;
      end
      else
        PistonesNeumIn.Enabled := false;
end;





// *********** END ***********************
end.

