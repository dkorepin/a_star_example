Include "./lib/WaypointManager.bmx";
Include "./lib/Hero.bmx";

AppTitle = "A-Star speed test";

global map: TList = new TList();
Global hero: THero = new THero(0,0);

Graphics( 640, 480, 0);
Init();
MainCycle();

Function MainCycle()
	Repeat
		Update();
		Cls();
		Draw();
		Flip(1);
	Until AppTerminate() Or KeyHit( KEY_ESCAPE )
EndFunction

Function Update()
	if (MouseHit( 1 )) hero.MoveTo(mouseX()/TILE_SIZE, MouseY()/TILE_SIZE, map);
	hero.Update();
EndFunction

Function Draw()
	For Local t: TTile = EachIn map
		t.Draw();
	Next
	hero.Draw();
	SetColor( 255, 255, 255 );
EndFunction

Function Init()
	For Local x% = 0 Until 25
		For Local y% = 0 Until 20
			local t: TTile = new TTile(x, y);
			if (x = 15 and y < 15) t.waypointId = 0;
			if (y = 8 and x < 10) t.waypointId = 0;
			if (y = 15 and x < TILE_SIZE and x > 3) t.waypointId = 0;
			map.AddLast(t);
		Next
	Next

	hero.MoveTo(23, 2, map);
EndFunction