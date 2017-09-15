


	
macroScript RechercherSurNet
category:"#CPages"
buttonText:"Rechercher"
toolTip:"Rechercher sur le net."
(
	rollout RollRechercher "Rechercher sur le web" width:259 height:52
	(
		edittext 'edt_texture' "" pos:[54,6] width:147 height:16 align:#left
		label 'lbl_texture' "Textures :" pos:[5,8] width:52 height:18 align:#left
		button 'btn_texture' "Chercher" pos:[204,7] width:50 height:17 align:#left
		
		edittext 'edt_model' "" pos:[54,26] width:147 height:16 align:#left
		label 'lblmodele' "Modèle :" pos:[5,28] width:40 height:18 align:#left
		button 'btn_model' "Chercher" pos:[204,27] width:50 height:17 align:#left
		
		
		fn rechercher_texture mot =(	
			command = "ShellLaunch \"Chrome.exe\" @\"https://www.textures.com/search?q=" + mot + "\""
			execute command
		)
		fn rechercher_MODEL mot =(		
			command = "ShellLaunch \"Chrome.exe\" @\"https://3dsky.org/search?query=" + mot + "\""
			execute command
		)
		
		
		
		on edt_texture entered _text do	
			rechercher_texture  _text 
		
		on btn_texture pressed do
			rechercher_texture	 edt_texture.text 		
		
		on edt_model entered _text do
			rechercher_MODEL  _text 
		
		on btn_model pressed do
			rechercher_MODEL  edt_texture.text  
		

	)


	createdialog RollRechercher
)