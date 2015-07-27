

all:
		lazbuild -B solarinfobank.lpi
		#fpc  -MObjFPC -Scghi -O1 -g -gl -vewnhi -Filib/x86_64-linux -Fl/opt/gnome/lib -Fusynapse/source/lib -Fu../.lazarus/lib/units/x86_64-linux/gtk2 -Fu../.lazarus/lib/LCLBase/units/x86_64-linux -Fu../.lazarus/lib/LazUtils/lib/x86_64-linux -Fu../.lazarus/lib/units/x86_64-linux -Fu. -FUlib/x86_64-linux -l -dLCL -dLCLgtk2 solarinfobank.lpr

clean:
		rm -f *.bak

