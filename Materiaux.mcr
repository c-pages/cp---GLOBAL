
/*#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

	----	MATERIAUX	----
	Quelques macros pour manipuler les materiaux avec racourcis clavier.
	
##########################################################################################################################
	todo:	
	-	Ouvrir les materiaux d'une selection mutliple dans le SME.
	-	Créer les racourcis claviers en auto.
##########################################################################################################################
	changelog:
	*v0.0 - [16/09/2016] -----------------------------------------------------------------------------
	- Mise en place globale dans un seul fichier.	
########################################################################################################################*/
/* 
		
		append ( sme.GetMtlInParamEditor() ).mapList ( CoronaColor ()	 )
		( sme.GetMtlInParamEditor() ).blendMode[1]  = 23
		
		
		
		map = ( sme.GetMtlInParamEditor() )
		show ( sme.GetMtlInParamEditor() )
		classof ( sme.GetMtlInParamEditor() )
		classof map

			for obj in selection  do 
					for subMat in obj.material do
						subMat.texmapDiffuse.
		
		
		popo = Color_Correction ()
		popo.map
		show popo
		 */
----------------------------------------------------------------------------------------------------------------------------
---- Appliquer UVWmpa avec : real  ------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
macroScript map_TeinterDiffus
category:"#CPages"
toolTip:"Appliquer kit Donner une teinte au diffus des objets selectionnés."
buttonText:"mapKit Teinter"
(
	local m_teinteMap 
	
	/* 
	
	----- manipulaition de l'opacité de la teinte -----
	fn setTeinteOpacity 	_mat 	param: 	=(
		if _mat.texmapDiffuse != undefined do (
			if 	_mat.texmapDiffuse.name == "cp_TeintDif - Compo" do (
				_mat.texmapDiffuse.opacity[2]  	= param
				_mat.texmapDiffuse.blendMode[2]  	= 23
			)
		)
	)
	
	fn appliquerFonctionMapToNodes  	_objects 	_fonction	param:  =(
			
			m_teinteMap 		= CoronaColor name:"cp_TeintDif - Color"
			
			--- on creer la liste des materiaux -------
			local listeMats = #()
			for obj in selection do if obj.material != undefined do appendIfUnique listeMats	obj.material
			
			--- on traite la question pour les mltimat et des mats de base ----
			for mat in listeMats do if mat != undefined do
				if classOf mat == Multimaterial then
					for subMat in mat do
						_fonction subMat		param:param
				else
					_fonction	mat		param:param
			
		)
	
	fn 	setTeinteOpacityToSelection 	_val =(
		
		appliquerFonctionMapToNodes selection  setTeinteOpacity 	param:_val
	)

	setTeinteOpacityToSelection  33
	
	
	  */
	
	
	
	
	----- creation du kit de la teinte -----
	with undo "map_TeinterDiffus" on (
		
		fn appliquerKitTo _mat =(
			
			case classOf _mat of (
				CoronaMtl:(
					
					local oldDiffus	 = _mat.texmapDiffuse
					
					local mapCompo 		= CompositeTexturemap ()
					mapCompo.name 		= "cp_TeintDif - Compo"
-- 					local m_teinteMap 	= CoronaColor ()
					
					append mapCompo.mapList 	m_teinteMap
					mapCompo.blendMode[2]  	= 23
					mapCompo.opacity[2]  		= 30
					
					if oldDiffus != undefined do
						mapCompo.mapList[1] =  oldDiffus
					_mat.texmapDiffuse = mapCompo
				)
				default: format "ATTENTION : fonctionne uniquement avec materiaux Corona : %.\n" _mat.name
			)
			
			
		)
		
		
		
		
		
		
		fn appliquerKitToNodes  	_objects =(
			
			m_teinteMap 		= CoronaColor name:"cp_TeintDif - Color"
			
			--- on creer la liste des materiaux -------
			local listeMats = #()
			for obj in selection do appendIfUnique listeMats	obj.material
			
			--- on traite la question pour les mltimat et des mats de base ----
			for mat in listeMats do if mat != undefined do
				if classOf mat == Multimaterial then
					for subMat in mat do
						appliquerKitTo subMat	
				else
					appliquerKitTo	mat	
			
		)


		appliquerKitToNodes selection
	)
)

--------------------------------------------------------------------------------------------------------------------------------
---- Appliquer UVWmpa avec : real  ------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
macroScript map_AjouterTransluVeget
category:"#CPages"
toolTip:"Appliquer kit translucide pour vegetation a partir les maps de diffus de la selection."
buttonText:"mapKit Translu"
(

	with undo "map_AjouterTransluVeget" on (
		
		fn appliquerKitTo _mat =(
			case classOf _mat of (
				CoronaMtl:(
					
					
					local mapTranslu 				= Color_Correction ()	
					mapTranslu.name 				= "cp - Translu veget."
					mapTranslu.map					= _mat.texmapDiffuse
					mapTranslu.lightnessMode		= 1
					mapTranslu.gammaRGB			= .5
					
					_mat.texmapTranslucency 	= mapTranslu
					_mat.levelTranslucency			= .4
					
				)
				default: format "ATTENTION : fonctionne uniquement avec materiaux Corona.\n"
			)
			
			
		)
		
		
		
		
		
		
		fn appliquerKitToNodes  	_objects =(
			
			--- on creer la liste des materiaux -------
			local listeMats = #()
			for obj in selection do appendIfUnique listeMats	obj.material
			
			--- on traite la question pour les mltimat et des mats de base ----
			for mat in listeMats do 
				if classOf mat == Multimaterial then
					for subMat in mat do
						appliquerKitTo subMat	
				else
					appliquerKitTo mat	
			
			
			
		)


		appliquerKitToNodes selection
	)
)



--------------------------------------------------------------------------------------------------------------------------------
---- Appliquer UVWmpa avec : real  ------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
macroScript map_KitMultiScatter
category:"#CPages"
toolTip:"Appliquer kitmultiscatter sur les maps de diffus de la selection."
buttonText:"mapKit Mltsc."
(
	with undo "KitMultiScatter" on (
		
-- 		fn appliquerMapsTo 	 _mat  =(
			
		fn getNouveauKit 	=(
			
			---- les maps ----
			local mapSortie 			= Color_Correction ()	
			local mapMix 				= Mix ()	
			local mapMultiMap 		= CoronaMultiMap ()
			local mapMultiScatt 	= MultiScatterTexture ()	
			local mapVar1 			= Color_Correction ()
			local mapVar2 			= Color_Correction ()
			local mapVar3 			= Color_Correction ()	
			local mapEntree 			= Color_Correction ()
			
			---- creer les liaisons	-----
			mapSortie.name 				= "Mltscat. Kit - Sortie"
			mapSortie.map 				= mapMix	
			
			mapMix.name 					= "Mltscat. Kit - Mix"
			mapMix.mixAmount			= 50
			mapMix.map1					= mapMultiMap
			mapMix.map2					= mapMultiScatt	
			
			mapMultiScatt.name 				= "Mltscat. Kit - MultiScatt"
			mapMultiScatt.Use_Object_Color = true
			mapMultiScatt.Mix_Value 			= .5
			
			mapMultiMap.name 			= "Mltscat. Kit - MultiMap"
			mapMultiMap.mode 			= 2
			mapMultiMap.items			= 3
			mapMultiMap.texmaps[1]	= mapVar1
			mapMultiMap.texmaps[2]	= mapVar2
			mapMultiMap.texmaps[3]	= mapVar3
			
			mapVar1.name 				= "Mltscat. Kit - Variance 1"
			mapVar1.map 					= mapEntree
			mapVar1.lightnessMode		= 1
			mapVar1.gammaRGB			= .66
			
			mapVar2.name 				= "Mltscat. Kit - Variance 2"
			mapVar2.map 					= mapEntree
			mapVar2.lightnessMode		= 1
			mapVar2.gammaRGB			= 1
			
			mapVar3.name 				= "Mltscat. Kit - Variance 3"
			mapVar3.map 					= mapEntree
			mapVar3.lightnessMode		= 1
			mapVar3.gammaRGB			= 1.33
			
			/* 
			local vueSME = sme.GetView 2
			
			vueSME.CreateNode mapSortie	[0,0]
			sme.SetMtlInParamEditor mapSortie
			*/
			
			#( mapSortie, mapEntree )
			
		)
		
		
		fn appliquerMapsTo _mat =(
			case classOf _mat of (
				CoronaMtl:(
					local b_skip = false
					if _mat.texmapDiffuse != undefined do
						if _mat.texmapDiffuse.name == "Mltscat. Kit - Sortie" do 
							b_skip = true
							
						
					if not b_skip do	(
						local kit = getNouveauKit ()
						local oldDiffus	 = _mat.texmapDiffuse
						_mat.texmapDiffuse = kit[1]
						
						if oldDiffus != undefined do
							kit[2].map = oldDiffus
					)
				)
				default: format "ATTENTION : fonctionne uniquement avec materiaux Corona.\n"
			)
			
			
		)
		
		
		
		
		
		
		fn ajouterMapsPrMultiScatterText  	_objects =(
			
			--- on creer la liste des materiaux -------
			local listeMats = #()
			for obj in selection do appendIfUnique listeMats	obj.material
			
			--- on traite la question pour les mltimat et des mats de base ----
			for mat in listeMats do 
				if classOf mat == Multimaterial then
					for subMat in mat do
						appliquerMapsTo subMat	
				else
					appliquerMapsTo mat	
			
			
			
		)


		ajouterMapsPrMultiScatterText selection

		/* 
		
		append ( sme.GetMtlInParamEditor() ).mapList ( CoronaColor ()	 )
		( sme.GetMtlInParamEditor() ).blendMode[1]  = 23
		
		
		
		map = ( sme.GetMtlInParamEditor() )
		show ( sme.GetMtlInParamEditor() )
		classof ( sme.GetMtlInParamEditor() )
		classof map

			for obj in selection  do 
					for subMat in obj.material do
						subMat.texmapDiffuse.
		
		
		popo = Color_Correction ()
		popo.map
		show popo
		 */
	)
)


--------------------------------------------------------------------------------------------------------------------------------
---- Appliquer UVWmpa avec : real  ------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
macroScript mat_UVWmap_RealWorldMap_Box
category:"#CPages"
toolTip:"Appliquer UVWmap à la selection avec : Real-World Map size en Box."
buttonText:"UVW Real"
(
	with undo "mat_UVWmap_RealWorldMap_Box" on (
		for obj in selection do (
			
			local uvMap = Uvwmap ()
			
			uvMap.realWorldMapSize = on
			uvMap.maptype = 4
			uvMap.utile = 1
			uvMap.vtile = 1
			uvMap.length = 1
			uvMap.width = 1
			uvMap.height = 1
			
			addModifier obj  uvMap
		)
	)
	
)







--------------------------------------------------------------------------------------------------------------------------------
---- Copier le materiau de la selection dans le clipboard ------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
macroScript mat_cleanAXYZ
category:"#CPages"
toolTip:"Nettois les trucs pourris de persos AXYZ (self illumination)"
buttonText:"Clean AXYZ"
(
	for obj in selection do (
		obj.material.levelSelfIllum = 0
		obj.material.texmapSelfIllum = undefined	
	)
)


--------------------------------------------------------------------------------------------------------------------------------
---- Copier le materiau de la selection dans le clipboard ------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
macroScript mat_copier
category:"#CPages"
-- toolTip:"Copier le materiau de la selection dans le clipboard."
-- buttonText:"Copy Mat"
(
global matClipboard
	if selection.count == 1 then (
		if $.material != undefined then (
			matClipboard = $.material
			format 	"<mat> Copier :%\n"	matClipboard
		) else format "<mat> Copier : L'objet sélectionné n'a pas de matériau.\n"
	) else format 	"<mat> Copier : Un seul objet doit etre sélectionné pour copier un matérau.\n"
)





--------------------------------------------------------------------------------------------------------------------------------
---- Coller le materiau du clipboard ----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
macroScript mat_coller
category:"#CPages"
-- toolTip:"Coller le materiau du clipboard."
-- buttonText:"Paste Mat"
( 
	global matClipboard
	if matClipboard != undefined 
		then (
			for obj in selection do 	obj.material = matClipboard
			format 	"<mat> Coller :%\n"	matClipboard
		) else	format 	"<mat> Coller : Clipborad vide, rien à coller. \n"
	
	redrawViews()
)





--------------------------------------------------------------------------------------------------------------------------------
---- Ouvrir les materiaux de la sélection dans le SME --------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
macroScript mat_ouvrir
category:"#CPages"
-- toolTip:"Ouvrir les materiaux de la sélection dans le SME."
-- buttonText:"ouvrir Mat"
(
	local	nomFenetre = "Edit"
	local fenetre
	local IndexFenetre
	local matsAAfficher = #()
	
	--- on ouvre le sme
	sme.Open() 	
	
	-- on regarde si une fenetre "edit mat" est ouverte
	IndexFenetre = sme.GetViewByName   nomFenetre
	if IndexFenetre == 0 
		then 	sme.CreateView  nomFenetre
	fenetre =  sme.GetView (sme.GetViewByName   nomFenetre  )

	--show fenetre
	fenetre.SelectAll()
	fenetre.DeleteSelection()
	
	-- on fait la liste des materiaux sans doublons --
	for obj in selection as array do 
		if obj.mat !=undefined do
			appendIfUnique matsAAfficher obj.mat
	
	---- fonction pour connaitre le nombre de nioveaux de maps qu'il y a dans le materiau ----
	fn getHierarchieLvl	objet =(
		local hierarchieLvl_local			= 1
		local hierarchieLvl_Max  			= 0
		local listePropsNomsObjet 		= getPropNames objet
		local listePropsNomsSousObjet 	= #()		
		
		for propNom in listePropsNomsObjet do (
			if propNom != #bitmap do (
				prop = getProperty objet 	propNom
				if superClassOf prop == textureMap do (
					append listePropsNomsSousObjet prop
					hierarchieLvl_local += ( getHierarchieLvl prop )
				)
			)
			
			if hierarchieLvl_local > hierarchieLvl_Max then 
				hierarchieLvl_Max = hierarchieLvl_local	
			
			hierarchieLvl_local	= 1			
		) 
		
		hierarchieLvl_Max 		
	)
	
	---- on repartit les mateiraus dans le SME ----
	posOrigine = [0,0]
	ecart_mat = [-200,0]
	ecart_map = [-250,0]
	for mat in matsAAfficher as array do (
		local lvl = ( getHierarchieLvl 	mat ) - 1 
		fenetre.createNode mat posOrigine
		posOrigine += ecart_mat + ( lvl * ecart_map )
	)
	
	fenetre.ZoomExtents()
	sme.SetMtlInParamEditor (selection as array)[1].material
	
)







--------------------------------------------------------------------------------------------------------------------------------
---- Ouvrir les materiaux de la sélection dans le SME --------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
macroScript mat_SelectByMat
category:"#CPages"
toolTip:"Selectionner les nodes portant le meme material que les objets selectionnés"
buttonText:"Select Mat"
(

	
	if selection.count >0 then ( 
		matsACharcher = #()
		for obj in selection do
			appendIfUnique matsACharcher 	obj.material
		
-- 		matACharcher = selection[1].material

		--- le material ouvert dans le SME -----
		l_nodes = #()
		for obj in geometry do (
			mat = obj.material
			for matACharcher in matsACharcher do (
				if mat == matACharcher then 
					appendIfUnique l_nodes obj
				else 	if classof mat == Multimaterial then
							for ssMat in mat do
								if ssMat == matACharcher do 
									appendIfUnique l_nodes obj
			)
			
			
		)
		select l_nodes
	)
	
) --- fin macro






















