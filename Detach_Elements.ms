
fn DetachToElements obj 	cPivot:true 	num:1 = (
-- 	local 
	
	while obj.getNumFaces() != 0 do (
		polyop.setFaceSelection obj #{1}
		obj.selectElement()
		ele = polyop.getFaceSelection obj
		newName = (obj.name + num as string)
		num += 1 -- pump up counter
		polyop.detachFaces obj ele asNode:true name:newName
		newObj = getNodeByName newName
		if cPivot do centerPivot newObj
-- 		append endObjs newObj
-- 		attachObjects obj newObj
	)
	
)


 DetachToElements $