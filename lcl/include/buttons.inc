{%MainUnit ../stdctrls.pp}
{ $Id: buttons.inc 20254 2009-05-27 00:40:55Z paul $}

{******************************************************************************
                                   TCustomButton
 ******************************************************************************

 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}

{------------------------------------------------------------------------------
       TCustomButton Constructor
------------------------------------------------------------------------------}

constructor TCustomButton.Create(TheOwner: TComponent);
begin
  Inherited Create(TheOwner);
  // set the component style to csButton
  fCompStyle := csButton;
  ControlStyle:=ControlStyle-[csClickEvents]+[csHasDefaultAction,csHasCancelAction];
  Color:=clBtnFace;
  ParentColor:=false;
  TabStop := true;
  // set default alignment
  Align := alNone;
  // setup default sizes
  SetInitialBounds(0,0,GetControlClassDefaultSize.X,GetControlClassDefaultSize.Y);
end;

{------------------------------------------------------------------------------
  Method:  TCustomButton.CreateWnd
  Params:  None
  Returns: Nothing

  Creates the interface object.
 ------------------------------------------------------------------------------}
procedure TCustomButton.CreateWnd;
begin
  inherited CreateWnd;
  //this is done in TWinControl
  //SetText(Caption);//To ensure shortcut is set
  UpdateDefaultCancel;
end;

procedure TCustomButton.ControlKeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited ControlKeyDown(Key, Shift);
end;

procedure TCustomButton.ControlKeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited ControlKeyUp(Key, Shift);
end;

procedure TCustomButton.UpdateRolesForForm;
var
  AForm: TCustomForm;
  NewRoles: TControlRolesForForm;
begin
  AForm:=GetParentForm(Self);
  if AForm=nil then begin
    // not on a form => keep settings
    exit;
  end else begin
    // on a form => use settings of parent form
    NewRoles:=AForm.GetRolesForControl(Self);
    Default := crffDefault in NewRoles;
    Cancel := crffCancel in NewRoles;
  end;
end;

{------------------------------------------------------------------------------
  Method:  TCustomButton.SetCancel
  Params:  NewCancel - new cancel value
  Returns: Nothing
 ------------------------------------------------------------------------------}
procedure TCustomButton.SetCancel(NewCancel: boolean);
var
  Form: TCustomForm;
begin
  if FCancel = NewCancel then Exit;
  FCancel := NewCancel;
  Form := GetParentForm(Self);
  if Form <> nil then
  begin
    if NewCancel then
      Form.CancelControl := Self
    else
      Form.CancelControl := nil;
  end;
end;

{------------------------------------------------------------------------------
  Method:  TCustomButton.SetDefault
  Params:  Value
  Returns: Nothing
 ------------------------------------------------------------------------------}
procedure TCustomButton.SetDefault(Value : Boolean);
var
  Form: TCustomForm;
begin
  if FDefault = Value then Exit;
  FDefault := Value;
  Form := GetParentForm(Self);
  if Form <> nil then
  begin
    if Value then
    begin
      Form.DefaultControl := Self;
    end else
    begin
      if Form.DefaultControl = Self then
        Form.DefaultControl := nil;
     end;
  end;
  WSSetDefault;
end;

procedure TCustomButton.SetModalResult(const AValue: TModalResult);
begin
  if AValue=FModalResult then exit;
  FModalResult:=AValue;
end;

procedure TCustomButton.ExecuteDefaultAction;
begin
  if FActive or FDefault then
    Click;
end;

procedure TCustomButton.ExecuteCancelAction;
begin
  if FCancel then
    Click;
end;

{------------------------------------------------------------------------------
  Method:  TCustomButton.Click
  Params:  None
  Returns: Nothing

  Handles the event that the button is clicked
 ------------------------------------------------------------------------------}
procedure TCustomButton.Click;
var
  Form : TCustomForm;
Begin
  if ModalResult <> mrNone
  then begin
    Form := GetParentForm(Self);
    if Form <> nil then Form.ModalResult := ModalResult;
  end;
  inherited Click;
end;

function TCustomButton.DialogChar(var Message: TLMKey): boolean;
begin
  if IsAccel(Message.CharCode, Caption) and CanFocus then
  begin
    Click;
    Result := true;
  end else
    Result := inherited;
end;

procedure TCustomButton.ActiveDefaultControlChanged(NewControl: TControl);
var
  lPrevActive: boolean;
  lForm: TCustomForm;
begin
  lPrevActive := FActive;
  lForm := GetParentForm(Self);
  if NewControl = Self then
  begin
    FActive := True;
    if lForm <> nil then
      lForm.ActiveDefaultControl := Self;
  end else 
  if NewControl <> nil then
    FActive := False
  else
  begin
    FActive := FDefault;
    if lForm.ActiveDefaultControl = Self then
      lForm.ActiveDefaultControl := nil;
  end;
  if lPrevActive <> FActive then
    WSSetDefault;
end;

procedure TCustomButton.CMUIActivate(var Message: TLMessage);
begin
  UpdateFocus(True);
end;

procedure TCustomButton.WMSetFocus(var Message: TLMSetFocus);
begin
  inherited;

  UpdateFocus(True);
end;

procedure TCustomButton.WMKillFocus(var Message: TLMKillFocus);
begin
  inherited;

  // if no change then exit
  if Message.FocusedWnd <> Handle then
    UpdateFocus(False);
end;

procedure TCustomButton.UpdateFocus(AFocused: Boolean);
var
  lForm: TCustomForm;
begin
  lForm := GetParentForm(Self);
  if lForm = nil then exit;

  if AFocused then
    ActiveDefaultControlChanged(lForm.ActiveControl)
  else
    ActiveDefaultControlChanged(nil);
end;

class procedure TCustomButton.WSRegisterClass;
begin
  inherited WSRegisterClass;
  RegisterCustomButton;
end;

function TCustomButton.ChildClassAllowed(ChildClass: TClass): boolean;
begin
  // no childs
  Result:=false;
end;

class function TCustomButton.GetControlClassDefaultSize: TPoint;
begin
  Result.X:=75;
  Result.Y:=25;
end;

function TCustomButton.UseRightToLeftAlignment: Boolean;
begin
  //Button always has center alignment
  Result := False;
end;

procedure TCustomButton.WSSetText(const AText: String);
var
  ParseStr : String;
  AccelIndex : Longint;
  OldShortCut: TShortCut;
begin
  if (not HandleAllocated) then
    exit;
  if not (csDesigning in ComponentState) then
  begin
    ParseStr := AText;
    AccelIndex := DeleteAmpersands(ParseStr);
    if AccelIndex > -1 then
    begin
      OldShortCut := FShortCut;
      FShortCut := ShortCut(Char2VK(ParseStr[AccelIndex]), [ssCtrl]);
      TWSButtonClass(WidgetSetClass).SetShortCut(Self, OldShortCut, FShortCut);
    end;
  end;
  inherited WSSetText(AText);
  //DebugLn(['TCustomButton.WSSetText ',dbgsName(Self),' Caption="',Caption,'" AutoSizeCanStart=',AutoSizeCanStart,' AutoSizeDelayed=',AutoSizeDelayed]);
end;

procedure TCustomButton.TextChanged;
begin
  InvalidatePreferredSize;
  if (Parent<>nil) and Parent.AutoSize then
    Parent.AdjustSize;
  AdjustSize;
  inherited TextChanged;
end;

procedure TCustomButton.Loaded;
begin
  inherited Loaded;

  UpdateDefaultCancel;
end;

procedure TCustomButton.UpdateDefaultCancel;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);
  if Form <> nil then
  begin
    if FDefault then
      Form.DefaultControl := Self;
    if FCancel then
      Form.CancelControl := Self;
  end;
  WSSetDefault;
end;

{------------------------------------------------------------------------------
  procedure TCustomButton.DoSendBtnDefault;
 ------------------------------------------------------------------------------}
procedure TCustomButton.WSSetDefault;
begin
  // Default only tell us if button was set to Default in the design time.
  // In run time Active actually shows us if this button is a default button
  // (will be clicked on enter)
  if HandleAllocated then
    TWSButtonClass(WidgetSetClass).SetDefault(Self, FActive);
end;


{ TButton }

procedure TButton.Click;
begin
  inherited Click;
end;



