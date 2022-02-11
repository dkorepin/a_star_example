Include "./Waypoint.bmx";
Include "./Tile.bmx";
Include "./Vector2Int.bmx";
Include "./Vector2.bmx";
Include "./Utils.bmx";

Type WaypointManager
	'points
	field position: Vector2Int = new Vector2Int();
	field target: Vector2Int = new Vector2Int();

	'a-star
	field currentWaypoints: TStringMap = new TStringMap();
	field openedList: TStringMap = new TStringMap();
	field closedList: TStringMap = new TStringMap();

	'config
	field disableDiagonal: byte = 1, maxCycles: short = 400, moveTreshold# = 0.3;

	'result
	field resultWP: TWaypoint;
	field path: Tlist = new Tlist();

	'moving
	field currentWP: TWaypoint;
	field currentWPId%;

	Method New()
	EndMethod

	Method SetPosition(other: Vector2)
		DebugLog( "Position setted "+other.ToString() )
		position.Set(int(other.x), Int(other.y));
	EndMethod

	Method Draw()
		SetColor( 255, 255, 255 );;

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

	Method SetTarget%(x%, y%, waypoints: TList)
		currentWaypoints.Clear();
		openedList.Clear();
		closedList.Clear();
		resultWP = null;
		path.Clear();

		For Local tile: TTile = EachIn waypoints
			if (tile.waypointId = 1)
				local wp: TWaypoint = new TWaypoint(tile.position);
				currentWaypoints.Insert(tile.position.ToString(), wp);
			EndIf
		Next

		target.Set(x, y);
		CalcPath();

		return HasPath();
	EndMethod

	Method HasPath: byte()
		if (resultWP) return 1;
		return 0;
	EndMethod

	Method GetVelocity: Vector2(currentPosition: Vector2)
		local result: Vector2 = new Vector2();

		if (currentWP)
			result = new Vector2(currentWP.position.x, currentWP.position.y).Minus(currentPosition);

			if (result.Magnitude() < moveTreshold) NextPathWP();
		EndIf

		Return result.Normalize();
	EndMethod

	Method RunTest()
		local startTime% = MilliSecs();
		local calls% = 0;

		For Local j = 0 Until 200
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

		if (HasPath())
			local nextWP: TWaypoint = resultWP;
			Repeat
				path.AddLast(nextWP);
				nextWP = nextWP.parent;

			Until nextWP.parent = null

			path.Reverse();
			SetCurrentPathWP(0);
		EndIf
	EndMethod

	Method SetCurrentPathWP(id%)
		if (id < path.Count())
			currentWPId = id;
			currentWP = TWaypoint(path.ValueAtIndex(id));
		EndIf
	EndMethod

	Method NextPathWP()
		if (currentWPId+1 < path.Count())
			SetCurrentPathWP(currentWPId+1);
		Else
			currentWP = null;
		EndIf
	EndMethod

	Method FindPath: TWaypoint(parent: TWaypoint, cycleId% = 0)
		if (cycleId > maxCycles) return null;

		local currentarget: Vector2Int= new Vector2Int(parent.position);

		For Local movX% = -1 Until 2
			For Local movY% = -1 Until 2
				local nowDiagonal: byte = isDiagonal(movX, movY)
				if (movX = 0 and movY = 0) Continue;
				if (disableDiagonal and nowDiagonal) Continue;

				currentarget.Set(parent.position);
				currentarget.Plus(movX, movY);
				
				local hasWP% = closedList.Contains(currentarget.ToString());
				if (hasWP) Continue;

				hasWP = openedList.Contains(currentarget.ToString());
				if (hasWP) Continue;

				local nearElement: TWaypoint = GetElement(currentarget);

				if (nearElement)
					local moveLength% = WAYPOINT_MOVE_ORTHO_WEIGHT;
					if (nowDiagonal) moveLength = WAYPOINT_MOVE_DIAGONAL_WEIGHT;

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

	Method GetElement: TWaypoint(vec: Vector2Int)
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
			if (wp.weight = minWeight) minWpList.AddLast(wp);
		Next

		if (minWpList.Count() = 1) return TWaypoint(minWpList.ValueAtIndex(0));
		if (minWpList.Count() > 0) result = TWaypoint(minWpList.ValueAtIndex(Rand(0, minWpList.Count() - 1)));

		return result;
	EndMethod
EndType