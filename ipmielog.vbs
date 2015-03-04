option explicit
on error resume next

dim ws, cmd, ev, ts, i, re1, re2, re3, st, rc

st=1
set re1=WScript.CreateObject("VBScript.RegExp")
re1.pattern=" Crit-"
set re2=WScript.CreateObject("VBScript.RegExp")
re2.pattern=" Fault"
set re3=WScript.CreateObject("VBScript.RegExp")
re3.pattern=" completed"

set ws=WScript.CreateObject("WScript.Shell")
set cmd=ws.exec("ipmiutil sensor -N 127.0.0.1 -U root -P xxxx -V 2")
' set cmd=ws.exec("cmd /c type c:\tmp\ipmiutil.txt")
if cmd then
 set ts=cmd.stdout
 do until ts.AtEndOfStream
  i=ts.ReadLine
  WScript.echo i
  if re1.test(i) then
   eventlog(i)
  elseif re2.test(i) then
   eventlog(i)
  elseif re3.test(i) then
   st=0
  end if
 Loop
 ts.close
end if

if st <> 0 then
 eventlog("ipmiutil error")
end if

sub eventlog (msg)
 ws.exec("eventcreate /ID 1 /L system /SO IPMI /T Error /D """ + msg + """")
end sub
