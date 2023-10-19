#Under the MIT license
#A classe based on Godot´s documentation
#By: Jstn Jrg 

class_name Bazier extends Node2D

#Contains the non-interpolated curve points
var data := [] 

#Repairs the curve for proper interpolation, avoiding access error. 
#Ensures that there are necessary points and interpolation conditions
func _fix_bazier_curve (curve_points: Array) -> Array:
	
	if (curve_points.size()-1)%3 != 0 and curve_points.size() >= 2:
		
		while true:
			
			var m_point : Vector2 = (curve_points[-1]+curve_points[-2])*0.5
			var aux_point : Vector2 = curve_points[-1]
			
			curve_points[-1] = m_point
			curve_points.append(aux_point)
			
			if (curve_points.size()-1)%3 == 0: break
	
	return curve_points

func _bazier_curve (curve_points: Array,precision: int) -> Array:
	
	curve_points = _fix_bazier_curve(curve_points)
	data = curve_points
	
	var bazier_points := []
	var key_points := range(0,curve_points.size(),3)
	
	if curve_points.size() > 0:
		for i in key_points:
			if i == 0: continue
			for j in precision: 
				bazier_points.append(_bazier_cubic(curve_points[i-3],curve_points[i-2],curve_points[i-1],curve_points[i-0],range_lerp(j,0,precision-1,0,0.99)))
		
		return bazier_points
	
	else : return []

func _bazier_cubic (p0: Vector2,p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var r0 := p0.linear_interpolate(p1,t)
	var r1 := p1.linear_interpolate(p2,t)
	var r2 := p2.linear_interpolate(p3,t)
	var s0 := r0.linear_interpolate(r1,t)
	var s1 := r1.linear_interpolate(r2,t)
	return s0.linear_interpolate(s1,t)

#Returns an array containing arrays with pairs of points representing segments	
func _control_points () -> Array: 
	
	var a_points := data.size()
	var controls_points := []
	
	if a_points == 0:
		printerr("The bazier curve must be gerate")
		return []
		
	elif a_points == 1:
		printerr("The bazier curve points must be greater than 1")
		return []
	
	for i in a_points-1:
		
		if i == 0:
			var points_l := []
			points_l.append(data[i])
			points_l.append(data[i+1])
			controls_points.append(points_l)
			continue
		
		elif i%3 == 0:
			var points_l := []
			var points_l2 := []
			
			points_l.append(data[i])
			points_l.append(data[i+1])
			
			points_l2.append(data[i])
			points_l2.append(data[i-1])
			
			controls_points.append(points_l)
			controls_points.append(points_l2)
			continue
		
		elif i == a_points-1:
			var points_l := []
			points_l.append(data[i-1])
			points_l.append(data[i])
			controls_points.append(points_l)
			continue
		
		
		elif i+1 == a_points-1:
			var points_l := []
			points_l.append(data[i])
			points_l.append(data[i+1])
			controls_points.append(points_l)
			pass
	
	return controls_points

func _get_closest_point(to: Vector2,precision: float) -> Vector2:
	for i in data.size():
		if (data[i]-to).length() < precision:
			return data[i]
	return Vector2.ZERO
