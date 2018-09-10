
macroScript MatchCamera
category:"#CPages"
buttonText:"MatchCam"
toolTip:"Match cameras"
(
	fn cam_filt 		obj = superclassof obj == camera
	

	fn assign_camPreview_to_cam	_camPrev	_camCible =(
		_camPrev.parent 			= _camCible
		_camPrev.transform 		= _camCible.transform
		_camPrev.fov 				= _camCible.focalLength	
	)

	local camPreview, camCible
	
	camPreview		=	 pickObject 	message:"Camera à matcher"	filter:cam_filt
	camCible			=	 pickObject 	message:"Camera cible"  rubberBand:camPreview.pos	filter:cam_filt
	assign_camPreview_to_cam	camPreview	camCible


)












