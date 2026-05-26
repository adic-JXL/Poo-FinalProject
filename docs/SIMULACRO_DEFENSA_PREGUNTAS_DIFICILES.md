# Simulacro de defensa: preguntas dificiles

Este documento esta pensado como entrenamiento para una sustentacion mas exigente. Aqui no se asume un profesor que solo quiera escuchar que el juego funciona, sino uno que pregunte por justificacion tecnica, decisiones de diseno, limites del proyecto y coherencia con Programacion Orientada a Objetos.

La idea es que ensayen estas respuestas en voz alta. Las respuestas estan escritas para que suenen naturales y defendibles, no para que parezcan memorizadas de libro.

## 1. Preguntas dificiles sobre la arquitectura

### 1.1 Si el proyecto es orientado a objetos, por que `main_game.gd` y `mundo_2.gd` siguen siendo clases grandes?

**Respuesta recomendada:**  
Porque son controladores de alto nivel. Su funcion es coordinar sistemas, no reemplazarlos. Es verdad que son clases extensas, pero no concentran toda la logica del juego: el movimiento vive en `Jugador`, los puzzles en sus clases, los enemigos en su jerarquia, el guardado en `SistemaGuardado`, la UI en `HUD` y `MenuPausa`, y las cinematicas en `CutsceneBase`. Si todo eso hubiera estado dentro de los controladores, el acoplamiento seria mucho peor.

**Como defenderlo mejor:**  
Pueden reconocer honestamente que esos controladores todavia son candidatos a una refactorizacion futura en subservicios, por ejemplo un coordinador de checkpoints o un coordinador de puertas. Decir eso no los debilita; al contrario, muestra criterio de ingenieria.

### 1.2 Por que no hicieron una sola clase `Mundo` y de ahi heredar `MainGame` y `Mundo2`?

**Respuesta recomendada:**  
Porque evaluamos que, aunque ambos son mundos, su flujo concreto es bastante distinto. El mundo 1 es mas de exploracion y progresion por zonas; el mundo 2 es una persecucion continua con otra logica de camara, respawn y tension. En ese punto, forzar una superclase podia generar una abstraccion artificial.

**Si repreguntan:**  
Si creciera el proyecto con tres o cuatro mundos mas, ahi si valdria la pena una clase base `MundoBase` con responsabilidades compartidas como pausa, HUD, jugador, guardado o transicion.

### 1.3 Como saben que su separacion de responsabilidades es correcta?

**Respuesta recomendada:**  
Porque cada clase tiene un motivo principal para cambiar. Si cambia el guardado, toca `SistemaGuardado`; si cambia el HUD, toca `HUD`; si cambia el comportamiento del jugador, toca `Jugador` y sus estados; si cambia el puzzle, toca la clase del puzzle. Ese criterio es una forma practica de validar separacion de responsabilidades.

## 2. Preguntas dificiles sobre POO

### 2.1 Me pueden senalar un ejemplo real de encapsulamiento y no solo definirmelo?

**Respuesta recomendada:**  
Si. Un ejemplo claro es `Jugador`. Desde fuera no deberiamos reducir vida tocando la variable manualmente. Para eso existe `recibir_danio()`, que no solo resta vida, sino que activa invulnerabilidad, recoil, actualizacion del HUD y posible muerte. Eso encapsula la regla completa del dano en un solo lugar.

### 2.2 Donde exactamente esta el polimorfismo? Denme un ejemplo concreto.

**Respuesta recomendada:**  
En las jerarquias de puzzles, interactivos y enemigos. Por ejemplo, el controlador puede tratar a distintos puzzles como objetos de una misma familia porque todos heredan de `PuzzleBase` y comparten operaciones como iniciar, cerrar o resolver. Lo mismo pasa con objetos que heredan de `InteractivoBase` y con enemigos desde `EnemigoBase`.

### 2.3 No estan usando Godot como excusa para decir que hay POO cuando en realidad solo estan conectando nodos?

**Respuesta recomendada:**  
No, porque la POO no esta en el motor por si sola, sino en como organizamos nuestras clases. Godot nos da nodos y escenas, pero nosotros decidimos crear jerarquias propias, sistemas separados, estados del jugador, un servicio de guardado y un TDA propio. El motor facilita la implementacion, pero la estructura orientada a objetos la definimos nosotros.

## 3. Preguntas dificiles sobre patrones de diseno

### 3.1 Por que dicen que usan `State` y no simplemente muchos `if`?

**Respuesta recomendada:**  
Porque el comportamiento del jugador cambia delegando en objetos estado distintos, no solo evaluando banderas. Cada estado tiene su propia clase y sus metodos de entrada, procesamiento y salida. Si fuera solo un bloque de condicionales dentro de `jugador.gd`, no habria esa separacion real del comportamiento.

### 3.2 Las senales de Godot realmente cuentan como `Observer` o solo estan usando una herramienta del motor?

**Respuesta recomendada:**  
Cuentan como una implementacion practica del patron `Observer`, porque resuelven el mismo problema: un objeto emite eventos y otros observadores reaccionan sin dependencia fuerte. El hecho de que Godot lo ofrezca como mecanismo nativo no le quita valor al patron; al contrario, nos permitio aplicarlo de forma idiomatica.

### 3.3 Usaron algun patron que no este perfectamente formal?

**Respuesta recomendada:**  
Si. Ademas de `State` y `Observer`, usamos una idea de plantilla o base reutilizable en `EnemigoBase`, `PuzzleBase` e `InteractivoBase`. No siempre es una implementacion academica cerrada de `Template Method`, pero si hay una estructura comun que las subclases especializan.

## 4. Preguntas dificiles sobre el TDA

### 4.1 Por que usar una lista enlazada para los creditos no se siente un poco forzado?

**Respuesta recomendada:**  
Es una pregunta valida. La respuesta honesta es que si, no era la unica opcion posible. Pero decidimos usar ese caso porque permitia demostrar una estructura enlazada propia en un flujo secuencial claro y visible dentro del proyecto. No es un uso ficticio en el sentido de que si participa en una funcionalidad real, aunque reconocemos que no es el caso mas exigente algoritmicamente.

### 4.2 Entonces, dirian que el TDA fue una necesidad tecnica o academica?

**Respuesta recomendada:**  
Fue ambas, pero principalmente academica. Tecnica porque igual necesitabamos una secuencia de datos para creditos; academica porque queriamos cumplir el requisito no con un ejemplo aparte, sino integrado al proyecto real.

### 4.3 Si les pidieran un uso mas fuerte del TDA, donde lo pondrian?

**Respuesta recomendada:**  
Podria ampliarse para gestionar colas de mensajes, secuencias de puzzles o historiales de checkpoints. Incluso una cola o lista circular podria servir para rotar pensamientos del personaje o eventos del HUD.

## 5. Preguntas dificiles sobre guardado

### 5.1 Por que usaron `ConfigFile` y no una base de datos o un formato JSON manual?

**Respuesta recomendada:**  
Porque para el alcance del proyecto `ConfigFile` era suficiente, estable y nativo de Godot. Nos permitia guardar por secciones, leer facil, mantener slots separados y no introducir complejidad innecesaria.

### 5.2 Que pasa si cambian la estructura interna del guardado?

**Respuesta recomendada:**  
Como guardamos diccionarios por secciones y no serializamos escenas completas, tenemos margen para versionar o agregar campos sin romper todo. Igual, si el proyecto siguiera creciendo, seria recomendable introducir una version del esquema de guardado.

### 5.3 Su sistema de guardado esta realmente desacoplado?

**Respuesta recomendada:**  
Si en buena medida, porque `SistemaGuardado` no depende del HUD, del menu ni del jugador. Solo administra rutas, slots, lectura, escritura y transiciones. Los mundos son quienes le entregan el estado logico que deben persistir.

## 6. Preguntas dificiles sobre el jugador y gameplay

### 6.1 Por que el jugador no ataca?

**Respuesta recomendada:**  
Porque la propuesta del juego no buscaba centrarse en combate clasico, sino en evasion, lectura del entorno, claridad visual y resignificacion del uso de las gafas. Hacer que el personaje resolviera todo golpeando enemigos iba en contra del enfoque simbolico del proyecto.

### 6.2 No creen que eso limita la variedad jugable?

**Respuesta recomendada:**  
La limita en un sentido, pero tambien nos obliga a profundizar en otras mecanicas. En nuestro caso, esa decision dio mas peso a plataformas, puzzles, uso de gafas, checkpoints, persecucion y jefes por mecanica. Fue una limitacion deliberada, no una ausencia accidental.

### 6.3 Por que el sprint se vuelve infinito con gafas activas?

**Respuesta recomendada:**  
Porque quisimos que las gafas no fueran solo una revelacion visual, sino tambien un momento breve de empoderamiento. Eso refuerza ludicamente la idea de claridad y control. Igual esta balanceado por duracion y cooldown.

## 7. Preguntas dificiles sobre narrativa y mecanicas

### 7.1 Como conectan el bullying con el gameplay y no solo con el texto?

**Respuesta recomendada:**  
Lo conectamos de varias formas. La distorsion visual representa incomodidad y presion. Las gafas representan claridad y resignificacion. Los pensamientos internos muestran el impacto emocional. Los jefes representan amenazas simbolicas mas que enemigos literales. Y el segundo mundo convierte la presion social en una persecucion concreta.

### 7.2 Por que los puzzles representan bullying?

**Respuesta recomendada:**  
No representan literalmente el bullying como evento escolar, sino la necesidad del personaje de leer, ordenar y reinterpretar un entorno que antes sentia hostil. Es decir, los puzzles se conectan mas con la claridad mental y la reconstruccion de la percepcion que con una traduccion directa de una burla.

### 7.3 No es demasiado abstracto?

**Respuesta recomendada:**  
Si, y fue intencional. No queriamos una representacion literal y plana, sino una traduccion jugable y simbolica. La abstraccion nos permitio unir tema y mecanica sin convertir el juego en una simple escena dramatica.

## 8. Preguntas dificiles sobre shaders y parte grafica

### 8.1 Por que usan shaders si la materia es POO?

**Respuesta recomendada:**  
Porque los shaders no reemplazan la POO; la complementan. La base estructural del proyecto sigue siendo orientada a objetos. Los shaders entran como una capa extra de presentacion y accesibilidad que apoya la experiencia.

### 8.2 Que parte del proyecto si consideran extra respecto a lo ensenado?

**Respuesta recomendada:**  
Principalmente:

- shaders de distorsion,
- filtro de accesibilidad para daltonismo,
- cinematicas programadas,
- parallax y profundidad visual,
- guardado por slots,
- audio sintetico,
- sistema de opciones mas completo.

### 8.3 Entonces hasta donde llega la responsabilidad del curso y hasta donde la iniciativa de ustedes?

**Respuesta recomendada:**  
La base del curso se ve en el diseno orientado a objetos, estructuras, sistemas y patrones. La iniciativa nuestra fue llevar eso a una experiencia mas pulida, con capas visuales, narrativas y de accesibilidad mas avanzadas.

## 9. Preguntas dificiles sobre la accesibilidad

### 9.1 Por que agregaron opcion para daltonismo?

**Respuesta recomendada:**  
Porque el proyecto gira alrededor de la percepcion visual. Incluir accesibilidad tenia mucho sentido tematico y tambien tecnico, porque nos permitia pensar en como distintas personas leen el mismo mundo.

### 9.2 Como defenderian tecnicamente esa implementacion?

**Respuesta recomendada:**  
La implementamos como un filtro de postprocesado sobre toda la pantalla usando un `ColorRect` con `ShaderMaterial`. El shader toma la imagen renderizada y aplica correcciones de color segun el modo seleccionado.

### 9.3 Eso fue investigacion de ustedes o algo ya dado por Godot?

**Respuesta recomendada:**  
Godot nos dio la base tecnica para hacerlo con shaders, pero la logica de accesibilidad y la adaptacion al juego la implementamos nosotros. No es una casilla magica del motor.

## 10. Preguntas dificiles sobre la calidad del codigo

### 10.1 Cual creen que es el punto mas fuerte del codigo?

**Respuesta recomendada:**  
La organizacion por sistemas y la reutilizacion mediante clases base. Eso nos permitio crecer el proyecto sin que cada nueva mecanica significara rehacerlo todo.

### 10.2 Cual creen que es la parte mas debil o mas mejorable?

**Respuesta recomendada:**  
Los controladores de mundo todavia concentran bastante coordinacion, asi que una mejora natural seria seguir separando logica en subcoordinadores o servicios por dominio, por ejemplo puertas, checkpoints o progresion.

### 10.3 Que error de diseno evitarian si empezaran de cero?

**Respuesta recomendada:**  
Definiriamos desde mas temprano una capa comun para mundos y una estrategia mas formal de datos persistentes. Eso habria reducido retrabajo a medida que el juego crecio.

## 11. Preguntas dificiles sobre alcance

### 11.1 No intentaron hacer demasiadas cosas para una materia?

**Respuesta recomendada:**  
Si nos arriesgamos bastante en alcance, pero fuimos consolidando primero una base funcional y luego capas de pulido. La prioridad fue dejar una arquitectura defendible, no solo una suma de efectos.

### 11.2 Si tuvieran que recortar el proyecto para quedarse con el nucleo, que dejaban?

**Respuesta recomendada:**  
Dejariamos:

- jugador con estados,
- sistema de gafas,
- mundo 1 con checkpoints,
- un puzzle,
- un jefe por mecanica,
- HUD,
- guardado,
- TDA en creditos.

Eso seguiria siendo una version representativa del proyecto.

## 12. Preguntas dificiles sobre decisiones simbolicas

### 12.1 Por que el mundo 2 es una persecucion?

**Respuesta recomendada:**  
Porque queriamos representar la sensacion de presion constante, de no tener descanso, como si las burlas siguieran empujando al personaje incluso cuando intenta escapar. La persecucion es una traduccion mecanica de eso.

### 12.2 Por que el jefe final no es un personaje humano?

**Respuesta recomendada:**  
Porque preferimos representar el efecto de la presion y la agresion como una fuerza simbolica. Eso evita reducir el conflicto a una persona mala y lo lleva a una dimension mas emocional y mental.

## 13. Preguntas dificiles con trampa academica

### 13.1 Entonces su juego es mas narrativo que orientado a objetos?

**Respuesta recomendada:**  
No. La narrativa es la capa tematica. La construccion tecnica sigue siendo orientada a objetos: clases, jerarquias, composicion, estados, senales como observer, TDA propio y sistemas separados.

### 13.2 No creen que usar tantas herramientas del motor les quita merito?

**Respuesta recomendada:**  
No, porque una buena ingenieria tambien consiste en usar bien el framework o motor disponible. El merito no esta en ignorar Godot, sino en organizar nuestras propias abstracciones sobre el motor.

### 13.3 Si no existieran las senales de Godot, como habrian implementado la comunicacion?

**Respuesta recomendada:**  
Podriamos haber usado observadores manuales, callbacks registrados o una capa de eventos propia. Las senales simplifican una necesidad de arquitectura que de todos modos existia.

## 14. Preguntas para cerrar con fuerza

### 14.1 Que demuestra este proyecto sobre ustedes como equipo?

**Respuesta recomendada:**  
Demuestra que no solo pudimos programar un juego funcional, sino estructurarlo como un sistema orientado a objetos, integrar narrativa y mecanicas, y sostener decisiones tecnicas con una justificacion clara.

### 14.2 Cual es la idea mas importante que quieren que quede del proyecto?

**Respuesta recomendada:**  
Que no hicimos solo un juego que anda, sino una propuesta donde la arquitectura del codigo, la jugabilidad y el mensaje narrativo intentan ir en la misma direccion.

## 15. Como practicar este simulacro

Les recomiendo ensayarlo asi:

1. Una persona hace de profesor.
2. Otra responde sin leer.
3. Luego comparan con esta guia.
4. Cambian roles.

Tambien les sirve hacer dos rondas:

- ronda 1: respuestas de 20 segundos,
- ronda 2: respuestas de 1 minuto con ampliacion.

## 16. Siguiente paso util

Si quieren, ahora les puedo preparar una de estas dos:

- una chuleta express de una pagina con solo ideas clave para repasar antes de entrar,
- o un simulacro oral por roles, diciendo que le tocaria responder a cada integrante segun su parte.
