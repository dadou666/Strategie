
class Batiment:
	var vie=0
	var reconstruction=false
	var estActif = false
	var estProtege = false
	var compteur=9
	var dureeCompteur=50
	var x=0
	var y=0
	func reparer(joueur,reparateur):
		var vieMax=joueur.parametrage[afficherNom()].vie
		if (vie < vieMax):
			vie+=joueur.parametrage.reparation
			if (vie > vieMax):
				vie=vieMax
			reparateur.compteurRecharge=9
			return

	func clef():
		var clef = " " +str(x)+"_"+str(y)
		return clef
	func dimCompteur():
		return 40
	func compteur():
		return compteur
	func init(joueur):
		pass
	func afficherNom():
		return ""
	func executer(joueur):
		pass
	func activer(joueur):
		pass
	func chiffresTexture(game):
		return game.chiffresTextureA
	func gererCompteur(game,joueur):
		if (compteur==0):
			return false
		if (dureeCompteur == 0):
			compteur-=1
			var nomBatiment=afficherNom()
			dureeCompteur=joueur.parametrage[nomBatiment].dureeCompteur
			if (reconstruction):
				dureeCompteur+=joueur.parametrage.reconstruction
			return true
		dureeCompteur=dureeCompteur-1
		return false

class BatimentRecharge extends Batiment:
	var dureeCompteurRecharge=0
	var compteurRecharge=9
	func dimCompteur():
		if (compteur==0):
			return 40
		return 40
	func recharger(joueur):
		pass
	func compteur():
		if (compteur==0):
			if (estActif):
				return compteurRecharge
			return 0
		return compteur
	func init(joueur):
		dureeCompteurRecharge=joueur.parametrage[afficherNom()].dureeCompteurRecharge
	func chiffresTexture(game):
		if (compteur==0):
			return game.chiffresTextureB
		return game.chiffresTextureA
	func gererCompteur(game,joueur):
		if (compteur==0):
			return gererCompteurRecharge(game,joueur)
		if (dureeCompteur == 0):
			compteur-=1
			var nomBatiment=afficherNom()
			dureeCompteur=joueur.parametrage[nomBatiment].dureeCompteur
			return true
		dureeCompteur=dureeCompteur-1
		return false
	func gererCompteurRecharge(game,joueur):
		if (!estActif):
			return false
		if (compteurRecharge==0):
			recharger(joueur)
			return false
		if (dureeCompteurRecharge == 0):
			compteurRecharge-=1
			if (compteurRecharge==0):
				recharger(joueur)
			var nomBatiment=afficherNom()
			dureeCompteurRecharge=joueur.parametrage[nomBatiment].dureeCompteurRecharge
			return true
		dureeCompteurRecharge=dureeCompteurRecharge-1
		return false
		
class GestionTextures:
	var imageTextures={}
	var nomBatiments=["Generateur","LanceMissileSansRadar","LanceMissileAvecRadar","LanceMissilePremiereLigne","Reparateur",
"Constructeur","Protecteur","Radar","Controlleur","Merveille","Socle","Laboratoire"]
	var nomBatimentAvecAmelioration=[]
	var secondeTexturesChoix={"LanceMissileAvecRadar":"Radar","LanceMissilePremiereLigne":"Protecteur" }
	func imageTexturePourIndex(idx):
		return imageTextures[nomBatiments[idx]]
	func imageTexture(bat):
		return imageTextures[bat.afficherNom()]
	func chargerImageTexture(nomBatiment):
		var it = ImageTexture.new()
		var chemin = "batiment/"+nomBatiment+".png"
		#print(chemin)
		it.load("batiment/"+nomBatiment+".png")
		
		imageTextures[nomBatiment]=it
	func modifierOrdreAttaque(game,ordreAttaque,ordreAttaqueSprite,posX):
		for i in range(ordreAttaque.size()):
			var nomBatiment= ordreAttaque[i]
			var tex=imageTextures[nomBatiment]
			var sprite=ordreAttaqueSprite[i]
			sprite.set_scale(game.ajusterTexture(10,10,tex))
			sprite.set_texture(tex)
		
	func donnerOrdreAttaque(game,nomBatiment,ordreAttaqueSprite,posX,carreTx):
		var i=0
		var tg=game.grilleSize
		var spritePremier=Sprite.new()
		var texPremier=imageTextures[nomBatiment]
		spritePremier.set_texture(texPremier)
		game.add_child(spritePremier)
		var pos=Vector2(posX+tg/2,tg/2)
		spritePremier.set_pos(pos)
		spritePremier.set_scale(game.ajusterTexture(10,10,texPremier))
		for nom in nomBatiments:
			var sprite =Sprite.new()
			var tex=imageTextures[nomBatiments[i]]
			sprite.set_texture(tex)
			game.add_child(sprite)
			var pos=Vector2(posX+tg/2,(i+1)*tg+tg/2)
			sprite.set_pos(pos)
			sprite.set_scale(game.ajusterTexture(10,10,tex))
			ordreAttaqueSprite.push_back(sprite)
			var carre = Sprite.new()
			carre.set_texture(carreTx)
			carre.set_scale(game.ajusterTexture(0,0,carreTx))
			carre.set_pos(pos)
			game.add_child(carre)
			i+=1
			
	func chargerImageTextures():
		for nom in nomBatiments:
			chargerImageTexture(nom)
	func ajouterChoixBatiment(game,posX,tg):
		for i in range(nomBatiments.size()):
			var sprite =Sprite.new()
			var tex=imageTextures[nomBatiments[i]]
			sprite.set_texture(tex)
			game.add_child(sprite)
			var pos=Vector2(posX+tg/2,(i+1)*tg+tg/2)
			sprite.set_pos(pos)
			sprite.set_scale(game.ajusterTexture(10,10,tex))
			if (secondeTexturesChoix.has(nomBatiments[i])):
				var secondSprite =Sprite.new()
				game.add_child(secondSprite)
				secondSprite.set_pos(Vector2(posX+tg/2+20,(i+1)*tg+tg/2+20))
				var tex2=imageTextures[secondeTexturesChoix[nomBatiments[i]]]
				secondSprite.set_texture(tex2)
				secondSprite.set_scale(game.ajusterTexture(35,35,tex2))
			var carreVert = Sprite.new()
			carreVert.set_texture(game.carreVertTexture)
			carreVert.set_scale(game.ajusterTexture(0,0,game.carreVertTexture))
			carreVert.set_pos(pos)
			game.add_child(carreVert)
	func ajouterChoixAmelioration(joueur,game,posX,tg,ordreAmeliorations,ordreAmeliorationsSprite):
		nomBatimentAvecAmelioration=[]
		for nomBatiment in nomBatiments:
			if (joueur.parametrage[nomBatiment].coutAmelioration > 0):
				nomBatimentAvecAmelioration.push_back(nomBatiment)


		for i in range(nomBatimentAvecAmelioration.size()):
			var sprite =Sprite.new()
			var nomBatiment=nomBatimentAvecAmelioration[i]
			ordreAmeliorationsSprite.push_back(sprite)
			ordreAmeliorations.push_back(nomBatiment)
			var tex=imageTextures[nomBatiment]
			sprite.set_texture(tex)
			game.add_child(sprite)
			var pos=Vector2(posX+tg/2,(i+1)*tg+tg/2)
			sprite.set_pos(pos)
			sprite.set_scale(game.ajusterTexture(10,10,tex))
			var carreVert = Sprite.new()
			carreVert.set_texture(game.carreBleueTexture)
			carreVert.set_scale(game.ajusterTexture(0,0,game.carreBleueTexture))
			carreVert.set_pos(pos)
			game.add_child(carreVert)
			var spriteOk = Sprite.new()
			var texOk= game.okTexture
			spriteOk.set_pos(pos)
			spriteOk.set_scale(game.ajusterTexture(10,10,texOk))
			spriteOk.set_texture(texOk)
			game.add_child(spriteOk)
			game.ordreAmeliorationsFaiteSprite.push_back(spriteOk)
			spriteOk.hide()

class Generateur extends BatimentRecharge:

	func afficherNom():
		return "Generateur"
	func recharger(joueur):
		compteurRecharge=9
		joueur.energie+=4

class MissileDeplacement:
	var distance
	var direction
	var bat
	var sprite
	var vitesse
	var spriteInitPos
	func orientationAngle():
		if (direction.y < 0):
			return acos(direction.x)+3.14+3.14/2
		else:
			return -acos(direction.x)+3.14+3.14/2
	func deplacer():
		var newPos = sprite.get_pos()+direction
		distance -= vitesse
		sprite.set_pos(newPos)
		if (distance <=0):
			sprite.set_pos(spriteInitPos)
			return true
		return false
class LanceMissile extends BatimentRecharge:
	var missileDeplacement
	func dirigerVers(sprite, pos,bat ):
		missileDeplacement=MissileDeplacement.new()
		missileDeplacement.vitesse=2.0
		var direction= pos-sprite.get_pos()
		missileDeplacement.spriteInitPos = sprite.get_pos()
		missileDeplacement.distance =direction.length()
		missileDeplacement.direction=direction.normalized()
		sprite.set_rot(missileDeplacement.orientationAngle())
		missileDeplacement.direction = missileDeplacement.direction * missileDeplacement.vitesse
		missileDeplacement.bat=bat
		missileDeplacement.sprite=sprite
		sprite.set_z(6)
		
		pass
	func deplacer(joueur,liste):
		if (missileDeplacement.deplacer()):
			compteurRecharge=9
			impact(joueur)
			return true
		liste.push_back(self)
		return false
	func impact(joueur):
		print(" impact ")
class LanceMissileSansRadar extends LanceMissile:
	func afficherNom():
		return "LanceMissileSansRadar"
	func recharger(joueur):
		joueur.listeLanceMissileSansRadarDisponnible.push_back(self)
	func impact(joueur):
		missileDeplacement.bat.vie-=joueur.parametrage[afficherNom()].impact

class LanceMissileAvecRadar extends LanceMissile:
	func afficherNom():
		return "LanceMissileAvecRadar"
	func impact(joueur):
		missileDeplacement.bat.vie=0
class LanceMissilePremiereLigne extends LanceMissile:
	func afficherNom():
		return "LanceMissilePremiereLigne"
	func impact(joueur):
		missileDeplacement.bat.vie=0
class Protecteur extends Batiment:
	func afficherNom():
		return "Protecteur"
	func executer(joueur):
		if (estActif && compteur==0):
			for ux in range(-1,2):
				for uy in range(-1,2):
					proteger(joueur,x+ux,y+uy)
			estProtege=false

	func proteger(joueur,px,py):
		if (joueur.contient(px,py)):
			var bat = joueur.donnerBatiment(px,py)
			if (bat.afficherNom() != "Protecteur"):
				bat.estProtege=true


class Controlleur extends Batiment:
	func afficherNom():
		return "Controlleur"
	func activer(joueur):
		if (compteur==0):
			activerPos(joueur,x,y)
	func activerPos(joueur,px,py):
		if (joueur.contient(px,py)):
			var bat = joueur.donnerBatiment(px,py)
			if (bat.estActif):
				return
			bat.estActif=true
			activerPos(joueur,px+1,py)
			activerPos(joueur,px-1,py)
			activerPos(joueur,px,py+1)
			activerPos(joueur,px,py-1)

class Merveille extends BatimentRecharge:
	func afficherNom():
		return "Merveille"
	func executer(joueur):
		pass
	func recharger(joueur):
		joueur.nombreMerveille+=1
		
class Laboratoire extends BatimentRecharge:
	func afficherNom():
		return "Laboratoire"
	func recharger(joueur):
		joueur.listeLaboratoireDisponible.push_back(self)

class Constructeur extends BatimentRecharge:
	func afficherNom():
		return "Constructeur"
	func executer(joueur):
		if (compteur==0 && compteurRecharge==0):
			joueur.listeConstructeur.push_back(self)
class Reparateur extends BatimentRecharge:
	func afficherNom():
		return "Reparateur"
	func executer(joueur):
		if (compteur==0 && compteurRecharge==0):
			joueur.listeReparateur.push_back(self)

class Socle extends Batiment:
	func afficherNom():
		return "Socle"
	func executer(joueur):
		estActif =true

class Radar extends Batiment:
	func afficherNom():
		return "Radar"
	func executer(joueur):
		if (estActif && compteur==0):
			joueur.nombreDeRadar+=1



