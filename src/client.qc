#include "player.qh"

entity SelectSpawnPoint () {
    local entity spot;
    
    spot = find (world, classname, "info_player_start");
	
    if (!spot) error ("PutClientInServer: there is no info_player_start on level");
	
    return spot;
}

void PutClientInServer () {
    local entity spot = SelectSpawnPoint();
    PlayerSpawn(spot);

    setorigin(self, spot.origin);
    self.angles = spot.angles;
    self.fixangle = TRUE;
}

void SetChangeParms() {}

//
// map entities
//
void info_player_start() {}