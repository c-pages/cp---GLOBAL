

macroscript transf_aleatoire 
category:"#CPages" 
buttonText:"Transf. alea."
tooltip:"Echelle et RotZ aleatoire "
(

	for obj in selection do (
		
		---- echelle ----
		local maxEchelle = 0.1
		local randEchelle = random ( 1. - maxEchelle ) ( 1. + maxEchelle ) 
		in coordSys Local scale obj [ randEchelle, randEchelle, randEchelle]
		
		---- rotation Z ----
		local maxRotZ = 360
		local randRotZ = random 0 maxRotZ
		in coordSys Local rotate obj (angleaxis randRotZ [0,0,1])
		
	)


	redrawViews ()
	
)


macroscript selectByWirecolor 
category:"#CPages" 
buttonText:"Select wirecolor"
tooltip:"Selectionne les obj ayant la meme couleur wire"
(

	


	fn selectByWireColor		_color =(
		clearSelection ()
		for obj in objects where not obj.isHidden and obj.wireColor == _color 
			do selectmore obj
		
	)
	
	cible = selection as array
	if cible.count == 1 do
		selectByWireColor	cible[1].wirecolor


)

macroscript transf_instanceAndReplace 
category:"#CPages" 
buttonText:"Inst. replace"
tooltip:"Remplace les nodes selectionnés par les instances du node pické."
(

	undo "remplacer selection" on (

		-- fn g_filter o = superclassof o == Geometryclass
		fn remplacer =(

				local nodesARemplacer 	= selection as array
				local nodeAInstancier 		= pickObject message:"Pick node à instancier:" prompt:"Pick node à instancier:"--filter:g_filter
				
			with redraw off (
	-- 			clearSelection ()
				
				if nodeAInstancier != undefined do (
					for cible in nodesARemplacer do (
						local nvNode = instance nodeAInstancier
						in coordSys world  nvNode.transform = cible.transform
	-- 					selectMore nvNode
					)
				)
			)
			select nodesARemplacer
		)
	
		remplacer()
		
	)
)
macroscript transf_selectInstances
category:"#CPages" 
buttonText:"Inst. select"
tooltip:"Selectionner les nodes instances du node selectionné."
(
	
	undo "remplacer selection" on (
		fn selectInstances _nodeBase =(
			local copains =#(_nodeBase)
			max create mode
			
			with redraw off (
				for obj in objects /* where classOf obj == classOf _nodeBase */ do (
					if areNodesInstances  obj _nodeBase do
						append copains obj
				)

			)
			select copains
		)

		selectInstances $
	)
)