option explicit
on error resume next
dim ws, cmd, ev, ts, i, w, re1, re2, re3, re4, s0, s1, debug, debug2
dim host, user, pass


host="10.xx.xx.xx"
user="root"
pass="xxxxxxxx"

debug=0
debug2=0

set re1=WScript.CreateObject("VBScript.RegExp")
re1.pattern="^.....SDR.([FC]...)............([c0][01248])"
set re2=WScript.CreateObject("VBScript.RegExp")
re2.pattern="^[0-9]"
set re3=WScript.CreateObject("VBScript.RegExp")
re3.pattern="^   Status of logical device"
set re4=WScript.CreateObject("VBScript.RegExp")
re4.pattern="^   Segment"

set ws=WScript.CreateObject("WScript.Shell")
set cmd=nothing
if debug then
 set cmd=ws.exec("cmd /c type hwchkerr.txt")
else
 set cmd=ws.exec("c:\windows\ipmiutil\ipmiutil sensor -N " _
                 +host+" -U "+user+" -P "+pass+" -V 2")
end if

if not cmd is nothing then
 if cmd.status = 0 then
  set ts=cmd.stdout
  do until ts.AtEndOfStream
   i=ts.ReadLine
   WScript.echo i
   s0=mid(i,59,4)
   s1=mid(i,64,4)
   if re1.test(i) then
    if strcomp(s0,"High") = 0 or strcomp(s0,"Warn") = 0 then
     eventlog "Warning", i
    elseif strcomp(s0, "Over") = 0 or strcomp(s0, "Crit") = 0 or _
           strcomp(s0, "Belo") = 0 or strcomp(s1,"Faul") = 0 then
     eventlog "Error", i
    elseif debug2 then
     eventlog "Information", i
    end if
   end if
  Loop
  ts.close
 end if
 if cmd.exitcode <> 0 then
  eventlog "Error", "ipmiutil sensor error rc=" + cstr(cmd.exitcode)
 end if
else
 eventlog "Error", "can not run ipmiutil sensor"
end if

set cmd=nothing
if debug then
 set cmd=ws.exec("cmd /c type hwchkerr.txt")
else
 set cmd=ws.exec("c:\windows\ipmiutil\ipmiutil sel -u -N " _
                 +host+" -U "+user+" -P "+pass+" -V 2")
end if
if not cmd is nothing then
 if cmd.status = 0 then
  set ts=cmd.stdout
  do until ts.AtEndOfStream
   i=ts.ReadLine
   WScript.echo i
   if re2.test(i) then
    w=mid(i, 24, 3)
    if strcomp(w, "MIN", 0) = 0 then
     eventlog "Warning", i
    elseif strcomp(w, "MAJ", 0) = 0 then
     eventlog "Warning", i
    elseif strcomp(w, "CRT", 0) = 0 then
     eventlog "Error", i
    elseif debug2 then
     eventlog "Information", i
    end if
   end if
  Loop
  ts.close
 end if
 if cmd.exitcode <> 0 then
  eventlog "Error", "ipmiutil sel error rc=" + cstr(cmd.exitcode)
 end if
else
 eventlog "Error", "can not run ipmiutil sel"
end if

set cmd=nothing
if debug then
 set cmd=ws.exec("cmd /c type hwchkerr.txt")
else
 set cmd=ws.exec("c:\program files\adaptec\adaptec storage manager\arcconf getconfig 1")
end if
if not cmd is nothing then
 if cmd.status = 0 then
  set ts=cmd.stdout
  do until ts.AtEndOfStream
   i=ts.ReadLine
   WScript.echo i
   if re3.test(i) then
    if strcomp(mid(i,47,7), "Degrade", 0) = 0 then
     eventlog "Error", i
    elseif debug2 then
     eventlog "Information", i
    end if
   elseif re4.test(i) then
    if strcomp(mid(i,47,7), "Inconsi", 0) = 0 then
     eventlog "Error", i
    elseif debug2 then
     eventlog "Information", i
    end if
   end if
  Loop
  ts.close
 end if
 if cmd.exitcode <> 0 then
  eventlog "Error", "ipmiutil sel error rc=" + cstr(cmd.exitcode)
 end if
else
 eventlog "Error", "can not run arcconf"
end if
WScript.quit(0)


sub eventlog (pri, msg)
 ws.exec("eventcreate /ID 1 /L system /SO IPMI /T " + pri + " /D """ + msg + """")
end sub
