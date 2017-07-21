
class Construire:
	var nomBatiment=""
	var x=0
	var y=0
	var reconstruction=false
	func saveData():
		return { type="C",x=x,y=y,nomBatiment=nomBatiment}
	func executer(game,joueur):
		
		var energie=joueur.parametrage[nomBatiment].energie
		var energieJoueur=joueur.energie
		if (energieJoueur < energie ):
				var clef = " " +str(x)+"_"+str(y)
				var spritePause = joueur.donnerSprite(game,clef,joueur.grillePause)
				var spritePauseBat = joueur.donnerSprite(game,clef,joueur.grillePauseBat)
				var spriteAttente = joueur.donnerSprite(game,clef,joueur.grilleAttente)
				spriteAttente.hide()
				var sprite = spritePause
				var spriteBat =spritePauseBat
	
				var pos=joueur.position(x,y,game)
				var tx =game.gestionTexture.imageTextures[nomBatiment]
				spriteBat.set_texture(tx)
				spriteBat.set_pos(pos)
				spriteBat.set_scale(game.ajusterTexture(10,10,tx))
				
				sprite.set_texture(game.pauseTexture)
				sprite.set_scale(game.ajusterTexture(40,40,game.pauseTexture))
				
				sprite.set_pos(pos)
				sprite.set_z(4)
				sprite.show()
				spriteBat.show()
				return false
		
		if (joueur.batEnCoursDeConstruction==null):
			joueur.energie-=energie
			joueur.batEnCoursDeConstruction=joueur.creerBatiment(game,x,y,nomBatiment,reconstruction)
			joueur.reconstructionPossible=true
			if (!reconstruction):
				joueur.idxAction+=1
			return true

		for bat in joueur.listeConstructeur:
			if (bat.compteurRecharge==0):
				bat.compteurRecharge=9
				joueur.energie-=energie
				joueur.creerBatiment(game,x,y,nomBatiment,reconstruction)
				joueur.reconstructionPossible=true
				if (!reconstruction):
					joueur.idxAction+=1
				return true
		
class OrdreAttaque:
	var nomBatiment
	var priorite
	func typeOA():
		return ""
	func saveData():
		return { type=typeOA(),priorite=priorite,nomBatiment=nomBatiment}
class OrdreAttaqueSansRadar extends OrdreAttaque:
	func typeOA():
		return "OASR"
	func executer(game,joueur):
		joueur.idxAction+=1
		var oldIdx=joueur.ordreAttaqueLanceMissileSansRadar.find(nomBatiment)
		var oldNomBatiment=joueur.ordreAttaqueLanceMissileSansRadar[priorite]
		joueur.ordreAttaqueLanceMissileSansRadar[priorite]=nomBatiment
		joueur.ordreAttaqueLanceMissileSansRadar[oldIdx]=oldNomBatiment
		var grilleX=game.grilleX
		var grilleSize=game.grilleSize
		if (joueur == game.joueur):
			game.gestionTexture.modifierOrdreAttaque(game,joueur.ordreAttaqueLanceMissileSansRadar,game.ordreAttaqueLanceMissileSansRadarSprite,(grilleX+1)*grilleSize)
class OrdreAttaqueAvecRadar extends OrdreAttaque:
	func executer(game,joueur):
		joueur.idxAction+=1
		var oldIdx=joueur.ordreAttaqueLanceMissileAvecRadar.find(nomBatiment)
		var oldNomBatiment=joueur.ordreAttaqueLanceMissileAvecRadar[priorite]
		joueur.ordreAttaqueLanceMissileAvecRadar[priorite]=nomBatiment
		joueur.ordreAttaqueLanceMissileAvecRadar[oldIdx]=oldNomBatiment
		var grilleX=game.grilleX
		var grilleSize=game.grilleSize
		if (joueur == game.joueur):
			game.gestionTexture.modifierOrdreAttaque(game,joueur.ordreAttaqueLanceMissileAvecRadar,game.ordreAttaqueLanceMissileAvecRadarSprite,(grilleX+2)*grilleSize)
	func typeOA():
		return "OAAR"
