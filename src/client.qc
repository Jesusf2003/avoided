// ==========================================
// GESTIÓN DE CLIENTES Y PREDICCIÓN
// ==========================================

void() PlayerPreThink = {
    CPlayer pl = (CPlayer)self;

    if (pl.view_ofs == '0 0 0') return;

    makevectors(pl.v_angle);

    if (pl.button2) {
        // CAMBIO AQUÍ: Llamada explícita para evitar el NULL FUNCTION
        pl.CPlayer::Jump(); 
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

// ==========================================
// SPAWN DEL JUGADOR
// ==========================================

entity() SelectSpawnPoint = {
    entity spot = find(world, classname, "info_player_start");
    
    if (!spot)
        error("Error: No se encontró info_player_start en el mapa.\n");

    return spot;
};

void() PutClientInServer = {
    entity spot = SelectSpawnPoint();

    // 1. Forzamos que la entidad 'self' use la vtable de CPlayer
    // Esto vincula los métodos virtuales correctamente
    self.classname = "player"; 
    
    CPlayer pl = (CPlayer)self;
    
    // 2. Llamada directa al constructor y luego al spawn
    // Usamos el operador :: si es necesario o simplemente aseguramos la instancia
    pl.CPlayer(); 
    
    // 3. SEGURIDAD: Si pl.Spawn() falla, es porque el puntero es nulo.
    // Llamémoslo de forma que el compilador no pueda fallar:
    pl.CPlayer::Spawn(); 

    // Posicionamiento
    setorigin(pl, spot.origin + '0 0 1');
    pl.angles = spot.angles;
};