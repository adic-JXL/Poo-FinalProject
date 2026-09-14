const fs = require('fs');

const graph = JSON.parse(fs.readFileSync('.understand-anything/intermediate/assembled-graph.json', 'utf8'));
const layers = JSON.parse(fs.readFileSync('.understand-anything/intermediate/layers.json', 'utf8'));
const nodeIds = new Set(graph.nodes.map((n) => n.id));

function keep(ids) {
  return ids.filter((id) => nodeIds.has(id));
}

const tour = [
  {
    order: 1,
    title: 'Vision general del proyecto',
    description: 'Empieza por la documentacion principal para entender la idea del juego, la arquitectura orientada a objetos y las decisiones del equipo.',
    nodeIds: keep([
      'document:docs/EXPLICACION_COMPLETA_PROYECTO.md',
      'document:docs/UML_PROYECTO.md',
      'document:docs/PREGUNTAS_Y_RESPUESTAS_DEFENSA.md'
    ])
  },
  {
    order: 2,
    title: 'Punto de entrada y configuracion base',
    description: 'Revisa la configuracion global de Godot y la escena de menu, porque desde ahi arranca la navegacion del juego y la seleccion de partida.',
    nodeIds: keep([
      'config:project.godot',
      'file:Escenas/Menu.tscn',
      'file:Scripts/menu.gd'
    ])
  },
  {
    order: 3,
    title: 'Mundo 1 y controlador principal',
    description: 'Este paso muestra como se arma el primer mundo y como el controlador principal coordina checkpoints, puertas, puzzles, jefe, HUD y progresion.',
    nodeIds: keep([
      'file:Escenas/MainGame.tscn',
      'file:Scripts/main_game.gd',
      'file:Scripts/cutscene_base.gd'
    ])
  },
  {
    order: 4,
    title: 'Jugador, estados y habilidad de gafas',
    description: 'Aqui se concentra la entidad principal: movimiento, estados, animaciones, stamina, cambios de skin y la mecanica especial de las gafas.',
    nodeIds: keep([
      'file:Escenas/Personaje.tscn',
      'file:Scripts/jugador.gd',
      'file:Scripts/habilidad_gafas.gd',
      'file:Scripts/estado_jugador_normal.gd',
      'file:Scripts/estado_jugador_sprint.gd'
    ])
  },
  {
    order: 5,
    title: 'Interfaz, pausa y retroalimentacion',
    description: 'El HUD y los menus muestran la lectura del estado del jugador y conectan con opciones, pausa, accesibilidad y mensajes contextuales.',
    nodeIds: keep([
      'file:Escenas/HUD.tscn',
      'file:Scripts/hud.gd',
      'file:Escenas/MenuPausa.tscn',
      'file:Scripts/menu_pausa.gd',
      'file:Scripts/menuOpciones.gd'
    ])
  },
  {
    order: 6,
    title: 'Enemigos, jefes y mundo 2',
    description: 'Despues conviene revisar la logica de enemigos y los dos jefes, incluyendo la persecucion del segundo mundo.',
    nodeIds: keep([
      'file:Scripts/enemigo_base.gd',
      'file:Scripts/enemigo_perseguidor.gd',
      'file:Scripts/jefe_sombras.gd',
      'file:Scripts/muro_carne.gd',
      'file:Scripts/mundo_2.gd',
      'file:Escenas/Mundo2.tscn'
    ])
  },
  {
    order: 7,
    title: 'Puzzles, puertas y progresion',
    description: 'Esta parte une la progresion del nivel: puzzles, llaves, puertas, totems, checkpoints y objetos interactivos que abren la ruta del jugador.',
    nodeIds: keep([
      'file:Scripts/puzzle_base.gd',
      'file:Scripts/puzzle_gafas.gd',
      'file:Scripts/puzzle_matematicas.gd',
      'file:Scripts/puzzle_secuencia.gd',
      'file:Scripts/puerta_teletransporte.gd',
      'file:Scripts/llave_interactiva.gd',
      'file:Scripts/checkpoint_activador.gd'
    ])
  },
  {
    order: 8,
    title: 'Persistencia, datos y presentacion final',
    description: 'Cierra revisando el sistema de guardado, el TDA propio y la landing web que resume el proyecto fuera del juego.',
    nodeIds: keep([
      'file:Scripts/sistema_guardado.gd',
      'file:Scripts/tda_lista_simple.gd',
      'file:landing/index.html',
      'file:landing/styles.css',
      'file:landing/script.js'
    ])
  }
];

fs.writeFileSync('.understand-anything/intermediate/tour.json', JSON.stringify(tour, null, 2));
console.log(JSON.stringify({ steps: tour.length }, null, 2));
