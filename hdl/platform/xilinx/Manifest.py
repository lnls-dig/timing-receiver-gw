def __dirs():
	dirs = []

	if (target == "xilinx" and syn_device[0:4].upper()=="XC7A"):
		dirs.extend(["artix7"]);
	#else: #add paltform here and generate the corresponding ip cores
	return dirs

modules = {
    "local" : __dirs()
           }
