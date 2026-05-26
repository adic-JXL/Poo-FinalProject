# Explicacion completa del proyecto Deep Shadow

Este documento sirve como guia integral para entender que se hizo en el proyecto, por que se hizo asi y como se conecta todo. La idea es que puedan usarlo para estudiar, repartir la exposicion por temas y defender tanto la parte tecnica como la parte de diseno orientado a objetos.

## 1. Vision general del proyecto

`Deep Shadow` es un juego 2D en Godot con enfoque narrativo y de plataformas. La idea central es representar, mediante mecanicas jugables, la percepcion de un personaje que sufre bullying por usar gafas. Por eso el juego no solo se construye como plataformas y enemigos, sino como una traduccion jugable de estados emocionales:

- El mundo base tiene distorsion visual.
- Las gafas no son solo un item: son una habilidad simbolica y mecanica.
- Los puzzles y rutas ocultas representan claridad, interpretacion y cambio de perspectiva.
- Los jefes representan obstaculos mentales y sociales.

En terminos de software, el proyecto mezcla:

- Programacion orientada a objetos.
- Arquitectura por escenas y nodos propia de Godot.
- Sistemas separados por responsabilidad.
- Herencia, polimorfismo, encapsulamiento y composicion.
- Senales de Godot como mecanismo tipo `Observer`.
- Un TDA propio (`ListaSimple`) para cumplir con la exigencia academica de estructuras construidas manualmente.

## 2. Estructura general del proyecto

La organizacion principal del repositorio esta dividida asi:

- [Escenas](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Escenas): contiene las escenas de Godot, es decir, la composicion visual y jerarquica de cada entidad o nivel.
- [Scripts](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts): contiene la logica orientada a objetos.
- [Shaders](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Shaders): filtros visuales como la distorsion y accesibilidad.
- [Imagenes](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Imagenes): sprites, HUD, fondos y objetos.
- [Fuentes](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Fuentes): tipografia pixel usada en UI y cinematics.
- [docs](C:\Users\HP\Documents\GitHub\Poo-FinalProject\docs): documentacion UML, informe y material auxiliar.
- [landing](C:\Users\HP\Documents\GitHub\Poo-FinalProject\landing): pagina web de presentacion del proyecto.

## 3. Como pensar la arquitectura del juego

El proyecto se entiende mejor si lo separamos en 8 bloques:

1. Controladores de mundo.
2. Entidades jugables.
3. Sistemas auxiliares.
4. Enemigos y jefes.
5. Interactivos.
6. Puzzles.
7. Interfaz y narrativa.
8. Persistencia y configuracion.

Cada bloque tiene una responsabilidad concreta. Esto evita que toda la logica quede metida en una sola clase gigante.

## 4. Controladores principales de mundo

### 4.1 `MainGame`

Archivo: [main_game.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\main_game.gd)

Es el controlador del mundo 1. Su rol no es hacer “todo”, sino coordinar. Es decir:

- Crea y conecta jugador, HUD, camaras, puertas, checkpoints, puzzles y jefe.
- Controla el flujo del nivel.
- Decide que se activa segun el progreso.
- Maneja el guardado del mundo 1.
- Aplica efectos globales como pausa, distorsion y pensamientos.

En orientacion a objetos, `MainGame` funciona como un **orquestador**. No contiene toda la logica interna del jugador o de cada puzzle, sino que llama a los objetos correctos.

Responsabilidades visibles en el codigo:

- Preparar todo en `_ready()`.
- Revisar caidas del jugador en `_physics_process()`.
- Coordinar entrada a jefe, puzzles, checkpoints y transiciones.
- Guardar y restaurar progreso.
- Aplicar el efecto de las gafas sobre mundo, camara y enemigos.

### 4.2 `Mundo2`

Archivo: [mundo_2.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\mundo_2.gd)

Es el controlador del segundo mundo. Cumple el mismo rol estructural que `MainGame`, pero para un tipo de nivel distinto: persecucion.

Responsabilidades principales:

- Instanciar y configurar jugador, HUD, menu pausa y jefe perseguidor.
- Manejar la persecucion del muro.
- Controlar checkpoints del mundo 2.
- Generar y resolver los puzzles por orden.
- Sincronizar camara y sensacion de presion.
- Manejar la transicion desde el mundo 1.
- Guardar progreso del mundo 2.

La razon por la que existe como clase aparte y no como una extension improvisada del primer mundo es que cada mundo tiene logicas de flujo muy diferentes. Separarlos mejora:

- legibilidad,
- mantenibilidad,
- posibilidad de escalar a mas mundos.

## 5. Entidad principal: el jugador

Archivo: [jugador.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\jugador.gd)

`Jugador` es una entidad `CharacterBody2D`. Esta clase concentra todo lo que el personaje “es” y “puede hacer”.

### 5.1 Responsabilidades del jugador

- Movimiento horizontal.
- Salto.
- Sprint.
- Vida y dano.
- Invulnerabilidad temporal.
- Retroceso al recibir golpes.
- Respawn funcional.
- Habilidad de gafas.
- Animaciones manuales por frames.
- Audio local: pisadas, gafas y dano.
- Emision de senales para el HUD y el resto del juego.

### 5.2 Encapsulamiento aplicado

El jugador no expone variables internas para que cualquier otra clase las cambie libremente. En vez de eso, se usan metodos como:

- `recibir_danio()`
- `establecer_control_habilitado()`
- `gafas_activas()`
- `obtener_estamina_actual()`
- `restaurar_para_respawn()`

Eso protege el estado interno y hace que otras clases no rompan la logica del jugador.

### 5.3 Composicion dentro del jugador

El jugador contiene dos subsistemas importantes:

- `SistemaEstamina`
- `HabilidadGafas`

Esto es composicion. Es mejor que meter toda la logica en una sola clase, porque separa conceptos:

- una clase maneja resistencia,
- otra maneja habilidad especial,
- otra maneja el cuerpo principal.

## 6. Patron State en el jugador

Archivos:

- [estado_jugador_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\estado_jugador_base.gd)
- [estado_jugador_normal.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\estado_jugador_normal.gd)
- [estado_jugador_sprint.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\estado_jugador_sprint.gd)
- [estado_jugador_aturdido.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\estado_jugador_aturdido.gd)
- [estado_jugador_bloqueado.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\estado_jugador_bloqueado.gd)

Este es uno de los patrones de diseno mas claros del proyecto.

### 6.1 Que problema resuelve

Si toda la logica del jugador estuviera en muchos `if` dentro de `jugador.gd`, el codigo seria mas dificil de mantener:

- si esta en sprint haz esto,
- si esta aturdido haz esto otro,
- si esta bloqueado ignora input,
- si esta normal vuelve al comportamiento base.

En vez de eso, cada estado es una clase.

### 6.2 Como funciona

`Jugador` guarda una referencia al estado actual:

- normal
- sprint
- aturdido
- bloqueado

Y delega el comportamiento con algo como:

- entrar
- procesar
- salir

Entonces el objeto `Jugador` no pregunta “que estado tengo y que hago”, sino que deja que el estado actual responda por el.

### 6.3 Ventaja academica

Esto demuestra:

- polimorfismo,
- delegacion de comportamiento,
- desacoplamiento de reglas,
- uso real de patrones de diseno.

## 7. Sistema de estamina

Archivo: [sistema_estamina.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\sistema_estamina.gd)

Este sistema modela la energia del personaje para el sprint.

### 7.1 Que hace

- Guarda valor actual y maximo.
- Permite consumir estamina.
- Permite regenerarla.
- Notifica cambios.

### 7.2 Por que esta separado

Se pudo haber hecho dentro del jugador, pero al separarlo:

- queda mas reutilizable,
- queda mas testeable,
- se entiende como una entidad logica propia.

Esto es buen diseno OO por separacion de responsabilidades.

## 8. Sistema de gafas

Archivo: [habilidad_gafas.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\habilidad_gafas.gd)

Las gafas son uno de los sistemas mas importantes del juego, tanto jugable como simbolicamente.

### 8.1 Funcionalidad

- Se activan manualmente.
- Duran 10 segundos.
- Tienen cooldown base.
- Cada uso incrementa el cooldown hasta un maximo.
- Al activarse, alteran visibilidad del mundo.
- Dan bonus de movimiento y salto.
- Vuelven infinito el sprint mientras estan activas.
- Reducen velocidad de amenazas del entorno.
- Desactivan o reducen la distorsion visual.

### 8.2 Valor conceptual

Las gafas no son un simple power-up. Son una mecanica narrativa:

- sin gafas, el mundo se siente hostil, borroso y oculto;
- con gafas, aparecen rutas, baja la distorsion y el personaje gana claridad.

Eso convierte una herramienta visual en un sistema de juego.

## 9. Enemigos y jerarquia de herencia

Base: [enemigo_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\enemigo_base.gd)

Derivados:

- [enemigo_patrulla.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\enemigo_patrulla.gd)
- [enemigo_perseguidor.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\enemigo_perseguidor.gd)
- [enemigo_flotante_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\enemigo_flotante_base.gd)
- [enemigo_flotante_vertical.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\enemigo_flotante_vertical.gd)
- [enemigo_flotante_horizontal.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\enemigo_flotante_horizontal.gd)
- [jefe_sombras.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\jefe_sombras.gd)

### 9.1 Que se comparte desde la base

`EnemigoBase` define comportamiento comun:

- vida,
- dano de contacto,
- recarga de ataque,
- velocidad,
- gravedad opcional,
- congelamiento,
- reinicio,
- audio base,
- audio de ataque,
- multiplicadores temporales de velocidad.

### 9.2 Por que es un buen ejemplo de POO

En vez de hacer cada enemigo desde cero, se define un contrato base y cada subtipo especializa su comportamiento.

Eso demuestra:

- herencia,
- reutilizacion,
- polimorfismo,
- extensibilidad.

Por ejemplo:

- el patrulla se mueve entre limites;
- el perseguidor activa persecucion al detectar al jugador;
- los flotantes heredan una base comun y cambian eje o patron;
- el jefe usa la base de enemigo, pero con mecanicas especiales.

## 10. Jefes

### 10.1 `JefeSombras`

Archivo: [jefe_sombras.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\jefe_sombras.gd)

Es el jefe del mundo 1. No se derrota con ataque directo del jugador, sino resolviendo logica del escenario.

Idea central:

- el jugador no pelea “golpeando”;
- activa totems;
- usa las gafas;
- desarma la amenaza por mecanica y estrategia.

Eso esta alineado con la narrativa del juego y evita meter combate clasico si no era parte del enfoque del proyecto.

### 10.2 `MuroCarne`

Archivo: [muro_carne.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\muro_carne.gd)

Es el jefe del mundo 2, pero su rol no es atacar como un enemigo comun. Es una amenaza de persecucion continua.

Su diseno es distinto porque:

- no representa combate puntual;
- representa presion constante;
- obliga a leer el terreno y usar gafas con precision.

## 11. Interactivos y reutilizacion

Base: [interactivo_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\interactivo_base.gd)

Derivados importantes:

- [puerta_teletransporte.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\puerta_teletransporte.gd)
- [puerta_bloqueada.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\puerta_bloqueada.gd)
- [llave_interactiva.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\llave_interactiva.gd)
- [altar_gafas.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\altar_gafas.gd)
- [npc_dialogo.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\npc_dialogo.gd)
- [totem_jefe.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\totem_jefe.gd)
- [checkpoint_activador.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\checkpoint_activador.gd)

### 11.1 Idea de diseno

Todos estos objetos comparten una idea:

- el jugador entra a un rango,
- el objeto sabe si puede o no interactuar,
- se emite una senal cuando corresponde.

Eso evita duplicar la misma logica de `Area2D`, rango, mensaje y confirmacion para cada objeto del juego.

### 11.2 Ventaja

Si mas adelante quisieran agregar:

- cofres,
- terminales,
- puertas especiales,
- letreros,
- palancas,

podrian heredar desde `InteractivoBase` y reutilizar la logica.

## 12. Puzzles

Base: [puzzle_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\puzzle_base.gd)

Derivados:

- [puzzle_secuencia.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\puzzle_secuencia.gd)
- [puzzle_matematicas.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\puzzle_matematicas.gd)
- [puzzle_gafas.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\puzzle_gafas.gd)

### 12.1 Funcion

`PuzzleBase` define el ciclo comun:

- iniciar,
- mostrar UI,
- cerrar,
- cancelar,
- completar.

Ademas centraliza el tema visual pixelado del panel.

### 12.2 Por que es importante

Aunque los puzzles sean distintos, todos obedecen la misma estructura de interfaz y ciclo de vida. Eso hace que:

- se vean coherentes,
- se comporten de forma parecida,
- el controlador del mundo los pueda tratar de manera uniforme.

Esto es otro caso claro de herencia y polimorfismo.

## 13. HUD e interfaz

Archivo: [hud.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\hud.gd)

El HUD no es solo decoracion. Es una vista reactiva.

### 13.1 Que muestra

- mensajes generales del nivel,
- estado del jugador,
- llave,
- checkpoint,
- corazones,
- stamina,
- estado de gafas,
- pensamientos emergentes tipo burbuja.

### 13.2 Patron Observer con senales

El jugador emite senales:

- vida cambiada,
- estado cambiado,
- estamina cambiada,
- sprint cambiado,
- gafas actualizadas.

El HUD se conecta a esas senales y reacciona. Esto es muy importante porque evita acoplar la interfaz a lecturas constantes del jugador.

En otras palabras:

- el jugador no dibuja su propia UI,
- el HUD no modifica la logica del jugador,
- ambos se comunican por eventos.

Eso es diseno limpio.

## 14. Menu de pausa, menu principal y opciones

Archivos:

- [menu.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\menu.gd)
- [menu_pausa.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\menu_pausa.gd)
- [menuOpciones.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\menuOpciones.gd)

### 14.1 Menu principal

Administra:

- nueva partida,
- cargar partida,
- eliminar slot,
- abrir creditos,
- abrir opciones.

### 14.2 Menu pausa

Administra:

- congelar o casi congelar el juego,
- continuar,
- reiniciar desde checkpoint,
- volver al menu.

### 14.3 Menu de opciones

Administra:

- volumen,
- modo de pantalla,
- resolucion,
- modo de accesibilidad para daltonismo,
- intensidad de sacudida de camara.

Este menu es importante porque introduce una capa de configuracion persistente y accesibilidad, que suele ir mas alla de lo visto en cursos introductorios.

## 15. Sistema de guardado

Archivo: [sistema_guardado.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\sistema_guardado.gd)

### 15.1 Que hace

Centraliza el guardado del juego usando `ConfigFile` en `user://`.

Maneja:

- 3 slots de guardado,
- escena actual,
- datos del mundo 1,
- datos del mundo 2,
- transiciones entre escenas,
- bandera para reproducir intro de nueva partida.

### 15.2 Como funciona

Cada slot guarda un archivo independiente. Cuando el usuario elige una partida:

1. se define el slot activo;
2. se consulta si existe guardado;
3. se carga la escena correcta;
4. el controlador del mundo reconstruye el estado.

Los controladores no guardan “todo el arbol de nodos”; guardan solo el estado esencial:

- posicion,
- checkpoints,
- puzzles resueltos,
- puertas abiertas,
- progreso del mundo,
- flags de jefe o transicion.

Eso es correcto porque persistir el estado logico es mas estable que intentar serializar toda la escena.

### 15.3 Por que esta bien disenado

`SistemaGuardado` es un servicio. No depende de la UI ni del jugador. Solo administra persistencia. Eso es una buena separacion de responsabilidades.

## 16. TDA implementado: lista enlazada simple

Archivo: [tda_lista_simple.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\tda_lista_simple.gd)

Esta parte es importante para la materia porque responde directamente al requisito de usar un TDA creado manualmente.

### 16.1 Estructura

La clase `ListaSimple` implementa:

- cabeza,
- cola,
- tamano,
- insercion al final,
- recorrido con callback.

Tambien define una clase interna `NodoLista`, con:

- `valor`
- `siguiente`

### 16.2 Donde se usa

Se usa en [cutscene_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\cutscene_base.gd) para construir los creditos.

La idea fue no usar `Array` para esa secuencia, sino un TDA real hecho por ustedes.

### 16.3 Por que vale la pena defenderlo

No es un uso “de adorno”. Sirve para demostrar:

- construccion manual de estructuras,
- recorrido secuencial,
- encapsulamiento de nodos,
- separacion entre estructura y visualizacion.

Si se los preguntan, pueden decir que el recorrido de creditos era un caso sencillo pero valido para demostrar una lista enlazada propia.

## 17. Cinematicas y presentacion narrativa

Archivo: [cutscene_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\cutscene_base.gd)

### 17.1 Que hace

Este sistema genera cinematicas estilo comic/panel:

- intro inicial,
- explicacion de controles,
- objetivos del mundo 1,
- transicion entre mundos,
- cierre del juego,
- creditos.

### 17.2 Por que es interesante

No se resolvio con videos externos obligatorios, sino con una UI programada que:

- crea paneles,
- anima sprites frame por frame,
- muestra fondos,
- compone escenas visuales,
- construye creditos desde el TDA.

Eso ya es una capa de presentacion bastante elaborada.

## 18. Parte grafica y visual

La parte grafica no es solo “poner sprites”. Hay varios subsistemas visuales.

### 18.1 Animacion del personaje

En vez de depender completamente de un `AnimatedSprite2D`, se manejan arreglos de rutas y actualizacion manual de frames segun el estado del personaje. Esto permite:

- controlar velocidad por animacion,
- sincronizar con gameplay,
- cambiar rapidamente entre idle, caminar, correr, salto, dano y muerte.

### 18.2 Distorsion visual y vigneta

Shaders:

- [vigneta_distorsion.gdshader](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Shaders\vigneta_distorsion.gdshader)
- [filtro_accesibilidad.gdshader](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Shaders\filtro_accesibilidad.gdshader)

La distorsion usa postprocesado para:

- oscurecer bordes,
- desenfocar periferia,
- reducir claridad,
- generar sensacion de incomodidad visual.

Cuando activas gafas:

- se reduce o elimina esa distorsion,
- aumenta claridad,
- el jugador “ve mejor”.

### 18.3 Fondos y parallax

Archivos:

- [fondo_mundo_1.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\fondo_mundo_1.gd)
- [fondo_mundo_final.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\fondo_mundo_final.gd)

El fondo no es estatico. Tiene capas y sensacion de profundidad. Eso mejora:

- lectura espacial,
- estetica,
- sensacion de desplazamiento.

### 18.4 Sombras y profundidad

Archivo: [sombras_plataformas.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\sombras_plataformas.gd)

Este sistema ayuda a que los bloques no se vean planos. Se oscurecen o complementan visualmente para sugerir profundidad.

## 19. Parte sonora

Hay varios componentes de audio:

- musica global,
- ambiente del mundo 1,
- ambiente del mundo 2,
- audio de puertas,
- audio de jugador,
- audio de enemigos.

Archivos clave:

- [musica_global.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\musica_global.gd)
- [ambiente_mundo_1.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\ambiente_mundo_1.gd)
- [ambiente_mundo_2.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\ambiente_mundo_2.gd)

Interesante aqui: en varios casos el audio fue generado o sintetizado por codigo, no solo cargado desde archivo. Eso ya es una capa extra que normalmente no se ve en ejercicios introductorios.

## 20. Camaras

Las camaras cumplen un rol de gameplay y presentacion.

### 20.1 Mundo 1

- uso de varias camaras y areas de activacion,
- encuadres especiales en prologo,
- camara del jefe,
- cambios de zoom con gafas.

### 20.2 Mundo 2

- camara mas abierta para persecucion,
- prioridad entre seguimiento del jugador y presion del muro,
- temblor controlado para tension,
- offsets para que se vea mejor la amenaza.

Esto va mas alla de una camara pegada al personaje y ya.

## 21. Checkpoints y progresion

Archivo principal: [checkpoint_activador.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\checkpoint_activador.gd)

Los checkpoints no solo guardan una posicion. Tambien:

- actualizan mensaje del HUD,
- definen nuevo punto de respawn,
- en el mundo 2 ajustan la persecucion,
- participan en el ritmo del nivel.

Es decir, forman parte de la progresion, no solo del respawn.

## 22. Puertas y transiciones

Archivos:

- [puerta_teletransporte.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\puerta_teletransporte.gd)
- [puerta_bloqueada.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\puerta_bloqueada.gd)

Las puertas son mas complejas de lo que parecen:

- manejan destino local o cambio de escena,
- tienen version abierta/cerrada,
- reproducen animacion,
- coordinan entrada y salida del jugador,
- usan `SistemaGuardado` para pasar datos de transicion.

Esto es un buen ejemplo de objeto interactivo con estado y comportamiento.

## 23. NPCs, dialogos y pensamientos

Archivos:

- [npc_dialogo.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\npc_dialogo.gd)
- [dialogo_ui.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\dialogo_ui.gd)
- [mensaje_automatico.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\mensaje_automatico.gd)

Aqui el objetivo fue meter narrativa sin depender de conversaciones gigantes. Hay dos capas:

- dialogo con NPCs,
- pensamientos internos del personaje.

La segunda capa es muy importante para el tema del bullying porque pone en voz el estado mental del protagonista.

## 24. Que patrones de diseno hay realmente

### 24.1 State

Usado en el jugador.

### 24.2 Observer

Usado por medio de senales entre:

- jugador y HUD,
- interactivos y controladores,
- puzzles y escena principal,
- menus y mundo.

### 24.3 Template Method o base reutilizable

No siempre de forma estricta academica, pero si conceptual:

- `InteractivoBase`
- `PuzzleBase`
- `EnemigoBase`

Cada base define comportamiento comun y deja especializacion a hijos.

### 24.4 Herencia y polimorfismo

Muy presentes en enemigos, estados, puzzles e interactivos.

### 24.5 Composicion

Muy clara en:

- jugador + estamina,
- jugador + gafas,
- mundo + HUD,
- mundo + menu pausa,
- cutscene + TDA creditos.

## 25. Que estructuras y conceptos OO se usaron

### 25.1 Clases

Todo el proyecto se organiza por clases GDScript con responsabilidades claras.

### 25.2 Objetos

Cada enemigo, puzzle, puerta, checkpoint o sistema es una instancia concreta de una clase.

### 25.3 Herencia

Permite tener familias de comportamiento.

### 25.4 Encapsulamiento

Se protege la logica interna con metodos dedicados.

### 25.5 Abstraccion

Las clases base ocultan complejidad y muestran solo lo necesario.

### 25.6 Polimorfismo

Los controladores pueden tratar puzzles o enemigos de manera uniforme aunque internamente sean distintos.

## 26. Que cosas se hicieron que probablemente van mas alla de lo visto en clase

Esta seccion es importante porque el profe podria preguntar que fue “extra”.

### 26.1 Shaders

La distorsion visual y el filtro para daltonismo son temas mas avanzados que POO basica.

### 26.2 Sistemas de postprocesado

Usar overlays con materiales para modificar la pantalla completa no suele verse en una materia introductoria.

### 26.3 Sistema de guardado por slots

Persistencia por `ConfigFile`, con transiciones entre escenas y restauracion de estado, ya es una capa extra.

### 26.4 Cinematicas programadas

La construccion de paneles y escenas narrativas desde codigo tambien va un poco mas alla.

### 26.5 Generacion de audio por codigo

En varias partes hay sonido sintetico o generado proceduralmente.

### 26.6 Camaras dinamicas con logica por mundo

No es solo seguir al personaje; hay encuadres, offsets, zooms, priorizacion y temblor.

### 26.7 Parallax y profundidad visual

Visualmente ya hay una busqueda de presentacion mas elaborada.

## 27. Que es estrictamente defendible como contenido de POO

Si tienen que aterrizarlo a la materia, lo mas importante es esto:

- clases separadas por responsabilidad,
- herencia de enemigos, puzzles e interactivos,
- patron State en jugador,
- patron Observer mediante senales,
- composicion de sistemas,
- TDA propio de lista enlazada,
- encapsulamiento del estado,
- coordinacion por controladores.

## 28. Como pueden repartir la exposicion

### Persona 1: idea y arquitectura general

- concepto del juego,
- estructura del proyecto,
- mundos y flujo general,
- escenas vs scripts.

### Persona 2: POO y patrones

- clases,
- herencia,
- polimorfismo,
- state,
- observer,
- composicion.

### Persona 3: jugador y gameplay

- movimiento,
- sprint,
- estamina,
- gafas,
- dano,
- checkpoints.

### Persona 4: puzzles, enemigos y jefes

- interactivos,
- puzzles,
- jerarquia de enemigos,
- jefe del mundo 1,
- muro del mundo 2.

### Persona 5: UI, narrativa y extras

- HUD,
- menu pausa,
- menu opciones,
- cinematics,
- guardado,
- shaders,
- accesibilidad.

## 29. Orden recomendado para estudiar el codigo

Si quieren entender todo sin perderse, revisen en este orden:

1. [UML_PROYECTO.md](C:\Users\HP\Documents\GitHub\Poo-FinalProject\docs\UML_PROYECTO.md)
2. [main_game.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\main_game.gd)
3. [mundo_2.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\mundo_2.gd)
4. [jugador.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\jugador.gd)
5. estados del jugador
6. [sistema_estamina.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\sistema_estamina.gd)
7. [habilidad_gafas.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\habilidad_gafas.gd)
8. [enemigo_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\enemigo_base.gd) y derivados
9. [interactivo_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\interactivo_base.gd) y derivados
10. [puzzle_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\puzzle_base.gd) y derivados
11. [hud.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\hud.gd)
12. [menuOpciones.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\menuOpciones.gd)
13. [sistema_guardado.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\sistema_guardado.gd)
14. [cutscene_base.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\cutscene_base.gd)
15. [tda_lista_simple.gd](C:\Users\HP\Documents\GitHub\Poo-FinalProject\Scripts\tda_lista_simple.gd)
16. shaders y sistemas visuales

## 30. Resumen final para defender el proyecto

`Deep Shadow` no es solo un platformer hecho por partes. La base del proyecto muestra una arquitectura pensada desde POO: controladores por mundo, sistemas auxiliares compuestos, familias de clases reutilizables, estados del jugador con patron `State`, UI conectada por eventos con `Observer`, persistencia centralizada y un TDA propio para cumplir el componente estructural. Encima de eso se agregaron capas extra como shaders, accesibilidad, cinematics, guardado por slots, audio ambiental y una presentacion visual coherente con la narrativa del bullying. En otras palabras, el juego no solo funciona: tambien tiene una estructura justificable desde ingenieria de software y desde el discurso tematico del proyecto.

## 31. Siguiente paso recomendado

Lo ideal ahora es hacer dos cosas:

1. preparar una version resumida de este documento para exposicion oral de 5 a 10 minutos;
2. preparar otra version tipo “preguntas y respuestas del profe”, con respuestas cortas sobre patrones, TDA, guardado, shaders, HUD y organizacion.

Si quieres, lo siguiente te lo puedo dejar ya hecho en cualquiera de estas dos formas:

- un `guion de exposicion` por integrantes,
- un `preguntario con respuestas`,
- o una `defensa tecnica corta` lista para leer.  
