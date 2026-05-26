extends RefCounted
class_name ListaSimple

class NodoLista:
	var valor: Variant
	var siguiente: NodoLista = null

	func _init(valor_inicial: Variant) -> void:
		valor = valor_inicial


var _cabeza: NodoLista = null
var _cola: NodoLista = null
var _tamano: int = 0


func esta_vacia() -> bool:
	return _tamano == 0


func obtener_tamano() -> int:
	return _tamano


func insertar_final(valor: Variant) -> void:
	var nodo := NodoLista.new(valor)
	if _cabeza == null:
		_cabeza = nodo
		_cola = nodo
	else:
		_cola.siguiente = nodo
		_cola = nodo
	_tamano += 1


func para_cada(callback: Callable) -> void:
	var actual := _cabeza
	var indice := 0
	while actual != null:
		callback.call(actual.valor, indice)
		actual = actual.siguiente
		indice += 1
