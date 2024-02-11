--[[

Tiny quaternion lib for GeeXLab

--]]


gx_quaternion = { }

--[[
Quaternions can be defined with an axis-angle notation
q = [x,y,z, angle]

- http://fr.wikipedia.org/wiki/Quaternions_et_rotation_dans_l%27espace
- http://fr.wikipedia.org/wiki/Blocage_de_cardan
- http://fr.wikipedia.org/wiki/Quaternion#Applications
--]]

--------------------------------------------------------------------------
function gx_quaternion.new()
  local q = {x=0, y=0, z=0, w=1 }
  return q
end

--------------------------------------------------------------------------
function gx_quaternion.set(q, x, y, z, w)
  q.x = x
  q.y = y
  q.z = z
  q.w = w
end

--------------------------------------------------------------------------
function gx_quaternion.get(q)
  return q.x, q.y, q.z, q.w
end

--------------------------------------------------------------------------
function gx_quaternion.get_conjugate(q)
  q.w = -q.w
  return q
end

--------------------------------------------------------------------------
function gx_quaternion.from_angle_axis(ang, x, y, z)
	local r = ang * math.pi / 180
  local halfang = 0.5 * r
	local fsin = math.sin(halfang)
  local q = gx_quaternion.new()
  q.x = fsin*x
  q.y = fsin*y
  q.z = fsin*z
  q.w = math.cos(halfang)
  return q
	--return fsin*x , fsin*y , fsin*z, math.cos(halfang)
end


--------------------------------------------------------------------------
function gx_quaternion.from_angle_axis_v2(q, ang, x, y, z)
	local r = ang * math.pi / 180
  local halfang = 0.5 * r
	local fsin = math.sin(halfang)
  q.x = fsin*x
  q.y = fsin*y
  q.z = fsin*z
  q.w = math.cos(halfang)
end

--------------------------------------------------------------------------
function gx_quaternion.from_euler(pitch, yaw, roll)
  local qx = gx_quaternion.new()
  local qy = gx_quaternion.new()
  local qz = gx_quaternion.new()
  local qt = gx_quaternion.new()
  local qtmp = gx_quaternion.new()
  
  qx = gx_quaternion.from_angle_axis(pitch,  1, 0, 0)
  qy = gx_quaternion.from_angle_axis(yaw,   0, 1, 0)
  qz = gx_quaternion.from_angle_axis(roll,     0, 0, 1)
  
  qtmp = gx_quaternion.mul(qy, qx)
  qt = gx_quaternion.mul(qtmp, qz)
  
  --q.x, q.y, q.z, q.w = gx_quaternion.normalise(qtmp)
  gx_quaternion.normalise(qt)
  return qt
end

--------------------------------------------------------------------------
function gx_quaternion.to_euler(q)
  local ww = q.w*q.w;
  local xx = q.x*q.x;
  local yy = q.y*q.y;
  local zz = q.z*q.z;
  local pitch = math.atan2(2.0*(q.y*q.z+q.x*q.w), -xx-yy+zz+ww);
  local yaw = math.asin(-2.0*(q.x*q.z-q.y*q.w));
  local roll = math.atan2(2.0*(q.x*q.y+q.z*q.w), xx-yy-zz+ww);
  return pitch, yaw, roll
end

--------------------------------------------------------------------------
function gx_quaternion.identity()
  local q = gx_quaternion.new()
  return q
	--return 0,0,0,1
end

--------------------------------------------------------------------------
function gx_quaternion.normalize(q)
	local factor = 1.0 / math.sqrt(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w)
  q.x = q.x*factor
  q.y = q.y*factor
  q.z = q.z*factor
  q.w = q.w*factor
end

function gx_quaternion.normalise(q)
  gx_quaternion.normalize(q)
end



--[[
function gx_quaternion.normalise(x, y, z, w)
	local factor = 1.0 / math.sqrt(x*x + y*y + z*z + w*w)
	return x*factor,y*factor,z*factor,w*factor
end
--]]


--------------------------------------------------------------------------
function gx_quaternion.to_string(q)
  local s = string.format("<qx=%f, qy=%f, qz=%f, qw=%f>", q.x, q.y, q.z, q.w)
  return s
end  


--------------------------------------------------------------------------
function gx_quaternion.mul(a, b)
  local q = gx_quaternion.new()
  q.x, q.y, q.z, q.w = gx_quaternion.mul_xyzw(a.x, a.y, a.z, a.w,   b.x, b.y, b.z, b.w)
  return q
end

--------------------------------------------------------------------------
function gx_quaternion.mul2(a, b, out)
  out.x, out.y, out.z, out.w = gx_quaternion.mul_xyzw(a.x, a.y, a.z, a.w,   b.x, b.y, b.z, b.w)
  return q
end

--------------------------------------------------------------------------
function gx_quaternion.mul_xyzw(ax,ay,az,aw,   bx,by,bz,bw)
	return	aw * bx + ax * bw + ay * bz - az * by,
			        aw * by + ay * bw + az * bx - ax * bz,
			        aw * bz + az * bw + ax * by - ay * bx,
              aw * bw - ax * bx - ay * by - az * bz
end

--------------------------------------------------------------------------
function gx_quaternion.slerp(qa, qb, t)
  -- from: http://www.codea.io/talk/discussion/1873/extension-of-andrew-staceys-quaternion-library/p1

  local qm = gx_quaternion.new()
  qm.w = 0

  --    // Calculate angle between them.
  local cosHalfTheta = (qa.x * qb.x) + (qa.y * qb.y) + (qa.z * qb.z) + (qa.w * qb.w)

  --    // if qa=qb or qa=-qb then...
  if (math.abs(cosHalfTheta) >= 1.0) then
    qm.x = qa.x
    qm.y = qa.y
    qm.z = qa.z
    qm.w = qa.w
    return qm
  end

  --   // Calculate temporary values.
  local halfTheta = math.acos(cosHalfTheta)
  local sinHalfTheta = math.sqrt(1.0 - cosHalfTheta*cosHalfTheta)

  --    // if theta = 180 degrees then result is not fully defined
  --    // we could rotate around any axis normal to qa or qb
  if (math.abs(sinHalfTheta) < 0.001) then
        qm.x = (qa.x * 0.5 + qb.x * 0.5)
        qm.y = (qa.y * 0.5 + qb.y * 0.5)
        qm.z = (qa.z * 0.5 + qb.z * 0.5)
        qm.w = (qa.w * 0.5 + qb.w * 0.5)
        return qm
  end

  local ratioA = math.sin((1 - t) * halfTheta) / sinHalfTheta
  local ratioB = math.sin(t * halfTheta) / sinHalfTheta

  --    //calculate Quaternion.
  qm.x = (qa.x * ratioA + qb.x * ratioB)
  qm.y = (qa.y * ratioA + qb.y * ratioB)
  qm.z = (qa.z * ratioA + qb.z * ratioB)
  qm.w = (qa.w * ratioA + qb.w * ratioB)
  return qm
end

--------------------------------------------------------------------------
function gx_quaternion.rotate_point(q, point)

	local uv = gx_quaternion.new()
  local uuv = gx_quaternion.new()
	local qvec = {x=q.x, y=q.y, z=q.z, w=1}
  
  local uv= {x=qvec.y*point.z - qvec.z*point.y, y=qvec.z*point.x - qvec.x*point.z, z=qvec.x*point.y - qvec.y*point.x, w=1.0}
  local uuv= {x=qvec.y*uv.z - qvec.z*uv.y, y=qvec.z*uv.x - qvec.x*uv.z, z=qvec.x*uv.y - qvec.y*uv.x, w=1.0}

	uv.x =  uv.x * (2.0 * q.w) 
	uv.y =  uv.y * (2.0 * q.w) 
	uv.z =  uv.z * (2.0 * q.w) 
	uv.w =  uv.w * (2.0 * q.w)
  
 	uuv.x =  uuv.x * 2.0 
 	uuv.y =  uuv.y * 2.0 
 	uuv.z =  uuv.z * 2.0 
 	uuv.w =  uuv.w * 2.0 

	return point.x + uv.x + uuv.x,  point.y + uv.y + uuv.y,  point.z + uv.z + uuv.z

end





