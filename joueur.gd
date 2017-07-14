extends Object

var energie=250
var estAdversaire = false
var imageTexture
var nombreMerveille=0
var nomJoueur=""
var nombreDeRadar=0
var listeConstructeur=[]
var batEnCoursDeConstruction=null
var ordreAttaqueLanceMissileAvecRadar=[]
var ordreAttaqueLanceMissileSansRadar=[]
var ameliorations= []
var ordreAmeliorations= []
var idxOrdreAmelioration=0
var listeLaboratoireDisponible=[]
var listeLanceMissileSansRadarDisponnible=[]
var listeLanceMissileSansRadarEnDeplacement=[]
var grille= {}
var grilleInactif = {}
var grilleProtege = {}
var grilleCompteur= {}
var grilleRadar = {}
var grillePause= {}
var grillePauseBat= {}
var grilleBatiment= {}
var grilleRecharge={}
var grilleAttente={}
var actions=[]
var periodeEnergie=0
var idxAction=0
var batiment = preload("batiment.gd")
var action = preload("action.gd")
var parametrage=load("parametrage.gd").new()
var adversaire
func raz():
	grille={}
	listeLaboratoireDisponible=[]
	listeLanceMissileSansRadarDisponnible=[]
	idxAction=0
	idxOrdreAmelioration=0
	energie=250
	ameliorations=[]
	nombreMerveille=0
	nombreDeRadar=0
	for sp in grilleRadar.values():
		sp.hide()
	for sp in grillePause.values():
		sp.hide()
	for sp in grillePauseBat.values():
		sp.hide()
	for sp in grilleRadar.values():
		sp.hide()
	for sp in grilleBatiment.values():
		sp.hide()
	for sp in grilleAttente.values():
		sp.hide()
	for sp in grilleProtege.values():
		sp.hide()
	for sp in grilleInactif.values():
		sp.hide()
	for sp in grilleRecharge.values():
		sp.hide()
	for sp in grilleCompteur.values():
		sp.hide()
func sauvegarder( ):
	var savegame = File.new()
	if (estAdversaire):
    	savegame.open("user://adversaire.save", File.WRITE)
	else:
		savegame.open("user://joueur.save", File.WRITE)
	var dataActions=[]
	for a in actions:
		dataActions.push_back(a.saveData())
	var data = { actions=dataActions,ordreAmeliorations=ordreAmeliorations}
	savegame.store_line(data.to_json())
	savegame.close()
func charger():
	var savegame = File.new()
	if (estAdversaire):
    	savegame.open("user://adversaire.save", File.READ)
	else:
		savegame.open("user://joueur.save", File.READ)
	var data = {}
	data.parse_json(savegame.get_line())
	ordreAmeliorations = data.ordreAmeliorations
	actions=[]
	for a in data.actions:
		if (a.type=="C"):
			var actionC= action.Construire.new()
			actionC.x=a.x
			actionC.y=a.y
			actionC.nomBatiment=a.nomBatiment
			actions.push_back(actionC)
		if (a.type=="OAAR"):
			var actionOA=action.OrdreAttaqueAvecRadar.new()
			actionOA.nomBatiment=a.nomBatiment
			actionOA.priorite = a.priorite
			actions.push_back(actionOA)
		if (a.type=="OASR"):
			var actionOA=action.OrdreAttaqueSansRadar.new()
			actionOA.nomBatiment=a.nomBatiment
			actionOA.priorite = a.priorite
			actions.push_back(actionOA)
	print(" data=",data)
func nomJoueur( nom ):
	nomJoueur = nom
func afficher():
	print(" joueur=",nomJoueur)
func batimentsParType():
	var r= {}
	for bat in grille.values():
		var nomBatiment = bat.afficherNom()
		if (r.has(nomBatiment)):
			r[nomBatiment].push_back(bat)
		else:
			r[nomBatiment]=[bat]
	return r


func contient(ix,iy):
	var clef = " " +str(ix)+"_"+str(iy)
	
	return grille.has(clef)
func donnerBatiment(ix,iy):
	var clef = " " +str(ix)+"_"+str(iy)
	return grille[clef]
func position(x,y,game):
	if (game.adversaire == self):
		y=2*game.grilleY-y-1

	var r = Vector2(x*game.grilleSize+game.grilleSize/2,y*game.grilleSize+game.grilleSize/2)
	return r

func gererLanceMissileSansRadar():
	var bats =adversaire.batimentsParType()
	for nomBatiment in ordreAttaqueLanceMissileSansRadar:
		if (bats.has(nomBatiment)):
			var cibles = bats[nomBatiment]
			if (cibles.size() > 0):
				var idx=0
				for lanceMissile in listeLanceMissileSansRadarDisponnible:
					
					var bat=cibles[idx]
					lanceMissile.dirigerVers(grille[lanceMissile.clef()],adversaire.grille[bat.clef()].get_pos(),bat)
					idx=idx+1
					if (idx == cibles.size()):
						idx=0
				listeLanceMissileSansRadarEnDeplacement=listeLanceMissileSansRadarDisponnible
				listeLanceMissileSansRadarDisponnible=[]
				return
	
	

func creerBatiment(game,ix,iy,nomBatiment):
	var bat = game.lib[nomBatiment].new()
	bat.init(self)
	var clef = " " +str(ix)+"_"+str(iy)
	var spriteBatiment = donnerSprite(game,clef,grilleBatiment)

	bat.x=ix
	bat.y=iy
	bat.vie = parametrage[nomBatiment].vie
	bat.dureeCompteur = parametrage[nomBatiment].dureeCompteur

	grille[clef]=bat
	creerSpriteCompteur(game,bat,game.chiffresTextureA)
	var tx =game.gestionTexture.imageTextures[nomBatiment]
	var pos=position(ix,iy,game)
	var sprite =spriteBatiment
	sprite.set_texture(tx)
	sprite.set_pos(pos)
	sprite.set_scale(game.ajusterTexture(10,10,tx))
	sprite.show()
	var spritePause = donnerSprite(game,clef,grillePause)
	var spritePauseBat = donnerSprite(game,clef,grillePauseBat)
	spritePauseBat.hide()
	spritePause.hide()
	var spriteAttente = donnerSprite(game,clef,grilleAttente)
	spriteAttente.hide()
	return bat

func ajouterOrdreAttaqueSansRadar(nomBatiment , priorite):
	var ordreAttaque = action.OrdreAttaqueSansRadar.new()
	ordreAttaque.priorite =priorite
	ordreAttaque.nomBatiment=nomBatiment
	actions.push_back(ordreAttaque)

func ajouterOrdreAttaqueAvecRadar(nomBatiment , priorite):
	var ordreAttaque = action.OrdreAttaqueAvecRadar.new()
	ordreAttaque.priorite =priorite
	ordreAttaque.nomBatiment=nomBatiment
	actions.push_back(ordreAttaque) 
	
	
func ajouterConstruire(game,ix,iy,nomBatiment):
	var clef = " " +str(ix)+"_"+str(iy)
	var spritePause = donnerSprite(game,clef,grillePause)
	var spritePauseBat = donnerSprite(game,clef,grillePauseBat)
	var spriteAttente = donnerSprite(game,clef,grilleAttente)
	if (spriteAttente.is_visible()):
		return
		
	if (grille.has(clef)):
		var bat=grille[clef]
		if (bat.compteur > 0):
			return
	if (spritePause.is_visible() && spritePauseBat.is_visible()):
		return
	var construire = action.Construire.new()
	construire.nomBatiment = nomBatiment
	construire.x=ix
	construire.y=iy
	actions.push_back(construire)
	var tx =game.gestionTexture.imageTextures[nomBatiment]
	var pos=position(ix,iy,game)
	pos=pos+Vector2(-20,20)
	spriteAttente.set_scale(game.ajusterTexture(40,40,tx))
	spriteAttente.set_texture(tx)
	spriteAttente.set_pos(pos)
	spriteAttente.show()
	

	
func donnerSpriteCompteur(game,bat):
	var clef = " " +str(bat.x)+"_"+str(bat.y)
	return donnerSprite(game,clef,grilleCompteur)
	
func donnerSprite(game,clef,dico):
	if (dico.has(clef)):
		return dico[clef]
	var sprite=Sprite.new()
	dico[clef]=sprite
	game.add_child(sprite)
	sprite.hide()
	return sprite
	
func creerSpriteCompteur(game,bat,chiffresTexture):
	var spriteCompteur = donnerSpriteCompteur(game,bat)
	var txChiffre = chiffresTexture[bat.compteur()]
	spriteCompteur.set_texture(txChiffre)
	var dimCompteur = bat.dimCompteur()
	spriteCompteur.set_scale(game.ajusterTexture(dimCompteur,dimCompteur,txChiffre))
	var posCpt=position(bat.x,bat.y,game)
	spriteCompteur.set_pos(posCpt+Vector2(10,10))
	spriteCompteur.set_z(4)
	spriteCompteur.show()
	var clef = " " +str(bat.x)+"_"+str(bat.y)
	var spritePause = donnerSprite(game,clef,grillePause)
	var spritePauseBat = donnerSprite(game,clef,grillePauseBat)
	if (spritePause.is_visible()):
		spritePause.hide()
		spritePauseBat.hide()


func activer(game):
	for key in grilleInactif.keys():
		if (grille.has(key)):
			var bat=grille[key]
			if (bat.estActif):
				var spriteInactif = donnerSprite(game,key,grilleInactif)
				spriteInactif.hide()
		else:
			var spriteInactif = donnerSprite(game,key,grilleInactif)
			spriteInactif.hide()
	for key in grille.keys():
		var bat= grille[key]
		var spriteInactif = donnerSprite(game,key,grilleInactif)
		if (!spriteInactif.is_visible() && !bat.estActif && bat.compteur==0):
			var sprite = spriteInactif
			var pos=position(bat.x,bat.y,game)
			sprite.set_pos(pos)
			sprite.set_texture(game.croixTexture)
			sprite.set_scale(game.ajusterTexture(10,10,game.croixTexture))
			sprite.set_z(3)
			sprite.show()


func proteger(game):
	for key in grilleProtege.keys():
		if (grille.has(key)):
			var bat=grille[key]
			if (!bat.estProtege):
				grilleProtege[key].hide()
		else:
			grilleProtege[key].hide()
	for key in grille.keys():
		var bat= grille[key]
		var spriteProtege = donnerSprite(game,key,grilleProtege)
		if (!spriteProtege.is_visible() && bat.estProtege && bat.compteur==0):
			var sprite = spriteProtege
			var pos=position(bat.x,bat.y,game)
			pos.x+=25
			pos.y+=25
			sprite.set_pos(pos)
			var tx = game.gestionTexture.imageTextures["Protecteur"]
			sprite.set_texture(tx)
			sprite.set_scale(game.ajusterTexture(30,30,tx))
			sprite.set_z(3)
			sprite.show()
			
func activerRadar(game,n):
	for bat in grille.values():
		var clef = " " +str(bat.x)+"_"+str(bat.y)
		if (bat.y >= game.grilleY-n):
			var spriteRadar=donnerSprite(game,clef,grilleRadar)
			if (!spriteRadar.is_visible()):
				print( "radar ",clef)
				var sprite = spriteRadar
				var pos = position(bat.x,bat.y,game)
				sprite.set_texture(game.cibleRadarTexture)
				sprite.set_scale(game.ajusterTexture(0,0,game.cibleRadarTexture))
				sprite.set_pos(pos)
				sprite.show()
		else:
			var spriteRadar=donnerSprite(game,clef,grilleRadar)
			if (spriteRadar.is_visible()):
 				spriteRadar.hide()


func executer(game):
	nombreDeRadar = 0
	listeConstructeur=[]
	if (periodeEnergie >= parametrage.periodeEnergie):
		energie+=1
		periodeEnergie=0
	periodeEnergie+=1
	
	for bat in grille.values():
		bat.estActif = false
		bat.estProtege =false
	for bat in grille.values():
		bat.activer(self)
	for bat in grille.values():
		bat.executer(self)
		if (bat == batEnCoursDeConstruction && bat.compteur==0):
				batEnCoursDeConstruction=null
		if (bat.compteur()==0):
			var sprite = donnerSpriteCompteur(game,bat)
			sprite.hide()
		else:
			if (bat.gererCompteur(game,self)):
				creerSpriteCompteur(game,bat,bat.chiffresTexture(game))
	
	activer(game)
	proteger(game)
	if (idxAction < actions.size()):
		actions[idxAction].executer(game,self)
		
	adversaire.activerRadar(game,nombreDeRadar)
	if (nombreMerveille >= parametrage.nombreMerveillePourVictoire):
		return true
	var tmpListeLaboratoireDisponible=[]
	for bat in listeLaboratoireDisponible:
		if (bat.vie > 0):
			tmpListeLaboratoireDisponible.push_back(bat)
	listeLaboratoireDisponible = tmpListeLaboratoireDisponible
	gererLanceMissileSansRadar()
	for lanceMissile in listeLanceMissileSansRadarEnDeplacement:
		lanceMissile.deplacer()
	
	tmpListeLaboratoireDisponible=[]
	if (idxOrdreAmelioration < ordreAmeliorations.size()):
		var nomBatimentPourAmelioration=ordreAmeliorations[idxOrdreAmelioration]
		var coutAmelioration=parametrage[nomBatimentPourAmelioration].coutAmelioration 
		if (coutAmelioration  <= listeLaboratoireDisponible.size()):
			for i in range(coutAmelioration,listeLaboratoireDisponible.size()):
				tmpListeLaboratoireDisponible.push_back(listeLaboratoireDisponible[i])
			for i in range(0,coutAmelioration):
				var bat=listeLaboratoireDisponible[i]
				bat.compteurRecharge=9
			listeLaboratoireDisponible=tmpListeLaboratoireDisponible
			ameliorations.push_back(nomBatimentPourAmelioration)
			if (!estAdversaire):
				game.ordreAmeliorationsFaiteSprite[idxOrdreAmelioration].show()
			idxOrdreAmelioration+=1
	return false
func initialiserGrille(game,ea,grilleX,grilleY,tg):
	estAdversaire =ea
	imageTexture=ImageTexture.new()
	if (estAdversaire):
		imageTexture.load("carreGris.png")
	else:
		imageTexture.load("carre.png")
	var deltat=0
	var ts = imageTexture.get_size()
	var scaleX =(game.grilleSize)/ ts.x
	var scaleY =(game.grilleSize)/ ts.y
	if (estAdversaire):
		deltat=grilleY*tg
	for x in range(grilleX):
		for y in range(grilleY):
			var sprite =Sprite.new()
			sprite.set_texture(imageTexture)
			game.add_child(sprite)
			sprite.set_pos(Vector2(x*tg+tg/2,y*tg+tg/2+deltat))
			sprite.set_scale(Vector2(scaleX,scaleY))