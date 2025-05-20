# win_time

win_time ist ein CmdTool um die Dauer von Cmd-Befehlen bequem zu messen.
Geschrieben in Zig, mit Fokus auf Stack Allocations.

## Benutzung
Nach dem Komilieren 'zig build -Doptimize=ReleaseFast' ist die Binary in die Umgebungsvariable einzufügen.
Danach kann ganz sie vor jedem Befehl in der Cmd aufgelistet werden und gibt dann die Dauer des folgenden Befehls nach dessen Beendigung aus.

Bsp.
win_time dir
win_time netstat
