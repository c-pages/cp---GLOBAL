

macroscript Model_Zinc
category:"#CPages" 
buttonText:"Zinc"
tooltip:"Créer un kit zinc à partir de la spline qu'on a piqué."
(

	
	data_zinc = attributes zincData	(
		parameters main rollout:paramsZinc	(
			
			shp_fond 		type:#maxObjectTab 	tabSize:1 			tabSizeVariable:false
			shp_joints 		type:#maxObjectTab 	tabSize:1 			tabSizeVariable:false
			shp_cadre 		type:#maxObjectTab 	tabSize:1 			tabSizeVariable:false
			
			largeur 			type: #float 		ui:ui_largeur 				default:60.
			hauteur			type: #float 		ui:ui_hauteur 				default:300.
			orientation		type: #float 		ui:ui_orientation			default:90.
			tilt				type: #float 		ui:ui_tilt						default:1.5
			
			jointsOn			type: #boolean	ui:ui_jointsOn				default:true
			jointsLargeur 	type: #float 		ui:ui_jointsLargeur 		default:4.
			jointsHauteur	type: #float 		ui:ui_jointsHauteur 		default:5.
			
			cadreOn 		type: #boolean	ui:ui_cadreOn				default:true	
			cadreLargeur 	type: #float 		ui:ui_cadreLargeur 		default:5.
			cadreHauteur	type: #float 		ui:ui_cadreHauteur 		default:6.		
			
			decalLargeur 			type: #float 		ui:ui_decalLargeur 	default:0.
			decalHauteur			type: #float 		ui:ui_decalHauteur 	default:0.
			
		)
		rollout paramsZinc "Zinc"
		( 
			
			---- UI ----
			group 	"Bandes" (
				spinner 		ui_largeur 			"Largeur" 		type: #float 	range:[0,100000,1]
				spinner 		ui_hauteur 			"Hauteur" 		type: #float 	range:[0,100000,1]
				spinner 		ui_orientation 		"Orientation" 	type: #float 	range:[0,100000,1]
				spinner 		ui_tilt 				"Tilt" 				type: #float 	range:[0,100000,1]
			)
			group 	"Joints debouts" (
				checkbox		ui_jointsOn				"On" 			type: #boolean
				spinner 		ui_jointsLargeur 		"Largeur" 	type: #float 	range:[0,100000,1]
				spinner 		ui_jointsHauteur 		"Hauteur" 	type: #float 	range:[0,100000,1]
			)
			group 	"Cadre" (
				checkbox		ui_cadreOn 			"On" 			type: #boolean
				spinner 		ui_cadreLargeur 		"Largeur" 	type: #float 	range:[0,100000,1]
				spinner 		ui_cadreHauteur 		"Hauteur" 	type: #float 	range:[0,100000,1]
			)
			
			group 	"Décalage" (
				spinner 		ui_decalLargeur 		"Largeur" 	type: #float 	range:[-100000,100000,1]
				spinner 		ui_decalHauteur 		"Hauteur" 	type: #float 	range:[-100000,100000,1]
			)
			
			
			-------- FONCTIONS---------------------
			fn actualiser =(
				
				local mod_fond 			= shp_fond[1].node.modifiers["Zinc_fond"]
				local mod_joints 			= shp_joints[1].node.modifiers["Zinc_joints"]
				local mod_cadreExtr 	= shp_cadre[1].node.modifiers["Zinc_extrude"]
				local mod_cadreShell 	= shp_cadre[1].node.modifiers["Zinc_shell"]
				
				mod_fond.length 				= hauteur
				mod_fond.width 				= largeur
				mod_fond.direction			= orientation
				mod_fond.Tilt 					= tilt
				mod_fond.ObjOffsetY		= decalLargeur
				mod_fond.ObjOffsetX		= decalHauteur
				
				-- joints --
				mod_joints.length 			= hauteur
				mod_joints.width 				= jointsLargeur
				mod_joints.direction			= orientation
				mod_joints.Extrude 			= jointsHauteur
				mod_joints.GroutWidth 		= largeur -  jointsLargeur
				mod_joints.ObjOffsetY		= decalLargeur
				mod_joints.ObjOffsetX		= decalHauteur
				
				-- cadre --
				mod_cadreExtr.amount 				= cadreHauteur
				mod_cadreShell.innerAmount 		= cadreLargeur / 2
				mod_cadreShell.outerAmount 	= cadreLargeur / 2
				
			)
			
			
						
			-------- EVENTS---------------------
			
			on paramsZinc open do 
				try actualiser () catch ()
			
			
			on ui_largeur 			changed  val 	do actualiser ()
			on ui_hauteur 		changed  val 	do actualiser ()
			on ui_orientation 	changed  val 	do actualiser ()
			on ui_tilt 				changed  val 	do actualiser ()
			
			on ui_jointsLargeur 		changed  val 	do actualiser ()
			on ui_jointsHauteur 		changed  val 	do actualiser ()
			
			on ui_cadreLargeur 		changed  val 	do actualiser ()
			on ui_cadreHauteur 		changed  val 	do actualiser ()
			
			on ui_decalLargeur 		changed  val 	do actualiser ()
			on ui_decalHauteur 		changed  val 	do actualiser ()
			
			
		)	 
	) -- fin attribute----
	
	
	
	
	undo "Creer Zinc" on (
		
		local b_freeze = false

		fn g_filter o = superclassof o == shape
		
		fn creerZinc 	sh_dest =(
			
			--------- CREATION DU ZINC --------
			with redraw off (
				
				---- LES PLAQUES DU FOND ----
				-- creation du shape -----
				sh_fond 				= reference sh_dest
				sh_fond.name 		= sh_dest.name + "_zinc_fond"
				sh_fond.material 	= sh_dest.material
				if b_freeze do freeze sh_fond
				
				-- application du floor gen -----
				mod_fond = FloorGenerator  name:"Zinc_fond"
				mod_fond.Extrude 			= 0.2
				mod_fond.Bevel 				= 0.5
				mod_fond.Grout_L 			= on
				mod_fond.GroutLength 		= 0
				mod_fond.MinRowOffset 	= 50
				addmodifier sh_fond ( mod_fond )
				
				---- LES JOINTS ----
				-- creation du shape -----
				sh_joints 			= reference sh_dest
				sh_joints.name 	= sh_dest.name + "_zinc_joints"
				sh_joints.material = sh_dest.material
				if b_freeze do freeze sh_joints
				
				-- application du floor gen -----
				mod_joints = FloorGenerator name:"Zinc_joints"
				mod_joints.Tilt 				= 0
				mod_joints.Bevel 				= 0.5
				mod_joints.Grout_L 			= off
				mod_joints.GroutLength 	= 0
				mod_joints.MinRowOffset 	= 0
				addmodifier sh_joints ( mod_joints )
				
				---- LE CADRE ----
				-- creation du shape -----
				sh_cadre 				= reference sh_dest
				sh_cadre.name 		= sh_dest.name + "_zinc_cadre"
				sh_cadre.material 	= sh_dest.material
				if b_freeze do freeze sh_cadre
				
				mod_cadreExtr 				= Extrude name:"Zinc_extrude"
				mod_cadreExtr.capStart 	= off
				mod_cadreExtr.capEnd 		= off
				mod_cadreExtr.segs 		= 1
				
				mod_cadreShell 					= Shell name:"Zinc_shell"
				mod_cadreShell.straightenCorners = on
				
				addmodifier sh_cadre ( mod_cadreExtr )
				addmodifier sh_cadre ( mod_cadreShell )
				
				---- LE MODIFIEUR GLOBAL----
				----reference de l'original ----
				sh_new = reference sh_dest
				delete sh_dest
				sh_dest = sh_new
				sh_fond.parent 	= sh_dest
				sh_joints.parent 	= sh_dest
				sh_cadre.parent 	= sh_dest
				
				-- Creation du modifieur ----
				mod_global = EmptyModifier name: "Zinc"
				addmodifier sh_dest ( mod_global )
				custAttributes.add  mod_global 	data_zinc
				
				---- liaison des shape au modifier ---
				mod_global.shp_fond[1] 	= 	( nodeTransformMonitor node:sh_fond 	forwardTransformChangeMsgs:false )
				mod_global.shp_joints[1] 	= 	( nodeTransformMonitor node:sh_joints 	forwardTransformChangeMsgs:false )
				mod_global.shp_cadre[1] 	= 	( nodeTransformMonitor node:sh_cadre 	forwardTransformChangeMsgs:false )
				
				---- Actualisation des parametres ----
				
				--sh_dest.modifiers["Zinc"].zincData.paramsZinc.actualiser ()
				
				-- fond --
				mod_fond.length 				= mod_global.hauteur
				mod_fond.width 				= mod_global.largeur
				mod_fond.direction			= mod_global.orientation
				mod_fond.Tilt 					= mod_global.tilt
				mod_fond.Extrude 			= 0.2
				mod_fond.Bevel 				= 0.5
				mod_fond.Grout_L 			= on
				mod_fond.GroutLength 		= 0
				mod_fond.MinRowOffset 	= 50
				mod_fond.ObjOffsetY		= mod_global.decalLargeur
				mod_fond.ObjOffsetX		= mod_global.decalHauteur
				
				-- joints --
				mod_joints.length 			= mod_global.hauteur
				mod_joints.width 				= mod_global.jointsLargeur
				mod_joints.direction			= mod_global.orientation
				mod_joints.Extrude 			= mod_global.jointsHauteur
				mod_joints.Tilt 					= 0
				mod_joints.Bevel 				= 0.5
				mod_joints.Grout_L 			= off
				mod_joints.GroutLength 	= 0
				mod_joints.MinRowOffset 	= 0
				mod_joints.GroutWidth 		= mod_global.largeur -  mod_global.jointsLargeur
				mod_joints.ObjOffsetY		= mod_global.decalLargeur
				mod_joints.ObjOffsetX		= mod_global.decalHauteur
				
				-- cadre --
				mod_cadreExtr.amount 				= mod_global.cadreHauteur
				mod_cadreShell.innerAmount 		= mod_global.cadreLargeur / 2
				mod_cadreShell.outerAmount 	= mod_global.cadreLargeur / 2 
				-- Liaisons des parametres au modifieurs ----
				
-- 				paramWire.connect2Way $.modifiers[1].largeur <value>rightParam <string>leftExpr <string>rightExpr 
				
				---- APPLICATION DES PARAMETRES ZINC -----
				
				
				---- SELECTION DES ELEMENTS DU ZINC CRééS ----
				select sh_dest
				
			)
			redrawViews ()
		)
		
		
		
		---- on gere si on a ou pas une selection ---
		local selec = selection as array		
		if selec.count != 0 then 
			for obj in selec do	
				if superclassof obj == shape do 
					creerZinc obj
			
		---- on pique le shape de base ----
		else (
			local sh_pique	= pickObject message:"Piquer le shape de base pour zinc" prompt:"Piquer le shape de base pour zinc:" filter:g_filter
			creerZinc sh_pique		
		)
		
		
	) -- fin undo -------
	
	
	
) -- fin macro ----------