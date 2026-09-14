# Manual de Ingenieria - Deep Shadow

## 1. Proposito del documento

Este manual esta pensado para programadores y equipo tecnico que necesiten entender como funciona `Deep Shadow`, como esta organizado el proyecto y como mantenerlo sin romper flujos existentes.

No reemplaza la documentacion conceptual del proyecto. Se complementa con:

- `docs/EXPLICACION_COMPLETA_PROYECTO.md`
- `docs/UML_PROYECTO.md`

Este documento se enfoca en:

- arquitectura real del codigo,
- flujo de arranque y transicion entre escenas,
- responsabilidades por subsistema,
- puntos de extension,
- mantenimiento,
- validacion manual y riesgos.

## 2. Stack tecnico y convenciones base

### 2.1 Motor y configuracion general

- Motor: `Godot 4.6`
- Renderer configurado: `GL Compatibility`
- Escena principal de arranque: `Escenas/Menu.tscn`
- Autoloads definidos en `project.godot`:
  - `MenuOpciones`
  - `MusicaGlobal`

### 2.2 Estructura principal del repositorio

- `Escenas/`: escenas `.tscn` del juego
- `Scripts/`: logica GDScript
- `Shaders/`: shaders de distorsion y accesibilidad
- `Imagenes/`: sprites, HUD, fondos y objetos
- `Fuentes/`: tipografia pixel
- `docs/`: documentacion tecnica y academica
- `landing/`: landing page web separada del runtime del juego

### 2.3 Filosofia de arquitectura

El proyecto sigue una arquitectura por escenas y nodos propia de Godot, pero con una separacion de responsabilidades bastante clara:

- un controlador coordina cada mundo,
- el jugador encapsula movimiento, dano y habilidad,
- varios sistemas pequenos resuelven preocupaciones especificas,
- la UI reacciona a senales,
- la persistencia vive fuera de los controladores como servicio.

## 3. Flujo de arranque del juego

## 3.1 Punto de entrada

El arranque esta definido en `project.godot`:

- `run/main_scene="uid://bxcpk2w338lbc"`
- esa UID corresponde a `Escenas/Menu.tscn`

### 3.2 Flujo de inicio

1. El juego abre `Escenas/Menu.tscn`.
2. `Scripts/menu.gd` construye el selector de slots y skin.
3. `Scripts/sistema_guardado.gd` decide si hay partida existente y que escena cargar.
4. Segun el progreso, la partida entra en:
   - `Escenas/MainGame.tscn` para mundo 1
   - `Escenas/Mundo2.tscn` para mundo 2

### 3.3 Servicios globales activos desde el inicio

- `MenuOpciones`: overlay de configuracion y accesibilidad
- `MusicaGlobal`: musica procedural global

Esto significa que cualquier cambio en opciones o audio global puede impactar varias escenas sin tocar su jerarquia local.

## 4. Mapa de arquitectura

La arquitectura tecnica se entiende mejor en 8 bloques:

1. Flujo general y controladores de mundo
2. Jugador y estados
3. Sistemas auxiliares
4. Interactivos
5. Puzzles
6. Enemigos y jefes
7. UI, cinematica y accesibilidad
8. Persistencia

## 5. Controladores de mundo

### 5.1 `Scripts/main_game.gd`

`MainGame` es el orquestador del mundo 1. Su trabajo es coordinar, no concentrar toda la logica del juego.

Responsabilidades principales:

- configurar HUD, camaras, checkpoints, puertas, NPCs, totems y puzzles,
- restaurar progreso guardado,
- controlar acceso al jefe,
- aplicar efectos globales de gafas y distorsion,
- manejar transicion hacia mundo 2.

Dependencias fuertes:

- rutas de nodos con `@onready`
- escenas y scripts de puzzles
- `SistemaGuardado`
- `HUD`
- `Jugador`
- `JefeSombras`

Riesgo de mantenimiento:

- si se renombra un nodo en `Escenas/MainGame.tscn`, es facil romper referencias directas en este script.

### 5.2 `Scripts/mundo_2.gd`

`Mundo2` es el controlador del segundo mundo. Tiene una naturaleza distinta: menos exploracion y mas persecucion.

Responsabilidades principales:

- construir estructura base del nivel,
- configurar jugador, HUD, camaras y muro perseguidor,
- generar ordenes de puzzles,
- administrar checkpoints y respawn,
- manejar la entrada desde mundo 1,
- guardar y restaurar progreso de mundo 2.

Rasgo importante:

- `Mundo2` instancia y arma varias piezas en runtime. Por eso cualquier cambio de flujo debe revisarse tanto en escena como en script.

## 6. Jugador y patron State

### 6.1 `Scripts/jugador.gd`

`Jugador` es una `CharacterBody2D` y concentra:

- movimiento horizontal,
- salto,
- sprint,
- vida e invulnerabilidad,
- dano y retroceso,
- respawn,
- habilidad de gafas,
- animacion manual por frames,
- audio local,
- emision de senales para la UI y el mundo.

La clase encapsula bien su estado. Otras piezas no deberian modificar variables internas directamente si ya existe un metodo publico para hacerlo.

### 6.2 Estados del jugador

Archivos:

- `Scripts/estado_jugador_base.gd`
- `Scripts/estado_jugador_normal.gd`
- `Scripts/estado_jugador_sprint.gd`
- `Scripts/estado_jugador_aturdido.gd`
- `Scripts/estado_jugador_bloqueado.gd`

El jugador usa un patron `State`:

- `normal`
- `sprint`
- `aturdido`
- `bloqueado`

Ventajas de mantenimiento:

- evita `if` gigantes en `jugador.gd`,
- desacopla reglas por estado,
- permite extender comportamiento sin volver fragil el controlador principal.

Regla practica:

- si una nueva mecanica cambia como se mueve el jugador durante un estado concreto, primero revisa si debe entrar como logica del estado y no como condicion extra en `jugador.gd`.

## 7. Sistemas auxiliares

### 7.1 `Scripts/sistema_estamina.gd`

Modelo aislado para consumo y regeneracion de estamina.

Sirve para:

- evitar que la estamina quede mezclada con toda la logica del cuerpo,
- emitir actualizaciones limpias al HUD,
- facilitar ajustes de balance.

### 7.2 `Scripts/habilidad_gafas.gd`

Modelo de la habilidad especial del juego.

Controla:

- activacion,
- duracion,
- cooldown actual,
- incremento progresivo del cooldown,
- senalizacion de estado.

Importante para mantenimiento:

- el modelo solo controla el estado logico,
- los efectos visuales y de gameplay al activar gafas se aplican desde los controladores de mundo y el jugador.

Si se cambia la mecanica de gafas, normalmente hay que tocar tres capas:

1. `Scripts/habilidad_gafas.gd`
2. `Scripts/jugador.gd`
3. `Scripts/main_game.gd` y/o `Scripts/mundo_2.gd`

### 7.3 `Scripts/sistema_guardado.gd`

Servicio estatico de persistencia.

Rutas importantes:

- slots: `user://deep_shadow_save_slot_%d.cfg`
- opciones: `user://deep_shadow_settings.cfg`

Responsabilidades:

- administrar slot activo,
- leer y escribir guardados,
- recordar la escena actual,
- guardar skin seleccionada,
- preparar transiciones entre escenas,
- marcar intro de nueva partida.

Regla critica:

- si agregas progreso nuevo a un mundo, no basta con guardar una variable en el controlador. Tambien debes incluirla en la estructura que se persiste y en la restauracion del estado.

### 7.4 `Scripts/tda_lista_simple.gd`

Implementa un TDA propio de lista enlazada simple.

Uso actual:

- apoyo para creditos y piezas academicas del proyecto.

Aunque no es el centro del runtime, no debe eliminarse si el proyecto sigue necesitando cumplir el requerimiento academico.

## 8. Interactivos

### 8.1 Base comun

`Scripts/interactivo_base.gd` define el contrato para objetos interactivos:

- deteccion del jugador en rango,
- mensaje de interaccion,
- emision de senal cuando corresponde,
- posibilidad de bloquear o desactivar la interaccion.

### 8.2 Derivados importantes

- `Scripts/puerta_teletransporte.gd`
- `Scripts/puerta_bloqueada.gd`
- `Scripts/llave_interactiva.gd`
- `Scripts/altar_gafas.gd`
- `Scripts/npc_dialogo.gd`
- `Scripts/totem_jefe.gd`
- `Scripts/checkpoint_activador.gd`

Regla de extension:

- si se agrega un nuevo objeto activable por el jugador, la primera opcion debe ser heredar de `InteractivoBase`.

Eso conserva coherencia en:

- rango,
- input,
- mensajes,
- desacoplamiento con HUD o controladores.

## 9. Puzzles

### 9.1 Base comun

`Scripts/puzzle_base.gd` centraliza el ciclo de vida:

- iniciar,
- mostrar,
- cerrar,
- cancelar,
- completar,
- aplicar tema visual consistente.

### 9.2 Implementaciones actuales

- `Scripts/puzzle_secuencia.gd`
- `Scripts/puzzle_matematicas.gd`
- `Scripts/puzzle_gafas.gd`

`PuzzleGafas`, por ejemplo, construye un patron aleatorio y separa:

- fase de revelacion,
- fase de entrada,
- validacion,
- retroalimentacion al jugador.

Regla de mantenimiento:

- un puzzle nuevo deberia heredar de `PuzzleBase` para reutilizar la UI base, senales y flujo de apertura/cierre.

## 10. Enemigos y jefes

### 10.1 Jerarquia base

`Scripts/enemigo_base.gd` centraliza:

- vida,
- dano de contacto,
- recarga de ataque,
- congelamiento,
- multiplicador temporal de velocidad,
- audio base y de ataque,
- reinicio del enemigo.

Subtipos:

- `Scripts/enemigo_patrulla.gd`
- `Scripts/enemigo_perseguidor.gd`
- `Scripts/enemigo_flotante_base.gd`
- `Scripts/enemigo_flotante_vertical.gd`
- `Scripts/enemigo_flotante_horizontal.gd`
- `Scripts/jefe_sombras.gd`

### 10.2 `Scripts/jefe_sombras.gd`

Es un jefe con estados internos:

- acecho,
- carga,
- embestida,
- aturdido,
- derrotado.

La derrota no depende de ataque directo del jugador sino de activar totems y sellos del escenario.

Implicacion tecnica:

- si se modifica el flujo del jefe, revisar tambien `MainGame`, `TotemJefe` y mensajes del HUD.

### 10.3 `Scripts/muro_carne.gd`

Es la amenaza principal del mundo 2.

No funciona como enemigo clasico, sino como presion de persecucion. Cualquier ajuste de dificultad del mundo 2 suele requerir revisar:

- velocidad del muro,
- checkpoints,
- camara,
- mensajes,
- ventajas temporales de las gafas.

## 11. UI, cinematica y accesibilidad

### 11.1 HUD

`Scripts/hud.gd` funciona como vista reactiva.

Se conecta a senales del jugador para mostrar:

- vida,
- estamina,
- sprint,
- estado de gafas,
- llave,
- checkpoint,
- mensajes del nivel,
- pensamientos del personaje.

Regla de mantenimiento:

- si el jugador emite una senal nueva relacionada con estado visible, el HUD es el lugar natural para reflejarla.

### 11.2 Menu principal y pausa

- `Scripts/menu.gd`
- `Scripts/menu_pausa.gd`

`menu.gd` administra slots, carga, borrado y seleccion de skin.

`menu_pausa.gd` administra:

- reanudar,
- reiniciar desde checkpoint,
- volver al menu,
- integracion con el estado de pausa del controlador actual.

### 11.3 Opciones y accesibilidad

`Scripts/menuOpciones.gd` es un autoload. Administra:

- volumen,
- modo de pantalla,
- resolucion,
- filtro de daltonismo,
- intensidad de sacudida de camara.

Detalle importante:

- las opciones persisten en `user://deep_shadow_settings.cfg`
- el filtro de accesibilidad usa `Shaders/filtro_accesibilidad.gdshader`

### 11.4 Cinematicas

`Scripts/cutscene_base.gd` construye overlays de cinematica y creditos.

Aspecto delicado:

- manipula `Engine.time_scale` para congelar o casi congelar el juego mientras muestra la cinematica.

Si una cinematica nueva deja el juego "congelado", revisar primero la restauracion de `time_scale`.

## 12. Flujo de senales y desacoplamiento

El proyecto usa bastante bien las senales de Godot como mecanismo de eventos.

Ejemplos importantes:

- jugador -> HUD
- interactivo -> controlador del mundo
- puzzle -> controlador del mundo
- jefe -> controlador del mundo

Buena practica local:

- preferir conectar por senales cuando una pieza debe informar que algo ocurrio,
- evitar que una clase hija empiece a buscar y modificar multiples nodos externos por ruta absoluta si puede emitir un evento.

## 13. Mapa rapido de escenas y scripts clave

Escenas principales:

- `Escenas/Menu.tscn`
- `Escenas/MainGame.tscn`
- `Escenas/Mundo2.tscn`
- `Escenas/HUD.tscn`
- `Escenas/MenuPausa.tscn`
- `Escenas/MenuOpciones.tscn`
- `Escenas/Personaje.tscn`

Scripts clave para empezar a leer el proyecto:

1. `project.godot`
2. `Scripts/menu.gd`
3. `Scripts/sistema_guardado.gd`
4. `Scripts/main_game.gd`
5. `Scripts/jugador.gd`
6. `Scripts/mundo_2.gd`
7. `Scripts/hud.gd`
8. `Scripts/interactivo_base.gd`
9. `Scripts/puzzle_base.gd`
10. `Scripts/enemigo_base.gd`

## 14. Guia de mantenimiento por tipo de cambio

### 14.1 Cambiar controles

Archivo principal:

- `project.godot`

Revisar tambien:

- mensajes de tutorial,
- prompts visuales del HUD,
- cinematicas de controles en `cutscene_base.gd`.

### 14.2 Cambiar balance del jugador

Archivos probables:

- `Scripts/jugador.gd`
- `Scripts/sistema_estamina.gd`
- `Scripts/habilidad_gafas.gd`
- estados del jugador

Validar:

- movimiento normal,
- sprint,
- salto,
- dano,
- respawn,
- uso de gafas,
- lectura correcta del HUD.

### 14.3 Agregar un nuevo interactivo

Recomendado:

1. heredar de `Scripts/interactivo_base.gd`
2. crear o duplicar escena en `Escenas/`
3. conectar la senal desde el controlador del mundo o desde la escena correspondiente

### 14.4 Agregar un puzzle nuevo

Recomendado:

1. heredar de `Scripts/puzzle_base.gd`
2. crear escena propia en `Escenas/`
3. emitir `completado` o `cancelado`
4. integrar en `MainGame` o `Mundo2`
5. si cambia progreso, agregar persistencia

### 14.5 Agregar progreso guardable

Revisar siempre:

- controlador del mundo que posee la variable,
- serializacion del progreso actual,
- restauracion del progreso guardado,
- `Scripts/sistema_guardado.gd` si se cambia estructura general del guardado,
- compatibilidad con slots ya existentes.

### 14.6 Cambiar HUD o mensajes

Archivos probables:

- `Scripts/hud.gd`
- `Scripts/main_game.gd`
- `Scripts/mundo_2.gd`
- scripts de interactivos o puzzles

Regla:

- si el cambio es visual, tocar HUD;
- si el cambio es narrativo o contextual, probablemente nace desde el controlador de mundo.

### 14.7 Cambiar opciones tecnicas o accesibilidad

Archivos probables:

- `Scripts/menuOpciones.gd`
- `Shaders/filtro_accesibilidad.gdshader`
- `project.godot`

Validar:

- persistencia,
- aplicacion en tiempo real,
- compatibilidad con pausa y cambio de escena.

## 15. Validacion manual recomendada

El repositorio no incluye un sistema visible de pruebas automatizadas. Por eso cada cambio relevante debe validarse manualmente.

Checklist minima:

1. Abrir el juego desde `Escenas/Menu.tscn`.
2. Crear nueva partida en un slot vacio.
3. Verificar carga del mundo 1.
4. Probar movimiento, salto, sprint, dano y respawn.
5. Activar gafas y revisar HUD, distorsion y cambios de gameplay.
6. Probar al menos un interactivo y un puzzle.
7. Guardar progreso y recargar partida.
8. Entrar al menu de pausa.
9. Entrar al menu de opciones y verificar persistencia.
10. Si el cambio toca mundo 2, validar transicion y persecucion.

## 16. Riesgos y zonas fragiles

### 16.1 Dependencia alta de nombres de nodos

`MainGame` y parte de `Mundo2` usan multiples rutas explicitas a nodos. Cambiar nombres en la escena puede romper inicializacion sin que el error sea obvio.

### 16.2 Acoplamiento de progreso con controladores

Buena parte del progreso esta representado con flags booleanas dentro de los controladores de mundo. Si se agrega contenido nuevo y no se serializa bien, el guardado puede quedar inconsistente.

### 16.3 Pausa y cinematicas

Hay logica que manipula `Engine.time_scale`. Un cambio incorrecto puede dejar:

- el juego pausado,
- UI fuera de sincronizacion,
- animaciones corriendo cuando no deben.

### 16.4 Validacion principalmente manual

Sin pruebas automatizadas, los cambios pequenos pueden generar regresiones silenciosas en:

- slots,
- HUD,
- flujo de puzzle,
- transiciones entre escenas.

## 17. Recomendaciones para futuras mejoras

1. Extraer parte de la logica de `MainGame` y `Mundo2` en componentes mas pequenos.
2. Centralizar mejor constantes de gameplay para balance.
3. Agregar pruebas manuales guiadas o scripts de smoke test.
4. Reducir dependencia de rutas de nodos muy especificas.
5. Definir un formato de datos de guardado mas versionable.

## 18. Resumen ejecutivo

`Deep Shadow` esta bien encaminado para un proyecto academico con ambicion tecnica: separa responsabilidades, usa herencia, composicion, senales y un patron `State` claro en el jugador.

Las piezas mas importantes para entenderlo y mantenerlo son:

- `menu.gd` para entrada,
- `sistema_guardado.gd` para persistencia,
- `main_game.gd` y `mundo_2.gd` para flujo,
- `jugador.gd` y sus estados para gameplay,
- `hud.gd` para presentacion reactiva,
- `interactivo_base.gd`, `puzzle_base.gd` y `enemigo_base.gd` como familias reutilizables.

Si alguien nuevo entra al proyecto, deberia leer en este orden:

1. `project.godot`
2. `Scripts/menu.gd`
3. `Scripts/sistema_guardado.gd`
4. `Scripts/main_game.gd`
5. `Scripts/jugador.gd`
6. `Scripts/mundo_2.gd`
7. `docs/UML_PROYECTO.md`
