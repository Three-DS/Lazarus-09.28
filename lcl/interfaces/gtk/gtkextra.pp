{ $Id: gtkextra.pp 17417 2008-11-18 02:31:29Z paul $ }
{
 ---------------------------------------------------------------------------
 gtkextra.pp  -  GTK(2) widgetset - additional gdk/gtk functions
 ---------------------------------------------------------------------------

 This unit contains missing gdk/gtk functions and defines for certain 
 versions of gtk or fpc.

 ---------------------------------------------------------------------------

 @created(Sun Jan 28th WET 2006)
 @lastmod($Date: 2008-11-18 03:31:29 +0100 (Tue, 18 Nov 2008) $)
 @author(Marc Weustink <marc@@dommelstein.nl>)

 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,        *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
 }

unit GtkExtra;

{$mode objfpc}{$H+}

interface

{$I gtkdefines.inc}

{$ifdef gtk1}
{$I gtk1extrah.inc}
{$endif}

{$ifdef gtk2}
{$I gtk2extrah.inc}
{$endif}


implementation

{$ifdef gtk1}
{$I gtk1extra.inc}
{$endif}

{$ifdef gtk2}
{$I gtk2extra.inc}
{$endif}

end.
