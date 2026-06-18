#include "player.qh"

void PlayerPreThink() {
    if (self.view_ofs == '0 0 0') return;
    makevectors(self.v_angle);

    local vector move_input;
    move_input_x = self.movement_x;
    move_input_y = self.movement_y;
    move_input_z = 0;

    if (vlen(move_input) > 210) {
        self.p_is_running = TRUE;
        self.maxspeed = runspeed;
    } else {
        self.p_is_running = FALSE;
        self.maxspeed = walkspeed;
    }

    if (self.button2) {
        PlayerJump(self);
    } else {
        self.flags = self.flags | FL_JUMPRELEASED;
    }

    if (time < self.pausetime) self.velocity = '0 0 0';
}

void PlayerPostThink() {
    if (self.view_ofs == '0 0 0') return;

    if (!(self.flags & FL_ONGROUND)) {
        self.jump_flag = self.velocity_z;
    }

    self.p_last_pos = self.origin;

    vector hvel = self.velocity;
    hvel_z = 0; // Descartamos el eje vertical
    
    float hspeed = vlen(hvel);
    if (hspeed > self.maxspeed) {
        vector hdir = normalize(hvel);
        self.velocity_x = hdir_x * self.maxspeed;
        self.velocity_y = hdir_y * self.maxspeed;
    }
}

void PlayerJump(entity ent) {
    if (!(ent.flags & FL_ONGROUND))     return;
    if (!(ent.flags & FL_JUMPRELEASED)) return;

    ent.flags &= ~FL_JUMPRELEASED;
    ent.flags &= ~FL_ONGROUND;
    
    ent.button2 = 0;
    ent.velocity_z += jumpvelocity;
}

void PlayerSpawn(entity spot) {
    self.classname = "player";
    self.solid     = SOLID_SLIDEBOX;
    self.movetype  = MOVETYPE_WALK;
    self.flags     = FL_CLIENT;
    self.health    = 100;
    self.maxspeed  = walkspeed;

    precache_model("models/player.mdl");
    setmodel(self, "models/player.mdl");
    setsize(self, '-16 -16 -24', '16 16 32');
    
    self.view_ofs = '0 0 22';
}