.float m_fWalkSpeed;
.float m_fRunSpeed;

class CPlayer : CBaseEntity {
    float m_fJumpVelocity;
    float max_speed;

    // El constructor debe ser simple
    void() CPlayer = {
        this.m_strClassName = "player";
        this.m_fJumpVelocity = 270;
        this.m_fWalkSpeed = 100;
        this.m_fRunSpeed = 400;
    };

    // Definición del método
    virtual void() Jump = {
        if (!(this.flags & FL_ONGROUND)) return;
        if (!(this.flags & FL_JUMPRELEASED)) return;

        this.flags -= (this.flags & FL_JUMPRELEASED);
        this.flags -= FL_ONGROUND;
        this.button2 = 0;
        this.velocity_z += this.m_fJumpVelocity;
    };

    virtual void() Spawn = {
        this.classname = "player";
        this.solid     = SOLID_SLIDEBOX;
        this.movetype  = MOVETYPE_WALK;
        this.flags     = FL_CLIENT;
        this.health    = 100;

        this.maxspeed = this.m_fWalkSpeed;
        
        setmodel(this, "models/testplayer.iqm");
        setsize(this, '-16 -16 -24', '16 16 32');
        this.view_ofs = '0 0 22';
    };
};