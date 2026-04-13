class CBaseEntity : entity {
    string m_strClassName;
    float  m_fHealth;
    
    virtual void() m_pSpawn = {};
    virtual void() m_pDie   = {};

    virtual void(string name) Init = {
        this.classname = name;
        this.m_strClassName = name;
    };
};

class CPointPlayerStart : CBaseEntity {
    void() CPointPlayerStart = {
        this.classname = "info_player_start";
    };

    virtual void() m_pSpawn = {
        this.solid    = SOLID_NOT;
        this.movetype = MOVETYPE_NONE;
        setsize(this, '-16 -16 -24', '16 16 32');
    };
};

void() info_player_start = {
    CPointPlayerStart ent = spawn(CPointPlayerStart);
    ent.CPointPlayerStart(); 
    ent.m_pSpawn();
};