/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	LA BIBLIO
	Gestionnaires d'assets 3D, et peut etre plus tard de bitmaps et autre.
	
##########################################################################################################################
	
	Structs
	
	-	gestionnaire de ListView dotnet
	
##########################################################################################################################

	todo:  A CLEANNER 
	
	creation :
			lv_mgr	=	str_listViewMgr 	m_prt:this				\ 	---- le parent, le rollout ---- ( a initialiser ) ----	
													m_ui:lv_sequence		---- le listview a controler -- ( a initialiser ) ----
			lv_mgr.initialiser ()
	
	event : 
	--------- le listView ---------
		on lv_sequence 	mouseDown 	_sender	_arg 	do  	lv_mgr.clq_down				_arg
		on lv_sequence 	mouseUp 		_sender	_arg 	do 	lv_mgr.clq_up 					_arg 
		on lv_sequence	MouseWheel	 			_arg 	do  	if keyboard.controlPressed do lv_mgr.zoomer 	_arg.delta
		on lv_sequence 	DoubleClick					_arg 	do  	lv_mgr.clq_double 			_arg 	
		on lv_sequence 	DragOver 		_sender	_arg 	do	lv_mgr.drag_checkSurvol  	_arg
		on lv_sequence 	DragDrop 					_arg 	do	lv_mgr.drag_recevoir 		_arg
		on lv_sequence 	itemDrag 		_sender 	_arg 	do 	lv_mgr.drag_demarrer 		_arg 	
		on lv_sequence 	AfterLabelEdit				_arg 	do  	lv_mgr.renommer				_arg		
		on lv_sequence 	BeforeLabelEdit			_arg 	do  	lv_mgr.debutRenommage 	()
		on lv_sequence 	keyup  						_arg 	do  	lv_mgr.key_up					_arg
		
##########################################################################################################################
	changelog:
	*v0.1 - [02/10/2016] -----------------------------------------------------------------------------
	- Mise en place globale 
########################################################################################################################*/



--------------------------------------------------------------------------------
----------	gerer un ListView dotnet 					--------------------
--------------------------------------------------------------------------------
struct str_listViewMgr (
		
	------------ DEBUG	----------------------------------------------------------------------------------
-- 		m_debug = false,
		m_debug = true,
		m_dbgPrefix ="LV",
		fn debug 	_txt  var:	 param:    =(
			if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		),
	----------------------------------------------------------------------------------------------------------
	
		
		
		
		
		
		------------ MEMBRES ----------------------------------
	public
		---- pointeurs (à donner en param a la creation) ----
		m_prt,										---- le parent, le rollout ---- ( a initialiser ) ----	
		m_ui, 										---- le listview a controler -- ( a initialiser ) ----
		m_TV,	
		
	private
-- 		m_prefs	=	m_prt.m_prefs,			---- les m_prefs de labib ---		
-- 		m_edit	=	m_prt.m_prt.m_labib.edit,
-- 		m_cmd	=	m_prt.m_prt.m_labib.cmd,
		
		---- pour la creation des items -----
		m_itemsAAfficher		= #(),
		m_iconesAAfficher,
		m_idImage 				= 0,
		
		---- affichage ----
		m_taille_icones,		
		
		---- couleurs ----
		m_col_uiFond,
		m_col_uiFondRecherche,	
		m_col_txtDossier,
		m_col_fondDossier,
		m_col_fondDossierPrt,			
		m_col_txt,		
		
		---- drag -----
		m_dragDropEffect=dotNetClass "System.Windows.Forms.DragDropEffects",
		
		---- les boutons de souris dotNet ----
		m_btnsDotNet = dotNetClass "System.Windows.Forms.MouseButtons",
		
		--- renommer ----
		m_renommageEnCours = false,
		
		
		------------ FONCTIONS ----------------------------------
		
	private
	
		
		---- Creation d'un tiem ----
		fn creerItems 		_noeudsA 	= (
			
			---- on transforme "_elemsArbo" en array si element unique --
			toArray 	&_noeudsA
			
			--- la creation ----
			for noeud  in _noeudsA do (
				
				---- le nouvel item ----
				local nvItem			= dotNetObject "System.Windows.Forms.ListViewItem" 	noeud.nomUnique
				nvItem.imageIndex 	= m_idImage
				nvItem.name 			= noeud.nomUnique
				
				---- le nouvel icone	 ----
				local	nvIcone 		= dotNetClass "System.Drawing.Image"
				
				--- Vue Détail : la couleur des lignes  --
				if m_prefs.fenetre.affichageLV == #Details do (
					
					local couleurLigne
					
					if classof noeud == str_branche then
						couleurLigne 	= m_col_uiFond + [20,20,20]
					else 
						couleurLigne 	= m_col_uiFond
					
					nvItem.BackColor		=	toCouleurDotnet	couleurLigne
					
				)			
				
				---- les differentes infos ---
				nvItem.text 			= noeud.nom
				
				nvItem.subItems.add 	( noeud.getNbrVertex () as string)
				nvItem.subItems.add 	( noeud.getDateDernierImport ()  )
				nvItem.subItems.add 	( noeud.getNbrImports ()   as string)
				nvItem.subItems.add 	( noeud.getAProxy ()  )
				nvItem.subItems.add 	( noeud.getAVueDetail ()   )		
				nvItem.subItems.add 	( noeud.getDateCreation ()  )
				
				nvItem.subItems.add 	( noeud.getFichier ()  )
				nvItem.subItems.add 	( noeud.getTags ()  )
				
				-- remplissage en fonction de la classe de l'élément --
				case classof noeud of (
					str_branche: (	--------------------------------------
						
						case  noeud.nomUnique  of (							
							"RETOUR":	(
								m_iconesAAfficher.images.add ( nvIcone.fromFile 	m_prefs.fenetre.apercuDossierParent )							

							)
							default:			(
								nvItem.text += "   (" + noeud.getNbrEnfants() as string + ")"
								m_iconesAAfficher.images.add ( nvIcone.fromFile 	m_prefs.fenetre.apercuDossier )
							)
						) -- fin case  noeud.nomUnique
						
					)
					str_element: (	--------------------------------------
						---- affichage du texte----
						nvItem.text 			= noeud.nom
						
						---- pour la vue image ----
						if noeud.apercu != undefined do
							if doesfileexist noeud.apercu 	then  m_iconesAAfficher.images.add 	( nvIcone.fromFile noeud.apercu )
																	else 	m_iconesAAfficher.images.add 	( nvIcone.fromFile m_prefs.fenetre.apercuVide )
					)					
				) -- fin case classof noeud 
				
				-- on ajoute le nouveau noeud à la liste de creation ---
				append m_itemsAAfficher	 nvItem
				m_idImage += 1
				
			) -- fin for noeud  in _noeudsA 
			
		),
		
		---- Accession ----
		fn	getNoeud 			_item 	= (
			local result
			if _item != undefined 	do	result = m_edit.getNoeud	 	_item.name
			result
		),
		fn	getItem 			_noeudA 	= (
			local	result
			for i=0 to  m_ui.items.count - 1 do (
				local elemLV  = m_ui.items.item[i]  
				if elemLV.name == _noeudA.nomUnique do
					result = elemLV
			)
			result
		),
		fn getNoeudA_at 	_x  _y 	=(
			local noeudClique
			local	noeudTVClique = m_ui.GetItemAt  _x  _y 
			
			if noeudTVClique != undefined then
				noeudClique = m_edit.getNoeud	 	  noeudTVClique.name
			
			noeudClique
		),
		fn getDossier 			=(
			m_edit.getDossier()
		),
		fn getSelection =(
			local selectionNoeud = #()
			
			for i = 0 to (  m_ui.SelectedItems.count - 1 ) do
				append selectionNoeud ( getNoeud 	m_ui.SelectedItems.item[ i ] )
			
			selectionNoeud
		),
		
		
		
		
		
	public
		---- divers ----
		fn selectionnerPremier = (
			debug "selectionnerPremier"
			if m_ui.items.count >0 do (
				m_ui.items.item[0].selected = true
				m_edit.setSelection (getNoeud  m_ui.items.item[0])
			)
		),
		
		
		fn selectionner 	_noeudsA	= (
			
			debug "selectionner"
			debug "_noeudsA" var:_noeudsA	 param:#nom
			
			---- on transforme "_noeudsA" en array si noeud unique --
			toArray 	&_noeudsA
			
			-- si _noeudsA est valide --
			if _noeudsA.count > 0 and _noeudsA[1] != undefined do (
				
				-- on actualise la selection des elements --
				m_edit.setSelection 	_noeudsA
				
				-- on deselectionne tout ----
				for i=0 to m_ui.items.count - 1 do
					m_ui.items.item[i].selected=false
				
				-- on selectionne les nouveau --
				for noeudA in _noeudsA do (
					local noeudLV = getItem 	noeudA
					if noeudLV != undefined do 
						noeudLV.selected = true
				)
				
				-- scroll jusqu'au elements selectionnés --
				if not m_edit.selectionEstVide()  then (
					local selectionUnique = (m_edit.getSelection())[1]
					if selectionUnique != undefined do
						if getItem	 selectionUnique != undefined do
							m_ui.EnsureVisible( ( getItem	 selectionUnique ).Index )
				) 
				
			) 
			
-- 			debug "(selection fin) m_edit.getSelection" var:(m_edit.getSelection () )	 param:#nom
		),
		
		
		
		
		fn vider = (
			
			-- on vide la liste --
			m_ui.items.Clear()
			
			-- initialiser les membres ---
			m_idImage								= 0
			m_itemsAAfficher						= #()
			m_iconesAAfficher 					= dotNetObject "System.Windows.Forms.ImageList"
			m_iconesAAfficher.imageSize 		= dotNetObject "System.Drawing.Size" 	m_prefs.fenetre.tailleApercusLV 		m_prefs.fenetre.tailleApercusLV
			m_iconesAAfficher.ColorDepth 	= m_iconesAAfficher.ColorDepth.Depth24Bit
			
		),
		fn actualiserSelection 	=(
		
			m_edit.viderSelection ()
			
			for i = 0 to m_ui.SelectedItems.count - 1 do (
				-- on ajoute chaque noeud a la slection --
				elem = 	m_edit.getNoeud	 		 m_ui.SelectedItems.item[i].name
				if elem != undefined do 
					m_edit.addSelection 		elem
				
			)
			debug "selection" var:(m_edit.getSelection ()) param:#nom
		),
		
		
		
		
		
		fn getBranches _noeuds =(
			local result = #()
			result = for noeud in _noeuds where classOf noeud == str_branche collect noeud
			result
		),
		fn getElements _noeuds =(
			local result = #()
			result = for noeud in _noeuds where classOf noeud == str_element collect noeud
			result
		),
		
		
		
		fn afficher  _noeudsAAfficher	= (	
			
			debug "afficher"
			
			-- on nettoie le terrain ---
			vider ()
			
			local aAfficher = _noeudsAAfficher
			
			--- la couleur de fond du LV ---------
			local col_fondVue			
			if m_prt.m_recherche.estActif () or m_prt.m_tags.estChecked ()
				then	col_fondVue 	= m_col_uiFondRecherche
				else	col_fondVue 	= m_col_uiFond
			m_ui.BackColor 				= toCouleurDotnet 	col_fondVue
			
			-- si Affichage des dossiers --
			if m_prefs.fenetre.afficherDossier do (	
				
				----  retour ----
				if m_brancheCourante.NomUnique != "ROOT" and m_brancheCourante.NomUnique != "RECHERCHE" do  (
					local ndRetour = m_edit.getNdRetour()
					creerItems 	ndRetour
					ndRetour.parent = m_brancheCourante.parent
				)
				
				---- Les dossiers enfants ----
				creerItems ( getBranches aAfficher )
				
			)
			
			---- les elements enfants----
			creerItems ( getElements aAfficher )
			
			--- on remplie la liste LV ----
			m_ui.LargeImageList = 	m_iconesAAfficher
			m_ui.items.addRange		m_itemsAAfficher
			
			---- on selectionne ----
			selectionner	( m_edit.getSelection() )
			
		),
		
		
		
		
		fn actualiser 	_noeuds	=(
			
			debug "actualiser"
			
			
			
			
			/* debug "(m_edit.getNdsAAfficher ())" var:(m_edit.getNdsAAfficher ()) param:#nom
			
			-- on nettoie le terrain ---
			vider ()
			
			--- on actualise la branche courante --
			m_brancheCourante = getDossier ()
			
			debug "m_brancheCourante" var:m_brancheCourante	 param:#nom
			
			debug "noeudAAfficher" var:noeudAAfficher	 param:#nom
			
			local aAfficher = noeudAAfficher
			
			--- la couleur de fond du LV ---------
			local col_fondVue			
			
			if m_prt.m_recherche.estActif () or m_prt.m_tags.estActif ()
				then	col_fondVue 	= m_col_uiFondRecherche
				else	col_fondVue 	= m_col_uiFond
			m_ui.BackColor 				= toCouleurDotnet 	col_fondVue
			
			-- Affichage des dossiers --
			if m_prefs.fenetre.afficherDossier do (	
				
				----  retour ----
				if m_brancheCourante.NomUnique != "ROOT" and m_brancheCourante.NomUnique != "RECHERCHE" do  (
					local ndRetour = m_edit.getNdRetour()
					creerItems 	ndRetour
					ndRetour.parent = m_brancheCourante.parent
				)
				
				---- Les dossiers enfants ----
				creerItems ( getBranches aAfficher )
			)
			
			---- les elements enfants----
			creerItems ( getElements aAfficher )
			
			--- on remplie la liste LV ----
			m_ui.LargeImageList = 	m_iconesAAfficher
			m_ui.items.addRange		m_itemsAAfficher
			*/
-- 			---- on selectionne ----
-- 			selectionner	( m_edit.getSelection() )
			 
			
		),
		
		
		
		
		
		fn ouvrir 	_noeudA 			=(
			debug "ouvrir"
-- 			debug "_noeudA" var:_noeudA
			
			local noeudCible 
			--- retour ? --
			if _noeudA.nomUnique == "RETOUR" 
				then noeudCible =  	_noeudA.parent
				else	noeudCible =	_noeudA
			
			-- ouverture --
			m_edit.ouvrir		noeudCible
			
			m_tv.selectionner noeudCible
-- 			m_tv.expandSelection	()
			
			debug "noeudCible" var:noeudCible param:#nom
			
		),
		
		
		
		
		
		---- nom ----
		fn editerNom 	_noeudA = (
			
			local noeudAEditer = getItem		_noeudA
			selectionner _noeudA
			noeudAEditer.BeginEdit()
			
			--- etat du renommage ----
			m_renommageEnCours = true
		),
		fn renommer 		_arg	  =(
			
			
			local nvNom 		= _arg.label
			local itemSelec 			= m_ui.items.item[_arg.item]
	 		local noeudCible = getNoeud 	itemSelec	
			
			debug "nvNom" var:nvNom
			debug "itemSelect" var:itemSelec	 param:#name
			
			debug "noeudCible" var:noeudCible param:#nomUnique		
			
			if nvNom != undefined  and  noeudCible !=undefined do 				
				m_cmd.renommer		noeudCible  	nvNom
			
		),
		fn debutRenommage = (
			m_renommageEnCours = true
		),
		
		---- La vue ----
		fn zoomer		_deltaArg 	= (
			debug "zoomer"
			/* 
			local delta
			
			if _deltaArg > 0 
				then delta = 10
				else  delta = -10
				
			local tailleMin 		= 40
			local tailleMax 	= 256
			m_prefs.fenetre.tailleApercusLV += delta
			
			if  m_prefs.fenetre.tailleApercusLV < tailleMin do 
				m_prefs.fenetre.tailleApercusLV = tailleMin
			if m_prefs.fenetre.tailleApercusLV  > tailleMax  do 
				m_prefs.fenetre.tailleApercusLV = tailleMax 
			
			m_ui.LargeImageList.imageSize	= dotNetObject "System.Drawing.Size" 	m_prefs.fenetre.tailleApercusLV 		m_prefs.fenetre.tailleApercusLV
			debug "m_prefs.fenetre.tailleApercusLV " var:m_prefs.fenetre.tailleApercusLV 
			actualiser ()
			 */
		),
		fn changerAffichage  	_nouvelAffichage		=(
			
			---- on vide les colonnes ----
			m_ui.columns.clear ()
			/* 
			-- on actualise les m_prefs --
			m_prefs.fenetre.affichageLV = _nouvelAffichage
			
			---- on creer le nouvel affiochage ----
			case _nouvelAffichage  of (
				#details: (
					m_ui.view = (dotNetClass "system.windows.forms.view").details
					m_ui.columns.add "Nom" 200
					m_ui.columns.add "Verts" 70
					m_ui.columns.add "Date du dernier import" 130
					m_ui.columns.add "Nbre d'imports" 70
					m_ui.columns.add "Proxy" 70
					m_ui.columns.add "Détail" 70
					m_ui.columns.add "Date de création" 130
					
					m_ui.columns.add "Fichier" 130
					m_ui.columns.add "Tags" 130				
					m_ui.columns.add "Lien" 130
					m_ui.columns.add "Détail" 70
					m_ui.columns.add "Source manquante" 70
					
					m_ui.FullRowSelect = true
				)
				#liste: (
					m_ui.view = (dotNetClass "system.windows.forms.view").list
					m_ui.Columns.add "Nom" 180
					m_ui.FullRowSelect = false
					m_ui.margin.all = 0
				)
				#grandeIcone: (
					m_ui.view = (dotNetClass "system.windows.forms.view").LargeIcon
					m_ui.Columns.add "Nom" 10
					m_ui.FullRowSelect = false
					m_ui.margin.all = 0
				)
				#petitIcone: (
					m_ui.view = (dotNetClass "system.windows.forms.view").SmallIcon
					m_ui.Columns.add "Nom" 10
					m_ui.FullRowSelect = false
					m_ui.margin.all = 0
				)
				#tuile: (
					uiview = (dotNetClass "system.windows.forms.view").Tile
					m_ui.Columns.add "Nom" 10
					m_ui.FullRowSelect = false
					m_ui.margin.all = 0
				)
			)
			 */
-- 			actualiser ()
			
		),
		
		
		---- dragAndDrop ---
		fn drag_checkSurvol	 _arg = (
			
			_arg.Effect=_arg.AllowedEffect
			local posAbsolu = [_arg.x, _arg.y]
			local posRollout = getDialogPos m_prt
			local posUI = m_ui.pos
			
			local posLocal = posAbsolu - posRollout - posUI
			--- si destination est un element qui se deplace , on fait rien ---
			local itemSurvol				= m_ui.GetItemAt  	posLocal.x 		posLocal.y
			local noeudSurvol 			= getNoeud	itemSurvol
			local noeudsQuiBougent 	= m_edit.drag_getNoeuds ()
		
			debug "_arg" var:[_arg.x, _arg.y]
			debug "itemSurvol" var:itemSurvol param:#name
			debug "noeudSurvol" var:noeudSurvol param:#nom
			
			
			---- si on survol un element du drag on fait rien ---
			if noeudSurvol != undefined 
				do if (findItem noeudsQuiBougent  noeudSurvol ) != 0
					do _arg.Effect=m_dragDropEffect.none
			
			
		),	 
		fn drag_demarrer 	_arg =(
			debug "drag_demarrer"
			
			debug "(drag_demarrer) getSelection" var:( m_edit.getSelection () )	 param:#nom
			m_edit.drag_demarrer 	( m_edit.getSelection() )
			
			--- demarrage du drag ----
			m_ui.doDragDrop 		_arg.item 		m_dragDropEffect.Move	
			/* 
			--- pour dragger dans viewport		
			intnum = dotnetobject "System.Int32" 0
			filenamestring= dotnetobject "System.string" "C:\Users\Windows\AppData\Local\Autodesk\3dsMax\2017 - 64bit\ENU\scripts\cp - Labib\data\labib_modeEdition.max"
			dropfile = dotnetobject "System.String[]" 1
			dropfile.setvalue filenamestring intnum 
			DataObj = dotnetobject "DataObject" ((dotnetclass "DataFormats").Text) dropfile
			m_ui.dodragdrop Dataobj ((dotnetclass "DragDropEffects").Copy)
			 */
		),
		fn drag_recevoir 	_arg =(
			
			debug "drag_recevoir"
		
			local posDrop	= m_ui.PointToClient 	m_ui.MousePosition
			local noeudDest = getNoeudA_at 	posDrop.x 	posDrop.y
			
			debug "noeudDest" var:noeudDest
			debug "m_edit.getNdsDrag()" var:(m_edit.getNdsDrag())
			
			if noeudDest != undefined do (
				---- si dépose dans "retour" ---
				if noeudDest.nomUnique == "RETOUR" 
					do noeudDest = noeudDest.parent
				
				---- deplacement des noeuds ---
				m_cmd.deplacer 	( m_edit.getNdsDrag() ) 		noeudDest
				m_edit.drag_finaliser 	noeudDest
			)
		),
		
		
		---- focus -----
		fn focus =(
			setFocus m_ui
		),
		
		
		
		---- Souris ----
		fn clq_down		_arg	 	= (
			debug "clq_down"
			
			--- actualiser la selection ----
			local	noeudLVClique = m_ui.GetItemAt  _arg.x _arg.y
			debug "(clq_down) noeudLVClique" var:( noeudLVClique )	 param:#name
			
			--- un seul element selectionné
			if m_ui.selectedItems.count <=1 then (
				debug "un seul elemnt selec"
				if noeudLVClique != undefined do ( 
					noeudAClique = m_edit.getNoeud  noeudLVClique.name
					
					debug "(clq_down) noeudAClique" var:( noeudAClique )	 param:#nomUnique
					
					if noeudAClique != undefined do 
						m_edit.setSelection	noeudAClique
				debug "(clq_down) getSelection -1- " var:( m_edit.getSelection () )	 param:#nom
					
				)
			) else if m_ui.selectedItems.count > 1 do (
				debug "plusieurs elemnts selec"
				m_edit.viderSelection ()
				for  i =0 to m_ui.selectedItems.count-1 do (
					itemSelec = m_ui.selectedItems.item[i]
					m_edit.addSelection 	( getNoeud itemSelec )
				)
			)
			
			
			debug "(clq_down) getSelection" var:( m_edit.getSelection () )	 param:#nom
			
		),
		fn clq_up 			_arg 			= (
			debug "clq_up"
			
			m_edit.setSelection 		( getSelection () )
			
			debug "(clq_up) m_edit.getSelection" var:( m_edit.getSelection () )	 param:#nom
			
			if not m_edit.dragEnCours () do (
				
				local	noeudLVClique = m_ui.GetItemAt  _arg.x _arg.y				
				
				case _arg.button of (
					(m_btnsDotNet.Left): 		if not m_edit.dragEnCours ()	do	actualiserSelection ()
					(m_btnsDotNet.Middle): 		()
					(m_btnsDotNet.None): 		()
					(m_btnsDotNet.Right): 		(
						debug "Bouton DROIT"
						actualiserSelection () 
						m_prt.m_menus.elements ()
					)
					(m_btnsDotNet.XButton1): 	m_edit.m_hist.seDeplacer 1
					(m_btnsDotNet.XButton2):	m_edit.m_hist.seDeplacer -1
				)
			)
-- 			debug "m_selection" var:m_selection
-- 			m_prt.dragFlag = false
			
			debug "(clq_up fin) m_edit.getSelection" var:( m_edit.getSelection () )	 param:#nom
		),
		fn clq_double		_arg 			= (
			debug "clq_double"
			
			local noeudClique = (m_edit.getSelection ())[1]
-- 			debug "noeudClique" var:noeudClique param:#nom
-- 			debug "classOf noeudClique" var: ( classOf noeudClique )
			
			case classOf noeudClique of (
				str_element: 	m_cmd.importer noeudClique --m_edit.importer_scene 	noeudClique
				str_branche:	ouvrir		noeudClique
			) 
			
		),
		
		
		---- clavier ----		
		fn key_up				_arg =(
			keyCode = _arg.KeyCode
			local touches = dotnetclass  "System.Windows.Forms.Keys"
			local selectionA = m_edit.getSelection ()
			
			
			case keyCode of (
				-- focus --
				( touches.Tab ): 		(
					if _arg.shift then m_prt.focusPrecedant ()
									else  m_prt.focusSuivant ()
				)
				
				-- renommer --
				( touches.F2 ): 		if not m_edit.selectionEstVide ()	do editerNom	selectionA[1]
				
				-- supprimer --
				( touches.Delete ): 	if not m_edit.selectionEstVide ()	and not m_renommageEnCours 	do m_cmd.supprimer		selectionA
				
				-- ouvrir --
				( touches.Enter ): 	if not m_edit.selectionEstVide ()	do (
					
					if m_renommageEnCours 
					then m_renommageEnCours = false
					else	case classOf selectionA[1] of (
							str_element: 	m_cmd.importer 	selectionA
							str_branche:	ouvrir		selectionA[1]
						) -- fin case classof
				)
				
				
				-- fleches --
				( touches.Left): 		actualiserSelection ()
				( touches.Right ): 	actualiserSelection ()
				( touches.Up): 		actualiserSelection ()
				( touches.Down ): 	actualiserSelection ()
				
				-- nouvelAsset --
				( touches.N ): 		(
					if _arg.Control do	
						if _arg.Shift		then 	m_cmd.nvxAssets ()
												else		m_cmd.nvlAsset ()
				)
				
				
				
				-- couper --
				( touches.X ): 		if _arg.Control do	m_cmd.couper 	( getSelection () )
				-- coller --
				( touches.X ): 		if _arg.Control do	m_cmd.coller 		( getdossier() )
				
				
				
				-- undo /redo --
				( touches.Z ): 		if _arg.Control do	m_cmd.defaire ()
				( touches.Y ): 		if _arg.Control do	m_cmd.refaire ()
				
				
				( touches.Escape ): 		m_apercus.annuler ()
			)
				
		),
		
-- 		m_classe_ordreInverse = false,
		
		
		------ trie des colonnes -----
		fn classerColonnes _idColonne =(
			m_edit.classerColonnes 	_idColonne
			actualiser () 
			/* local elemsAClasser = ( getDossier() ).enfants
			local arbo = m_edit.m_arbo
			case _idColonne  of (
				0: arbo.classerNoms				elemsAClasser	ordreInverse:m_classe_ordreInverse
				1: arbo.classerVertex			elemsAClasser	ordreInverse:m_classe_ordreInverse
				2: arbo.classerNbrImports		elemsAClasser	ordreInverse:m_classe_ordreInverse
				3: arbo.classerNbrImports		elemsAClasser	ordreInverse:m_classe_ordreInverse
				4: arbo.classerNbrImports		elemsAClasser	ordreInverse:m_classe_ordreInverse
				5: arbo.classerNbrImports		elemsAClasser	ordreInverse:m_classe_ordreInverse
				6: arbo.classerCreation			elemsAClasser	ordreInverse:m_classe_ordreInverse
				7: arbo.classerNbrImports		elemsAClasser	ordreInverse:m_classe_ordreInverse
				8: arbo.classerNbrImports		elemsAClasser	ordreInverse:m_classe_ordreInverse
			)
			
			m_classe_ordreInverse = not m_classe_ordreInverse
			*/
			
		),
		
		
		
		
		
		
		---- Initialisation ----
		fn initialiser =(
			/* 
			---- affichage ----
			m_taille_icones				= m_prefs.fenetre.tailleApercusLV
			
			---- couleurs ----
			m_col_uiFond 				 	= m_prefs.fenetre.col_uiFond
			m_col_uiFondRecherche	= m_prefs.fenetre.col_uiFondRecherche
		
			m_col_txtDossier 				= m_prefs.fenetre.col_txtDossier
			m_col_fondDossier 			= m_prefs.fenetre.col_fondDossier
			m_col_fondDossierPrt 		= m_prefs.fenetre.col_fondDossierPrt	
			m_col_txt						= m_prefs.fenetre.col_txt
			*/
			-- UI --
			m_ui.borderstyle 				= (dotnetclass "System.Windows.Forms.BorderStyle").None
			m_ui.showitemtooltips 		= true
			m_ui.gridlines 					= false
			m_ui.checkboxes 				= false
			m_ui.labeledit 					= true
			m_ui.MultiSelect				= true
			m_ui.HideSelection 			= false
			m_ui.allowdrop 				= true
			m_ui.AllowColumnReorder	= true/*
			m_ui.BackColor 				= toCouleurDotnet	m_col_uiFond
			m_ui.ForeColor 				= toCouleurDotnet   m_col_txt
			
			
			--image fond --
			m_ui.BackgroundImageLayout = (dotnetclass "System.Windows.Forms.ImageLayout").tile
			local fichierFond 					= GetDir #userScripts + "\cp - Labib\data\img\Labib_fondDotnet.jpg"
			m_ui.BackgroundImage			= (dotnetclass "System.Drawing.Image").FromFile( fichierFond )
			m_ui.Refresh()
			 */
		)
		
)	--- fin struct listView ----
































































