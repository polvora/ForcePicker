#pragma semicolon 1

#include <sourcemod>
#include <tf2_stocks>
#include <sdktools>


#define PLUGIN_URL ""
#define PLUGIN_VERSION "2.0"
#define PLUGIN_NAME "Force Picker"
#define PLUGIN_AUTHOR "Statik and KniL"
#define DEBUG 1

/*================================
******** HANDLES | CVARS *********
================================*/
new Handle:g_hCvarEnabled;
new Handle:g_hCvarHudX;
new Handle:g_hCvarHudY;
new Handle:g_hCvarHudMessage;
new Handle:g_hTimer;
new Handle:g_hHud;

/*================================
************ CVARS ***************
================================*/
new g_iTimerTime;
new bool:g_bEnabled;
new Float:g_iHudX;
new Float:g_iHudY;
new String:g_strHudMessage[50];

/*=====================================
************* VARIABLES ***************
=====================================*/
new g_iRemaining;
new bool:g_bTournament;

public Plugin:myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Tool to make the pick up games quicker",
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}

new minPlayers = 2;

/*==================================
******* ONFUNCTIONS & EVENTS *******
==================================*/

public OnPluginStart()
{
	// Cvars 
	CreateConVar("sm_forcepicker_version", PLUGIN_VERSION, "Forcepicker Version", FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_hCvarEnabled = CreateConVar("sm_forcepicker_enabled", "1", "Enable Forcepicker\n0 = Disabled\n1 = Enabled", _, true, 0.0, true, 1.0);
	g_bEnabled = GetConVarBool(g_hCvarEnabled);
	HookConVarChange(g_hCvarEnabled, OnConVarChange);
	
	// Commands
	RegConsoleCmd("sm_forcepicker", cmdForcePickers, "Forces random people from spec to pick players");
	RegConsoleCmd("sm_forcepick", cmdForcePickers, "Forces random people from spec to pick players");
	RegConsoleCmd("sm_fp", cmdForcePickers, "Forces random people from spec to pick players");
	
	// Quick Commands
	AddCommandListener(cmdSay, "say");
	AddCommandListener(cmdSay, "say_team");
	
	// Timer Cvars
	g_hCvarHudX = CreateConVar("sm_forcepicker_xhud", "-1", "X hud position\n-1 = Center", _, true, -1.0, true, 1.0);
	g_iHudX = GetConVarFloat(g_hCvarHudX);
	HookConVarChange(g_hCvarHudX, OnConVarChange);

	g_hCvarHudY = CreateConVar("sm_forcepicker_yhud", "0.15", "Y hud position\n-1 = Center", _, true, -1.0, true, 1.0);
	g_iHudY = GetConVarFloat(g_hCvarHudY);
	HookConVarChange(g_hCvarHudY, OnConVarChange);
	
	g_hCvarHudMessage = CreateConVar("sm_forcepicker_hudMessage", "Time to pick", "Message for the timer");
	GetConVarString(g_hCvarHudMessage, g_strHudMessage, sizeof(g_strHudMessage));
	HookConVarChange(g_hCvarHudMessage, OnConVarChange);

	//Create config on cfg/sourcemod
	AutoExecConfig(true, "plugin.forcepicker");

	//To hook timer related game events
	HookEvent("player_team", OnPlayerChangeTeam);

	//Timer Hud
	g_hHud = CreateHudSynchronizer();
}

public OnMapStart()
{
	//Clear the timer
	ClearTimer(g_hTimer);
	//Make sure the map is on Tournament mode 
	g_bTournament = false;
	if(GetConVarBool(FindConVar("mp_tournament")))
		g_bTournament = true;
}

public Action:OnPlayerChangeTeam(Handle:hEvent, const String:strName[], bool:bDontBroadcast)
{
	CreateTimer(3.0, AuxOnPlayerChangeTeam, _);
}

public Action:AuxOnPlayerChangeTeam(Handle:timer) 
{ 
	// Checks if there are players in both teams already
	if (GetRealTeamClientCount(2) == 1) 
	{
		if (GetRealTeamClientCount(3) == 1)
			ClearTimer(g_hTimer);
	}
}

/*==================================
**********TIMER CREATION************
==================================*/
public Action:Timer_Round(Handle:hTimer)
{
	g_iRemaining--;

	if(g_iRemaining >= 0)
	{
		if(g_hHud != INVALID_HANDLE)
		{
			SetHudTextParams(g_iHudX, g_iHudY, 1.1, 255, 255, 255, 255);
			for(new i = 1; i <= MaxClients; i++) if(IsValidClient(i))
			{
				//if(!IsFakeClient(i))
					ShowSyncHudText(i, g_hHud, "Time to pick: %02d:%02d", g_iRemaining / 60, g_iRemaining % 60);
			}
		}
	}
	else
	{
		ForcePickers();
		ClearTimer(g_hTimer);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

/*==================================
**************STOCKS****************
==================================*/

stock IsValidClient(iClient, bool:bReplay = true)
{
	if(iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient))
		return false;
	if(bReplay && (IsClientSourceTV(iClient) || IsClientReplay(iClient)))
		return false;
	return true;
}

stock ClearTimer(&Handle:hTimer)
{
	if(hTimer != INVALID_HANDLE)
	{
		KillTimer(hTimer);
		hTimer = INVALID_HANDLE;
	}
}

/*==================================
*********CLIENT COMMANDS************
==================================*/

public Action:cmdForcePickers(client, args)
{
	new String:buffer[4];
	if(g_bTournament)
	{
		if(args < 1)
			cmdExecutor(client, 0);
		else
		{
			if (args == 1)
			{
				GetCmdArg(1, buffer, sizeof(buffer));
				g_iTimerTime = StringToInt(buffer);
				cmdExecutor(client, g_iTimerTime);
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

public Action:cmdSay(client, const String:command[], args)
{
	new String:text[192];
	GetCmdArgString(text, sizeof(text));
	
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
		CreateTimer(0.1, tmrAuxExecutor, client);
	}
	
	return Plugin_Continue;
}

public Action:tmrAuxExecutor(Handle:timer, any:client) 
{ 
	if (IsClientInGame(client)) { cmdExecutor(client, 0); }
}

cmdExecutor(client, time)
{
	if (!GetAdminFlag(GetUserAdmin(client), Admin_Generic)) // Checks if client is not a generic admin
	{
		PrintToChat(client, "\x07FFF047You do not have access to this command.");
		return;
	}
	if (GetRealClientCount() < minPlayers)
	{
		PrintToChat(client, "\x07FFF047There is no enough players to pick.");
		return;
	}
	if ((GetRealTeamClientCount(2) != 0) && (GetRealTeamClientCount(3) != 0)) // Checks if there are players in both teams already
	{
		PrintToChat(client, "\x07FFF047There are already players in both teams.");
		return;
	}
	
	//When sm_forcepicker have time argument
	if(time)
	{
		ClearTimer(g_hTimer);
		
		MovePlayersToSpec(); // Move players to spectator
		
		g_iRemaining = time;
		g_iTimerTime = time; // Save time for future use
		g_hTimer = CreateTimer(1.0, Timer_Round, _, TIMER_REPEAT);
	}
	else ForcePickers();
}

/*==================================
*************MAIN CODE**************
==================================*/

ForcePickers()
{
	new client1, client2;
	new redCount = GetRealTeamClientCount(2);
	new bluCount = GetRealTeamClientCount(3);
	
	if (redCount == 0)
	{
		client1 = GetRandomPlayer(1); // Spectator
		ChangeClientTeam(client1, 2); // Red
		PrintCenterText(client1, "You have been chosen to pick for this match.");
	}
	else 
	{	// Get current player in the team
		client1 = GetRandomPlayer(2);
	}
	
	if (bluCount == 0)
	{
		client2 = GetRandomPlayer(1); // Spectator
		ChangeClientTeam(client2, 3); // Blue
		PrintCenterText(client2, "You have been chosen to pick for this match.");
	}
	else 
	{	// Get current player in the team
		client2 = GetRandomPlayer(3);
	}
	
	// This is to know the comp mode (HL/6v6)
	new Handle:cvarClassLimit = FindConVar("tf_tournament_classlimit_scout");
	new classLimit = GetConVarInt(cvarClassLimit);
	CloseHandle(cvarClassLimit);
	cvarClassLimit = INVALID_HANDLE;
	
	if (classLimit == 2) // 6v6
	{
		TF2_SetPlayerClass(client1, TFClass_Scout);
		TF2_SetPlayerClass(client2, TFClass_Scout);
	}
	else // HL
	{
		TF2_SetPlayerClass(client1, TFClass_Heavy);
		TF2_SetPlayerClass(client2, TFClass_Heavy);
	}
	
	TF2_RespawnPlayer(client1);
	TF2_RespawnPlayer(client2);
	
	CreateTimer(1.0, tmrMeleeStrip, client1);
	CreateTimer(1.0, tmrMeleeStrip, client2);
	
	if (redCount == 0 && bluCount == 0)
		PrintToChatAll("\x07FFF047\x07FF4040%N \x07FFF047and \x0799CCFF%N \x07FFF047have been randomly chosen to pick.", client1, client2);
	else if (redCount == 0)
		PrintToChatAll("\x07FFF047\x07FF4040%N \x07FFF047has been randomly chosen to pick against \x0799CCFF%N\x07FFF047.", client1, client2);
	else if (bluCount == 0)
		PrintToChatAll("\x07FFF047\x0799CCFF%N \x07FFF047has been randomly chosen to pick against \x07FF4040%N\x07FFF047.", client2, client1);
}//F1E783

// Change to weapon slot 2 (Melee)
public Action:tmrMeleeStrip(Handle:timer, any:client) 
{ 
	if (client && IsPlayerAlive(client))
	{
		new weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	}
}

/*==================================
*********EXTRA FUNCTIONS************
==================================*/

GetRealClientCount(bool:inGameOnly = true) 
{
	new clients = 0;
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		//if(((inGameOnly) ? IsClientInGame(i) : IsClientConnected(i)) && !IsFakeClient(i)) 
		if(((inGameOnly) ? IsClientInGame(i) : IsClientConnected(i))) 
			clients++;
	}
	return clients;
}

GetRealTeamClientCount(team)
{
	new clients = 0;
	for (new i = 1; i <= MaxClients; i++)
		//if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == team) 
		if(IsClientInGame(i) && GetClientTeam(i) == team) 
			clients++;
	return clients;
}

GetRandomPlayer(team) 
{ 
    new clients[MaxClients+1], clientCount; 
    for (new i = 1; i <= MaxClients; i++) 
        //if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == team) 
		if (IsClientInGame(i) && GetClientTeam(i) == team) 
			clients[clientCount++] = i; 
    return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)]; 
}  

//If a cvar change
public OnConVarChange(Handle:hConvar, const String:strOldValue[], const String:strNewValue[])
{
	if(hConvar == g_hCvarEnabled)
	{
		g_bEnabled = GetConVarBool(g_hCvarEnabled);
		if(!g_bEnabled)
			//Delete the timer
			ClearTimer(g_hTimer);
	}
	if(hConvar == g_hCvarHudMessage)
		GetConVarString(g_hCvarHudMessage, g_strHudMessage, sizeof(g_strHudMessage));
	if(hConvar == g_hCvarHudX)
		g_iHudX = GetConVarFloat(hConvar);
	if(hConvar == g_hCvarHudY)
		g_iHudY = GetConVarFloat(hConvar);
}

MovePlayersToSpec()
{
	decl String:buffer[96];
	new targets[33], bool:ml;
	new count = ProcessTargetString("@all", 0, targets, sizeof(targets), COMMAND_FILTER_CONNECTED, buffer, sizeof(buffer), ml);
	if (count > 0)
	{
		for (new i = 0; i < count; i++)
		{
			new t = targets[i];
			if (IsPlayerAlive(t)) ForcePlayerSuicide(t);
			ChangeClientTeam(t, 1);
		}
	}
}
