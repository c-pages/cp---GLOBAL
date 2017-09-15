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
	m_debug = true,
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
	private
		fn ecrire_preset  		_preset  	=(
			
			local proprietesPreset 	= getPropNames  _preset
			
			for propNom in proprietesPreset do (
				setINISetting   fichier		_preset.idUnique	   propNom  	( ( getProperty _preset		 propNom	)	as string )
			)
		),
		
		fn lire_preset  	_idPreset	=(
			
			local nvPreset = preset_type ()
			
			local proprietesPreset 	= getPropNames  nvPreset
			
			for propNom in proprietesPreset do (
				
				local propFichier 	= getINISetting   	fichier		_idPreset   propNom 
				
				local propType 	= classof ( getProperty 	nvPreset	 propNom )
				case propType of (
					Integer:			setProperty 	nvPreset 	propNom		( propFichier	as integer )
					Float:			setProperty 	nvPreset 	propNom		( propFichier	as float )
					BooleanClass:	setProperty 	nvPreset 	propNom		( if propFichier == "true" then true else false )
					Point2:			setProperty 	nvPreset 	propNom		( execute propFichier )
					Color:			setProperty 	nvPreset 	propNom		( execute propFichier )
					Array:			setProperty 	nvPreset 	propNom		( execute propFichier )
					Default:			setProperty 	nvPreset 	propNom		propFichier
				) 
			)
			
			nvPreset
			
		),
		
	----- Accessions diverses -------------------------------------------------------------------------------------------
	public
		fn get 										= 	presets,
		fn get_preset					_id		= 	if _id >0 and _id < presets.count then	presets[_id]	else undefined,
		fn set_idUniqueCourant 	_id 		=	idUniqueCourant = _id,
		fn get_idUniqueCourant 				= 	idUniqueCourant,
		fn trouver_ID		_preset				= (
			findItem	presets _preset
		),
		
		
		
		
	----- Gestion du fichier -------------------------------------------------------------------------------------------
	public
		fn sauvegarder			_preset	= ecrire_preset 	_preset,
		fn sauvegarder_tout					=(
			
			--- la valeur de l'idUnique ----
			setINISetting   fichier		(prefixUnique + "idUniqueCourant")	"val"	( idUniqueCourant as string)
			
			--- les presets ----
			for preset in presets do
				ecrire_preset 	preset
		),
		
		fn charger 						=(
			
			--- vider la liste des presets -----
			presets 	=#()	
			
			---- si existe pas on initialise le fichier ----
			if not doesFileExist fichier then (
				debug "fichier absent, création du fichier"		var:fichier
				sauvegarder_tout ()
				
			---- sinon on charge ----
			) else (
				
				---- id unique ------
				set_idUniqueCourant 		( ( getINISetting   fichier	(prefixUnique + "idUniqueCourant")		"val"	)	as integer )
				
				---- charger les presets -------
				local finDeLecture = false
				idUniquePreset_lecture	 = 1
				while not finDeLecture do (
					
					local nom_idPreset = (prefixUnique + "_" +   idUniquePreset_lecture as string )
					
					if hasINISetting fichier	nom_idPreset		then (
						
						local nvPreset = 	lire_preset  nom_idPreset
						append presets nvPreset
						
						idUniquePreset_lecture +=1
						
					)	else	finDeLecture = true
					
				)
			)
		),
		
		
		
		
	----- Creations,  suppression ....-------------------------------------------------------------------------------------------		
	public
		fn ajouter 	nvPreset	= (
			append presets nvPreset
			nvPreset
		),
		
		fn creer_preset = (
			
			idUniqueCourant += 1
			
			local  nvPreset	= preset_type 	idUnique:( prefixUnique + "_" + idUniqueCourant as string )
			append presets 	nvPreset
			
			nvPreset
		),
		fn supprimer_preset 		_preset = (),
-- 		fn vider 					=	presets 	=#()	,
		
		
		
		
		
	---------------------------------------------------------------------------------------------------------------
	------------  EVENEMENTS		---------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------
		on create do (
			
			---- Erreurs d'initialisation -----
			if preset_type == undefined or fichier == "" or prefixUnique == ""	do ( 
				
				format 	"\n	****	ERREUR INITIALISATION STRUCT : \"str_presetsMGR ()\"	****\n"
				
				if preset_type == undefined do 
					format 	"	****	\"preset_type\" doit etre initialiser à la création. 	****\n"
				
				if fichier == "" do 
					format 	"	****	\"fichier\" doit etre initialiser à la création. 		****\n\n"
				
				if prefixUnique == "" do 
					format 	"	****	\"prefixUnique\" doit etre initialiser à la création. 		****\n\n"
			)
		)
		
		
		
)














