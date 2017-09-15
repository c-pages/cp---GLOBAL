
i = 0
-- popo = $
for mat in popo.material do (
	i=i+50
	format "mat : %\n" mat.name
	nbox = box lengthsegs:1 widthsegs:1 heightsegs:1 length:189.968 width:105.249 height:165.832 mapcoords:on pos:[-4119.87 + i,-3647.75,0] isSelected:on
	nbox.material = mat
)