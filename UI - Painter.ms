
-- include "$userScripts\cp - GLOBAL\Polices.ms"

 struct str_couleur (				
				---- couleurs ----
				blanc			= 	white,

				bleu1 		= 	color 		100	100	200,
				bleu2 		= 	color 		25		25		70,

				gris1 			= 	color 		100	100	100,
				gris2	 		=  color 	40		40		40	,
				gris3	 		=  color 	32		32		32,
				gris4	 		=  color 	17		17		17,
				gris5	 		=  color 	13		13		13,
				
				---- couleurs par defaut ----
				fond 			= 	color 		5		5		5,	
				police 		= 	blanc,
				point 		= 	blanc,
				surbrillance = 	color 		200	200	10,
				defaut		= 	gray,
	 
				---- couleurs boutons ----
				repos 		= 	defaut,
				survol	 	=  color 	250	250	32	,
				press	 		=  white

	 
	)
 
struct str_painter (
	
	------------ DEBUG	----------------------------------------------------------------------------------
-- 		m_debug = true,
		m_debug = false,
		m_dbgPrefix ="Painter",
		fn debug 	_txt  var:	 param:    =(
			if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		),
	----------------------------------------------------------------------------------------------------------
	
		
		
		
	m_ui,
	
	m_couleurs =  str_couleur (),
	
	m_taille 	= 	[m_ui.width, m_ui.height ],
	
	m_bmpCourante	= bitmap 	m_taille.x 	m_taille.y		color:m_couleurs.fond	,
	m_bmpFond	 	= bitmap 	m_taille.x 	m_taille.y		color:m_couleurs.fond	,
	
	
	m_police 	= str_policePetite (),
	
--------- 	FONCTIONS	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	fn getBitmap = m_bmpCourante,
	fn setBitmap _bmp= m_bmpCourante = copy _bmp,
		
	fn bigmatrixMultExt k M = (
		a=M.rows
		b=M.columns 
		matrice=bigmatrix a b
		for i=1 to a do for j=1 to b do matrice[i][j]=M[i][j]*k
		matrice
	),

	fn moins M = (
		a=M.rows
		b=M.columns 
		matrice=bigmatrix a b
		matrice=bigmatrixMultExt -1 M
		matrice
	),

	fn bigmatrixMult M N=(
		a=M.rows
		b=M.columns 
		c=N.columns 			
		matrice=bigmatrix a c
		for i=1 to a do for j=1 to c do (
			matrice[i][j]=0
			for k=1 to b do matrice[i][j]+=M[i][k]*N[k][j]					
		)
		matrice
	),

	fn Matrice2Rotation2LEllipse_glob  	_pt_ctr	 	_pt_axe	=(
		
		
		bmRotationEllipse	=	bigmatrix 2 2
		axe=[ _pt_axe[1] 	- _pt_ctr[1] , 	_pt_axe[2] - _pt_ctr[2] ]	

			
		--parent.pt_axe
		
		try (
			-- 		_Angle =atan  (bmB[2][1]/bmB[1][1])
			_Angle =atan  (axe[2]/axe[1])
			if  (axe[1] )<0 do _Angle =_Angle +180
		)
		catch _Angle = 90 * abs axe[2] / axe[2]
		
		bmRotationEllipse[1][1]		=	cos 	_Angle
		bmRotationEllipse[1][2]		=	-sin 	_Angle
		bmRotationEllipse[2][1]		=	sin 	_Angle
		bmRotationEllipse[2][2]		=	cos 	_Angle	
		
		bmRotationEllipse	
		
	),
	
	fn Matrice2Rotation2LEllipse  		_pt_ctr	 	_pt_axe		=(
		
		
		local bmRotationEllipse	=	bigmatrix 2 2
		local axe =_pt_axe 	- _pt_ctr		
		local angleRot =atan  (axe[2]/axe[1])
		
		if  (axe[1] )<0 do angleRot =angleRot +180
		
		bmRotationEllipse[1][1]		=	cos 	angleRot
		bmRotationEllipse[1][2]		=	-sin 	angleRot
		bmRotationEllipse[2][1]		=	sin 	angleRot
		bmRotationEllipse[2][2]		=	cos 	angleRot	
		
		bmRotationEllipse	
		
	),
	
	fn rotateVecteur 		_vect	_angle =(
		local result =[0,0]
		result.x = _vect.x * cos _angle 	- 	_vect.y * sin _angle
		result.y = _vect.x * sin _angle 	+ 	_vect.y * cos _angle
		result
	),
	
	fn normPerpendiculaireADroite 		_droite_pt1		_droite_pt2	 =(
		local result 		=	[0,0]
		local vecDroite 	= _droite_pt2 - _droite_pt1
		result	 				= 	normalize ( rotateVecteur 		vecDroite	90 )
		
		result
	),
	
	
	
	fn dot2D 		_pt2D_1		_pt2D_	 =(
		local result = dot [ _pt2D_1.x , _pt2D_1.y , 0 ]  [ _pt2D_.x , _pt2D_.y , 0 ]
		result
	),
	
	
	
	fn projectionPointSurDroite 		_droite_pt1		_droite_pt2		_ptAProjeter 	=(
		
		local result 				= [0,0]
		local droite_coefDir
		local droite_coordOrig
		
		--- droites verticales ----
		if _droite_pt2.x == _droite_pt1.x then (
			
-- 			debug "Droites verticales" 
			/* 
			droite_coefDir 		= 0
			droite_coordOrig	= 0 */
			
			result.x = _droite_pt1.x
			result.y = _ptAProjeter.y

		--- autres droite ----
		)else (
			
-- 			debug "droite pas verticale"
			
-- 			local normal_perpendiculaire 	= normPerpendiculaireADroite  _droite_pt1  _droite_pt2
-- 			local normal_projection 		= normalize ( _droite_pt2 -  _droite_pt1  )
			
			local normal_perpendiculaire 	= normalize ( _droite_pt2 -  _droite_pt1  )
			local normal_projection 		= normPerpendiculaireADroite  _droite_pt1  _droite_pt2
			
			local normal_1 		= 	normal_perpendiculaire
			local normal_2 		=	normalize ( _ptAProjeter - _droite_pt1 )
			local dotVec 			= 	dot2D  	normal_1 	normal_2
			local	angleAlpha		=	acos dotVec
			local distProjection 	= 	sin angleAlpha * ( distance _ptAProjeter 	_droite_pt1 )
			
-- 			debug "angleAlpha" var:( 180 - angleAlpha )
-- 			debug "dotVec" var:dotVec
-- 			debug "distProjection" var:distProjection
			
			
			local normal_C1 		= 	normPerpendiculaireADroite  _droite_pt1  _droite_pt2 
			local normal_C2 		=	normalize (  _droite_pt1 - _ptAProjeter ) --normPerpendiculaireADroite   _droite_pt1  _ptAProjeter 
			local dotVecC 		= 	dot2D  	normal_C1 	normal_C2
			
-- 			debug "" 
-- 			debug "dotVecC -------------------> " var:dotVecC
			
			--- connaitre le sens de projection ----
			/* 
			local normal_b1 		= 	normalize ( _droite_pt1 - _droite_pt2 )
			local normal_b2 		=	normalize (  _droite_pt1 - _ptAProjeter )
			
			local	cosAngle_b			=	 ( dot2D  	normal_b1 	normal_b2 )
			
-- 			debug "angle_b" var:angle_b 
*/
			
-- 			
-- 			local distCible 		= distance _droite_pt2  	_droite_pt1
-- 			local distProj 			= cosAngle_b * distance  _ptAProjeter  	_droite_pt1
-- 			
			
-- 			debug "distCible" var:distCible
-- 			debug "distProj" var:distProj
			
			
			if dotVecC<0 do normal_projection = -1 * normal_projection
			
			
			local vecProjection 	= distProjection * normal_projection
			result 					= _ptAProjeter + vecProjection
			
			
			
			/* 
			droite_coefDir 		= ( _droite_pt2.y - _droite_pt1.y) / ( _droite_pt2.x - _droite_pt1.x) 
			droite_coordOrig	= _droite_pt1.y - _droite_pt1.x * droite_coefDir
			
			result.x = ( _ptAProjeter.x - droite_coordOrig + droite_coefDir * _ptAProjeter.y ) / (1 + droite_coordOrig*droite_coordOrig )
			result.y = ( droite_coordOrig + droite_coefDir * ( _ptAProjeter.x - droite_coordOrig + _ptAProjeter.y ) ) / (1 + droite_coordOrig*droite_coordOrig ) */
		)
		
	/* 	debug "droite_coefDir" var:droite_coefDir
		debug "droite_coordOrig" var:droite_coordOrig */
		debug "result" var:result
		
		
		result
	),
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	----- 	DESSIN	---------------	

	fn ecrire 			_posOrigine 	_txt	 			couleur:m_couleurs.defaut	 	= (
		
			local 	pos 		= [0,0]
		
			---- pour chaque charactere du texte ----
			for idCharac = 1 to 	_txt.count do (
				local characAEcrire 	= _txt[ idCharac ]
				local characPolice 	= m_police.get  characAEcrire
-- 				format "CHAR : %\n" characPolice
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
							local 	pos_rep 	= _posOrigine + pos +[ index_pix , index_ligne]
							
							---- on dessine le pixel, ou pas ... ---
							if val >0 do 	setPixels 	m_bmpCourante 	pos_rep  	#( couleur )
							
						)
					)
					pos +=  [ 		(characPolice[1].count ) + m_police.ecart , 0]
				)
			)
			
		
	),
	fn droite				pt_1 	pt_2  						couleur:m_couleurs.defaut		= (
		
		D = pt_1 - pt_2
		if abs D.x > abs D.y
			then (
				if D.x < 0 
					then for x = 0 to m_bmpCourante.width do (
						y =  pt_1.y + D.y/D.x * (x - pt_1.x)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					) else  for x = 0 to m_bmpCourante.width do (
						y =  pt_2.y + D.y/D.x * (x - pt_2.x)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
				)
			) else (
				if D.y < 0 
					then for y = 0 to m_bmpCourante.height do (
						x =  pt_1.x + D.x/D.y * (y - pt_1.y)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					) else for y = 0 to m_bmpCourante.height  do (
						x =  pt_2.x + D.x/D.y * (y - pt_2.y)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					)
		)
		--PAD_painter_roll.log_rayon = sqrt ( d.x^2 +  d.y^2)
	),
	fn droite_perp		pt_1 	pt_2  						couleur:m_couleurs.defaut		= (	--	droite perpendiculaire à la droite "pt_1 - pt_2"  passant par pt_1
-- 		pt_1 = 	repere_pad_bmp	pt_1
-- 		pt_2 =	repere_pad_bmp	pt_2
		D = pt_1 - pt_2
		if abs D.x < abs D.y
			then (
			--	format" A	>	\n"
				if D.x < 0 then (
-- 						format" 	A	1	>	\n"
					for x = 0 to m_bmpCourante.width do (
						
						y =  pt_1.y - D.x/D.y * (x - pt_1.x)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					)
				) else (
-- 						format" 	A	2	>	\n"
					for x = 0 to m_bmpCourante.width do (
						
						y =  pt_1.y - D.x/D.y * (x - pt_1.x)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					)
				)
			) else (
			--	format" B	>	\n"
				if D.y < 0 then (
-- 						format" 	B	1	>	\n"
					 for y = 0 to m_bmpCourante.height do (
						
						x =  pt_1.x - D.y/D.x * (y - pt_1.y)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					 )
				) else (
-- 						format" 	B	2	>	\n"
					 for y = 0 to m_bmpCourante.height  do (
						
						x =  pt_1.x - D.y/D.x * (y - pt_1.y)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					)
				)
		)
		--PAD_painter_roll.log_rayon = sqrt ( d.x^2 +  d.y^2)
	),
	fn demi_droite		pt_1 	pt_2  						couleur:m_couleurs.defaut		= (
		
		D = pt_1 - pt_2
		if abs D.x > abs D.y
			then (
				if D.x < 0 
					then for x = pt_1.x to m_taille.x do (
						y =  pt_1.y + D.y/D.x * (x - pt_1.x)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					) else  for x = 0 to pt_1.x do (
						y =  pt_2.y + D.y/D.x * (x - pt_2.x)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
				)
			) else (
				if D.y < 0 
					then for y = pt_1.y to m_taille.y do (
						x =  pt_1.x + D.x/D.y * (y - pt_1.y)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					) else for y = 0 to pt_1.y do (
						x =  pt_2.x + D.x/D.y * (y - pt_2.y)
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					)
		)
		--PAD_painter_roll.log_rayon = sqrt ( d.x^2 +  d.y^2)
	),
	fn segment 		pt_1 	pt_2  						couleur:m_couleurs.defaut		tiret:0 	espace:0	= (
		
		local D = pt_1 - pt_2
		local i_tiret 	= 0
		local i_espace = 0
		
		if abs D.x > abs D.y
			then (
				if D.x < 0 
					then for x = pt_1.x to pt_2.x do (
						y =  pt_1.y + D.y/D.x * (x - pt_1.x)
						
						local b_ecrire = true
						if tiret != 0 then (
							if i_tiret <= tiret 	then (
								i_tiret += 1
							) else	if i_espace <= espace 	then (
								i_espace += 1
								b_ecrire = false
							) else (
								i_tiret = 0
								i_espace = 0
							)
						)  
						
						if b_ecrire do 
							setPixels m_bmpCourante 	[x, y] 	#(couleur)
					) else  for x = pt_2.x to pt_1.x do (
						y =  pt_2.y + D.y/D.x * (x - pt_2.x)
						
						local b_ecrire = true
						if tiret != 0 then (
							if i_tiret <= tiret 	then (
								i_tiret += 1
							) else	if i_espace <= espace 	then (
								i_espace += 1
								b_ecrire = false
							) else (
								i_tiret = 0
								i_espace = 0
							)
						)  
						
						if b_ecrire do 
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
				)
			) else (
				if D.y < 0 
					then for y = pt_1.y to pt_2.y do (
						x =  pt_1.x + D.x/D.y * (y - pt_1.y)
						
						local b_ecrire = true
						if tiret != 0 then (
							if i_tiret <= tiret 	then (
								i_tiret += 1
							) else	if i_espace <= espace 	then (
								i_espace += 1
								b_ecrire = false
							) else (
								i_tiret = 0
								i_espace = 0
							)
						)  
						
						if b_ecrire do 
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					) else for y = pt_2.y to pt_1.y do (
						
						x =  pt_2.x + D.x/D.y * (y - pt_2.y)
						local b_ecrire = true
						if tiret != 0 then (
							if i_tiret <= tiret 	then (
								i_tiret += 1
							) else	if i_espace <= espace 	then (
								i_espace += 1
								b_ecrire = false
							) else (
								i_tiret = 0
								i_espace = 0
							)
						)  
						
						if b_ecrire do 
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
					)
		)
		--PAD_painter_roll.log_rayon = sqrt ( d.x^2 +  d.y^2)
	),
	fn cercle  			ctre		R 	  						couleur:m_couleurs.defaut		= (
		
-- 		ctre = 	repere_pad_bmp	ctre
		
		
		for	x=  (ctre.x - R*(cos 45) ) to  (ctre.x + R*(cos 45) )  do (
			y  =	sqrt (R^2 - (x-ctre.x)^2)	+ctre.y
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
			y  =	- sqrt (R^2 - (x-ctre.x)^2)	+ctre.y
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
		)
		for	y=  (ctre.y - R*(cos 45) ) to  (ctre.y + R*(cos 45) )  do (
			x  =	sqrt (R^2 - (y-ctre.y)^2)	+ctre.x
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
			x  =	- sqrt (R^2 - (y-ctre.y)^2)	+ctre.x
						setPixels m_bmpCourante 	[x, y] 	#(couleur)
		)
	),
	fn ovale 			CTR 	ptAxe	 r_A2 	  		couleur:m_couleurs.defaut		= (
		
		local r_A1 							= 	distance  	CTR 	ptAxe		
		
		local nbr_sgt 						= 	64
		local increment_angle 			= 	360.0 / nbr_sgt
		local points_ovale 				= 	#()		
		
		local bmC							=	bigmatrix 2 1
		for i=1 to 2 do bmC[i][1] 		= CTR[i]
		
		local bmAxe						= bigmatrix 2 1
		for i = 1 to 2 do bmAxe[i][1]	= ptAxe[i]-	bmC[i][1]
	
		local bmRotationEllipse			=	Matrice2Rotation2LEllipse 	CTR	ptAxe
		local bmResultat					=	bigmatrix 2 1
		local bm							=	bigmatrix 2 1
		
		--- on liste les points qui composent l'ovale -----
		for	s=0 to nbr_sgt do (
			bm[1][1] 		=  		r_A1		* 	cos (	s * increment_angle)		--	marge.x
			bm[2][1]		= 			r_A2  	* 	sin  (	s * increment_angle )		--	marge.x
			
			bmResultat		= 	bmC		+	bigmatrixMult 		bmRotationEllipse 	bm
			Result			=	[bmResultat[1][1] ,bmResultat[2][1] ]				
			
			append 			points_ovale 		Result
		)
		
		
		--- on dessine les segments de l'ovale -----
		nbr_sgt = points_ovale.count		
		for index = 1 to nbr_sgt	
			 do if index == nbr_sgt 	
				then  		segment 		points_ovale[index] 			points_ovale[1] 			 	couleur:couleur
				else 			segment 		points_ovale[index] 			points_ovale[index+1]  	couleur:couleur
		
	),
	fn rect_plein  		pt_1 	pt_2	 						couleur:m_couleurs.defaut		= (
		taille = pt_2 - pt_1
		if taille.x >1 and taille.y >1 do (
			bmp_rect = bitmap (abs taille.x ) (abs taille.y ) color:couleur
			pos = [	amin 	#(pt_2.x ,	pt_2.x )		,	amin 	#(pt_2.y ,	pt_2.y )		]
			pasteBitmap bmp_rect	m_bmpCourante 	[1,1]		pt_1
		)
	),
	fn rect  				pt1 	pt2	 						couleur:m_couleurs.defaut		tiret:0 	espace:0	= (
		
		coin_Ht_G = [	amin 	#(pt1.x ,	pt2.x )		,	amin 	#(pt1.y ,	pt2.y )		]		--	coin 1	:	Ht_G
		coin_Bs_G = [	amin 	#(pt1.x ,	pt2.x )		,	amax #(pt1.y , 	pt2.y )		]		--	coin 2	:	Bs_G
		coin_Ht_D = [	amax #(pt1.x , 	pt2.x )		,	amin 	#(pt1.y ,	pt2.y )		]		--	coin 3	:	Ht_D
		coin_Bs_D = [	amax #(pt1.x , 	pt2.x )		,	amax #(pt1.y ,	pt2.y )		]		--	coin 4	:	Bs_D
		segment 	coin_Ht_G 	coin_Bs_G  couleur:couleur	tiret:tiret 	espace:espace
		segment 	coin_Ht_G 	coin_Ht_D  couleur:couleur	tiret:tiret 	espace:espace
		segment 	coin_Bs_D	coin_Bs_G  couleur:couleur	tiret:tiret 	espace:espace
		segment 	coin_Bs_D 	coin_Ht_D  couleur:couleur	tiret:tiret 	espace:espace
	),
	fn grille  			_centre  	_ecart	 			couleur:m_couleurs.defaut		= (
		
		taille			= [	m_bmpCourante.width	,	m_bmpCourante.height ]	
		ecart_x 		=  _ecart
		ecart_y 		=  _ecart
		
		local posX = _centre.x
		while posX > 0 do ( 
			droite 	( [ posX  , 	0 ]  )	([ posX, 	m_taille.y ] ) 		couleur:couleur
			posX -= ecart_x
		)
		posX = _centre.x
		while posX < taille.x  do ( 
			droite 	( [ posX  , 	0 ]  )	([ posX, 	m_taille.y ] ) 		couleur:couleur
			posX += ecart_x
		)
		local posY = _centre.y
		while posY > 0 do ( 
			droite 	( [ 0, posY  ]  )	([ m_taille.x , posY ] ) 		couleur:couleur
			posY -= ecart_y
		)
		posY = _centre.y
		while posY < taille.y  do ( 
			droite 	( [ 0 , posY  ]  )	([m_taille.x ,  posY ] ) 		couleur:couleur
			posY += ecart_y
		)


	),
	fn grilleBACK  			pas_x 	pas_y	 				couleur:m_couleurs.defaut		= (
-- 		pt_1 = 	repere_pad_bmp	pt_1
-- 		pt_2 =	repere_pad_bmp	pt_2
		
		taille			= [	m_bmpCourante.width	,	m_bmpCourante.height ]	
		ecart_x 		= (taille.x / pas_x)
		ecart_y 		= (taille.y / pas_y)
		
		for ind_X = 1 to pas_x 
			do 	droite 	( [  ind_X *  ecart_x	, 	0 ]  )	([ ind_X * ecart_x	, 	m_taille.y ] ) 		couleur		m_bmpCourante	

		for ind_Y = 1 to pas_y 
			do	droite 	([ 0 ,  ind_Y * ecart_y ]  )		( [m_taille.x  	, 	ind_Y * ecart_y ] ) 			couleur		m_bmpCourante	
-- 		display m_bmpCourante
	),
	fn pt					pos									couleur:m_couleurs.defaut		= (
-- 			pos = repere_pad_bmp 	pos
			--- rond ----
			_color_33 		=	_color_66	= couleur as color
			_color_33.a 	= 255	/3
			_color_66.a 	= 255	*2/3
		
			--	rang 0	---
			setPixels m_bmpCourante (pos - [0,0]) #( couleur	)	
			
			--	rang 1	---
			setPixels m_bmpCourante (pos - [-1,0]) #( couleur	)	
			setPixels m_bmpCourante (pos - [1,0]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [0,-1]) #( couleur	)	
			setPixels m_bmpCourante (pos - [0,1]) 	#( couleur	)	
		
			setPixels m_bmpCourante (pos - [-1,-1]) #( couleur	)	
			setPixels m_bmpCourante (pos - [1,1]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [1,-1]) #( couleur	)	
			setPixels m_bmpCourante (pos - [-1,1]) #( couleur	)		
			
			--	rang 2	---
			setPixels m_bmpCourante (pos - [-2,0]) #( couleur	)	
			setPixels m_bmpCourante (pos - [2,0]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [0,-2]) #( couleur	)	
			setPixels m_bmpCourante (pos - [0,2]) 	#( couleur	)	

			setPixels m_bmpCourante (pos - [-1,2]) #( couleur	)	
			setPixels m_bmpCourante (pos - [1,2]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [2,-1]) #( couleur	)	
			setPixels m_bmpCourante (pos - [2,1]) #( couleur	)		
			
			setPixels m_bmpCourante (pos - [-1,-2]) #( couleur	)	
			setPixels m_bmpCourante (pos - [1,-2]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [-2,-1]) #( couleur	)	
			setPixels m_bmpCourante (pos - [-2,1]) #( couleur	)	


			--	rang 3
			setPixels m_bmpCourante (pos - [-1,3]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [0,3]) 		#( couleur	)	
			setPixels m_bmpCourante (pos - [1,3]) 		#( couleur	)	
			
			setPixels m_bmpCourante (pos - [-1,-3]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [0,-3]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [1,-3]) 	#( couleur	)	
			
			setPixels m_bmpCourante (pos - [3,-1]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [3,0]) 		#( couleur	)	
			setPixels m_bmpCourante (pos - [3,1]) 		#( couleur	)	
			
			setPixels m_bmpCourante (pos - [-3,-1]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [-3,0]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [-3,1]) 	#( couleur	)	
			
			setPixels m_bmpCourante (pos - [-2,-2]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [-2,2]) 	#( couleur	)	
			setPixels m_bmpCourante (pos - [2,-2]) 	#( couleur	)		
			setPixels m_bmpCourante (pos - [2,2]) 		#( couleur	)	
			
	),

	fn croix					pos				taille:6		couleur:m_couleurs.defaut		= (
-- 			pos = repere_pad_bmp 	pos
			--- rond ----
		
		_color_33 		=	_color_66	= couleur as color
		_color_33.a 	= 255	/3
		_color_66.a 	= 255	*2/3
		
		segment 		[pos.x - taille /2 , pos.y]		[pos.x + taille /2 , pos.y]  couleur:couleur
		segment 		[pos.x , pos.y - taille /2]		[pos.x, pos.y + taille /2 ]  couleur:couleur
	
	),

	
	
	
	
	
	----- ACTUALISATIONS	---------------	

	fn	ui_refresh = (
		
		m_ui.bitmap = m_bmpCourante
	),
	fn clear =(
		m_bmpCourante = bitmap m_taille.x m_taille.y color:m_couleurs.fond

	)
	
)	--	fin struct	---------------------------------------------------------------------------------------------



	
