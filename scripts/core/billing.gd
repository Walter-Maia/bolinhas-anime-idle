extends Node
## Camada de compras (autoload "Billing").
##
## No Android com o plugin oficial "GodotGooglePlayBilling" (https://github.com/godot-sdk-integrations/godot-google-play-billing)
## a compra real e feita pela Google Play. Fora disso (editor/PC) roda em MODO TESTE: a compra e simulada
## para voce testar o fluxo sem cobrar ninguem.
##
## Para publicar: crie os produtos com os mesmos ids de DB.IAP no Google Play Console, instale o plugin,
## habilite-o no preset de exportacao Android e VALIDE os recibos num servidor seu antes de entregar as gemas.

signal purchase_finished(product_id: String, ok: bool, result: Dictionary)

var _store: Object = null
var test_mode := true


func _ready() -> void:
	if Engine.has_singleton("GodotGooglePlayBilling"):
		_store = Engine.get_singleton("GodotGooglePlayBilling")
		test_mode = false
		if _store.has_signal("purchases_updated"):
			_store.connect("purchases_updated", _on_purchases_updated)
		if _store.has_method("startConnection"):
			_store.startConnection()


func purchase(product_id: String) -> void:
	if test_mode or _store == null:
		# simulacao: entrega depois de um pequeno atraso
		await get_tree().create_timer(0.6).timeout
		var res := Game.grant_iap(product_id)
		purchase_finished.emit(product_id, not res.is_empty(), res)
		return
	_store.purchase(product_id)


func _on_purchases_updated(purchases: Array) -> void:
	for p in purchases:
		var ids: Array = p.get("products", [p.get("sku", "")])
		for id in ids:
			# TODO producao: enviar p.purchase_token ao seu backend para validar antes de entregar
			var res := Game.grant_iap(str(id))
			if _store.has_method("consumePurchase"):
				_store.consumePurchase(p.get("purchase_token", ""))
			purchase_finished.emit(str(id), true, res)
