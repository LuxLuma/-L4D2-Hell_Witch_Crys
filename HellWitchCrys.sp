/*##########################
#Big Thanks for TimoCop    #
#for Helping me with silly #
#mistake i'm still learning#
#SourcePawn xD fact this is#
#my first programming      #
#language                  #
##########################*/
//you should checkout http://downloadtzz.firewall-gateway.com/ for free programs and basicpawn autocomplete func ect

//Remember SmLib to Compile using Point Hurt that Library very useful
//also i forgot to credit silver shot for using some of his director KVs :D

//1.1 Set AutoExecCfg(true) <--- my bad :D

//1.2 i changed some stuff and fixed some mistakes again and added devil scream for the witch death and Changed the point hurt bitflags to the tank being shot and hitting 1hp just to make sure :) enjoy also hint timeout is lower 

#include <sourcemod>
#include <sdktools>
#include <smlib>
#pragma semicolon 1

#define PLUGIN_VERSION "1.2"

#define ENABLE_AUTOEXEC false

#define g_sChargerMob	"player/charger/voice/warn/charger_warn_03.wav"
#define g_sChargerMob2	"player/charger/voice/idle/charger_lurk_21.wav"
#define g_sChargerMob3	"player/charger/voice/idle/charger_lurk_14.wav"
#define g_sChargerMob4	"player/charger/voice/idle/charger_lurk_18.wav"
#define g_sBoomerMob	"player/boomer/voice/alert/male_boomer_alert_15.wav"
#define g_sBoomerMob2	"player/boomer/voice/alert/male_boomer_alert_14.wav"
#define g_sBoomerMob3	"player/boomer/voice/warn/male_boomer_warning_16.wav"
#define g_sBoomerMob4	"player/boomer/voice/idle/male_boomer_lurk_08.wav"
#define g_sTankCall		"player/tank/voice/idle/tank_voice_04.wav"
#define g_sTankCall2	"player/tank/voice/idle/tank_voice_09.wav"
#define g_sTankCall3	"player/tank/voice/idle/tank_voice_02.wav"
#define g_sTankCallp3	"player/tank/voice/idle/tank_voice_01.wav"
#define g_sTankCall4	"player/tank/voice/pain/tank_fire_07.wav"
#define g_sHunterMob	"player/hunter/voice/alert/hunter_alert_02.wav"
#define g_sHunterMob2	"player/hunter/voice/alert/hunter_alert_04.wav"
#define g_sHunterMob3	"player/hunter/voice/alert/hunter_alert_03.wav"
#define g_sHunterMob4	"player/hunter/voice/alert/hunter_alert_05.wav"
#define g_sNothing		"npc/infected/alert/alert/alert44.wav"
#define g_sNothing2		"npc/witch/voice/retreat/horrified_4.wav"
#define g_sMobCall		"npc/infected/action/rage/malerage_50.wav"
#define g_sMobCall2		"npc/mega_mob/mega_mob_incoming.wav"
#define g_sMobCall3		"npc/witch/voice/attack/female_distantscream2.wav"
#define g_sWitchDeath	"npc/witch/voice/die/female_death_1.wav"
#define g_sWitchDeath2	"npc/witch/voice/attack/female_distantscream1.wav"
#define g_sWitchDeath3	"npc/witch/voice/attack/female_distantscream2.wav"
#define g_sWitchDeath4	"npc/witch/voice/retreat/horrified_3.wav"

new Handle:hCvar_HellWitch = INVALID_HANDLE;
new Handle:hCvar_TankMobCount = INVALID_HANDLE;
new Handle:hCvar_HunterMobCount = INVALID_HANDLE;
new Handle:hCvar_ChargerMobCount = INVALID_HANDLE;
new Handle:hCvar_BoomerMobCount = INVALID_HANDLE;
new Handle:hCvar_MobCall = INVALID_HANDLE;
new Handle:hCvar_DirHint = INVALID_HANDLE;
new Handle:hCvar_TankRush = INVALID_HANDLE;

new g_iTankMobCount;
new g_iHunterMobCount;
new g_iChargerMobCount;
new g_iBoomerMobCount;

new bool:g_bHW = false;
new bool:g_bMobCall = false;
new bool:g_bDirHint = false;
new bool:g_bTankRush = false;

public Plugin:myinfo = 
{
	name = "Hell_Witch_Crys",
	author = "Ludastar (Armonic)",
	description = "You'll think twice about messing with the witch c:",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/ArmonicJourney"
}

public OnPluginStart()
{	
	CreateConVar("Hell_Witch_Crys", PLUGIN_VERSION, " Version of Hell_Witch_Crys ", FCVAR_SPONLY|FCVAR_DONTRECORD);
	
	hCvar_HellWitch		=	CreateConVar("HW_Enable", "1", "Should We Enable the HellWitchCrys?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	hCvar_TankMobCount = 	CreateConVar("HW_TankCount", "6", "Amount In TankMob 0 = Disable", FCVAR_PLUGIN, true, 0.0, true, 31.0);
	hCvar_HunterMobCount = 	CreateConVar("HW_HunterCount", "4", "Amount In HunterMob 0 = Disable", FCVAR_PLUGIN, true, 0.0, true, 31.0);
	hCvar_ChargerMobCount = CreateConVar("HW_ChargerCount", "4", "Amount In ChangerMob 0 = Disable", FCVAR_PLUGIN, true, 0.0, true, 31.0);
	hCvar_BoomerMobCount = 	CreateConVar("HW_BoomerCount", "4", "Amount In BoomerMob 0 = Disable", FCVAR_PLUGIN, true, 0.0, true, 31.0);
	hCvar_MobCall		=	CreateConVar("HW_MobCall", "1", "Should We Enable Mobs?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	hCvar_DirHint		=	CreateConVar("HW_DirectorHint", "1", "Should We Enable Director Hints?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	hCvar_TankRush		=	CreateConVar("HW_TankRush", "1", "Should We Enable TankRush Globally?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	#if ENABLE_AUTOEXEC
	AutoExecConfig(true, "Hell_Witch_Crys");
	#endif
	
	//Use "HookConVarChange" to detect Cvars changes
	//To save some unessasary calculations we hook our own Cvars and save their values into variables
	HookConVarChange(hCvar_HellWitch, eConvarChanged);
	HookConVarChange(hCvar_TankMobCount, eConvarChanged);
	HookConVarChange(hCvar_HunterMobCount, eConvarChanged);
	HookConVarChange(hCvar_ChargerMobCount, eConvarChanged);
	HookConVarChange(hCvar_BoomerMobCount, eConvarChanged);
	HookConVarChange(hCvar_DirHint, eConvarChanged);
	HookConVarChange(hCvar_TankRush, eConvarChanged);
	CvarsChanged();

	HookEvent("witch_killed", eWitchKilled);
	HookEvent("tank_spawn", ePreTankRush);
	
}

public OnMapStart()
{	
	
	PrecacheSound(g_sWitchDeath, true);
	PrecacheSound(g_sWitchDeath2, true);
	PrecacheSound(g_sWitchDeath3, true);
	PrecacheSound(g_sWitchDeath4, true);
	PrecacheSound(g_sChargerMob, true);
	PrecacheSound(g_sChargerMob2, true);
	PrecacheSound(g_sChargerMob3, true);
	PrecacheSound(g_sChargerMob4, true);
	PrecacheSound(g_sBoomerMob, true);
	PrecacheSound(g_sBoomerMob2, true);
	PrecacheSound(g_sBoomerMob3, true);
	PrecacheSound(g_sBoomerMob4, true);
	PrecacheSound(g_sTankCall, true);
	PrecacheSound(g_sTankCall2, true);
	PrecacheSound(g_sTankCall3, true);
	PrecacheSound(g_sTankCallp3, true);
	PrecacheSound(g_sTankCall4, true);
	PrecacheSound(g_sHunterMob, true);
	PrecacheSound(g_sNothing, true);
	PrecacheSound(g_sNothing2, true);
	PrecacheSound(g_sMobCall ,true);
	PrecacheSound(g_sMobCall2 ,true);
	PrecacheSound(g_sMobCall3 ,true);
	SetConVarBounds(FindConVar("z_max_player_zombies"), ConVarBound_Upper, true, 32.0);
	SetConVarBounds(FindConVar("z_minion_limit"), ConVarBound_Upper, true, 32.0);
	SetConVarBounds(FindConVar("survivor_limit"), ConVarBound_Upper, true, 32.0);
	SetConVarBounds(FindConVar("survival_max_specials"), ConVarBound_Upper, true, 32.0);	
	CvarsChanged();
}

public eConvarChanged(Handle:hCvar, const String:sOldVal[], const String:sNewVal[])
{
	CvarsChanged();
}

CvarsChanged()
{
	g_bHW = GetConVarInt(hCvar_HellWitch) > 0;
	g_iTankMobCount = GetConVarInt(hCvar_TankMobCount);
	g_iHunterMobCount = GetConVarInt(hCvar_HunterMobCount);
	g_iChargerMobCount = GetConVarInt(hCvar_ChargerMobCount);
	g_iBoomerMobCount = GetConVarInt(hCvar_BoomerMobCount);
	g_bMobCall = GetConVarInt(hCvar_MobCall) > 0;
	g_bDirHint = GetConVarInt(hCvar_DirHint) > 0;
	g_bTankRush = GetConVarInt(hCvar_TankRush) > 0;
}

public eWitchKilled(Handle:hEvent, const String:strName[], bool:bDontBroadcast)
{
	if(g_bHW)
	{
		if(!GetEventBool(hEvent, "oneshot"))
		{
			new iWitch = GetEventInt(hEvent, "witchid");
			decl Float:fPos[3];
			GetEntPropVector(iWitch, Prop_Send, "m_vecOrigin", fPos);
			
			new iWitchKiller = GetClientOfUserId(GetEventInt(hEvent, "userid"));

			if(iWitchKiller > 0 && iWitchKiller <= MaxClients && IsClientInGame(iWitchKiller) && GetClientTeam(iWitchKiller) == 2)
			{
				switch(GetRandomInt(1, 5))
				{
					case 1:
					{
						EmitAmbientSound(g_sWitchDeath, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 1.0, 35);
					}
					case 2:
					{
						EmitAmbientSound(g_sWitchDeath2, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 1.0, 66);
					}
					case 3:
					{
						EmitAmbientSound(g_sWitchDeath3, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 1.0, 48);
					}
					case 4:
					{
						EmitAmbientSound(g_sWitchDeath4, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 1.0, 60);
					}
					case 5:
					{
						EmitAmbientSound(g_sWitchDeath, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 1.0, 130, 0.0);//my devil witch SFX 1.2 
						EmitAmbientSound(g_sWitchDeath, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.8, 120, 0.0);
						EmitAmbientSound(g_sWitchDeath, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.7, 110, 0.0);
						EmitAmbientSound(g_sWitchDeath, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.6, 90, 0.0);
						EmitAmbientSound(g_sWitchDeath, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.5, 80, 0.0);
						EmitAmbientSound(g_sWitchDeath, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.4, 70, 0.0);
						EmitAmbientSound(g_sWitchDeath, fPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.3, 60, 0.0);
					}
				}
				
				CreateTimer(3.2, MobCall, iWitchKiller, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action:MobCall(Handle:hTimer, any:iWitchKiller)
{
	new iClient = 0;
	for(new i = 1; i <= MaxClients; i++) 
	{
		//Get some random inGame client for executing cheats
		if(IsClientInGame(i))
		{
			//Got some!
			iClient = i;
			break; //Exit the For-Loop
		}
	}
	
	//Noone found? exit everything
	if(iClient < 1)
	return Plugin_Stop;
	
	decl String:sCapText[64];
	sCapText[0] = 0;
	decl String:sValues[32];
	sValues[0] = 0;
	decl String:sColour[13];
	sColour[0] = 0;
	decl String:sIcon[32];
	sIcon[0] = 0;

	
	switch(GetRandomInt(1, 7))
	{
		case 1:
		{
			if(g_bMobCall)
			{
				ClientCheatCommand(iClient, "z_spawn_old", "mob auto");
				switch(GetRandomInt(1, 4))
				{
					case 1:
					{
						EmitSoundToAllClients(g_sMobCall, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 95);
					}
					case 2:
					{
						EmitSoundToAllClients(g_sMobCall2, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 75);
					}
					case 3:
					{
						EmitSoundToAllClients(g_sMobCall2, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 130);
					}
					case 4:
					{
						EmitSoundToAllClients(g_sMobCall3, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
				}
			}
			
			strcopy(sIcon, sizeof(sIcon), "icon_skull");
			strcopy(sCapText, sizeof(sCapText), "Mob Incomming!\0");
			strcopy(sColour, sizeof(sColour), "125 160 110");
		}
		case 2:
		{
			if(g_iTankMobCount > 0)
			{
				for(new x = 1; x <= g_iTankMobCount; x++)
					ClientCheatCommand(iClient, "z_spawn_old", "tank auto");
				
				switch(GetRandomInt(1, 4))
				{
					case 1:
					{
						EmitSoundToAllClients(g_sTankCall, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 2:
					{
						EmitSoundToAllClients(g_sTankCall2, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 3:
					{
						EmitSoundToAllClients(g_sTankCall3, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
						CreateTimer(2.5, TankCallp3, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
					}
					case 4:
					{
						EmitSoundToAllClients(g_sTankCall4, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
				}
				
				strcopy(sIcon, sizeof(sIcon), "icon_skull");
				strcopy(sCapText, sizeof(sCapText), "Tank Mob Incomming!\0");
				strcopy(sColour, sizeof(sColour), "255 1 1");
			}
		}
		case 3:
		{
			if(g_iChargerMobCount > 0)	
			{
				for(new x = 1; x <= g_iChargerMobCount; x++)
					ClientCheatCommand(iClient, "z_spawn_old", "charger auto");
					
				switch(GetRandomInt(1, 4))
				{
					case 1:
					{
						EmitSoundToAllClients(g_sChargerMob, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 2:
					{
						EmitSoundToAllClients(g_sChargerMob2, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 3:
					{
						EmitSoundToAllClients(g_sChargerMob3, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 4:
					{
						EmitSoundToAllClients(g_sChargerMob4, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
				}

				strcopy(sIcon, sizeof(sIcon), "icon_skull");
				strcopy(sCapText, sizeof(sCapText), "Charger Mob Incomming!\0");
				strcopy(sColour, sizeof(sColour), "1 1 255");
			}
		}
		case 4:
		{
			if(g_iHunterMobCount > 0)	
			{
				for(new x = 1; x <= g_iChargerMobCount; x++)
					ClientCheatCommand(iClient,"z_spawn_old", "hunter auto");
					
				switch(GetRandomInt(1, 4))
				{
					case 1:
					{
						EmitSoundToAllClients(g_sHunterMob, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 2:
					{
						EmitSoundToAllClients(g_sHunterMob2, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 3:
					{
						EmitSoundToAllClients(g_sHunterMob3, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 4:
					{
						EmitSoundToAllClients(g_sHunterMob4, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
				}					
					
				strcopy(sIcon, sizeof(sIcon), "icon_skull");
				strcopy(sCapText, sizeof(sCapText), "Hunter Mob Incomming!\0");
				strcopy(sColour, sizeof(sColour), "255 100 255");
			}
		}
		case 5:
		{
			if(g_iBoomerMobCount > 0)	
			{
				for(new x = 1; x <= g_iBoomerMobCount; x++)
					ClientCheatCommand(iClient, "z_spawn_old", "boomer auto");
				
				switch(GetRandomInt(1, 4))
				{
					case 1:
					{
						EmitSoundToAllClients(g_sBoomerMob, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 2:
					{
						EmitSoundToAllClients(g_sBoomerMob2, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 3:
					{
						EmitSoundToAllClients(g_sBoomerMob3, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
					case 4:
					{
						EmitSoundToAllClients(g_sBoomerMob4, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
					}
				}		
				
				strcopy(sIcon, sizeof(sIcon), "icon_skull");
				strcopy(sCapText, sizeof(sCapText), "Boomer Mob Incomming!\0");
				strcopy(sColour, sizeof(sColour), "1 255 1");
			}
		}
		case 6:
		{	
			EmitSoundToAllClients(g_sNothing2, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 85);
			
			strcopy(sIcon, sizeof(sIcon), "icon_info");
			strcopy(sCapText, sizeof(sCapText), "HellWitch's Don't Hellscream When Crowned\0");
			strcopy(sColour, sizeof(sColour), "255 255 255");
			
		}
		case 7:
		{
			EmitSoundToAllClients(g_sNothing, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);
			
			strcopy(sIcon, sizeof(sIcon), "icon_info");
			strcopy(sCapText, sizeof(sCapText), "HellWitch Crys Can call SpecialMobs\0");
			strcopy(sColour, sizeof(sColour), "255 255 255");
		}
	}
	
	if(g_bDirHint && sCapText[0] != 0 && IsClientInGame(iWitchKiller))
	{
		new entity = CreateEntityByName("env_instructor_hint");
		FormatEx(sValues, sizeof(sValues), "hint%d", iWitchKiller);
		DispatchKeyValue(iWitchKiller, "targetname", sValues);
		DispatchKeyValue(entity, "hint_target", sValues);

		Format(sValues, sizeof(sValues), "4");//1.2
		DispatchKeyValue(entity, "hint_timeout", sValues);
		DispatchKeyValue(entity, "hint_range", "999.0");
		DispatchKeyValue(entity, "hint_icon_onscreen", sIcon);
		DispatchKeyValue(entity, "hint_caption", sCapText);
		DispatchKeyValue(entity, "hint_color", sColour);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "ShowHint");

		Format(sValues, sizeof(sValues), "OnUser1 !self:Kill::4:1");//1.2
		SetVariantString(sValues);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
	
	return Plugin_Stop;
}

public ePreTankRush(Handle:hEvent, const String:sname[], bool:bDontBroadcast)
{
	if(g_bTankRush)
	{	
		new iTank =  GetEventInt(hEvent, "tankid");
		if(iTank > 0 && iTank <= MaxClients && IsClientInGame(iTank) && GetClientTeam(iTank) == 3)
		{
			//Create unique UserID via GetClientUserId for easy checking if the client has disconnected
			//If the tank disconnected in the 0.1 sec the unique userID becomes invalid, perfect, no need to hooking Connect/Disconnect and no bugs when the client index gets replaced by another player who isn't a tank by re-joining
			CreateTimer(0.1, TankRush, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action:TankRush(Handle:hTimer, any:iUserID)
{
	//Convert UserID to Client Index again
	//If the Tank client disconnects in the meantime while the Timer was "sleepin", GetClientOfUserId will return -1
	new iTank = GetClientOfUserId(iUserID);
	
	if(iTank < 1 || iTank > MaxClients || !IsClientInGame(iTank))
	return Plugin_Stop;
	
	new iClient = 0;
	for(new i = 1; i <= MaxClients; i++) 
	{
		if(IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i)) 
		{
			iClient = i;
			break; //Exit the For-Loop
		}
	}

	if(iClient < 1)
	return Plugin_Stop;
	
	Entity_Hurt(iTank, 1, iClient, DMG_BULLET);//1.2 1hp is not so bad if it bothers you then make the tanks hp bigger by 1
	
	return Plugin_Stop;
}

stock ClientCheatCommand(iClient, String:sArg1[], const String:sArg2[]="", const String:sArg3[]="", const String:sArg4[]="")
{
    if(IsFakeClient(iClient)) {
        static iCommandFlags;
        iCommandFlags = GetCommandFlags(sArg1);
        SetCommandFlags(sArg1, iCommandFlags & ~(1<<14));
 
        FakeClientCommand(iClient, "%s %s %s %s", sArg1, sArg2, sArg3, sArg4);
 
        SetCommandFlags(sArg1, iCommandFlags);
    }
    else {
        static iUserFlags;
        iUserFlags = GetUserFlagBits(iClient);
        SetUserFlagBits(iClient, (1<<14));
 
        static iCommandFlags;
        iCommandFlags = GetCommandFlags(sArg1);
        SetCommandFlags(sArg1, iCommandFlags & ~(1<<14));
 
        FakeClientCommand(iClient, "%s %s %s %s", sArg1, sArg2, sArg3, sArg4);
 
        SetCommandFlags(sArg1, iCommandFlags);
        SetUserFlagBits(iClient, iUserFlags);
    }
}


EmitSoundToAllClients(const String:sample[], entity = SOUND_FROM_PLAYER, channel = SNDCHAN_AUTO, level = SNDLEVEL_NORMAL, flags = SND_NOFLAGS, Float:volume = SNDVOL_NORMAL, pitch = SNDPITCH_NORMAL, speakerentity = -1, const Float:origin[3] = NULL_VECTOR, const Float:dir[3] = NULL_VECTOR, bool:updatePos = true, Float:soundtime = 0.0)
{
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && !IsFakeClient(i))
			EmitSoundToClient(i, sample, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}

public Action:TankCallp3(Handle:hTimer)
{
	EmitSoundToAllClients(g_sTankCallp3, SOUND_FROM_PLAYER, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, 100);

}

