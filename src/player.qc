class CPlayer : CBaseEntity {
    float m_fJumpVelocity;

    // Constructor de la clase
    void() CPlayer = {
        this.m_strClassName = "player";
        this.m_fJumpVelocity = 270;
    };

    // Lógica de salto encapsulada
    virtual void() Jump = {
        if (!(this.flags & FL_ONGROUND)) return;
        if (!(this.flags & FL_JUMPRELEASED)) return;

        this.flags -= (this.flags & FL_JUMPRELEASED);
        this.flags -= FL_ONGROUND;
        this.button2 = 0;
        this.velocity_z += this.m_fJumpVelocity;
    };

    // Configuración inicial del jugador
    virtual void() Spawn = {
        this.classname = "player";
        this.solid     = SOLID_SLIDEBOX;
        this.movetype  = MOVETYPE_WALK;
        this.flags     = FL_CLIENT;
        this.health    = 100;
        this.fixangle  = TRUE;
        
        setmodel(this, "models/testplayer.iqm");
        setsize(this, '-16 -16 -24', '16 16 32');
        this.view_ofs = '0 0 22';
    };
};
