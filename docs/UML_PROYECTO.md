# UML actualizado para Deep Shadow

Este UML representa la estructura actual del proyecto en Godot. La idea principal es separar la coordinacion de cada mundo, las entidades jugables, los sistemas auxiliares y la interfaz. Aunque Godot trabaja con escenas y nodos, el diagrama se centra en las clases propias del proyecto y en sus responsabilidades dentro de Programacion Orientada a Objetos.

## Diagrama de clases

```mermaid
classDiagram
direction LR

class MainGame {
  <<Controlador Mundo 1>>
  -jugador: Jugador
  -hud: HUD
  -menu_pausa: MenuPausa
  -jefe_sombras: JefeSombras
  -puzzle_gafas_superado: bool
  -mundo_2_desbloqueado: bool
  +reiniciar_nivel(): void
  +alternar_pausa(): void
  +volver_al_menu(): void
  -_guardar_progreso_actual(): void
  -_cargar_progreso_guardado(): void
}

class Mundo2 {
  <<Controlador Mundo 2>>
  -jugador: Jugador
  -hud: HUD
  -muro_carne: MuroCarne
  -checkpoint_activo: bool
  -escape_muro_completado: bool
  +reiniciar_nivel(): void
  +alternar_pausa(): void
  -_guardar_progreso(): void
  -_cargar_guardado_mundo_2(): void
  -_reiniciar_carrera(): void
}

class Menu {
  <<Controlador UI>>
  +nueva_partida(slot: int): void
  +cargar_partida(slot: int): void
  +eliminar_partida(slot: int): void
  +abrir_creditos(): void
}

class SistemaGuardado {
  <<Servicio>>
  -slot_activo: int
  -transicion_pendiente: Dictionary
  +establecer_slot_activo(slot: int): void
  +existe_guardado(slot: int): bool
  +cargar_datos(slot: int): Dictionary
  +guardar_estado_main_game(datos: Dictionary): void
  +guardar_estado_mundo_2(datos: Dictionary): void
  +borrar_guardado_slot(slot: int): void
  +preparar_transicion_escena(escena: String, entrada: String): void
}

class Jugador {
  <<Entidad>>
  -vida: int
  -velocidad_base: float
  -fuerza_salto: float
  -estado: EstadoJugadorBase
  -sistema_estamina: SistemaEstamina
  -habilidad_gafas: HabilidadGafas
  +recibir_danio(cantidad: int, direccion: float): void
  +restaurar_para_respawn(posicion: Vector2): void
  +establecer_control_habilitado(activo: bool): void
  +gafas_activas(): bool
}

class SistemaEstamina {
  <<Modelo>>
  +actual: float
  +maxima: float
  +consumir(cantidad: float): bool
  +regenerar(cantidad: float): void
  +reiniciar(): void
}

class HabilidadGafas {
  <<Modelo>>
  -activa: bool
  -duracion_restante: float
  -cooldown_actual: float
  +intentar_activar(): bool
  +actualizar(delta: float): void
  +esta_activa(): bool
}

class EstadoJugadorBase {
  <<State>>
  +entrar(jugador: Jugador): void
  +actualizar(jugador: Jugador, delta: float): void
  +salir(jugador: Jugador): void
}

class EstadoJugadorNormal
class EstadoJugadorSprint
class EstadoJugadorAturdido
class EstadoJugadorBloqueado

class HUD {
  <<Vista>>
  +configurar_jugador(jugador: Jugador): void
  +actualizar_estamina(actual: float, maxima: float): void
  +actualizar_vida(vida: int): void
  +mostrar_mensaje(texto: String): void
  +mostrar_pensamiento(texto: String): void
}

class MenuPausa {
  <<Vista>>
  +abrir(tiene_checkpoint: bool, descripcion: String): void
  +cerrar(): void
  +establecer_modo_carrera(activo: bool): void
}

class CutsceneBase {
  <<Vista Narrativa>>
  +reproducir_intro_inicio(): void
  +reproducir_objetivos_mundo_1(): void
  +reproducir_transicion_mundo_2(): void
  +reproducir_pantalla_final_creditos(): void
  -_crear_creditos_tda(): ListaSimple
}

class ListaSimple {
  <<TDA>>
  -cabeza: NodoLista
  -cola: NodoLista
  -tamano: int
  +esta_vacia(): bool
  +obtener_tamano(): int
  +insertar_final(valor: Variant): void
  +para_cada(callback: Callable): void
}

class NodoLista {
  <<Nodo>>
  +valor: Variant
  +siguiente: NodoLista
}

class InteractivoBase {
  <<Abstracta>>
  -jugador_en_rango: bool
  +interactuar(): void
  +esta_en_rango(): bool
}

class PuertaTeletransporte {
  +configurar_destino(destino: Node2D): void
  +abrir(silencioso: bool): void
  +establecer_transporte_habilitado(activo: bool): void
}

class PuertaBloqueada {
  +desbloquear(): void
}

class LlaveInteractiva {
  +otorgar_llave(): void
}

class AltarGafas {
  +marcar_resuelto(): void
}

class NPCDialogo {
  +iniciar_dialogo(): void
}

class TotemJefe {
  -activado: bool
  +activar(): void
  +reiniciar_totem(): void
}

class CheckpointActivador {
  <<Area>>
  +checkpoint_alcanzado(posicion: Vector2, mensaje: String)
}

class PuzzleBase {
  <<Abstracta>>
  +abrir(): void
  +cerrar(): void
  +resolver(): void
}

class PuzzleSecuencia
class PuzzleMatematicas
class PuzzleGafas

class EnemigoBase {
  <<Abstracta>>
  -vida: int
  -velocidad_base: float
  -danio_contacto: int
  +reiniciar_enemigo(): void
  +establecer_congelado(activo: bool): void
  +establecer_multiplicador_velocidad(valor: float): void
}

class EnemigoPatrulla
class EnemigoPerseguidor
class EnemigoFlotanteBase
class EnemigoFlotanteVertical
class EnemigoFlotanteHorizontal

class JefeSombras {
  -fase_actual: int
  -sellos_activados: int
  +registrar_sello_activado(): void
  +establecer_activo_en_arena(activo: bool): void
  +esta_derrotado(): bool
}

class MuroCarne {
  <<Jefe Mundo 2>>
  -velocidad_base: float
  -objetivo: Jugador
  +configurar_objetivo(jugador: Jugador): void
  +reiniciar(posicion: Vector2): void
  +establecer_congelado(activo: bool): void
}

class PlataformaGafas {
  +establecer_revelada(activa: bool): void
}

class FondoMundo1 {
  +parallax_activo: bool
}

class FondoMundoFinal {
  +parallax_activo: bool
}

MainGame --> Jugador
MainGame --> HUD
MainGame --> MenuPausa
MainGame --> SistemaGuardado
MainGame --> JefeSombras
MainGame --> PuzzleBase
MainGame --> CheckpointActivador
MainGame --> InteractivoBase

Mundo2 --> Jugador
Mundo2 --> HUD
Mundo2 --> MenuPausa
Mundo2 --> SistemaGuardado
Mundo2 --> MuroCarne
Mundo2 --> TotemJefe
Mundo2 --> CheckpointActivador
Mundo2 --> FondoMundoFinal

Menu --> SistemaGuardado
PuertaTeletransporte --> SistemaGuardado

Jugador *-- SistemaEstamina
Jugador *-- HabilidadGafas
Jugador --> EstadoJugadorBase

EstadoJugadorBase <|-- EstadoJugadorNormal
EstadoJugadorBase <|-- EstadoJugadorSprint
EstadoJugadorBase <|-- EstadoJugadorAturdido
EstadoJugadorBase <|-- EstadoJugadorBloqueado

HUD ..> Jugador : observa senales
MenuPausa ..> MainGame : senales UI
MenuPausa ..> Mundo2 : senales UI

CutsceneBase --> ListaSimple
ListaSimple *-- NodoLista

InteractivoBase <|-- PuertaTeletransporte
PuertaTeletransporte <|-- PuertaBloqueada
InteractivoBase <|-- LlaveInteractiva
InteractivoBase <|-- AltarGafas
InteractivoBase <|-- NPCDialogo
InteractivoBase <|-- TotemJefe

PuzzleBase <|-- PuzzleSecuencia
PuzzleBase <|-- PuzzleMatematicas
PuzzleBase <|-- PuzzleGafas

EnemigoBase <|-- EnemigoPatrulla
EnemigoBase <|-- EnemigoPerseguidor
EnemigoBase <|-- EnemigoFlotanteBase
EnemigoBase <|-- JefeSombras
EnemigoFlotanteBase <|-- EnemigoFlotanteVertical
EnemigoFlotanteBase <|-- EnemigoFlotanteHorizontal

MainGame --> FondoMundo1
Jugador ..> PlataformaGafas : revela con gafas
```

## Patrones y enfoque POO

- `State`: el jugador delega su comportamiento a `EstadoJugadorNormal`, `EstadoJugadorSprint`, `EstadoJugadorAturdido` y `EstadoJugadorBloqueado`, evitando que toda la logica de movimiento quede concentrada en una sola clase.
- `Observer`: se usa por medio de senales de Godot. Por ejemplo, `Jugador` emite cambios de vida, estamina, sprint y gafas; `HUD` escucha esas senales y actualiza la interfaz sin depender de consultas constantes.
- Herencia y polimorfismo: `EnemigoBase`, `PuzzleBase` e `InteractivoBase` son bases comunes para enemigos, puzzles y objetos interactivos. Esto permite agregar variantes sin reescribir los controladores principales.
- Separacion de responsabilidades: `MainGame` y `Mundo2` coordinan el flujo de cada mundo, mientras que `Jugador`, `SistemaEstamina`, `HabilidadGafas`, `SistemaGuardado`, puzzles y enemigos mantienen reglas especificas.

## Uso del TDA Lista Simple

El TDA implementado es `ListaSimple`, una lista enlazada simple creada con nodos propios (`NodoLista`) y referencias `cabeza`, `cola` y `siguiente`. No se usa un `Array` para almacenar los creditos: cada credito se inserta al final con `insertar_final(valor)` y luego se recorre con `para_cada(callback)`. Actualmente se usa en `CutsceneBase`, dentro de `_crear_creditos_tda()`, para construir la secuencia de creditos del juego y renderizar cada fila mediante un callback. Esto permite demostrar una estructura de datos propia, encapsulada y reutilizable.

## Sistema de guardado

El sistema de guardado esta centralizado en `SistemaGuardado`, que maneja tres slots usando archivos `ConfigFile` en `user://deep_shadow_save_slot_%d.cfg`. El menu selecciona, carga o elimina slots; `MainGame` guarda el progreso del mundo 1 y `Mundo2` guarda el progreso de la persecucion, checkpoints, puzzles y posicion de respawn. Al iniciar una escena, cada controlador consulta `SistemaGuardado.cargar_datos()` y reconstruye el estado necesario; para pasar del mundo 1 al mundo 2 se usa una transicion pendiente que indica la escena destino y el punto de entrada.

## Clases principales por archivo

- `Scripts/main_game.gd`: controlador del mundo 1, puertas, jefe, puzzles, checkpoints, HUD, guardado y camaras.
- `Scripts/mundo_2.gd`: controlador del mundo 2, persecucion del muro, checkpoints, puzzle final, camara y guardado.
- `Scripts/jugador.gd`: entidad principal del jugador, movimiento, vida, estamina, gafas, estados y animaciones.
- `Scripts/sistema_guardado.gd`: servicio de persistencia por slots y transiciones.
- `Scripts/tda_lista_simple.gd`: TDA de lista enlazada simple usado en creditos.
- `Scripts/enemigo_base.gd`, `Scripts/jefe_sombras.gd`, `Scripts/muro_carne.gd`: jerarquia de enemigos y jefes.
- `Scripts/puzzle_base.gd`, `Scripts/puzzle_secuencia.gd`, `Scripts/puzzle_matematicas.gd`, `Scripts/puzzle_gafas.gd`: jerarquia de puzzles.
- `Scripts/interactivo_base.gd`, `Scripts/puerta_teletransporte.gd`, `Scripts/puerta_bloqueada.gd`: base de interacciones y puertas.
