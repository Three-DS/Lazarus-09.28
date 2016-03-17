{
 *****************************************************************************
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************

  Abstract:
    Defines interface to source editors.
}
unit SrcEditorIntf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLProc, FileUtil, Forms, Controls, ProjectIntf;
  
type
  TSrcEditSearchOption = (
    sesoMatchCase,
    sesoWholeWord,
    sesoBackwards,
    sesoEntireScope,
    sesoSelectedOnly,
    sesoReplace,
    sesoReplaceAll,
    sesoPrompt,
    sesoRegExpr,
    sesoMultiLine
    );
  TSrcEditSearchOptions = set of TSrcEditSearchOption;

  TSrcEditReplaceAction = (seraCancel, seraSkip, seraReplace, seraReplaceAll);

  { TSourceEditorInterface }

  TSourceEditorInterface = class
  protected
    function GetBlockBegin: TPoint; virtual; abstract;
    function GetBlockEnd: TPoint; virtual; abstract;
    function GetCodeToolsBuffer: TObject; virtual; abstract;
    function GetCursorScreenXY: TPoint; virtual; abstract;
    function GetCursorTextXY: TPoint; virtual; abstract;
    function GetEditorControl: TWinControl; virtual; abstract;
    function GetFileName: string; virtual; abstract;
    function GetLines: TStrings; virtual; abstract;
    function GetLineText: string; virtual; abstract;
    function GetModified: Boolean; virtual; abstract;
    function GetReadOnly: Boolean; virtual; abstract;
    function GetSelection: string; virtual; abstract;
    function GetSelEnd: Integer; virtual; abstract;
    function GetSelStart: Integer; virtual; abstract;
    function GetSourceText: string; virtual; abstract;
    function GetTopLine: Integer; virtual; abstract;
    procedure SetBlockBegin(const AValue: TPoint); virtual; abstract;
    procedure SetBlockEnd(const AValue: TPoint); virtual; abstract;
    procedure SetCursorScreenXY(const AValue: TPoint); virtual; abstract;
    procedure SetCursorTextXY(const AValue: TPoint); virtual; abstract;
    procedure SetLines(const AValue: TStrings); virtual; abstract;
    procedure SetLineText(const AValue: string); virtual; abstract;
    procedure SetModified(const NewValue: Boolean); virtual; abstract;
    procedure SetReadOnly(const AValue: Boolean); virtual; abstract;
    procedure SetSelection(const AValue: string); virtual; abstract;
    procedure SetSelEnd(const AValue: Integer); virtual; abstract;
    procedure SetSelStart(const AValue: Integer); virtual; abstract;
    procedure SetSourceText(const AValue: string); virtual; abstract;
    procedure SetTopLine(const AValue: Integer); virtual; abstract;
  public
    // selections
    function SelectionAvailable: boolean; virtual; abstract;
    function GetText(OnlySelection: boolean): string; virtual; abstract;
    procedure SelectText(LineNum, CharStart, LineNum2, CharEnd: Integer);
    procedure SelectText(const StartPos, EndPos: TPoint); virtual; abstract;
    procedure ReplaceLines(StartLine, EndLine: integer; const NewText: string); virtual; abstract;
    procedure ReplaceText(const StartPos, EndPos: TPoint; const NewText: string);
    procedure AskReplace(Sender: TObject; const ASearch, AReplace: string;
                        Line, Column: integer;
                        var Action: TSrcEditReplaceAction); virtual; abstract;
    procedure CopyToClipboard; virtual; abstract;
    procedure CutToClipboard; virtual; abstract;

    // screen and text position mapping
    function LineCount: Integer; virtual; abstract;
    function TextToScreenPosition(const Position: TPoint): TPoint; virtual; abstract;
    function ScreenToTextPosition(const Position: TPoint): TPoint; virtual; abstract;

    // characters and pixels
    function WidthInChars: Integer; virtual; abstract;
    function HeightInLines: Integer; virtual; abstract;
    function CharWidth: integer; virtual; abstract;
    function CursorInPixel: TPoint; virtual; abstract;
    function ScreenToPixelPosition(const Position: TPoint): TPoint; virtual; abstract;// ScreenXY to pixel in EditorControl.
      // To get the desktop pixel coords use:
      //   with SourceEditorWindow.ActiveEditor do
      //     DesktopXY:=EditorControl.ClientToScreen(ScreenToPixelPosition(ScreenXY));

    // update
    procedure BeginUndoBlock; virtual; abstract;
    procedure EndUndoBlock; virtual; abstract;
    procedure BeginUpdate; virtual; abstract; // block painting
    procedure EndUpdate; virtual; abstract;
    procedure IncreaseIgnoreCodeBufferLock; virtual; abstract;
    procedure DecreaseIgnoreCodeBufferLock; virtual; abstract;
    procedure UpdateCodeBuffer; virtual; abstract;// copy the source from EditorComponent to the codetools
    function NeedsUpdateCodeBuffer: boolean; virtual; abstract;// needs UpdateCodeBuffer

    // search and replace
    function SearchReplace(const ASearch, AReplace: string;
                           SearchOptions: TSrcEditSearchOptions): integer; virtual; abstract;

    // context
    function GetProjectFile: TLazProjectFile; virtual; abstract;
    function GetDesigner(LoadForm: boolean): TIDesigner; virtual; abstract;
  public
    property BlockBegin: TPoint read GetBlockBegin write SetBlockBegin;
    property BlockEnd: TPoint read GetBlockEnd write SetBlockEnd;
    property CodeToolsBuffer: TObject read GetCodeToolsBuffer;
    property CursorScreenXY: TPoint read GetCursorScreenXY write SetCursorScreenXY;
    property CursorTextXY: TPoint read GetCursorTextXY write SetCursorTextXY;
    property EditorControl: TWinControl read GetEditorControl;// normally TSynEdit
    property FileName: string read GetFileName;
    property Lines: TStrings read GetLines write SetLines;// the whole file
    property CurrentLineText: string read GetLineText write SetLineText;// source of current line
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property Selection: string read GetSelection write SetSelection;
    property SelEnd: Integer read GetSelEnd write SetSelEnd;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SourceText: string read GetSourceText write SetSourceText;// the whole file
    property TopLine: Integer read GetTopLine write SetTopLine;// first visible line
    property Modified: Boolean read GetModified write SetModified;
  end;

  { TSourceEditorWindowInterface }

  TSourceEditorWindowInterface = class(TForm)
  protected
    function GetItems(Index: integer): TSourceEditorInterface; virtual; abstract;
  protected
    function GetActiveEditor: TSourceEditorInterface; virtual; abstract;
    procedure SetActiveEditor(const AValue: TSourceEditorInterface); virtual; abstract;
    function GetCompletionBoxPosition: integer; virtual; abstract;
  public
    function SourceEditorIntfWithFilename(
                                const Filename: string): TSourceEditorInterface;
    property ActiveEditor: TSourceEditorInterface read GetActiveEditor
                                                  write SetActiveEditor;
    function Count: integer; virtual; abstract;
    property Items[Index: integer]: TSourceEditorInterface read GetItems; default;
    
    function GetEditorControlSettings(EditControl: TControl): boolean; virtual; abstract;
    function GetHighlighterSettings(Highlighter: TObject): boolean; virtual; abstract;
    procedure ClearErrorLines; virtual; abstract;

    property CompletionBoxPosition: integer read GetCompletionBoxPosition;
  end;
  
  
var
  SourceEditorWindow: TSourceEditorWindowInterface = nil;// set by the IDE


type

  { TIDEInteractiveStringValue }

  TIDEInteractiveStringValue = class(TPersistent)
  private
    FValue: string;
  published
    property Value: string read FValue write FValue;
  end;

  { TIDETemplateParser }

  TIDETemplateParser = class
  protected
    function GetSrcPosition: Integer; virtual; abstract;
    function GetDestPosition: Integer; virtual; abstract;
    function GetDestPosX: Integer; virtual; abstract;
    function GetDestPosY: Integer; virtual; abstract;
    function GetSrcTemplate: String; virtual; abstract;
    function GetDestTemplate: String; virtual; abstract;
  public
    property SrcTemplate: String read GetSrcTemplate;
    property DestTemplate: String read GetDestTemplate;
    property SrcPosition: Integer read GetSrcPosition;
    property DestPosition: Integer read GetDestPosition;
    property DestPosX: Integer read GetDestPosX;
    property DestPosY: Integer read GetDestPosY;
  end;

  TIDECodeMacroGetValueProc = function(const Parameter: string;
                      InteractiveValue: TPersistent;
                      SrcEdit: TSourceEditorInterface;
                      var Value, ErrorMsg: string): boolean;
  TIDECodeMacroGetValueMethod = function(const Parameter: string;
                      InteractiveValue: TPersistent;
                      SrcEdit: TSourceEditorInterface;
                      var Value, ErrorMsg: string): boolean of object;

  TIDECodeMacroGetValueExProc = function(const Parameter: string;
                      InteractiveValue: TPersistent;
                      SrcEdit: TSourceEditorInterface;
                      var Value, ErrorMsg: string;
                      TemplateParser: TIDETemplateParser): boolean;
  TIDECodeMacroGetValueExMethod = function(const Parameter: string;
                      InteractiveValue: TPersistent;
                      SrcEdit: TSourceEditorInterface;
                      var Value, ErrorMsg: string;
                      TemplateParser: TIDETemplateParser): boolean of object;

  { TIDECodeMacro }

  TIDECodeMacro = class
  private
    FInteractive: boolean;
    FInteractiveValueClass: TPersistentClass;
    FLongDescription: string;
    FName: string;
    FOnGetValueMethod: TIDECodeMacroGetValueMethod;
    FOnGetValueProc: TIDECodeMacroGetValueProc;
    FOnGetValueExMethod: TIDECodeMacroGetValueExMethod;
    FOnGetValueExProc: TIDECodeMacroGetValueExProc;
    FShortDescription: string;
  protected
    procedure Init; virtual;
  public
    constructor Create(const TheName: string);
    property Name: string read FName;
    property ShortDescription: string read FShortDescription write FShortDescription;
    property LongDescription: string read FLongDescription write FLongDescription;
    property OnGetValueProc: TIDECodeMacroGetValueProc read FOnGetValueProc
                                                       write FOnGetValueProc;
    property OnGetValueMethod: TIDECodeMacroGetValueMethod read FOnGetValueMethod
                                                       write FOnGetValueMethod;
    property OnGetValueExProc: TIDECodeMacroGetValueExProc read FOnGetValueExProc
                                                       write FOnGetValueExProc;
    property OnGetValueExMethod: TIDECodeMacroGetValueExMethod read FOnGetValueExMethod
                                                       write FOnGetValueExMethod;
    function GetValue(const Parameter: string; InteractiveValue: TPersistent;
                      SrcEdit: TSourceEditorInterface; out Value, ErrorMsg: string;
                      TemplateParser: TIDETemplateParser = nil): boolean; virtual;
    property Interactive: boolean read FInteractive write FInteractive;
    property InteractiveValueClass: TPersistentClass read FInteractiveValueClass
                                                   write FInteractiveValueClass;
  end;


  { TIDECodeMacros }

  TIDECodeMacros = class
  protected
    function GetItems(Index: integer): TIDECodeMacro; virtual; abstract;
  public
    property Items[Index: integer]: TIDECodeMacro read GetItems; default;
    function Count: integer; virtual; abstract;
    function Add(Macro: TIDECodeMacro): integer; virtual; abstract;
    function FindByName(const AName: string): TIDECodeMacro; virtual; abstract;
    function CreateUniqueName(const AName: string): string; virtual; abstract;
  end;

var
  IDECodeMacros: TIDECodeMacros = nil; // set by the IDE

function RegisterCodeMacro(const Name: string;
  const ShortDescription, LongDescription: string;
  OnGetValueProc: TIDECodeMacroGetValueProc;
  OnGetValueMethod: TIDECodeMacroGetValueMethod): TIDECodeMacro;

function RegisterCodeMacroEx(const Name: string;
  const ShortDescription, LongDescription: string;
  OnGetValueProc: TIDECodeMacroGetValueExProc;
  OnGetValueMethod: TIDECodeMacroGetValueExMethod): TIDECodeMacro;

{ SearchInFile to search in a file.
  This can be interactively or without user interaction.
  If the file is open in the source editor, changes will be added to the undo
  history.
}
type
  TIDESearchInTextAddMatch = procedure(const Filename: string;
                                  const StartPos, EndPos: TPoint;
                                  const Lines: string) of object;

  { TIDESearchInTextProgress }

  TIDESearchInTextProgress = class
  private
    FAbort: boolean;
    FOnAddMatch: TIDESearchInTextAddMatch;
  protected
    procedure SetAbort(const AValue: boolean); virtual;
  public
    property Abort: boolean read FAbort write SetAbort;
    property OnAddMatch: TIDESearchInTextAddMatch read FOnAddMatch write FOnAddMatch;
  end;

  TIDESearchInTextFunction = function(const TheFileName: string;
    var TheText: string;// if TheFileName='' then use TheText
    SearchFor, ReplaceText: string; Flags: TSrcEditSearchOptions;
    var Prompt: boolean; Progress: TIDESearchInTextProgress = nil): TModalResult;

var
  IDESearchInText: TIDESearchInTextFunction = nil;// set by the IDE

implementation

function RegisterCodeMacro(const Name: string; const ShortDescription,
  LongDescription: string; OnGetValueProc: TIDECodeMacroGetValueProc;
  OnGetValueMethod: TIDECodeMacroGetValueMethod): TIDECodeMacro;
var
  NewName: String;
begin
  NewName:=IDECodeMacros.CreateUniqueName(Name);
  Result:=TIDECodeMacro.Create(NewName);
  Result.ShortDescription:=ConvertLineEndings(ShortDescription);
  Result.LongDescription:=ConvertLineEndings(LongDescription);
  Result.OnGetValueProc:=OnGetValueProc;
  Result.OnGetValueMethod:=OnGetValueMethod;
  IDECodeMacros.Add(Result);
end;

function RegisterCodeMacroEx(const Name: string; const ShortDescription,
  LongDescription: string; OnGetValueProc: TIDECodeMacroGetValueExProc;
  OnGetValueMethod: TIDECodeMacroGetValueExMethod): TIDECodeMacro;
var
  NewName: String;
begin
  NewName:=IDECodeMacros.CreateUniqueName(Name);
  Result:=TIDECodeMacro.Create(NewName);
  Result.ShortDescription:=ConvertLineEndings(ShortDescription);
  Result.LongDescription:=ConvertLineEndings(LongDescription);
  Result.OnGetValueExProc:=OnGetValueProc;
  Result.OnGetValueExMethod:=OnGetValueMethod;
  IDECodeMacros.Add(Result);
end;

{ TSourceEditorInterface }

procedure TSourceEditorInterface.SelectText(LineNum, CharStart, LineNum2,
  CharEnd: Integer);
begin
  SelectText(Point(CharStart,LineNum),Point(CharEnd,LineNum2));
end;

procedure TSourceEditorInterface.ReplaceText(const StartPos, EndPos: TPoint;
  const NewText: string);
begin
  BeginUpdate;
  BeginUndoBlock;
  SelectText(StartPos,EndPos);
  CursorTextXY:=StartPos;
  Selection:=NewText;
  EndUndoBlock;
  EndUpdate;
end;

{ TIDECodeMacro }

procedure TIDECodeMacro.Init;
begin
  FInteractiveValueClass:=TIDEInteractiveStringValue;
end;

constructor TIDECodeMacro.Create(const TheName: string);
begin
  FName:=TheName;
  FShortDescription:=FName;
  FLongDescription:=FName;
end;

function TIDECodeMacro.GetValue(const Parameter: string;
  InteractiveValue: TPersistent; SrcEdit: TSourceEditorInterface;
  out Value, ErrorMsg: string; TemplateParser: TIDETemplateParser = nil): boolean;
begin
  Value:=Parameter;
  ErrorMsg:='';
  if Assigned(OnGetValueProc) then
    Result:=OnGetValueProc(Parameter,InteractiveValue,SrcEdit,Value,ErrorMsg)
  else if Assigned(OnGetValueMethod) then
    Result:=OnGetValueMethod(Parameter,InteractiveValue,SrcEdit,Value,ErrorMsg)
  else if Assigned(OnGetValueExProc) then
    Result:=OnGetValueExProc(Parameter,InteractiveValue,SrcEdit,Value,ErrorMsg,
                             TemplateParser)
  else if Assigned(OnGetValueExMethod) then
    Result:=OnGetValueExMethod(Parameter,InteractiveValue,SrcEdit,Value,ErrorMsg,
                               TemplateParser)
  else
    Result:=true;
end;

{ TSourceEditorWindowInterface }

function TSourceEditorWindowInterface.SourceEditorIntfWithFilename(
  const Filename: string): TSourceEditorInterface;
var
  i: Integer;
begin
  for i:=Count-1 downto 0 do begin
    Result:=Items[i];
    if CompareFilenames(Result.Filename,Filename)=0 then exit;
  end;
  Result:=nil;
end;

{ TIDESearchInTextProgress }

procedure TIDESearchInTextProgress.SetAbort(const AValue: boolean);
begin
  if FAbort=AValue then exit;
  fAbort:=AValue;
end;

end.

