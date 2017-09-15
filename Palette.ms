


plugin shape palette			-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
name:"Palette"
classID:#(356567364921,5756443256)
extends:rectangle version:1
category:"CP"
replaceUI:true 
autoPromoteDelegateProps:true

(
	----------	declarations locales plug		--------------------									--	<-- variables localces MASTER_helper ( accessible depuis l'exterieur)

	
-- 	local cadre 
	local ecouteur
	

	fn title_placement =	(
		
-- 		BoundingTemp = nodeGetBoundingBox   title.node 		cadre.node.transform
		--groupTemp[1].pivot.z = BoundingTemp[1].z
-- 		fo
		
		BoundingTemp = nodeGetBoundingBox   this.title.node 		this.cadre.node.transform
		
		this.title.node.pos 	= this.cadre.node.pos	+	[ - this.longueur/2 - BoundingTemp[1].x/ 2 , this.largeur/2 , 0 ]
	)
	
	
	fn cadre_ecouteur = (
-- 		format "cadre_ecouteur ->	 		cadre: %		cadre.node: %\n"		cadre		cadre.node
		try ( deleteChangeHandler ecouteur ) catch ()
		try (
			
			ecouteur  = 	when children  this.cadre.node	 change		id:#kris_palette_children	 _obj  do
			(
				if _obj.children.count > 0 do (
					_new_node = _obj.children[_obj.children.count]
					_old_transf = _new_node.transform
					for _index 	= 1 to  ( _obj.children.count - 1 )  do
						if 	(areNodesInstances _obj.children[_index]	 _new_node ) 		
						do if classof _new_node != palette do (
								_new_node.parent = undefined
								_new_node.transform = _old_transf
								format "Instance deja present dans cette palette"
								select _obj.children[_index]
							)
				)
			)-- fin ecouteur
		) catch ()
	)
	
	
	
	
	parameters params 		rollout:roll_Palette
	(
		title				type:#maxObject
		cadre				type:#maxObject
		titre_txt			type:#string			ui:edt_titre				default:"Titre"
		taille_titre		type:#float				ui:spn_texte			default:10
		
		largeur			type:#float				ui:spn_largeur
		longueur			type:#float				ui:spn_longueur
		corner			type:#float				ui:spn_corner
		
	)
	
	
	rollout roll_Palette "Palette" width:162 height:140
	(
		spinner 	spn_texte 		"" pos:[97,38] width:57 height:16 range:[0,1e+010,0]
		edittext 	edt_titre 		"" pos:[45,5] width:108 height:17
		label 		lbl_titre 			"Titre :" pos:[13,6] width:35 height:15
		label 		lbl_taille 		"Taille du texte : " pos:[14,38] width:78 height:15
		spinner 	spn_largeur 	"" pos:[97,58] width:57 height:16 range:[0,1e+010,0]
		label 		lbl3 				"Hauteur : " pos:[14,58] width:78 height:15
		spinner 	spn_longueur 	"" pos:[97,78] width:57 height:16 range:[0,1e+012,0]
		label 		lbl4 				"Longueur :" pos:[14,78] width:78 height:15
		spinner 	spn_corner 	"" pos:[97,98] width:57 height:16 range:[0,1e+012,0]
		label 		lbl5 				"Corner : " pos:[15,98] width:78 height:15
		/*	
		button test	"test"	width:78 height:15
	 on test pressed do (
-- 			format "owner : %		this: %		$: %\n"	owner	this 	$
-- 			format "delegate : %	this.pos: %\n"	delegate		this.pos
			
			BoundingTemp = nodeGetBoundingBox   title.node 		cadre.node.transform
-- 			BoundingTemp[1].x
			format "BoundingTemp: %		BoundingTemp[1].x: %\n" BoundingTemp		BoundingTemp[1].x
		
			
		) */
		on edt_titre changed  text do
			if  title != undefined do title.node.text  = text
		
	

	)
	
	tool create
	(
		local startPoint
		
		on mousePoint click do (
			case click of	(
				1: (
					
					
					-- cadre------------------------------
					
					cadre = nodeTransformMonitor node:$	forwardTransformChangeMsgs:false
					cadre.node.name = uniquename "Cadre "
					
					
					startPoint = nodeTM.translation = gridPoint
					
					delegate.render_displayRenderMesh = false 
					delegate.optimize = true	
					delegate.adaptive = false	
					delegate.sides=8
					delegate.steps = 6
					delegate.cornerRadius	= 0
					
					largeur.controller 		= bezier_float ()
					longueur.controller 	= bezier_float ()
					corner.controller 		= bezier_float ()
					
					
					delegate.length.controller	=	largeur.controller
					delegate.width.controller	=	longueur.controller
					delegate.cornerRadius.controller	=	corner.controller
					
					
					
					
					
					-- title ---------------------
					_node = text text:"Titre"	name:(uniquename "Cadre - titre ")
					title = nodeTransformMonitor \
								node:_node \
								forwardTransformChangeMsgs:false	\
								render_displayRenderMesh:false 
					
					--	position--
					title.node.parent 	= cadre.node
-- 					title.node.pos 		= cadre.node.pos	+	[ - longueur/2 , largeur/2 , 0 ]
					title_placement ()
					
					--	contros--
					title.node.size.controller = bezier_float ()
 					taille_titre.controller = bezier_float ()
					
					title.node.wirecolor = cadre.node.wirecolor
					
					title.node.size.controller = taille_titre.controller
					
					cadre_ecouteur ()
					
				)
				
				4: 	#stop
			)	-- fin case
		) -- fin click	----------------------
		
		on mouseMove click do (
			case click of	(
				2: (
						delegate.length				= abs gridDist.y --* 2
						delegate.width				= abs gridDist.x --* 2
						nodeTM.translation 			= startpoint + gridDist/2.0
						nodeTM.translation.z 		= 0.0
						title_placement ()
					) -- fin 2: ----
				3:	delegate.cornerRadius		= abs gridDist.y
				4: (	title.node.size					= abs gridDist.y	;	title_placement ()	)
				
			) -- fin case click of----
		)-- fin mouseMove -------
		
	)-- fin tools create --------
	
	
	
	
	
	
	
	on postLoad do (
-- 		format "PAD load pour init les struct ...à faire...\n" 
		cadre_ecouteur ()			
		format "palette load : 		this: "this
	)
	

) --fin plugin-------













/* 

when children  selection change		id:#kris_groupes_proxies	 _obj  do
(
	_new_node 	= _obj.children[_obj.children.count]
	format  "EVENT > #kris_groupes_proxies : %\n"	_obj
	for _index = 1 to  ( _obj.children.count - 1 )  do( 
		if 	(areNodesInstances _obj.children[_index]	 _new_node ) 		do _new_node.parent = undefined
	)
)

 */









