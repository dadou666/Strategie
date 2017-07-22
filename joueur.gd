extends Object

var energie=1000
var premiereConstruction=false
var estAdversaire = false

var imageTexture
var nombreMerveille=0
var nombreBatiment=0
var nomJoueur=""
var nombreDeRadar=0
var listeConstructeur=[]
var listeReparateur=[]
var batEnCoursDeConstruction=null
var ordreAttaqueLanceMissileAvecRadar=[]
var ordreAttaqueLanceMissileSansRadar=[]
var ameliorations= []
var ordreAmeliorations= []
var idxOrdreAmelioration=0
var listeLaboratoireDisponible=[]
var listeLanceMissileSansRadarDisponnible=[]
var listeLanceMissileAvecRadarDisponnible=[]
var listeLanceMissilePremiereLigneDisponnible=[]
var listeLanceMissileEnDeplacement=[]
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
var nombreAction=0
var idxAction=0
var batiment = preload("batiment.gd")
var action = preload("action.gd")
var parametrage=load("parametrage.gd").new()
var adversaire
var reconstruire=null
var reconstructionPossible = false
func initOrdreAttaque(game):
	ordreAttaqueLanceMissileAvecRadar=[]
	ordreAttaqueLanceMissileSansRadar=[]
	for nomBatiment in game.gestionTexture.nomBatiments:
		ordreAttaqueLanceMissileAvecRadar.push_back(nomBatiment)
		ordreAttaqueLanceMissileSansRadar.push_back(nomBatiment)
	
func raz():
	grille={}
	nombreAction=0
	nombreBatiment=0
	premiereConstruction=false
	reconstruire=null
	listeLaboratoireDisponible=[]
	listeLanceMissileSansRadarDisponnible=[]
	listeLanceMissileEnDeplacement=[]
	listeLanceMissileAvecRadarDisponnible=[]
	idxAction=0
	idxOrdreAmelioration=0
	energie=parametrage.energieJoueur
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
	energie=parametrage.energieJoueur
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
		if (bat.vie > 0):
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
func gererLanceMissileAvecRadar():
	var bats =adversaire.batimentsParType()
	var idxLanceMissile=0
	var listeTmp=[]
	for nomBatiment in ordreAttaqueLanceMissileAvecRadar:
		if (bats.has(nomBatiment)):
			var cibles = bats[nomBatiment]
			for bat in cibles:
				if (bat.compteur==0&&!bat.estCible&&adversaire.grilleRadar.has(bat.clef()) && adversaire.grilleRadar[bat.clef()].is_visible()):
					if (idxLanceMissile == listeLanceMissileAvecRadarDisponnible.size()):
						listeLanceMissileSansRadarDisponnible=[]
						return
					var lanceMissile = listeLanceMissileAvecRadarDisponnible[idxLanceMissile]
					idxLanceMissile+=1
					lanceMissile.dirigerVers(grilleBatiment[lanceMissile.clef()],adversaire.grilleBatiment[bat.clef()].get_pos(),bat)
					listeLanceMissileEnDeplacement.push_back(lanceMissile)
	for i in range(idxLanceMissile,listeLanceMissileAvecRadarDisponnible.size()):
		var bat=listeLanceMissileAvecRadarDisponnible[i]
		listeTmp.push_back(bat)
	listeLanceMissileAvecRadarDisponnible=listeTmp
func gererLanceMissilePremiereLigne(game):
	var grilleY=game.grilleY-1
	var grilleX=game.grilleX
	var cibles=[]
	for i in range(0,grilleX):
		var y=grilleY
		while y>=0:
			var clef = " " +str(i)+"_"+str(y)
			y=y-1
			if (adversaire.grilleBatiment.has(clef)):
				var sb=adversaire.grilleBatiment[clef]
				if (sb.is_visible()):
					cibles.push_back(adversaire.grille[clef])
					y=-1
	var listTmp=[]
	for lanceMissile in listeLanceMissilePremiereLigneDisponnible:
		var spl=grilleBatiment[lanceMissile.clef()]
		var cible= lePlusProche(cibles,spl.get_pos())
		if (cible==null):
			listTmp.push_back(lanceMissile)
		else:
			lanceMissile.dirigerVers(spl,adversaire.grilleBatiment[cible.clef()].get_pos(),cible)
			listeLanceMissileEnDeplacement.push_back(lanceMissile)
	listeLanceMissilePremiereLigneDisponnible=listTmp

func lePlusProche(cibles,pos):
	var dist=null
	var rs=null
	var idx=null
	for i in range(0,cibles.size()):
		var cible = cibles[i]
		if (cible!=null && !cible.estCible && !cible.estProtege && cible.compteur==0):
			var sb = adversaire.grilleBatiment[cible.clef()]
			var distTmp =(sb.get_pos()-pos).length()
			if (rs == null):
				rs=cible
				dist=distTmp
				idx=i
			else:
				if (dist > distTmp):
					rs=cible
					dist=distTmp
					idx=i
	if (rs==null):
		return null
	cibles[idx]=null
	return rs


func gererLanceMissileSansRadar():
	var bats =adversaire.batimentsParType()
	for nomBatiment in ordreAttaqueLanceMissileSansRadar:
		if (bats.has(nomBatiment)):
			var cibles = bats[nomBatiment]
			if (cibles.size() > 0):
				var idx=0
				for lanceMissile in listeLanceMissileSansRadarDisponnible:
					
					var bat=cibles[idx]
					if (!bat.estCible && bat.compteur==0):
						lanceMissile.dirigerVers(grilleBatiment[lanceMissile.clef()],adversaire.grilleBatiment[bat.clef()].get_pos(),bat)
					idx=idx+1
					listeLanceMissileEnDeplacement.push_back(lanceMissile)
					if (idx == cibles.size()):
						idx=0
				listeLanceMissileSansRadarDisponnible=[]
				return
	
	

func creerBatiment(game,ix,iy,nomBatiment,reconstruction):
	var clef = " " +str(ix)+"_"+str(iy)
	var bat=null
	if (!premiereConstruction):
		nombreBatiment=1
	premiereConstruction=true
	bat = game.lib[nomBatiment].new()
	
	bat.init(self)
	var spriteBatiment = donnerSprite(game,clef,grilleBatiment)

	bat.x=ix
	bat.y=iy
	bat.vie = parametrage[nomBatiment].vie
	bat.dureeCompteur = parametrage[nomBatiment].dureeCompteur
	if (reconstruction):
		bat.dureeCompteur+=parametrage.reconstruction
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
func gererRepriseActions():
	if (idxAction >= nombreAction):
		var tmpActions = []
		for i in range(0,idxAction):
			tmpActions.push_back(actions[i])
		nombreAction=tmpActions.size()
		actions=tmpActions
func ajouterOrdreAttaqueSansRadar(nomBatiment , priorite):
	var ordreAttaque = action.OrdreAttaqueSansRadar.new()
	ordreAttaque.priorite =priorite
	ordreAttaque.nomBatiment=nomBatiment
	gererRepriseActions()
	actions.push_back(ordreAttaque)
	nombreAction += 1
	

func ajouterOrdreAttaqueAvecRadar(nomBatiment , priorite):
	var ordreAttaque = action.OrdreAttaqueAvecRadar.new()
	ordreAttaque.priorite =priorite
	ordreAttaque.nomBatiment=nomBatiment
	gererRepriseActions()
	actions.push_back(ordreAttaque) 
	nombreAction += 1
	
	
func ajouterConstruire(game,ix,iy,nomBatiment):
	var clef = " " +str(ix)+"_"+str(iy)
	var spritePause = donnerSprite(game,clef,grillePause)
	var spritePauseBat = donnerSprite(game,clef,grillePauseBat)
	var spriteAttente = donnerSprite(game,clef,grilleAttente)
	var spriteBatiment =donnerSprite(game,clef,grilleBatiment)
	if (spriteAttente.is_visible() || spriteBatiment.is_visible() ):
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
	gererRepriseActions()
	actions.push_back(construire)
	nombreAction += 1
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
	spriteCompteur.set_pos(posCpt+Vector2(15,15))
	spriteCompteur.set_z(6)
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
			pos.x+=-25
			pos.y+=-25
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
	nombreBatiment =0
	listeConstructeur=[]
	listeReparateur=[]
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
		if (bat.vie > 0):
			bat.executer(self)
			nombreBatiment+=nombreBatiment+1
			
			if (bat == batEnCoursDeConstruction && bat.compteur==0):
					batEnCoursDeConstruction=null
			if (bat.compteur()==0):
				var sprite = donnerSpriteCompteur(game,bat)
				sprite.hide()
			else:
				if (bat.gererCompteur(game,self)):
					creerSpriteCompteur(game,bat,bat.chiffresTexture(game))
		else:
			var spriteBatiment=grilleBatiment[bat.clef()]
			if (spriteBatiment.is_visible()):
				for reparateur in listeReparateur:
					if (reparateur.compterRecharge==0):
						bat.reparer(self,reparateur)
				if (bat.vie <=0):
					spriteBatiment.hide()
					donnerSprite(game,bat.clef(),grilleCompteur).hide()
			else:
				if (reconstruire==null):
					reconstruire=action.Construire.new()
					bat.reconstruction=true
					reconstruire.x=bat.x
					reconstruire.y=bat.y
					reconstruire.reconstruction = true
					reconstruire.nomBatiment = bat.afficherNom()
	
	activer(game)
	proteger(game)
	if (reconstruire != null && reconstructionPossible):
		if (reconstruire.executer(game,self)):
			reconstruire=null
			reconstructionPossible=false
	if (!reconstructionPossible || reconstruire==null):
		if (idxAction < actions.size()):
			actions[idxAction].executer(game,self)
			
	
	adversaire.activerRadar(game,nombreDeRadar)
	if (nombreMerveille >= parametrage.nombreMerveillePourVictoire):
		return true
	if (adversaire.premiereConstruction && adversaire.nombreBatiment==0):
		return true
	var tmpListeLaboratoireDisponible=[]
	for bat in listeLaboratoireDisponible:
		if (bat.vie > 0):
			tmpListeLaboratoireDisponible.push_back(bat)
	listeLaboratoireDisponible = tmpListeLaboratoireDisponible
	gererLanceMissileSansRadar()
	gererLanceMissileAvecRadar()
	gererLanceMissilePremiereLigne(game)
	var listeTmp=[]
	for lanceMissile in listeLanceMissileEnDeplacement:
		lanceMissile.deplacer(self,listeTmp)
	listeLanceMissileEnDeplacement=listeTmp
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
	
	if (estAdversaire):
		imageTexture =load("carreGris.png")
	else:
		imageTexture=load("carre.png")
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