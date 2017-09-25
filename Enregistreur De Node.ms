


struct str_enregistreurDeNode (
	private
	separateur_items 	= ";",
	separateur_tableaux = "§",
	
	public
	fn get_datas 	_node =(
		local dataResult =""		
		local nodeTemp = copy  _node
		convertToPoly nodeTemp
		
		--- les vertex ----
		for i=1 to (polyop.getNumVerts  nodeTemp )  do
			dataResult += (polyop.getVert  nodeTemp 	i ) as string + separateur_items
		--- de la partie ----
		dataResult += separateur_tableaux 
		
		--- les edges ----
		for i=1 to (polyop.getNumEdges  nodeTemp )  do
			dataResult += (polyop.getEdgeVerts  nodeTemp 	i ) as string + separateur_items
		--- de la partie ----
		dataResult += separateur_tableaux 
		 
		--- les faces ----
		for i=1 to (polyop.getNumFaces  nodeTemp )  do
			dataResult += (polyop.getFaceVerts  nodeTemp 	i ) as string + separateur_items
		--- de la partie ----
		dataResult += separateur_tableaux 
		
		--- les smoothing group ----
		for i=1 to (polyop.getNumFaces  nodeTemp )  do
			dataResult += (polyop.getFaceSmoothGroup  nodeTemp 	i ) as string + separateur_items
		--- de la partie ----
		dataResult += separateur_tableaux 
		
		--- les material ID ----
		for i=1 to (polyop.getNumFaces  nodeTemp )  do
			dataResult += (polyop.getFaceMatID   nodeTemp 	i ) as string + separateur_items
		--- de la partie ----
		dataResult += separateur_tableaux 
		
		delete nodeTemp
		
		format "dataResult :%\n" dataResult
		dataResult
	),

	fn creer_objet		_datas	=(
		local 	nvNode = convertToPoly (mesh ())
		nvNode.EditablePoly.SetSelection #Face #{1..25}
		nvNode.EditablePoly.delete #Face
		
		local donnees = filterString 	_datas 	separateur_tableaux
		format "donnees :%\n" donnees.count
		
		-- les vertex -- 
		local datas_pts = filterString 	donnees[1] 	separateur_items
		local pts = for data in datas_pts collect ( execute data )
		for pt in  pts do 
			polyop.createVert nvNode	pt
			
		-- les edges -- 
		local datas_edges = filterString 	donnees[2] 	separateur_items
		format "datas_edges :%\n" datas_edges
		local edges = for data in datas_edges collect ( execute data )
		for edge_pts in  edges do 
			polyop.createEdge nvNode		edge_pts[1] 	edge_pts[2]
		
		-- les faces -- 
		local datas_faces = filterString 	donnees[3] 	separateur_items
		format "datas_faces :%\n" datas_faces
		local faces = for data in datas_faces collect ( execute data )
		for face_pts in  faces do 
			polyop.createPolygon	 nvNode		face_pts
		
		--- les smoothing group ----
		local datas_SG = filterString 	donnees[4] 	separateur_items
		format "datas_SG :%\n" datas_SG
		local SGs = for data in datas_SG collect ( execute data )
		for i = 1 to  SGs.count do 
			polyop.setFaceSmoothGroup	 nvNode		i  SGs[i]
		
		--- les material ID ----
		local datas_matID = filterString 	donnees[5] 	separateur_items
		format "datas_matID :%\n" datas_matID
		local matIDs = for data in datas_matID collect ( execute data )
		for i = 1 to  matIDs.count do 
			polyop.setFaceMatID	 nvNode		i  matIDs[i]
		
		
		
		
		select nvNode
	)
	
)
/* 

popo = str_trimeshMgr ()

data3D = popo.get_datas $urba_batiment003

popo.creer_objet 	data3D


 */

