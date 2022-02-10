Include "./Waypoint.bmx";
Include "./Tile.bmx";
Include "./Vector2.bmx";
Include "./Utils.bmx";

Type WaypointManager
	field position: Vector2 = new Vector2();
	field target: Vector2 = new Vector2();

	field currentWaypoints: TList = new TList();
	field openedList: TList = new TList();
	field closedList: TList = new TList();

	field resultWP: TWaypoint;

	Method New(x%, y%)
		position.Set(x, y);
	EndMethod

	Method Draw()
		SetColor( 255, 255, 255 );
		DrawText( "closedList: "+closedList.Count()+" openedList: "+openedList.Count(), 0, 400 );

		For Local wp: TWaypoint = EachIn openedList
			wp.DrawOpen();
		Next

		For Local wp: TWaypoint = EachIn closedList
			wp.DrawClose();
		Next

		SetColor( 255, 255, 255 );
		if (resultWP <> null) resultWP.DrawPath()

		SetColor( 9, 104, 0 );
		DrawRect( position.x*TILE_SIZE+WAYPOINT_START_DRAW_SIZE_MARGIN, position.y*TILE_SIZE+WAYPOINT_START_DRAW_SIZE_MARGIN, WAYPOINT_START_DRAW_SIZE, WAYPOINT_START_DRAW_SIZE );

		if (target.x <> position.x and target.y <> position.y)
			SetColor( 24, 1, 109 );
			DrawRect( target.x*TILE_SIZE+WAYPOINT_START_DRAW_SIZE_MARGIN, target.y*TILE_SIZE+WAYPOINT_START_DRAW_SIZE_MARGIN, WAYPOINT_START_DRAW_SIZE, WAYPOINT_START_DRAW_SIZE );
		EndIf
	EndMethod

	Method SetTarget(x%, y%, waypoints: TList)
		currentWaypoints.Clear();
		openedList.Clear();
		closedList.Clear();

		For Local tile: TTile = EachIn waypoints
			if (tile.waypointId = 1)
				local wp: TWaypoint = new TWaypoint(tile.position);
				currentWaypoints.AddLast(wp);
			EndIf
		Next

		local startTime% = MilliSecs();
		target.Set(x, y);
		
		local endTime% = MilliSecs() - startTime;
		DebugLog( "Time: "+endTime );
	EndMethod

	Method CalcPath()
		local start: TWaypoint = new TWaypoint(position, null, 0);
		openedList.AddLast(start);
		resultWP = FindPath(start);
	EndMethod

	Method FindPath: TWaypoint(parent: TWaypoint, cycleId% = 0)
		if (cycleId > 400) return null;

		DebugLog( "cycle: "+cycleId+" x:"+parent.position.x+" y:"+parent.position.y );
		For Local movX% = -1 Until 2
			For Local movY% = -1 Until 2
				if (movX = 0 and movY = 0) Continue;
				local currentarget: Vector2= new Vector2(parent.position);
				currentarget.Add(movX, movY)
				local hasWP: byte = 0;

				For Local wp: TWaypoint = EachIn closedList
					if (currentarget.isEqual(wp.position))
						hasWP = 1;
						exit;
					EndIf
				next
				if (hasWP) Continue;

				For Local wp: TWaypoint = EachIn openedList
					if (currentarget.isEqual(wp.position))
						hasWP = 1;
						exit;
					EndIf
				next
				if (hasWP) Continue;

				local finded: TWaypoint = GetElement(currentarget.x, currentarget.y);

				if (finded)
					local le = WAYPOINT_MOVE_ORTHO_WEIGHT;
					if (Abs(movX) + Abs(movY) > 1) le = WAYPOINT_MOVE_DIAGONAL_WEIGHT;
					local wp: TWaypoint = new TWaypoint(currentarget, parent, le);
					wp.Calc(target.x, target.y);
					openedList.AddLast(wp);
				EndIf
			Next
		Next

		openedList.Remove(parent);
		closedList.AddLast(parent);
		local minWp: TWaypoint = GetMinWeightWP(openedList);

		if (minWp <> null)
			if (target.isEqual(minWp.position))
				DebugLog( "Finded "+minWp.position.x+"/"+minWp.position.y );
				closedList.AddLast(minWp);
				return minWp;
			EndIf
			return FindPath(minWp, cycleId+1);
		EndIf
	EndMethod

	Method GetElement: TWaypoint(x%, y%)
		For Local t: TWaypoint = EachIn currentWaypoints
			if (t.position.isEqual(x, y)) return t;
		Next
	
		return null;
	EndMethod

	Method GetMinWeightWP: TWaypoint(list: Tlist)
		local minWeight% = 999, minWp: TWaypoint, minWpList: TList = new TList();

		For Local wp:TWaypoint = EachIn list
			if (target.isEqual(wp.position)) return wp;
			if (wp.weight < minWeight) minWeight = wp.weight;
		Next

		For Local wp:TWaypoint = EachIn list
			if (wp.weight = minWeight) minWpList.AddlAst(wp);
		Next

		if (minWpList.Count() > 0) minWp = TWaypoint(minWpList.ValueAtIndex(Rand(0, minWpList.Count() - 1)));

		return minWp;
	EndMethod
EndType