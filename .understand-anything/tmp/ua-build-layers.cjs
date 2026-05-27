const fs = require('fs');

const graph = JSON.parse(fs.readFileSync('.understand-anything/intermediate/assembled-graph.json', 'utf8'));
const fileTypes = new Set(['file', 'config', 'document', 'service', 'pipeline', 'table', 'schema', 'resource', 'endpoint']);
const fileNodes = graph.nodes.filter((n) => fileTypes.has(n.type));

const layers = [
  { id: 'layer:documentacion', name: 'Documentacion', description: 'Material de apoyo, UML, informe y guias de defensa del proyecto.', nodeIds: [] },
  { id: 'layer:configuracion', name: 'Configuracion', description: 'Archivos globales de configuracion del proyecto, recursos base y reglas del analisis.', nodeIds: [] },
  { id: 'layer:presentacion-web', name: 'Presentacion Web', description: 'Landing page y recursos web usados para presentar el proyecto fuera del juego.', nodeIds: [] },
  { id: 'layer:escenas-ui', name: 'Escenas UI', description: 'Escenas de interfaz, menus, dialogos y prefabs visuales de apoyo.', nodeIds: [] },
  { id: 'layer:escenas-gameplay', name: 'Escenas Gameplay', description: 'Escenas principales de mundo, jugador, puertas, plataformas, puzzles y contenido jugable.', nodeIds: [] },
  { id: 'layer:control-global', name: 'Control Global', description: 'Controladores de mundo, HUD, menus, guardado, audio, fondos y sistemas transversales.', nodeIds: [] },
  { id: 'layer:jugador-estados', name: 'Jugador y Estados', description: 'Scripts centrados en el personaje jugable, sus estados, movimiento y habilidades.', nodeIds: [] },
  { id: 'layer:enemigos-jefes', name: 'Enemigos y Jefes', description: 'Scripts de IA, enemigos comunes y jefes de ambos mundos.', nodeIds: [] },
  { id: 'layer:interactivos-puzzles', name: 'Interactivos y Puzzles', description: 'Objetos interactivos, checkpoints, llaves, puertas, totems y logica de puzzles.', nodeIds: [] },
  { id: 'layer:render-visual', name: 'Render y Visual', description: 'Shaders y scripts visuales o de ambientacion aplicados a la presentacion del juego.', nodeIds: [] }
];

const byId = new Map(layers.map((l) => [l.id, l]));

function assign(node, layerId) {
  byId.get(layerId).nodeIds.push(node.id);
}

for (const node of fileNodes) {
  const fp = node.filePath || '';
  if (fp.startsWith('docs/')) {
    assign(node, 'layer:documentacion');
    continue;
  }
  if (fp === '.gitattributes' || fp === 'project.godot' || fp.endsWith('.understandignore') || fp.endsWith('tile_set.tres')) {
    assign(node, 'layer:configuracion');
    continue;
  }
  if (fp.startsWith('landing/')) {
    assign(node, 'layer:presentacion-web');
    continue;
  }
  if (fp.startsWith('Shaders/')) {
    assign(node, 'layer:render-visual');
    continue;
  }
  if (fp.startsWith('Escenas/')) {
    if (/Menu|HUD|Dialogo|NPC|Manual|opciones/i.test(fp)) {
      assign(node, 'layer:escenas-ui');
    } else {
      assign(node, 'layer:escenas-gameplay');
    }
    continue;
  }
  if (fp.startsWith('Scripts/')) {
    if (/main_game|mundo_2|hud|menu|menuOpciones|musica_global|sistema_guardado|sistema_estamina|cutscene_base|mensaje_automatico|ambiente_|fondo_/i.test(fp)) {
      assign(node, 'layer:control-global');
      continue;
    }
    if (/jugador|estado_jugador_|correr|salto|perso|habilidad_gafas/i.test(fp)) {
      assign(node, 'layer:jugador-estados');
      continue;
    }
    if (/enemigo_|jefe_sombras|muro_carne/i.test(fp)) {
      assign(node, 'layer:enemigos-jefes');
      continue;
    }
    if (/puzzle|puerta|llave|altar_gafas|checkpoint|totem_jefe|interactivo_base|npc_dialogo|plataforma_gafas|sombras_plataformas|farol_decorativo/i.test(fp)) {
      assign(node, 'layer:interactivos-puzzles');
      continue;
    }
    if (/sprite_animado_frames/i.test(fp)) {
      assign(node, 'layer:render-visual');
      continue;
    }
    assign(node, 'layer:control-global');
    continue;
  }
  assign(node, 'layer:configuracion');
}

fs.writeFileSync('.understand-anything/intermediate/layers.json', JSON.stringify(layers, null, 2));
console.log(JSON.stringify({
  totalLayers: layers.length,
  assigned: layers.reduce((sum, layer) => sum + layer.nodeIds.length, 0),
  fileNodes: fileNodes.length
}, null, 2));
