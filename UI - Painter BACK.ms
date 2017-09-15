


						
	
global PAD_painter_roll

--global painter_utils

col_police 			= 	white
col_point 			= 	white

col_surbrillance 	= 	color 		200	200	00

col_bleu1 			= 	color 		100	100	200
col_bleu2 			= 	color 		25		25		70

col_gris1 			= 	color 		100	100	100
col_gris2	 		=  color 	40		40		40	
col_gris3	 		=  color 	32		32		32
col_gris4	 		=  color 	17		17		17
col_gris5	 		=  color 	13		13		13

color_fond 			= 	color 		10		10		10


struct pad_point (
	
	pos 				= 	[0,0]							,
	pos_back									,
	nom 				= 	"" 								,
	col_repos 		=	col_bleu1					,
	col_survol		=	col_surbrillance			,
	b_survol 		= 	false							,	
	b_nom 			= 	false							,	
	type=#point,
	distance_survol = 4,
	parent											,
	elypse											,
	parent_survol	=	#()						,
	rayon												,
	radial ,
	fn snap _pos = (	---	pos : 1 axe, pas x et y 
		--format "sanp\n"
		snapgrid = parent.painter.snapgrid
		taille_snap = parent.painter.pad_taille.x / snapgrid
		--val = pos/snapgrid
		
		int_ = int ( _pos / taille_snap ) 
		val = (	( _pos / taille_snap ) - int_ ) 
		if val > 0  
			then if abs val <.5	
				then	val = ( int_  ) * taille_snap 		
				else	val = ( int_ +1 ) * taille_snap 
			else if abs val <.5	
				then	val =  ( int_ ) * taille_snap 		
				else	val =  ( int_ - 1.0 ) * taille_snap 
		val	
	),
	fn bouge _pos	= (
		--	SNAP				--------
		if parent.painter.b_snap do (
			_pos.x = snap pos.x
			_pos.y = snap pos.y
		)
		--	CONTRAINTES	--------
		case (parent.type) of (----------------------------------------------------------------------
			#linear:	(
 				format	">	linear:	\n"
				
			)
			#radial:	(
-- 				format	">	radial:	nom : %\n"	nom
				
				case nom of (--------------------------------------------------
					"A1":	(
						
						parent.pt_axe.pos = _pos
						
						for elem in parent.elements do (
							
							elem.refresh_pt2()	
							elem.maj_parram()
							elem.refresh_pt1()		
						)
					)
					"A2":	(
-- 						
						elypse.reoriente_ptAxe()
-- 						elypse.refresh_pt2()	
						elypse.refresh_pt1()	
						elypse.maj_parram()
						for elem in parent.elements do (
							--elem.reoriente_ptAxe()
							elem.refresh_pt1()	
							elem.refresh_pt2()	
							
							elem.maj_parram()
						)
					)
					"B1":	(
						
-- 						elypse.refresh_pt1()	
						elypse.contrainte 	elypse.pt_1 	parent.pt_ctr 	parent.elypse_A.pt_1
						
						elypse.maj_parram()
						--for elem in parent.elements do (
							
								
						
						--parent.pt_axe.pos = _pos
					)
					"B2":	(
						
						elypse.contrainte elypse.pt_2 parent.pt_ctr 	parent.elypse_A.pt_2
						parent.pt_axe.pos = parent.elypse_B.pt_1.pos
						
						elypse.maj_parram()
						for elem in parent.elements do (
-- 							--elem.reoriente_ptAxe()
-- 							elem.refresh_pt1()	
-- 							elem.refresh_pt2()	
-- 							
-- 							elem.maj_parram()
						)
					)
					
					"C":	(
					--	if pos_back == undefined then pos_back = _pos
						--parent.pt_ctr.pos = _pos
						deplacement = _pos - pos_back
-- 						format "deplacement:%\n" deplacement
						for elem in parent.elements do (
							--elem.reoriente_ptAxe()
-- 							elem.refresh_pt1()	
-- 							elem.refresh_pt2()	
							elem.pt_1.pos += deplacement
							elem.pt_2.pos += deplacement
							elem.maj_parram()
						)
						
						parent.pt_axe.pos += deplacement
						parent.pt_ctr.pos = _pos
						pos_back = _pos
					)
				)	--	fin case nom of-------------------------------------------
			
			)--	fin radial	--------------------------
			
			default: (
				
-- 				format	">	classof:	default\n"
				
				
			)
		)	-- fin case (parent.type) of ------------------------------------------------------------------------
		
	),
	fn draw  _bmp	 = (				
		decalage_txt = [5,-10]
		if b_survol 
			then _color	= col_survol
			else _color	 	= col_repos
		
		--- textes	-----
		if parent.painter.b_infos then (	
			if b_nom do (
				--if parent !=undefined 	then 	_nom = parent.nom + nom else _nom = nom
				parent.painter.write		(pos /*+ parent.painter.repere_bmp_pad 	decalage_txt */)		nom 	#small		_color	_bmp		decalage_txt
			)
		)
		
		else if b_survol do (	
			if b_nom do (
				--if parent !=undefined 	then 	_nom = parent.nom + nom else _nom = nom
				parent.painter.write		(pos /*+ parent.painter.repere_bmp_pad 	decalage_txt */)		nom 	#small		_color	_bmp		decalage_txt
			)
		)
		
		--- dessin	-----
		parent.painter.pt	pos	_color	_bmp
		
	),
	on create do (
		
	)
	
)


struct PAD_elypse (
	pos 			= 	[0,0]					,
	nom 			= 	"" 						,
	col_repos 	=	col_bleu1			,
	col_survol	=	col_surbrillance	,
	rayon_1		=	0.0					,	
	rayon_2		=	0.0					,
-- 	ratio_rayon	,	
	ratio_pos 	= 	0.5			,
	parent	,
	pt_1 = pad_point	nom:(nom + "1")	parent:parent	rayon:1 		b_nom:true		elypse:this,
	pt_2 = pad_point	nom:(nom + "2")	parent:parent	rayon:2 		b_nom:true		elypse:this,
	elements = # (pt_1 , pt_2)		,
	
	b_survol = false	,
	type=#elypse,
	
	
	
	fn angle_pts 	pt1	pt2	= (	--	pt1 : centre
		
		if pt1.x >= pt2.x then (

				_angle = 180+ atan ( ( pt1.y - pt2.y) / ( pt1.x - pt2.x ) )

		) else (
			if pt1.y >= pt2.y then (
				
				format "B1\n"
				_angle = 360 + atan ( ( pt1.y - pt2.y) / ( pt1.x - pt2.x ) )
			) else (
				format "B2\n"
				_angle = atan ( ( pt1.y - pt2.y) / ( pt1.x - pt2.x ) )
			)
		)
		format "_angle : %\n" _angle		
		_angle
	)
	,
	fn reoriente_ptAxe =(
		pos_ctr 		= 	parent.pt_ctr.pos
		pos_axe		= 	parent.pt_axe.pos
		pos_pt1 	= 	pt_1.pos
		pos_pt2 	= 	pt_2.pos

		bmRotationEllipse	=	bigmatrix 2 2		
		bmRotationEllipse[1][1]		=	0.0
		bmRotationEllipse[1][2]		=	1
		bmRotationEllipse[2][1]		=	-1
		bmRotationEllipse[2][2]		=	0.0
		
		bmC= bigmatrix 2 1
			for i=1 to 2 do bmC[i][1] = pos_ctr[i]
		bm2 = bigmatrix 2 1
			for i=1 to 2 do bm2[i][1] = pos_pt2[i]
		bmResultat		=	bigmatrix 2 1
			
			bmC			=	bigmatrix 2 1
		for i=1 to 2 do bmC[i][1] = parent.pt_ctr.pos[i]
		bmAxe=bigmatrix 2 1
		for i = 1 to 2 do bmAxe[i][1]= parent.pt_axe.pos[i]-	bmC[i][1]
		bmResultat		=	bigmatrix 2 1
		bmResultat 	= 	bmC + bigmatrixMultExt (rayon_1/rayon_2) ( bigmatrixMult ( bmRotationEllipse ) (bm2+ moins bmC) ) 
		
		pos_axe_dest = [bmResultat[1][1],bmResultat[2][1]]
		
		parent.pt_axe.pos 	= pos_axe_dest
		
	)
	,	
	
		
	
	fn refresh_pt1=(
		
		bmC			=	bigmatrix 2 1
		for i=1 to 2 do bmC[i][1] = parent.pt_ctr.pos[i]
		bmAxe=bigmatrix 2 1
		for i = 1 to 2 do bmAxe[i][1]= parent.pt_axe.pos[i]-	bmC[i][1]
		bmResultat		=	bigmatrix 2 1
		
		bm				=	bigmatrix 2 1
		bm[1][1]		=	rayon_1
		bm[2][1]		=	0
		bmResultat 	= 	bmC + bigmatrixMult ( parent.painter.Matrice2Rotation2LEllipse		 parent.pt_ctr.pos	parent.pt_axe.pos) (bm)	
		pt_1.pos.x  	= 	bmResultat[1][1]
		pt_1.pos.y  	=	bmResultat[2][1]
		
	),
	fn contrainte _pt 	_ptlim1 _ptlim2 =(
		
		d=( dot2 (_pt.pos - _ptlim1.pos) ( _ptlim2.pos-_ptlim1.pos ) )  / (dist _ptlim2.pos _ptlim1.pos)^2-- M1M.M1M2 / M1M2^2 
		
		
		if d >= 1 then (  
			d=1.0--_pt.pos =  _ptlim2.pos 			
			)
		else	
			if d<=0 
				then ( d=0.001 )
							
		_pt.pos = _ptlim1.pos + d * (  ( _ptlim2.pos-_ptlim1.pos )    )
		
		--format " d _pt.pos _ptlim1.pos  _ptlim2.pos % % % % \n"  d _pt.pos _ptlim1.pos  _ptlim2.pos
		
		)
			
			
			
	,
	fn refresh_pt2=(
		bmC			=	bigmatrix 2 1
		for i=1 to 2 do bmC[i][1] = parent.pt_ctr.pos[i]
		bmAxe=bigmatrix 2 1
		for i = 1 to 2 do bmAxe[i][1]= parent.pt_axe.pos[i]-	bmC[i][1]
		bmResultat=bigmatrix 2 1		
		bm=bigmatrix 2 1
		bm[1][1]=0
		bm[2][1]=rayon_2
		bmResultat = bmC + bigmatrixMult (	 parent.painter.Matrice2Rotation2LEllipse		 parent.pt_ctr.pos	parent.pt_axe.pos	) (bm)	
		pt_2.pos.x=bmResultat[1][1]
		pt_2.pos.y=bmResultat[2][1]
	)
	,
	
	fn maj_parram = (
		
		pos						=		parent.pt_ctr.pos
		R							=		rayon_1 
		rayon_1 				= 		sqrt (dot2 ( pt_1.pos - pos ) (	pt_1.pos - pos ) )
		rayon_2 				= 		sqrt (dot2 ( pt_2.pos - pos ) (	pt_2.pos - pos ) )
-- 		if rayon_1<
-- 		ratio_rayon			= 			rayon_2  / rayon_1
	)	,
	fn draw  _bmp	 = (	
	
		if b_survol 
			then _color	= col_survol
			else _color	 	= col_repos
			parent.painter.ovale		pos	pt_1.pos	  rayon_2 	  _color		_bmp
		
	)		

	, fn init = (
		refresh_pt1 ()
		refresh_pt2 ()
-- 		pt_1.pos_back = pt_1.pos
-- 		pt_2.pos_back = pt_2.pos
		format "pt_1.pos : %		pt_1.pos_back:%\n" pt_1.pos pt_1.pos_back
	)

)



struct radial (
	pos 					= 	[0,0]								,
	nom 					= 	"" 									,
	col_repos 			=		col_bleu1					,
	col_survol			=		col_surbrillance			,
	b_survol 			= 	false								,	
	b_nom 				= 	false								,	
	painter														,
	elypse_A	 		= 	PAD_elypse			nom:"A"			ratio_pos:1			parent:this		,
	elypse_B	 		= 	PAD_elypse			nom:"B"			ratio_pos:0			parent:this		,
	pt_ctr	 			= 	pad_point			nom:"C"			b_nom:true			parent:this		,
	pt_axe	 			= 	pad_point			nom:"Axe"		b_nom:true			parent:this		,
	type = #radial,
	elements 			=	#(		elypse_A	, 	elypse_B	)			,
	elemsInteractifs 		= 	#(		pt_ctr  ,  elypse_A.pt_1	, elypse_A.pt_2, elypse_B.pt_1, elypse_B.pt_2 ) 			,
	
	
		
	
	
	fn init 	pos_ctr		pos_A1		rad_A2		rad_B1		rad_B2		= (
		
		rad_A1 						= 	( 	dist 		pos_ctr		pos_A1 )
		
		pt_ctr.pos 						= pos_ctr
		pt_ctr.pos_back 				= pt_ctr.pos 
		pt_axe.pos 					= pos_A1
		--for elem in elemsInteractifs do elem.painter = painter
		elypse_A.rayon_1		=	rad_A1
		elypse_A.rayon_2		=	rad_A2
		elypse_B.rayon_1		=	rad_B1
		elypse_B.rayon_2		=	rad_B2

		elypse_A.refresh_pt2()
		elypse_A.refresh_pt1()
		
		elypse_A.maj_parram()
		elypse_A.refresh_pt2()
		
		elypse_B.refresh_pt2()
		elypse_B.refresh_pt1()
		
		elypse_B.maj_parram()
-- 		
		--elypse_B.rayon_2  = 75
		for elemGraphique in elements do elemGraphique.init()
	),
	
	
	fn draw 	_bmp		= (
		-- GUIDES ------------
		if painter.b_guides	do (
			painter.droite							(	painter.repere_pad_bmp	pt_ctr.pos	 )		(	painter.repere_pad_bmp	pt_axe.pos	)		col_gris4		_bmp
			painter.droite_perp					pt_ctr.pos													pt_axe.pos													col_gris4		_bmp
			painter.droite							(	painter.repere_pad_bmp	pt_axe.pos	 )		(	painter.repere_pad_bmp	pt_ctr.pos				)		col_gris4		_bmp
			painter.droite_perp					pt_axe.pos	 												pt_ctr.pos																col_gris4		_bmp
		)
		
		-- ELYPSES ------------
		for elemGraphique in elements do elemGraphique.draw	_bmp
		painter.segment	 			elypse_A.pt_1.pos	 	elypse_B.pt_1.pos		col_bleu1		_bmp
		painter.segment	 			elypse_A.pt_2.pos	 	elypse_B.pt_2.pos		col_bleu1		_bmp
		
		elypse_A.pt_1.draw 		_bmp
		elypse_A.pt_2.draw 		_bmp
		
		elypse_B.pt_1.draw 		_bmp
		elypse_B.pt_2.draw 		_bmp
		
		pt_ctr.draw 						_bmp
-- 		pt_axe.draw 						_bmp
	)

)

struct linear (
	pos 				= 	[0.0,0.0]								,
	nom 				= 	"" 									,
	col_repos 		=		col_bleu1					,
	col_survol		=		col_surbrillance			,
	b_survol 		= 	false								,	
	b_nom 			= 	false								,	
	painter	,
	pt_axe = pad_point	nom:("A")	parent:this	radial:radial	rayon:1 		b_nom:true,
	pt_ctr = pad_point	nom:("B")	parent:this	radial:radial	rayon:2 		b_nom:true,
	elements = # ()		,
	elemsInteractifs 		= 	#(pt_axe , pt_ctr)		,
	type=#linear,
	fn init 	pos_A	pos_B		= (
		pt_axe.pos 					= pos_A
		pt_ctr.pos 					= pos_B
		--for elem in elemsInteractifs do elem.painter = painter
		
	),
	
	
	fn draw 	_bmp		= (
		-- GUIDES ------------
		if painter.b_guides	do (
			painter.droite							(	painter.repere_pad_bmp	pt_axe.pos	 )		(	painter.repere_pad_bmp	pt_ctr.pos	)						col_gris4		_bmp
			painter.droite_perp					pt_axe.pos															pt_ctr.pos															col_bleu1		_bmp
-- 			painter.droite							(	painter.repere_pad_bmp	pt_axe.pos	 )		(	painter.repere_pad_bmp	pt_ctr.pos				)		col_gris4		_bmp
			painter.droite_perp					pt_ctr.pos	 														pt_axe.pos															col_bleu1		_bmp
		)
		
		-- ICONE ------------
		for elemGraphique in elemsInteractifs do elemGraphique.draw	_bmp
		painter.segment					pt_axe.pos															pt_ctr.pos															col_bleu1		_bmp
	)
)

struct str_painter (
	
	parent							,
	
-- 	contro,
	
	
	marge 			= 	[100 , 100]		,
	image_map 	= 	[256 , 256]		,
	pad_taille 		= 	[100,100]		,
	canvas_taille 	= 	2*marge + 	image_map ,
	canvas_pos 	= 	[0,0] 	,
	
	isDraging 		= 	false 		,
	isDrawing 		= 	false 		,
	snapgrid			=	8			,
	b_points 		= true		,
	b_guides 		= true		,
	b_infos 			= true		,
	b_snap			= 	false		,
	
-- 	type_courrant 				= #radial	,
	-- 		rayon_A1 ,	rayon_A2,	rayon_B1	,	rayon_B2	,Rapport_rayon_A , Rapport_rayon_B , RapportDesElipses	,		
	
	saved_bmp		 			= bitmap 	image_map.x 		image_map.y			color:color_fond	filename:(getdir #temp + "/painter_BMP_tmp.jpg")	,
	canvas_bmp			 	= bitmap 	canvas_taille.x 	canvas_taille.y		color:color_fond	,
	canvas_bmp_fond	 	= bitmap 	canvas_taille.x 	canvas_taille.y		color:color_fond	,

	-- 	pt_ctr	 	,
	-- 	pt_axe	 	,
	-- 	elypse_A		,
	-- 	elypse_B		,
	
	elemsGraphiques 	=	#(	)	,
	elemsInteractifs 		= 	#(	) 	,  

--------- 	FONCTIONS	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	fn repere_pad_bmp 		_pos		= (
		--format "repere_pad_bmp() : \n"
		case classof _pos of (
			Point2:	_pos = [1.0,1.0]	*	_pos * image_map / [100.0,100.0] + marge
			--float:	_pos = 1.0	*	_pos * image_map.x / 100 --+ marge.x
		)
		
		--format "	-> pos : %\n" _pos
		_pos
	),
	fn repere_bmp_pad 		_pos		= (
		case classof _pos of (
			Point2:	_pos =  [1.0,1.0]	*	( _pos - marge )  * [100.0,100.0] / image_map 
			float:	_pos = 1.0	*	( _pos - marge.x ) * 100 / image_map.x   --+ marge.x
		)
		_pos
	),
	
	
	fn type_radial 				pos_ctr	pos_A1		rad_A2		rad_B1 		rad_B2	= (
		
		type_courrant 		=	#radial
		radial_1 = radial 	painter:this
		
		radial_1.init		pos_ctr		pos_A1		rad_A2		rad_B1 		rad_B2	
		
		elemsGraphiques 		= 	#(		radial_1	)
		elemsInteractifs +=		radial_1.elemsInteractifs
	),
	fn type_linear 				pos_ptA		pos_ptB	= (
		
		type_courrant 				=#linear
		-----création des elements de base de l'elemGraphique	-----------
		linear_1 = linear 	painter:this
		
		linear_1.init		pos_ptA		pos_ptB
		
		elemsGraphiques 		= 	#(		linear_1	)
		elemsInteractifs +=		linear_1.elemsInteractifs
	),
	fn init 						= (
		--type_radial 		[image_map.x/3,image_map.y/3]	[image_map.x/2,image_map.y/2]		100			50			50
	),
	
	
	fn Matrice2Rotation2LEllipse  	_pt_ctr	 _pt_axe	=(
		
		
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
		
	)

,
	----- 	DESSIN	---------------
	

	fn write 				_pos 	txt	size 	_col	 _bmp	decalage_txt = (
		
		--_pos += [2,2]		
-- 		pos += marge
		
		l 	= 	txt.count * 2
		h	=	10
		
-- 		pos_max_x = canvas_taille.x - l
-- 		pos_max_y = canvas_taille.y - h
-- 		if _pos.x		> pos_max_x		do _pos.x = pos_max_x
-- 		if _pos.y	> pos_max_y		do _pos.y = pos_max_y
			
		_pos = repere_pad_bmp 	( _pos )
		for index = 1 to txt.count do (
			carac = txt[index]
			case size of (
				#big:		charac_def = police_big 		carac
				#small:	charac_def = police_small 	carac
			)
			-- traitement du charactere
			for index_ligne = 1 to charac_def.count do (
				charac_ligne = charac_def[	index_ligne]
				for index_colonne = 1 to  charac_ligne.count do (
					val = charac_ligne [ index_colonne ]
					pos_rep = _pos +decalage_txt+ [ index_colonne, index_ligne]
					if val >0 do 	setPixels _bmp 	pos_rep  	#(_col)
				)
			)
			_pos +=  [ 		(charac_def[1].count ) +1, 0]
		)
		
	),
	fn droite				pt_1 	pt_2  _color	_bmp			= (
		
-- 		pt_1 = 	repere_pad_bmp	pt_1
-- 		pt_2 =	repere_pad_bmp	pt_2
		
		D = pt_1 - pt_2
		if abs D.x > abs D.y
			then (
				if D.x < 0 
					then for x = 0 to _bmp.width do (
						y =  pt_1.y + D.y/D.x * (x - pt_1.x)
						setPixels _bmp 	[x, y] 	#(_color)
					) else  for x = 0 to _bmp.width do (
						y =  pt_2.y + D.y/D.x * (x - pt_2.x)
						setPixels _bmp 	[x, y] 	#(_color)
				)
			) else (
				if D.y < 0 
					then for y = 0 to _bmp.height do (
						x =  pt_1.x + D.x/D.y * (y - pt_1.y)
						setPixels _bmp 	[x, y] 	#(_color)
					) else for y = 0 to _bmp.height  do (
						x =  pt_2.x + D.x/D.y * (y - pt_2.y)
						setPixels _bmp 	[x, y] 	#(_color)
					)
		)
		--PAD_painter_roll.log_rayon = sqrt ( d.x^2 +  d.y^2)
	),
	fn droite_perp		pt_1 	pt_2  _color	_bmp			= (	--	droite perpendiculaire à la droite "pt_1 - pt_2"  passant par pt_1
		pt_1 = 	repere_pad_bmp	pt_1
		pt_2 =	repere_pad_bmp	pt_2
		D = pt_1 - pt_2
		if abs D.x < abs D.y
			then (
			--	format" A	>	\n"
				if D.x < 0 then (
-- 						format" 	A	1	>	\n"
					for x = 0 to _bmp.width do (
						
						y =  pt_1.y - D.x/D.y * (x - pt_1.x)
						setPixels _bmp 	[x, y] 	#(_color)
					)
				) else (
-- 						format" 	A	2	>	\n"
					for x = 0 to _bmp.width do (
						
						y =  pt_1.y - D.x/D.y * (x - pt_1.x)
						setPixels _bmp 	[x, y] 	#(_color)
					)
				)
			) else (
			--	format" B	>	\n"
				if D.y < 0 then (
-- 						format" 	B	1	>	\n"
					 for y = 0 to _bmp.height do (
						
						x =  pt_1.x - D.y/D.x * (y - pt_1.y)
						setPixels _bmp 	[x, y] 	#(_color)
					 )
				) else (
-- 						format" 	B	2	>	\n"
					 for y = 0 to _bmp.height  do (
						
						x =  pt_1.x - D.y/D.x * (y - pt_1.y)
						setPixels _bmp 	[x, y] 	#(_color)
					)
				)
		)
		--PAD_painter_roll.log_rayon = sqrt ( d.x^2 +  d.y^2)
	),
	fn demi_droite		pt_1 	pt_2  _color	_bmp			= (
		pt_1 = 	repere_pad_bmp	pt_1
		pt_2 =	repere_pad_bmp	pt_2
		D = pt_1 - pt_2
		if abs D.x > abs D.y
			then (
				if D.x < 0 
					then for x = pt_1.x to canvas_taille.x do (
						y =  pt_1.y + D.y/D.x * (x - pt_1.x)
						setPixels _bmp 	[x, y] 	#(_color)
					) else  for x = 0 to pt_1.x do (
						y =  pt_2.y + D.y/D.x * (x - pt_2.x)
						setPixels _bmp 	[x, y] 	#(_color)
				)
			) else (
				if D.y < 0 
					then for y = pt_1.y to canvas_taille.y do (
						x =  pt_1.x + D.x/D.y * (y - pt_1.y)
						setPixels _bmp 	[x, y] 	#(_color)
					) else for y = 0 to pt_1.y do (
						x =  pt_2.x + D.x/D.y * (y - pt_2.y)
						setPixels _bmp 	[x, y] 	#(_color)
					)
		)
		--PAD_painter_roll.log_rayon = sqrt ( d.x^2 +  d.y^2)
	),
	fn segment 		pt_1 	pt_2  _color	_bmp			= (
		pt_1 = 	repere_pad_bmp	pt_1
		pt_2 =	repere_pad_bmp	pt_2
		D = pt_1 - pt_2
		
		if abs D.x > abs D.y
			then (
				if D.x < 0 
					then for x = pt_1.x to pt_2.x do (
						y =  pt_1.y + D.y/D.x * (x - pt_1.x)
						setPixels _bmp 	[x, y] 	#(_color)
					) else  for x = pt_2.x to pt_1.x do (
						y =  pt_2.y + D.y/D.x * (x - pt_2.x)
						setPixels _bmp 	[x, y] 	#(_color)
				)
			) else (
				if D.y < 0 
					then for y = pt_1.y to pt_2.y do (
						x =  pt_1.x + D.x/D.y * (y - pt_1.y)
						setPixels _bmp 	[x, y] 	#(_color)
					) else for y = pt_2.y to pt_1.y do (
						x =  pt_2.x + D.x/D.y * (y - pt_2.y)
						setPixels _bmp 	[x, y] 	#(_color)
					)
		)
		--PAD_painter_roll.log_rayon = sqrt ( d.x^2 +  d.y^2)
	),
	fn cercle  			ctre		R 	  _color	_bmp			= (
		
		ctre = 	repere_pad_bmp	ctre
		
		
		for	x=  (ctre.x - R*(cos 45) ) to  (ctre.x + R*(cos 45) )  do (
			y  =	sqrt (R^2 - (x-ctre.x)^2)	+ctre.y
						setPixels _bmp 	[x, y] 	#(_color)
			y  =	- sqrt (R^2 - (x-ctre.x)^2)	+ctre.y
						setPixels _bmp 	[x, y] 	#(_color)
		)
		for	y=  (ctre.y - R*(cos 45) ) to  (ctre.y + R*(cos 45) )  do (
			x  =	sqrt (R^2 - (y-ctre.y)^2)	+ctre.x
						setPixels _bmp 	[x, y] 	#(_color)
			x  =	- sqrt (R^2 - (y-ctre.y)^2)	+ctre.x
						setPixels _bmp 	[x, y] 	#(_color)
		)
	),
	fn ovale 			CTR 	ptAxe	 	rayon_A2 	  	_color	_bmp		= (
		
		rayon_A1 			= 	dist 	CTR 	ptAxe
		--CTR 					= 	repere_pad_bmp	CTR
		--ptAxe 				= 	repere_pad_bmp	ptAxe
-- 		r_A1 					= 	repere_pad_bmp	rayon_A1
-- 		r_A2 					= 	repere_pad_bmp	rayon_A2	
		r_A1 = rayon_A1
		r_A2 = rayon_A2
		nbr_sgt 				= 	64
		increment_angle 	= 	360.0 / nbr_sgt
		points_ovale 		= 	#()		
		
		bmC			=	bigmatrix 2 1
		for i=1 to 2 do bmC[i][1] = CTR[i]
		bmAxe=bigmatrix 2 1
		for i = 1 to 2 do bmAxe[i][1]= ptAxe[i]-	bmC[i][1]
	
		bmRotationEllipse		=	Matrice2Rotation2LEllipse 	CTR	ptAxe
		bmResultat=bigmatrix 2 1
		bm=bigmatrix 2 1
		
		-- 		r_A1 = ( repere_bmp_pad		[rayon_A1,0]	)[1]
		-- 		r_A2 = ( repere_bmp_pad		[rayon_A2,0]	)[1] 
		
		for	s=0 to nbr_sgt do (
			bm[1][1] 		=  		r_A1		* 	cos (	s * increment_angle)		--	marge.x
			bm[2][1]		= 			r_A2  	* 	sin  (	s * increment_angle )		--	marge.x
			
-- 			tmp=repere_pad_bmp 	[ r_A1		* 	cos (	s * increment_angle)	)	, 	r_A2  	* 	sin  (	s * increment_angle )	]
-- 			bm[1][1] 		=tmp[1]
-- 			bm[2][1]		= tmp[2]
			bmResultat		= 	bmC		+	bigmatrixMult 		bmRotationEllipse 	bm
			Result			=	[bmResultat[1][1] ,bmResultat[2][1] ]	
-- 			Result			=	repere_bmp_pad	Result	
-- 			
-- 			
			
			
			append 			points_ovale 		Result
		)
		nbr_sgt = points_ovale.count 
		for index = 1 to nbr_sgt	
			 do if index == nbr_sgt 	
				then  		segment 		points_ovale[index] 			points_ovale[1] 			 	_color	_bmp
				else 			segment 		points_ovale[index] 			points_ovale[index+1]  	_color	_bmp
	),
	fn rect_plein  		pt_1 	pt_2	 _color	_bmp			= (
		pt1 = 	repere_bmp_pad	pt1
		pt2 =	repere_bmp_pad	pt2
-- 		format "%		%\n" pt_1 	pt_2	
		taille = pt_2 - pt_1
		bmp_rect = bitmap (abs taille.x ) (abs taille.y ) color:_color
		pos = [	amin 	#(pt_2.x ,	pt_2.x )		,	amin 	#(pt_2.y ,	pt_2.y )		]
-- 		pos_rep = repere_pad_bmp 	pos
		pasteBitmap bmp_rect	_bmp 	[1,1]		[0,0]	 
	--	display bmp_rect
	),
	fn rect  				pt1 	pt2	 _color	_bmp			= (
		pt1 = 	repere_bmp_pad	pt1
		pt2 =	repere_bmp_pad	pt2
		coin_Ht_G = [	amin 	#(pt1.x ,	pt2.x )		,	amin 	#(pt1.y ,	pt2.y )		]		--	coin 1	:	Ht_G
		coin_Bs_G = [	amin 	#(pt1.x ,	pt2.x )		,	amax #(pt1.y , 	pt2.y )		]		--	coin 2	:	Bs_G
		coin_Ht_D = [	amax #(pt1.x , 	pt2.x )		,	amin 	#(pt1.y ,	pt2.y )		]		--	coin 3	:	Ht_D
		coin_Bs_D = [	amax #(pt1.x , 	pt2.x )		,	amax #(pt1.y ,	pt2.y )		]		--	coin 4	:	Bs_D
		segment 	coin_Ht_G 	coin_Bs_G  _color	_bmp	
		segment 	coin_Ht_G 	coin_Ht_D  _color	_bmp	
		segment 	coin_Bs_D	coin_Bs_G  _color	_bmp	
		segment 	coin_Bs_D 	coin_Ht_D  _color	_bmp	
	),
	fn grille  			pas_x 	pas_y	 _color	_bmp	= (
-- 		pt_1 = 	repere_pad_bmp	pt_1
-- 		pt_2 =	repere_pad_bmp	pt_2
		
		taille			= [	_bmp.width	,	_bmp.height ]	
		ecart_x 		= (taille.x / pas_x)
		ecart_y 		= (taille.y / pas_y)
		
		for ind_X = 1 to pas_x 
			do 	droite 	( [  ind_X *  ecart_x	, 	0 ]  )	([ ind_X * ecart_x	, 	canvas_taille.y ] ) 		_color		_bmp	

		for ind_Y = 1 to pas_y 
			do	droite 	([ 0 ,  ind_Y * ecart_y ]  )		( [canvas_taille.x  	, 	ind_Y * ecart_y ] ) 			_color		_bmp	
-- 		display _bmp
	),
	fn pt					pos	_color	_bmp					= (
			pos = repere_pad_bmp 	pos
			--- rond ----
			_color_33 		=	_color_66	= _color
			_color_33.a 	= 255	/3
			_color_66.a 	= 255	*2/3
	-- 			ovale  pos		4 	 4	 _color_33	_bmp
	-- 			ovale  pos		3 	 3	 _color	_bmp
	-- 			ovale  pos		2 	 2	 _color	_bmp
	-- 			ovale  pos		1 	 1	 _color	_bmp
	-- 			
			--	rang 0	---
			setPixels _bmp (pos - [0,0]) #( _color	)	
			
			--	rang 1	---
			setPixels _bmp (pos - [-1,0]) #( _color	)	
			setPixels _bmp (pos - [1,0]) 	#( _color	)	
			setPixels _bmp (pos - [0,-1]) #( _color	)	
			setPixels _bmp (pos - [0,1]) 	#( _color	)	
		
			setPixels _bmp (pos - [-1,-1]) #( _color	)	
			setPixels _bmp (pos - [1,1]) 	#( _color	)	
			setPixels _bmp (pos - [1,-1]) #( _color	)	
			setPixels _bmp (pos - [-1,1]) #( _color	)		
			
			--	rang 2	---
			setPixels _bmp (pos - [-2,0]) #( _color	)	
			setPixels _bmp (pos - [2,0]) 	#( _color	)	
			setPixels _bmp (pos - [0,-2]) #( _color	)	
			setPixels _bmp (pos - [0,2]) 	#( _color	)	

			setPixels _bmp (pos - [-1,2]) #( _color	)	
			setPixels _bmp (pos - [1,2]) 	#( _color	)	
			setPixels _bmp (pos - [2,-1]) #( _color	)	
			setPixels _bmp (pos - [2,1]) #( _color	)		
			
			setPixels _bmp (pos - [-1,-2]) #( _color	)	
			setPixels _bmp (pos - [1,-2]) 	#( _color	)	
			setPixels _bmp (pos - [-2,-1]) #( _color	)	
			setPixels _bmp (pos - [-2,1]) #( _color	)	


			--	rang 3
			setPixels _bmp (pos - [-1,3]) 	#( _color	)	
			setPixels _bmp (pos - [0,3]) 		#( _color	)	
			setPixels _bmp (pos - [1,3]) 		#( _color	)	
			
			setPixels _bmp (pos - [-1,-3]) 	#( _color	)	
			setPixels _bmp (pos - [0,-3]) 	#( _color	)	
			setPixels _bmp (pos - [1,-3]) 	#( _color	)	
			
			setPixels _bmp (pos - [3,-1]) 	#( _color	)	
			setPixels _bmp (pos - [3,0]) 		#( _color	)	
			setPixels _bmp (pos - [3,1]) 		#( _color	)	
			
			setPixels _bmp (pos - [-3,-1]) 	#( _color	)	
			setPixels _bmp (pos - [-3,0]) 	#( _color	)	
			setPixels _bmp (pos - [-3,1]) 	#( _color	)	
			
			setPixels _bmp (pos - [-2,-2]) 	#( _color	)	
			setPixels _bmp (pos - [-2,2]) 	#( _color	)	
			setPixels _bmp (pos - [2,-2]) 	#( _color	)		
			setPixels _bmp (pos - [2,2]) 		#( _color	)	
			
			
			/*--- CROIX	-----
	--		cercle  pos		4 	  _color	_bmp
	-- 			-- 	croix	-----
			setPixels _bmp (pos - [0,0]) #(_color	)	
	-- 			
	-- 			
			setPixels _bmp (pos - [1,0]) #(_color	)	
			setPixels _bmp (pos - [2,0]) #(_color	)
			setPixels _bmp (pos - [3,0]) #(_color	)			
	-- 			--	setPixels _bmp (pos - [4,0]) #(_color	)
	-- 			--	setPixels _bmp (pos - [5,0]) #(_color	)
	-- 			--	setPixels _bmp (pos - [6,0]) #(_color	)

			setPixels _bmp (pos - [-1,0]) #(_color	)	
			setPixels _bmp (pos - [-2,0]) #(_color	)	
			setPixels _bmp (pos - [-3,0]) #(_color	)	
	-- 			--	setPixels _bmp (pos - [-4,0]) #(_color	)
	-- 			--	setPixels _bmp (pos - [-5,0]) #(_color	)
	-- 			--	setPixels _bmp (pos - [-6,0]) #(_color	)

			setPixels _bmp (pos - [0,1]) #(_color	)
			setPixels _bmp (pos - [0,2]) #(_color	)
			setPixels _bmp (pos - [0,3]) #(_color	)	
	-- 			--	setPixels _bmp (pos - [0,4]) #(_color	)
	-- 			--	setPixels _bmp (pos - [0,5]) #(_color	)
	-- 			--	setPixels _bmp (pos - [0,6]) #(_color	)

			setPixels _bmp (pos - [0,-1]) #(_color	)
			setPixels _bmp (pos - [0,-2]) #(_color	)
			setPixels _bmp (pos - [0,-3]) #(_color	)
	-- 			--	setPixels _bmp (pos - [0,-4]) #(_color	)
	-- 			--	setPixels _bmp (pos - [0,-5]) #(_color	)
	-- 			--	setPixels canvas_bmp (pos - [0,-6]) #(_color	)

		--	if b_survol 	then 
		*/
	),
	fn fond_creation 												= (
		free canvas_bmp_fond
		canvas_bmp_fond		= bitmap 	canvas_taille.x 	canvas_taille.y	color:color_fond
		bmp_zone					= bitmap 	image_map.x 		image_map.y		color:color_fond
		pastebitmap 				saved_bmp		canvas_bmp_fond	[0,0]	[0,0]
		
		rect_plein  	[1,1] 										image_map	 											col_gris5				bmp_zone
		grille 			snapgrid										snapgrid													col_gris4				bmp_zone
		droite		([	1	,	(	(image_map.y/2)	)	]  )			([	image_map.x	,	((	image_map.y/2)	) 	]  )		col_gris3				bmp_zone
		droite		([	((	image_map.x / 2)	 ) ,	1	]  )			([((image_map.x/2)	) ,	image_map.y			]  )		col_gris3				bmp_zone
		rect 			([1,1]  )	 									(	image_map-[1,1] )		 						col_gris3				bmp_zone	
		
				
		pastebitmap bmp_zone		canvas_bmp_fond	[0,0]	[marge.x , marge.y]
	),

	
	
	
	
	
	
	
	----- ACTUALISATIONS	---------------	

	fn refresh_viewport = (
		save saved_bmp
-- 		try ( 	(get_creen contro).material.diffusemap.composite.mapList[1].bitmap = canvas_bmp		)	catch ()
	),
	fn actualise_parametres = (
		for elemGraphique in elemsGraphiques do (
			for elem in elemGraphique.elements do (
				elem.maj_parram ()
				elem.refresh_pt2()
			)
		)
	),
	fn	canvas_refresh = (
		-- 	format "pad>	canvas_refresh()\n"
		-- 	RESET FOND DE BASE		-----
		copy canvas_bmp_fond  	canvas_bmp 
		--copy canvas_bmp_fond		saved_bmp
		
		for elemGraphique in elemsGraphiques do elemGraphique.draw		canvas_bmp
		
		bmp_Affiche = bitmap canvas_taille.x canvas_taille.y color:color_fond
		pastebitmap  canvas_bmp 	bmp_Affiche	[0,0]		[0,0]--canvas_pos
		
		-- affichage de la bitmap	dans l'elemGraphique	---
-- 		format "refresh : parent : %\n" parent
		parent.ui_painter.bitmap = bmp_Affiche
	),
	
	
	fn test_selec	 _pos = (
		_pos = repere_bmp_pad		_pos
		local ui_select
		--format "painter.elemsInteractifs : %\n"	painter.elemsInteractifs
		for elemGraphique in elemsInteractifs do(
			D =   _pos - elemGraphique.pos 					--+	painter.marge
			D =   sqrt ( D.x^2 + D.y^2)
			if D <elemGraphique.distance_survol 	do (ui_select = elemGraphique )
		)
		ui_select
	)
	,
	
	fn deplace_elem 	pt  pos	= (
		
	--	pos_back 		= UI_selec.pos 
-- 		pt.pos_back = pt.pos
		pt.pos 	=  pos 
		
		pt.bouge  	pos

		--init_ui()
		canvas_refresh ()
	)	,
	
	fn donne_couleur xx yy	=(
		
		CTR 		= elemsGraphiques[1].pt_ctr.pos
		
		bmctr=bigmatrix 2 1
		for i = 1 to 2 do bmctr[i][1]=CTR[i]	
		
		bmC=bigmatrix 2 1
		for i = 1 to 2 do bmC[i][1]=bmctr[i][1]	
		
		bmAxe=bigmatrix 2 1
		for i = 1 to 2 do bmAxe[i][1]= elemsGraphiques[1].pt_axe.pos[i]	-	bmC[i][1]		
		
		bmRotationEllipse		=	Matrice2Rotation2LEllipse  	elemsGraphiques[1].pt_ctr.pos  	elemsGraphiques[1].pt_axe.pos 
		bmResultat=bigmatrix 2 1
		bm=bigmatrix 2 1
		
		
		RExt1=elemsGraphiques[1].elypse_A.rayon_1*1.0
		RExt2=elemsGraphiques[1].elypse_A.rayon_2*1.0
		RInt1=elemsGraphiques[1].elypse_B.rayon_1*1.0
		Rint2=elemsGraphiques[1].elypse_B.rayon_2*1.0
		
		bmA1=elemsGraphiques[1].elypse_A.pt_1.pos*1.0
		bmA2=elemsGraphiques[1].elypse_A.pt_2.pos*1.0
		bmB1=elemsGraphiques[1].elypse_B.pt_1.pos*1.0
		bmB2=elemsGraphiques[1].elypse_B.pt_2.pos*1.0
		bmC= elemsGraphiques[1].pt_ctr.pos*1.0
		
		
		
		bmI=(bmA1-bmC)/(dist bmA1 bmC )
		
		bmJ=- (bmA2-bmC)/(dist bmA2 bmC )
		bmCA1	=	bmA1-bmC
		






		bmM		=  [ 100.0*xx/image_map[1] , 100.0*yy/image_map[2]]
		bmMA1	=	bmA1-bmM
		bmCM	=	bmM-bmC
			
		if bmCM==[0,0] then 
			( coul = 255.0 )
		else (--if bmCM==[0,0] 
			_angle=atan (1.0*(dot2 bmCM bmJ)/( dot2 bmCM bmI ))
			if  (dot2 bmCM bmI)<0 do _angle=180.0+_angle
			
			distCM  	= 	( dist bmC bmM ) 
			
			sInt=atan(Rint1/Rint2 * tan _angle)
			bmEint	=	Rint1*cos(sInt)*bmI+Rint2*sin(sInt)*bmJ +bmC
			sExt=atan(Rext1/Rext2 * tan _angle)	
			bmEext	=	Rext1*cos(sExt)*bmI+Rext2*sin(sExt)*bmJ + bmC

			distInt	=	dist bmEint bmC
			distExt 	= 	dist bmEext bmC

			if distCM < distInt then -- et distCM!=0 
				( coul=255.0)
			else if distCM < distExt then 
				( --coul=255.0*(1.0 - 1.0*(distCM-distInt)/(distExt-distInt) ) 
					coul=255.0*(1.0 - 1.0*((distCM-distInt)/(distExt-distInt) )  )
					) 	
			if distCM>=distExt then coul=0.0

		)
		color coul coul coul		
		

	
	),
	
	

	fn creer_bitmap = (
		--_bmp = bitmap image_map.x	 image_map.y	 color:black
/* 		
			RExt1=elemsGraphiques[1].elypse_A.rayon_1
			RExt2=elemsGraphiques[1].elypse_A.rayon_2
			RInt1=elemsGraphiques[1].elypse_B.rayon_1
			Rint2=elemsGraphiques[1].elypse_B.rayon_2
			format " RExt1  RExt2 RInt1 Rint2  % % % %\n" RExt1  RExt2 RInt1 Rint2
			format "% \n" elemsGraphiques[1].pt_ctr.pos
			
			bmA1=elemsGraphiques[1].elypse_A.pt_1.pos
			bmA2=elemsGraphiques[1].elypse_A.pt_2.pos
			bmB1=elemsGraphiques[1].elypse_B.pt_1.pos
			bmB2=elemsGraphiques[1].elypse_B.pt_2.pos
			format " bmA1 bmA2 bmB1 bmB2 % % % %\n" image_map[2] bmA2 bmB1 bmB2
			bmC= elemsGraphiques[1].pt_ctr.pos
			bmI=(bmA1-bmC)/(dist bmA1 bmC )
			bmJ=- (bmA2-bmC)/(dist bmA2 bmC )
			format " bmC bmI bmJ % % %\n" bmC bmI bmJ 
			
			bmM=elemsGraphiques[1].elypse_B.pt_2.pos--HISTOIRE DE 
			
			for yy=1 to int(image_map[2]-1) do (
			
				rangee=#()
				local coul
					for xx=1 to int(image_map[1]-1) do (
						 
						append rangee (donne_couleur xx yy)
	-- 						col_tmp =  color 255 255 255
	-- 						append rangee col_tmp
						
								
					)	
-- 					rangee=#()
-- 					coul=128
-- 					for xx=1 to int(image_map[1]-1) do (		append rangee ( color xx xx xx) )
-- 					
				_pos= [ 1  ,  yy ]-- marge	
				--if coul >254 do (format "%  % % % % : %\n "   yy dist distInt distExt coul rangee)
-- 				format "% " yy
				setPixels 	saved_bmp	 _pos  rangee		
				if yy==1 do (format "rangee   % \n "    rangee)
			)	
			
			
			
		display saved_bmp
			 */
		--enregistrer bitmap
		fond_creation ()
		refresh_viewport()
		
		
		
	),
	
	
	on create do (
		
		actualise_parametres ()
		
		--refresh_pt2()
		

		fond_creation()
	)
	
)	--	fin struct	---------------------------------------------------------------------------------------------





	
	
rollout PAD_painter_roll "PAD Painter" width:296 height:296
(
	

	local 	painter
	local 	isDrawing
	local 	UI_selec
	local 	distance_click = 2
	local 	drag_initial 			,	canvas_pos_initial
	local 	b_survol
	local    	pt_select
	
	
	bitmap ui_painter  "" pos:[20,20] width:256 height:256
	
	
	
	
	---
/* 
	fn init_ui = (
		local b_type_radial , b_type_lineair
		format "PAINTER>	init_ui()\n"
		case ddl_type.selection of (
			1: (
				--painter.type_radial()
				b_type_radial 	= true
				b_type_lineair 	= false
				
-- 				spn_A1.value		=	painter.elemsGraphiques[1].elypse_A.rayon_1
-- 				spn_A2.value		=	painter.elemsGraphiques[1].elypse_A.rayon_2
-- 				spn_B1.value		=	painter.elemsGraphiques[1].elypse_B.rayon_1
-- 				spn_B2.value		=	painter.elemsGraphiques[1].elypse_B.rayon_2
		
			)
			2:(
				b_type_radial 		= false
				b_type_lineair 	= true
-- 				painter.type_linear ()
			)
		)
-- 		format "pt_select : %\n" pt_select
 		if pt_select != undefined do (
			
		)
--
		
		
	)	-- fin init_ui	------------
	fn Retaille_ui = (
		
		ui_painter.width 			= painter.canvas_taille.x
		ui_painter.height 		= painter.canvas_taille.y
 		
		PAD_painter_roll.width 		= ui_painter.pos.x + ui_painter.width 			+  15 + grp_canvas.width + 5
		PAD_painter_roll.height 		= amax 	#( (ui_painter.height+70) 	,  0)
		
	)	--	fin Retaille_ui --------------
	
	 */
	
	
	
	
	fn pt_dans_ui  pos elemGraphique = (
		--pos = painter.repere_bmp_pad 	pos
		if pos.x >  elemGraphique.pos.x 		and 	pos.x <  elemGraphique.pos.x + elemGraphique.width 
			then if pos.y > elemGraphique.pos.y	and 	pos.y < elemGraphique.pos.y + elemGraphique.height 
				then 	true 
				else 		false 
		else 	false 
	)
	fn test_UI_selectionnable _pos = (
		_pos = painter.repere_bmp_pad		_pos
		local ui_select
		--format "painter.elemsInteractifs : %\n"	painter.elemsInteractifs
		for elemGraphique in painter.elemsInteractifs do(
			D =   _pos - elemGraphique.pos --+	painter.marge
			D =   sqrt ( D.x^2 + D.y^2)
			if D <distance_click 	do (ui_select = elemGraphique )
		)
		ui_select
	)
	fn actualise_ui_elem pos	= (
		
	--	pos_back 		= UI_selec.pos 
		UI_selec.pos 	= pos 
		UI_selec.bouge  	pos

		--init_ui()
		painter.canvas_refresh ()
	)
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	------EVENTS	----------------------------------------------------------------------------------------------------------------------------------------------------
	
	on PAD_painter_roll open do
	(
		
		painter = str_painter 	parent:PAD_painter_roll	
		painter.canvas_refresh ()
		/* 
		--painter.init ()
		Retaille_ui()
	
		selec = selection as array
		if selec.count == 1 then (
			if classof (get_contro selec[1] ) == Pad_contro then (		--				<---	il y a un contro selectionné donc on affiche les param qu'il faut
				case painter.type_courrant of (
					#radial: painter.type_radial 		[painter.pad_taille.x/4,painter.pad_taille.y/4]		[painter.pad_taille.x/2,painter.pad_taille.y/2]		(painter.pad_taille.x/4)		(	painter.pad_taille.x/6	)		(painter.pad_taille.x/8)
					#linear: painter.type_linear		[painter.pad_taille.x/4,painter.pad_taille.y/4]		[painter.pad_taille.x/2,painter.pad_taille.y/2]	
				)
				btn_contro.object = (get_contro selec[1] )  
				painter.contro = (get_contro selec[1] )  
			) else 																				--	<---	il n'y a pas de contro selectionné donc on affiche les param default
						painter.type_radial 		[painter.pad_taille.x/4,painter.pad_taille.y/4]		[painter.pad_taille.x/2,painter.pad_taille.y/2]			(painter.pad_taille.x/4)		(	painter.pad_taille.x/6	)		(painter.pad_taille.x/8)
		)	else 		painter.type_radial 		[painter.pad_taille.x/4,painter.pad_taille.y/4]		[painter.pad_taille.x/2,painter.pad_taille.y/2]			(painter.pad_taille.x/4)		(	painter.pad_taille.x/6	)		(painter.pad_taille.x/8)
		
		isDrawing = false
		
		painter.canvas_refresh ()
		init_ui ()
		curve_init() */
	)
	
	
	/* 
	on PAD_painter_roll mbuttondown pos 	do			-------			mouse	MIDDLE DOWN		-----
	(	
		
		if pt_dans_ui 	pos 		ui_painter  	do	( 
			painter.isDraging 		= true
			drag_initial 				= pos
			canvas_pos_initial 	= painter.canvas_pos
		)
	)
	on PAD_painter_roll mbuttonup pos 		do			-------			mouse	MIDDLE UP			-----
	(	
		if pt_dans_ui 	pos 		ui_painter  
			do	painter.isDraging 	= false
		)
	on PAD_painter_roll lbuttondown pos 	do				-------			mouse	CLICK DOWN		-----
	(
			if pt_dans_ui 		pos 		ui_painter 	do (
				pos = pos - ui_painter.pos
			
				UI_selec = painter.test_selec 	pos 
	-- 				UI_selec = test_UI_selectionnable 	pos 
				
				if UI_selec != undefined then	(
					pt_select = UI_selec
					for elemGraphique in painter.elemsInteractifs 	do	elemGraphique.b_survol = false
					for elemGraphique in painter.elemsGraphiques					do	elemGraphique.b_survol = false
					pt_select.b_survol = true
					
					pos = painter.repere_bmp_pad pos
					painter.actualise_parametres ()
					painter.isDrawing 	= true
					actualise_ui_elem 	(pos	)
					
				) else (
					pt_select = undefined
					for elemGraphique in painter.elemsInteractifs 	do	elemGraphique.b_survol = false
					for elemGraphique in painter.elemsGraphiques					do	elemGraphique.b_survol = false
				)
			)
			init_ui ()
		)
	on PAD_painter_roll lbuttonup pos 		do				-------			mouse	CLICK UP				-----
	(
			pos = pos - ui_painter.pos
			pos = painter.repere_bmp_pad pos
			painter.isDrawing = false
			if PAD_painter_roll.chk_view_autoupdt.checked do 
				painter.refresh_viewport ()
		)
	on PAD_painter_roll mouseMove pos 	do				-------			mouse MOVE					-----
	(
		if painter.isDrawing  == false 	and painter.isDraging == false  	and  pt_dans_ui 	pos 		ui_painter  
			do (
			
				pos = pos - ui_painter.pos
				--pos = painter.repere_bmp_pad pos
				UI_selec = painter.test_selec 	pos 

			)
			if painter.isDrawing do (

				pos = pos - ui_painter.pos 
				--UI_selec = test_UI_selectionnable 	pos	
				pos = painter.repere_bmp_pad 	pos
				actualise_ui_elem 	(pos	)
			)
	)
	
	
	 */
)

createDialog PAD_painter_roll  style:#(#style_toolwindow, #style_sysmenu ) 	

