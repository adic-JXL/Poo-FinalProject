# Preguntas y respuestas para la defensa del proyecto

Este documento esta pensado para ensayar la sustentacion del proyecto `Deep Shadow`. La idea es que puedan responder preguntas tecnicas de forma clara, corta y segura, sin perder el hilo de lo que realmente se hizo.

La estructura es:

- pregunta probable del profesor,
- respuesta corta para decir en voz alta,
- aclaracion extra por si les repreguntan.

## 1. Preguntas generales del proyecto

### 1.1 ¿De que trata el juego?

**Respuesta corta:**  
`Deep Shadow` es un juego 2D de plataformas hecho en Godot que representa, por medio de mecanicas jugables, la experiencia de un personaje que sufre bullying por usar gafas. La idea fue convertir ese tema en gameplay, usando distorsion visual, rutas ocultas, puzzles y jefes simbolicos.

**Si repreguntan:**  
No queriamos que el tema se quedara solo en el dialogo o en la historia. Por eso lo llevamos al diseno del mundo: sin gafas el entorno se siente mas hostil y confuso, mientras que con gafas aparece claridad, nuevas rutas y control.

### 1.2 ¿Que tipo de juego es tecnicamente?

**Respuesta corta:**  
Es un juego 2D de plataformas con elementos de exploracion, puzzles, persecucion, interaccion contextual y narrativa ambiental.

**Si repreguntan:**  
El mundo 1 se enfoca mas en exploracion, puzzles y jefe por mecanica; el mundo 2 se enfoca en persecucion, precision y lectura del entorno.

### 1.3 ¿En que motor lo hicieron?

**Respuesta corta:**  
En Godot, usando escenas, nodos, GDScript, shaders y sistemas propios del motor como senales, `CharacterBody2D`, `CanvasLayer`, `ConfigFile` y `Area2D`.

## 2. Preguntas de arquitectura

### 2.1 ¿Como organizaron el proyecto?

**Respuesta corta:**  
Lo organizamos por responsabilidades: escenas en [Escenas](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Escenas), logica en [Scripts](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts), shaders en [Shaders](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Shaders), assets en [Imagenes](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Imagenes) y documentacion en [docs](C:/Users/HP/Documents/GitHub/Poo-FinalProject/docs).

**Si repreguntan:**  
Ademas separamos por tipo de sistema: controladores de mundo, jugador, enemigos, puzzles, interactivos, HUD, guardado y cinematics. Eso evita mezclar toda la logica en pocas clases gigantes.

### 2.2 ¿Cuales son las clases mas importantes?

**Respuesta corta:**  
Las mas importantes son:

- [main_game.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/main_game.gd) para el mundo 1,
- [mundo_2.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/mundo_2.gd) para el mundo 2,
- [jugador.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/jugador.gd) para el personaje,
- [sistema_guardado.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/sistema_guardado.gd),
- [hud.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/hud.gd),
- [interactivo_base.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/interactivo_base.gd),
- [enemigo_base.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/enemigo_base.gd),
- [puzzle_base.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/puzzle_base.gd).

### 2.3 ¿Por que separaron `MainGame` y `Mundo2`?

**Respuesta corta:**  
Porque cada mundo tiene un flujo distinto. `MainGame` coordina exploracion, checkpoints, jefe, puzzles y transicion. `Mundo2` coordina persecucion, muro, camara especial, checkpoints de carrera y puzzles del segundo tramo.

**Si repreguntan:**  
Separarlos mejora mantenibilidad y escalabilidad. Si todo estuviera en una sola clase, el codigo seria mucho mas dificil de leer y modificar.

## 3. Preguntas de Programacion Orientada a Objetos

### 3.1 ¿Donde se ve la POO en el proyecto?

**Respuesta corta:**  
Se ve en el uso de clases, objetos, herencia, composicion, encapsulamiento, polimorfismo y separacion de responsabilidades.

**Si repreguntan:**  
Por ejemplo:

- `Jugador` compone `SistemaEstamina` y `HabilidadGafas`.
- `EnemigoBase` tiene subclases como patrulla, perseguidor y flotantes.
- `PuzzleBase` tiene subclases para distintos puzzles.
- `InteractivoBase` sirve como base para puertas, altares, llaves y otros objetos.

### 3.2 ¿Que entienden por encapsulamiento en su proyecto?

**Respuesta corta:**  
Que cada clase administra su propio estado y no dejamos que cualquier otra clase modifique internamente sus variables sin control.

**Si repreguntan:**  
Por ejemplo, al jugador no se le cambia la vida desde afuera tocando la variable directamente, sino usando metodos como `recibir_danio()` o `restaurar_para_respawn()`.

### 3.3 ¿Que ejemplos de herencia tienen?

**Respuesta corta:**  
Tenemos tres jerarquias muy claras:

- enemigos desde `EnemigoBase`,
- puzzles desde `PuzzleBase`,
- interactivos desde `InteractivoBase`.

### 3.4 ¿Que ejemplos de composicion tienen?

**Respuesta corta:**  
El mejor ejemplo es el jugador, que internamente usa un `SistemaEstamina` y una `HabilidadGafas`. Tambien los controladores de mundo componen HUD, jugador, jefes, puzzles y menus.

### 3.5 ¿Que ejemplos de polimorfismo tienen?

**Respuesta corta:**  
Los controladores pueden trabajar con objetos de la misma familia sin importar la variante exacta. Por ejemplo, un puzzle se puede abrir, cerrar o completar aunque internamente sea de secuencia, matematicas o gafas.

## 4. Preguntas de patrones de diseno

### 4.1 ¿Que patrones de diseno usaron?

**Respuesta corta:**  
Principalmente `State` y `Observer`, ademas de una estructura base reutilizable por herencia en enemigos, puzzles e interactivos.

### 4.2 ¿Donde usaron el patron State?

**Respuesta corta:**  
En el jugador. El personaje no tiene todo su comportamiento mezclado en un solo bloque, sino que delega a estados como normal, sprint, aturdido y bloqueado.

**Si repreguntan:**  
Eso esta implementado en:

- [estado_jugador_base.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/estado_jugador_base.gd)
- [estado_jugador_normal.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/estado_jugador_normal.gd)
- [estado_jugador_sprint.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/estado_jugador_sprint.gd)
- [estado_jugador_aturdido.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/estado_jugador_aturdido.gd)
- [estado_jugador_bloqueado.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/estado_jugador_bloqueado.gd)

### 4.3 ¿Por que les sirvio usar State?

**Respuesta corta:**  
Porque el jugador tiene comportamientos distintos segun su estado. En vez de llenar `jugador.gd` de condicionales, cada estado maneja su propia logica.

### 4.4 ¿Donde usaron Observer?

**Respuesta corta:**  
En las senales de Godot. Por ejemplo, el jugador emite senales cuando cambia vida, estamina, sprint o gafas, y el HUD escucha esas senales para actualizarse.

### 4.5 ¿Por que las senales sirven como Observer?

**Respuesta corta:**  
Porque permiten comunicacion entre objetos sin acoplarlos directamente. El emisor no necesita saber como el receptor usa la informacion; solo emite el evento.

## 5. Preguntas del jugador

### 5.1 ¿Como funciona el movimiento del jugador?

**Respuesta corta:**  
El jugador usa `CharacterBody2D`, gravedad del motor, movimiento horizontal con aceleracion y desaceleracion, salto y sprint. El comportamiento final depende del estado actual del jugador.

### 5.2 ¿Como funciona el sprint?

**Respuesta corta:**  
Mientras el jugador tiene estamina, puede aumentar su velocidad usando un multiplicador de sprint. Si las gafas estan activas, el sprint se vuelve ilimitado temporalmente.

### 5.3 ¿Como funciona el dano?

**Respuesta corta:**  
Cuando un enemigo llama `recibir_danio()` sobre el jugador, se reduce vida, se activa invulnerabilidad temporal, se aplica retroceso, se emiten senales para la UI y, si la vida llega a cero, se activa la secuencia de muerte y respawn.

### 5.4 ¿Como funciona el respawn?

**Respuesta corta:**  
El jugador reaparece en el checkpoint activo o en el punto inicial si no hay checkpoint. Al respawnear se restauran controles, posicion, estado y una breve invulnerabilidad.

## 6. Preguntas sobre las gafas

### 6.1 ¿Las gafas son un item o una habilidad?

**Respuesta corta:**  
Son una habilidad intrinseca del personaje. No se recogen como consumible. El jugador las activa manualmente.

### 6.2 ¿Que hacen las gafas en gameplay?

**Respuesta corta:**  
Revelan plataformas y rutas ocultas, reducen la distorsion visual, hacen mas claro el entorno, dan un pequeno bonus de velocidad y salto, y reducen la velocidad de amenazas del mundo.

### 6.3 ¿Por que las gafas son importantes narrativamente?

**Respuesta corta:**  
Porque representan la idea de que ver distinto no es una debilidad sino una forma de encontrar claridad. Mecanicamente cambian el mundo y simbolicamente resignifican el problema del personaje.

## 7. Preguntas sobre enemigos

### 7.1 ¿Como organizaron los enemigos?

**Respuesta corta:**  
Con una clase base, `EnemigoBase`, que maneja vida, dano, velocidad, congelamiento, reinicio y ataque. A partir de ahi se construyen enemigos con comportamientos especializados.

### 7.2 ¿Que tipos de enemigos tienen?

**Respuesta corta:**  
Tenemos enemigos patrulla, enemigos perseguidores y enemigos flotantes en variantes horizontal y vertical. Ademas, cada mundo tiene su propio jefe.

### 7.3 ¿Como hacen dano los enemigos?

**Respuesta corta:**  
Usan un area de ataque y tambien validacion por colision directa. Si detectan al jugador y pueden atacar, llaman la funcion `recibir_danio()` del jugador.

## 8. Preguntas sobre los jefes

### 8.1 ¿Como se derrota el jefe del mundo 1 si el personaje no ataca?

**Respuesta corta:**  
No se derrota por combate directo, sino activando totems y resolviendo la mecanica del escenario. Eso se hizo asi para mantener coherencia con el enfoque del juego.

### 8.2 ¿Que representa el jefe del mundo 1?

**Respuesta corta:**  
Representa una forma de presion mental y distorsion. Por eso se relaciona con el uso de las gafas, la arena cerrada y el incremento de tension visual.

### 8.3 ¿Como funciona el jefe del mundo 2?

**Respuesta corta:**  
Es una persecucion con un muro que avanza de izquierda a derecha. Si toca al jugador, reinicia la carrera. La dificultad no esta en pegarle, sino en escapar usando plataformas, timing y gafas.

## 9. Preguntas sobre interactivos

### 9.1 ¿Para que hicieron `InteractivoBase`?

**Respuesta corta:**  
Para no repetir la misma logica de rango, deteccion del jugador, mensaje e interaccion en puertas, llaves, altares, carteles, NPCs y totems.

### 9.2 ¿Que ganaron con eso?

**Respuesta corta:**  
Reutilizacion, codigo mas limpio y posibilidad de agregar nuevos interactivos sin rehacer toda la logica.

## 10. Preguntas sobre puzzles

### 10.1 ¿Que tipos de puzzles tiene el juego?

**Respuesta corta:**  
Tiene puzzles de secuencia, de matematica y de uso contextual de gafas.

### 10.2 ¿Por que hicieron `PuzzleBase`?

**Respuesta corta:**  
Porque todos los puzzles comparten un ciclo comun: abrir, mostrar UI, resolver o cancelar, y cerrar. Lo distinto es la logica interna de cada puzzle.

### 10.3 ¿Como conectaron los puzzles con la historia?

**Respuesta corta:**  
Intentamos que no fueran pruebas aisladas. Los puzzles se conectan con ideas de lectura, orden, claridad y percepcion, que son temas centrales del juego.

## 11. Preguntas sobre HUD y UI

### 11.1 ¿Como funciona el HUD?

**Respuesta corta:**  
El HUD es una vista reactiva. Escucha las senales del jugador y actualiza vida, estamina, estado, llave, checkpoint, gafas y pensamientos.

### 11.2 ¿Por que no hicieron el HUD leyendo variables todo el tiempo?

**Respuesta corta:**  
Porque con senales el acoplamiento es menor. El jugador emite cambios y el HUD responde solo cuando hace falta.

### 11.3 ¿Que muestra el HUD?

**Respuesta corta:**  
Muestra corazones, barra de estamina, icono de gafas, estado, mensajes de progreso, llave, checkpoint y pensamientos del personaje.

## 12. Preguntas sobre guardado

### 12.1 ¿Como funciona el guardado?

**Respuesta corta:**  
Usamos un sistema centralizado con `ConfigFile` y tres slots. Cada slot guarda la escena actual y los datos de progreso del mundo correspondiente.

### 12.2 ¿Que guarda exactamente?

**Respuesta corta:**  
Guarda lo esencial del estado logico:

- escena actual,
- posicion o respawn,
- checkpoints,
- puertas abiertas,
- puzzles resueltos,
- progreso del mundo,
- transiciones entre escenas.

### 12.3 ¿Por que no guardaron todo el arbol de nodos?

**Respuesta corta:**  
Porque es mas robusto guardar estado logico reconstruible que intentar serializar toda la escena completa. Asi el guardado es mas controlado y mantenible.

### 12.4 ¿Quien maneja el guardado?

**Respuesta corta:**  
La clase [sistema_guardado.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/sistema_guardado.gd). Los controladores de mundo solo le pasan los datos a persistir.

## 13. Preguntas sobre el TDA

### 13.1 ¿Que TDA implementaron?

**Respuesta corta:**  
Una lista enlazada simple propia, en [tda_lista_simple.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/tda_lista_simple.gd).

### 13.2 ¿Que tiene internamente esa lista?

**Respuesta corta:**  
Tiene una clase `NodoLista` con `valor` y `siguiente`, y la lista maneja `cabeza`, `cola` y `tamano`.

### 13.3 ¿Que operaciones implementaron?

**Respuesta corta:**  
Implementamos:

- verificar si esta vacia,
- obtener tamano,
- insertar al final,
- recorrer la lista con callback.

### 13.4 ¿Donde la usaron?

**Respuesta corta:**  
La usamos en la construccion de los creditos del juego dentro de [cutscene_base.gd](C:/Users/HP/Documents/GitHub/Poo-FinalProject/Scripts/cutscene_base.gd).

### 13.5 ¿Por que decidieron usarla ahi?

**Respuesta corta:**  
Porque era un caso claro de secuencia ordenada, donde podiamos demostrar un recorrido lineal con una estructura propia, sin depender de `Array`.

### 13.6 ¿Por que no usaron un array normal?

**Respuesta corta:**  
Precisamente porque queriamos cumplir el requisito del TDA implementado manualmente y demostrar que entendemos la estructura, no solo el uso de colecciones del lenguaje.

## 14. Preguntas sobre shaders y accesibilidad

### 14.1 ¿Que shaders usaron?

**Respuesta corta:**  
Usamos shaders para la distorsion visual del mundo y para el filtro de accesibilidad por daltonismo.

### 14.2 ¿Como funciona la distorsion?

**Respuesta corta:**  
Es un postprocesado que aplica oscurecimiento en bordes, blur, cambios de claridad y tension visual. Se intensifica o reduce segun el contexto, como el jefe o el uso de gafas.

### 14.3 ¿Como funciona la opcion de daltonismo?

**Respuesta corta:**  
Se aplica como un filtro de pantalla completa mediante un `ColorRect` con un `ShaderMaterial`. El shader recolorea la salida final para hacer mas distinguibles ciertos contrastes segun el tipo de daltonismo elegido.

### 14.4 ¿Eso fue algo extra?

**Respuesta corta:**  
Si. Tanto el shader de accesibilidad como la distorsion son extras respecto a lo que normalmente se ve en una materia base de POO.

## 15. Preguntas sobre la parte grafica

### 15.1 ¿Como manejaron las animaciones del personaje?

**Respuesta corta:**  
Las manejamos con secuencias de frames y actualizacion por codigo segun el estado del personaje: idle, caminar, correr, salto, dano y muerte.

### 15.2 ¿Como manejaron la profundidad del escenario?

**Respuesta corta:**  
Con fondos por capas, parallax y detalles visuales como sombras en plataformas, para que el entorno no se viera plano.

### 15.3 ¿Como integraron la estetica pixel art?

**Respuesta corta:**  
Mantuvimos sprites, HUD, fondos, UI, fuentes y transiciones en una misma linea visual pixelada. Incluso los menus y cinematicas usan la misma logica estetica.

## 16. Preguntas sobre sonido

### 16.1 ¿Que papel tiene el sonido?

**Respuesta corta:**  
El sonido refuerza game feel y ambiente. Tenemos musica, sonidos de movimiento, dano, puertas, enemigos, ambiente y tension del segundo mundo.

### 16.2 ¿Hicieron algo especial con el audio?

**Respuesta corta:**  
Si. En algunas partes no solo cargamos audios, sino que generamos o sintetizamos ciertos sonidos por codigo.

## 17. Preguntas sobre camaras

### 17.1 ¿La camara siempre sigue igual al jugador?

**Respuesta corta:**  
No. La camara cambia segun la zona y el mundo. En el prologo tiene encuadres especiales; en el mundo 1 cambia por zonas y jefe; en el mundo 2 se adapta a la persecucion.

### 17.2 ¿Por que la camara del mundo 2 es diferente?

**Respuesta corta:**  
Porque en una persecucion no basta con centrar solo al jugador. Tambien hay que mostrar el muro, anticipar lo que viene y transmitir presion.

## 18. Preguntas sobre lo que hicieron extra

### 18.1 ¿Que hicieron que fuera mas alla de lo visto en clase?

**Respuesta corta:**  
Hicimos varias cosas extra:

- shaders de distorsion y accesibilidad,
- guardado por slots,
- cinematics programadas,
- audio sintetico,
- camaras dinamicas,
- parallax,
- HUD reactivo con burbujas de pensamiento.

### 18.2 ¿Eso sigue siendo valido para la materia?

**Respuesta corta:**  
Si, porque la base estructural sigue siendo POO. Los extras no reemplazan la orientacion a objetos; la complementan y muestran una aplicacion mas completa.

## 19. Preguntas de justificacion tecnica

### 19.1 ¿Por que no hicieron todo en un solo script?

**Respuesta corta:**  
Porque seria mas dificil de mantener, probar y ampliar. Separar responsabilidades mejora claridad y hace que cada sistema tenga una funcion concreta.

### 19.2 ¿Por que usan clases base?

**Respuesta corta:**  
Para reutilizar comportamiento comun y permitir variantes sin duplicar codigo. Eso reduce errores y facilita crecer el proyecto.

### 19.3 ¿Por que usan senales en vez de llamadas directas en todo?

**Respuesta corta:**  
Porque las senales desacoplan sistemas. Permiten comunicar eventos sin que los objetos dependan demasiado unos de otros.

## 20. Preguntas capciosas que si les podrian hacer

### 20.1 ¿Como defenderian que esto si es orientado a objetos y no solo scripting?

**Respuesta corta:**  
Porque el proyecto no esta resuelto como una secuencia de funciones sueltas, sino como una red de clases con responsabilidades, estado interno, relaciones por herencia y composicion, y patrones de comunicacion entre objetos.

### 20.2 ¿Cual dirian que es la decision de diseno mas importante del proyecto?

**Respuesta corta:**  
Separar el juego por sistemas y usar clases base reutilizables. Eso permitio que el proyecto creciera sin romperse tanto y que la narrativa se integrara con el gameplay.

### 20.3 ¿Que mejorarian si tuvieran mas tiempo?

**Respuesta corta:**  
Podriamos mejorar tres cosas:

- ampliar el uso del TDA a mas sistemas,
- pulir aun mas testing y herramientas de depuracion,
- seguir desacoplando ciertos controladores grandes en subservicios.

Esa respuesta es buena porque reconoce margen de mejora sin debilitar el trabajo hecho.

## 21. Respuesta corta final si les piden resumir todo

**Respuesta corta:**  
`Deep Shadow` es un juego 2D en Godot construido con una arquitectura orientada a objetos. Organizamos el proyecto por responsabilidades, usamos herencia para enemigos, puzzles e interactivos, aplicamos `State` en el jugador y `Observer` mediante senales, implementamos un TDA propio de lista enlazada para creditos, y construimos sistemas de guardado, HUD, puzzles, jefes, shaders y narrativa visual para que el tema del bullying no solo se contara, sino que tambien se jugara.

## 22. Recomendacion para ensayar

Ensayen respondiendo en tres niveles:

1. respuesta de 10 segundos,
2. respuesta de 30 segundos,
3. respuesta ampliada de 1 minuto.

Si quieren, el siguiente paso que les puedo dejar es uno de estos:

- un simulacro de preguntas del profesor con respuestas mas exigentes,
- una version ultra resumida tipo machete de repaso,
- o un guion por integrante con que debe decir cada uno.  
