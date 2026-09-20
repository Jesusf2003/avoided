/*  Copyright (C) 1996-1997  Id Software, Inc.

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
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

// prototypes
void(entity attacker, float damage) player_pain;
void() player_stand1;

float	modelindex_eyes, modelindex_player;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

float	intermission_running;
float	intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission = {};

void() SetChangeParms =
{
	if (self.health <= 0)
	{
		SetNewParms ();
		return;
	}

	// cap health carried across a level transition
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;
	parm2 = self.health;
};

void() SetNewParms =
{
	parm2 = 100;
};

void() DecodeLevelParms =
{
	if (serverflags)
	{
		if (world.model == "maps/start.bsp")
			SetNewParms ();		// take away all stuff on starting new episode
	}

	self.health = parm2;
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local entity spot;
	local float cyc;

	// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

	// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;

	// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	objerror ("FindIntermission: no spot");
	// avoid compiler warning
	return world;
};


string nextmap;

void() GotoNextMap =
{
	if (cvar("samelevel"))	// if samelevel is set, stay on same level
		changelevel (mapname);
	else
		changelevel (nextmap);
};


void() ExitIntermission =
{
	// skip any text in deathmatch
	if (deathmatch)
	{
		GotoNextMap ();
		return;
	}

	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

	GotoNextMap();
};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;

	ExitIntermission ();
};

void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;

	// enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);

	pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other != world)
	{
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;		// turn this way immediately
		other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}

	WriteByte (MSG_ALL, SVC_INTERMISSION);
};


void() changelevel_touch =
{
	if (other.classname != "player")
		return;

	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
		T_Damage (other, self, self, 50000);
		return;
	}

	// don't print the messages in singleplayer
	if (coop || deathmatch)
	{
		bprint(other.netname);
		bprint(" exited the level\n");
	}

	nextmap = self.map;

	SUB_UseTargets ();

	if ( (self.spawnflags & 1) && (deathmatch == 0) )
	{	// NO_INTERMISSION
		GotoNextMap();
		return;
	}

	self.touch = SUB_Null;

	// we can't move people right now, because touch functions are called
	// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
		objerror ("changelevel trigger doesn't have map");

	InitTrigger ();
	self.touch = changelevel_touch;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
	if (coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// set default spawn parms
		SetNewParms ();
		// respawn
		PutClientInServer ();
	}
	else
	{	// restart the entire server
		localcmd ("restart\n");
	}
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	bprint (self.netname);
	bprint (" suicides\n");
	set_suicide_frame ();
	self.modelindex = modelindex_player;
	self.frags = self.frags - 2;	// extra penalty
	respawn ();
};

float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local	entity spot;
	local entity thing;
	local float pcount;

	// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	// choose a info_player_deathmatch point
	if (coop)
	{
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (lastspawn == world)
			lastspawn = find (lastspawn, classname, "info_player_start");
		if (lastspawn != world)
			return lastspawn;
	}
	else if (deathmatch)
	{
		spot = lastspawn;
		// loop until a spawn point is located
		while(1) {
			// locate a spawn point
			spot = find(spot, classname, "info_player_deathmatch");
			// check that a spot was found
			if (spot != world) {
				// check if the spot is the same as the last spawn point checked
				if (spot == lastspawn) {
					return lastspawn;
				}
				// count the number of players close to the spawn point
				pcount = 0;
				thing = findradius(spot.origin, 32);
				while(thing) {
					if (thing.classname == "player") {
						pcount = pcount + 1;
					}
					thing = thing.chain;
				}
				// use spot if no players at spawn point
				if (pcount == 0) {
					lastspawn = spot;
					return spot;
				}
			}
		}
	}

	if (serverflags)
	{	// return with a rune to start
		spot = find (world, classname, "info_player_start2");
		if (spot)
			return spot;
	}

	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");

	return spot;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void() PlayerDie;


void() PutClientInServer =
{
	local	entity spot;

	spot = SelectSpawnPoint ();

	self.classname = "player";
	self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;

	DecodeLevelParms ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;

	self.deadflag = DEAD_NO;
	// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

	// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

	self.view_ofs = '0 0 22';

	player_stand1 ();
};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start = {};

/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 = {};

/*
saved out by quaked in region mode
*/
void() testplayerstart = {};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch = {};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop = {};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
*/
void() NextLevel =
{
	local entity o;

	if (mapname == "start")
	{
		mapname = "start";
		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger for the next level
		if (!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;

	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;

	if (gameover)	// someone else quit the game already
		return;

	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");

	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}

	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel ();
		return;
	}
};

//============================================================================

void() PlayerDeathThink =
{
	local float forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else
			self.velocity = forward * normalize(self.velocity);
	}

	// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
};


void() PlayerJump =
{
	if (self.flags & FL_WATERJUMP)
		return;

	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

		// play swimming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

	self.flags = self.flags - FL_ONGROUND;	// don't stairwalk

	self.button2 = 0;
	// player jumping sound
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
};


/*
===========
WaterMove

============
*/
.float	dmgtime;

void() WaterMove =
{
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			T_Damage (self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}

	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{
		// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, world, 10*self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{
		// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel);
		}
	}

	if ( !(self.flags & FL_INWATER) )
	{
		// player enter water sound
		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}

	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

void() CheckWaterJump =
{
	local vector start, end;

	// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};


/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
	if (intermission_running)
	{
		// otherwise a button could be missed between
		// the think tics
		IntermissionThink ();
		return;
	}

	// intermission or finale
	if (self.view_ofs == '0 0 0')
		return;

	// is this still used
	makevectors (self.v_angle);

	CheckRules ();
	WaterMove ();

	if (self.waterlevel == 2)
		CheckWaterJump ();

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}

	// dying, so do nothing
	if (self.deadflag == DEAD_DYING)
		return;

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


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
	// intermission or finale
	if (self.view_ofs == '0 0 0')
		return;
	if (self.deadflag)
		return;

	// check to see if player landed and play landing sound
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			T_Damage (self, world, world, 5);
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			self.deathtype = "falling";
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;
};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	bprint (self.netname);
	bprint (" entered the game\n");

	// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission ();
};


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	bprint (" frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	set_suicide_frame ();
};

/*
===========
ClientObituary

called when a player dies
============
*/
void(entity targ, entity attacker) ClientObituary =
{
	if (targ.classname != "player")
		return;

	if (attacker.classname == "player")
	{
		if (targ == attacker)
		{
			// killed self
			attacker.frags = attacker.frags - 1;
			bprint (targ.netname);
			bprint (" becomes bored with life\n");
			return;
		}
		else if ( (teamplay == 2) && (targ.team > 0) && (targ.team == attacker.team) )
		{
			bprint (attacker.netname);
			bprint (" loses another friend\n");
			attacker.frags = attacker.frags - 1;
			return;
		}
		else
		{
			attacker.frags = attacker.frags + 1;
			bprint (targ.netname);
			bprint (" was killed by ");
			bprint (attacker.netname);
			bprint ("\n");
		}
		return;
	}

	// killed by the world / environment
	targ.frags = targ.frags - 1;
	bprint (targ.netname);

	if (targ.watertype == CONTENT_WATER)
	{
		if (random() < 0.5)
			bprint (" sleeps with the fishes\n");
		else
			bprint (" sucks it down\n");
		return;
	}
	else if (targ.watertype == CONTENT_SLIME)
	{
		if (random() < 0.5)
			bprint (" gulped a load of slime\n");
		else
			bprint (" can't exist on slime alone\n");
		return;
	}
	else if (targ.watertype == CONTENT_LAVA)
	{
		if (targ.health < -15)
		{
			bprint (" burst into flames\n");
			return;
		}
		if (random() < 0.5)
			bprint (" turned into hot slag\n");
		else
			bprint (" visits the Volcano God\n");
		return;
	}

	if (targ.deathtype == "falling")
	{
		targ.deathtype = string_null;
		bprint (" fell to his death\n");
		return;
	}

	bprint (" died\n");
};
