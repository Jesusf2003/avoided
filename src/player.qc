void info_player_start () {}; // Entidad para el editor

void PlayerJump () {
    if (!(self.flags & FL_ONGROUND))
		return;
    if ( !(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick
    
    self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	self.flags = self.flags - FL_ONGROUND;	// don't stairwalk

	self.button2 = 0;
    self.velocity_z = self.velocity_z + 270;
};

void PlayerPreThink () {
	// intermission or finale
	if (self.view_ofs == '0 0 0')
		return;

	// is this still used
	makevectors (self.v_angle);

	if (self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

	// teleporters can force a non-moving pause time
	if (time < self.pausetime)
		self.velocity = '0 0 0';
};

void PlayerPostThink () {
    if (self.view_ofs == '0 0 0')
		return;
    if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;
};

entity SelectSpawnPoint () {
    local entity spot;

    spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");

	return spot;
};

void PutClientInServer () {
    local entity spot = SelectSpawnPoint();

    self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
    setmodel(self, "models/testplayer.iqm");
	self.movetype = MOVETYPE_WALK;
	self.flags = FL_CLIENT;
	self.health = 100;
	self.fixangle = TRUE;
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.view_ofs = '0 0 22';

    self.pausetime = 0;

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
};