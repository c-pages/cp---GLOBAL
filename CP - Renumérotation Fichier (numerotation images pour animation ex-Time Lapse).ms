/* 
dossier = undefined
dossierTab = undefined
suffixe_nvDossier = undefined
nv_dossier = undefined
pre_num = undefined
fichier_avecExtension = undefined
fichiers_aRenommer = undefined
fichier = undefined
extension = undefined
nbre_lettre = undefined
nouveauNom = undefined
fichierDest = undefined

 */
gc ()
-- 	global chemin_renum_back 

(
clearListener ()
	
	if chemin_renum_back == undefined do 
		global chemin_renum_back = "V:\\02 - AFFAIRES\\2018\\09 - NOW - Marseille\\03 - Rendus\\00 - Animatique 03\\Plan 00 - Time lapses\\"
	
	
	-- dossier 						= "V:\\02 - AFFAIRES\\2018\\09 - NOW - Marseille\\03 - Rendus\\00 - Animatique 03\\Plan 00-2\\"
	local dossier 					= getsavePath "dossier a renuméroter"   initialDir:chemin_renum_back
	chemin_renum_back 		= copy dossier
	local dossierTab 				= filterString	dossier	"\\"
	local suffixe_nvDossier 	=	" - Renuméroté"
	
	local nv_dossier 				= ""	
	for i = 1 to dossierTab.count - 1 do 
		nv_dossier += dossierTab[i] + "\\"	
	local dossier_nom = dossierTab[dossierTab.count]
	nv_dossier += dossier_nom + suffixe_nvDossier
	
	format "dossier :%\n" dossier	
	format "nv_dossier :%\n" nv_dossier	
	format "\n\n\n"
	
	local on_continue = true
	if doesFileExist nv_dossier do (
		if queryBox "Le dossier de destination existe:\nOn ecrase les destinations ?" then (
			local fichiers_aSupprimer = getfiles (nv_dossier +"\\*" )
			for fichier in fichiers_aSupprimer do
				deletefile fichier
		) else (
			on_continue = false
			
		)
			
	)
	
	if on_continue do (
		
		if not doesFileExist nv_dossier do 
			makeDir nv_dossier
		
		local i = 0
		local pre_num =""
		
		local fichiers_aRenommer = getfiles (dossier +"\\*" )
		for fichier_nom in fichiers_aRenommer do(
		
			
			i+=1
			
			if i < 10 			then pre_num ="0000"
			else if i < 100 	then pre_num ="000"
			else if i < 1000 	then pre_num ="00"
			else if i < 10000	then pre_num ="0"
			
			
			
			local fichier_avecExtension 	= filenameFromPath fichier_nom
			local fichier 						= getFilenameFile  fichier_avecExtension
			local extension 					= getFilenameType   fichier_avecExtension
			local nbre_lettre 					= fichier.count
			
			
			local tab_fichier_ssNombre	=	filterString	fichier	" - "
			local nom_sans_nombreFin	=	""
			
			format "tab_fichier_ssNombre :%\n" tab_fichier_ssNombre
			
			for j = 1 to tab_fichier_ssNombre.count - 1  do 
				nom_sans_nombreFin += tab_fichier_ssNombre[j] + " - "
			
			
			
			format "nom_sans_nombreFin :%\n" nom_sans_nombreFin
			
			
-- 			local nouveauNom 				= replace fichier		(nbre_lettre-4) 5 ( pre_num + i as string + extension )
			local nouveauNom 				=  nom_sans_nombreFin	+ ( pre_num + i as string + extension )
			
			local fichierDest = nv_dossier + "\\" + nouveauNom
			
-- 			format "fichier_avecExtension :%\n" fichier_avecExtension	
-- 			format "fichier :%\n" fichier
-- 			format "i :%\n" i
-- 			format "pre_num :%\n" pre_num
-- 			format "\n"
-- 			format "nouveauNom :%\n" nouveauNom
			format "fichier source :%\n" fichier_nom
			format "fichier Dest :%\n" fichierDest
			
			local result_copy = copyFile  fichier_nom	fichierDest
			if not result_copy then
				format "RATE !\n"
			else
				format "OK\n"
			
			format "\n\n\n"
			
			
		)
		format "% fichiers renumérotés.\n"		i
		local codeExplorer = ""
		codeExplorer += "ShellLaunch \"explorer.exe\" @\"" + nv_dossier + "\""
		execute codeExplorer
		
	)

)


