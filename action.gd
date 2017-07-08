
class Construire:
	var nomBatiment=""
	var x=0
	var y=0
	func executer(game,joueur):
		var energie=joueur.parametrage[nomBatiment].energie
		if (joueur.energie < energie ):
			return
		joueur.energie-=energie
		if (joueur.batEnCoursDeConstruction==null):
			joueur.batEnCoursDeConstruction=joueur.creerBatiment(game,x,y,nomBatiment)
			joueur.idxAction+=1
			return
		for bat in joueur.listeConstructeur:
			if (bat.compteurRecharge==0):
				bat.compteurRecharge=9
				joueur.creerBatiment(game,x,y,nomBatiment)
				joueur.idxAction+=1
				return
		
class OrdreAttaque:
	var nomBatiment
	
class OrdreAttaqueSansRadar extends OrdreAttaque:
	func executer(game,joueur):
		pass
class OrdreAttaqueSansRadar extends OrdreAttaque:
	func executer(game,joueur):
		pass
class Amelioration:
	var nomBatiment

