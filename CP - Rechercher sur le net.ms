macroScript RechercherSurNet
category:"#CPages"
buttonText:"Rechercher"
toolTip:"Rechercher sur le net."
(
	rollout RollRechercher "Rechercher sur le web" width:209 height:72
	(
		edittext 'edt_texture' "" pos:[54,4] width:147 height:15 align:#left
		label 'lbl_texture' "Textures :" pos:[5,3] width:52 height:18 align:#left
		
		edittext 'edt_model' "" pos:[54,20] width:147 height:15 align:#left
		label 'lblmodele' "Modèle :" pos:[5,19] width:40 height:18 align:#left
		

		edittext 'edt_osm' "" pos:[54,36] width:147 height:15 align:#left
		label 'lbl_osm' "OSM :" pos:[5,35] width:40 height:18 align:#left
		
		
		edittext 'edt_ral' "" pos:[54,52] width:147 height:15 align:#left
		label 'lblral' "RAL :" pos:[5,51] width:40 height:18 align:#left
		
		
		fn formaterTexte 	_texte =(
			substituteString 	_texte " " "%20"
		)
		
		
		fn rechercher_texture mot =(	
			mot = formaterTexte 	mot
			DOSCommand 	("start https://www.textures.com/search?q=" + mot + "\"")
-- 			command = "ShellLaunch \"Chrome.exe\" @\"https://www.textures.com/search?q=" + mot + "\""
-- 			execute command
		)
		fn rechercher_MODEL mot =(		
			mot = formaterTexte 	mot
			DOSCommand 	("start https://3dsky.org/search?query=" + mot + "\"")
-- 			command = "ShellLaunch \"Chrome.exe\" @\"https://3dsky.org/search?query=" + mot + "\""
-- 			execute command
		)
		fn rechercher_OSM mot =(		
			mot = formaterTexte 	mot
			DOSCommand 	("start https://www.openstreetmap.org/search?query=" + mot + "\"")
-- 			command = "ShellLaunch \"Chrome.exe\" @\"https://www.openstreetmap.org/search?query=" + mot + "\""
-- 			execute command
		)
		fn rechercher_RAL mot =(		
			mot = formaterTexte 	mot
			DOSCommand 	("start http://rgb.to/ral/" + mot + "\"")
-- 			command = "ShellLaunch \"Chrome.exe\" @\"http://rgb.to/ral/" + mot  + "\""
-- 			execute command
		)
		
		
		
		
		
		
		
		on edt_texture entered _text do
			rechercher_texture  _text
		on edt_model entered _text do
			rechercher_MODEL  _text
		on edt_osm entered _text do
			rechercher_OSM  _text
		on edt_ral entered _text do
			rechercher_RAL  _text
	)


	createdialog RollRechercher
)