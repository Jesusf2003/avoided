//
// monsters
//
.float 		pausetime;

vector	VEC_ORIGIN = '0 0 0';
vector	VEC_HULL_MIN = '-16 -16 -24';
vector	VEC_HULL_MAX = '16 16 32';

.float		jump_flag;		// player jump flag

// Añadir a defs.qc
.float leaning; // 0 = centro, 1 = izquierda, 2 = derecha
.float lean_view_offset; // El desplazamiento actual para suavizado