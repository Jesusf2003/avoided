void() main = {
    print("Standalone project.\n");
    precache_file ("progs.dat");
    precache_file ("default.cfg");
    precache_file("maps/demo.bsp");
};

void() worldspawn = {
	cvar_set ("sv_gravity", "800");
    precache_model("models/testplayer.iqm");
};

void() StartFrame = {};

// Funciones de red necesarias para que no crashee
void() ClientConnect = {};
void() ClientDisconnect = {};
void() SetNewParms = {};
void() SetChangeParms = {};