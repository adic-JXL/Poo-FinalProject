# Guion Presentacion Final - 6 Personas

Este guion esta construido a partir de:

- la explicacion completa del proyecto,
- el informe final,
- el UML,
- y la transcripcion del testimonio sobre como fue otra presentacion.

La idea es seguir exactamente este orden:

1. Problematica.
2. Solucion.
3. Metodologia.
4. Requisitos funcionales.
5. UML.
6. Patrones de diseno.
7. Sistemas principales.
8. Resultados y cierre.

## 1. Como deberian hacer la presentacion

No la hagan como si estuvieran leyendo un informe. Haganla como una defensa del proyecto.

Reglas practicas:

- Siempre empiecen por el problema real: bullying y percepcion emocional del protagonista.
- Luego expliquen por que el juego es la solucion a esa problematica.
- Despues entren a metodologia y requisitos.
- Cuando lleguen al UML, no expliquen todas las cajas. Expliquen las partes importantes.
- Del UML enfaticen: controladores, jugador, guardado, HUD, puzzles, enemigos, TDA y patrones.
- No se queden mucho tiempo en detalles visuales menores al principio.
- La demo del juego debe reforzar lo que ya explicaron, no reemplazar la explicacion.
- Si el profesor pregunta algo tecnico, respondan aterrizandolo a POO.

## 2. Reparto sugerido

Si quieren repartirlo segun los 6 integrantes, este orden funciona bien:

1. Integrante 1: problema, objetivo y propuesta del juego.
2. Integrante 2: metodologia y requerimientos.
3. Integrante 3: arquitectura general y UML.
4. Integrante 4: patrones de diseno y TDA.
5. Integrante 5: sistemas principales del gameplay.
6. Integrante 6: resultados, demo, cierre y conclusiones.

## 3. Orden exacto de la exposicion

### Integrante 1 - Problematica, objetivo y solucion

Tiempo sugerido: 2 minutos

Que debe explicar:

- cual es la problematica,
- por que decidieron trabajar bullying,
- cual es la solucion propuesta,
- por que un videojuego si es una solucion valida.

Guion sugerido:

"Nuestro proyecto se llama Deep Shadows. La problematica que quisimos abordar fue el bullying, especificamente como afecta la percepcion emocional y mental de una persona. No queriamos resolverlo con un cuestionario ni con una charla tradicional, sino con una experiencia interactiva.

La solucion que propusimos fue un videojuego 2D de plataformas con enfoque narrativo. En este juego, el protagonista atraviesa escenarios distorsionados, enfrenta obstaculos y resuelve retos que simbolizan la confusion, la presion social y la necesidad de recuperar claridad.

La razon por la que el juego es la solucion a la problematica es que no solo cuenta el tema del bullying, sino que lo convierte en mecanicas jugables. Por ejemplo, la distorsion visual representa incomodidad y confusion, mientras que las gafas representan claridad, interpretacion y cambio de perspectiva."

Frase de cierre para conectar con el siguiente:

"Despues de definir esa idea general, estructuramos el proyecto con una metodologia de desarrollo y una serie de requisitos concretos."

### Integrante 2 - Metodologia y requerimientos

Tiempo sugerido: 2 a 3 minutos

Que debe explicar:

- como se organizaron,
- herramienta de gestion,
- metodologia incremental,
- requerimientos funcionales importantes,
- requerimientos no funcionales mas defendibles.

Guion sugerido:

"Para desarrollar el proyecto usamos una metodologia incremental. Primero definimos el concepto, la problematica, los requisitos y el diseno general. Luego implementamos un corte vertical con movimiento, salto, sprint, HUD, puerta, llave y puzzle. En iteraciones posteriores agregamos la habilidad de gafas, distorsion visual, guardado por slots, menu de opciones, enemigos, checkpoints, segundo mundo y mejoras de accesibilidad.

Tambien usamos Trello para repartir tareas y llevar seguimiento del trabajo por areas.

En cuanto a requerimientos funcionales, los mas importantes fueron: iniciar, cargar y eliminar partidas por slots; mover al jugador; saltar; usar sprint con estamina; interactuar con objetos; activar las gafas; resolver puzzles aleatorios; mostrar mensajes de ayuda; enfrentar enemigos y amenazas distintas; y permitir pausa y opciones.

En cuanto a requerimientos no funcionales, destacamos usabilidad, confiabilidad, rendimiento y soporte. Por ejemplo, el juego debia ser entendible mediante HUD, controles y mensajes, debia soportar reinicios y checkpoints, y debia tener una estructura mantenible por clases y escenas."

Frase de cierre:

"Una vez definidos esos requisitos, la implementacion se organizo con una arquitectura orientada a objetos que se ve claramente en el UML."

### Integrante 3 - UML y arquitectura general

Tiempo sugerido: 3 minutos

Que debe explicar:

- no todo el UML,
- la estructura global,
- controladores principales,
- relacion entre clases base y especializaciones.

Guion sugerido:

"En el UML se ve que no construimos el juego como una sola clase gigante, sino como una arquitectura por responsabilidades.

Los dos controladores principales son MainGame y Mundo2. MainGame coordina el flujo del mundo 1: jugador, HUD, puzzles, checkpoints, jefe y progresion. Mundo2 hace algo parecido, pero para un nivel de persecucion con el muro, checkpoints de carrera y puzzles por orden.

Luego tenemos la entidad principal, que es Jugador, y varios sistemas que lo componen, como SistemaEstamina y HabilidadGafas. Esto demuestra composicion: el jugador no guarda toda esa logica mezclada, sino que delega responsabilidades.

Tambien se ven varias jerarquias importantes: EnemigoBase para enemigos, PuzzleBase para puzzles e InteractivoBase para objetos interactivos. Eso hace que el proyecto sea mas mantenible y extensible."

Que senalar visualmente en el UML:

- `MainGame`
- `Mundo2`
- `Jugador`
- `SistemaEstamina`
- `HabilidadGafas`
- `SistemaGuardado`
- `HUD`
- `PuzzleBase`
- `EnemigoBase`
- `ListaSimple`

Frase de cierre:

"Ya viendo la estructura general, hay dos ideas de diseno que vale la pena defender con fuerza: los patrones usados y el TDA propio."

### Integrante 4 - Patrones de diseno y TDA

Tiempo sugerido: 2 a 3 minutos

Que debe explicar:

- `State`,
- `Observer`,
- herencia y polimorfismo,
- TDA `ListaSimple`.

Guion sugerido:

"El patron mas claro del proyecto es State, aplicado al jugador. En vez de manejar todo con muchos if dentro de una sola clase, el jugador delega comportamiento a estados como EstadoJugadorNormal, EstadoJugadorSprint, EstadoJugadorAturdido y EstadoJugadorBloqueado. Esto mejora el desacoplamiento y permite cambiar comportamiento sin romper toda la clase.

El otro patron importante es Observer, implementado mediante senales de Godot. Por ejemplo, el jugador emite eventos cuando cambia la vida, la estamina, el sprint o las gafas, y el HUD escucha esas senales para actualizarse. Asi evitamos dependencias fuertes entre logica e interfaz.

Tambien usamos herencia y polimorfismo en enemigos, puzzles e interactivos. La base define comportamiento comun y las subclases especializan.

Ademas, implementamos un TDA propio llamado ListaSimple, una lista enlazada simple con nodos propios. La usamos en CutsceneBase para construir y recorrer los creditos, lo que nos permite demostrar una estructura manual, encapsulada y reutilizable."

Frase de cierre:

"Despues de eso, podemos pasar a los sistemas principales que hacen funcionar la experiencia jugable."

### Integrante 5 - Sistemas principales del juego

Tiempo sugerido: 3 minutos

Que debe explicar:

- jugador,
- estamina,
- gafas,
- puzzles,
- enemigos,
- guardado,
- interactivos.

Guion sugerido:

"En cuanto a sistemas principales, el primero es el jugador. El jugador maneja movimiento, salto, sprint, vida, dano, invulnerabilidad, animaciones, audio y la habilidad de gafas.

El sistema de estamina controla consumo y regeneracion del sprint. Esta separado del jugador para que tenga una responsabilidad propia.

La habilidad de gafas es uno de los sistemas centrales del proyecto. No es solo un item, sino una mecanica narrativa y funcional. Al activarla, se reducen efectos de distorsion, se revelan rutas ocultas, aparecen plataformas especiales y cambia la lectura del entorno.

Los puzzles siguen una estructura comun gracias a PuzzleBase, y de ahi salen PuzzleSecuencia, PuzzleMatematicas y PuzzleGafas.

En enemigos, partimos de EnemigoBase y construimos variantes como patrulla, perseguidor y flotantes. Ademas hay dos jefes importantes: JefeSombras, que se supera por logica del escenario y uso de totems, y MuroCarne, que funciona como una amenaza continua de persecucion en el segundo mundo.

Tambien vale la pena mencionar SistemaGuardado, porque centraliza slots, transiciones entre escenas y restauracion del progreso, lo cual le da solidez al proyecto."

Que debe enfatizar:

- las gafas conectan narrativa y mecanica,
- el guardado por slots es una capa tecnica fuerte,
- los jefes no son solo combate, sino representacion simbolica.

Frase de cierre:

"Con todos esos sistemas integrados, el resultado final ya no es solo una idea en papel, sino un prototipo funcional que pudimos probar y presentar."

### Integrante 6 - Resultados, demo y cierre

Tiempo sugerido: 2 a 3 minutos

Que debe explicar:

- que se logro al final,
- que se va a mostrar en demo,
- inclusividad y accesibilidad,
- cierre fuerte del proyecto.

Guion sugerido:

"Como resultado, obtuvimos un prototipo funcional con menu principal, slots de guardado, menu de opciones, selector de skin, controles, HUD, jugador, puzzles, enemigos, jefes, checkpoints, sistema de dialogos, segundo mundo, efectos visuales y cierre narrativo.

Tambien integramos componentes de accesibilidad e inclusion, como filtros de color, ajustes visuales, selector de personaje masculino y femenino y mensajes de apoyo en la interfaz.

En la demo vamos a mostrar brevemente el menu, el selector de skin, el movimiento del jugador, el uso de las gafas, un puzzle, parte del mundo 2 y una muestra del flujo general del juego.

En conclusion, Deep Shadows no solo cumple con la idea de hacer un videojuego funcional, sino que tambien esta defendido desde programacion orientada a objetos, porque tiene separacion de responsabilidades, herencia, composicion, patrones de diseno y un TDA propio. Ademas, el tema del bullying no se queda en el discurso, sino que se representa directamente en la experiencia jugable."

Cierre final:

"Muchas gracias. Si quieren, ahora podemos mostrar la demo y responder preguntas sobre el UML, patrones, guardado o sistemas principales."

## 4. Orden recomendado de diapositivas

Este seria el orden ideal:

1. Titulo del proyecto y nombres.
2. Problematica.
3. Objetivo general.
4. Solucion propuesta: el juego.
5. Metodologia de desarrollo.
6. Requerimientos funcionales.
7. Requerimientos no funcionales.
8. Arquitectura general.
9. UML.
10. Patrones de diseno.
11. Sistemas principales.
12. TDA ListaSimple.
13. Resultados del prototipo.
14. Demo.
15. Conclusiones.

## 5. Como explicar el UML sin perderse

No digan "aqui esta MainGame, aqui esta Jugador, aqui esta HUD" y ya. Expliquenlo por bloques:

1. Controladores:
   `MainGame` y `Mundo2`.

2. Entidad principal:
   `Jugador`.

3. Sistemas que componen al jugador:
   `SistemaEstamina` y `HabilidadGafas`.

4. Jerarquias reutilizables:
   `EnemigoBase`, `PuzzleBase`, `InteractivoBase`.

5. Vista y eventos:
   `HUD`, `MenuPausa`, `DialogoUI`.

6. Persistencia:
   `SistemaGuardado`.

7. Estructura propia:
   `ListaSimple` y `NodoLista`.

La frase mas fuerte para defender el UML es esta:

"El UML demuestra que el proyecto esta organizado por responsabilidades y no como una sola clase con toda la logica mezclada."

## 6. Que mostrar en la demo

No intenten jugar demasiado. La demo debe reforzar conceptos.

Orden de demo sugerido:

1. Menu principal.
2. Selector de slots.
3. Selector de skin.
4. Entrada al juego.
5. Movimiento, salto y sprint.
6. Activacion de gafas.
7. Plataforma o ruta revelada.
8. Un puzzle corto.
9. Una muestra del segundo mundo o del jefe.
10. Cierre.

## 7. Como deberian hablar

Forma correcta:

- explicar con seguridad,
- hablar por ideas,
- conectar siempre problema con solucion,
- conectar siempre mecanica con narrativa,
- conectar siempre codigo con POO.

Forma incorrecta:

- ponerse a leer lineas del informe,
- intentar explicar todo el UML caja por caja,
- hablar solo de arte o solo de codigo,
- decir "eso lo hizo tal persona y yo no se".

## 8. Si el profesor interrumpe con preguntas

Respondan corto y directo.

Ejemplos:

- Si pregunta por `State`:
  "Lo usamos para separar los estados del jugador y evitar muchos if en una sola clase."

- Si pregunta por `Observer`:
  "Lo aplicamos con senales de Godot, por ejemplo entre Jugador y HUD."

- Si pregunta por el TDA:
  "Implementamos una lista enlazada simple propia para construir los creditos desde CutsceneBase."

- Si pregunta por por que dos mundos:
  "Porque MainGame y Mundo2 tienen flujos diferentes: exploracion y persecucion."

- Si pregunta por por que el juego representa bullying:
  "Porque la distorsion, las gafas, los puzzles y los obstaculos convierten el estado emocional del protagonista en mecanicas jugables."

## 9. Reparto final ultra corto

Si necesitan memorizarlo rapido, este es el reparto minimo:

- Persona 1: problema, objetivo, solucion.
- Persona 2: metodologia y requisitos.
- Persona 3: UML y arquitectura.
- Persona 4: patrones y TDA.
- Persona 5: jugador, gafas, puzzles, enemigos, guardado.
- Persona 6: resultados, demo, conclusiones.

## 10. Frase final recomendada

"Deep Shadows es un proyecto donde la narrativa del bullying no solo se cuenta, sino que se juega, y esa experiencia fue construida con una arquitectura orientada a objetos defendible tecnica y academicamente."
