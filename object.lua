
-- basiskram fuer objekte
-- position, zerstörbar
-- was passiert wenn man gegenfliegt
-- bewegungspfad

-- sub-dinger z.B.
	-- enemy
	-- lebloser kram
	-- goodie

object = {}

object.x1 = ""
object.x2 = ""
object.y1 = ""
object.y2 = ""
object.destructable = ""

function object.createblock(self,x1,x2,y1,y2)
end

function object.collision(self, damage) 
end

function object.destroy(self)
  
end
