Type Vector2
	field x%, y%

	Method New(x%, y%)
		self.x = x;
		self.y = y;
	EndMethod

	Method New(o: Vector2)
		self.x = o.x;
		self.y = o.y;
	EndMethod

	Method Set(o: Vector2)
		self.x = o.x;
		self.y = o.y;
	EndMethod

	Method Set(x%, y%)
		self.x = x;
		self.y = y;
	EndMethod

	Method Add(vx%, vy%)
		self.x:+vx;
		self.y:+vy;
	EndMethod

	Method isEqual(o: Vector2)
		return o.x = x and o.y = y;
	EndMethod

	Method isEqual(x%, y%)
		return self.x = x and self.y = y;
	EndMethod

	Method ToString$()
		return x+":"+y;
	EndMethod
EndType