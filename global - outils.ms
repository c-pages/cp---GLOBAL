
/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	OUTILS GLOBAUX
	Regroupe differentes fonctions manipulant matrices, nodes, scenes ...
	
##########################################################################################################################
	todo:	
##########################################################################################################################
	changelog:
	*v0.1 - [22/09/2016] -----------------------------------------------------------------------------
	- Mise en place globale 
######################################################################################################################## 
*/


( 



	------------------------------------------------------------------------------------------------------------------------------------------
	----	Structs 	Secondaires ------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------
	---- Tableau ----------------------------------------------------------------------------------------------------------------------------------------------
	struct tableau_struct (
		
		-- 	Renvois true si  #premierTab  est égale à   #deuxiemeTab. --
		fn comparer  tab1 tab2  = (
			local result = true
			if tab1.count != tab2.count then
				result = false
			else
				for i = 1 to tab1.count do
					if tab1[i] != tab2[i] do result = false
			result
		),
		
		-- 	Supprime les doublons de  #tableau de tableaux. --
		fn supprimerDoublons 	 tableauDeTableaux  = (
			for i = 1 to tableauDeTableaux.count do (
				for j = tableauDeTableaux.count to i+1 by -1 do (
					test = ( comparer  tableauDeTableaux[i] 	tableauDeTableaux[j] )
					if test do
						deleteItem tableauDeTableaux	 j
				)--end j loop
			)--end i loop
		)
		
	) -- fin struct tableau --

	---- Matrices ----------------------------------------------------------------------------------------------------------------------------------------------
	struct matrice_struct (
		prt ,	
		
		-- 	renvois une matrice Rotation de la normal  --
		fn rotate_X 	normalFace  angleEnDeg 	= (
			local result	=  (eulerAngles angleEnDeg 0 0) as matrix3 * ( matrixFromNormal normalFace )
			result
		),
		-- 	renvois une matrice Rotation de la normal  --
		fn rotate_Y 	normalFace    angleEnDeg 	= (
			local result	=  (eulerAngles 0 angleEnDeg  0) as matrix3 * ( matrixFromNormal normalFace )
			result
		),
		-- 	renvois une matrice Rotation de la normal  --
		fn rotate_Z 	normalFace    angleEnDeg 	= (
			local result	=  (eulerAngles 0 0 angleEnDeg ) as matrix3 * ( matrixFromNormal normalFace )
			result
		),
		
		-- renvois une matrice de transformation dans le repere constitué du centre de la face et de sa normale --
		fn repereFace face noeud:$ =(
			local	normal 						= archi.faces.normal 		face
			local	mtrxRepereFace 			= matrixfromnormal 			normal
			local	centreFace 				= archi.faces.centre 		face
			mtrxRepereFace.translation 	= centreFace
			mtrxRepereFace
		),
		---- 	Renvois la normal  de la face, axe Y orienté vers le haut.  ----
		fn repereFaceOriente 	face 	noeud:$   marquer:false  = (
			
	-- 		local chrono_debut = timeStamp()
			
			local normalFace = archi.faces.normal		face 	noeud:noeud
			local mtrx_result 
			
			---- pour les faces horizontales   ---- 
			local angleMin = 0
			local angleMax = 0
			if archi.faces.sontHorizontal 	noeud:noeud	faces:#(face) then (
	-- 			format "Horizontal------>\n"
				
				-- on cherche l'angle Z pour que le rectangle soirt le plus petit possible
				local aireMin 			= 1e20
				local precision_1 	= .7
				local precision_2 	= .001
				
	-- 			format "\nprecision_1 : %\n"	precision_1	
				local	i = 0
				while  i < 360 do (
					local mtrx_norm = prt.outils.matrice.rotate_Z 	normalFace 	i 	noeud:noeud
					local aireTest = prt.faces.boundingAire face  	noeud:noeud	repere:mtrx_norm				
	-- 				format " 	% )	aireTest : %\n" i	aireTest				
					if i == 0 do aireMin = aireTest
					if aireTest < aireMin then (
	-- 					format " 	>>> gagne <<<\n"
						aireMin = aireTest
						angleMax = i 	--	+ precision_1
						angleMin = i - precision_1
						mtrx_result = copy mtrx_norm
						
					)
					i += precision_1
	-- 			format "b_trouveFin : %   i : %\n"	b_trouveFin	 i
					
				)
				
	-- 			local chrono_etape1 = timeStamp()
	-- 			chrono_etape1 = chrono_etape1 - chrono_debut
	-- 			format "	CHRONO ::: etape 1 : %\n"	chrono_etape1	
	-- 			format "	I etape 1 : %\n"	i				
	-- 			format "	angleMin : %	angleMax : %\n"	angleMin		 angleMax	
	-- 			format "precision_2 : %\n"	precision_2	
				
				local b_trouveDebut  	= false
				local b_trouveFin  		= false
				aireMin = 1e20
				i = angleMin
				while not b_trouveFin and i < angleMax do (
	-- 			for i = angleMin to angleMax by precision_2 do (
					local mtrx_norm = prt.outils.matrice.rotate_Z 	normalFace 	i 	noeud:noeud
					local aireTest = prt.faces.boundingAire face  	noeud:noeud	repere:mtrx_norm				
	-- 				format " 	% )	aireTest : %\n" i	aireTest					
					if i == angleMin do aireMin = aireTest		
					if aireTest < aireMin then (
	-- 					format " 	>>> gagne <<<\n"
						aireMin = aireTest
						angleMin = i
						mtrx_result = copy mtrx_norm
						b_trouveDebut = true
					) else if b_trouveDebut do (
						b_trouveFin = true
					)
					i += precision_2
				)
	-- 			format "	I etape 2 : %\n"	i	
	-- 			
	-- 			local chrono_fin = timeStamp()
	-- 			local chrono_duree = chrono_fin - chrono_debut
	-- 			format "	CHRONO::: duree : %\n"	chrono_duree
	-- 			format "---->	angle final : %\n\n" angleMin
				
			) else (
			
				-- on cherche l'angle Z pour que l'axe X soit horizontal --
				aXmin = 1e20
				precision = 1
				for i = 0 to 360 by precision do (
						mtrx_norm = prt.outils.matrice.rotate_Z 	normalFace 	i 	noeud:noeud
						ptTest = [1,0,0] * mtrx_norm
					
						if abs ptTest.z < aXmin do (
				-- 			format " 	>>> gagne <<<\n"
							aXmin = abs ptTest.z
							angleMin = i
							mtrx_result = copy mtrx_norm
						)
				)
			)
			-- pour trouver la bonne orientation 
			local matricesPourOrientation = #(
				rotate_Z 	normalFace 	( angleMin + 0 ),
				rotate_Z 	normalFace 	( angleMin + 90 ),
				rotate_Z 	normalFace 	( angleMin + 180 ),
				rotate_Z 	normalFace 	( angleMin + 270	 )		
			)
			
			local listePoints = selection as array
			local altMax = -10000000000000000000000.
			local normalFaceOriente
			
			for matrice in matricesPourOrientation do (
				ptTest = [0,1,0] * matrice
				if ptTest.z > altMax do (
					altMax = ptTest.z
					normalFaceOriente = matrice
				)
			)
			
			normalFaceOriente.translation = archi.faces.centre 	face 	noeud:noeud
			
			if marquer do (
				ptMarque1 = point 	name:(uniquename "pt Normal" ) \
											axistripod:on cross:off Box:off centermarker:off\
											wirecolor:(color 50 100 200) size:5
				ptMarque1.transform 	= normalFaceOriente
			)
			
			
			
			normalFaceOriente
			
		)
		
	) -- fin struct tableau --




	---- Scene ----------------------------------------------------------------------------------------------------------------------------------------------
	struct scene_struct (

			--  Vider la scene -------------------------------------------
			fn vider = (
				
				-- on se place sur le calque 0 ----
				calque_0 =  LayerManager.getLayerFromName "0"
				calque_0.current  = true
				calque_0.on = true
				
				---- o vide les calques de leurs objects ----
				calquesASupprimer = #()
				for i = 0 to LayerManager.count  - 1 do (				
					calque =  LayerManager.getLayer i  
					
					clearSelection()
					calque.select   true
					selec = ( selection as array )
					for nd in selec do
						try delete nd catch ()
					
					if calque.name != "0" then
						append calquesASupprimer 	calque
					
				)
				
				---- o supprimer les calques ----
				while calquesASupprimer.count != 0 do (
					calque = calquesASupprimer[calquesASupprimer.count]
					LayerManager.deleteLayerByName calque.name
					deleteItem calquesASupprimer ( calquesASupprimer.count )
				)
				
				--- les xrefs ---
				xrefs.deleteAllXRefs()
				
				---- les populates ---
				actionMan.executeAction 2061898532 "3"
				
			)
			
	) -- fin struct scene --

	---- Nodes ----------------------------------------------------------------------------------------------------------------------------------------------
	struct node_struct (
		
			--  Collapse les nodes en un seul poly -------------------------------------------
			--	(supprime tout les groupes, helpers, cameras, lumieres  ....  )	--------
			fn applatir 		_nodes = (
				
				explodeGroup _nodes 
				
				local GroupAsupprimer = #()
				local newMesh
		
				for i=1 to _nodes.count do (
					
					BoolDeleteObjet = false
					ObjetTemp = _nodes[i]
					
					if IsValidNode ObjetTemp do (				
						
						if not canConvertTo ObjetTemp Editable_Poly 	then 	
							append GroupAsupprimer 	ObjetTemp
						
						else	if ObjetTemp.isHidden 				then   delete ObjetTemp
						else (
							
							if ObjetTemp.modifiers.count != 0 do collapseStack ObjetTemp
							
							if superclassof ObjetTemp == shape do 
								if ObjetTemp.render_renderable do 
									ObjetTemp.displayRenderMesh = true
							
							if classof ObjetTemp != Editable_Poly do convertToPoly ObjetTemp
							
							if i != 1 then 
								polyop.attach newMesh 	_nodes[i]
							else newMesh = _nodes[1]
						)
							
						
					)
					
				)
				
				clearselection()
				for i=1 to GroupAsupprimer.count do
					selectmore GroupAsupprimer[i]
				delete selection
				
				newMesh
				
			),

			--  Compter le nombre de vertex de la seletion  -------------------------------------------
			fn compterVertex 	_nodes = (
				nbrVertex = 0
				for obj in _nodes do 
					try nbrVertex += obj.verts.count catch ()
				return nbrVertex
			)
			
			
	) -- fin struct node --

	---- Materiaux ----------------------------------------------------------------------------------------------------------------------------------------------
	struct mat_struct (
			----------------------------------------------------------------------------------
			--  nettoie les doublons des multimat --------------------------------------
			----------------------------------------------------------------------------------
			fn nettoyerMultimat 	ObjetCible = (
				
				local SubMatNouveau, Mat_a_nettoyer, IdMAtEnDouble, SubMatOrigine, MateriauRemplacant, aListeDesSubMatRemplacant, bPremierPassage
				Mat_a_nettoyer = ObjetCible.material
				
				if classof Mat_a_nettoyer == Multimaterial then (
					
					MateriauRemplacant = Multimaterial numsubs:0 name:(ObjetCible.name + "_Mat_multi")
					MateriauRemplacant[1] = undefined
					aListeDesSubMatRemplacant = #()
					aListe_ID_SubMatRemplacant = #()
					append aListeDesSubMatRemplacant Mat_a_nettoyer[1]
					NombreUndefined = 0

					for i=1 to Mat_a_nettoyer.count do (
						
						SubMatOrigine = Mat_a_nettoyer[i]
						
						if SubMatOrigine != undefined then 	(					
							TestDejaPresent = false
							IDOrigine = Mat_a_nettoyer.materialIDList[i-NombreUndefined]						
							for j = 1 to aListeDesSubMatRemplacant.count do (
								SubMatNouveau = aListeDesSubMatRemplacant[j]
								if SubMatNouveau.name == SubMatOrigine.name then (
									TestDejaPresent = true
									IdMAtEnDouble = J
								) 
							)
							
							if TestDejaPresent  == false then (
								append aListeDesSubMatRemplacant SubMatOrigine
								IDDestination = aListeDesSubMatRemplacant.count 
								ObjetCible.EditablePoly.selectByMaterial IDOrigine
								ObjetCible.EditablePoly.setMaterialIndex IDDestination 1
							)	else (
								if classof ObjetCible != Editable_Poly do convertToPoly ObjetCible
								
								IDDestination = IdMAtEnDouble 
								ObjetCible.EditablePoly.selectByMaterial IDOrigine
								ObjetCible.EditablePoly.setMaterialIndex IDDestination 1
							)
							
						)  else  NombreUndefined = NombreUndefined + 1
					)
					MateriauRemplacant.count = aListeDesSubMatRemplacant.count 
					for i=1 to aListeDesSubMatRemplacant.count do (
						MateriauRemplacant[i] = aListeDesSubMatRemplacant[i]
					)
					ObjetCible.material = MateriauRemplacant
				)
				
			) 	-- FIN fnNettoitMultimat
			
	) -- fin struct materiaux --






	------------------------------------------------------------------------------------------------------------------------------------------
	----	Struct 	Principale		------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------
	---- Outils ----
	struct outils_struct (
		
		---- MEMBRES ----
		tableau,	
		matrice,
		
		scene,
		node,
		mat,
		
		---- FONCTIONS ----
		fn dateToString 	_date = (
			local result 
			
			zeroJour 	= if _date[4] <10 then  "0"  else ""
			zeroMois 	= if _date[2] <10 then  "0"  else ""
			zeroH 		= if _date[5] <10 then  "0"  else ""
			zeroM 		= if _date[6] <10 then  "0"  else ""
			zeroS 		= if _date[7] <10 then  "0"  else ""
			if _date[4] != 0 then 
				result = zeroJour + _date[4] as string + "/"  + zeroMois + _date[2] as string+ "/"  + _date[1] as string + "  "  + zeroH + _date[5] as string + ":"  + zeroM  + _date[6] as string + ":"  +zeroS + _date[7] as string 
			else 
				result = ""
			
			result
		),
		
		---- EVENEMENTS ----
		on create do (
			tableau 	= tableau_struct ()
			matrice 	= matrice_struct ()
			scene		= scene_struct ()
			node 		= node_struct ()
			mat 			= mat_struct ()
		)
		
	) -- fin struct outils --


	global outils = outils_struct ()
	
) ---------------------------
















	