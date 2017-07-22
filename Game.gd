extends Node


var lib = preload("batiment.gd")

var grilleX = 14
var grilleY= 7
var grilleSize=64
var itSelection
var joueur=null
var adversaire=null
var gestionTexture
var idxSelection=1
var selection
var croixTexture
var cibleRadarTexture
var okTexture
var pauseTexture
var selectSprite=preload("select.png")
var chiffresTextureA=[]
var chiffresTextureB=[]
var chiffresTextureC=[]
var carreVertTexture
var carreBleueTexture
var nombre1=[]
var parametrage=load("parametrage.gd")
var lstSprite=[]
var ordreAmeliorationsSprite= []
var ordreAmeliorationsFaiteSprite= []
var ordreAttaqueLanceMissileAvecRadarSprite=[]
var ordreAttaqueLanceMissileSansRadarSprite=[]
func afficherNombre1( n ) :
	var s=str(n)
	var u=0
	for s in nombre1:
		s.hide()
		#s.queue_free()
	
	for c in s:
		var idx= int(c) 
		var r = Vector2(u*grilleSize+grilleSize/2,2*grilleY*grilleSize+grilleSize/2)
		if (u >= nombre1.size()):
			var sprite = Sprite.new()
			nombre1.push_back(sprite)
			add_child(sprite)
		var sprite = nombre1[u]
		sprite.set_texture(chiffresTextureC[idx])
		sprite.set_pos(r)
		sprite.set_scale(ajusterTexture(0,0,chiffresTextureC[idx]))
		sprite.show()
		u+=1
		
		


func orientationAngle(orientation):
		if (orientation.y < 0):
			return acos(orientation.x)
		else:
			return -acos(orientation.x)
			
func ajusterTexture(dx,dy,tx):
	var ts = tx.get_size()
	var scaleX =(grilleSize-dx)/ ts.x
	var scaleY =(grilleSize-dy)/ ts.y
	return Vector2(scaleX,scaleY)
func initSelectionPos():
	selection.set_pos(Vector2(grilleX*grilleSize+grilleSize/2,idxSelection*grilleSize+grilleSize/2))
func _input(ev):
	if (ev.type==InputEvent.MOUSE_BUTTON  && ev.is_pressed() ):

		var ix=int(ev.x/grilleSize)
		var iy=int(ev.y/grilleSize)
		if (ix ==grilleX):
			if (iy >= gestionTexture.nomBatiments.size()+1 || iy ==0):
				return
			idxSelection = iy
			initSelectionPos()
			return
		if (ix ==grilleX+2):
			if (iy >= gestionTexture.nomBatiments.size()+1 || iy ==0):
				return
			var nomBatiment =gestionTexture.nomBatiments[idxSelection-1]

			joueur.ajouterOrdreAttaqueAvecRadar(nomBatiment,iy-1)
			return
		if (ix ==grilleX+1):
			if (iy >= gestionTexture.nomBatiments.size()+1 || iy ==0):
				return
			var nomBatiment =gestionTexture.nomBatiments[idxSelection-1]
			joueur.ajouterOrdreAttaqueSansRadar(nomBatiment,iy-1)
			return
		if (iy >= grilleY):
			return
		if (ix ==grilleX+3):
			if (iy >= gestionTexture.nomBatimentAvecAmelioration.size()+1 || iy ==0):
				return
			var nomBatiment =gestionTexture.nomBatimentAvecAmelioration[iy-1]
			
			if (joueur.ameliorations.find(nomBatiment)>=0):
				return
			nomBatiment =gestionTexture.nomBatiments[idxSelection-1]
			if (joueur.ameliorations.find(nomBatiment)>=0):
				return
			var oldIdx=joueur.ordreAmeliorations.find(nomBatiment)
			if (oldIdx< 0):
				return
			var oldNomBatiment =joueur.ordreAmeliorations[iy-1]
			joueur.ordreAmeliorations[iy-1]=nomBatiment
			joueur.ordreAmeliorations[oldIdx]=oldNomBatiment
			gestionTexture.modifierOrdreAttaque(self,joueur.ordreAmeliorations,ordreAmeliorationsSprite,(grilleX+3)*grilleSize)


			return
		if (iy >= grilleY):
			return
		var nomBatiment = gestionTexture.nomBatiments[idxSelection-1];

		joueur.ajouterConstruire(self,ix,iy,nomBatiment)


func _ready():
	initialiserTextures()
	OS.set_window_size(Vector2((4+grilleX)*grilleSize,(2*grilleY+1)*grilleSize))

  
func initialiserTextures():
	#selectSprite=ImageTexture.new()
	#selectSprite.load("select.png")
	itSelection =load("carreSelection.png")
	gestionTexture=lib.GestionTextures.new()
	gestionTexture.chargerImageTextures()
	croixTexture =load("croix.png")
	carreVertTexture=load("carreVert.png")
	carreBleueTexture =load("carreBleue.png")
	okTexture = load("ok.png")
	
	for i in range(10):
		var tx =load("chiffres/A"+str(i)+".png")
		chiffresTextureA.push_back(tx)
	for i in range(10):
		var tx = load("chiffres/B"+str(i)+".png")
		chiffresTextureB.push_back(tx)
	for i in range(10):
		var tx =load("chiffres/C"+str(i)+".png")
		chiffresTextureC.push_back(tx)
	cibleRadarTexture=load("cibleLanceMissile.png")
	pauseTexture=load("pause.png")
	
func demarer(nouveau):
	get_parent().get_node("Loose").hide()
	get_parent().get_node("Win").hide()
	if (joueur==null):
		selection = Sprite.new()
		selection.set_texture(itSelection)

		selection.set_scale(ajusterTexture(0,0,itSelection))
		selection.set_z(2)
		initSelectionPos()
		var selectTitre = Sprite.new()
		selectTitre.set_texture(selectSprite)
		selectTitre.set_scale(ajusterTexture(0,0,selectSprite))
		selectTitre.set_pos(Vector2(grilleX*grilleSize+grilleSize/2,grilleSize/2))
		add_child(selectTitre)
		add_child(selection)
		var selectLabo = Sprite.new()
		var txLabo = gestionTexture.imageTextures["Laboratoire"]
		selectLabo.set_texture(txLabo)
		selectLabo.set_scale(ajusterTexture(0,0,txLabo))
		selectLabo.set_pos(Vector2((grilleX+3)*grilleSize+grilleSize/2,grilleSize/2))
		add_child(selectLabo)
		gestionTexture.ajouterChoixBatiment(self,grilleX*grilleSize,grilleSize)
		
		joueur=load("joueur.gd").new()
		adversaire=load("joueur.gd").new()
		joueur.initialiserGrille(self,false,grilleX,grilleY,grilleSize)
		adversaire.initialiserGrille(self,true,grilleX,grilleY,grilleSize)
		gestionTexture.donnerOrdreAttaque(self,"LanceMissileSansRadar",ordreAttaqueLanceMissileSansRadarSprite,(grilleX+1)*grilleSize,carreBleueTexture)
		gestionTexture.donnerOrdreAttaque(self,"LanceMissileAvecRadar",ordreAttaqueLanceMissileAvecRadarSprite,(grilleX+2)*grilleSize,carreVertTexture)
		gestionTexture.ajouterChoixAmelioration(joueur,self,(grilleX+3)*grilleSize,grilleSize,joueur.ordreAmeliorations,ordreAmeliorationsSprite)

		joueur.adversaire = adversaire
		adversaire.adversaire = joueur
		joueur.initOrdreAttaque(self)
		adversaire.initOrdreAttaque(self)
		adversaire.estAdversaire = true
		joueur.estAdversaire = false
		if (!nouveau):
			joueur.charger()
			adversaire.charger()
	

	
		
		joueur.nomJoueur("joueur")
		adversaire.nomJoueur("adversaire")

		set_process(true)
		set_process_input(true)
		return
	set_process(true)
	set_process_input(true)
	get_parent().get_node("demarer").hide()
	get_node("sortir").show()
	for sprite in lstSprite:
		sprite.show()


func _process(delta):
	if (joueur.executer(self)):
		get_parent().get_node("Win").show()
		get_parent().get_node("demarer").show()
		for spriteOk in ordreAmeliorationsFaiteSprite:
			spriteOk.hide()
		lstSprite=[]
		joueur.raz()
		adversaire.raz()
		addVisible(self)
		print(" nombre visible=",lstSprite.size())
		set_process(false)
		set_process_input(false)
		var tmp=adversaire
		adversaire=joueur
		joueur=tmp
		adversaire.estAdversaire=true
		joueur.estAdversaire=false
		joueur.sauvegarder()
		adversaire.sauvegarder()
		return
		
	afficherNombre1(joueur.energie)
	if (adversaire.executer(self)):
		get_parent().get_node("Loose").show()
		get_parent().get_node("demarer").show()
		lstSprite=[]
		joueur.raz()
		adversaire.raz()
		addVisible(self)

		set_process(false)
		set_process_input(false)

		


func _on_demarer_pressed():

	get_parent().get_node("demarer").hide()
	get_parent().get_node("nouveau").hide()
	demarer(false)

	var nd=get_node("sortir")
	nd.show()
	var sz=nd.get_size()
	
	var scaleX =(grilleSize)/ sz.x
	var scaleY =(grilleSize)/ sz.y
	print("scaleX=",scaleX," scaleY=",scaleY)
	nd.set_scale(Vector2(scaleX,scaleY))
	var ix=grilleX
	var iy=2*grilleY
	nd.set_pos(Vector2(grilleSize*ix,iy*grilleSize))
	
func is_visible(node):
	for child in node.get_children():
		
		if (child.get_type() != "Node"):
			if (is_visible(node)):
				return true
		else:
			if (child.is_visible()):
				return true
				
func hide( node ):
	for child in node.get_children():
		
		if (child.get_type() != "Node"):
			child.hide()
		else:
			hide(child)

func show(node):
	for child in node.get_children():
		
		if (child.get_type() != "Node"):
			child.show()
		else:
			show(child)
			
func addVisible(node):
	for child in node.get_children():
		if (child.get_type() != "Node" && child.is_visible()):
			lstSprite.push_back(child)
			child.hide()
		else:
			addVisible(child)
	


func _on_sortir_pressed():
	get_parent().get_node("demarer").show()
	joueur.sauvegarder()
	adversaire.sauvegarder()
	lstSprite=[]
	addVisible(self)
	set_process(false)
	set_process_input(false)


func _on_nouveau_pressed():
	get_parent().get_node("demarer").hide()
	get_parent().get_node("nouveau").hide()
	demarer(true)

	var nd=get_node("sortir")
	nd.show()
	var sz=nd.get_size()
	
	var scaleX =(grilleSize)/ sz.x
	var scaleY =(grilleSize)/ sz.y
	print("scaleX=",scaleX," scaleY=",scaleY)
	nd.set_scale(Vector2(scaleX,scaleY))
	var ix=grilleX
	var iy=2*grilleY
	nd.set_pos(Vector2(grilleSize*ix,iy*grilleSize))
