struct str_conv_GPStoMeter_mercator (
	private
		rayonMax = 6378137.0	as double,
		rayonMin = 6356752.3142	as double,
	
	
	private
		fn mercX	_longitude =(
			( degToRad  _longitude ) * rayonMax
		),
		fn mercY	_latitude	=(
			if _latitude > 89.5 		do	_latitude = 89.5
			if _latitude < -89.5		do	_latitude = -89.5
			
			local 	temp 	= rayonMin / rayonMax
			local 	es 		= 1.0 - (temp * temp)
			local 	eccent 	= sqrt es
			
			local 	phi 		= ( degToRad		_latitude  ) as double
			local 	sinphi 	= sin	phi
			
			local 	con 		= eccent * sinphi
			local 	com 		= .5 * eccent			
			con 		= ( (1.0-con)/(1.0+con) )	^ com
			
			local 	ts = tan (.5 * ( PI * 0.5 - phi))/con
			local 	result = 0 - rayonMax * log ts
			
			format "classof result:%\n"	(classof result)
			result
			
		),
		
		
	public
		fn gpsToMeters		_long	_lat	=(
			
			struct posGPS (
				x,
				y
			)
			posGPS x:(mercX _long)	y:(mercY	_lat)
		)
)

converterGPS = str_conv_GPStoMeter_mercator ()
-- converterGPS.mercX   1.1118993	
clearlistener()
converterGPS.gpsToMeters   49.4514973		1.1118993


