/* #######################################################################################################################

	2017 Christophe Pages (http://www.c-pages.fr) 

##########################################################################################################################
	
	Ecran : 
	un element d'interface utlisant une bitmap pour recevoir des boutons textes et label dans un seul ecran
	( par exemple pour faire une barre d'adresse dont chaque dossier est un bouton )
##########################################################################################################################

	notes :
	freeSceneBitmaps()  ?!?!,
	
	
######################################################################################################################## */ 
--  (
	
-- 	include "$userScripts\cp - GLOBAL\Debuger et ecrire.ms"
	include "$userScripts\cp - GLOBAL\Polices.ms"


	struct str_elemUI_fond (
		m_prt,												--- pointeur PaRenT à initialiser a la creation ----
		m_couleur	= 	color 68  68 68,		----- la couleur du texte -----
		
		fn dessiner = (
			local 	laBmp	= bitmap 	m_prt.m_ui.width 	m_prt.m_ui.height 	\
										color:m_couleur		\
										gamma:.45
			m_prt.setBmp 	laBmp 
		),
		fn setCouleur		_color	= (
			m_couleur = _color
		)
		
		
	)
	
	
	
	
	
	
	
	
	
	struct str_elemUI_texte (
		
		m_prt,												--- pointeur PaRenT à initialiser a la creation ----
		
		
		
		m_texte 	= "Label",
		m_police 	= str_police (),			----- la police utilisée par defaut -----		
		m_couleur	= 	color 250	250	250,		----- la couleur du texte -----
		m_marge 	= [2,2],
		
		fn dessiner = (
			local 	laBmp 	= m_prt.getBmp ()
			local 	pos 		= [0,0]
			
			---- pour chaque charactere du texte ----
			for idCharac = 1 to 	m_texte.count do (
				local characAEcrire 	= m_texte[ idCharac ]
				local characPolice 	= m_police.get  characAEcrire
				
				if characAEcrire == "§" then (
					pos.x =  0
					pos.y += m_police.lignes +  m_police.ecart 
				) else (
					
					---- pour chaque ligne ----
					for index_ligne = 1 to m_police.lignes do (
						
						local charac_ligne = characPolice[	index_ligne ]
						
						---- pour chaque pixel de la ligne ----
						for index_pix = 1 to  charac_ligne.count do (
							
							local 	val 		= charac_ligne [ index_pix ]
							local 	pos_rep 	= pos +[ index_pix , index_ligne] + m_marge
							
							---- on dessine le pixel, ou pas ... ---
							if val >0 do 	setPixels 	laBmp 	pos_rep  	#( m_couleur )
							
						)
					)
					pos +=  [ 		(characPolice[1].count ) + m_police.ecart , 0]
				)
			)
			m_prt.setBmp 	laBmp
			
		),
		
		fn getTaille =(
			local result = [0,m_police.lignes]
			local maxX = 0
			local maxY = m_police.lignes
			for index = 1 to m_texte.count do (				
				local characAEcrire 	= m_texte[index]
				local characPolice 	= m_police.get  characAEcrire
			
				if characAEcrire == "§" then (
					result.x =  0
					maxY += m_police.lignes +  m_police.ecart 
				) else (
					result +=  [ 		(characPolice[1].count ) +m_police.ecart, 0]
					if maxX< result.x do maxX = result.x
				)
			)
				
			( [maxX, maxY ] + m_marge *2 )
		),
		
		
		-- texte ---
		fn setTexte 	_txt	= (				
			if _txt != undefined do m_texte = _txt
			dessiner ()
		),
		fn setPolice 	_police	= (				
			if _police != undefined do m_police = _police
			dessiner ()
		),
		
		-- couleurs  ---
		fn setCouleur		_color	= (
			m_couleur = _color
		),
		
		fn setTaille =(
			
		)
	)

	
	
	
	
	
	
	
	
	
	

 	struct str_label (
		public
			m_ui,							----- l'ui  imgtag a controller  -----
			m_texte = "",
		
			m_ajusterAuTexte = true,
		
		private
			m_bmp 	 			,		----- la bitmap qui s'affiche dans l'imgTag  -----
			
			mgr_fond 	= str_elemUI_fond  	m_prt:this,
			mgr_texte 	= str_elemUI_texte  m_prt:this 	m_texte:m_texte,
			
		public
			fn getBmp = m_bmp,			
			fn setBmp  _bmp =(
				m_bmp = _bmp
			 	m_ui.bitMap = m_bmp 
			),
			
			fn actualiser = (
				---- redessiner tout ----
				mgr_fond.dessiner ()
				mgr_texte.dessiner ()
			),
			
		
			fn ajusterUI =(
				if m_ajusterAuTexte do (
					local tailleTxt = mgr_texte.getTaille ()
					m_ui.width 	= tailleTxt.x 
					m_ui.height 	= tailleTxt.y  - 1
				)
			),
			
			
			
			
			
			
			
			fn setTexte 	_txt	= (				
				if _txt != undefined do 
					mgr_texte.m_texte = _txt
				
				ajusterUI ()
				actualiser ()
			),
			fn setPolice 	_police	= (				
				if _police != undefined do  
					mgr_texte.setPolice 	_police	
				
				ajusterUI ()
				actualiser ()
			),
			fn setCouleur 	_couleur	= (				
				if _couleur != undefined do  
					mgr_texte.setCouleur 	_couleur	
				
				ajusterUI ()
				actualiser ()
			),
			fn setCouleurFond 	_couleur	= (				
				if _couleur != undefined do  
					mgr_fond.setCouleur 	_couleur	
				
				ajusterUI ()
				actualiser ()
			),
			
			
			
			
			
			
			
			
			
			on create do (
				setTexte 	m_texte
				ajusterUI ()
				actualiser ()				
			)
	) 
	
	
	
	
	
	
	
	
/* 

	struct str_btnTexte (
			---------- Membres ----------------------------
		public
			m_ui,																----- l'ui  imgtag a controller  -----
			m_police = str_policePetite (),							----- la police utilisée -----
			
			m_col_fond				=	color 56  95 120,				----- la couleur du fond de l'ecran -----
			m_col_texteRepos	= 	color 200	200	250,		----- la couleur repos du texte -----
			m_col_texteSurvol	= 	color 230	230	230,		----- la couleur survol du texte -----
			m_col_textePresse	= 	color 255	255	255,		----- la couleur presse du texte -----
			
			m_marge 				= [2,2],
			m_ajusterAuTexte 	= true,
			
			m_texte 			="",
			
		private
			m_bmp 	 			,		----- la bitmap qui s'affiche dans l'imgTag  -----
			m_etat				,		---- l'etat courant du bouton ----
			m_col_texteCourant = m_col_texteRepos,
			
			---------- Fonctions ----------------------------
		private
			------- Outils -----
			fn getTailleTexte =(
				local result = [0,m_police.lignes]
				for index = 1 to m_texte.count do (
						local characAEcrire 	= m_texte[index]
						local characPolice 	= m_police.get  characAEcrire
						result +=  [ 		(characPolice[1].count ) +1, 0]
					)
				result
			),
			fn ajusterAuTexte =(
				if m_ajusterAuTexte do (
					debug "ajusterAuTexte"
					local tailleTxt = getTailleTexte ()
					debug "tailleTxt" var:tailleTxt
					m_ui.width 	= tailleTxt.x + m_marge.x * 2
					m_ui.height = tailleTxt.y + m_marge.y * 2 - 1
				)
			),
			
			------- Dessin -------
			fn dessinerTexte	 =(
				
				local pos = [0,0]
				
				---- pour chaque charactere du texte ----
				for idCharac = 1 to 	m_texte.count do (
					
					local characAEcrire 	= m_texte[ idCharac ]
					local characPolice 	= m_police.get  characAEcrire
					
					---- pour chaque ligne ----
					for index_ligne = 1 to m_police.lignes do (
						
						local charac_ligne = characPolice[	index_ligne ]
						
						---- pour chaque pixel de la ligne ----
						for index_pix = 1 to  charac_ligne.count do (
							
							local 	val 		= charac_ligne [ index_pix ]
							local 	pos_rep 	= pos +[ index_pix , index_ligne] + m_marge
							
							---- on dessine le pixel, ou pas ... ---
							if val >0 do 	setPixels 	m_bmp 	pos_rep  	#( m_col_texteCourant )
							
						)
					)
					pos +=  [ 		(characPolice[1].count ) +1, 0]
				)
			 	m_ui.bitMap = m_bmp 
			),
			fn dessinerFond 	=(
				m_bmp	= bitmap 	m_ui.width 	m_ui.height 	\
											color:m_col_fond		\
											gamma:.45
			 	m_ui.bitMap = m_bmp 
			),
			fn actualiser = (
				
				--- etat du bouton ? ----
				case m_etat of (
					#repos:		m_col_texteCourant = m_col_texteRepos
					#survol:		m_col_texteCourant = m_col_texteSurvol
					#presse:	m_col_texteCourant = m_col_textePresse
				)
				
				--- ajuter ? ----
				ajusterAuTexte ()
				
				---- redessiner tout ----
				dessinerFond ()
				dessinerTexte ()
			),
			fn setEtat 	_etat =(
				m_etat = _etat
				actualiser ()
			),
			
			--- initialiser ----
			fn initialiser = (
			 	m_ui.bitMap = m_bmp 
				actualiser ()
			),		
			
			----- proprietes ------
		public
			-- texte ---
			fn setTexte 	_txt	= (				
				if _txt != undefined do m_texte = _txt
				actualiser ()
			),
			
			-- couleurs texte ---
			fn setColorTxt_repos		_color	= (
				m_col_texteRepos = _color
				actualiser ()
			),
			fn setColorTxt_survol		_color	= (
				m_col_texteSurvol = _color
				actualiser ()
			),
			fn setColorTxt_presse		_color	= (
				m_col_textePresse = _color
				actualiser ()
			),
			
			-- couleur fond --
			fn setColorFond 	_color	=(
				m_col_fond = _color
				actualiser ()				
			),
			
			
			
		public
			
			---- evenements du btnTexte ----
			fn survoler 		= setEtat 	#survol,
			fn quitter 		= setEtat 	#repos,
				
			fn G_down 		= setEtat 	#presse,
			fn G_up 			= setEtat 	#survol,
			fn G_double 	= setEtat 	#presse,
			fn D_down 		= debug "btn_D_down",
			fn D_up 			= debug "btn_D_up",
			fn D_double 	= debug "btn_D_double",
			
			
			---------- Evenements --------------------------
			on create do initialiser ()
	)
	
	struct str_barreAdresse (
		private
			m_adresse 	= "",
			m_btns 		= #(),
			
			
			
			fn vider  =(
				
			),
			fn nvBtn  _txt 	=(
				
			),
			
			fn actualiser =(
				
			),
			
			
			
		public
			fn setTaille = (
				
			),
			fn setAdresse = (
				
			),
			fn setTexte = (
				
			)
		
		
		
	)
	
	 */
	 /* 
	rollout roll_ecran "rollEcran" width:250 height:250
	(
		---------- Membres --------------------------
-- 		local m_btn ----- le controleur  -----
		local m_lbl		----- le controleur  -----
		
		---------- UI ---------------------------------
		
-- 		imgtag 	ui_btnTexte 	""	pos:[50,50] width:150 height:50 align:#left 
		imgtag 	ui_Label 		""	pos:[50,50] width:150 height:50 align:#left 
		
		
		---------- Fonctions --------------------------
		fn initialiser = (
			
			m_lbl = str_label 		m_ui:				ui_Label				\
										m_texte:		"Label hop hop hop"
			
		)
		
		---------- Evenements --------------------------
		---- fenetre -----
		on roll_ecran open do initialiser ()
		
		---- btn texte -----
-- 		on ui_btnTexte 	mbuttondown 	_pos _flags do m_btn.survoler ()
-- 		on ui_btnTexte 	rightClick 		_pos _flags do m_btn.survoler ()
-- 		on ui_btnTexte 	click 				_pos _flags do m_btn.survoler ()
-- 		on ui_btnTexte 	mbuttonup 		_pos _flags do m_btn.survoler ()
-- 		on ui_btnTexte 	dblclick 			_pos _flags do m_btn.survoler ()
-- 		on ui_btnTexte 	mbuttondblclk 	_pos _flags do m_btn.survoler ()
		
		
-- 		on ui_btnTexte 	mousedown 	_pos _flags do m_btn.survoler ()
-- 		on ui_btnTexte 	mouseup 		_pos _flags do m_btn.survoler ()
		
		on ui_btnTexte 	lbuttondown 	_pos _flags do m_btn.G_down ()
		on ui_btnTexte 	lbuttonup 		_pos _flags do m_btn.G_up ()
		on ui_btnTexte 	lbuttondblclk 	_pos _flags do m_btn.G_double ()
		on ui_btnTexte 	rbuttondown 	_pos _flags do m_btn.D_down ()		
		on ui_btnTexte 	rbuttondblclk 	_pos _flags do m_btn.D_up ()
		on ui_btnTexte 	rbuttonup 		_pos _flags do m_btn.D_double ()
		
		on ui_btnTexte 	mouseout 		_pos _flags do m_btn.quitter ()
		on ui_btnTexte 	mouseover 		_pos _flags do m_btn.survoler () 
			
	)
	
	createdialog roll_ecran 		bgcolor:		( color 56  95 120 )
	 */
-- )
























