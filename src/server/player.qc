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

void() bubble_bob;

/*
==============================================================================

PLAYER

==============================================================================
*/

$cd id1/models/player_4
$origin 0 -6 24
$base base
$skin skin

//
// running
//
$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

//
// pain
//
$frame pain1 pain2 pain3 pain4 pain5 pain6

//
// death
//
$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

/*
==============================================================================
PLAYER
==============================================================================
*/

void() player_run;

void()	player_stand1 =[	$stand1,	player_stand1	]
{
	self.weaponframe=0;
	if (self.velocity_x || self.velocity_y)
	{
		self.walkframe=0;
		player_run();
		return;
	}

	if (self.walkframe >= 5)
		self.walkframe = 0;
	self.frame = $stand1 + self.walkframe;
	self.walkframe = self.walkframe + 1;
};

void()	player_run =[	$rockrun1,	player_run	]
{
	self.weaponframe=0;
	if (!self.velocity_x && !self.velocity_y)
	{
		self.walkframe=0;
		player_stand1();
		return;
	}

	if (self.walkframe == 6)
		self.walkframe = 0;
	self.frame = self.frame + self.walkframe;
	self.walkframe = self.walkframe + 1;
};

void(float num_bubbles) DeathBubbles;

void() PainSound =
{
	local float rs;

	if (self.health < 0)
		return;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	// water pain sounds
	if (self.watertype == CONTENT_WATER && self.waterlevel == 3)
	{
		DeathBubbles(1);
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
		return;
	}

	// slime pain sounds
	if (self.watertype == CONTENT_SLIME)
	{
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}

	if (self.pain_finished > time)
	{
		self.axhitme = 0;
		return;
	}
	self.pain_finished = time + 0.5;

	// don't make multiple pain sounds right after each other

	rs = rint((random() * 5) + 1);

	self.noise = string_null;
	if (rs == 1)
		self.noise = "player/pain1.wav";
	else if (rs == 2)
		self.noise = "player/pain2.wav";
	else if (rs == 3)
		self.noise = "player/pain3.wav";
	else if (rs == 4)
		self.noise = "player/pain4.wav";
	else if (rs == 5)
		self.noise = "player/pain5.wav";
	else
		self.noise = "player/pain6.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	return;
};

void()	player_pain1 =	[	$pain1,	player_pain2	] {PainSound();self.weaponframe=0;};
void()	player_pain2 =	[	$pain2,	player_pain3	] {};
void()	player_pain3 =	[	$pain3,	player_pain4	] {};
void()	player_pain4 =	[	$pain4,	player_pain5	] {};
void()	player_pain5 =	[	$pain5,	player_pain6	] {};
void()	player_pain6 =	[	$pain6,	player_run	] {};

void(entity attacker, float damage) player_pain =
{
	if (self.weaponframe)
		return;

	if (self.invisible_finished > time)
		// eyes don't have pain frames
		return;

	player_pain1 ();
};

void() player_diea1;
void() player_dieb1;
void() player_diec1;
void() player_died1;
void() player_diee1;

void() DeathBubblesSpawn =
{
	local entity bubble;

	if (self.owner.waterlevel != 3)
		return;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.owner.origin + '0 0 24');
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.bubble_count)
		remove(self);
};

void(float num_bubbles) DeathBubbles =
{
	local entity bubble_spawner;

	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
	return;
};


void() DeathSound =
{
	local float rs;

	// water death sounds
	if (self.waterlevel == 3)
	{
		DeathBubbles(20);
		sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
		return;
	}

	rs = rint ((random() * 4) + 1);
	if (rs == 1)
		self.noise = "player/death1.wav";
	if (rs == 2)
		self.noise = "player/death2.wav";
	if (rs == 3)
		self.noise = "player/death3.wav";
	if (rs == 4)
		self.noise = "player/death4.wav";
	if (rs == 5)
		self.noise = "player/death5.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
	return;
};


void() PlayerDead =
{
	self.nextthink = -1;
	// allow respawn after a certain time
	self.deadflag = DEAD_DEAD;
};

vector(float dm) VelocityForDamage =
{
	local vector v;

	// check if the inflictor had velocity, e.g. like a rocket or explode box
	if (vlen(damage_inflictor.velocity) > 0)
	{
		// impact some of inflictor's velocity on the gibs
		v = 0.5 * damage_inflictor.velocity;
		v = v + (25 * normalize(self.origin - damage_inflictor.origin));
		v_z = 100 + 100 * random();
		v_x = v_x + (50 * crandom());
		v_y = v_y + (50 * crandom());
	}
	else
	{
		// use a random velocity for the gibs
		v_x = 100 * crandom();
		v_y = 100 * crandom();
		v_z = 200 + 100 * random();
	}

	if (dm > -50)
	{
		v = v * 0.7;
	}
	else if (dm > -200)
	{
		v = v * 2;
	}
	else
		v = v * 10;

	return v;
};

void(string gibname, float dm) ThrowGib =
{
	local entity new;

	new = spawn();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');
	new.velocity = VelocityForDamage (dm);
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;
};

void(string gibname, float dm) ThrowHead =
{
	setmodel (self, gibname);
	self.frame = 0;
	self.nextthink = -1;
	self.movetype = MOVETYPE_BOUNCE;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	self.velocity = VelocityForDamage (dm);
	self.origin_z = self.origin_z - 24;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.avelocity = crandom() * '0 600 0';
};


void() GibPlayer =
{
	ThrowHead ("progs/h_player.mdl", self.health);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	ThrowGib ("progs/gib3.mdl", self.health);

	self.deadflag = DEAD_DEAD;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
};

void() PlayerDie =
{
	local float i;

	// don't die as eyes
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	// don't use eyes
	self.modelindex = modelindex_player;

	self.weaponmodel = string_null;
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;
	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	if (self.health < -40)
	{
		GibPlayer ();
		return;
	}

	DeathSound();

	self.angles_x = 0;
	self.angles_z = 0;

	i = cvar("temp1");
	if (!i)
		i = 1 + floor(random()*6);

	if (i == 1)
		player_diea1();
	else if (i == 2)
		player_dieb1();
	else if (i == 3)
		player_diec1();
	else if (i == 4)
		player_died1();
	else
		player_diee1();

};

void() set_suicide_frame =
{
	// used by kill command and disconnect command
	if (self.model != "progs/player.mdl")
		// already gibbed
		return;
	self.frame = $deatha11;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
};


void()	player_diea1	=	[	$deatha1,	player_diea2	] {};
void()	player_diea2	=	[	$deatha2,	player_diea3	] {};
void()	player_diea3	=	[	$deatha3,	player_diea4	] {};
void()	player_diea4	=	[	$deatha4,	player_diea5	] {};
void()	player_diea5	=	[	$deatha5,	player_diea6	] {};
void()	player_diea6	=	[	$deatha6,	player_diea7	] {};
void()	player_diea7	=	[	$deatha7,	player_diea8	] {};
void()	player_diea8	=	[	$deatha8,	player_diea9	] {};
void()	player_diea9	=	[	$deatha9,	player_diea10	] {};
void()	player_diea10	=	[	$deatha10,	player_diea11	] {};
void()	player_diea11	=	[	$deatha11,	player_diea11 ] {PlayerDead();};

void()	player_dieb1	=	[	$deathb1,	player_dieb2	] {};
void()	player_dieb2	=	[	$deathb2,	player_dieb3	] {};
void()	player_dieb3	=	[	$deathb3,	player_dieb4	] {};
void()	player_dieb4	=	[	$deathb4,	player_dieb5	] {};
void()	player_dieb5	=	[	$deathb5,	player_dieb6	] {};
void()	player_dieb6	=	[	$deathb6,	player_dieb7	] {};
void()	player_dieb7	=	[	$deathb7,	player_dieb8	] {};
void()	player_dieb8	=	[	$deathb8,	player_dieb9	] {};
void()	player_dieb9	=	[	$deathb9,	player_dieb9	] {PlayerDead();};

void()	player_diec1	=	[	$deathc1,	player_diec2	] {};
void()	player_diec2	=	[	$deathc2,	player_diec3	] {};
void()	player_diec3	=	[	$deathc3,	player_diec4	] {};
void()	player_diec4	=	[	$deathc4,	player_diec5	] {};
void()	player_diec5	=	[	$deathc5,	player_diec6	] {};
void()	player_diec6	=	[	$deathc6,	player_diec7	] {};
void()	player_diec7	=	[	$deathc7,	player_diec8	] {};
void()	player_diec8	=	[	$deathc8,	player_diec9	] {};
void()	player_diec9	=	[	$deathc9,	player_diec10	] {};
void()	player_diec10	=	[	$deathc10,	player_diec11	] {};
void()	player_diec11	=	[	$deathc11,	player_diec12	] {};
void()	player_diec12	=	[	$deathc12,	player_diec13	] {};
void()	player_diec13	=	[	$deathc13,	player_diec14	] {};
void()	player_diec14	=	[	$deathc14,	player_diec15	] {};
void()	player_diec15	=	[	$deathc15,	player_diec15 ] {PlayerDead();};

void()	player_died1	=	[	$deathd1,	player_died2	] {};
void()	player_died2	=	[	$deathd2,	player_died3	] {};
void()	player_died3	=	[	$deathd3,	player_died4	] {};
void()	player_died4	=	[	$deathd4,	player_died5	] {};
void()	player_died5	=	[	$deathd5,	player_died6	] {};
void()	player_died6	=	[	$deathd6,	player_died7	] {};
void()	player_died7	=	[	$deathd7,	player_died8	] {};
void()	player_died8	=	[	$deathd8,	player_died9	] {};
void()	player_died9	=	[	$deathd9,	player_died9	] {PlayerDead();};

void()	player_diee1	=	[	$deathe1,	player_diee2	] {};
void()	player_diee2	=	[	$deathe2,	player_diee3	] {};
void()	player_diee3	=	[	$deathe3,	player_diee4	] {};
void()	player_diee4	=	[	$deathe4,	player_diee5	] {};
void()	player_diee5	=	[	$deathe5,	player_diee6	] {};
void()	player_diee6	=	[	$deathe6,	player_diee7	] {};
void()	player_diee7	=	[	$deathe7,	player_diee8	] {};
void()	player_diee8	=	[	$deathe8,	player_diee9	] {};
void()	player_diee9	=	[	$deathe9,	player_diee9	] {PlayerDead();};
