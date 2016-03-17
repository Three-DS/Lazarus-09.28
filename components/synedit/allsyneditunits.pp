{  $Id: allsyneditunits.pp 20917 2009-07-21 22:44:09Z martin $  }
{
 /***************************************************************************
                               allsyneditunits.pp

                      dummy unit to compile all units 

 /***************************************************************************
}
unit AllSynEditUnits;

{$mode objfpc}{$H+}

interface

uses
  SynTextDrawer, SynEditKeyCmds, SynEditTypes, SynEditStrConst,
  SynEditSearch, SynEditMiscProcs, SynEditmiscClasses, SynEditTextbuffer,
  SynEdit, SynEditHighlighter, SynCompletion, SynEditAutoComplete, 
  SynEditLazDsgn, SynRegExpr, SynEditRegexSearch, SynEditExport, 
  SynExportHTML, SynMemo, SynMacroRecorder, SynEditPlugins,
  SynPluginSyncronizedEditBase, SynPluginTemplateEdit, SynPluginSyncroEdit,
  SynHighlighterAsm,
  SynHighlighterAny,
  SynhighlighterCPP, 
  SynHighlighterCss, 
  SynHighlighterHashEntries, 
  SynhighlighterHTML, 
  SynHighlighterJava,
  SynHighlighterJScript,
  SynHighlighterLFM, 
  SynHighlighterMulti,
  SynHighlighterPas,
  SynHighlighterPerl, 
  SynHighlighterPHP,
  SynHighlighterPosition, 
  SynHighlighterPython, 
  SynHighlighterSQL,
  SynHighlighterTeX, 
  SynHighlighterUNIXShellScript, 
  SynHighlighterVB, 
  SynHighlighterXML,
  SynGutter, SynGutterChanges, SynGutterCodeFolding, SynGutterLineNumber, SynGutterMarks,
  SynPropertyEditObjectList, SynDesignStringConstants;

implementation

end.

