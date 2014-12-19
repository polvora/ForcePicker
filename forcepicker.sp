#include <sourcemod>
#include <tf2_stocks>

#define UPDATE_URL ""
#define PLUGIN_VERSION "1.0"
#define PLUGIN_NAME "Force Picker"
#define PLUGIN_AUTHOR "Statik"

new Handle:timer;
new minPlayers = 2;
new bool:isTimerRunning = false;
new redPicker, bluPicker;

public Plugin:myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Tool to make the pick up games quicker",
	version = PLUGIN_VERSION,
	url = ""
}

/*==================================
*******ONFUNCTIONS & EVENTS*********
==================================*/

public OnPluginStart()
{
	// Commands
	RegConsoleCmd("forcepickers", cmdForcePickers, "Forces 2 random people from spec to pick players");
	
	// Quick Commands
	AddCommandListener(cmdSay, "say");
	AddCommandListener(cmdSay, "say_team");
	
	// Event Hooks
	HookEvent("player_team", eventChangeTeam, EventHookMode_Pre); // Change team
}

public OnClientDisconnect(client)
{
	if (isTimerRunning && GetRealClientCount() < minPlayers)
	{
		KillTimer(timer);
		isTimerRunning = false;
		PrintToChatAll("There is no enough players to pick. Timer stopped");
	}
}

public Action:eventChangeTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (isTimerRunning)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new team = GetEventInt(event, "team");
		new oldteam = GetEventInt(event, "oldteam");
		new redCount = GetTeamClientCount(2);
		new bluCount = GetTeamClientCount(3);
		
		// Player joined team to pick
		if((redCount == 0 && team == 2) || (bluCount == 0 && team == 3))
		{	
			new String:teamColor[16];
			if (team == 2)
			{
				teamColor = "\x0799CCFFRed";
				redPicker = client;
				if(bluPicker != 0)
				{
					KillTimer(timer);
					isTimerRunning = false;
				}
			}
			else 
			{
				teamColor = "\x07FF4040Blu";
				bluPicker = client;
				if (redPicker != 0) {
					KillTimer(timer);
					isTimerRunning = false;
				}
			}
			PrintToChatAll("\x07476291CE - \x01%N will lead %s team ", client, teamColor);
		}
	}
	
}

/*==================================
*********CLIENT COMMANDS************
==================================*/

public Action:cmdForcePickers(client, args)
{
	decl String:arg[6];
	GetCmdArg(1, arg, sizeof(arg));
	new time = StringToInt(arg);
	cmdExecutor(client, time);
}

public Action:cmdSay(client, const String:command[], args)
{
	new startidx = 0;
	if (text[0] == '"')
	{
		startidx = 1;
		new len = strlen(text);
		if (text[len-1] == '"')
		{
			text[len-1] = '\0';
		}
	}
	if (StrEqual(text[startidx], ".fp", false))
	{
		decl String:arg[2][6];
		ExplodeString(text[startidx], " ", arg, sizeof(bit), sizeof(bit[])); // Separates arguments
		new time = StringToInt(arg[1]);
		cmdExecutor(client, time);
	}
	return Plugin_Continue;
}

cmdExecutor(client, time)
{
	if (!GetAdminFlag(GetUserAdmin(client), Admin_Generic)) // Checks if client is not a generic admin
	{
		PrintToChat(client, "You do not have access to this command.");
		return;
	}
	if (GetRealClientCount() < minPlayers)
	{
		PrintToChat(client, "There is no enough players to pick.");
		return;
	}
	if (time == 0) ForcePickers();
	else  
	{
		for(new i = 1; i <= MaxClients; i++)
			if(IsClientInGame(i)) ChangeClientTeam(i, 1);
			
		timer = CreateTimer(1.0, tmrCallback, time, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		isTimerRunning = true;
	}
	
}

/*==================================
***************TIMERS***************
==================================*/

public Action:tmrCallback(Handle:timer, time)
{
	static counter = time+1;
	counter--;
	
	new minutes = RoundToZero(counter/60.0);
	new seconds = counter % 60;
	PrintHintTextToAll("%02i:%02i", minutes, seconds);
	
	if (counter == 0) {
		ForcePickers();
		isTimerRunning = false;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

/*==================================
*************MAIN CODE**************
==================================*/

ForcePickers()
{
	new redCount = GetTeamClientCount(2);
	new bluCount = GetTeamClientCount(3);
	
	if ((redCount + bluCount) > 1)
	{ // If there's too much people playing they are moved to spec
		for(new i = 1; i <= MaxClients; i++)
			if(IsClientInGame(i))
				ChangeClientTeam(i, 1);
		redCount = bluCount = 0;
	}
	
	new client1, client2;
	if(redCount == 0)
	{
		do client1 = GetRandomInt(1,MaxClients);
		while(!IsClientInGame(client1));
		ChangeClientTeam(client1, 2); // Red
		TF2_SetPlayerClass(client1, TFClass_Scout);
	}
	if(bluCount == 0)
	{
		do client2 = GetRandomInt(1,MaxClients);
		while(!IsClientInGame(client2) && client2 == client1);
		ChangeClientTeam(client2, 3); // Blu
		TF2_SetPlayerClass(client2, TFClass_Scout);
	}
	if (redCount == 0 && bluCount == 0)
		PrintToChatAll("\x07FF4040%N \x01and \x0799CCFF%N \x01have been randomly chosen to pick.", client1, client2);
	else if (redCount == 0)
		PrintToChatAll("\x07FF4040%N has been randomly chosen to pick.", client1);
	else if (blueTeam == 0)
		PrintToChatAll("\x0799CCFF%N has been randomly chosen to pick.", client2);
}

/*==================================
*********EXTRA FUNCTIONS************
==================================*/

GetRealClientCount(bool:inGameOnly = true) 
{
	new clients = 0;
	for( new i = 1; i <= GetMaxClients(); i++ ) {
		if(((inGameOnly) ? IsClientInGame(i) : IsClientConnected(i)) && !IsFakeClient(i)) 
			clients++;
	}
	return clients;
}