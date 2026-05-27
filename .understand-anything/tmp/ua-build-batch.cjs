const fs = require('fs');
const path = require('path');

const root = process.cwd();
const idx = Number(process.argv[2]);
if (!idx) {
  console.error('Usage: node ua-build-batch.cjs <batchIndex>');
  process.exit(1);
}

const scan = JSON.parse(fs.readFileSync('.understand-anything/intermediate/scan-result.json', 'utf8'));
const batches = JSON.parse(fs.readFileSync('.understand-anything/intermediate/batches.json', 'utf8')).batches;
const batch = batches.find(b => b.batchIndex === idx);
if (!batch) {
  console.error(`Batch ${idx} not found`);
  process.exit(1);
}
const extract = JSON.parse(fs.readFileSync(path.join('.understand-anything', 'tmp', `ua-file-extract-results-${idx}.json`), 'utf8'));
const fileMeta = new Map(scan.files.map(f => [f.path.replace(/\\/g, '/'), f]));
const fileSet = new Set([...fileMeta.keys()]);

function rel(p) { return p.replace(/\\/g, '/'); }
function ext(file) { return path.extname(file).toLowerCase(); }
function base(file) { return path.basename(file); }
function stem(file) { return path.basename(file, path.extname(file)); }
function read(file) { try { return fs.readFileSync(path.join(root, file), 'utf8'); } catch { return ''; } }
function complexity(nonEmpty) { return nonEmpty > 200 ? 'complex' : nonEmpty >= 50 ? 'moderate' : 'simple'; }
function sanitizeTags(tags) {
  return [...new Set(tags.map(t => String(t).toLowerCase().replace(/[^a-z0-9áéíóúñü-]+/gi, '-').replace(/-+/g, '-').replace(/^-|-$/g, '')).filter(Boolean))].slice(0, 5);
}
function inferNodeType(file) {
  const e = ext(file);
  if (file.endsWith('.md') || file.endsWith('.tex')) return 'document';
  if (file === 'project.godot' || file.endsWith('.tres') || file.endsWith('.understandignore') || file === '.gitattributes') return 'config';
  return 'file';
}
function summaryFor(file, nonEmpty) {
  const map = {
    'Scripts/main_game.gd': 'Controlador principal del mundo 1; coordina progreso, puertas, puzzles, enemigos, cinemáticas, checkpoints y HUD.',
    'Scripts/mundo_2.gd': 'Controlador del segundo mundo; organiza la persecución, los checkpoints, la cámara y el cierre del juego.',
    'Scripts/jugador.gd': 'Entidad principal jugable; maneja movimiento, salto, daño, animaciones, estados y cambio de skin.',
    'Scripts/hud.gd': 'Gestiona la interfaz del juego: vida, stamina, gafas, mensajes guía y estados visibles del jugador.',
    'Scripts/sistema_guardado.gd': 'Administra slots de guardado, persistencia de progreso y restauración del estado del juego.',
    'Scripts/habilidad_gafas.gd': 'Implementa la habilidad de gafas, sus efectos sobre el mundo y su ciclo de activación y enfriamiento.',
    'Scripts/jefe_sombras.gd': 'Implementa la lógica del primer jefe y el combate basado en pilares y fases.',
    'Scripts/muro_carne.gd': 'Controla al jefe perseguidor del segundo mundo y la lógica central de la persecución.',
    'Scripts/tda_lista_simple.gd': 'Implementa una lista simplemente enlazada usada como TDA propio dentro del proyecto.',
    'project.godot': 'Archivo principal de configuración de Godot; define arranque, autoloads y ajustes globales del proyecto.'
  };
  if (map[file]) return map[file];
  if (file.startsWith('Escenas/') && file.endsWith('.tscn')) return `Escena de Godot que define ${stem(file)} y la composición de nodos usada en el juego.`;
  if (file.startsWith('Scripts/') && file.endsWith('.gd')) return `Script GDScript asociado a ${stem(file)}; encapsula lógica de juego, comportamiento o soporte del sistema.`;
  if (file.startsWith('Shaders/')) return 'Shader usado para efectos visuales o de accesibilidad dentro de la presentación del juego.';
  if (file.startsWith('docs/')) return `Documento del proyecto que desarrolla ${stem(file)} para soporte técnico, defensa o entrega.`;
  if (file.startsWith('landing/')) return 'Archivo de la landing page del proyecto usado para presentar el juego y su arquitectura.';
  return `Archivo ${base(file)} integrado en la estructura del proyecto con ${nonEmpty} líneas no vacías.`;
}
function tagsFor(file) {
  const tags = [];
  if (file.startsWith('Scripts/')) tags.push('gdscript', 'gameplay');
  if (file.startsWith('Escenas/')) tags.push('escena', 'godot');
  if (file.startsWith('docs/')) tags.push('documentacion');
  if (file.startsWith('Shaders/')) tags.push('shader', 'visual');
  if (file.startsWith('landing/')) tags.push('web', 'presentacion');
  if (/menu/i.test(file)) tags.push('menu', 'ui');
  if (/hud/i.test(file)) tags.push('hud', 'ui');
  if (/jugador|personaje/i.test(file)) tags.push('jugador', 'movimiento');
  if (/enemigo|jefe|muro/i.test(file)) tags.push('enemigo', 'ia');
  if (/puzzle/i.test(file)) tags.push('puzzle', 'interaccion');
  if (/gafas/i.test(file)) tags.push('gafas', 'habilidad');
  if (/guardado/i.test(file)) tags.push('persistencia', 'sistema');
  if (/mundo|main_game/i.test(file)) tags.push('mundo', 'controlador');
  if (/dialogo|npc/i.test(file)) tags.push('dialogo', 'npc');
  if (/lista_simple|tda/i.test(file)) tags.push('tda', 'estructura-de-datos');
  return sanitizeTags(tags.length ? tags : ['archivo']);
}
function parseGDFunctions(content) {
  const lines = content.split(/\r?\n/);
  const out = [];
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/^\s*func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)/);
    if (!m) continue;
    let end = lines.length - 1;
    for (let j = i + 1; j < lines.length; j++) {
      if (/^\s*func\s+[A-Za-z_][A-Za-z0-9_]*\s*\(/.test(lines[j])) { end = j - 1; break; }
    }
    out.push({ name: m[1], lineRange: [i + 1, end + 1], size: end - i + 1 });
  }
  return out;
}
function parseJSFunctions(content) {
  const lines = content.split(/\r?\n/);
  const out = [];
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/^\s*function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/);
    if (!m) continue;
    let end = lines.length - 1;
    for (let j = i + 1; j < lines.length; j++) {
      if (/^\s*function\s+[A-Za-z_][A-Za-z0-9_]*\s*\(/.test(lines[j])) { end = j - 1; break; }
    }
    out.push({ name: m[1], lineRange: [i + 1, end + 1], size: end - i + 1 });
  }
  return out;
}
function parseClassName(content) {
  const m = content.match(/^\s*class_name\s+([A-Za-z_][A-Za-z0-9_]*)/m);
  return m ? m[1] : null;
}
function extractResRefs(content) {
  const refs = new Set();
  const regex = /res:\/\/([^"'\\)\]\s]+)/g;
  let m;
  while ((m = regex.exec(content)) !== null) {
    const candidate = rel(m[1]);
    if (fileSet.has(candidate)) refs.add(candidate);
  }
  return [...refs];
}

const nodes = [];
const edges = [];

for (const result of extract.results) {
  const file = rel(result.path);
  const content = read(file);
  const nodeType = inferNodeType(file);
  const fileId = `${nodeType}:${file}`;
  nodes.push({
    id: fileId,
    type: nodeType,
    name: base(file),
    filePath: file,
    lineRange: [1, Math.max(1, result.totalLines || 1)],
    summary: summaryFor(file, result.nonEmptyLines || result.totalLines || 0),
    tags: tagsFor(file),
    complexity: complexity(result.nonEmptyLines || result.totalLines || 0)
  });

  for (const target of extractResRefs(content)) {
    const targetType = inferNodeType(target);
    edges.push({
      source: fileId,
      target: `${targetType}:${target}`,
      type: 'imports',
      direction: 'forward',
      weight: 0.7,
      description: 'Referencia interna mediante ruta res://.'
    });
  }

  const e = ext(file);
  const funcs = e === '.gd' ? parseGDFunctions(content) : (e === '.js' ? parseJSFunctions(content) : []);
  const className = e === '.gd' ? parseClassName(content) : null;
  if (className && (result.nonEmptyLines || 0) >= 20) {
    const classId = `class:${file}:${className}`;
    nodes.push({
      id: classId,
      type: 'class',
      name: className,
      filePath: file,
      lineRange: [1, Math.max(1, result.totalLines || 1)],
      summary: `Clase principal del script ${base(file)}; concentra el comportamiento central definido en este archivo.`,
      tags: sanitizeTags([...tagsFor(file), 'clase']),
      complexity: complexity(result.nonEmptyLines || result.totalLines || 0)
    });
    edges.push({
      source: fileId,
      target: classId,
      type: 'contains',
      direction: 'forward',
      weight: 1,
      description: 'El archivo contiene esta clase principal.'
    });
  }
  for (const fn of funcs) {
    if (!(fn.size >= 10 || ['_ready', '_process', '_physics_process'].includes(fn.name))) continue;
    const funcId = `function:${file}:${fn.name}`;
    nodes.push({
      id: funcId,
      type: 'function',
      name: fn.name,
      filePath: file,
      lineRange: fn.lineRange,
      summary: `Función ${fn.name} definida en ${base(file)}; participa en la lógica específica de este módulo.`,
      tags: sanitizeTags([...tagsFor(file), 'funcion']),
      complexity: fn.size > 40 ? 'complex' : fn.size >= 15 ? 'moderate' : 'simple'
    });
    edges.push({
      source: fileId,
      target: funcId,
      type: 'contains',
      direction: 'forward',
      weight: 1,
      description: 'El archivo contiene esta función.'
    });
  }
}

const seen = new Set();
const dedupEdges = [];
for (const e of edges) {
  const key = `${e.source}|${e.target}|${e.type}`;
  if (seen.has(key)) continue;
  seen.add(key);
  dedupEdges.push(e);
}

const outPath = path.join('.understand-anything', 'intermediate', `batch-${idx}.json`);
fs.writeFileSync(outPath, JSON.stringify({ nodes, edges: dedupEdges }, null, 2));
console.log(JSON.stringify({ batch: idx, nodes: nodes.length, edges: dedupEdges.length, outPath }, null, 2));
