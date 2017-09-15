
fichierAChercher 	= "\\NAS\Données\00 - images\toiture\Rooftiles.jpg"
fichierNouveau 	= "D:\00 - images\06 - Toitures\RooftilesSlate0101_1_S.jpg"

	fn changerMap  _mat 	=(
			
							format "------------\n%\n------------\n" _mat.name
			case classOf _mat of (
				CoronaMtl:(
					maps = #(	_mat.texmapDiffuse,
									_mat.texmapReflect,
									_mat.texmapReflectGlossiness,
									_mat.texmapRefract,
									_mat.texmapRefractGlossiness,
									_mat.texmapOpacity,
									_mat.texmapBump,
									_mat.texmapTranslucency,
									_mat.texmapReflectAnisotropy,
									_mat.texmapReflectAnisotropyRotation,
									_mat.texmapIor,
									_mat.texmapFresnelIor,
									_mat.texmapDisplace,
									_mat.texmapReflectBgOverride,
									_mat.texmapRefractBgOverride,
									_mat.texmapSelfIllum )
									
					for map in maps do (
						if map != undefined do (
							format "	------------\n	%\n" map.name
							if classof map == Bitmaptexture do (
								format "%\n" map.fileName
								if map.fileName == fichierAChercher do
									map.fileName = fichierNouveau
							)
						)
					)
					
				)
				default: ()
			)
			
		) -- fin changerMap ---------------
		
		
		
		
		fn changerMapToNodes  	_objects =(
			
			
			--- on creer la liste des materiaux -------
			local listeMats = #()
			for obj in selection do appendIfUnique listeMats	obj.material
			
			--- on traite la question pour les mltimat et des mats de base ----
			for mat in listeMats do if mat != undefined do
				if classOf mat == Multimaterial then
					for subMat in mat do
						changerMap 	subMat	
				else
					changerMap	mat	
			
		) -- fin changerMapToNodes ---------------












changerMapToNodes  (selection as array )
	