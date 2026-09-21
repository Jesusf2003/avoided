/*
==============================================================================

FUNCS

Generic scaffolding shared by every func_* brush entity, so each one only
has to add its own behavior (touch/use/think) on top of it. To add a new
mover, write its own file under src/funcs/ that calls StartBrush the same
way func_detail.qc does.

==============================================================================
*/

/*
================
StartBrush

Common setup for every brush entity: solid, non-moving by default, using
its own compiled brush model instead of a studio model.
================
*/
void() StartBrush =
{
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);
};
