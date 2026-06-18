void main () {
    bprint("Standalone project.\n");
    precache_file("progs.dat");
    precache_file("default.cfg");
    precache_file("maps/demo.bsp");
};

void worldspawn (void){
	cvar_set("sv_gravity", "800");
    precache_model("models/player.mdl");
};

void StartFrame () {};

// Funciones de red necesarias para que no crashee
void ClientConnect () {};
void ClientDisconnect () {};
void SetNewParms () {};
float CSQC_InputEvent( float flEventType, float flKey, float flCharacter ) {
    return FALSE;
}