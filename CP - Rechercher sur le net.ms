macroScript RechercherSurNet
category:"#CPages"
buttonText:"Rechercher"
toolTip:"Rechercher sur le net."
(
	rollout RollRechercher "Rechercher sur le web" width:259 height:56
	(
		edittext 'edt_texture' "" pos:[54,4] width:147 height:15 align:#left
		label 'lbl_texture' "Textures :" pos:[5,3] width:52 height:18 align:#left
		button 'btn_texture' "Chercher" pos:[201,4] width:50 height:16 align:#left
		
		edittext 'edt_model' "" pos:[54,20] width:147 height:15 align:#left
		label 'lblmodele' "Modèle :" pos:[5,19] width:40 height:18 align:#left
		button 'btn_model' "Chercher" pos:[201,20] width:50 height:16 align:#left
		

		edittext 'edt_osm' "" pos:[54,36] width:147 height:15 align:#left
		label 'lbl_osm' "OSM :" pos:[5,35] width:40 height:18 align:#left
		button 'btn_osm' "Chercher" pos:[201,36] width:50 height:16 align:#left
		
		
		
		fn formaterTexte 	_texte =(
			substituteString 	_texte " " "%20"
		)
		
		
		fn rechercher_texture mot =(	
			mot = formaterTexte 	mot
			command = "ShellLaunch \"Chrome.exe\" @\"https://www.textures.com/search?q=" + mot + "\""
			execute command
		)
		fn rechercher_MODEL mot =(		
			mot = formaterTexte 	mot
			command = "ShellLaunch \"Chrome.exe\" @\"https://3dsky.org/search?query=" + mot + "\""
			execute command
		)
		fn rechercher_OSM mot =(		
			mot = formaterTexte 	mot
			command = "ShellLaunch \"Chrome.exe\" @\"https://www.openstreetmap.org/search?query=" + mot + "\""
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
		on edt_osm entered _text do
			rechercher_OSM  _text
		on btn_osm pressed do
			rechercher_OSM  edt_texture.text
	)


	createdialog RollRechercher
)



