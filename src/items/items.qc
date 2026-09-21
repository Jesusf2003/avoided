/*
==============================================================================

ITEMS

Generic pickup/respawn scaffolding shared by every item_* entity, so each
item only has to supply its own model, sound and stat values. To add a
new item family, write its own file under src/items/ that calls these,
the same way item_armor.qc does for armor.

==============================================================================
*/

float() CheckValidTouch =
{
	if (other.classname != "player")
		return FALSE;
	if (other.health <= 0)
		return FALSE;
	return TRUE;
};

/*
================
StartItem

Common setup for every item: save the model so it can be restored after
a respawn, mark it FL_ITEM (wider bbox for touching), and drop it to
the floor.
================
*/
void() StartItem =
{
	precache_sound ("items/itembk2.wav");	// respawn sound, played by ItemRespawn

	self.mdl = self.model;
	self.flags = self.flags | FL_ITEM;
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;

	if (!droptofloor())
	{
		dprint ("StartItem: fell out of level: ");
		dprint (self.classname);
		dprint ("\n");
		remove (self);
	}
};

/*
================
ItemRespawn

Brings a picked-up item back so it can be touched again.
================
*/
void() ItemRespawn =
{
	setmodel (self, self.mdl);
	self.solid = SOLID_TRIGGER;
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
	setorigin (self, self.origin);
};

/*
================
ItemTouched

Call this from an item's *_touch once the pickup effect has been applied
to "other": fires the item's targets, then either schedules a respawn
(deathmatch) or removes the item for good (singleplayer/coop).
================
*/
void() ItemTouched =
{
	activator = other;
	SUB_UseTargets ();

	self.solid = SOLID_NOT;
	self.model = string_null;

	if (deathmatch)
	{
		self.think = ItemRespawn;
		if (self.wait > 0)
			self.nextthink = self.ltime + self.wait;
		else
			self.nextthink = self.ltime + 20;
	}
	else
	{
		self.think = SUB_Remove;
		self.nextthink = self.ltime + 0.1;
	}
};
