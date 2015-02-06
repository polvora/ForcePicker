#pragma semicolon 1

#include <sourcemod>
#include <tf2_stocks>
#include <sdktools>


#define PLUGIN_URL ""
#define PLUGIN_VERSION "2.2"
#define PLUGIN_NAME "Force Picker"
#define PLUGIN_AUTHOR "Statik and KniL"
#define DEBUG 1

public Plugin:myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Tool to make the pick up games quicker",
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}

/*================================
************ HANDLES *************
================================*/

new Handle:g_hTimer;
new Handle:g_hHud;

/*=====================================
************* VARIABLES ***************
=====================================*/

new remainingTime;
new bool:isRunning = false;

/*==================================
******* ONFUNCTIONS & EVENTS *******
==================================*/

public OnPluginStart()
{
	// Cvars 
	CreateConVar("forcepicker_version", PLUGIN_VERSION, "Force Picker Version", FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	
	// Commands
	RegAdminCmd("sm_forcepicker", cmdForcePicker, ADMFLAG_GENERIC, "Forces random people from spec to pick players.");
	RegAdminCmd("fp", cmdForcePicker, ADMFLAG_GENERIC, "Forces random people from spec to pick players.");
	
	//To hook timer related game events
	HookEvent("player_team", OnPlayerChangeTeam);

	//Timer Hud
	g_hHud = CreateHudSynchronizer();
}

public Action:OnPlayerChangeTeam(Handle:hEvent, const String:strName[], bool:bDontBroadcast)
{
	if (isRunning) CreateTimer(1.0, AuxOnPlayerChangeTeam);
}

public Action:AuxOnPlayerChangeTeam(Handle:timer) 
{ 
	// Checks if there are players in both teams already
	if (GetRealTeamClientCount(2) == 1 && GetRealTeamClientCount(3) == 1)
	{
		ForcePicker();
		ClearTimer(g_hTimer);
	}
}

/*==================================
*********CLIENT COMMANDS************
==================================*/

public Action:cmdForcePicker(client, args)
{
	new String:buffer[16];
	if(GetConVarBool(FindConVar("mp_tournament")) == false)
		return Plugin_Handled;
	
	if(args == 0)
		cmdExecutor(client);
	if (args > 0)
	{
		GetCmdArg(1, buffer, sizeof buffer);
		new time = StringToInt(buffer);
		if (time == 0) // It means time is nan
		{
			if (StrEqual(buffer, "stop"))
			{
				cmdExecutor(client, _, _, true);
				return Plugin_Handled;
			}
			else if (StrEqual(buffer, "spec"))
			{
				cmdExecutor(client, _, true);
				return Plugin_Handled;
			}
			else
			{
				GetCmdArg(0, buffer, sizeof(buffer));
				PrintToChat(client, "\x07FFF047Incorrect syntax, usage: \x01%s [5-600] [stop|spec]", buffer);
				return Plugin_Handled;
			}
		}
		if (args > 1)
		{
			GetCmdArg(2, buffer, sizeof buffer);
			if (StrEqual(buffer, "spec"))
			{
				cmdExecutor(client, time, true);
				return Plugin_Handled;
			}
			else
			{
				GetCmdArg(0, buffer, sizeof(buffer));
				PrintToChat(client, "\x07FFF047Incorrect syntax, usage: \x01%s [5-600] [stop|spec]", buffer);
				return Plugin_Handled;
			}
		}
		else
		{
			cmdExecutor(client, time);
			return Plugin_Handled;
		}
	}
	return Plugin_Handled;
}

cmdExecutor(client, time=0 , bool:spec=false, bool:stop=false)
{
	if (GetRealClientCount() < 2)
	{
		PrintToChat(client, "\x07FFF047There is no enough players to pick.");
		return;
	}
	if (time != 0 && (time < 5 || time > 600))
	{
		PrintToChat(client, "\x07FFF047Invalid time. Input range: \x01[5-600].");
		return;
	}
	if (!spec && !stop)
	{
		if ((GetRealTeamClientCount(2) > 0) && (GetRealTeamClientCount(3) > 0))
		{
			PrintToChat(client, "\x07FFF047There are already players in both teams.");
			return;
		}
		if (GetRealTeamClientCount(1) < 2)
		{
			PrintToChat(client, "\x07FFF047There is no enough players on Spectator team.");
			return;
		}
	}
	if (stop)
	{
		if (!isRunning)
			PrintToChat(client, "\x07FFF047No timer is running at this time.");
		else
			PrintToChatAll("\x07FFF047Countdown timer has been stopped.");
		
		ClearTimer(g_hTimer);
		return;
	}
	if (spec)
		MovePlayersToSpec();
	
	if(time)
	{
		ClearTimer(g_hTimer);
		
		PrintToChatAll("\x07FFF047In \x01%i \x07FFF047seconds random players will be chosen to pick.", time);
		
		remainingTime = time;
		g_hTimer = CreateTimer(1.0, CountdownTimer, _, TIMER_REPEAT);
	}
	else
	{
		if (GetRealTeamClientCount(1) < 2)
		{
			PrintToChat(client, "\x07FFF047There is no enough players on Spectator team.");
			return;
		}
		ForcePicker();
	}
}

public Action:CountdownTimer(Handle:hTimer)
{
	isRunning = true;

	if(remainingTime >= 0)
	{
		if(g_hHud != INVALID_HANDLE)
		{
			SetHudTextParams(-1.0, 0.15, 1.1, 255, 255, 60, 255);
			for(new i = 1; i <= MaxClients; i++) if(IsValidClient(i))
				if(IsValidClient(i))
					ShowSyncHudText(i, g_hHud, "Forcing random players to pick in %02d:%02d", remainingTime / 60, remainingTime % 60);
		}
	}
	else
	{
		isRunning = false;
		ForcePicker();
		return Plugin_Stop;
	}
	
	remainingTime--;
	return Plugin_Handled;
}

ClearTimer(&Handle:hTimer)
{
	if(hTimer != INVALID_HANDLE && isRunning == true)
	{
		KillTimer(hTimer);
		hTimer = INVALID_HANDLE;
		isRunning = false;
	}
}

/*==================================
*************MAIN CODE**************
==================================*/

ForcePicker()
{
	new client1, client2;
	new redCount = GetRealTeamClientCount(2);
	new bluCount = GetRealTeamClientCount(3);
	
	if (redCount > 0 || bluCount > 0)
	{
		if (GetRealTeamClientCount(1) < 1)
		{
			PrintToChatAll("\x07FFF047There is no enough players on Spectator team.");
			return;
		}
	}
	else
	{
		if (GetRealTeamClientCount(1) < 2)
		{
			PrintToChatAll("\x07FFF047There is no enough players on Spectator team.");
			return;
		}
	}
	
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
	
	TF2_SetPlayerClass(client1, TFClass_Scout);
	TF2_SetPlayerClass(client2, TFClass_Scout);
	
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
	else
		PrintToChatAll("\x07FFF047\x07FF4040%N \x07FFF047and \x0799CCFF%N \x07FFF047are picking for this match.", client1, client2);
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


IsValidClient(client)
{
	//if(client <= 0 || client > MaxClients || !IsClientInGame(client)) // DEBUG PURPOSES
	if (client <= 0 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client))
		return false;
	return true;
}

GetRealClientCount() 
{
	new clients = 0;
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if(IsValidClient(i)) 
			clients++;
	}
	return clients;
}

GetRealTeamClientCount(team)
{
	new clients = 0;
	for (new i = 1; i <= MaxClients; i++)
		if(IsValidClient(i) && GetClientTeam(i) == team) 
			clients++;
	return clients;
}

GetRandomPlayer(team) 
{ 
    new clients[MaxClients+1], clientCount; 
    for (new i = 1; i <= MaxClients; i++) 
		if (IsValidClient(i) && GetClientTeam(i) == team) 
			clients[clientCount++] = i; 
    return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)]; 
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
