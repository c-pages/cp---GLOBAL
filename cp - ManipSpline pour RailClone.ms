

-------------------------------------------------------------
-----  Appliquer RailClone à surface verticale ---------
-------------------------------------------------------------

-- 1 -- Freezer la spline séléctionnée ----
-- 2 -- Plaquer la spline en [0,0,0] horizontalement -----
-- 3 -- Creer un objetb RailClone ----
-- 4 -- Charger le zinc depuis la libraierie railclone ----
-- 5 -- Appliquer à la spline ----
-- 6 -- Parenter le railclone à la spline ----
-- 7 -- Reset Transfrom de la spline ----

-------------------------------------------------------------



fn FreezePerso CurObj = (
	-- ****** FREEZE **********
Try
	(	
	--	 print "freezzzzzzzzz"	
		if classof CurObj.rotation.controller != Rotation_Layer do
		(

			-- freeze rotation		
			CurObj.rotation.controller = Euler_Xyz() 		
			CurObj.rotation.controller = Rotation_list() 			
			CurObj.rotation.controller.available.controller = Euler_xyz() 		
			
			/* "Localization on" */  
		
			CurObj.rotation.controller.setname 1 "Frozen Rotation" 		
			CurObj.rotation.controller.setname 2 "Zero Euler XYZ" 		
		
			/* "Localization off" */  
			
			CurObj.rotation.controller.SetActive 2 		
		)
		if classof CurObj.position.controller != Position_Layer do
		(

			-- freeze position
			CurObj.position.controller = Bezier_Position() 			
			CurObj.position.controller = position_list() 			
			CurObj.position.controller.available.controller = Position_XYZ() 	

			/* "Localization on" */  
					
			CurObj.position.controller.setname 1 "Frozen Position" 	
			CurObj.position.controller.setname 2 "Zero Pos XYZ" 			
			
			/* "Localization off" */  
			
			CurObj.position.controller.SetActive 2 		

			-- position to zero
			CurObj.Position.controller[2].x_Position = 0
			CurObj.Position.controller[2].y_Position = 0
			CurObj.Position.controller[2].z_Position = 0
		)
	)	
	/* "Localization on" */  
			
	Catch( messagebox "A failure occurred while freezing an object's transform." title:"Freeze Transform")
			
	
		-- ****** fin de FREEZE **********
) -- ***	FIN FreezePerso	***



	
	
	
	
	
rollout roll_AppliquerRC_a_spline "RC to spline" width:156 height:55
(
	local RC_origine
	
	fn RC_filt obj = classof obj == RailClone_Pro
	fn Spline_filt obj = superClassOf obj == shape
	
	pickButton 'btn_RC' 	"RailClone à copier" pos:[10,8] width:136 height:18 toolTip:"RailClone à copier" align:#left autoDisplay:true
	pickButton 'btn_spline' "Spline" pos:[11,30] width:136 height:18 toolTip:"Piquer la spline à laquelle applisuer le railClone" align:#left enabled:false

	
	fn positionnePourRailcClone 	_spline 	=(
		
		-- 1 -- Freezer la spline séléctionnée ----
		FreezePerso _spline
		
		-- 2 -- Plaquer la spline en [0,0,0] horizontalement -----
		_spline.transform = matrix3 1	
		
		-- 3 -- Creer un objetb RailClone ----
		RC_Zinc = copy RC_origine

		-- 4 -- Charger le zinc depuis la libraierie railclone ----
		
		
		-- 5 -- Appliquer à la spline ----
		RC_Zinc.banode[1] = _spline
		
		-- 6 -- Parenter le railclone à la spline ----	
		RC_Zinc.parent = _spline
		
		-- 7 -- Reset Transfrom de la spline ----
	 	select _spline
	 	macros.run "Animation Tools" "TransformToZero"
		
	)
	
	


	on btn_RC picked obj do	(
		RC_origine = obj
		
		if RC_origine != undefined do (
			btn_spline.enabled = true
		)
	)
	on btn_spline picked obj do	(
		positionnePourRailcClone obj
		btn_spline.object =undefined
	)
	
	
)
	
createdialog roll_AppliquerRC_a_spline
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
