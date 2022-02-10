Const TILE_SIZE: byte = 16;
Const TILE_DRAW_SIZE: byte = 14;

Type TTile
	field waypointId: byte = 1;
	field position: Vector2 = new Vector2();

	Method New(x%, y%)
		position.Set(x, y);
	EndMethod

	Method Draw()
		SetColor( 255, 51, 0 );
		if (waypointId) SetColor( 102, 255, 0 );

		DrawRect( position.x*TILE_SIZE+1, position.y*TILE_SIZE+1, TILE_DRAW_SIZE, TILE_DRAW_SIZE );
	EndMethod
EndType
