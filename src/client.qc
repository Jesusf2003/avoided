void() PlayerPreThink = {
    CPlayer pl = (CPlayer)self;

    if (pl.view_ofs == '0 0 0') return;

    makevectors(pl.v_angle);

    // LÓGICA DE CAMINAR / CORRER
    // button3 suele estar mapeado a la tecla Shift en muchos setups
    if (pl.button3) {
        pl.maxspeed = pl.m_fRunSpeed;
    } else {
        pl.maxspeed = pl.m_fWalkSpeed;
    }

    // Lógica de Salto
    if (pl.button2) {
        CPlayer::Jump(); 
    } else {
        pl.flags |= FL_JUMPRELEASED;
    }

    if (time < pl.pausetime)
        pl.velocity = '0 0 0';
};

void() PlayerPostThink = {
    CPlayer pl = (CPlayer)self;
    if (pl.view_ofs == '0 0 0') return;

    if (!(pl.flags & FL_ONGROUND))
        pl.jump_flag = pl.velocity_z;
};

entity() SelectSpawnPoint = {
    entity spot = find(world, classname, "info_player_start");
    if (!spot) error("No se encontró info_player_start.\n");
    return spot;
};

void() PutClientInServer = {
    entity spot = SelectSpawnPoint();

    // El motor nos da 'self' como una entidad cruda, la inicializamos
    CPlayer pl = (CPlayer)self;
    pl.CPlayer(); 
    pl.CPlayer::Spawn();

    setorigin(pl, spot.origin + '0 0 1');
    pl.angles = spot.angles;
    pl.fixangle = TRUE;
};