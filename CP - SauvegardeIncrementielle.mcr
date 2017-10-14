macroScript SauvegardeIncrementielle
category:"#CPages" 
tooltip:"Save copy (+1)"
(
	local dir_tmp,	nom_tmp

	
	fn savecopy dir	=(
		
-- 	 		format "--->OK<----\n"
			dossier_copy = dir 
-- 	 		format "	dossier_copy : %\n" dossier_copy
			files_copy = getFiles ( dossier_copy	+	"\\*.max")
-- 	 		format "	files_copy : %\n" files_copy
			_file_copy_nbr = 0
			for _file_copy in files_copy do (
				
				_file_copy_name = getFilenameFile _file_copy
-- 				format "	-->_file_copy_name : %\n" _file_copy_name
				
				_a_tmp 	= filterString _file_copy_name	" - "
-- 				format "	-->_a_tmp : %\n" _a_tmp
				
				_file_copy_nbr_tmp = _a_tmp[_a_tmp.count] as integer
-- 				format "	-->_file_copy_nbr_tmp : %\n" _file_copy_nbr_tmp
				if not _file_copy_nbr_tmp == undefined do if _file_copy_nbr_tmp > _file_copy_nbr do 	_file_copy_nbr = _file_copy_nbr_tmp
			)
			_file_copy_nbr += 1
			if _file_copy_nbr<10 	then 	_file_copy_nbr = "0" + _file_copy_nbr as string
											else		_file_copy_nbr as string
			_file_copy_save = dir + nom_tmp + " - " + _file_copy_nbr as string + ".max"
			
			fn existFile fname = (getfiles fname).count != 0
			
			fn _save 	_file_copy_save	=   (
				local source = maxfilepath + maxfilename
				copyFile 	source 		_file_copy_save
				
				savemaxfile source useNewFile:false	clearNeedSaveFlag:false	quiet:true
				format "copie du fichier avant sauvegarde : %\n"		_file_copy_save
			)
			if existFile 	_file_copy_save 
			then  	if querybox "file exist !! on ecrase ?!?" 
						then  _save	_file_copy_save
						else	()
			else		_save 	_file_copy_save
			
			
			
			
-- 			maxFileName 
-- 			maxFilePath 
-- 			copyFile 
	-- 		format "		_file_copy : 		%\n" _file_copy
	-- 		format "		_file_copy_name : 	%\n" _file_copy_name
	-- 		format "		_file_copy_nbr : 	%\n" _file_copy_nbr
	-- 		format "		_file_copy_save : 	%\n" _file_copy_save
	)
	

	dir_tmp = getDirectories (maxfilepath + "*")
	nom_tmp = getFilenameFile 	maxfilename
	DIR_result = undefined
	for dir in dir_tmp do (
	-- 	format "dir : %\n"dir
		_adresse_tmp= filterString dir	"\\"
		DIR_test = _adresse_tmp[_adresse_tmp.count]
	--	format "DIR_result : %\n"	DIR_result
		if DIR_test == nom_tmp do DIR_result = nom_tmp
	)
	if DIR_result == nom_tmp 
		then savecopy 	( maxfilepath + nom_tmp+ "\\")
		else 	if querybox "Creer le dossier des copies?"
				then 	(
					DIR_result = maxfilepath + nom_tmp
					makeDir DIR_result
					savecopy (DIR_result + "\\")
				)
				else		format "action annulé\n"

)
