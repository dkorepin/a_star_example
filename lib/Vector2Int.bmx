Type Vector2Int
	field x%, y%

	Method New(x%, y%)
		self.x = x;
		self.y = y;
	EndMethod

	Method New(o: Vector2Int)
		self.x = o.x;
		self.y = o.y;
	EndMethod

	Method Set(o: Vector2Int)
		self.x = o.x;
		self.y = o.y;
	EndMethod

	Method Set(x%, y%)
		self.x = x;
		self.y = y;
	EndMethod

	Method Plus(vx%, vy%)
		self.x:+vx;
		self.y:+vy;
	EndMethod

	Method Plus(o: Vector2Int)
		self.x:+o.x;
		self.y:+o.y;
	EndMethod

	Method Minus: Vector2Int(o: Vector2Int)
		self.x:-o.x;
		self.y:-o.y;

		return self;
	EndMethod

	Method Normalize: Vector2Int()
		local mag# = self.Magnitude();

		self.x = int(x/mag);
		self.x = int(y/mag);
		return self;
	End Method

	Method Magnitude#()
		return Sqr(x * x + y * y);
	EndMethod

	Method isEqual(o: Vector2Int)
		return o.x = x and o.y = y;
	EndMethod

	Method isEqual(x%, y%)
		return self.x = x and self.y = y;
	EndMethod

	Method ToString$()
		return x+":"+y;
	EndMethod
EndType