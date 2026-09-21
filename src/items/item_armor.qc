/*
==============================================================================

ARMOR

armorvalue = hit points the armor absorbs before it breaks
armortype  = fraction of incoming damage it soaks up (see world/combat.qc)

==============================================================================
*/

#include "items.qh"

/*
================
armor_set_type

Keeps .items in sync with .armortype so the HUD shows the right icon.
================
*/
void(entity e) armor_set_type =
{
	e.items = e.items - (e.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));

	if (e.armortype >= 0.8)
		e.items = e.items | IT_ARMOR3;
	else if (e.armortype >= 0.6)
		e.items = e.items | IT_ARMOR2;
	else if (e.armortype > 0)
		e.items = e.items | IT_ARMOR1;
};

void() armor_touch =
{
	if (!CheckValidTouch())
		return;

	// only pick up if it's actually an upgrade over what's carried
	if (other.armortype * other.armorvalue >= self.armortype * self.armorvalue)
		return;

	other.armortype = self.armortype;
	other.armorvalue = self.armorvalue;
	armor_set_type (other);

	sprint (other, "You got armor\n");
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	ItemTouched ();
};

/*
================
StartArmor

Reusable process for adding a new armor pickup: give it a skin, an
absorb fraction and a point value, and it takes care of the model,
sound and generic item scaffolding (StartItem). To add another armor
tier, add one more QUAKED wrapper below that calls this with different
numbers - no other code needs to change.
================
*/
void(float skn, float atype, float amount) StartArmor =
{
	self.skin = skn;
	self.armortype = atype;
	self.armorvalue = amount;
	self.touch = armor_touch;
	self.noise = "items/armor1.wav";

	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	precache_sound (self.noise);

	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
Green armor. Absorbs 30% of incoming damage, up to 100 points.
*/
void() item_armor1 =
{
	StartArmor (0, 0.3, 200);
};
