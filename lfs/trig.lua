function fsin(s)
  local x=s
  if x>180.0 then
    x=(x+180)%360-180
  elseif x<-180.0 then
    x=(x-180)%-360+180
  end
  if x>90.0 then
     x=180.0-x
  elseif x<-90.0 then
     x=-180-x
  end
--  print (x)
  x=math.pi*x/180.0
  local p=x
  local f=1
  local r=p
-- print (x)
 -- 6 Stellen hinter dem Komma fuer 1/4-Kreis
  for j=2,10,2 do
    p=-p * x * x
    f=f*j*(j+1)
    r=r+p/f
  end
 return(r)
end

function fcos(c)
  return fsin(90-c)
end

function rotate_point(p, a)
  local s = fsin(a)
  local c = fcos(a)
  return {x = p.x * c - p.y * s, y = p.x * s + p.y * c}
end

return {fsin = fsin, fcos = fcos, rotate_point = rotate_point}
