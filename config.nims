when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
switch("define", "ssl")
switch("threads", "on")
switch("mm", "orc")
switch("incremental", "on")
