

fn getNodeInXref _nodeName _xref = (
	local _node
	local xrefsObj = _xref.tree.children
	
	for obj in xrefsObj /* where classOf obj == MultiScatter  */do 
		if obj.name == _nodeName do _node = obj
	
	_node
)

fn matchCamera 	_cameraAMatcher 	 _cameraCible  	=(
	_cameraAMatcher.transform 	= _cameraCible.transform
	_cameraAMatcher.fov 			= _cameraCible.fov
	_cameraAMatcher.nearrange 	= _cameraCible.nearrange
	_cameraAMatcher.farrange 	= _cameraCible.farrange
	_cameraAMatcher.nearclip 	= _cameraCible.nearclip
	_cameraAMatcher.farclip 		= _cameraCible.farclip
)

 ---- Match cam scatter dun xref à la camera cible ----
aXref=xrefs.getXRefFile 3
cameraScatters = getNodeInXref  "Cam - Scatters" aXref
camCible = $'Cam - jardin'
-- camCible = $'Cam - Rue'
matchCamera cameraScatters camCible





-- node_eau.pos.z += 10