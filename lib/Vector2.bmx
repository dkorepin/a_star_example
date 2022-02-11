Type Vector2
	field x#, y#;

	Method New()
		self.x = 0;
		self.y = 0;
	EndMethod

	Method New(x#, y#)
		self.x = x;
		self.y = y;
	EndMethod

	Method New(x#)
		self.x = x;
		self.y = x;
	EndMethod

	Method New(vec: Vector2)
		self.x = vec.x;
		self.y = vec.y;
	EndMethod

	Method ToString$()
		return x+":"+y;
	EndMethod

	Method Set(x#, y#)
		self.x = x;
		self.y = y;
	EndMethod

	Method Set(x#)
		self.x = x;
		self.y = x;
	EndMethod

	Method Set(vec: Vector2)
		self.x = vec.x;
		self.y = vec.y;
	EndMethod

	Method Magnitude#()
		return Sqr(x * x + y * y);
	EndMethod

	Method Equals%(other: Vector2)
        return x = other.x And y = other.y;
	EndMethod

	Method Plus: Vector2(other: Vector2)
		x:+ other.x;
		y:+ other.y;

		return self;
	EndMethod

	Method Plus: Vector2(x#, y#)
		self.x:+ x;
		self.y:+ y;

		return self;
	EndMethod

	Method Minus: Vector2(other: Vector2)
		x:- other.x;
		y:- other.y;

		return self;
	EndMethod

	Method Mltpl: Vector2(other: Vector2)
		x:* other.x;
		y:* other.y;

		return self;
	EndMethod

	Method Mltpl: Vector2(a#)
		x:* a;
		y:* a;

		return self;
	EndMethod

	Method Normalize: Vector2()
		local mag# = self.Magnitude();
		if (mag < 0.01)
			self.x = 0;
			self.y = 0;
		Else
			self.x:/mag;
			self.y:/mag;
		EndIf

		return self;
	End Method
EndType