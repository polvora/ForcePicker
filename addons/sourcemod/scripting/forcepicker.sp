#pragma semicolon 1

#include <sourcemod>
#include <tf2_stocks>

#define PLUGIN_URL ""
#define PLUGIN_VERSION "1.0"
#define PLUGIN_NAME "Force Picker"
#define PLUGIN_AUTHOR "Statik"

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
*******ONFUNCTIONS & EVENTS*********
==================================*/

public OnPluginStart()
{
	// Commands
	RegConsoleCmd("sm_forcepicker", cmdForcePickers, "Forces random people from spec to pick players");
	
	// Quick Commands
	AddCommandListener(cmdSay, "say");
	AddCommandListener(cmdSay, "say_team");
}

/*==================================
*********CLIENT COMMANDS************
==================================*/

public Action:cmdForcePickers(client, args)
{
	cmdExecutor(client);
	return Plugin_Continue;
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
	if (IsClientInGame(client)) { cmdExecutor(client); }
}

cmdExecutor(client)
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
	
	ForcePickers();
}

/*==================================
*************MAIN CODE**************
==================================*/

ForcePickers()
{
	
	new redCount = GetRealTeamClientCount(2);
	new bluCount = GetRealTeamClientCount(3);
	
	new client1, client2;
	if (redCount == 0)
	{
		client1 = GetRandomPlayer(1); // Spectator
		ChangeClientTeam(client1, 2); // Red
		PrintCenterText(client1, "You have been chosen to pick for this match.");
	}
	else 
	{	// Get current player in the team
		client1 = GetRandomPlayer(1);
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
	
	CreateTimer(0.1, tmrMeleeStrip, client1);
	CreateTimer(0.1, tmrMeleeStrip, client2);
	
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
		if(((inGameOnly) ? IsClientInGame(i) : IsClientConnected(i)) && !IsFakeClient(i)) 
			clients++;
	}
	return clients;
}

GetRealTeamClientCount(team)
{
	new clients = 0;
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == team) 
			clients++;
	return clients;
}

GetRandomPlayer(team) 
{ 
    new clients[MaxClients+1], clientCount; 
    for (new i = 1; i <= MaxClients; i++) 
        if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == team) 
			clients[clientCount++] = i; 
    return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)]; 
}  