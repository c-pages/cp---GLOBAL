

for obj in objects do  
	try (
		obj.previzType = 2
	) catch ()
	
	
	
	--obj.points = 1000

/* for obj in (selection as array ) do 

CoronaProxy filename:"{00000000-0000-0000-0000-000000000000}" \
displayIconSize:19.5187 \
pos:obj.pos \
name:("Pxy_cor - " + obj.name) \
wirecolor:obj.wirecolor	



------------------------------------------------


$.material


for obj in (selection as array ) do  obj.points = 1000
$.TrianglesUI = 10



---------------------------

for obj in (selection as array ) do (
	color_decalle	=	random (	color 0 0 0		)	( color 10 10 10)


	random_signe = random 0 10
	if random_signe > 0 
		then obj.wirecolor += color_decalle
		else obj.wirecolor -= color_decalle


)

 */

-- deleteAllChangeHandlers()
-- deleteChangeHandler		#kris_groupes_proxies
/* 
when children  selection change		id:#kris_groupes_proxies	 _obj  do
(
	_new_node 	= _obj.children[_obj.children.count]
	format  "EVENT > #kris_groupes_proxies : %\n"	_obj
	for _index = 1 to  ( _obj.children.count - 1 )  do( 
		if 	(areNodesInstances _obj.children[_index]	 _new_node ) 		do _new_node.parent = undefined
	)
)



 */