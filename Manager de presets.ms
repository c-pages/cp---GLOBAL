/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

	MANAGER de PRESETS générique
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
########################################################################################################################*/

include "$userScripts\cp - GLOBAL\Debuger et ecrire.ms"


struct str_presetsMGR (
	
	------------ DEBUG	----------------------------------------------------------------------------------
	m_debug = false,
	m_dbgPrefix ="presetsMGR",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	---------------------------------------------------------------------------------------------------------------
	------------  Membres	---------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------
	
	--------------------|	A INITIALISER à la création	...		--- --- ---
	public
		preset_type,				----	la classe définissant les type de preset géré par le manager 
		fichier			= 	"", 	----	pour le chargement et la sauvegarde ----
		prefixUnique	=	"",		----	le prefixe utilisé pour lidentification du preset
	--- --- --- 		...	fin	A INITIALISER à la création. 		|--------------------
	
	
	private
		presets 				= #(),		----	la liste des presets
		idUniqueCourant	= 0,			----	le dernier ID unique pour gerer l'identification des presets
	
	---------------------------------------------------------------------------------------------------------------
	------------  Fonctions	-----------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------
		
	----- Accessions diverses -------------------------------------------------------------------------------------------
	public
		fn get 											= 	presets,
		fn get_preset					_id			= 	if _id >0 and _id <= presets.count then	presets[_id]	else undefined,
		fn get_parIdUnique			_idUnique	= (
-- 			debug	"get_parIdUnique"
-- 			debug	"_idUnique" var:_idUnique
-- 			debug	"presets" var:presets
			local result
			for preset in presets do (
				
-- 				debug	"	preset.idUnique" var: preset.idUnique
				if preset.idUnique == _idUnique do
					result = preset
			)
			result
		),
		fn set_idUniqueCourant 	_id 			=	idUniqueCourant = _id,
		fn get_idUniqueCourant 					= 	idUniqueCourant,
		fn trouver_ID		_preset					= (
			findItem	presets _preset
		),
		
		
		
		
	----- Gestion du fichier -------------------------------------------------------------------------------------------
	private
		fn convertTabToString		_tab =(
			local txt = "#("
			for  i = 1 to _tab.count do (
				local item = "\"" + _tab[i] as string + "\"" 
				txt += item 
				if i != _tab.count do txt += ", "
			)
			txt += ")" 
			txt
		),
		
		
		
		fn ecrire_params =(
			
			--- Sauvegarde de la liste des parametres du mgr ------------
			local lstDesPresets = #()
			for preset in presets do append lstDesPresets	preset.idUnique
			setINISetting   fichier	(prefixUnique +"_params" )	"idUniqueCourant"		( idUniqueCourant as string)
			setINISetting	fichier	(prefixUnique +"_params" )	"listeDesPresets"		( convertTabToString	lstDesPresets  )
			
		),
			
		fn ecrire_preset  		_preset  	=(
			
			--- Ecriture du preset ------------
			local proprietesPreset 	= getPropNames  _preset
			
			for propNom in proprietesPreset do (
				
				local propriete =  ( getProperty _preset		 propNom	)	
				
				debug "ecrire_preset"				
				debug "propriete"		var:propriete
				debug "classof propriete "		var:(classof propriete )
				
					
				--- si c'est un tableau on le reecris nous meme -----
				if classof propriete == array do 
					propriete = convertTabToString	propriete
					
				
				
				setINISetting   fichier		_preset.idUnique	   propNom  	( propriete as string )
				
			)
		),
		
		fn lire_preset  	_idPreset	=(
			
			local nvPreset = preset_type ()
			
			local proprietesPreset 	= getPropNames  nvPreset
			
			for propNom in proprietesPreset do (
				
				local propFichier 	= getINISetting   	fichier		_idPreset   propNom 
				
				local propType 	= classof ( getProperty 	nvPreset	 propNom )
				
				debug "propNom" var:propNom
				debug "propType" var:propType
				
				case propType of (
					Integer:			setProperty 	nvPreset 	propNom		( propFichier	as integer )
					Float:			setProperty 	nvPreset 	propNom		( propFichier	as float )
					BooleanClass:	setProperty 	nvPreset 	propNom		( if propFichier == "true" then true else false )
					Point2:			setProperty 	nvPreset 	propNom		( execute propFichier )
					Color:			setProperty 	nvPreset 	propNom		( execute propFichier )
					Array:			(
						local tabTmp = execute propFichier
						local tabTmpResult = #()
						debug "	tabTmp	1	" var:tabTmp
						for item in tabTmp do ( 
								debug "	item	1	" var:item
							
								if  (  execute item ) != undefined then
									append tabTmpResult (  execute item )
								else
									append tabTmpResult (  item )
								debug "	item	2	" var:(  execute item )
						)
				debug "	tabTmp	2	" var:tabTmpResult
						setProperty 	nvPreset 	propNom		tabTmpResult
					)
					
					Default:			setProperty 	nvPreset 	propNom		propFichier
				) 
			)
			
			nvPreset
			
		),
		

		
		
		
		
	public
		fn sauvegarder			_preset	= (
			ecrire_params ()
			ecrire_preset 	_preset
		),
		fn sauvegarder_tout					=(
			
			ecrire_params ()
			
			--- les presets ----
			for preset in presets do
				ecrire_preset 	preset
		),
		
		fn charger 						=(
			
			--- vider la liste des presets -----
			presets 	=#()	
			
			---- si existe pas on initialise le fichier ----
			if not doesFileExist fichier then (
				
				debug "fichier des Presets absent, création du fichier"		var:fichier
				sauvegarder_tout ()
				
			---- sinon on charge ----
			) else (
				
				debug "fichier des Presets trouvé, chargement du fichier"		var:fichier
				
				if not hasINISetting fichier	(prefixUnique +"_params" ) do
					ecrire_params ()	
					
				---- parametres globaux ---
				set_idUniqueCourant 		( ( getINISetting   fichier	(prefixUnique +"_params" ) "idUniqueCourant"	)	as integer )
				
				---- charger les presets -------
				local listeDesPresets = execute ( getINISetting	fichier	(prefixUnique +"_params" )	"listeDesPresets"	) 
				
				
				for presetID in listeDesPresets do 					
					if hasINISetting fichier	presetID		do						
						append presets ( lire_preset  presetID )
						
			)
		),
		
		
		
		
	----- Creations,  suppression ....-------------------------------------------------------------------------------------------		
	public
		fn ajouter 		nvPreset	= (
			append presets nvPreset
			nvPreset
		),
		
		fn supprimer 	_id	= (
			debug "supprimer"
			debug "_id" var:_id
			delIniSetting  fichier		presets[_id].idUnique
			deleteItem  presets 	_id
			ecrire_params ()
		),
		
		
		fn supprimer_preset		_preset	= (
			
			debug "supprimer_preset" 
			debug "_preset" var:_preset
			local ID_aSuppr = findItem		presets	_preset
			debug "ID_aSuppr" var:ID_aSuppr
			if ID_aSuppr != 0 do supprimer 	ID_aSuppr
			
		),
		fn supprimer_parIdUnique	_idUnique	= (
			debug "supprimer_preset" 
			debug "_idUnique" var:_idUnique
			local presetASppr = get_parIdUnique 	_idUnique
			debug "presetASppr" var:presetASppr
			supprimer_preset		presetASppr
		),

		fn creer_preset = (
			
			idUniqueCourant += 1
			
			local  nvPreset	= preset_type 	idUnique:( prefixUnique + "_" + idUniqueCourant as string )
			append presets 	nvPreset
			
			sauvegarder nvPreset
			
			nvPreset
		),
		
		
		
		
		
		
		
	---------------------------------------------------------------------------------------------------------------
	------------  EVENEMENTS		---------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------
		on create do (
			
			---- Erreurs d'initialisation -----
			if preset_type == undefined or fichier == "" or prefixUnique == ""	do ( 
				
				format 	"\n	****	/!\	ERREUR INITIALISATION STRUCT : \"str_presetsMGR ()\"		/!\		****\n"
				
				if preset_type == undefined do 
					format 	"	****		\"preset_type\" doit etre initialiser à la création. 				****\n"
				
				if fichier == "" do 
					format 	"	****		\"fichier\" doit etre initialiser à la création. 					****\n"
				
				if prefixUnique == "" do 
					format 	"	****		\"prefixUnique\" doit etre initialiser à la création. 			****\n\n"
			)
		)
		
		
		
)





popo = str_presetsMGR ()








