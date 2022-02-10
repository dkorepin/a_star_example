Const WAYPOINT_DRAW_SIZE: byte = 12;
Const WAYPOINT_START_DRAW_SIZE: byte = 8;
Const WAYPOINT_START_DRAW_SIZE_MARGIN: byte = 4;
Const WAYPOINT_MOVE_ORTHO_WEIGHT: byte = 10;
Const WAYPOINT_MOVE_DIAGONAL_WEIGHT: byte = 14;

Type TWaypoint
	field position: Vector2 = new Vector2();
	field parent: TWaypoint;
	field pathLength%;
	field evristicDist%;
	field weight%;

	Method New(pos: Vector2)
		position.Set(pos);
	EndMethod

	Method New(pos: Vector2, parent: TWaypoint, le%)
		position.Set(pos);
		self.parent = parent;
		if (parent)
			self.pathLength = parent.pathLength + le;
		endif
	EndMethod

	Method Calc(tx%, ty%)
		local sX% = position.x, sy% = position.y;
		evristicDist = 0;

		Repeat
			if (sX > tx)
				sX:-1;
				evristicDist:+WAYPOINT_MOVE_ORTHO_WEIGHT;
			EndIf
			if (sX < tx)
				sX:+1;
				evristicDist:+WAYPOINT_MOVE_ORTHO_WEIGHT;
			EndIf
			if (sY > ty)
				sY:-1;
				evristicDist:+WAYPOINT_MOVE_ORTHO_WEIGHT;
			EndIf
			if (sY < ty)
				sY:+1;
				evristicDist:+WAYPOINT_MOVE_ORTHO_WEIGHT;
			EndIf
		Until sX = tx and sY = ty

		weight = pathLength + evristicDist;
	EndMethod

	Method Move()
		'TO DO
	EndMethod

	Method DrawOpen()
		SetColor( 196, 0, 0 );
		DrawRect( position.x*TILE_SIZE+2, position.y*TILE_SIZE+2, WAYPOINT_DRAW_SIZE, WAYPOINT_DRAW_SIZE );
		SetColor( 0, 0, 0 );

		DrawInfo();
	EndMethod

	Method DrawClose()
		SetColor( 126, 0, 0 );
		DrawRect( position.x*TILE_SIZE+2, position.y*TILE_SIZE+2, 12, 12 );
		SetColor( 0, 0, 0 );

		DrawArrow();

		DrawInfo();
	EndMethod

	Method DrawInfo()
		if (mouseX() > position.x*TILE_SIZE and MouseX()<position.x*TILE_SIZE+TILE_SIZE and mouseY() > position.y*TILE_SIZE and MouseY()<position.y*TILE_SIZE+TILE_SIZE )
			SetColor( 255, 255, 255 );
			DrawText( "WP: "+position.x+":"+position.y+"| path:"+pathLength+"| evr:"+evristicDist+"| wei:"+weight, 0, 420 );
		EndIf
	EndMethod

	Method DrawPath()
		SetLineWidth( 3 );
		if (parent)
			DrawLine( position.x*TILE_SIZE+8, position.y*TILE_SIZE+8, parent.position.x*TILE_SIZE+8, parent.position.y*TILE_SIZE+8, True );
			parent.DrawPath();
		EndIf
	EndMethod

	Method DrawArrow()
		SetLineWidth( 1 );
		if (parent)
			local dx% = parent.position.x - position.x;
			local dy% = parent.position.y - position.y;

			DrawLine( position.x*TILE_SIZE+8, position.y*TILE_SIZE+8, position.x*TILE_SIZE+8+dx*5, position.y*TILE_SIZE+8+dy*5, True );
		EndIf
	EndMethod
EndType
