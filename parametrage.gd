extends Node

var periodeEnergie=20
var nombreMerveillePourVictoire=7
var reparation=2
var reconstruction=20
var energieJoueur=500
var Generateur= { vie=50 ,energie=100,dureeCompteur = 50 ,dureeCompteurRecharge=5 ,coutAmelioration=3,dureeCompteurRechargeAmelioration=2}
var LanceMissileSansRadar= { vie=50 ,dureeCompteur = 50,energie=100 ,coutAmelioration=4,dureeCompteurRecharge=150,impact=10,dureeCompteurRechargeAmelioration=50}
var LanceMissileAvecRadar= { vie=50 ,dureeCompteur = 50,energie=100 ,coutAmelioration=2,dureeCompteurRecharge=120,dureeCompteurRechargeAmelioration=50}
var Protecteur= { vie=50 ,dureeCompteur = 50 ,energie=100 ,coutAmelioration=2}
var Controlleur= { vie=50 ,dureeCompteur = 50 ,energie=100,coutAmelioration=0}
var Merveille= { vie=50 ,dureeCompteur = 50 ,energie=100,coutAmelioration=6,dureeCompteurRecharge=120,dureeCompteurRechargeAmelioration=60}
var Laboratoire= { vie=50 ,dureeCompteur = 50 ,energie=100,coutAmelioration=3,dureeCompteurRecharge=120,dureeCompteurRechargeAmelioration=40}
var Reparateur= { vie=50 ,dureeCompteur = 50 ,energie=100,coutAmelioration=2,dureeCompteurRecharge=75,dureeCompteurRechargeAmelioration=30}
var Socle= { vie=50 ,dureeCompteur = 50 ,energie=100,coutAmelioration=0}
var Radar= { vie=50 ,dureeCompteur = 50 ,energie=100,coutAmelioration=0}
var LanceMissilePremiereLigne= { vie=50 ,energie=100,dureeCompteur = 50,coutAmelioration=3,dureeCompteurRecharge=75 ,dureeCompteurRechargeAmelioration=30}
var Constructeur= { vie=50 ,energie=100,dureeCompteur = 50,dureeCompteurRecharge= 150 ,coutAmelioration=2,dureeCompteurRechargeAmelioration=75}
