/* stateSetsDotNetObject = dotNetObject "Autodesk.Max.StateSets.Plugin"
show stateSetsDotNetObject
tmp1 = stateSetsDotNetObject.SequencerTreeView
stateSetsDotNetObject.TreeView

masterState = stateSetsDotNetObject.EntityManager.RootEntity.MasterStateSet
show masterState


masterState.DescendantStateCount

show  stateSets


show masterState.Children.Item

show masterState.Children.Item[0]



show masterState.Children.Item[1].Children.Item[0].CustomAttributes.Item[0]

show masterState.Children.Item[0].ActiveViewportCamera.Name
show masterState.Children.Item[0].RenderRange
 */




stateSetsDotNetObject = dotNetObject "Autodesk.Max.StateSets.Plugin" --Get StateSets dotNet object. 
stateSets = stateSetsDotNetObject.Instance 
masterState = stateSets.EntityManager.RootEntity.MasterStateSet


listePlans = #()
for n = 0 to masterState.Children.count-1 do 
	if masterState.Children.Item[n].ActiveViewportCamera != undefined do (
		
		itemTmp 		= masterState.Children.Item[n]
		
		NomDeLaCam 	= itemTmp.ActiveViewportCamera.Name
		range_debut 	= itemTmp.RenderRange.Start / 200
		range_fin 		= itemTmp.RenderRange.End / 200
		zeroTmp 		= if n< 9 then "0" else ""
		format "NomDeLaCam : % (%->%)\n" NomDeLaCam range_debut range_fin
		
		--/* 
		---- RENOMMMER LES CAMERA type "Plan 15" --------
		select (execute ("$'" + NomDeLaCam + "'"))
		$.name = "Plan" + zeroTmp + (n +1) as string
		--*/
	)
