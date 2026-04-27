#include "player.qh"

void PlayerPreThink() {
    if (self.view_ofs == '0 0 0') return;

    makevectors(self.v_angle);

    // local float speed_frac;

    // if (self.button3) {
    //     self.p_is_running = TRUE;
    //     speed_frac = 1.0;
    // } else {
    //     self.p_is_running = FALSE;
    //     speed_frac = walkspeed / runspeed;
    // }

    // Escalamos el vector de movimiento directamente
    // self.movement_x *= speed_frac;
    // self.movement_y *= speed_frac;

    self.maxspeed = runspeed;  // siempre en runspeed, el scale lo maneja movement

    if (self.button2) {
        PlayerJump(self);
    } else {
        self.flags |= FL_JUMPRELEASED;
    }

    if (time < self.pausetime) self.velocity = '0 0 0';
}

void PlayerPostThink() {
    if (self.view_ofs == '0 0 0') return;

    if (!(self.flags & FL_ONGROUND)) {
        self.jump_flag = self.velocity_z;
    }

    self.p_last_pos = self.origin;

    // Clampear velocidad horizontal aquí, después de que el engine aplicó física
    local vector hvel;
    local float  hspeed;

    hvel   = self.velocity;
    hvel_z = 0;
    hspeed = vlen(hvel);

    if (hspeed > self.maxspeed) {
        self.velocity_x = (hvel_x / hspeed) * self.maxspeed;
        self.velocity_y = (hvel_y / hspeed) * self.maxspeed;
    }
}

void PlayerJump(entity ent) {
    if (!(self.flags & FL_ONGROUND))     return;
    if (!(self.flags & FL_JUMPRELEASED)) return;

    self.flags  -= (self.flags & FL_JUMPRELEASED);
    self.flags  -= FL_ONGROUND;
    self.button2 = 0;
    self.velocity_z += jumpvelocity;
}

void PlayerSpawn(entity spot) {
    self.classname = "player";
    self.solid     = SOLID_SLIDEBOX;
    self.movetype  = MOVETYPE_WALK;
    self.flags     = FL_CLIENT;
    self.health    = 100;
    self.maxspeed  = walkspeed;

    precache_model("models/testplayer.iqm");
    setmodel(self, "models/testplayer.iqm");
    setsize(self, '-16 -16 -24', '16 16 32');
    self.view_ofs = '0 0 22';
}