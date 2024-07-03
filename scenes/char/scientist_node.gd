class_name ScientistNode
extends ClassNode

var player: Player
var ScientistPassive: PanelContainer
var TempLabel : Label
var TempColor : ColorRect
var PurifyOverlay : PanelContainer

var ColorDict : Dictionary = {
	"0": Color8(170,200,250,255),
	"1": Color8(70,125,230,255),
	"2": Color8(130,160,140,255),
	"3": Color8(250,170,50,255),
	"4": Color8(250,160,60,255),
	"5": Color8(250,145,70,255),
	"6": Color8(255,125,75,255),
	"7": Color8(255,105,75,255),
	"8": Color8(255,85,70,255),
	"9": Color8(255,65,65,255),
}

var ActualTemp : String = "0"

func _ready():
	player = get_parent()
	ScientistPassive = player.get_ScientistPassive()
	TempColor = ScientistPassive.get_child(0)
	TempLabel = ScientistPassive.get_child(1)
	PurifyOverlay = player.get_PurifyOverlay()

func _process(delta):
	var Temp : String = str(player.test())
	if Temp != ActualTemp:
		ActualTemp = Temp
		update_temp(Temp)

func update_temp(temp : String):
	TempLabel.text = temp + "°T"
	TempColor.set_color(ColorDict[temp])

func ability():
	#activar ovelay
	PurifyOverlay.visible = true
	Player.purify = true
	#trakear mouse
	
	#al hacer click verificar el bloque
	
	#cambiar atlas si es posible
	
	#dejar de trakear mouse
	
	#desactivar overlay
	
	pass
