

---- retirere affichage des maps des textures dans le viewport (qui deconne des fois alors autant rien afficher )

for obj in selection do (
	if obj.material != unedfined do (
		showTextureMap obj.material on
		showTextureMap obj.material off
	)
)


--------






listeCams = selection as array
camsRendu = #()

for cam in listeCams do 
	if classof cam != Targetobject  do(
		format "----\n"
	camRendu = reference cam
	camRendu.name = cam.name + "- rendu"
	camRendu.transform.controller = cam.transform.controller
	
-- 	if classOf cam == Targetcamera do 
-- 	camRendu.target.transform.controller = cam.target.transform.controller
	
	append camsRendu camRendu

)

select camsRendu

---------------------------------------
	
		
		fn appliquerModif _mat =(
			
			case classOf _mat of (
				CoronaMtl:(
					_mat.fresnelIor = 1.53
				)
			)
			
			
		)
		
		
		
		
		
		
		fn appliquerModifToNodes  	_objects =(
			
			m_teinteMap 		= CoronaColor name:"cp_TeintDif - Color"
			
			--- on creer la liste des materiaux -------
			local listeMats = #()
			for obj in selection do appendIfUnique listeMats	obj.material
			
			--- on traite la question pour les mltimat et des mats de base ----
			for mat in listeMats do if mat != undefined do
				if classOf mat == Multimaterial then
					for subMat in mat do
						appliquerModif subMat	
				else
					appliquerModif	mat	
			
		)


		appliquerModifToNodes selection