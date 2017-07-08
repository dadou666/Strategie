
class Batiment:
	var vie=0
	var estActif = false
	var estProtege = false
	var compteur=9
	var dureeCompteur=50
	var x=0
	var y=0
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
		
	func donnerOrdreAttaque(game,nomBatiment,ordreAttaque,ordreAttaqueSprite,posX,carreTx):
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
			ordreAttaque.push_back(nom)
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

class Generateur extends BatimentRecharge:

	func afficherNom():
		return "Generateur"
	func recharger(joueur):
		compteurRecharge=9
		joueur.energie+=4
		print(" generation.. ")
	
class LanceMissileSansRadar extends Batiment:
	var puissance=0
	func afficherNom():
		return "LanceMissileSansRadar"


class LanceMissileAvecRadar extends Batiment:
	var puissance=0
	func afficherNom():
		return "LanceMissileAvecRadar"

class LanceMissilePremiereLigne extends Batiment:
	func afficherNom():
		return "LanceMissilePremiereLigne"
		
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

class Merveille extends Batiment:
	func afficherNom():
		return "Merveille"
	func executer(joueur):
		estActif =true
		
class Laboratoire extends Batiment:
	func afficherNom():
		return "Laboratoire"

class Constructeur extends BatimentRecharge:
	func afficherNom():
		return "Constructeur"
	func executer(joueur):
		if (compteur==0 && compteurRecharge==0):
			joueur.listeConstructeur.push_back(self)
class Reparateur extends Batiment:
	func afficherNom():
		return "Reparateur"

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
