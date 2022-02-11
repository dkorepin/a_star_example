Include "./Waypoint.bmx";
Include "./Tile.bmx";
Include "./Vector2.bmx";
Include "./Utils.bmx";

Type WaypointManager
	field position: Vector2 = new Vector2();
	field target: Vector2 = new Vector2();

	field currentWaypoints: TStringMap = new TStringMap();
	field openedList: TStringMap = new TStringMap();
	field closedList: TStringMap = new TStringMap();

	field resultWP: TWaypoint;

	Method New(x%, y%)
		position.Set(x, y);
	EndMethod

	Method Draw()
		SetColor( 255, 255, 255 );
		' DrawText( "closedList: "+Len(closedList.Values())+" openedList: "+Len(openedList.Values()), 0, 400 );

		For Local wp: TWaypoint = EachIn openedList.Values()
			wp.DrawOpen();
		Next

		For Local wp: TWaypoint = EachIn closedList.Values()
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
				currentWaypoints.Insert(tile.position.ToString(), wp);
			EndIf
		Next

		local startTime% = MilliSecs();
		local calls% = 0;

		For Local j = 0 Until 20
			For Local i = 1 Until 19
				target.Set(i+5, i);
				CalcPath();
				calls:+1;
			Next
			For Local i = 1 Until 19
				target.Set(24, 19-i);
				CalcPath();
				calls:+1;
			Next
		Next

		local endTime% = MilliSecs() - startTime;
		local av# = Float(endTime)/Float(calls);
		DebugLog( "Time: "+endTime+" calls:"+calls+" average: "+av );
	EndMethod

	Method CalcPath()
		local start: TWaypoint = new TWaypoint(position, null, 0);
		openedList.Insert(position.ToString(), start);
		resultWP = FindPath(start);
	EndMethod

	Method FindPath: TWaypoint(parent: TWaypoint, cycleId% = 0)
		if (cycleId > 400) return null;

		local currentarget: Vector2= new Vector2(parent.position);

		For Local movX% = -1 Until 2
			For Local movY% = -1 Until 2

				if (movX = 0 and movY = 0) Continue;

				currentarget.Set(parent.position);
				currentarget.Add(movX, movY);
				
				local hasWP% = closedList.Contains(currentarget.ToString());
				if (hasWP) Continue;

				hasWP = openedList.Contains(currentarget.ToString());
				if (hasWP) Continue;

				local nearElement: TWaypoint = GetElement(currentarget);

				if (nearElement)
					local moveLength% = WAYPOINT_MOVE_ORTHO_WEIGHT;
					if (Abs(movX) + Abs(movY) > 1) moveLength = WAYPOINT_MOVE_DIAGONAL_WEIGHT;

					local wp: TWaypoint = new TWaypoint(currentarget, parent, moveLength);

					wp.CalcForTarget(target);
					openedList.Insert(wp.position.ToString(), wp);
				EndIf
			Next
		Next

		openedList.Remove(parent.position.ToString());
		closedList.Insert(parent.position.ToString(), parent);
		local minWeightWp: TWaypoint = GetMinWeightWP(openedList);

		if (minWeightWp <> null)
			if (target.isEqual(minWeightWp.position))
				DebugLog( "Finded "+minWeightWp.position.x+"/"+minWeightWp.position.y );
				closedList.Insert(minWeightWp.position.ToString(), minWeightWp);
				return minWeightWp;
			EndIf
			return FindPath(minWeightWp, cycleId+1);
		EndIf
	EndMethod

	Method GetElement: TWaypoint(vec: Vector2)
		return TWaypoint(currentWaypoints[vec.ToString()]);
	EndMethod

	Method GetMinWeightWP: TWaypoint(map: TStringMap)
		local minWeight% = 999, result: TWaypoint, minWpList: TList = new TList();

		local targetWp: TWaypoint = TWaypoint(map[target.ToSTring()]);
		if (targetWp) return targetWp;

		For Local wp:TWaypoint = EachIn map.Values()
			if (wp.weight < minWeight) minWeight = wp.weight;
		Next

		For Local wp:TWaypoint = EachIn map.Values()
			if (wp.weight = minWeight) minWpList.AddlAst(wp);
		Next

		if (minWpList.Count() = 1) return TWaypoint(minWpList.ValueAtIndex(0));
		if (minWpList.Count() > 0) result = TWaypoint(minWpList.ValueAtIndex(Rand(0, minWpList.Count() - 1)));

		return result;
	EndMethod
EndType