Type THero
	field spd# = 0.3;
	field position: Vector2 = new Vector2();
	field wayManager: WaypointManager;

	Method New(x%, y%)
		position.Set(x, y);
		wayManager = new WaypointManager();
	EndMethod

	Method MoveTo(x%, y%, waypoints: TList)
		wayManager.SetPosition(position);
		wayManager.SetTarget(x, y, waypoints);
	EndMethod

	Method Update()
		if (wayManager.HasPath())
			Move(wayManager.GetVelocity(position));
		EndIf
	EndMethod

	Method Move(velocity: Vector2)
		local resultVelocity: Vector2 = new Vector2(velocity).Mltpl(spd);
		position.Plus(resultVelocity);
	EndMethod

	Method Draw()
		wayManager.Draw();
		SetColor( 68, 0, 255 );
		DrawOval( position.x*TILE_SIZE+WAYPOINT_START_DRAW_SIZE_MARGIN, position.y*TILE_SIZE+WAYPOINT_START_DRAW_SIZE_MARGIN, WAYPOINT_START_DRAW_SIZE, WAYPOINT_START_DRAW_SIZE )
		if (mouseX() > position.x*TILE_SIZE and MouseX()<position.x*TILE_SIZE+TILE_SIZE and mouseY() > position.y*TILE_SIZE and MouseY()<position.y*TILE_SIZE+TILE_SIZE )
			SetColor( 255, 255, 255 );
			DrawText( "WP id: "+wayManager.currentWPId, 0, 440 );
		EndIf
	EndMethod
EndType