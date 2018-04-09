/*
print $.Base_Scale
showproperties $
-- 				print ("** Nom : " +  i.name as string)
-- 				print ("	on : " +  i.ScatterIsOn as string)
-- 				print ("	Nodes sources : " +  i.ScatterObjectsNodeList as string)
-- 				print ("	ScatterObjectsNodeList_Percent: " +  i.ScatterObjectsNodeList_Percent as string)
-- 				print ("	Node Distribution : " +  i.Node_Mesh as string)
-- 				print ("	Count : " +  i.Count as string)
-- 				print ("	MaxPreviewInstanceCount : " +  i.MaxPreviewInstanceCount as string)		
-- 				print ("	Density_Map : " +  i.Density_Map as string)
-- 				print ("	Random_Rotate : " +  i.Random_Rotate as string)
-- 				
-- 				print ("	Random_Scale1 : " +  i.Random_Scale1 as string)
-- 				print ("	Random_Scale2 : " +  i.Random_Scale2 as string)

*/



macroScript ManageMultiScatter
	category:"#CPages"
	toolTip:""
(
	-- UI
	local chk_On_Liste, Spn_MaxCount_ALL, Spn_MaxCount_Preview_ALL, btn_MaskMap_ALL, chk_MaskMap_ALL

	
	-- etat des scatters --
	local etat_scatters = #()
	
	--	GLOBALS
	global Check_Cible
	
	
	rollout Rollout_ManageMultiScatter "Multiscatters" width:490 height:235
	(
		-- Tableaux
		local Liste_Multiscatter
		Local Liste_MultiscatterActif
		
		local ListeDesCoef_count = #()
		local ListeDesCoef_PreviewCount = #()
		
		-- Variables
		Local Count_total_ALL, PreviewCount_total_ALL
		local ValeurMax_count = 0
		--local ValeurMax_countPreview = 0
		
		checkbox 'chk_On_Liste' "on" pos:[216,44] width:37 height:15 align:#left
		spinner 'Spn_MaxCount_ALL' "Max count (total) : " pos:[248,46] width:139 height:16 range:[0,1e+16,0] scale:1 align:#left	
	
	
	
	
		checkbox 'chk_mute' "Mute all" pos:[212,8] width:82 height:15 align:#left
	
	
		spinner 'Spn_MaxCount_Preview_ALL' "Max count Preview (total) : " pos:[215,68] width:129 height:16 range:[0,1e+16,0] scale:1 align:#left
		mapButton 'btn_MaskMap_ALL' "None" pos:[255,89] width:212 height:15 align:#left
		label 'lbl1' "Mask: " pos:[217,90] width:38 height:20 align:#left
		GroupBox 'grp1' "Paramètres" pos:[206,28] width:273 height:88 align:#left
		GroupBox 'grp4' "Transformations aléatoires" pos:[206,122] width:273 height:101 align:#left
		spinner 'spn_Echelle_Min' "min. :  " pos:[215,159] width:100 height:16 range:[0,1e+10,0] scale:1 align:#left
		spinner 'spn_Echelle_Max' "max. : " pos:[215,180] width:100 height:16 range:[0,1e+10,0] scale:1 align:#left
		label 'lbl4' "Echelle :" pos:[216,140] width:136 height:13 align:#left
		spinner 'spn_Rotation_X' "x :  " pos:[355,159] width:100 height:16 range:[0,360,0] scale:1 align:#left
		label 'lbl5' "Rotation :" pos:[356,140] width:109 height:13 align:#left
		spinner 'spn_Rotation_Y' "y :  " pos:[354,181] width:100 height:16 range:[0,360,0] scale:1 align:#left
		spinner 'spn_Rotation_Z' "z :  " pos:[354,202] width:100 height:16 range:[0,360,0] scale:1 align:#left
		button 'btnSelectsources' "Select sources" pos:[5,172] width:97 height:15 align:#left
		button 'btnselectDistrib' "Select Distribution" pos:[105,172] width:97 height:15 align:#left
		button 'btnCamPreview' "Camera Preview" pos:[5,190] width:197 height:15 toolTip:"La caméra active du viewport " align:#left
		multiListBox 'lbx_multiScatt' "" pos:[10,9] width:189 height:12 align:#left
		
		button 'btnCamVueActive' "Camera from active view" pos:[4,208] width:197 height:15 toolTip:"Associe la caméra selectionnée à tout les scatters de la scene." align:#left
		
		fn fn_Gestion_desMinimum_count = (
			ListeDesCoef_count = #()
			ValeurMax_count = 0
			-------------------------------------------------
			-- gestion des minimum 
			-------------------------------------------------
			for i in Liste_MultiscatterActif do (
				countCoef_Temp = float  i.Count / Count_total_ALL 
				append ListeDesCoef_count countCoef_Temp
			)
			
			CoefMinBack = amin  ListeDesCoef_count
			CoefMaxBack = amax  ListeDesCoef_count
			
			j = 1

			for i in ListeDesCoef_count do (
				
				ValeurTemp =  ( i / CoefMinBack )
				ValeurTemp = ValeurTemp * 10
				ValeurTemp = int ( ValeurTemp - (int ValeurTemp - ValeurTemp ) )
				
				ListeDesCoef_count[j] = ceil ValeurTemp

				ValeurMax_count += ListeDesCoef_count[j]
				
				j += 1
			)
			
		) -- fin fn_Gestion_desMinimum
		
		
		fn Actualise_UI state = (
			
			chk_On_Liste.enabled 							= state
			Spn_MaxCount_ALL.enabled 					= state
			Spn_MaxCount_Preview_ALL.enabled 		= state
			btn_MaskMap_ALL.enabled 					= state
			lbl1.enabled 										= state
			--chk_MaskMap_ALL.enabled 					= state
			grp1.enabled 										= state
			grp4.enabled 										= state
			spn_Echelle_Min.enabled 						= state
			spn_Echelle_Max.enabled 						= state
			lbl4.enabled 										= state
			spn_Rotation_X.enabled 						= state
			lbl5.enabled 										= state
			spn_Rotation_Y.enabled 						= state
			spn_Rotation_Z.enabled 						= state
			btnSelectsources.enabled 						= state
			btnselectDistrib.enabled 						= state
			btnCamPreview.enabled 						= state
			--lbx_multiScatt.enabled 							= state
			
		)
		
		
		fn fn_ActualiseListeUI = (
			-------------------------------------------------
			-- creation liste des multi : Liste_Multiscatter
			-------------------------------------------------
			Liste_Multiscatter = #()
			local ListeTemp = #()
			for i in objects do (
				if classof i == MultiScatter do (
					append Liste_Multiscatter i
					if i.ScatterIsOn then (
						append ListeTemp ("# " + i.name)
					)else(
						append ListeTemp ("    " + i.name)
					)
				)
			)
			lbx_multiScatt.items = for i in ListeTemp collect i
		)
		
		fn fn_Init =(
			
			local countCoef_Temp 
			Count_total_ALL 	=  PreviewCount_total_ALL 	= 	0
			Liste_MultiscatterActif = #()
			try (
				--rdo_Cible.state 	=	Check_Cible
			) catch (
				--rdo_Cible.state 	= 	1
			)
			-------------------------------------------------
			-- Check UI
			-------------------------------------------------	
			print ("lbx_multiScatt.selection.count : " + lbx_multiScatt.selection.count as string)
			if lbx_multiScatt.selection.count == 0 then (
				Actualise_UI false
			) else (
				Actualise_UI true
			)
			 
			-------------------------------------------------
			-- creation liste des multi : Liste_MultiscatterActif  et Liste_Multiscatter
			-------------------------------------------------
			
			fn_ActualiseListeUI () 
			/*
			case rdo_Cible.state  of (
				1:	(
						for i in objects do (
							if classof i == MultiScatter do
								append Liste_MultiscatterActif i
						)
					)
				2:	(
						for i in selection do (
							if classof i == MultiScatter do
								append Liste_MultiscatterActif i
						)
					)
			) -- fin case rdo_Cible.state
			*/
			
		
			for i in lbx_multiScatt.selection do (
				append 	Liste_MultiscatterActif 		Liste_Multiscatter[i]
			)				
			-------------------------------------------------
			-- Récuperation des données
			-------------------------------------------------
			
			if Liste_MultiscatterActif.count > 0 do (
				
				boolONBack 						= Liste_MultiscatterActif[1].ScatterIsOn
				boolDensityMapBack 			= Liste_MultiscatterActif[1].Density_Map
				boolUse_Density_MapBack 	= Liste_MultiscatterActif[1].Use_Density_Map
				boolEchelleMinBack 				= Liste_MultiscatterActif[1].Base_Scale[1]
				boolEchelleMaxBack 				= Liste_MultiscatterActif[1].Base_Scale[2]
				boolRotXBack 						= Liste_MultiscatterActif[1].Random_Rotate[1]
				boolRotYBack 						= Liste_MultiscatterActif[1].Random_Rotate[2]
				boolRotZBack 						= Liste_MultiscatterActif[1].Random_Rotate[3]
				
-- 				CmPreviewBack					=	Liste_MultiscatterActif[1].Camera_Preview
				--Base_Scale
				
				
				TestUnabled_ON = true
				TestUnabled_Density_Map = true
				TestUnabled_Use_Density_Map = true
				TestUnabled_EchelleMin = true
				TestUnabled_EchelleMax = true
				TestUnabled_boolRotXBack = true
				TestUnabled_boolRotYBack = true
				TestUnabled_boolRotZBack = true
-- 				TestUnabled_CmPreviewBack= true
				
				
				for i in Liste_MultiscatterActif do (
					Count_total_ALL = Count_total_ALL + i.Count
					PreviewCount_total_ALL = PreviewCount_total_ALL + i.MaxPreviewInstanceCount
					
					-- Gestion du  ON
					if boolONBack != i.ScatterIsOn do
						TestUnabled_ON = false
					boolONBack = i.ScatterIsOn
					
					-- Gestion du  DENSITY_MAP
					if boolDensityMapBack != i.Density_Map do
						TestUnabled_Density_Map = false
					boolDensityMapBack = i.Density_Map
					
					-- Gestion du  USE_DENSITY_MAPBACK
					if boolUse_Density_MapBack != i.Use_Density_Map do
						TestUnabled_Use_Density_Map = false
					boolUse_Density_MapBack = i.Use_Density_Map
					
					-- Gestion du  ECHELLEMIN
					if boolEchelleMinBack != i.Base_Scale[1] do
						TestUnabled_EchelleMin = false
					boolEchelleMinBack = i.Base_Scale[1]			
					
					-- Gestion du  ECHELLEMAX
					if boolEchelleMaxBack != i.Base_Scale[2] do
						TestUnabled_EchelleMax = false
					boolEchelleMaxBack = i.Base_Scale[2]						
					
					-- Gestion du  RotX
					if boolRotXBack != i.Random_Rotate[1] do
						TestUnabled_boolRotXBack = false
					boolRotXBack = i.Random_Rotate[1]						
					
					-- Gestion du  RotY
					if boolRotYBack != i.Random_Rotate[2] do
						TestUnabled_boolRotYBack = false
					boolRotYBack = i.Random_Rotate[2]
					
					-- Gestion du  RotZ
					if boolRotZBack != i.Random_Rotate[3] do
						TestUnabled_boolRotZBack = false
					boolRotZBack = i.Random_Rotate[3]	
					
-- 					-- Gestion CAmera preview
-- 					if CmPreviewBack != i.Camera_Preview do
-- 						TestUnabled_CmPreviewBack = false
-- 					CmPreviewBack = i.Camera_Preview	
					
					
				)
				-- Conclusion du  ON
				if TestUnabled_ON then  
					chk_On_Liste.state  = boolONBack
				else 
					chk_On_Liste.triState = 2
				
				-- Conclusion du  DENSITY_MAP
				if TestUnabled_Density_Map then  
					if boolDensityMapBack!= undefined then
						btn_MaskMap_ALL.map  = boolDensityMapBack
					else (
						btn_MaskMap_ALL.map = undefined
						btn_MaskMap_ALL.caption = "None"
					)
				else (
					btn_MaskMap_ALL.map = undefined
					btn_MaskMap_ALL.caption = "--"
				)
				/*
				-- Conclusion du  USE_DENSITY_MAPBACK
				if TestUnabled_Use_Density_Map then  
					chk_MaskMap_ALL.state  = boolUse_Density_MapBack
				else 
					chk_MaskMap_ALL.triState = 2			
				*/
				-- Conclusion du  ECHELLEMIN
				if TestUnabled_EchelleMin then  (
					spn_Echelle_Min.value  = boolEchelleMinBack
					spn_Echelle_Min.Indeterminate = false
				)
				else 
					spn_Echelle_Min.Indeterminate = true
				
				-- Conclusion du  ECHELLEMAX
				if TestUnabled_EchelleMax then  (
					spn_Echelle_Max.value  = boolEchelleMaxBack
					spn_Echelle_Max.Indeterminate = false
				)
				else 
					spn_Echelle_Min.Indeterminate = true

				-- Conclusion du  RotX
				if TestUnabled_boolRotXBack then  (
					spn_Rotation_X.value  = boolRotXBack
					spn_Rotation_X.Indeterminate = false
				)
				else 
					spn_Rotation_X.Indeterminate = true
				
				-- Conclusion du  RotY
				if TestUnabled_boolRotYBack then  (
					spn_Rotation_Y.value  = boolRotYBack
					spn_Rotation_Y.Indeterminate = false
				)
				else 
					spn_Rotation_Y.Indeterminate = true
				
				-- Conclusion du  RotZ
				if TestUnabled_boolRotZBack then  (
					spn_Rotation_Z.value  = boolRotZBack
					spn_Rotation_Z.Indeterminate = false
				)
				else 
					spn_Rotation_Z.Indeterminate = true
				
				-- Conclusion du  CAmera preview
-- 				if TestUnabled_CmPreviewBack then  (
-- 					if CmPreviewBack != undefined do btnCamPreview.text =  "Camera Preview : " + CmPreviewBack.name
-- 				)
-- 				else 
-- 					btnCamPreview.text =  "Camera Preview : ..." 
				
					
			--	print "FIN	Liste des scatters	-----------------------------"
			--	print ""
				
				
				-------------------------------------------------
				-- Gestion de l'affichage du rollout
				-------------------------------------------------
				
				Spn_MaxCount_ALL.value 					= int Count_total_ALL
				Spn_MaxCount_Preview_ALL.value 		= int PreviewCount_total_ALL
				
				
				fn_Gestion_desMinimum_count ()
				--fn_Gestion_desMinimum_PreviewCount ()
			)
		)
		
		
		
		
		---------------------------------------------------------------------------------------------------------------
		--	EDITION
		---------------------------------------------------------------------------------------------------------------
		
		fn fn_Change_ON_ALL state = (
			for i in Liste_MultiscatterActif do (
				i.ScatterIsOn = state
			)
			fn_Init()
		)
		
		
		fn fn_Change_Maxcount_ALL val = (
			-- gestion des changements : 		
			if val >ValeurMax_count then (
				for i in Liste_MultiscatterActif do (
					
					countCoef_Temp = float  i.Count / Count_total_ALL 
					count_Temp = ( countCoef_Temp * val )  as integer
					
					i.Count  = count_Temp 
				)
				
				Count_total_ALL = val
			) else (
				j=1
				for i in Liste_MultiscatterActif do (				
					i.Count					 = ListeDesCoef_count[j]
					j+=1
				)
				Spn_MaxCount_ALL.value = ValeurMax_count
				Count_total_ALL = ValeurMax_count
			)
		) -- FIN fn_Change_Maxcount_ALL
		
		
		
		fn fn_Change_MaxcountPreview_ALL val = (
	-- gestion des changements : 		
			if val >ValeurMax_count then (
				print "oui"
				for i in Liste_MultiscatterActif do (
					
					countCoef_Temp = float  i.MaxPreviewInstanceCount / PreviewCount_total_ALL 
					count_Temp = ( countCoef_Temp * val )  as integer
					
					i.MaxPreviewInstanceCount = count_Temp 
				)
				Spn_MaxCount_Preview_ALL.value = val
				PreviewCount_total_ALL = val
			) else (
				print "non"
				j=1
				for i in Liste_MultiscatterActif do (				
					i.MaxPreviewInstanceCount					 = ListeDesCoef_count[j]
					j+=1
				)
				Spn_MaxCount_Preview_ALL.value = ValeurMax_count
				PreviewCount_total_ALL = ValeurMax_count
			)
		)-- FIN fn_Change_MaxcountPreview_ALL

		fn fn_Change_ON_MaskMap_ALL state = (
			--print  val
			for i in Liste_MultiscatterActif do (
				state
				--i.ScatterIsOn = state
			)
		)				
		
		fn fn_Change_rdo_Cible arg = (
			print arg
			case arg of (
				1:	(
						for i in objects do (
							if classof i == MultiScatter do
								append Liste_MultiscatterActif i
						)
					)
				2:	(
						for i in selection do (
							if classof i == MultiScatter do
								append Liste_MultiscatterActif i
						)
					)
			)
			
			Check_Cible = arg
			
		)
		
		fn fn_Change_UseMaskMap_ALL state = (
			for i in Liste_MultiscatterActif do (
				i.Use_Density_Map = state
			)
		)	
		
		fn fn_Change_MaskMap_ALL mapTemp = (
			for i in Liste_MultiscatterActif do (
				i.Density_Map = mapTemp
			)
			fn_Init()
		)		
		
		fn fn_Change_Echelle_Min val = (
			for i in Liste_MultiscatterActif do (
				i.Base_Scale[1] = val
			)
		)
		
		fn fn_Change_Echelle_Max val = (
			for i in Liste_MultiscatterActif do (
				i.Base_Scale[2] = val
			)
		)		
		
		
		
		fn fn_Change_Rotation_X val = (
			for i in Liste_MultiscatterActif do (
				i.Random_Rotate[1] = val
			)
		)		
		fn fn_Change_Rotation_Y val = (
			for i in Liste_MultiscatterActif do (
				i.Random_Rotate[2] = val
			)
		)	
		fn fn_Change_Rotation_Z val = (
			for i in Liste_MultiscatterActif do (
				i.Random_Rotate[3] = val
			)
		)			
		
		
		
		fn fnSelectsources = (
			clearselection()
			--print ("Liste_MultiscatterActif : " + Liste_MultiscatterActif as string)
			for i in  Liste_MultiscatterActif do (
				for o in i.ScatterObjectsNodeList do (
					try(
					selectmore o
					)catch()
				)
			)
		)
		
		fn fnSelectDistrib = (
			clearselection()
			--print ("Liste_MultiscatterActif : " + Liste_MultiscatterActif as string)
			for i in  Liste_MultiscatterActif do (
				for o in i.Node_Mesh do (
					try(
					selectmore o
					)catch()
				)
			)
		)
		
		fn fnCamPreview = (
			
			local cam = getActiveCamera() 
			local activeViewportBack = viewport.activeViewportID
			
			
			if viewport.numViewEx() >1  do  (
				
				viewport.activeViewportID =  4
				cam = getActiveCamera()
-- 				viewport.activeViewportID = activeViewportBack
			)
			
			if cam != undefined do (
				print "CAM"
				for i in Liste_MultiscatterActif do (
					print i
					i.Camera_Preview = cam
				)
			)
			fn_Init()
		)
		
		
		--------------------------------------------
		
		
		
		
		
			--------------------------------------------
		
		
		
		


		
		
		
			--------------------------------------------
		
		





		on Rollout_ManageMultiScatter open do
			fn_Init()
		on chk_On_Liste changed state do
		(
				with undo label:"chk_On_Liste" on 
							fn_Change_ON_ALL state
			)
		on Spn_MaxCount_ALL changed val do
		(
				with undo label:"Spn_MaxCount_ALL" on 
							fn_Change_Maxcount_ALL 	Spn_MaxCount_ALL.value
			)
		on Spn_MaxCount_Preview_ALL changed val do
		(
				with undo label:"Spn_MaxCount_Preview_ALL" on 
							fn_Change_MaxcountPreview_ALL	Spn_MaxCount_Preview_ALL.value
			)
		on btn_MaskMap_ALL picked arg do
			fn_Change_MaskMap_ALL arg
		on spn_Echelle_Min changed val do
		(
				with undo label:"spn_Echelle_Min" on 
							fn_Change_Echelle_Min	val
			)
		on spn_Echelle_Max changed val do
		(
				with undo label:"spn_Echelle_Max" on 
							fn_Change_Echelle_Max	val
			)
		on spn_Rotation_X changed val do
		(
				with undo label:"spn_Rotation_X" on 
							fn_Change_Rotation_X	val
			)
		on spn_Rotation_Y changed val do
		(
				with undo label:"spn_Rotation_Y" on 
							fn_Change_Rotation_Y	val
			)
		on spn_Rotation_Z changed val do
		(
				with undo label:"spn_Rotation_Z" on 
							fn_Change_Rotation_Z	val
			)
		on btnSelectsources pressed do
		(
		fnSelectsources ()
			)
		on btnselectDistrib pressed do
		(
		fnSelectDistrib()
			)
		on btnCamPreview pressed do
		(
			fnCamPreview()
			)
		on lbx_multiScatt selectionEnd do
		(
			--select Liste_Multiscatter[sel]
			fn_Init()
			)
		on lbx_multiScatt doubleClicked sel do
		(
			select Liste_Multiscatter[sel]
			fn_Init()
			)
		on btnCamVueActive pressed do
		(
			
			
				
			local camActive = getActiveCamera ()
			local activeViewportBack = viewport.activeViewportID
			
			
			if viewport.numViewEx() >1  do  (
				
				viewport.activeViewportID =  4
				camActive = getActiveCamera()
				viewport.activeViewportID = activeViewportBack
			)
			
			
			
			if camActive != undefined then (
				for scatt in Liste_Multiscatter do 
					scatt.CameraAdaptationNode = camActive
				format "Multiscatters : Caméra active : %\n"  camActive.name
			) else (
				format "Multiscatters : Erreur : La vue active n'est pas une caméra\n"
			)
			/* 
			if selection.count == 1 do
				if superclassof $ == Camera do
					for scatt in Liste_Multiscatter do 
						scatt.CameraAdaptationNode = $
				 */
			)
		on chk_mute changed state do
		(
			case state of (
				true: (
					etat_scatters = #()
					for scatt in Liste_Multiscatter do (
						append etat_scatters scatt.ScatterIsOn
						scatt.ScatterIsOn = off
					)
				)
				false: (
					for i = 1 to Liste_Multiscatter.count do (
						Liste_Multiscatter[i].ScatterIsOn = etat_scatters[i]
					)
				)
			)
			fn_Init()
		)
	)
	on Execute do
	(
		try (DestroyDialog Rollout_ManageMultiScatter) catch ()
		createDialog Rollout_ManageMultiScatter  pos:[100,150] lockHeight:true style:#(#style_toolwindow, #style_sysmenu, #style_maximizebox, #style_minimizebox )				--#(#style_resizing,#style_toolwindow, #style_sysmenu )
	)
	
	
	

	
	
	
	

)

