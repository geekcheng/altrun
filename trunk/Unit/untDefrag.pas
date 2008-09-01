(*
    DEFRAG.PAS : Unit used to defrag the Ms-Windows memory
    Copyright (C) 2000  Yohanes Nugroho

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

    Yohanes Nugroho (yohanes_n@hotmail.com)
    Kp Areman RT 09/08 No 71
    Ds Tugu Cimanggis
    Bogor 16951
    Indonesia
*)

unit untDefrag;

interface
uses Windows;

type
  proc = procedure;
var
  bussy: boolean;

  //limit dalam satuan megabyte
procedure defragmem(limit: integer; x: proc);

implementation

procedure defragmem(limit: integer; x: proc);
var
  tab: array[0..1024] of pointer;
  i: integer;
  p: pointer;
  lim: integer;
begin
  if bussy then exit;
  bussy := true;
  lim := limit;
  if lim > 1024 then lim := 1024;
  for i := 0 to lim do tab[i] := nil;
  for i := 0 to lim - 1 do
  begin
    p := VirtualAlloc(nil, 1024 * 1024, MEM_COMMIT,
      PAGE_READWRITE + PAGE_NOCACHE);
    tab[i] := p;
    asm
                 pushad
                 pushfd
                 mov   edi, p
                 mov   ecx, 1024*1024/4
                 xor   eax, eax
                 cld
                 repz  stosd
                 popfd
                 popad
    end;
    if assigned(x) then x;
  end;
  for i := 0 to lim - 1 do
  begin
    VirtualFree(Tab[i], 0, MEM_RELEASE);
    if assigned(x) then x;
  end;
  bussy := false;
end;

begin
  bussy := false;
end.

