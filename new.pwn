//============================= [ Инклуды ] ===============================
#include <a_samp>
#include <a_actor>
#include <a_mysql>
#include <fix>
#include <streamer>
#include <Pawn.Regex>
#include <sscanf2>
#include <objects>
#include <removeobjects>
#include <fix_Kick>
#include <foreach>
#include <MD5>
#include <crashdetect>
#include <playerprogress>
#include <time_t>
#include <weapon-config>
#include <Pawn.CMD>
//============================== [ Дефайны ] ===============================
#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll
#define SPD ShowPlayerDialog
#define DSI DIALOG_STYLE_INPUT
#define DSM DIALOG_STYLE_MSGBOX
#define DSL DIALOG_STYLE_LIST
#define DSP DIALOG_STYLE_PASSWORD
#define DSTH DIALOG_STYLE_TABLIST_HEADERS
//------------------------ [ Настройки систем ] ---------------------------
#define MAX_FRACTIONS 25 // Максимальное количество фракций
#define MAX_HOUSES 1000 // Максимальное количество домов
#define MAX_WORKS 50 // Максимальное количество работ
#define MAX_GANGZONES 131 // Максимальное количество гангзон
#define MAX_QUESTIONS 100 // Максимальное количество вопросов
#define BYTES_PER_CELL (cellbits / 8) // Используется стоком SendMes
//========================== [ Настройки мода ] ============================
#define SERVER_NAME "Role Play | Разработка"
#define SERVER_MODE "RP"
//========================= [ База данных MySQL ] ==========================
new MySQL:dbHandle;
/*
#define MYSQL_HOST "localhost"
#define MYSQL_USER "root"
#define MYSQL_BASE "gs52494"
#define MYSQL_PASS ""
*/
#define MYSQL_HOST "46.174.50.7"
#define MYSQL_USER "u32937_alexeyrulew"
#define MYSQL_BASE "u32937_alliant"
#define MYSQL_PASS "a15b121975"
//============================= [ Массивы ] ================================
enum PlayerInformation
{
	pID, // ID аккаунта
	pName[MAX_PLAYER_NAME], // Имя персонажа
	pPassword[32], // Пароль от аккаунта
	pEmail[64], // Электронная почта аккаунта
	pAdmin, // Права администрирования
	pSupport, // Права саппорта
	pReferal[MAX_PLAYER_NAME], // Ник пригласившего игрока
	pGender, // Пол персонажа
	pLevel, // Уровень персонажа
	pExp, // EXP персонажа
	pTime, // Отыгранное время за час
	pSkin, // Скин персонажа
	pRegData[16], // Дата регистрации
	pRegIP[16], // IP при регистрации
	pMoney, // Наличные деньги
	pFraction, // Фракция игрока
	pRank, // Ранг во фракции
	pFractionSkin, // Фракционный скин
	pBankMoney, // Деньги в банке
	pCarLic, // Лицензия на авто
	pBikeLic, // Лицензия на мотоциклы
	pAirLic, // Лицензия на воздушный ТС
	pBoatLic, // Лицензия на лодки
	pFishLic, // Лицензия на рыбалку
	pBizLic, // Лицензия на бизнес
	pGunLic, // Лицензия на оружие
	Float:pHP, // Здоровье игрока
	pDrugs, // Наркотики у игрока
	pMaterials, // Материалы у игрока
	pHouse, // Дом игрока
	pSpawn, // Место возрождения
	pCarModel, // Модель автомобиля
	pCarColor1, // Цвет автомобиля [1]
	pCarColor2, // Цвет автомобиля [2]
	pMute, // Время затычки чата (в секундах)
	pWarn, // Количество варнов на аккаунте
	pWanted, // Уровень розыска
	pTimeWanted, // Время заключения
	pCopKey, // Наличие ключей от камеры
}
new PlayerInfo[MAX_PLAYERS][PlayerInformation];

enum VehicleInformation
{
	vFuel, // Топливо в машине
	vMats, // Маты в машине (для вояк и банд)
	vMaterials, // материалы которые везут на базу
	vLoading, // машина в процессе загрузки
}
new VehicleInfo[MAX_VEHICLES][VehicleInformation];

enum GangZoneInformation
{
	gID, // ID ганг зоны
	gZone, // Создание гангзоны
	Float: gCoords[4], // Координаты территории
	gOwner, // Банда, владеющая территорией
	gAttacker, // Банда, пытающаяся захватить территорию
}
new GZInfo[MAX_GANGZONES][GangZoneInformation];
new TotalGZ; // Общее количество гангзон

enum QuestionsInformation
{
	qID, // ID вопроса в /ask
	qName[MAX_PLAYER_NAME], // Никнейм игрока
	qQuestion[128], // Вопрос игрока
}
new QInfo[MAX_QUESTIONS][QuestionsInformation];
new TotalQuestions;

enum AdminInformation
{
	aID, // ID админа в таблице
	aName[MAX_PLAYER_NAME], // Никнейм администратора
	aPassword[16], // Пароль от админ-панели
	aLastOnline[16], // Последняя дата захода
	aLogged, // Авторизация администратора
	aSkin, // Скин администратора
}
new AdminInfo[MAX_PLAYERS][AdminInformation];

enum SupportInformation
{
	sID, // ID саппорта в таблице
	sName[MAX_PLAYER_NAME], // Никнейм саппорта
	sAnswer, // Количество ответов саппорта
}
new SupportInfo[MAX_PLAYERS][SupportInformation];

enum HouseInformation
{
	hID, // ID дома
	hOwned, // Имеет ли дом владельца
	hOwner[24], // Ник владельца дома
	hCost, // Стоимость дома
	hPickup, // Пикап дома
	hIcon, // Иконка дома
	hType[24], // Тип дома
	hClass, // Класс дома
	hRoomAmount, // Количество комнат
	hRent, // Квартплата за дом
	Float:hEnterX, // Координата X входа в дом
	Float:hEnterY, // Координата Y входа в дом
	Float:hEnterZ, // Координата Z входа в дом
	hInterior, // Интерьер дома
	Float:hiEnterX, // Координата X после входа в дом
	Float:hiEnterY, // Координата Y после входа в дом
	Float:hiEnterZ, // Координата Z после входа в дом
	Float:hiEnterAngle, // Координата A (поворота) после входа в дом
	Float:hExitX, // Координата X после выхода из дома
	Float:hExitY, // Координата Y после выхода из дома
	Float:hExitZ, // Координата Z после выхода из дома
	Float:hExitAngle, // Координата A (поворота) после выхода из дома
	hLocked, // Статус закрытия дома
	Text3D:hText3D, // Создание 3D текста
	hGarage, // Количество гаражных мест в доме
	hPay[16], // На сколько дней оплачен дом
	hMedKit, // Количество аптечек в доме
	Float:hWardrobeX, // Координата X шкафа в доме
	Float:hWardrobeY, // Координата Y шкафа в доме
	Float:hWardrobeZ, // Координата Z шкафа в доме
	Text3D:hWardrobeText, // 3D текст шкафа
	hStoreMaterials, // Материалы в шкафу
	hStoreDrugs, // Наркотики в шкафу
	hCar, // Автомобиль
	Float:hCarPosX, // Координата X автомобиля
	Float:hCarPosY, // Координата Y автомобиля
	Float:hCarPosZ, // Координата Z автомобиля
	Float:hCarAngle, // Координата угла автомобиля
}
new HouseInfo[MAX_HOUSES][HouseInformation];
new TotalHouses; // Общее количество домов

enum WorkInformation
{
	wID, // ID работы
	wName[64], // Название работы
	wSalary, // Зарплата на работе
	wSalary2, // Зарплата на работе [2]
	wSalary3, // Зарплата на работе [3]
	wLastChange, // Последнее изменение зарплаты на работе
}
new WorkInfo[MAX_WORKS][WorkInformation];

enum FractionInformation
{
	fID, // ID фракции
	fName[50], // Название фракции
	fLeader[24], // Лидер организации
	fBank, // Баланс банка организации
	fMaterials, // Материалов на складе фракции
	fInvRang, // Ранг для инвайта
	fSkin1, // Скин фракции [1]
	fSkin2, // Скин фракции [2]
	fSkin3, // Скин фракции [3]
	fSkin4, // Скин фракции [4]
	fSkin5, // Скин фракции [5]
	fSkin6, // Скин фракции [6]
	fSkin7, // Скин фракции [7]
	fSkin8, // Скин фракции [8]
	fSkin9, // Скин фракции [9]
	fSkinRank1, // Ранг скина фракции [1]
	fSkinRank2, // Ранг скина фракции [2]
	fSkinRank3, // Ранг скина фракции [3]
	fSkinRank4, // Ранг скина фракции [4]
	fSkinRank5, // Ранг скина фракции [5]
	fSkinRank6, // Ранг скина фракции [6]
	fSkinRank7, // Ранг скина фракции [7]
	fSkinRank8, // Ранг скина фракции [8]
	fSkinRank9, // Ранг скина фракции [9]
	fRang1[32], // Название ранга во фракции [1]
	fRang2[32], // Название ранга во фракции [2]
	fRang3[32], // Название ранга во фракции [3]
	fRang4[32], // Название ранга во фракции [4]
	fRang5[32], // Название ранга во фракции [5]
	fRang6[32], // Название ранга во фракции [6]
	fRang7[32], // Название ранга во фракции [7]
	fRang8[32], // Название ранга во фракции [8]
	fRang9[32], // Название ранга во фракции [9]
	fRang10[32], // Название ранга во фракции [10]
	fRang11[32], // Название ранга во фракции [11]
	fRang12[32], // Название ранга во фракции [12]
	fRang13[32], // Название ранга во фракции [13]
	fRang14[32],// Название ранга во фракции [14]
	fRang15[32] // Название ранга во фракции [15]
}
new FracInfo[MAX_FRACTIONS][FractionInformation];

enum sDialogs
{
	DLG_NONE,
	DLG_REGPASSWORD,
	DLG_REGEMAIL,
	DLG_REGREFERAL,
	DLG_REGRULES,
	DLG_REGGENDER,
	DLG_AUTHORIZATION,
	DLG_ADMINLOGIN,
	DLG_SHOW_LICENS,
	DLG_SETLEADER,
	DLG_LSPDSTART,
	DLG_UNLOAD_SANG,
	DLG_LOADERINVITE,
	DLG_SANGSTART,
	DLG_SANGGUN,
	DLG_LSPDGUN,
	DLG_INVITE,
	DLG_LSPDCLOTHES,
	DLG_HOUSENOWNER, // Дом без владельца
	DLG_HOUSEOWNER, // Дом с владельцем
	DLG_ALTHOUSEMENU,
	DLG_SETSPAWN,
	DLG_MAINMENU,
	DLG_MAINMENU_ADMIN,
	DLG_LEADER_MENU,
	DLG_LEADER_MENU_RANG,
	DLG_RED_RANG,
	DLG_STATS,
	DLG_RED_NAME,
	DLG_CARM,
	DLG_FMATS,
	DLG_FMATS_SET,
	DLG_TPLIST,
	DLG_ASK,
	DLG_ASK_SEND,
	DLG_TPLIST_BASE,
	DLG_WARDROBEMENU,
	DLG_WMATERIALS,
	DLG_SPAWNCARS,
	DLG_REPORT,
	DLG_WDRUGS,
	DLG_WSETMATERIALS,
	DLG_WSETDRUGS,
	DLG_CREATEHOUSECLASS,
	DLG_CREATEHOUSEINT,
	DLG_CREATEHOUSECOST,
	WORK_BUILDER,
	DLG_MANAGER_MENU,
	DLG_MANAGER_FRAK,
	DLG_MANAGER_FRAK_BANK
}
//============================= [ Переменные ] =============================
//-------------------------------- [ Рекон ] -------------------------------
new SpecAd[MAX_PLAYERS], Float: SpecPos[MAX_PLAYERS][3]; // Ваше положение для Spectate — 0 = X, 1 = Y, 2 = Z
new PlayerMute[MAX_PLAYERS]; // Время мута
new PlayerAFK[MAX_PLAYERS]; // Переменная, отвечающая за AFK
new FollowTimer[MAX_PLAYERS]; // Таймер /follow
new Escort[MAX_PLAYERS]; // Ид конвоира при /follow
//new ProSport[MAX_PLAYERS]; // Ускорение тюннинг
new Timer_Tazer[MAX_PLAYERS];
new RedName_String[MAX_PLAYER_NAME+1];
//------------------------ [ Динамические чекпоитны ] ----------------------
new rent_car[MAX_PLAYERS]; // Аренда авто на спавне
//------------------------- [ Движущиеся обьекты ] -------------------------
new gatestatus[11]; // статус открытия ворот
new gate[11]; //ворота,шлакбаумы,двери
//--------------------- [ Всё для поставок SANG ] ------------------
new loadzone; // пикап подбора матов
new Text3D: loadzone3dtext; // 3д текст подбора матов
new submarine; // Подлодка
new Farmcar_pickup[MAX_VEHICLES];
new Text3D: unloadzone3dtext[MAX_VEHICLES]; // 3д текст сброса матов
new submarine_mats = 500000;
new submarinestat = 0; // статус вызова подлодки
new SOStime = 0; // Минуты экстренного вызова
new morder = 0; // статус Экстренный вызов
new time_call = 0; // Время экстренного вызова
//---------------------------- [ Транспорт ] -------------------------------
new lspdcar[30]; // Транспорт фракции LSPD
new rifacar[9]; // Транспорт фракции Rifa
new sangcar[34]; // Транспорт фракции SANG
new vagoscar[7]; // Транспорт фракции Vagos
new grovecar[8]; // Транспорт фракции Grove
new ballascar[8]; // Транспорт фракции Ballas
new azteccar[7]; // Транспорт фракции Aztec
new ascar[12]; // Транспорт для Автошколы
new loadercar[10]; // Транспорт для грузчиков
//------------------------- [ Пикапы ] -----------------------------
new healthspls; // Чекпоинт выдачи ХП на спавне ЛС
new lspdenter[2]; // Вход в LSPD
new victimenter[2];
new loaderinvite;
new lspdexit[2]; // Выход из LSPD
new lspd[1];
new SANG[8];
new BALLAS[2];
new GROVE[2];
new VAGOS[2];
new AZTEC[2];
new DRUGDEN[2];
new MayorPic[2];
new AUTOSCHOOL[4];
new LOADERPIC;
new lspdinvite; // Начало работы LSPD / Переодевание
new rifaenter; // Вход в здание Rifa
new rifaexit; // Выход из здания Rifa
//------------------------- [ Актеры ] -----------------------------
new actorintro; // Актер на интро
new autoschoolactor; // Инструктор Джош в автошколе
//------------------------ [ Текстдравы ] --------------------------
new Text:damage[MAX_PLAYERS][2];
new Text:selectskin_TD[12]; // Текстдрав выбора скина
new Text:LogoAlliant_TD[4]; // Текстдрав логотипа
new Text:rentcar_TD[23]; // Аренда транспорта на спавне
new Text:selectskinloader[10]; // Выбор скина на грузчиках
//--------------------------- [ Без категории ] ----------------------------
new exptonextlevel = 4; // Сколько нужно EXP до следующего LVL'a
new redrang = 0;
//================================ [ Цвета ] ===============================
#define COLOR_WHITE 	0xFFFFFFFF
#define COLOR_PURPLE 	0xC2A2DAAA
#define COLOR_INFO 		0xEE82EEFF
#define COLOR_ERROR		0xD90000FF
#define COLOR_ADMIN		0xFF6347AA
#define COLOR_GREY		0xA9A9A9FF
#define COLOR_DARK_BLUE 0xFF69B4FF
#define COLOR_YELLOW	0xFFFF00FF

main()
{
	print("_______________________________________________________");
	print(" server by: James_Awoken, Ghost                  ");
	print(" project © 2022, inc. all rights reserved.             ");
	print("_______________________________________________________");
}

public OnGameModeInit()
{
	ObjectLoad();
	ConnectMySQL();
	CreateTextDraws();
	PickupLoad();
	DisableInteriorEnterExits();
	LimitGlobalChatRadius(15.0);
	LimitPlayerMarkerRadius(45.0);
	EnableStuntBonusForAll(0);
	SendRconCommand("hostname "SERVER_NAME"");
	SetGameModeText(""SERVER_MODE"");
	ManualVehicleEngineAndLights();
	CreateVehicles();
	CreateObjects();
	SetGravity(0.009);
	gatestatus = {0,0,0,0,0,0,0,0,0,0,0}; // Приравниваем значения ворот к нулю.
	//=========================== [ Установка времени ] ============================
	new hour;
	gettime(hour);
	SetWorldTime(hour); // Установка мирового времени на сервере
	//================================ [ Актёры ] =====================================
	actorintro = CreateActor(97, 2134.1243,-101.5932,1.1565,132.7034); // Актёр на заставке
	ApplyActorAnimation(actorintro, "BEACH", "PARKSIT_M_LOOP", 4.0, 1, 0, 0, 0, 0);
	SetActorVirtualWorld(actorintro, 125);
	autoschoolactor = CreateActor(240, -2035.0952,-117.4809,1035.1719,270.3484); // Инструктор в Автошколе
	SetActorVirtualWorld(autoschoolactor, 3);
	//============================= [ Загрузка таблиц ] ================================
	mysql_tquery(dbHandle, "SELECT * FROM `fractions`", "LoadFractions", "");
	mysql_tquery(dbHandle, "SELECT * FROM `houses`", "LoadHouses", "");
	mysql_tquery(dbHandle, "SELECT * FROM `works`", "LoadWorks", "");
	mysql_tquery(dbHandle, "SELECT * FROM `gangzone`", "LoadGangZones", "");
	//================================= [ Таймеры ] ====================================
	SetTimer("ThirtySecondUpdate", 30000, true);
	SetTimer("SecondUpdate", 1000, true);
	SetTimer("MinuteUpdate", 60000, true);
	//===================================== [ Машины ] =================================
	for(new i = 0; i < MAX_VEHICLES; i++)
	{
		VehicleInfo[i][vFuel] = 100;
		VehicleInfo[i][vMats] = 0;
	}
	//=========================== [ Динамические чекпоинты ] ===========================
	foreach(new i: Player)
	{
		rent_car[i] = CreateDynamicCP(1130.2950, -1752.0189, 13.5802, 0.5, 0, 0, i, 15.0);
	}
	//================================= [ 3D тексты ] ===================================
	Create3DTextLabel("{FFFFFF}[ {E7B816}Аренда транспорта {FFFFFF}]", 0xFFFFFFFF, 1130.2950, -1752.0189, 13.5802, 8.0, 0, 0);
	Create3DTextLabel("{FFFFFF}[ {E7B816}Полицейский участок LS {FFFFFF}]", 0xFFFFFFFF, 1555.4999,-1675.5962,16.1953 + 0.7, 8.0, 0, 0);
	Create3DTextLabel("{FFFFFF}[ {E7B816}Казарма {FFFFFF}]", 0xFFFFFFFF, -1107.0048,-1672.4940,76.3672 + 0.7, 8.0, 0, 0);
	Create3DTextLabel("{FFFFFF}[ {E7B816}Автошкола {FFFFFF}]", 0xFFFFFFFF, 739.0128,-1418.5146,13.5234 + 0.7, 8.0, 0, 0);
	Create3DTextLabel("{FFFFFF}[ {E7B816}Штаб {FFFFFF}]", 0xFFFFFFFF, -1108.9335,-1641.7371,76.3672 + 0.7, 8.0, 0, 0);
	Create3DTextLabel("{FFFFFF}[ {E7B816}Мэрия {FFFFFF}]", 0xFFFFFFFF, 1481.0587,-1772.3138,18.7958 + 0.7, 8.0, 0, 0);
	Create3DTextLabel("{FFFFFF}[ {E7B816}Наркопритон {FFFFFF}]", 0xFFFFFFFF, 2165.9128, -1671.2115, 15.0732 + 0.7, 8.0, 0, 0);
	Create3DTextLabel("{FFFFFF}[ {E7B816}Главный склад и тир {FFFFFF}]", 0xFFFFFFFF, -1065.0961,-1582.3878,76.3672 + 0.7, 8.0, 0, 0);
	Create3DTextLabel("Дейв", 0xFFFFFFFF, 1281.5895,-1259.8771,13.5384 + 2, 8.0, 0, 0);
	Create3DTextLabel("{FFFFFF}Взятие груза", 0xFFFFFFFF, 2682.7825, -2263.35, 12.0966, 7.0, 0, 0);
	//------------------------ Автошкола ------------------------------
	Create3DTextLabel("{FFFFFF}[ Инструктор Джош ]", 0xFFFFFFFF, -2035.0952, -117.4809, 1035.1719 + 1.0, 6.0, 3, 0);
	//============================= [ Динамические иконки ] =============================
	CreateDynamicMapIcon(1552.8314, -1675.9022, 16.1953, 30, 0); // LSPD
	CreateDynamicMapIcon(2183.7136, -1808.9355, 13.3744, 61, 0); // Rifa
	CreateDynamicMapIcon(2779.6248, -1617.9624, 10.9219, 60, 0); // Vagos
	CreateDynamicMapIcon(2489.5396, -1670.1710, 13.3359, 62, 0); // Grove
	CreateDynamicMapIcon(2644.4338, -2007.4794, 13.3828, 59, 0); // Ballas
	CreateDynamicMapIcon(1679.6399, -2111.4336, 13.5469, 58, 0); // Aztec
	CreateDynamicMapIcon(739.0323, -1415.1632, 13.5170, 36, 0); // AutoSchool
	return 1;
}

public OnGameModeExit()
{
	static const fmt_query[] = "UPDATE `admins` SET `aLogged` = '0'";
	mysql_tquery(dbHandle, fmt_query);
	mysql_close(dbHandle);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(GetPVarInt(playerid, "pLogged") == 1)
	{
		SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1);
		SpawnPlayer(playerid);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	ZeroCharacter(playerid);
	ObjectRemove(playerid);
	PreloadAnim(playerid);
	SetPVarInt(playerid, "Escorted", -1);
	SetPVarInt(playerid, "OnEscort", -1);
	TogglePlayerSpectating(playerid, 1);
	GetPlayerName(playerid, PlayerInfo[playerid][pName], MAX_PLAYER_NAME);
	SetTimerEx("ConnectPlayerToServer", 750, false, "i", playerid);
	//========================= [ Дамаг-информер ] =======================
	damage[playerid][0] = TextDrawCreate(137.500000, 349.416625, "Nick Weapon +damage");
	TextDrawLetterSize(damage[playerid][0], 0.226874, 0.859166);
	TextDrawAlignment(damage[playerid][0], 1);
	TextDrawColor(damage[playerid][0], 16711935);
	TextDrawSetShadow(damage[playerid][0], 0);
	TextDrawSetOutline(damage[playerid][0], 1);
	TextDrawBackgroundColor(damage[playerid][0], 51);
	TextDrawFont(damage[playerid][0], 1);
	TextDrawSetProportional(damage[playerid][0], 1);

	damage[playerid][1] = TextDrawCreate(448.500000, 346.333251, "Nick Weapon -damage");
	TextDrawLetterSize(damage[playerid][1], 0.209374, 0.934999);
	TextDrawAlignment(damage[playerid][1], 1);
	TextDrawColor(damage[playerid][1], 16777215);
	TextDrawSetShadow(damage[playerid][1], 0);
	TextDrawSetOutline(damage[playerid][1], 1);
	TextDrawBackgroundColor(damage[playerid][1], 51);
	TextDrawFont(damage[playerid][1], 1);
	TextDrawSetProportional(damage[playerid][1], 1);
	//=================================================================
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
 	KillTimer(PlayerMute[playerid]);
	if(PlayerInfo[playerid][pCarModel] != -1)
	{
		new HouseID = PlayerInfo[playerid][pHouse] - 1;
		DestroyVehicle(HouseInfo[HouseID][hCar]);
	}
	if(PlayerInfo[playerid][pAdmin] >= 1)
	{
		static const fmt_query[] = "UPDATE `admins` SET `aLogged` = '0' WHERE `aName` = '%s'";
		new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
		format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pName]);
		mysql_tquery(dbHandle, query);
	}
	SaveAccount(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	SetPlayerWantedLevel(playerid, PlayerInfo[playerid][pWanted]);
	SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
	PlayerAFK[playerid] = 0;
	// if(GetPVarInt(playerid, "Cuffed") == 1)
	// {
	// 	SetPlayerPos(playerid, 1477.1868,1057.2545,-50.4020);
	// 	SetPlayerFacingAngle(playerid, 90.9791);
	// 	SetPlayerInterior(playerid, 1);
	// 	SetPlayerVirtualWorld(playerid, 1);
	// 	SetPlayerWantedLevel(playerid, 0);
	// 	RemovePlayerAttachedObject(playerid, 0);
	// 	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
	//     TogglePlayerControllable(playerid, 1);
	//     SetPVarInt(playerid, "Cuffed", 0);
	//     SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
	//     SetCameraBehindPlayer(playerid);
	//     return 1;
	// }
	if(GetPVarInt(playerid, "RegistrationSkin") == 1)
	{
		SetPVarInt(playerid, "RegistrationSkin", 0);
		SetPVarInt(playerid, "RegistrationSkinConfirm", 1);
		SetPlayerPos(playerid, 2152.4675, -85.9747, 2.7164);
		SetPlayerFacingAngle(playerid, 130.7099);
		SelectTextDraw(playerid, 0x3896D3FF);
		InterpolateCameraPos(playerid, 2133.793212, -94.768066, 1.255280, 2148.530761, -89.176223, 3.305278, 2500);
		InterpolateCameraLookAt(playerid, 2135.047607, -101.182060, 2.095280, 2152.497070, -85.952064, 3.495278, 2500);
		TogglePlayerControllable(playerid, 0);
		for(new i = 0; i < 12; i++) TextDrawShowForPlayer(playerid, Text:selectskin_TD[i]);
		switch(PlayerInfo[playerid][pGender])
	  	{
	  		case 1: { SetPlayerSkin(playerid, 7); SetPVarInt(playerid, "SelectSkinRegistration", 7); }
	  		case 2: { SetPlayerSkin(playerid, 41); SetPVarInt(playerid, "SelectSkinRegistration", 41); }
	  	}
	}
	if(PlayerInfo[playerid][pGender] == 0 && GetPVarInt(playerid, "RegistrationSkin") == 0)
	{
		SetPVarInt(playerid, "RegistrationSkin", 1);
 	    SpawnPlayer(playerid);
 	    switch(PlayerInfo[playerid][pGender])
		{
		    case 1: { SetPlayerSkin(playerid, 7); SetPVarInt(playerid, "SelectSkinRegistration", 7); }
	  		case 2: { SetPlayerSkin(playerid, 41); SetPVarInt(playerid, "SelectSkinRegistration", 41); }
		}
		return 1;
	}
	if(GetPVarInt(playerid, "Registration") == 1)
	{
		SetPlayerVirtualWorld(playerid, 0);
 	    SetPlayerInterior(playerid, 0);
 	    SetCameraBehindPlayer(playerid);
		SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
		CancelSelectTextDraw(playerid);
		TogglePlayerControllable(playerid, 1);
		for(new i = 0; i < 12; i++)
		{
			TextDrawHideForPlayer(playerid, selectskin_TD[i]);
		}
		SetPVarInt(playerid, "Registration", 0);
	}
	if(GetPVarInt(playerid, "RegistrationSkin") == 0 && GetPVarInt(playerid, "Registration") == 0 && GetPVarInt(playerid, "RegistrationSkinConfirm") == 0)
	{
		if(GetPVarInt(playerid, "FirstLogged") == 0)
		{
			new string[128];
			format(string, sizeof(string), "~w~WELCOME~n~~p~%s", PlayerInfo[playerid][pName]);
			GameTextForPlayer(playerid, string, 5000, 1);
			SetPVarInt(playerid, "FirstLogged", 1);
		}
		switch(PlayerInfo[playerid][pFraction])
		{
			case 0: SetPlayerColor(playerid, 0xFFFFFF00);
			case 1:
			{
				if(GetPVarInt(playerid, "DutyStart") == 0) SetPlayerColor(playerid, 0xFFFFFF00);
				else SetPlayerColor(playerid, 0x110CE7FF);
			}
			case 9: SetPlayerColor(playerid, 0xB313E7FF);
			case 10: SetPlayerColor(playerid, 0xDBD604FF);
			case 12: SetPlayerColor(playerid, 0x009F00FF);
			case 13: SetPlayerColor(playerid, 0x01FCFFC8);
			case 14: SetPlayerColor(playerid, 0x40848BFF);
		}
		if(PlayerInfo[playerid][pTimeWanted] > 0)
		{
			SetPlayerPos(playerid, 1477.1868,1057.2545,-50.4020);
			SetPlayerFacingAngle(playerid, 90.9791);
			SetPlayerInterior(playerid, 1);
			SetPlayerVirtualWorld(playerid, 1);
			SetCameraBehindPlayer(playerid);
			switch(PlayerInfo[playerid][pFraction])
			{
				case 4, 5, 6, 9, 10, 11, 12, 13, 14, 15, 16: SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
		    	default: SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
			}
		    SetCameraBehindPlayer(playerid);
			return 1;
		}
		if(SpecAd[playerid] != 65535)
		{
    		SpecAd[playerid] = 65535;
			SetPlayerPos(playerid, SpecPos[playerid][0], SpecPos[playerid][1], SpecPos[playerid][2]);
			SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "SpecVirtualWorld"));
			SetPlayerInterior(playerid, GetPVarInt(playerid, "SpecInterior"));
			if(PlayerInfo[playerid][pAdmin] > 0 && AdminInfo[playerid][aLogged] == 1 && AdminInfo[playerid][aSkin] != 0) {SetPlayerSkin(playerid, AdminInfo[playerid][aSkin]);}
			else { SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]); }
			return 1;
		}
		if(PlayerInfo[playerid][pAdmin] > 0 && AdminInfo[playerid][aLogged] == 1 && AdminInfo[playerid][aSkin] != 0) SetPlayerSkin(playerid, AdminInfo[playerid][aSkin]);
		switch(PlayerInfo[playerid][pSpawn])
		{
			case 1: // Спавн
			{
				switch(PlayerInfo[playerid][pFraction])
				{
					case 0: // Без фракции
					{
						SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
						SetPlayerInterior(playerid, 0);
						SetPlayerVirtualWorld(playerid, 0);
						switch(PlayerInfo[playerid][pLevel])
						{
							case 1:
							{
								SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
								SetPlayerFacingAngle(playerid, 358.3446);
							}
							default:
							{
								SetPlayerPos(playerid, 1759.3574, -1903.1975, 13.5648);
								SetPlayerFacingAngle(playerid, 269.0671);
							}
						}
						SetCameraBehindPlayer(playerid);
					}
					case 1: // LSPD
					{
						if(GetPVarInt(playerid, "DutyStart") == 0)
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							switch(PlayerInfo[playerid][pLevel])
							{
								case 1:
								{
									SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
									SetPlayerFacingAngle(playerid, 358.3446);
								}
								default:
								{
									SetPlayerPos(playerid, 1759.3574, -1903.1975, 13.5648);
									SetPlayerFacingAngle(playerid, 269.0671);
								}
							}
							SetCameraBehindPlayer(playerid);
						}
						else
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 1);
							SetPlayerVirtualWorld(playerid, 1);
							SetPlayerPos(playerid, 1494.4174, 1059.2925, -50.4082);
							SetPlayerFacingAngle(playerid, 179.8256);
							SetCameraBehindPlayer(playerid);
						}
					}
					case 2: // FBI
					{
						if(GetPVarInt(playerid, "DutyStart") == 0)
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							switch(PlayerInfo[playerid][pLevel])
							{
								case 1:
								{
									SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
									SetPlayerFacingAngle(playerid, 358.3446);
								}
								default:
								{
									SetPlayerPos(playerid, 1759.3574, -1903.1975, 13.5648);
									SetPlayerFacingAngle(playerid, 269.0671);
								}
							}
							SetCameraBehindPlayer(playerid);
						}
						else
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
							SetPlayerFacingAngle(playerid, 358.3446);
							SetCameraBehindPlayer(playerid);
						}
					}
					case 3: // SANG
					{
						if(GetPVarInt(playerid, "DutyStart") == 1)
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
							SetPlayerHealth(playerid, 100);
							SetPlayerColor(playerid,0x51964DFF);
							SetPlayerInterior(playerid, 25);
							SetPlayerVirtualWorld(playerid, 25);
							SetPlayerPos(playerid, -1139.4773, -1720.8060, 59.9490);
							SetPlayerFacingAngle(playerid, 271.2137);
							SetCameraBehindPlayer(playerid);
						}
						else
						{
							if(PlayerInfo[playerid][pRank] < 3)
							{
								SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
								SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
								SetPVarInt(playerid, "DutyStart", 1);
								SetPlayerColor(playerid,0x51964DFF);
								SetPlayerInterior(playerid, 25);
								SetPlayerVirtualWorld(playerid, 25);
								SetPlayerPos(playerid, -1139.4773, -1720.8060, 59.9490);
								SetPlayerFacingAngle(playerid, 271.2137);
								SetCameraBehindPlayer(playerid);
							}
							else
							{
								SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
								SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
								SetPlayerInterior(playerid, 0);
								SetPlayerVirtualWorld(playerid, 0);
								switch(PlayerInfo[playerid][pLevel])
								{
									case 1:
									{
										SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
										SetPlayerFacingAngle(playerid, 358.3446);
									}
									default:
									{
										SetPlayerPos(playerid, 1759.3574, -1903.1975, 13.5648);
										SetPlayerFacingAngle(playerid, 269.0671);
									}
								}
								SetCameraBehindPlayer(playerid);
							}
						}
					}
					case 4: // EMS
					{
						if(GetPVarInt(playerid, "DutyStart") == 0)
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							switch(PlayerInfo[playerid][pLevel])
							{
								case 1:
								{
									SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
									SetPlayerFacingAngle(playerid, 358.3446);
								}
								default:
								{
									SetPlayerPos(playerid, 1759.3574, -1903.1975, 13.5648);
									SetPlayerFacingAngle(playerid, 269.0671);
								}
							}
							SetCameraBehindPlayer(playerid);
						}
						else
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
							SetPlayerFacingAngle(playerid, 358.3446);
							SetCameraBehindPlayer(playerid);
						}
					}
					case 5: // LCN
					{
						if(GetPVarInt(playerid, "DutyStart") == 0)
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							switch(PlayerInfo[playerid][pLevel])
							{
								case 1:
								{
									SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
									SetPlayerFacingAngle(playerid, 358.3446);
								}
								default:
								{
									SetPlayerPos(playerid, 1759.3574, -1903.1975, 13.5648);
									SetPlayerFacingAngle(playerid, 269.0671);
								}
							}
							SetCameraBehindPlayer(playerid);
						}
						else
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
							SetPlayerFacingAngle(playerid, 358.3446);
							SetCameraBehindPlayer(playerid);
						}
					}
					case 6: // Yakuza
					{
						if(GetPVarInt(playerid, "DutyStart") == 0)
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							switch(PlayerInfo[playerid][pLevel])
							{
								case 1:
								{
									SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
									SetPlayerFacingAngle(playerid, 358.3446);
								}
								default:
								{
									SetPlayerPos(playerid, 1759.3574, -1903.1975, 13.5648);
									SetPlayerFacingAngle(playerid, 269.0671);
								}
							}
							SetCameraBehindPlayer(playerid);
						}
						else
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
							SetPlayerFacingAngle(playerid, 358.3446);
							SetCameraBehindPlayer(playerid);
						}
					}
					case 7: // Gover
					{
						if(GetPVarInt(playerid, "DutyStart") == 0)
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							switch(PlayerInfo[playerid][pLevel])
							{
								case 1:
								{
									SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
									SetPlayerFacingAngle(playerid, 358.3446);
								}
								default:
								{
									SetPlayerPos(playerid, 1759.3574, -1903.1975, 13.5648);
									SetPlayerFacingAngle(playerid, 269.0671);
								}
							}
							SetCameraBehindPlayer(playerid);
						}
						else
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
							SetPlayerFacingAngle(playerid, 358.3446);
							SetCameraBehindPlayer(playerid);
						}
					}
					case 8: // News
					{
						if(GetPVarInt(playerid, "DutyStart") == 0)
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							switch(PlayerInfo[playerid][pLevel])
							{
								case 1:
								{
									SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
									SetPlayerFacingAngle(playerid, 358.3446);
								}
								default:
								{
									SetPlayerPos(playerid, 1759.3574, -1903.1975, 13.5648);
									SetPlayerFacingAngle(playerid, 269.0671);
								}
							}
							SetCameraBehindPlayer(playerid);
						}
						else
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 0);
							SetPlayerVirtualWorld(playerid, 0);
							SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
							SetPlayerFacingAngle(playerid, 358.3446);
							SetCameraBehindPlayer(playerid);
						}
					}
					case 9: // The Ballas Gang
					{
						SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
						SetPlayerPos(playerid, 2341.2354, -1063.7969, 1049.0234);
						SetPlayerFacingAngle(playerid, 92.2361);
						SetPlayerInterior(playerid, 6);
						SetPlayerVirtualWorld(playerid, 6);
						SetCameraBehindPlayer(playerid);
					}
					case 10: // The Vagos Gang
					{
						SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
						SetPlayerPos(playerid, 300.4859, 303.8335, 999.1484);
						SetPlayerFacingAngle(playerid, 1.9569);
						SetPlayerInterior(playerid, 4);
						SetPlayerVirtualWorld(playerid, 4);
						SetCameraBehindPlayer(playerid);
					}
					case 11: // Russian
					{
						SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
						SetPlayerInterior(playerid, 0);
						SetPlayerVirtualWorld(playerid, 0);
						SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
						SetPlayerFacingAngle(playerid, 358.3446);
						SetCameraBehindPlayer(playerid);
					}
					case 12: // The Grove Street
					{
						SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
						SetPlayerPos(playerid, 2495.7754, -1709.9971, 1014.7422);
						SetPlayerFacingAngle(playerid, 358.5719);
						SetPlayerInterior(playerid, 3);
						SetPlayerVirtualWorld(playerid, 3);
						SetCameraBehindPlayer(playerid);
					}
					case 13: // Varios Los Aztecas
					{
						SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
						SetPlayerPos(playerid, -47.6596,1399.9733,1084.4297);
						SetPlayerFacingAngle(playerid, 91.6839);
						SetPlayerInterior(playerid, 8);
						SetPlayerVirtualWorld(playerid, 8);
						SetCameraBehindPlayer(playerid);
					}
					case 14: // The Rifa Gang
					{
						SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
						SetPlayerPos(playerid, 2807.3286, -1167.0428, 1025.5703);
						SetPlayerFacingAngle(playerid, 181.6333);
						SetPlayerInterior(playerid, 8);
						SetPlayerVirtualWorld(playerid, 8);
						SetCameraBehindPlayer(playerid);
					}
					case 15: // Angel
					{
						SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
						SetPlayerInterior(playerid, 0);
						SetPlayerVirtualWorld(playerid, 0);
						SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
						SetPlayerFacingAngle(playerid, 358.3446);
						SetCameraBehindPlayer(playerid);
					}
					case 16: // Outlaw
					{
						SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
						SetPlayerInterior(playerid, 0);
						SetPlayerVirtualWorld(playerid, 0);
						SetPlayerPos(playerid, 1153.8356, -1767.4061, 16.5938);
						SetPlayerFacingAngle(playerid, 358.3446);
						SetCameraBehindPlayer(playerid);
					}
				}
			}
			case 2: // Частное имущество (Дом)
			{
				if(PlayerInfo[playerid][pHouse] == 9999)
				{
					new query[128];
					PlayerInfo[playerid][pSpawn] = 1;
					format(query, sizeof(query), "UPDATE `users` SET `pSpawn` = '1' WHERE `pName` = '%s'", PlayerInfo[playerid][pName]);
					mysql_tquery(dbHandle, query);
					SpawnPlayer(playerid);
					return 1;
				}
				SetPVarInt(playerid, "HouseID", PlayerInfo[playerid][pHouse] - 1);
				switch(PlayerInfo[playerid][pFraction])
				{
					case 0: // Без фракции
					{
						SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
				 		SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][pHouse] + 99);
				 		SetPlayerInterior(playerid, HouseInfo[PlayerInfo[playerid][pHouse]-1][hInterior]);
				 		SetPlayerPos(playerid, HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterX], HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterY], HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterZ]);
				 		SetPlayerFacingAngle(playerid, HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterAngle]);
				 		SetCameraBehindPlayer(playerid);
				 		SetPVarInt(playerid, "PlayerIntoHouse", 1);
				 	}
				 	case 1: // LSPD
				 	{
				 		if(GetPVarInt(playerid, "DutyStart") == 0)
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
					 		SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][pHouse] + 99);
					 		SetPlayerInterior(playerid, HouseInfo[PlayerInfo[playerid][pHouse]-1][hInterior]);
					 		SetPlayerPos(playerid, HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterX], HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterY], HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterZ]);
					 		SetPlayerFacingAngle(playerid, HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterAngle]);
					 		SetCameraBehindPlayer(playerid);
					 		SetPVarInt(playerid, "PlayerIntoHouse", 1);
						}
						else
						{
							SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
							SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
							SetPlayerInterior(playerid, 1);
							SetPlayerVirtualWorld(playerid, 1);
							SetPlayerPos(playerid, 1494.4174, 1059.2925, -50.4082);
							SetPlayerFacingAngle(playerid, 179.8256);
							SetCameraBehindPlayer(playerid);
						}
				 	}
				 	case 14: // The Rifa Gang
				 	{
				 		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
						SetPlayerHealth(playerid, PlayerInfo[playerid][pHP]);
				 		SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][pHouse] + 99);
				 		SetPlayerInterior(playerid, HouseInfo[PlayerInfo[playerid][pHouse]-1][hInterior]);
				 		SetPlayerPos(playerid, HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterX], HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterY], HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterZ]);
				 		SetPlayerFacingAngle(playerid, HouseInfo[PlayerInfo[playerid][pHouse]-1][hiEnterAngle]);
				 		SetCameraBehindPlayer(playerid);
				 		SetPVarInt(playerid, "PlayerIntoHouse", 1);
				 	}
				}
			}
		}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	PlayerAFK[playerid] = -2;
	if((PlayerInfo[killerid][pFraction] == 1 || PlayerInfo[killerid][pFraction] == 2))
	{
		if(PlayerInfo[playerid][pWanted] > 0)
		{
			new string[128], query[128];
		    PlayerInfo[playerid][pTimeWanted] = PlayerInfo[playerid][pWanted]*10;
			PlayerInfo[playerid][pWanted] = 0;
		    format(string, sizeof(string), "{FF69B4}Вы были арестованы и посажены в тюрьму на {FFFFFF}%d {FF69B4}секунд", PlayerInfo[playerid][pTimeWanted]);
		    SCM(playerid, COLOR_INFO, string);
		    format(string, sizeof(string), "{FF69B4}Вы посадили {FFFFFF}%s{FF69B4} в тюрьму на {FFFFFF}%d {FF69B4}секунд", PlayerInfo[playerid][pName], PlayerInfo[playerid][pTimeWanted]);
		    SCM(killerid, COLOR_INFO, string);
		    format(query, sizeof(query), "UPDATE `users` SET `pTimeWanted` = '%d', `pWanted` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[playerid][pTimeWanted], PlayerInfo[playerid][pWanted], PlayerInfo[playerid][pID]);
			mysql_tquery(dbHandle, query);
		}
	    SetPVarInt(killerid, "Escorted", -1);
	    SetPVarInt(playerid, "OnEscort", -1);
	    SetPVarInt(playerid, "Cuffed", 0);
	    return 1;
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Чтобы писать в чат, Вам необходимо авторизоваться!");
	if(PlayerInfo[playerid][pMute] > 0)
	{
		new string[128]; 
		if(PlayerInfo[playerid][pMute] < 1)
		{
			format(string, sizeof(string), "[Информация]: {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}менее {FF69B4}минуты!");
		}
		else
		{
			format(string, sizeof(string), "[Информация]: {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}минут!", PlayerInfo[playerid][pMute]/60);
		}
		SCM(playerid, COLOR_INFO, string);
		SetPlayerChatBubble(playerid, "блокировка чата", 0xDDA0DDFF, 15, 2000);
		return 0;
	}
	new chat = strlen(text);
	if(chat < 144)
	{
		ProxDetector(20.0, playerid, text, 0xE6E6E6E6, 0xC8C8C8C8, 0xAAAAAAAA, 0x8C8C8C8C,0x6E6E6E6E);
		if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
		{
			ApplyAnimation(playerid, "PED", "IDLE_chat", 4.1, 0, 1, 1, 1, 1);
			SetTimerEx("ChatAnimation", 3200, 0, "i", playerid);
		}
	}
	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(GetPlayerVehicleID(playerid) >= loadercar[0] && GetPlayerVehicleID(playerid) <= loadercar[9])
	{
		if(GetPVarInt(playerid, "LoaderInvite") != 1 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) 
		{
			SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не работаете грузчиком!");
			return RemovePlayerFromVehicle(playerid);
		}
	}
	if(GetPlayerVehicleID(playerid) >= ascar[0] && GetPlayerVehicleID(playerid) <= ascar[11])
	{
		if(GetPVarInt(playerid, "AutoSchoolExamination") != 1 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			RemovePlayerFromVehicle(playerid);
			return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}У вас нет доступа к данном транспорту!");
		}
	}
	if(GetPlayerVehicleID(playerid) >= rifacar[0] && GetPlayerVehicleID(playerid) <= rifacar[7])
	{
		if(PlayerInfo[playerid][pFraction] != 14 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			RemovePlayerFromVehicle(playerid);
			return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не состоите в The Rifa Gang!");
		}
	}
	if(GetPlayerVehicleID(playerid) >= sangcar[0] && GetPlayerVehicleID(playerid) <= sangcar[33])
    {
        if(PlayerInfo[playerid][pFraction] != 3 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            RemovePlayerFromVehicle(playerid);
            return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не состоите в San Andreas National Guard!");
        }
        else 
        {
        	if(GetPlayerVehicleID(playerid) >= sangcar[2] && GetPlayerVehicleID(playerid) <= sangcar[7] && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) 
        	{
        		new string[128];
        		new vehicleid = GetPlayerVehicleID(playerid);
				SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Для того чтобы приступить к поставкам используйте {FFFFFF}/carm{FF69B4}.");
        		format(string, sizeof(string), "{F4CB4D}Боеприпасов в машине:{FFFFFF} %d. {F4CB4D}Материалов в машине:{FFFFFF} %d. ", VehicleInfo[vehicleid][vMats], VehicleInfo[vehicleid][vMaterials]);
        		SCM(playerid, COLOR_INFO, string);
        		if(VehicleInfo[GetPlayerVehicleID(playerid)][vLoading] == 1)
        		{
        			SPD(playerid, DLG_UNLOAD_SANG, DSM, "Погрузка материалов {F385D5}|| Фракция","{FFFFFF}Вы хотите прекратить погрузку ресурсов в машину?","Да","Нет");
        		}
        	}
        	else
	        {
	        	if(GetPVarInt(playerid, "DutyStart") == 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	        	{
	        		SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вам необходимо начать рабочий день, чтобы воспользоваться транспортом!");
	        	}
	        }
        }
    }
	if(GetPlayerVehicleID(playerid) >= lspdcar[0] && GetPlayerVehicleID(playerid) <= lspdcar[29])
    {
        if(PlayerInfo[playerid][pFraction] != 1 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            RemovePlayerFromVehicle(playerid);
            return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не состоите в Los-Santos Police Department!");
        }
        else
        {
        	if(GetPVarInt(playerid, "DutyStart") == 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        	{
        		SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вам необходимо начать рабочий день, чтобы воспользоваться транспортом!");
        	}
        }
    }
	if(GetPlayerVehicleID(playerid) >= grovecar[0] && GetPlayerVehicleID(playerid) <= grovecar[7])
	{
		if(PlayerInfo[playerid][pFraction] != 12 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			RemovePlayerFromVehicle(playerid);
			return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не состоите в The Grove Street!");
		}
	}
	if(GetPlayerVehicleID(playerid) >= azteccar[0] && GetPlayerVehicleID(playerid) <= azteccar[6])
	{
		if(PlayerInfo[playerid][pFraction] != 13 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			RemovePlayerFromVehicle(playerid);
			return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не состоите в Varios Los Aztecas!");
		}
	}
	if(GetPlayerVehicleID(playerid) >= ballascar[0] && GetPlayerVehicleID(playerid) <= ballascar[7])
	{
		if(PlayerInfo[playerid][pFraction] != 9 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			RemovePlayerFromVehicle(playerid);
			return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не состоите в The Ballas Gang!");
		}
	}
	if(GetPlayerVehicleID(playerid) >= vagoscar[0] && GetPlayerVehicleID(playerid) <= vagoscar[6])
	{
		if(PlayerInfo[playerid][pFraction] != 10 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			RemovePlayerFromVehicle(playerid);
			return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не состоите в The Vagos Gang!");
		}
	}
	if(newstate != PLAYER_STATE_ONFOOT && GetPVarInt(playerid, "LoadMats") == 1)
	{
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
		RemovePlayerAttachedObject(playerid,1);
		SCM(playerid, COLOR_ERROR, "Вы уронили ящик.");
		SetPVarInt(playerid, "LoadMats", 0);
	}
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new newcar = GetPlayerVehicleID(playerid);
		new engine, lights, alarm, doors, bonnet, boot, objective;
		if(IsACar(newcar))
		{
			if(PlayerInfo[playerid][pCarLic] == 0 && GetPVarInt(playerid, "AutoSchoolExamination") != 1)
			{
				new string[128];
				format(string, sizeof(string), "[Напоминание]:{FFFFFF} У Вас нет водительских прав!");
				SendClientMessage(playerid, COLOR_PURPLE, string);
			}
		}
		if(GetVehicleModel(newcar) == 481 || GetVehicleModel(newcar) == 509 || GetVehicleModel(newcar) == 510)
		{
			GetVehicleParamsEx(newcar,engine,lights,alarm,doors,bonnet,boot,objective);
			SetVehicleParamsEx(newcar,true,lights,alarm,doors,bonnet,boot,objective);
		}
		else
		{
		    GetVehicleParamsEx(newcar,engine,lights,alarm,doors,bonnet,boot,objective);
			if(!engine) SendClientMessage(playerid,COLOR_INFO, "[Информация] {FF69B4}Чтобы завести двигатель нажмите клавишу {FFFFFF}'2'{FF69B4} или введите команду {FFFFFF}/en");
			//ProSport[playerid] = SetTimerEx("speed_timer", 2000, 1, "i", playerid);
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	//========================================= Строитель ======================================================
	if(IsPlayerInCheckpoint(playerid))
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.0, 2662.4285, -2213.0852, 13.5469) && GetPVarInt(playerid, "LoaderInvite") == 1)
		{
			DisablePlayerCheckpoint(playerid);
			SetPlayerSpecialAction(playerid, 0);
			ApplyAnimation(playerid, "CARRY", "PUTDWN", 4.0, 0, 0, 0, 0, 0);
			SetPVarInt(playerid, "LoaderAmountObject", GetPVarInt(playerid, "LoaderAmountObject") + 1);
			new string[128];
			format(string, sizeof(string), "[Информация]: {FF69B4}Груз перенесен на склад. Всего перенесено: {F7BA0B}%d шт.", GetPVarInt(playerid, "LoaderAmountObject"));
			SCM(playerid, COLOR_INFO, string);
			RemovePlayerAttachedObject(playerid, 5);
			SetPVarInt(playerid, "LoaderPick", 0);
		}
		if(IsPlayerInRangeOfPoint(playerid, 2.0, 2666.1814, -2213.0854, 13.5469) && GetPVarInt(playerid, "LoaderInvite") == 1)
		{
			DisablePlayerCheckpoint(playerid);
			SetPlayerSpecialAction(playerid, 0);
			ApplyAnimation(playerid, "CARRY", "PUTDWN", 4.0, 0, 0, 0, 0, 0);
			SetPVarInt(playerid, "LoaderAmountObject", GetPVarInt(playerid, "LoaderAmountObject") + 1);
			new string[128];
			format(string, sizeof(string), "[Информация]: {FF69B4}Груз перенесен на склад. Всего перенесено: {F7BA0B}%d шт.", GetPVarInt(playerid, "LoaderAmountObject"));
			SCM(playerid, COLOR_INFO, string);
			RemovePlayerAttachedObject(playerid, 5);
			SetPVarInt(playerid, "LoaderPick", 0);
		}
		if(IsPlayerInRangeOfPoint(playerid, 2, 1255.0181,-1267.3550,13.4216) && GetPVarInt(playerid, "BuildStart") == 1)
		{
			DisablePlayerCheckpoint(playerid);
			PlayerInfo[playerid][pMoney] += 25;
			switch(random(3))
			{
				case 0:
				{
					SetPlayerCheckpoint(playerid, 1239.6769,-1266.5416,13.4330, 2.0);
				}
				case 1:
				{
					SetPlayerCheckpoint(playerid, 1248.4233,-1250.0099,13.6569, 2.0);
				}
				case 2:
				{
					SetPlayerCheckpoint(playerid, 1264.5876,-1241.7101,16.3458, 2.0);
				}
			}
		}
		if(IsPlayerInRangeOfPoint(playerid, 2, 1239.6769,-1266.5416,13.4330) && GetPVarInt(playerid, "BuildStart") == 1)
		{
			DisablePlayerCheckpoint(playerid);
			PlayerInfo[playerid][pMoney] += 25;
			switch(random(3))
			{
				case 0:
				{
					SetPlayerCheckpoint(playerid, 1255.0181,-1267.3550,13.4216, 2.0);
				}
				case 1:
				{
					SetPlayerCheckpoint(playerid, 1248.4233,-1250.0099,13.6569, 2.0);
				}
				case 2:
				{
					SetPlayerCheckpoint(playerid, 1264.5876,-1241.7101,16.3458, 2.0);
				}
			}
		}
		if(IsPlayerInRangeOfPoint(playerid, 2, 1248.4233,-1250.0099,13.6569) && GetPVarInt(playerid, "BuildStart") == 1)
		{
			DisablePlayerCheckpoint(playerid);
			PlayerInfo[playerid][pMoney] += 25;
			switch(random(3))
			{
				case 0:
				{
					SetPlayerCheckpoint(playerid, 1239.6769,-1266.5416,13.4330, 2.0);
				}
				case 1:
				{
					SetPlayerCheckpoint(playerid, 1255.0181,-1267.3550,13.4216, 2.0);
				}
				case 2:
				{
					SetPlayerCheckpoint(playerid, 1264.5876,-1241.7101,16.3458, 2.0);
				}
			}
		}
		if(IsPlayerInRangeOfPoint(playerid, 2, 1264.5876,-1241.7101,16.3458) && GetPVarInt(playerid, "BuildStart") == 1)
		{
			DisablePlayerCheckpoint(playerid);
			PlayerInfo[playerid][pMoney] += 25;
			switch(random(3))
			{
				case 0:
				{
					SetPlayerCheckpoint(playerid, 1239.6769,-1266.5416,13.4330, 2.0);
				}
				case 1:
				{
					SetPlayerCheckpoint(playerid, 1248.4233,-1250.0099,13.6569, 2.0);
				}
				case 2:
				{
					SetPlayerCheckpoint(playerid, 1255.0181,-1267.3550,13.4216, 2.0);
				}
			}
		}
		//=============================================[ Поставки ]=================================================
		if(GetPVarInt(playerid, "LoadStart") == 1)
		{
			new query[128];
			DisablePlayerCheckpoint(playerid);
			if(FracInfo[2][fMaterials] < 10000) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}На главном складе недостаточно боеприпасов");
			if(VehicleInfo[GetPlayerVehicleID(playerid)][vMats] == 10000) { SetPVarInt(playerid, "LoadStart",0); return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}В машине не хватает места"); }
			else 
			{
				FracInfo[2][fMaterials] -= 10000;
				SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Вы загрузились на главном складе");
				VehicleInfo[GetPlayerVehicleID(playerid)][vMats] = 10000;
				SetPVarInt(playerid, "LoadStart",0);
				format(query, sizeof(query), "UPDATE `fractions` SET `fMaterials` = '%d' WHERE `fID` = 3 LIMIT 1", FracInfo[2][fMaterials]);
				mysql_tquery(dbHandle, query);
				return true;
			}
		}
		if(GetPVarInt(playerid, "UnLoadToMainSkladStart") == 1)
		{
			new query[128];
			DisablePlayerCheckpoint(playerid);
			if(VehicleInfo[GetPlayerVehicleID(playerid)][vMaterials]>0)
			{
				FracInfo[2][fMaterials] += VehicleInfo[GetPlayerVehicleID(playerid)][vMaterials]*10;
				if(FracInfo[2][fMaterials]>500000) FracInfo[2][fMaterials] = 500000;
				VehicleInfo[GetPlayerVehicleID(playerid)][vMaterials] -= VehicleInfo[GetPlayerVehicleID(playerid)][vMaterials];
				SetPVarInt(playerid, "UnLoadToMainSkladStart",0);
				SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Вы разгрузились на главном складе");
				format(query, sizeof(query), "UPDATE `fractions` SET `fMaterials` = '%d' WHERE `fID` = 3 LIMIT 1", FracInfo[2][fMaterials]);
				mysql_tquery(dbHandle, query);
				return true;
			}
			if(VehicleInfo[GetPlayerVehicleID(playerid)][vMats]>0)
			{
				FracInfo[2][fMaterials] += VehicleInfo[GetPlayerVehicleID(playerid)][vMats];
				if(FracInfo[2][fMaterials]>500000) FracInfo[2][fMaterials] = 500000;
				VehicleInfo[GetPlayerVehicleID(playerid)][vMats] -= VehicleInfo[GetPlayerVehicleID(playerid)][vMats];
				SetPVarInt(playerid, "UnLoadToMainSkladStart",0);
				SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Вы разгрузились на главном складе");
				format(query, sizeof(query), "UPDATE `fractions` SET `fMaterials` = '%d' WHERE `fID` = 3 LIMIT 1", FracInfo[2][fMaterials]);
				mysql_tquery(dbHandle, query);
				return true;
			}
			else {SetPVarInt(playerid, "UnLoadToMainSkladStart",0); return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}В машине нет боеприпасов");} 
		}
		if(GetPVarInt(playerid, "UnLoadToLSPD") == 1)
		{
			new query[128];
			DisablePlayerCheckpoint(playerid);
			if(VehicleInfo[GetPlayerVehicleID(playerid)][vMats]>0)
			{
				if(FracInfo[0][fMaterials]==200000) { SetPVarInt(playerid, "UnLoadToLSPD",0); return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Склад организации полон");}
				FracInfo[0][fMaterials] += VehicleInfo[GetPlayerVehicleID(playerid)][vMats];
				if(FracInfo[0][fMaterials]>200000) {VehicleInfo[GetPlayerVehicleID(playerid)][vMats] = FracInfo[0][fMaterials]-200000; FracInfo[0][fMaterials] = 200000; }
				else { VehicleInfo[GetPlayerVehicleID(playerid)][vMats] -= VehicleInfo[GetPlayerVehicleID(playerid)][vMats]; }
				SetPVarInt(playerid, "UnLoadToLSPD",0);
				SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Вы разгрузились в {FFFFFF}LSPD");
				format(query, sizeof(query), "UPDATE `fractions` SET `fMaterials` = '%d' WHERE `fID` = 1 LIMIT 1", FracInfo[0][fMaterials]);
				mysql_tquery(dbHandle, query);
				return true;
			}
			else {SetPVarInt(playerid, "UnLoadToLSPD",0); return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}В машине нет боеприпасов");} 
		}
		if(GetPVarInt(playerid, "UnLoadToFBI") == 1)
		{
			new query[128];
			DisablePlayerCheckpoint(playerid);
			if(VehicleInfo[GetPlayerVehicleID(playerid)][vMats]>0)
			{
				if(FracInfo[1][fMaterials] == 200000) { SetPVarInt(playerid, "UnLoadToFBI",0); return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Склад организации полон"); }
				FracInfo[1][fMaterials] += VehicleInfo[GetPlayerVehicleID(playerid)][vMats];
				if(FracInfo[1][fMaterials]>200000) {VehicleInfo[GetPlayerVehicleID(playerid)][vMats] = FracInfo[1][fMaterials]-200000; FracInfo[1][fMaterials] = 200000; }
				else { VehicleInfo[GetPlayerVehicleID(playerid)][vMats] -= VehicleInfo[GetPlayerVehicleID(playerid)][vMats]; }
				SetPVarInt(playerid, "UnLoadToFBI",0);
				SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Вы разгрузились в {FFFFFF}FBI");
				format(query, sizeof(query), "UPDATE `fractions` SET `fMaterials` = '%d' WHERE `fID` = 2 LIMIT 1", FracInfo[1][fMaterials]);
				mysql_tquery(dbHandle, query);
				return true;
			}
			else {SetPVarInt(playerid, "UnLoadToFBI",0); return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}В машине нет боеприпасов");} 
		}
		//=========================================================================================================
	}
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	if(objectid == submarine)
	{
		if(submarinestat == 1)
		{
			new string[64];
			submarinestat = 2;
			loadzone = CreateDynamicPickup(19605, 23, 2739.6382,-2576.7817,1.3000, -1);
			format(string, sizeof(string), "Материалов в подлодке:\n%d/500000", submarine_mats);
			loadzone3dtext = Create3DTextLabel(string, COLOR_INFO, 2739.6382,-2576.7817,3.0000, 15.0, 0, 0);
			//MoveObject(submarine, 3252.048583, -2586.376220, -14.737571, 50.0);
			return 1;
		}
		if(submarinestat == 2)
		{
			submarine_mats = 500000;
			submarinestat = 0;
			DestroyObject(submarine);
			return 1;
		}
	}
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == selectskinloader[5])
	{
		switch(PlayerInfo[playerid][pGender])
		{
			case 1: if(GetPlayerSkin(playerid) == 69 && GetPVarInt(playerid, "LoaderInviteSkin") == 69) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Скин не соответствует вашему полу, выберите другой!");
			case 2:
			{
				if(GetPlayerSkin(playerid) == 8 && GetPVarInt(playerid, "LoaderInviteSkin") == 8) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Скин не соответствует вашему полу, выберите другой!");
				if(GetPlayerSkin(playerid) == 16 && GetPVarInt(playerid, "LoaderInviteSkin") == 16) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Скин не соответствует вашему полу, выберите другой!");
			}
		}
		SetPVarInt(playerid, "LoaderInvite", 1);
		SetPlayerVirtualWorld(playerid, 0);
		TogglePlayerControllable(playerid, 1);
		SetPlayerPos(playerid, 2647.8589, -2215.2109, 13.5501);
		SetPlayerFacingAngle(playerid, 270.9471);
		SetCameraBehindPlayer(playerid);
		for(new i = 0; i < 10; i++) TextDrawHideForPlayer(playerid, selectskinloader[i]);
		CancelSelectTextDraw(playerid);
		SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Вы начали работу грузчика!");
		SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Основная работа грузчика - переносить вещи с корабля на склад.");
		SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Если у вас достаточно навыка, то Вы можете продолжать свою работу, используя погрузчик!");
	}
	if(clickedid == selectskinloader[4])
	{
		switch(GetPVarInt(playerid, "LoaderInviteSkin"))
		{
			case 8: { SetPlayerSkin(playerid, 69); SetPVarInt(playerid, "LoaderInviteSkin", 69); }
			case 69: { SetPlayerSkin(playerid, 16); SetPVarInt(playerid, "LoaderInviteSkin", 16); }
			case 16: { SetPlayerSkin(playerid, 8); SetPVarInt(playerid, "LoaderInviteSkin", 8); }
		}
	}
	if(clickedid == selectskinloader[3])
	{
		switch(GetPVarInt(playerid, "LoaderInviteSkin"))
		{
			case 8: { SetPlayerSkin(playerid, 16); SetPVarInt(playerid, "LoaderInviteSkin", 16); }
			case 16: { SetPlayerSkin(playerid, 69); SetPVarInt(playerid, "LoaderInviteSkin", 69); }
			case 69: { SetPlayerSkin(playerid, 8); SetPVarInt(playerid, "LoaderInviteSkin", 8); }
		}
	}
	if(clickedid == selectskinloader[9])
	{
		SetPlayerVirtualWorld(playerid, 0);
		TogglePlayerControllable(playerid, 1);
		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
		SetPlayerPos(playerid, 2647.8589, -2215.2109, 13.5501);
		SetPlayerFacingAngle(playerid, 270.9471);
		SetCameraBehindPlayer(playerid);
		for(new i = 0; i < 10; i++) TextDrawHideForPlayer(playerid, selectskinloader[i]);
		CancelSelectTextDraw(playerid);
		SetPVarInt(playerid, "LoaderInviteSkin", 0);
	}
	if(clickedid == rentcar_TD[21])
	{
		switch(GetPVarInt(playerid, "RentCarModel"))
		{
			case 462:
			{
				if(PlayerInfo[playerid][pMoney] < 125)
				{
					SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У вас недостаточно средств!");
					CancelSelectTextDraw(playerid);
					for(new i = 0; i < 22; i++) TextDrawHideForPlayer(playerid, rentcar_TD[i]);
					TogglePlayerControllable(playerid, true);
					return 1;
				}
				GiveMoney(playerid, -125);
				CancelSelectTextDraw(playerid);
				for(new i = 0; i < 22; i++) TextDrawHideForPlayer(playerid, rentcar_TD[i]);
				TogglePlayerControllable(playerid, true);
				new rentcar = AddStaticVehicle(GetPVarInt(playerid, "RentCarModel"), 1120.3962, -1746.9673, 13.1699, 269.8824, 3, 3);
				SetVehicleNumberPlate(rentcar, "RENT");
				PutPlayerInVehicle(playerid, rentcar, 0);
				SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Транспортное средство успешно арендовано!");
			}
		}
	}
	if(clickedid == rentcar_TD[22])
	{
		CancelSelectTextDraw(playerid);
		for(new i = 0; i < 22; i++) TextDrawHideForPlayer(playerid, rentcar_TD[i]);
		TogglePlayerControllable(playerid, true);
	}
	if(clickedid == selectskin_TD[3])
	{
		switch(PlayerInfo[playerid][pGender])
		{
			case 1:
			{
				switch(GetPVarInt(playerid, "SelectSkinRegistration"))
				{
					case 7: { SetPlayerSkin(playerid, 136); SetPVarInt(playerid, "SelectSkinRegistration", 136); }
					case 136: { SetPlayerSkin(playerid, 128); SetPVarInt(playerid, "SelectSkinRegistration", 128); }
					case 128: { SetPlayerSkin(playerid, 2); SetPVarInt(playerid, "SelectSkinRegistration", 2); }
					case 2: { SetPlayerSkin(playerid, 7); SetPVarInt(playerid, "SelectSkinRegistration", 7); }
				}
			}
			case 2:
			{
				switch(GetPVarInt(playerid, "SelectSkinRegistration"))
				{
					case 41: { SetPlayerSkin(playerid, 88); SetPVarInt(playerid, "SelectSkinRegistration", 88); }
					case 88: { SetPlayerSkin(playerid, 69); SetPVarInt(playerid, "SelectSkinRegistration", 69); }
					case 69: { SetPlayerSkin(playerid, 56); SetPVarInt(playerid, "SelectSkinRegistration", 56); }
					case 56: { SetPlayerSkin(playerid, 41); SetPVarInt(playerid, "SelectSkinRegistration", 41); }
				}
			}
		}
	}
	if(clickedid == selectskin_TD[11])
	{
		switch(PlayerInfo[playerid][pGender])
		{
			case 1:
			{
				switch(GetPVarInt(playerid, "SelectSkinRegistration"))
				{
					case 7: { SetPlayerSkin(playerid, 2); SetPVarInt(playerid, "SelectSkinRegistration", 2); }
					case 2: { SetPlayerSkin(playerid, 128); SetPVarInt(playerid, "SelectSkinRegistration", 128); }
					case 128: { SetPlayerSkin(playerid, 136); SetPVarInt(playerid, "SelectSkinRegistration", 136); }
					case 136: { SetPlayerSkin(playerid, 7); SetPVarInt(playerid, "SelectSkinRegistration", 7); }
				}
			}
			case 2:
			{
				switch(GetPVarInt(playerid, "SelectSkinRegistration"))
				{
					case 41: { SetPlayerSkin(playerid, 56); SetPVarInt(playerid, "SelectSkinRegistration", 56); }
					case 56: { SetPlayerSkin(playerid, 69); SetPVarInt(playerid, "SelectSkinRegistration", 69); }
					case 69: { SetPlayerSkin(playerid, 88); SetPVarInt(playerid, "SelectSkinRegistration", 88); }
					case 88: { SetPlayerSkin(playerid, 41); SetPVarInt(playerid, "SelectSkinRegistration", 41); }
				}
			}
		}
	}
	if(clickedid == selectskin_TD[7])
	{
		static const fmt_query[] = "UPDATE `users` SET `pSkin` = '%d' WHERE `pName` = '%s'";
		PlayerInfo[playerid][pSkin] = GetPVarInt(playerid, "SelectSkinRegistration");
		new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)+3];
		format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pSkin], PlayerInfo[playerid][pName]);
		mysql_tquery(dbHandle, query);
		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
		SetPVarInt(playerid, "Registration", 1);
		SetPVarInt(playerid, "RegistrationSkinConfirm", 0);
		CancelSelectTextDraw(playerid);
		SpawnPlayer(playerid);
	}
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	new strings[128];
	format(strings, sizeof(strings), "Ид пикапа:%d", pickupid);
	SCM(playerid, -1, strings);
	if(GetPVarInt(playerid, "PickupActivated") > gettime()) return 1;
	if(pickupid == LOADERPIC)
	{
		if(IsPlayerInRangeOfPoint(playerid, 1.5, 2682.7825,-2263.4648,12.0966))
		{
			if(GetPVarInt(playerid, "LoaderInvite") != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не работаете грузчиком!");
			if(GetPVarInt(playerid, "LoaderPick") == 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше!");
			DisablePlayerCheckpoint(playerid);
			ApplyAnimation(playerid, "CARRY", "LIFTUP", 4.0, 0, 0, 0, 0, 0);
			SetTimerEx("PickObjectLoader", 1700, 0, "i", playerid);
			SetPVarInt(playerid, "LoaderPick", 1);
			switch(random(2))
			{
				case 0: SetPlayerCheckpoint(playerid, 2662.4285, -2213.0852, 13.5469, 1.5);
				case 1: SetPlayerCheckpoint(playerid, 2666.1814, -2213.0854, 13.5469, 1.5);
			}
		}
	}
	if(pickupid == loaderinvite)
	{
		switch(GetPVarInt(playerid, "LoaderInvite"))
		{
			case 0: SPD(playerid, DLG_LOADERINVITE, DIALOG_STYLE_LIST, "Грузчик {FFFFFF}|| Трудоустройство", "{FFFFFF}[1] Устроиться на работу\n[2] Статистика грузчика", "Выбрать", "Закрыть");
			case 1: SPD(playerid, DLG_LOADERINVITE, DIALOG_STYLE_LIST, "Грузчик {FFFFFF}|| Трудоустройство", "{FFFFFF}[1] Закончить работу\n[2] Статистика грузчика", "Выбрать", "Закрыть");
		}
	}
	if(pickupid == healthspls)
	{
		if(PlayerInfo[playerid][pLevel] > 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Доступно только новичкам (1 lvl)!");
		SetHealth(playerid, 100); // Восстановление здоровья до 100 единиц с последующим сохранением (происходит в стоке!).
		SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Здоровье успешно восстановлено!");
	}
	if(pickupid == victimenter[0]) // Вход в Магазин одежды (Стандарт класс)
	{
		SetPlayerPos(playerid, 225.03,-9.18,1002.21);
        SetPlayerFacingAngle(playerid, 90);
        SetPlayerInterior(playerid, 5);
        SetPlayerVirtualWorld(playerid, 5);
        SetCameraBehindPlayer(playerid);
	}
	if(pickupid == victimenter[1]) // Выход из Магазин одежды (Стандарт класс)
	{
		SetPlayerPos(playerid, 458.5028,-1500.9413,31.0412);
        SetPlayerFacingAngle(playerid, 98.5497);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetCameraBehindPlayer(playerid);
	}
	if(pickupid == DRUGDEN[0]) // Вход в наркопритон
	{
		SetPlayerPos(playerid, 318.6837, 1117.1589, 1083.8828);
        SetPlayerFacingAngle(playerid, 358.0547);
        SetPlayerInterior(playerid, 5);
        SetPlayerVirtualWorld(playerid, 5);
        SetCameraBehindPlayer(playerid);
	}
	if(pickupid == DRUGDEN[1]) // Выход из наркопритона
	{
		SetPlayerPos(playerid, 2168.2590, -1673.7946, 15.0831);
        SetPlayerFacingAngle(playerid, 224.8636);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetCameraBehindPlayer(playerid);
	}
	if(pickupid == lspdenter[0]) // Вход в LSPD
	{
		SetPlayerPos(playerid, 1483.1387,1023.8972,-50.4082);
        SetPlayerFacingAngle(playerid, 0.2683);
        SetPlayerInterior(playerid, 1);
        SetPlayerVirtualWorld(playerid, 1);
        SetCameraBehindPlayer(playerid);
	}
	if(pickupid == lspdexit[0]) // Выход из LSPD
	{
		SetPlayerPos(playerid, 1553.0358, -1675.5183, 16.1953);
		SetPlayerFacingAngle(playerid, 88.0137);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == lspdenter[1]) // Вход в LSPD (Гараж)
	{
		SetPlayerPos(playerid, 1495.3157, 1046.4153, -50.4082);
		SetPlayerFacingAngle(playerid, 89.6474);
		SetPlayerInterior(playerid, 1);
		SetPlayerVirtualWorld(playerid, 1);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == lspdexit[1]) // Выход из LSPD (Гараж)
	{
		SetPlayerPos(playerid, 1568.8564, -1692.9025, 5.8906);
		SetPlayerFacingAngle(playerid, 179.3029);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == AUTOSCHOOL[0]) // Вход в АШ передний
	{
		SetPlayerPos(playerid, -2028.4403,-105.0960,1035.1719);
		SetPlayerFacingAngle(playerid, 94.7859);
		SetPlayerInterior(playerid, 3);
		SetPlayerVirtualWorld(playerid, 3);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == AUTOSCHOOL[1]) // Выход из АШ (первый)
	{
		SetPlayerPos(playerid, 738.9571,-1415.2159,13.5169);
		SetPlayerFacingAngle(playerid, 359.5707);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == AUTOSCHOOL[2]) // Вход в АШ с заднего двора
	{
		SetPlayerPos(playerid, -2029.8218,-117.3519,1035.1719);
		SetPlayerFacingAngle(playerid, 359.2380);
		SetPlayerInterior(playerid, 3);
		SetPlayerVirtualWorld(playerid, 3);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == AUTOSCHOOL[3]) // Выход из АШ на задний двор
	{
		SetPlayerPos(playerid, 739.3280,-1431.2889,13.5234);
		SetPlayerFacingAngle(playerid, 180.2408);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == MayorPic[0]) // Вход в Мэрию
	{
		SetPlayerPos(playerid, 386.52,173.63,1008.38);
		SetPlayerFacingAngle(playerid, 90.2071);
		SetPlayerInterior(playerid, 3);
		SetPlayerVirtualWorld(playerid, 3);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == MayorPic[1]) // Выход из Мэрию
	{
		SetPlayerPos(playerid, 1481.0302,-1768.7919,18.7958);
		SetPlayerFacingAngle(playerid, 0);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == AZTEC[0]) // Вход в Aztec
	{
		SetPlayerPos(playerid, -42.3760,1408.3560,1084.4297);
		SetPlayerFacingAngle(playerid, 2.0148);
		SetPlayerInterior(playerid, 8);
		SetPlayerVirtualWorld(playerid, 8);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == AZTEC[1]) // Выход из Aztec
	{
		SetPlayerPos(playerid, 1667.4701,-2108.8208,13.5469);
		SetPlayerFacingAngle(playerid, 179.9076);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == VAGOS[0]) // Вход в Vagos
	{
		SetPlayerPos(playerid, 301.8263, 309.9498, 1003.3047);
		SetPlayerFacingAngle(playerid, 271.5197);
		SetPlayerInterior(playerid, 4);
		SetPlayerVirtualWorld(playerid, 4);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == VAGOS[1]) // Выход из Vagos
	{
		SetPlayerPos(playerid, 2772.9856,-1628.2773,12.1775);
		SetPlayerFacingAngle(playerid, 269.0723);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == BALLAS[0]) // Вход в Ballas
	{
		SetPlayerPos(playerid, 2333.0945,-1075.4524,1049.0234);
		SetPlayerFacingAngle(playerid, 358.6856);
		SetPlayerInterior(playerid, 6);
		SetPlayerVirtualWorld(playerid, 6);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == BALLAS[1]) // Выход из Ballas
	{
		SetPlayerPos(playerid, 2648.9705,-2021.8663,13.8233);
		SetPlayerFacingAngle(playerid, 89.2394);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == GROVE[0]) // Вход в Grove
	{
		SetPlayerPos(playerid, 2496.3967,-1694.8004,1014.7422);
		SetPlayerFacingAngle(playerid, 180.9064);
		SetPlayerInterior(playerid, 3);
		SetPlayerVirtualWorld(playerid, 3);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == GROVE[1]) // Выход на улицу из Grove
	{
		SetPlayerPos(playerid, 2495.3865,-1688.4746,13.8290);
		SetPlayerFacingAngle(playerid, 2.0148);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == SANG[0]) // Вход в казарму SANG
	{
		SetPlayerPos(playerid, -1112.5602,-1723.0953,59.9490);
		SetPlayerFacingAngle(playerid, 357.4988);
		SetPlayerInterior(playerid, 25);
		SetPlayerVirtualWorld(playerid, 25);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == SANG[1]) // Выход из казармы SANG
	{
		SetPlayerPos(playerid, -1104.0660,-1672.2758,76.3739);
		SetPlayerFacingAngle(playerid, 263.2809);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == SANG[4]) // Вход в штаб SANG
	{
		SetPlayerPos(playerid, -1113.5087,-1633.5870,59.9490);
		SetPlayerFacingAngle(playerid, 268.8639);
		SetPlayerInterior(playerid, 25);
		SetPlayerVirtualWorld(playerid, 26);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == SANG[5]) // Выход из штаба SANG
	{
		SetPlayerPos(playerid, -1108.9795,-1643.9509,76.3672);
		SetPlayerFacingAngle(playerid, 182.6804);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == SANG[6]) // Вход в ГС SANG
	{
		SetPlayerPos(playerid, 316.50,-167.62,999.59);
		SetPlayerInterior(playerid, 6);
		SetPlayerVirtualWorld(playerid, 25);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == SANG[7]) // Выход из ГС SANG
	{
		SetPlayerPos(playerid, -1065.0778,-1584.4771,76.3672);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == SANG[2]) // Оружейная САНГ
	{
		if(PlayerInfo[playerid][pFraction] != 3) return 1;
		if(GetPVarInt(playerid, "DutyStart") == 1)
		{
			SPD(playerid, DLG_SANGGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Парашют", "Выбрать", "Отмена");
		}
		else
		{
			return 1;
		}
	}
	if(pickupid == SANG[3]) // Раздевалка SANG
	{
		if(PlayerInfo[playerid][pFraction] != 3) return 1;
		if(GetPVarInt(playerid, "DutyStart") == 0)
		{
			SPD(playerid, DLG_SANGSTART, DSL, "{FFFFFF}Раздевалка {2776AB}|| Фракция", "[1] Начать рабочий день", "Выбрать", "Отмена");
		}
		else
		{
			SPD(playerid, DLG_SANGSTART, DSL, "{FFFFFF}Раздевалка {2776AB}|| Фракция", "[1] Закончить рабочий день\n[2] Сменить одежду", "Выбрать", "Отмена");
		}
	}
	if(pickupid == lspd[0]) // Оружейная LSPD
	{
		if(PlayerInfo[playerid][pFraction] != 1) return 1;
		if(GetPVarInt(playerid, "DutyStart") == 1)
		{
			SPD(playerid, DLG_LSPDGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Дубинка", "Выбрать", "Отмена");
		}
		else
		{
			return 1;
		}
	}
	if(pickupid == lspdinvite) // Начало работы LSPD / Переодевание
	{
		if(PlayerInfo[playerid][pFraction] != 1) return 1;
		if(GetPVarInt(playerid, "DutyStart") == 0)
		{
			SPD(playerid, DLG_LSPDSTART, DSL, "{FFFFFF}Раздевалка {2776AB}|| Фракция", "[1] Начать рабочий день", "Выбрать", "Отмена");
		}
		else
		{
			SPD(playerid, DLG_LSPDSTART, DSL, "{FFFFFF}Раздевалка {2776AB}|| Фракция", "[1] Закончить рабочий день\n[2] Сменить одежду", "Выбрать", "Отмена");
		}
	}
	if(pickupid == rifaenter)
	{
		SetPlayerPos(playerid, 2807.5349, -1172.1549, 1025.5703);
		SetPlayerFacingAngle(playerid, 359.1933);
		SetPlayerInterior(playerid, 8);
		SetPlayerVirtualWorld(playerid, 8);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == rifaexit)
	{
		SetPlayerPos(playerid, 2185.9163,-1812.7882,13.5567);
		SetPlayerFacingAngle(playerid, 1.3584);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	SetPVarInt(playerid, "PickupActivated", gettime() + 3);
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

// public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
// {
// 	if((weaponid == 24 || weaponid == 25) && GetPVarInt(playerid, "Tazer") == 1)
// 	{
// 		new Float: Health;
// 		GetPlayerHealth(damagedid,Health);
// 		SetPlayerHealth(damagedid,Health);
// 		ApplyAnimation(damagedid,"PED","KO_skid_front",6.0,0,1,1,1,0);
// 		TogglePlayerControllable(damagedid, 0);
// 		SetPVarInt(damagedid, "OnTazer" , 1);
// 		Timer_Tazer[damagedid] = SetTimerEx("pTazer", 10000, false, "i", damagedid);
// 		GameTextForPlayer(damagedid,"~r~freeze", 5000, 3);
// 	}
//     return 1;
// }

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	if(GetPVarInt(playerid, "EditObject") == 1)
	{
	    new string[144];
	    format(string, sizeof(string), "SPAO(playerid, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f);", index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ);
	    SCM(playerid, 0xDEA4F7AA, string);
	}
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	if(GetPVarInt(playerid, "PickupActivated") > gettime()) return 1;
	for(new h = 0; h < TotalHouses; h++)
	{
		if(pickupid == HouseInfo[h][hPickup])
		{
			SetPVarInt(playerid, "HouseID", h);
			if(HouseInfo[h][hOwned] == 0)
			{
				new string[256];
				format(string, sizeof(string), "{FFFFFF}Номер дома: {6ACDE6}%d\n{FFFFFF}Тип: {6ACDE6}%s\n{FFFFFF}Количество комнат: {6ACDE6}%d\n{FFFFFF}Стоимость: {6ACDE6}%d\n\n{FFFFFF}Владелец: {C20C0C}Отсутствует", HouseInfo[h][hID], HouseInfo[h][hType], HouseInfo[h][hRoomAmount], HouseInfo[h][hCost]);
				SPD(playerid, DLG_HOUSENOWNER, DSM, "{FFFFFF}Информация {29B4EF}|| Дом", string, "Войти", "Закрыть");
			}
			else
			{
				new string[256];
				format(string, sizeof(string), "{FFFFFF}Номер дома: {6ACDE6}%d\n{FFFFFF}Тип: {6ACDE6}%s\n{FFFFFF}Количество комнат: {6ACDE6}%d\n{FFFFFF}Стоимость: {6ACDE6}%d\n\n{FFFFFF}Владелец: {84BA14}%s", HouseInfo[h][hID], HouseInfo[h][hType], HouseInfo[h][hRoomAmount], HouseInfo[h][hCost], HouseInfo[h][hOwner]);
				SPD(playerid, DLG_HOUSEOWNER, DSM, "{FFFFFF}Информация {29B4EF}|| Дом", string, "Войти", "Закрыть");
			}
		}
	}

	for(new i = GetVehiclePoolSize(); i >= 0; i--)
	{
		if(pickupid == Farmcar_pickup[i] && PlayerInfo[playerid][pFraction] == 3 && GetPVarInt(playerid, "DutyStart") == 1)
		{
			if(GetPVarInt(playerid,"LoadMats") == 1)
			{
				new string[64];
				SetPVarInt(playerid, "LoadMats", 0);
				SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
				RemovePlayerAttachedObject(playerid,1);
				VehicleInfo[i][vMaterials] += 1000;
				SCM(playerid, COLOR_INFO, "Вы успешно погрузили материалы в машину.");
				if(VehicleInfo[i][vMaterials] >= 10000) { VehicleInfo[i][vMaterials] = 10000; SCM(playerid, COLOR_DARK_BLUE, "Машина полная");}
				format(string, sizeof(string), "Ресурсов в машине:\n%d/10000", VehicleInfo[i][vMaterials]);
				Update3DTextLabelText(unloadzone3dtext[i], COLOR_DARK_BLUE, string);
			}
			else
			{
				return SCM(playerid, COLOR_INFO, "{FF69B4}У вас ничего нет. Для начала возьмите материалы с подлодки.");
			}
			return true;
		}
	}
	if(pickupid == loadzone && PlayerInfo[playerid][pFraction] == 3 && GetPVarInt(playerid, "DutyStart") == 1)
	{
		new string[64];
		if( GetPVarInt(playerid,"LoadMats") == 1 ) return SCM(playerid, COLOR_INFO, "{FF69B4}Вы уже взяли ресурсы. Погрузите их в машину.");
		SetPVarInt(playerid, "LoadMats", 1);
		SetPlayerSpecialAction (playerid, SPECIAL_ACTION_CARRY);
		SetPlayerAttachedObject(playerid, 1 , 2358, 1,0.11,0.36,0.0,0.0,90.0);
		SCM(playerid, COLOR_INFO, "{FF69B4}Вы взяли {FFFFFF}1000 {FF69B4}ресурсов с подлодки. Погрузите их в машину.");
		if(submarine_mats <=0) return SCM(playerid, COLOR_INFO, "{FF69B4}Подлодка пуста.");
		submarine_mats -= 1000;
		format(string, sizeof(string), "Ресурсов в подлодке:\n%d/500000", submarine_mats);
		Update3DTextLabelText(loadzone3dtext, COLOR_INFO, string);
		return true;
	}
	SetPVarInt(playerid, "PickupActivated", gettime() + 3);
	return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
		if(newkeys == KEY_JUMP && GetPVarInt(playerid, "LoadMats") == 1)
		{
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			RemovePlayerAttachedObject(playerid, 1);
			SCM(playerid, COLOR_ERROR, "Вы уронили ящик.");
			SetPVarInt(playerid, "LoadMats", 0);
		}
		if(newkeys == KEY_YES && GetPVarInt(playerid, "InviteAccept") == 1)
		{
			SPD(playerid, DLG_INVITE, DIALOG_STYLE_MSGBOX, "{37D5D5}Трудоустройство {FFFFFF}|| Фракция", "{FFFFFF}Вы действительно хотите трудоустроиться во фракцию?", "Да", "Нет");
		}
		if(newkeys == KEY_NO && GetPVarInt(playerid, "InviteAccept") == 1)
		{
			new InviterID = GetPVarInt(playerid, "InviterID");
			new string[128];
			format(string, sizeof(string), "[Информация]: {FF69B4}Игрок {FFFFFF}%s[%d] {FF69B4}отказался от вступления в вашу фракцию!", PlayerInfo[playerid][pName], playerid);
			SCM(InviterID, COLOR_INFO, string);
			SetPVarInt(playerid, "InviteAccept", 0);
		}
		if(newkeys == KEY_YES && GetPVarInt(playerid, "SetHouseExitWaypoint") == 1)
		{
			new query[512];
			new Float:fX, Float:fY, Float:fZ, Float:fAngle;
			SetPVarInt(playerid, "SetHouseExitWaypoint", 0);
			GetPlayerPos(playerid, Float:fX, Float:fY, Float:fZ);
			GetPlayerFacingAngle(playerid, fAngle);
			format(query, sizeof(query), "UPDATE `houses` SET `hExitX` = '%f', `hExitY` = '%f', `hExitZ` = '%f', `hExitAngle` = '%f' WHERE `hID` = '%d'", fX, fY, fZ, fAngle, TotalHouses);
			mysql_tquery(dbHandle, query);
			if(GetPVarInt(playerid, "HouseType") == 1 && GetPVarInt(playerid, "HouseInterior") == 1)
			{
				SetPlayerPos(playerid, fX, fY + 2, fZ);
				new vehicleid = CreateVehicle(462, fX, fY + 2, fZ, fAngle, 1, 1, -1);
				PutPlayerInVehicle(playerid, vehicleid, 0);
				SCM(playerid, COLOR_INFO, "[Информация] {7AC5E0}Нажмите клавишу \"Y\" на том месте, где будет расположен спавн автомобиля");
				SetPVarInt(playerid, "SetVehiclePosHouse", 1);
			}
			if(GetPVarInt(playerid, "HouseType") == 1 && GetPVarInt(playerid, "HouseInterior") == 2)
			{
				SetPlayerPos(playerid, fX, fY + 2, fZ);
				new vehicleid = CreateVehicle(462, fX, fY + 2, fZ, fAngle, 1, 1, -1);
				PutPlayerInVehicle(playerid, vehicleid, 0);
				SCM(playerid, COLOR_INFO, "[Информация] {7AC5E0}Нажмите клавишу \"Y\" на том месте, где будет расположен спавн автомобиля");
				SetPVarInt(playerid, "SetVehiclePosHouse", 1);
			}
		}
		if(newkeys == KEY_YES && GetPVarInt(playerid, "SetPickupEnterHouse") == 1)
		{
			new query[768], htype[48], houseint, roomamount;
			new Float:fX, Float:fY, Float:fZ;
			SetPVarInt(playerid, "SetPickupEnterHouse", 0);
			GetPlayerPos(playerid, Float:fX, Float:fY, Float:fZ);
			switch(GetPVarInt(playerid, "HouseType"))
			{
				case 0: htype = "";
				case 1: htype = "Эконом класс";
				case 2: htype = "Средний класс";
				case 3: htype = "Премиум класс";
				case 4: htype = "Элитный класс";
			}
			TotalHouses += 1;
			SetPVarInt(playerid, "HouseID", TotalHouses);
			format(query, sizeof(query), "INSERT INTO `houses` (`hID`, `hOwned`, `hOwner`, `hCost`, `hEnterX`, `hEnterY`, `hEnterZ`, `hType`, `hClass`, `hRoomAmount`, `hRent`, `hInterior`) VALUES ('%d', '0', '', '0', '%f', '%f', '%f', '%s', '%d', '0', '3500', '0')", TotalHouses, fX, fY, fZ, htype, GetPVarInt(playerid, "HouseType"));
			mysql_tquery(dbHandle, query);
			if(GetPVarInt(playerid, "HouseType") == 1) // Эконом класс
			{
				switch(GetPVarInt(playerid, "HouseInterior"))
				{
					case 1: // Burglary house 2
					{
						houseint = 2;
						roomamount = 2;
						format(query, sizeof(query), "UPDATE `houses` SET `hiEnterX` = '225.0679', `hiEnterY` = '1239.8706', `hiEnterZ` = '1082.1406', `hiEnterAngle` = '94.2163', `hWardrobeX` = '223.1142', `hWardrobeY` = '1249.3680', `hWardrobeZ` = '1082.1406', `hRoomAmount` = '%d', `hInterior` = '%d', `hGarage` = '1' WHERE `hID` = '%d'", roomamount, houseint, TotalHouses);
						mysql_tquery(dbHandle, query);
					}
					case 2: // Burglary house 3
					{
						houseint = 1;
						roomamount = 2;
						format(query, sizeof(query), "UPDATE `houses` SET `hiEnterX` = '222.8565', `hiEnterY` = '1288.9363', `hiEnterZ` = '1082.1406', `hiEnterAngle` = '357.9766', `hWardrobeX` = '229.1177', `hWardrobeY` = '1287.0781', `hWardrobeZ` = '1082.1406', `hRoomAmount` = '%d', `hInterior` = '%d', `hGarage` = '1' WHERE `hID` = '%d'", roomamount, houseint, TotalHouses);
						mysql_tquery(dbHandle, query);
					}
				}
			}
			SPD(playerid, DLG_CREATEHOUSECOST, DSI, "{FFFFFF}Создание дома {FEA9D8}|| Стоимость", "{FFFFFF}Введите стоимость будущего дома:", "Далее", "");
		}
		if(newkeys == KEY_SECONDARY_ATTACK && GetPVarInt(playerid, "PlayerIntoHouse") == 1)
		{
			new HouseID = GetPVarInt(playerid, "HouseID");
			switch(HouseInfo[HouseID][hClass])
			{
				case 1:
				{
					switch(HouseInfo[HouseID][hInterior])
					{
						case 1:
						{
							if(IsPlayerInRangeOfPoint(playerid, 1.5, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY], HouseInfo[HouseID][hiEnterZ]))
							{
								if(GetPlayerVirtualWorld(playerid) == HouseID + 100)
								{
									SetPlayerVirtualWorld(playerid, 0);
									SetPlayerInterior(playerid, 0);
									SetPlayerPos(playerid, HouseInfo[HouseID][hExitX], HouseInfo[HouseID][hExitY], HouseInfo[HouseID][hExitZ]);
									SetPlayerFacingAngle(playerid, HouseInfo[HouseID][hExitAngle]);
									SetCameraBehindPlayer(playerid);
								}
							}
						}
						case 2:
						{
							if(IsPlayerInRangeOfPoint(playerid, 1.5, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY], HouseInfo[HouseID][hiEnterZ]))
							{
								if(GetPlayerVirtualWorld(playerid) == HouseID + 100)
								{
									SetPlayerVirtualWorld(playerid, 0);
									SetPlayerInterior(playerid, 0);
									SetPlayerPos(playerid, HouseInfo[HouseID][hExitX], HouseInfo[HouseID][hExitY], HouseInfo[HouseID][hExitZ]);
									SetPlayerFacingAngle(playerid, HouseInfo[HouseID][hExitAngle]);
									SetCameraBehindPlayer(playerid);
								}
							}	
						}
						case 9:
						{
							if(IsPlayerInRangeOfPoint(playerid, 1.5, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY] - 1.8, HouseInfo[HouseID][hiEnterZ]))
							{
								if(GetPlayerVirtualWorld(playerid) == HouseID + 100)
								{
									SetPlayerVirtualWorld(playerid, 0);
									SetPlayerInterior(playerid, 0);
									SetPlayerPos(playerid, HouseInfo[HouseID][hExitX], HouseInfo[HouseID][hExitY], HouseInfo[HouseID][hExitZ]);
									SetPlayerFacingAngle(playerid, HouseInfo[HouseID][hExitAngle]);
									SetCameraBehindPlayer(playerid);
								}
							}
						}
					}
				}
			}
		}
		if(newkeys == KEY_CTRL_BACK && GetPVarInt(playerid, "PlayerIntoHouse") == 1)
		{
			new HouseID = GetPVarInt(playerid, "HouseID");
			if(IsPlayerInRangeOfPoint(playerid, 1.5, HouseInfo[HouseID][hWardrobeX], HouseInfo[HouseID][hWardrobeY], HouseInfo[HouseID][hWardrobeZ]))
			{
				if(PlayerInfo[playerid][pHouse]-1 == HouseID)
				{
					SPD(playerid, DLG_WARDROBEMENU, DSL, "{FFFFFF}Шкаф {29B4EF}|| Дом", "{FFFFFF}[1] Взять материалы\n[2] Взять наркотики\n[3] Положить материалы\n[4] Положить наркотики", "Далее", "Закрыть");
				}
			}
		}
		if(newkeys == KEY_WALK && GetPVarInt(playerid, "PlayerIntoHouse") == 1)
		{
			new HouseID = GetPVarInt(playerid, "HouseID");
			switch(HouseInfo[HouseID][hClass])
			{
				case 1:
				{
					switch(HouseInfo[HouseID][hInterior])
					{
						case 1:
						{
							if(IsPlayerInRangeOfPoint(playerid, 1.5, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY], HouseInfo[HouseID][hiEnterZ]))
							{
								if(HouseInfo[HouseID][hOwned] == 0)
								{
									SPD(playerid, DLG_ALTHOUSEMENU, DSL, "{FFFFFF}Настройки {29B4EF}|| Дом", "{FFFFFF}[1] Купить дом\n[2] Информация о доме", "Выбрать", "Закрыть");
								}
								else
								{
									new string[180], locked[16];
									switch(HouseInfo[HouseID][hLocked])
									{
										case 0: locked = "{BB0000}Закрыть";
										case 1: locked = "{64A21A}Открыть";
									}
									format(string, sizeof(string), "{FFFFFF}[1] %s {FFFFFF}дом\n[2] Улучшить дом\n[3] Информация о доме\n[4] Использовать аптечку {269AAE}[Всего: %d]{FFFFFF}\n[5] Продать дом", locked, HouseInfo[HouseID][hMedKit]);
									SPD(playerid, DLG_ALTHOUSEMENU, DSL, "{FFFFFF}Настройки {29B4EF}|| Дом", string, "Выбрать", "Закрыть");
								}	
							}
						}
						case 2:
						{
							if(IsPlayerInRangeOfPoint(playerid, 1.5, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY], HouseInfo[HouseID][hiEnterZ]))
							{
								if(HouseInfo[HouseID][hOwned] == 0)
								{
									SPD(playerid, DLG_ALTHOUSEMENU, DSL, "{FFFFFF}Настройки {29B4EF}|| Дом", "{FFFFFF}[1] Купить дом\n[2] Информация о доме", "Выбрать", "Закрыть");
								}
								else
								{
									new string[180], locked[16];
									switch(HouseInfo[HouseID][hLocked])
									{
										case 0: locked = "{BB0000}Закрыть";
										case 1: locked = "{64A21A}Открыть";
									}
									format(string, sizeof(string), "{FFFFFF}[1] %s {FFFFFF}дом\n[2] Улучшить дом\n[3] Информация о доме\n[4] Использовать аптечку {269AAE}[Всего: %d]{FFFFFF}\n[5] Продать дом", locked, HouseInfo[HouseID][hMedKit]);
									SPD(playerid, DLG_ALTHOUSEMENU, DSL, "{FFFFFF}Настройки {29B4EF}|| Дом", string, "Выбрать", "Закрыть");
								}
							}
						}
						case 9:
						{
							if(IsPlayerInRangeOfPoint(playerid, 1.5, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY] - 1.8, HouseInfo[HouseID][hiEnterZ]))
							{
								if(HouseInfo[HouseID][hOwned] == 0)
								{
									SPD(playerid, DLG_ALTHOUSEMENU, DSL, "{FFFFFF}Настройки {29B4EF}|| Дом", "{FFFFFF}[1] Купить дом\n[2] Информация о доме", "Выбрать", "Закрыть");
								}
								else
								{
									new string[180], locked[16];
									switch(HouseInfo[HouseID][hLocked])
									{
										case 0: locked = "{BB0000}Закрыть";
										case 1: locked = "{64A21A}Открыть";
									}
									format(string, sizeof(string), "{FFFFFF}[1] %s {FFFFFF}дом\n[2] Улучшить дом\n[3] Информация о доме\n[4] Использовать аптечку {269AAE}[Всего: %d]{FFFFFF}\n[5] Продать дом", locked, HouseInfo[HouseID][hMedKit]);
									SPD(playerid, DLG_ALTHOUSEMENU, DSL, "{FFFFFF}Настройки {29B4EF}|| Дом", string, "Выбрать", "Закрыть");
								}
							}
						}
					}
				}
			}
		}
		if(newkeys == KEY_WALK && IsPlayerInRangeOfPoint(playerid, 1.5, 1130.2950,-1752.0189,13.5802))
		{
		    SelectTextDraw(playerid, 0xFFFFFF00);
		    TogglePlayerControllable(playerid, false);
		    TextDrawSetPreviewModel(rentcar_TD[16], 462);
		    for(new i = 0; i < 22; i++) TextDrawShowForPlayer(playerid, rentcar_TD[i]);
			TextDrawSetString(rentcar_TD[19], "Faggio");
			TextDrawSetString(rentcar_TD[20], "$80");
			SetPVarInt(playerid, "RentCarModel", 462);
		}
	}
	else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		if(newkeys == 512) return callcmd::en(playerid, "");
		if(newkeys == KEY_YES && GetPVarInt(playerid, "SetVehiclePosHouse") == 1)
		{
			SetPVarInt(playerid, "SetVehiclePosHouse", 0);
			new query[512];
			new Float:fX, Float:fY, Float:fZ, Float:fAngle;
			new vehicleid = GetPlayerVehicleID(playerid);
			GetVehiclePos(vehicleid, Float:fX, Float:fY, Float:fZ);
			GetVehicleZAngle(vehicleid, Float:fAngle);
			format(query, sizeof(query), "UPDATE `houses` SET `hCarPosX` = '%f', `hCarPosY` = '%f', `hCarPosZ` = '%f', `hCarAngle` = '%f' WHERE `hID` = '%d'", fX, fY, fZ, fAngle, TotalHouses);
			mysql_tquery(dbHandle, query);
			SCM(playerid, COLOR_INFO, "[Информация] {FFFFFF}Дом успешно создан!");
			format(query, sizeof(query), "SELECT * FROM `houses`");
			TotalHouses = 0;
			mysql_tquery(dbHandle, query, "LoadHouses", "i", playerid);
			DestroyVehicle(vehicleid);
		}
	}
	if(newkeys == KEY_CTRL_BACK && !IsPlayerInAnyVehicle(playerid) || newkeys == 2 && IsPlayerInAnyVehicle(playerid))//kpp-1
	{
		// if(IsPlayerInRangeOfPoint(playerid, 1, 142.2286,1939.8599,19.3014) || IsPlayerInRangeOfPoint(playerid, 1, 127.8147,1943.7101,19.3385))
		// {
		// 	if(gatestatus[0] == 0) { MoveObject(gate[0], 121.138076, 1941.352905, 21.657272,3.0); gatestatus[0] = 1; }
		// 	else if(gatestatus[0] == 1) { MoveObject(gate[0], 134.877975, 1941.352905, 21.657272,3.0); gatestatus[0] = 0; }
		// }
		// if(IsPlayerInRangeOfPoint(playerid, 2, 214.062667, 1875.866455, 13.201104))// garage
		// {
		// 	if(gatestatus[1] == 0) { MoveObject(gate[1], 214.062667, 1875.866455, 8.841090,3.0); gatestatus[1] = 1; }
		// 	else if(gatestatus[1] == 1) { MoveObject(gate[1], 214.062667, 1875.866455, 13.201104,3.0); gatestatus[1] = 0; }
		// }
		// if(IsPlayerInRangeOfPoint(playerid, 5, 344.9378,1798.1331,18.5311))// шлагбаум кпп-2
		// {
		// 	if(gatestatus[2] == 0) { MoveObject(gate[2], 347.687957, 1799.582519, 18.201555+0.004,0.002, 2.399998, -2.800081, 34.699996); gatestatus[2] = 1; }
		// 	else if(gatestatus[2] == 1) { MoveObject(gate[2], 347.687957, 1799.582519, 18.201555+0.004-0.004,0.002, 2.399998, -89.700057, 34.699996); gatestatus[2] = 0; }
		// }
		// if(IsPlayerInRangeOfPoint(playerid, 1, 287.8338,1814.4796,17.6406) || IsPlayerInRangeOfPoint(playerid, 1, 283.6367,1814.5358,17.6406))// ворота внутри базы, у ГШ
		// {
		// 	if(gatestatus[3] == 0) { MoveObject(gate[3], 285.734924, 1833.631225, 19.933525,3.0); gatestatus[3] = 1; }
		// 	else if(gatestatus[3] == 1) { MoveObject(gate[3], 285.734924, 1821.661865, 19.933525,3.0); gatestatus[3] = 0; }
		// }
		if(IsPlayerInRangeOfPoint(playerid, 5, 1544.696777, -1630.804199, 13.012815))// шлагбаум_LSPD
		{
			if(PlayerInfo[playerid][pFraction] == 1 || PlayerInfo[playerid][pFraction] == 2 || PlayerInfo[playerid][pFraction] == 3 || PlayerInfo[playerid][pFraction] == 7) 
			{
				if(gatestatus[4] == 0) { MoveObject(gate[4], 1544.696777, -1630.804199, 13.012815+0.004,0.002, 0.000000, 0.100008, 90.000000); gatestatus[4] = 1; }
		    	else if(gatestatus[4] == 1) { MoveObject(gate[4], 1544.696777, -1630.804199, 13.012815+0.004-0.004,0.002, 0.000000, 89.399986, 90.000000); gatestatus[4] = 0; }
		    }
		    else return 1;
		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1492.8341,1051.0527,-50.4082)) // D_IN
		{
			if(PlayerInfo[playerid][pFraction] == 1 || PlayerInfo[playerid][pFraction] == 2 || PlayerInfo[playerid][pFraction] == 3 || PlayerInfo[playerid][pFraction] == 7) 
			{
				if(gatestatus[5] == 0) {  MoveObject(gate[5], 1491.796386, 1051.502685, -51.427848, 1.5); gatestatus[5] = 1; }
		    	else if(gatestatus[5] == 1) {  MoveObject(gate[5], 1493.127685, 1051.502685, -51.427848, 1.5); gatestatus[5] = 0; }
		    }
		    else return 1;
		}
		if(IsPlayerInRangeOfPoint(playerid, 3, 1472.3370,1031.7941,-50.4082))//// LD_O
		{
			if(PlayerInfo[playerid][pFraction] == 1 || PlayerInfo[playerid][pFraction] == 2 || PlayerInfo[playerid][pFraction] == 3 || PlayerInfo[playerid][pFraction] == 7) 
			{
				if(gatestatus[6] == 0) {  MoveObject(gate[6], 1473.526977, 1032.260131, -51.427848, 1.5); gatestatus[6] = 1;}
			    else if(gatestatus[6] == 1) {  MoveObject(gate[6], 1472.185668, 1032.260131, -51.427848, 1.5); gatestatus[6] = 0; }
		    }
		    else return 1;

		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1472.6875,1039.2444,-50.4082))// dopros_1
		{
			if(PlayerInfo[playerid][pFraction] == 1 || PlayerInfo[playerid][pFraction] == 2 || PlayerInfo[playerid][pFraction] == 3 || PlayerInfo[playerid][pFraction] == 7) 
			{
				if(gatestatus[7] == 0) {  MoveObject(gate[7], 1473.152587, 1038.285888, -51.412124, 1.5); gatestatus[7] = 1; }
			    else if(gatestatus[7] == 1) {  MoveObject(gate[7], 1473.152587, 1039.616333, -51.412124, 1.5); gatestatus[7] = 0; }
		    }
		    else return 1;
		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1472.6873,1044.7306,-50.4082))// dopros_2
		{
			if(PlayerInfo[playerid][pFraction] == 1 || PlayerInfo[playerid][pFraction] == 2 || PlayerInfo[playerid][pFraction] == 3 || PlayerInfo[playerid][pFraction] == 7) 
			{
				if(gatestatus[8] == 0) {  MoveObject(gate[8], 1473.152587, 1045.661499, -51.412124, 1.5); gatestatus[8] = 1; }
			    else if(gatestatus[8] == 1) {  MoveObject(gate[8], 1473.152587, 1044.330810, -51.412124, 1.5); gatestatus[8] = 0; }
		    }
		    else return 1;
		}
		if(IsPlayerInRangeOfPoint(playerid, 3, 1492.9064,1031.8044,-50.4082))// RD_O
		{
			if(PlayerInfo[playerid][pFraction] == 1 || PlayerInfo[playerid][pFraction] == 2 || PlayerInfo[playerid][pFraction] == 3 || PlayerInfo[playerid][pFraction] == 7) 
			{
				if(gatestatus[9] == 0) {  MoveObject(gate[9], 1495.965209, 1032.274047, -51.421325, 1.5); gatestatus[9] = 1; }
			    else if(gatestatus[9] == 1) {  MoveObject(gate[9], 1494.634155, 1032.274047, -51.421325, 1.5); gatestatus[9] = 0; }
		    }
		    else return 1;
		}
		if(IsPlayerInRangeOfPoint(playerid, 15, -979.3566, -1720.7438, 77.5703))// SANG_ворота
		{
			GameTextForPlayer(playerid, "~w~PRESS ~r~H", 3000, 1);
			if(PlayerInfo[playerid][pFraction] == 1 || PlayerInfo[playerid][pFraction] == 2 || PlayerInfo[playerid][pFraction] == 3 || PlayerInfo[playerid][pFraction] == 7)
			{
				if(gatestatus[10] == 0) {  MoveObject(gate[10], -979.434020, -1705.194702, 79.593902, 3.5); gatestatus[10] = 1; }
		    	else if(gatestatus[10] == 1) {  MoveObject(gate[10], -979.041015, -1714.996704, 79.593902, 3.5); gatestatus[10] = 0; }
			}
		    else return 1;
		}
		if(IsPlayerInRangeOfPoint(playerid, 2, 204.32001, 1869.49805, 11.841))
		{
			new vehicleid = GetPlayerVehicleID(playerid);
            if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
            {
                SetVehiclePos(vehicleid, -125.457, -103.603, -37.3296);
                SetVehicleZAngle(vehicleid, 262.1269);
                SetVehicleVirtualWorld(vehicleid, 18);
				SetPlayerVirtualWorld(playerid, 18);
 	   			SetCameraBehindPlayer(playerid);
            }
            else
            {
                SetPlayerPos(playerid, -125.457, -103.603, -38.3296);
				SetPlayerFacingAngle(playerid, 262.1269);
				SetPlayerVirtualWorld(playerid, 18);
 	    		SetCameraBehindPlayer(playerid);
            }
		}
		if(IsPlayerInRangeOfPoint(playerid, 2, -125.457, -103.603, -39.33))
		{
			new vehicleid = GetPlayerVehicleID(playerid);
            if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
            {
                SetVehiclePos(vehicleid, 206.4904,1869.5320,12.8880);
                SetVehicleZAngle(vehicleid, 270.8380);
                SetVehicleVirtualWorld(vehicleid, 0);
				SetPlayerVirtualWorld(playerid, 0);
            }
            else
            {
                SetPlayerPos(playerid, 204.9461,1869.6157,13.1406);
				SetPlayerFacingAngle(playerid, 270.8380);
				SetPlayerVirtualWorld(playerid, 0);
 	    		SetCameraBehindPlayer(playerid);
            }
		}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &weapon, &bodypart) 
{
	if((weapon == 24 || weapon == 25 || weapon == 3) && GetPVarInt(issuerid, "Tazer") == 1)
	{
		new Float: Health;
		GetPlayerHealth(playerid,Health);
		SetPlayerHealth(playerid,Health);
		TogglePlayerControllable(playerid, 0);
		ClearAnimations(playerid);
		ApplyAnimation(playerid,"PED","KO_skid_front",6.0,0,1,1,1,0);
		SetPVarInt(playerid, "OnTazer" , 1);
		Timer_Tazer[playerid] = SetTimerEx("pTazer", 10000, false, "i", playerid);
		GameTextForPlayer(playerid,"~r~freeze", 5000, 3);
		return false;
	}
	if(weapon == 3)
	{
		new Float: Health;
		GetPlayerHealth(playerid,Health);
		SetPlayerHealth(playerid,Health);
		TogglePlayerControllable(playerid, 0);
		ClearAnimations(playerid);
		ApplyAnimation(playerid,"PED","KO_skid_front",6.0,0,1,1,1,0);
		SetPVarInt(playerid, "OnTazer" , 1);
		Timer_Tazer[playerid] = SetTimerEx("pTazer", 10000, false, "i", playerid);
		GameTextForPlayer(playerid,"~r~freeze", 5000, 3);
		return false;
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(PlayerAFK[playerid] > -2)
	{
	    if(PlayerAFK[playerid] > 2) SetPlayerChatBubble(playerid, "", -1, 25.0, 200);
	    PlayerAFK[playerid] = 0;
	}
	if(GetPlayerMoney(playerid) != PlayerInfo[playerid][pMoney])
	{
	    ResetPlayerMoney(playerid);
	    GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
	}
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DLG_REGPASSWORD:
		{
			if(response)
			{
				if(!strlen(inputtext) || strlen(inputtext) < 6 || strlen(inputtext) > 24)
				{
					ShowRegister(playerid);
					return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Длина пароля должна быть от 6-ти до 24-х символов.");
				}
				else
				{
					new Regex: Reg_Password = Regex_New("^[a-zA-Z0-9]{1,}$");
					if(Regex_Check(inputtext, Reg_Password))
					{
						strmid(PlayerInfo[playerid][pPassword], inputtext, 0, strlen(inputtext), 24);
						SPD(playerid, DLG_REGEMAIL, DSI, "{FFFFFF}Регистрация {F385D5}|| Электронная почта [2/5]", "{FFFFFF}Введите Ваш адрес электронной почты\nИспользуя его, Вы сможете восстановить данные от аккаунта\nв случае взлома или утери данных.\n\nУбедитесь в правильности ввода и нажмите \"Далее\"", "Далее", "Пропустить");
					}
					else
					{
						ShowRegister(playerid);
						return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Пароль может состоять только из латинских символов!");
					}
					Regex_Delete(Reg_Password);
				}
			}
			else
			{
				SCM(playerid, COLOR_ERROR, "[Выход]: {9AAAAB}Используйте \"/q\", чтобы покинуть сервер!");
				return Kick(playerid);
			}
		}
		case DLG_REGEMAIL:
		{
			if(response)
			{
				if(!strlen(inputtext)) return SPD(playerid, DLG_REGEMAIL, DSI, "{FFFFFF}Регистрация {F385D5}|| Электронная почта [2/5]", "{FFFFFF}Введите Ваш адрес электронной почты\nИспользуя его, Вы сможете восстановить данные от аккаунта\nв случае взлома или утери данных.\n\nУбедитесь в правильности ввода и нажмите \"Далее\"", "Далее", "Пропустить");
				new Regex: Reg_Email = Regex_New("^([-A-Za-z0-9_]+\\.)*[-A-Za-z0-9_]+@([A-Za-z0-9][-A-Za-z0-9]*\\.)+[A-Za-z]{2,6}$");
				if(Regex_Check(inputtext, Reg_Email))
				{
					strmid(PlayerInfo[playerid][pEmail], inputtext, 0, strlen(inputtext), 64);
					SPD(playerid, DLG_REGREFERAL, DSI, "{FFFFFF}Регистрация {F385D5}|| Ник пригласившего игрока [3/5]", "{FFFFFF}Если Вы узнали о нашем сервере от своего друга\nто введите его ник в поле ниже и нажмите \"Далее\"\n\n{1295CD}При достижении вами 4-го уровня он получит вознаграждение!", "Далее", "Пропустить");
				}
				else
				{
					SPD(playerid, DLG_REGEMAIL, DSI, "{FFFFFF}Регистрация {F385D5}|| Электронная почта [2/5]", "{FFFFFF}Введите Ваш адрес электронной почты\nИспользуя его, Вы сможете восстановить данные от аккаунта\nв случае взлома или утери данных.\n\nУбедитесь в правильности ввода и нажмите \"Далее\"", "Далее", "Пропустить");
					SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Электронная почта введена некорректно!");
				}
				Regex_Delete(Reg_Email);
			}
			else
			{
				PlayerInfo[playerid][pEmail] = 0;
				SPD(playerid, DLG_REGREFERAL, DSI, "{FFFFFF}Регистрация {F385D5}|| Ник пригласившего игрока [3/5]", "{FFFFFF}Если Вы узнали о нашем сервере от своего друга\nто введите его ник в поле ниже и нажмите \"Далее\"\n\n{1295CD}При достижении вами 4-го уровня он получит вознаграждение!", "Далее", "Пропустить");
			}
		}
		case DLG_REGREFERAL:
		{
			if(response)
			{
				if(!strlen(inputtext) || strlen(inputtext) < 4 || strlen(inputtext) > 24)
				{
					SPD(playerid, DLG_REGREFERAL, DSI, "{FFFFFF}Регистрация {F385D5}|| Ник пригласившего игрока [3/5]", "{FFFFFF}Если Вы узнали о нашем сервере от своего друга\nто введите его ник в поле ниже и нажмите \"Далее\"\n\n{1295CD}При достижении вами 4-го уровня он получит вознаграждение!", "Далее", "Пропустить");
					return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Ник пригласившего Вас игрока введён некорректно!");
				}
				else
				{
					static const fmt_query[] = "SELECT * FROM `users` WHERE `pName` = '%s'";
					new query[sizeof(fmt_query)+(- 2 + MAX_PLAYER_NAME)];
					format(query, sizeof(query), fmt_query, inputtext);
					mysql_tquery(dbHandle, query, "CheckReferal", "is", playerid, inputtext);
				}
			}
			else
			{
				PlayerInfo[playerid][pReferal] = 0;
				ShowRules(playerid);
			}
		}
		case DLG_REGRULES:
		{
			if(response) SPD(playerid, DLG_REGGENDER, DSM, "{FFFFFF}Регистрация {F385D5}|| Выбор пола [5/5]", "{FFFFFF}Выберите пол вашего будущего персонажа.", "Мужской", "Женский");
			else SPD(playerid, DLG_REGGENDER, DSM, "{FFFFFF}Регистрация {F385D5}|| Выбор пола [5/5]", "{FFFFFF}Выберите пол вашего будущего персонажа.", "Мужской", "Женский");
		}
		case DLG_REGGENDER:
		{
			if(response)
			{
				new query[512], ip[16], year, month, day;
				PlayerInfo[playerid][pGender] = 1;
				GetPlayerIp(playerid, ip, sizeof(ip));
				gmtime(gettime(), year, month, day);
				format(query, sizeof(query), "INSERT INTO `users` (`pName`, `pPassword`, `pEmail`, `pReferal`, `pGender`, `pRegData`, `pRegIP`) VALUES ('%s', '%s', '%s', '%s', '%d', '%02d.%02d.%04d', '%s')", PlayerInfo[playerid][pName], MD5_Hash(PlayerInfo[playerid][pPassword]), PlayerInfo[playerid][pEmail], PlayerInfo[playerid][pReferal], PlayerInfo[playerid][pGender], day, month, year, ip);
				mysql_tquery(dbHandle, query);
				format(query, sizeof(query), "SELECT * FROM `users` WHERE `pName` = '%s' LIMIT 1", PlayerInfo[playerid][pName]);
   				mysql_tquery(dbHandle, query, "LoadAccount", "i", playerid);
				SCM(playerid, COLOR_WHITE, "");
				SCM(playerid, COLOR_WHITE, "Регистрация завершена.");
				SCM(playerid, 0xDFCB1AAA, "Выберите внешность вашего будущего персонажа и нажмите \"SELECT\".");
				TogglePlayerControllable(playerid, 0);
				StopAudioStreamForPlayer(playerid);
				SpawnPlayer(playerid);
			}
			else
			{
				new query[512], ip[16], year, month, day;
				PlayerInfo[playerid][pGender] = 2;
				GetPlayerIp(playerid, ip, sizeof(ip));
				gmtime(gettime(), year, month, day);
				format(query, sizeof(query), "INSERT INTO `users` (`pName`, `pPassword`, `pEmail`, `pReferal`, `pGender`, `pRegData`, `pRegIP`) VALUES ('%s', '%s', '%s', '%s', '%d', '%02d.%02d.%04d', '%s')", PlayerInfo[playerid][pName], MD5_Hash(PlayerInfo[playerid][pPassword]), PlayerInfo[playerid][pEmail], PlayerInfo[playerid][pReferal], PlayerInfo[playerid][pGender], day, month, year, ip);
				mysql_tquery(dbHandle, query);
				format(query, sizeof(query), "SELECT * FROM `users` WHERE `pName` = '%s' LIMIT 1", PlayerInfo[playerid][pName]);
   				mysql_tquery(dbHandle, query, "LoadAccount", "i", playerid);
				SCM(playerid, COLOR_WHITE, "");
				SCM(playerid, COLOR_WHITE, "Регистрация завершена.");
				SCM(playerid, 0xDFCB1AAA, "Выберите внешность вашего будущего персонажа и нажмите \"SELECT\".");
				TogglePlayerControllable(playerid, 0);
				StopAudioStreamForPlayer(playerid);
				SpawnPlayer(playerid);
			}
		}
		case DLG_AUTHORIZATION:
		{
			if(response)
			{
				static const fmt_query[] = "SELECT * FROM `users` WHERE `pName` = '%s' AND `pPassword` = '%s' LIMIT 1";
				new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)+(-2+24)];
				strmid(PlayerInfo[playerid][pPassword], inputtext, 0, strlen(inputtext), 24);
				format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pName], MD5_Hash(PlayerInfo[playerid][pPassword]));
				mysql_tquery(dbHandle, query, "LoadAccount", "i", playerid);
			}
			else
			{
				SCM(playerid, COLOR_ERROR, "[Выход]: {9AAAAB}Используйте \"/q\", чтобы покинуть сервер!");
				return Kick(playerid);
			}
		}
		case DLG_ASK:
		{
			new string[256];
			if(!response) return 1;
			switch(QInfo[TotalQuestions][qID])
			{
				case 0..20: // 
				{
					format(string, sizeof(string), "%s", QInfo[QInfo[TotalQuestions][qID]][qQuestion]);
					SPD(playerid, DLG_ASK_SEND, DIALOG_STYLE_MSGBOX, "АСКИ", string, "1", "2");
				}
			}
		}
		case DLG_ASK_SEND:
		{
			if(response)
			{
				SCM(playerid, COLOR_ERROR, "MSG1");
			}
			else
			{
				SCM(playerid, COLOR_ERROR, "MSG2");
			}
		}
		case DLG_ADMINLOGIN:
		{
			if(!response) return 1;
			if(GetPVarInt(playerid, "FirstAdminLogin") == 1)
			{
				if(!strlen(inputtext) || strlen(inputtext) < 4 || strlen(inputtext) > 16)
				{
					SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Длина пароля должна быть от 4-х до 16-ти символов!");
					return SPD(playerid, DLG_ADMINLOGIN, DSI, "{FFFFFF}Админ-панель {F385D5}|| Авторизация", "{FFFFFF}Введите ваш будущий пароль от админ-панели.\n\n{1295CD}Пароль должен иметь длину от 4-х до 16-ти символов!", "Далее", "Отмена");
				}
				else
				{
					strmid(AdminInfo[playerid][aPassword], inputtext, 0, strlen(inputtext), 16);
					static const fmt_query[] = "INSERT INTO `admins` (`aName`, `aPassword`, `aLastOnline`, `aLogged`) VALUES ('%s', '%s', '%04d.%02d.%02d %02d:%02d', '%d')";
					new year, month, day, hour, minute, query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)+33], string[128];
					gmtime(gettime(), year, month, day, hour, minute);
					format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pName], MD5_Hash(AdminInfo[playerid][aPassword]), year, month, day, hour + 3, minute, AdminInfo[playerid][aLogged]);
					mysql_tquery(dbHandle, query);
					format(string, sizeof(string), "Ваш админ-пароль: {A0DE2E}%s", AdminInfo[playerid][aPassword]);
					SCM(playerid, 0xE06C54FF, string);
					format(query, sizeof(query), "SELECT * FROM `admins` WHERE `aName` = '%s' AND `aPassword` = '%s'", PlayerInfo[playerid][pName], MD5_Hash(AdminInfo[playerid][aPassword]));
					mysql_tquery(dbHandle, query, "LoadAdmin", "i", playerid);
				}
			}
			else
			{
				if(!strlen(inputtext) || strlen(inputtext) < 4 || strlen(inputtext) > 16)
				{
					SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Длина пароля должна быть от 4-х до 16-ти символов!");
					return SPD(playerid, DLG_ADMINLOGIN, DSP, "{FFFFFF}Админ-панель {F385D5}|| Авторизация", "{FFFFFF}Введите ваш пароль от админ-панели.", "Далее", "Отмена");
				}
				else
				{
					strmid(AdminInfo[playerid][aPassword], inputtext, 0, strlen(inputtext), 16);
					static const fmt_query[] = "SELECT * FROM `admins` WHERE `aName` = '%s' AND `aPassword` = '%s'";
					new query[128];
					format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pName], MD5_Hash(AdminInfo[playerid][aPassword]));
					mysql_tquery(dbHandle, query, "LoadAdmin", "i", playerid);
				}
			}
		}
		case DLG_FMATS:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0..14: // Los Santos Police Department
				{
					SetPVarInt(playerid, "FractionNumber", listitem);
					SPD(playerid, DLG_FMATS_SET, DSI, "{FFFFFF}Управление {2776AB}|| Установить материалы", "Укажите количество материалов", "Выбрать", "Отмена");
				}
			}
		}
		case DLG_FMATS_SET:
		{
			if(!response) return 1;
			new FractionNumber = GetPVarInt(playerid, "FractionNumber");
			new query[128], amount;
			if(sscanf(inputtext, "d", amount)) return SPD(playerid, DLG_FMATS_SET, DSI, "{FFFFFF}Управление {2776AB}|| Установить материалы", "Укажите количество материалов", "Выбрать", "Отмена");
			FracInfo[FractionNumber][fMaterials] = amount;
			FractionNumber += 1;
			if(amount > 500000) 
			{
				SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Количество материалов не может быть больше 500.000!"); 
				return SPD(playerid, DLG_FMATS_SET, DSI, "{FFFFFF}Управление {2776AB}|| Установить материалы", "Укажите количество материалов", "Выбрать", "Отмена");
			}
			format(query, sizeof(query), "UPDATE `fractions` SET `fMaterials` = '%d' WHERE `fID` = '%d' LIMIT 1", amount, FractionNumber);
			mysql_tquery(dbHandle, query);
			SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Вы установили количество материалов!");
		}
		case DLG_UNLOAD_SANG:
		{
			if(!response) return RemovePlayerFromVehicle(playerid);
			VehicleInfo[GetPlayerVehicleID(playerid)][vLoading] = 0;
			SetPVarInt(playerid, "UnLoadToMainSkladStart", 1);
			SetPlayerCheckpoint(playerid, -1075.8771,-1587.6854,76.3913, 10.0);
			DestroyDynamicPickup(Farmcar_pickup[GetPlayerVehicleID(playerid)]);
			Delete3DTextLabel(unloadzone3dtext[GetPlayerVehicleID(playerid)]);
		}
		case DLG_LOADERINVITE:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0:
				{
					if(GetPVarInt(playerid, "LoaderInvite") == 0)
					{
						SetPlayerVirtualWorld(playerid, 1 + playerid);
						SetPlayerPos(playerid, 2644.7295,-2219.4492,13.5501);
						SetPlayerFacingAngle(playerid, 243.4756);
						SetPlayerCameraPos(playerid, 2647.0320, -2220.9819, 13.5469);
						SetPlayerCameraLookAt(playerid, 2644.5530, -2219.7446, 13.5501);
						TogglePlayerControllable(playerid, 0);
						SetPlayerSkin(playerid, 8);
						SetPVarInt(playerid, "LoaderInviteSkin", 8);
						for(new i = 0; i < 10; i++) TextDrawShowForPlayer(playerid, selectskinloader[i]);
						SelectTextDraw(playerid, 0x3896D3FF);
					}
					else
					{

					}
				}
				case 1:
				{
					
				}
			}
		}
		case DLG_INVITE:
		{
			if(!response) return 1;
			new InviterID = GetPVarInt(playerid, "InviterID");
			switch(PlayerInfo[InviterID][pFraction])
			{
				case 1: // Los Santos Police Department
				{

					PlayerInfo[playerid][pFraction] = 1;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 280); PlayerInfo[playerid][pFractionSkin] = 280; }
						case 2: { SetPlayerSkin(playerid, 306); PlayerInfo[playerid][pFractionSkin] = 306; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SetPlayerColor(playerid, 0x110CE7FF);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}Los Santos Police Department.");
				}
				case 2: // Federal Bureau of Investigation
				{
					PlayerInfo[playerid][pFraction] = 2;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 286); PlayerInfo[playerid][pFractionSkin] = 286; }
						case 2: { SetPlayerSkin(playerid, 141); PlayerInfo[playerid][pFractionSkin] = 141; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}Federal Bureau of Investigation.");
				}
				case 3: // San Andreas National Guard
				{
					PlayerInfo[playerid][pFraction] = 3;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 287); PlayerInfo[playerid][pFractionSkin] = 287; }
						case 2: { SetPlayerSkin(playerid, 191); PlayerInfo[playerid][pFractionSkin] = 191; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}San Andreas National Guard.");
				}
				case 4: // Emergency Medical Service
				{
					PlayerInfo[playerid][pFraction] = 4;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 274); PlayerInfo[playerid][pFractionSkin] = 274; }
						case 2: { SetPlayerSkin(playerid, 219); PlayerInfo[playerid][pFractionSkin] = 219; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}Emergency Medical Service.");
				}
				case 5: // La Cosa Nostra
				{
					PlayerInfo[playerid][pFraction] = 5;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 124); PlayerInfo[playerid][pFractionSkin] = 124; }
						case 2: { SetPlayerSkin(playerid, 263); PlayerInfo[playerid][pFractionSkin] = 263; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}La Cosa Nostra.");
				}
				case 6: // Yakuza
				{
					PlayerInfo[playerid][pFraction] = 6;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 123); PlayerInfo[playerid][pFractionSkin] = 123; }
						case 2: { SetPlayerSkin(playerid, 169); PlayerInfo[playerid][pFractionSkin] = 169; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}Yakuza.");
				}
				case 7: // Government
				{
					PlayerInfo[playerid][pFraction] = 7;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 57); PlayerInfo[playerid][pFractionSkin] = 57; }
						case 2: { SetPlayerSkin(playerid, 216); PlayerInfo[playerid][pFractionSkin] = 216; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}Government.");
				}
				case 8: // San Andreas News
				{
					PlayerInfo[playerid][pFraction] = 8;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 188); PlayerInfo[playerid][pFractionSkin] = 188; }
						case 2: { SetPlayerSkin(playerid, 211); PlayerInfo[playerid][pFractionSkin] = 211; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}San Andreas News.");
				}
				case 9: // The Ballas Gang
				{
					PlayerInfo[playerid][pFraction] = 9;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 103); PlayerInfo[playerid][pFractionSkin] = 103; }
						case 2: { SetPlayerSkin(playerid, 195); PlayerInfo[playerid][pFractionSkin] = 195; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}The Ballas Gang.");
				}
				case 10: // Los Santos Vagos
				{
					PlayerInfo[playerid][pFraction] = 10;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 108); PlayerInfo[playerid][pFractionSkin] = 108; }
						case 2: { SetPlayerSkin(playerid, 190); PlayerInfo[playerid][pFractionSkin] = 190; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}Los Santos Vagos.");
				}
				case 11: // Russian Mafia
				{
					PlayerInfo[playerid][pFraction] = 11;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 111); PlayerInfo[playerid][pFractionSkin] = 111; }
						case 2: { SetPlayerSkin(playerid, 214); PlayerInfo[playerid][pFractionSkin] = 214; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}Russian Mafia.");
				}
				case 12: // The Grove Street
				{
					PlayerInfo[playerid][pFraction] = 12;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 105); PlayerInfo[playerid][pFractionSkin] = 105; }
						case 2: { SetPlayerSkin(playerid, 56); PlayerInfo[playerid][pFractionSkin] = 56; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}The Grove Street.");
				}
				case 13: // Varios Los Aztecas
				{
					PlayerInfo[playerid][pFraction] = 13;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 114); PlayerInfo[playerid][pFractionSkin] = 114; }
						case 2: { SetPlayerSkin(playerid, 41); PlayerInfo[playerid][pFractionSkin] = 41; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}Varios Los Aztecas.");
				}
				case 14: // The Rifa Gang
				{
					PlayerInfo[playerid][pFraction] = 14;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 175); PlayerInfo[playerid][pFractionSkin] = 175; }
						case 2: { SetPlayerSkin(playerid, 226); PlayerInfo[playerid][pFractionSkin] = 226; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}The Rifa Gang.");
				}
				case 15: // Hell’s Angels MC
				{
					PlayerInfo[playerid][pFraction] = 15;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 247); PlayerInfo[playerid][pFractionSkin] = 247; }
						case 2: { SetPlayerSkin(playerid, 298); PlayerInfo[playerid][pFractionSkin] = 298; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}Hell’s Angels MC.");
				}
				case 16: // Outlaws MC
				{
					PlayerInfo[playerid][pFraction] = 16;
					PlayerInfo[playerid][pRank] = 1;
					switch(PlayerInfo[playerid][pGender])
					{
						case 1: { SetPlayerSkin(playerid, 247); PlayerInfo[playerid][pFractionSkin] = 247; }
						case 2: { SetPlayerSkin(playerid, 298); PlayerInfo[playerid][pFractionSkin] = 298; }
					}
					SetPVarInt(playerid, "DutyStart", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы приняты во фракцию {FFFFFF}Outlaws MC.");
				}
			}
			switch(PlayerInfo[playerid][pFraction])
			{
				case 1: SetPlayerColor(playerid, 0x110CE7FF);
				case 2: SetPlayerColor(playerid, 0x313131AA);
				case 3: SetPlayerColor(playerid, 0x51964DFF);
				case 4: SetPlayerColor(playerid, 0x954F4FFF);
				case 5: SetPlayerColor(playerid, 0xDDA701FF);
				case 6: SetPlayerColor(playerid, 0xFF0000AA);
				case 7: SetPlayerColor(playerid, 0x114D71FF);
				case 8: SetPlayerColor(playerid, 0x5F9EA0FF);
				case 9: SetPlayerColor(playerid, 0xB313E7FF);
				case 10: SetPlayerColor(playerid, 0xDBD604AA);
				case 12: SetPlayerColor(playerid, 0x009F00AA);
				case 13: SetPlayerColor(playerid, 0x01FCFFC8);
				case 14: SetPlayerColor(playerid, 0x40848BFF);
			}
			SetPVarInt(playerid, "InviteAccept", 0);
			new query[128], string[128];
			format(string, sizeof(string), "[Информация]: {FF69B4}Игрок {FFFFFF}%s[%d] {FF69B4}принял ваше приглашение во фракцию.", PlayerInfo[playerid][pName], playerid);
			SCM(InviterID, COLOR_INFO, string);
			format(query, sizeof(query), "UPDATE `users` SET `pFraction` = '%d', `pRank` = '%d', `pFractionSkin` = '%d' WHERE `pName` = '%s'", PlayerInfo[playerid][pFraction], PlayerInfo[playerid][pRank], PlayerInfo[playerid][pFractionSkin], PlayerInfo[playerid][pName]);
			mysql_tquery(dbHandle, query);
		}
		case DLG_MANAGER_MENU:
		{
			if(!response) return 1;
			new string[128];
			switch(listitem)
			{
				case 0: // Выдача средств фракции
				{
					format(string, sizeof(string), "{FFFFFF}Панель управления {F385D5}|| Выделить средства организации");
					SPD(playerid, DLG_MANAGER_FRAK, DSL, string, "1. Los-Santos Police Department\n2. San-Andreas National Guard\n3. Federal Bureau of Investigation\n4. Emergency Medical Services\n5. San-Andreas News", "Далее", "Отмена");
				}
				case 1: // Настроить зарплату на подработках
				{
					//format(string, sizeof(string), "{FFFFFF}Панель управления {F385D5}|| Зарплата на подработках", PlayerInfo[params[0]][pName], params[0]);
					//SPD(playerid, DLG_MANAGER_MENU, DSL, string, "1. Выделить средства организации\n2. Настроить зарплату на подработках\n3. Налоговые операции\n4. Главы организаций\n5. Полная информация", "Далее", "Отмена");
				}
				case 2: // Налоговые операции
				{
					//format(string, sizeof(string), "{FFFFFF}Панель управления {F385D5}|| Налоговые операции", PlayerInfo[params[0]][pName], params[0]);
					//SPD(playerid, DLG_MANAGER_MENU, DSL, string, "1. Выделить средства организации\n2. Настроить зарплату на подработках\n3. Налоговые операции\n4. Главы организаций\n5. Полная информация", "Далее", "Отмена");
				}
				case 3: // Главы организаций
				{
					//format(string, sizeof(string), "{FFFFFF}Панель управления {F385D5}|| Главы организаций", PlayerInfo[params[0]][pName], params[0]);
					//SPD(playerid, DLG_MANAGER_MENU, DSL, string, "1. Выделить средства организации\n2. Настроить зарплату на подработках\n3. Налоговые операции\n4. Главы организаций\n5. Полная информация", "Далее", "Отмена");
				}
				case 4: // Полная информация
				{
					//format(string, sizeof(string), "{FFFFFF}Панель управления {F385D5}|| Полная информация", PlayerInfo[params[0]][pName], params[0]);
					//SPD(playerid, DLG_MANAGER_MENU, DSL, string, "1. Выделить средства организации\n2. Настроить зарплату на подработках\n3. Налоговые операции\n4. Главы организаций\n5. Полная информация", "Далее", "Отмена");
				}
			}
		}
		case DLG_MANAGER_FRAK:
		{
			if(!response) return 1;
			new string[256];
			switch(listitem)
			{
				case 0: // Los-Santos Police Department
				{
					format(string, sizeof(string), "\tLos-Santos Police Department\nБюджет организации: %d\nУкажите сумму которую вы хотите выделить данной организации", FracInfo[0][fBank]);
					SPD(playerid, DLG_MANAGER_FRAK_BANK, DSI, "{FFFFFF}Панель управления {F385D5}|| Выделить средства организации", string, "Отправить", "Отмена");
					SetPVarInt(playerid, "Frak_Number", 0);
				}
				case 1: // San-Andreas National Guard
				{
					format(string, sizeof(string), "\tSan-Andreas National Guard\nБюджет организации: %d\nУкажите сумму которую вы хотите выделить данной организации", FracInfo[2][fBank]);
					SPD(playerid, DLG_MANAGER_FRAK_BANK, DSI, "{FFFFFF}Панель управления {F385D5}|| Выделить средства организации", string, "Отправить", "Отмена");
					SetPVarInt(playerid, "Frak_Number", 2);
				}
				case 2: // Federal Bureau of Investigation
				{
					format(string, sizeof(string), "\tFederal Bureau of Investigation\nБюджет организации: %d\nУкажите сумму которую вы хотите выделить данной организации", FracInfo[1][fBank]);
					SPD(playerid, DLG_MANAGER_FRAK_BANK, DSI, "{FFFFFF}Панель управления {F385D5}|| Выделить средства организации", string, "Отправить", "Отмена");
					SetPVarInt(playerid, "Frak_Number", 1);
				}
				case 3: // Emergency Medical Services
				{
					format(string, sizeof(string), "\tEmergency Medical Services\nБюджет организации: %d\nУкажите сумму которую вы хотите выделить данной организации", FracInfo[3][fBank]);
					SPD(playerid, DLG_MANAGER_FRAK_BANK, DSI, "{FFFFFF}Панель управления {F385D5}|| Выделить средства организации", string, "Отправить", "Отмена");
					SetPVarInt(playerid, "Frak_Number", 3);
				}
				case 4: // San-Andreas News
				{
					format(string, sizeof(string), "\tSan-Andreas News\nБюджет организации: %d\nУкажите сумму которую вы хотите выделить данной организации", FracInfo[7][fBank]);
					SPD(playerid, DLG_MANAGER_FRAK_BANK, DSI, "{FFFFFF}Панель управления {F385D5}|| Выделить средства организации", string, "Отправить", "Отмена");
					SetPVarInt(playerid, "Frak_Number", 7);
				}
			}
		}
		case DLG_MANAGER_FRAK_BANK:
		{
			if(!response) return 1;
			new string[256], query[256], amount;
			new fraknum = GetPVarInt(playerid, "Frak_Number");
			if(sscanf(inputtext, "d", amount)) return SPD(playerid, DLG_MANAGER_FRAK_BANK, DSI, "{FFFFFF}Панель управления {F385D5}|| Выделить средства организации", string, "Отправить", "Отмена");
			if(amount > 10000000) return SCM(playerid, COLOR_ERROR, "[Ошибка]{9AAAAB} Количество сивмолов не должно превышать 6-ти.");
			FracInfo[fraknum][fBank] += amount;
			format(query, sizeof(query), "UPDATE `fractions` SET `fBank` = '%d' WHERE `fID` = '%d'", FracInfo[fraknum][fBank], fraknum+1);
			mysql_tquery(dbHandle, query);
			format(string, sizeof(string), "[Информация] {FF69B4}Вы пополнили баланс организации %s. Новый баланс: %d", FracInfo[fraknum][fName], FracInfo[fraknum][fBank]);
			SCM(playerid, COLOR_INFO, string);
		}
		case DLG_SETLEADER:
		{
			if(!response) return 1;
			new LeaderID = GetPVarInt(playerid, "LeaderID");
			new query[128];
			format(query, sizeof(query), "SELECT * FROM `fractions` WHERE `fLeader` = '%s'", PlayerInfo[LeaderID][pName]);
			mysql_tquery(dbHandle, query, "CheckLeader", "i", playerid);
			switch(listitem)
			{
				case 0: // Los Santos Police Department
				{

					PlayerInfo[LeaderID][pFraction] = 1;
					PlayerInfo[LeaderID][pRank] = 14;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 283); PlayerInfo[LeaderID][pFractionSkin] = 283; }
						case 2: { SetPlayerSkin(LeaderID, 306); PlayerInfo[LeaderID][pFractionSkin] = 306; }
					}
					SetPVarInt(LeaderID, "DutyStart", 1);
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}Los Santos Police Department", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}Los Santos Police Department");
				}
				case 1: // Federal Bureau of Investigation
				{
					PlayerInfo[LeaderID][pFraction] = 2;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 165); PlayerInfo[LeaderID][pFractionSkin] = 165; }
						case 2: { SetPlayerSkin(LeaderID, 141); PlayerInfo[LeaderID][pFractionSkin] = 141; }
					}
					SetPVarInt(LeaderID, "DutyStart", 1);
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}Federal Bureau of Investigation!", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}Federal Bureau of Investigation!");
				}
				case 2: // San Andreas National Guard
				{
					PlayerInfo[LeaderID][pFraction] = 3;
					PlayerInfo[LeaderID][pRank] = 15;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 287); PlayerInfo[LeaderID][pFractionSkin] = 287; }
						case 2: { SetPlayerSkin(LeaderID, 191); PlayerInfo[LeaderID][pFractionSkin] = 191; }
					}
					SetPVarInt(LeaderID, "DutyStart", 1);
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}San Andreas National Guard", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}San Andreas National Guard!");
				}
				case 3: // Emergency Medical Service
				{
					PlayerInfo[LeaderID][pFraction] = 4;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 70); PlayerInfo[LeaderID][pFractionSkin] = 70; }
						case 2: { SetPlayerSkin(LeaderID, 219); PlayerInfo[LeaderID][pFractionSkin] = 219; }
					}
					SetPVarInt(LeaderID, "DutyStart", 1);
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}Emergency Medical Service", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}Emergency Medical Service!");
				}
				case 4: // La Cosa Nostra
				{
					PlayerInfo[LeaderID][pFraction] = 5;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 223); PlayerInfo[LeaderID][pFractionSkin] = 223; }
						case 2: { SetPlayerSkin(LeaderID, 263); PlayerInfo[LeaderID][pFractionSkin] = 263; }
					}
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}La Cosa Nostra", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}La Cosa Nostra!");
				}
				case 5: // Yakuza
				{
					PlayerInfo[LeaderID][pFraction] = 6;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 120); PlayerInfo[LeaderID][pFractionSkin] = 120; }
						case 2: { SetPlayerSkin(LeaderID, 169); PlayerInfo[LeaderID][pFractionSkin] = 169; }
					}
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}Yakuza", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}Yakuza!");
				}
				case 6: // Government
				{
					PlayerInfo[LeaderID][pFraction] = 7;
					PlayerInfo[LeaderID][pRank] = 8;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 147); PlayerInfo[LeaderID][pFractionSkin] = 147; }
						case 2: { SetPlayerSkin(LeaderID, 216); PlayerInfo[LeaderID][pFractionSkin] = 216; }
					}
					SetPVarInt(LeaderID, "DutyStart", 1);
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}Government", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}Government!");
				}
				case 7: // San Andreas News
				{
					PlayerInfo[LeaderID][pFraction] = 8;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 261); PlayerInfo[LeaderID][pFractionSkin] = 261; }
						case 2: { SetPlayerSkin(LeaderID, 211); PlayerInfo[LeaderID][pFractionSkin] = 211; }
					}
					SetPVarInt(LeaderID, "DutyStart", 1);
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}San Andreas News", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}San Andreas News!");
				}
				case 8: // The Ballas Gang
				{
					PlayerInfo[LeaderID][pFraction] = 9;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 104); PlayerInfo[LeaderID][pFractionSkin] = 104; }
						case 2: { SetPlayerSkin(LeaderID, 195); PlayerInfo[LeaderID][pFractionSkin] = 195; }
					}
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}The Ballas Gang", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}The Ballas Gang!");
				}
				case 9: // Los Santos Vagos
				{
					PlayerInfo[LeaderID][pFraction] = 10;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 110); PlayerInfo[LeaderID][pFractionSkin] = 110; }
						case 2: { SetPlayerSkin(LeaderID, 190); PlayerInfo[LeaderID][pFractionSkin] = 190; }
					}
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}Los Santos Vagos", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}Los Santos Vagos!");
				}
				case 10: // Russian Mafia
				{
					PlayerInfo[LeaderID][pFraction] = 11;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 125); PlayerInfo[LeaderID][pFractionSkin] = 125; }
						case 2: { SetPlayerSkin(LeaderID, 214); PlayerInfo[LeaderID][pFractionSkin] = 214; }
					}
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}Russian Mafia", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}Russian Mafia!");
				}
				case 11: // The Grove Street
				{
					PlayerInfo[LeaderID][pFraction] = 12;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 270); PlayerInfo[LeaderID][pFractionSkin] = 270; }
						case 2: { SetPlayerSkin(LeaderID, 56); PlayerInfo[LeaderID][pFractionSkin] = 56; }
					}
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}The Grove Street", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}The Grove Street!");
				}
				case 12: // Varios Los Aztecas
				{
					PlayerInfo[LeaderID][pFraction] = 13;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 115); PlayerInfo[LeaderID][pFractionSkin] = 115; }
						case 2: { SetPlayerSkin(LeaderID, 41); PlayerInfo[LeaderID][pFractionSkin] = 41; }
					}
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}Varios Los Aztecas", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}Varios Los Aztecas!");
				}
				case 13: // The Rifa Gang
				{
					PlayerInfo[LeaderID][pFraction] = 14;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 173); PlayerInfo[LeaderID][pFractionSkin] = 173; }
						case 2: { SetPlayerSkin(LeaderID, 226); PlayerInfo[LeaderID][pFractionSkin] = 226; }
					}
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}The Rifa Gang", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}The Rifa Gang!");
				}
				case 14: // Hell’s Angels MC
				{
					PlayerInfo[LeaderID][pFraction] = 15;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 248); PlayerInfo[LeaderID][pFractionSkin] = 248; }
						case 2: { SetPlayerSkin(LeaderID, 298); PlayerInfo[LeaderID][pFractionSkin] = 298; }
					}
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}Hell’s Angels MC", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}Hell’s Angels MC!");
				}
				case 15: // Outlaws MC
				{
					PlayerInfo[LeaderID][pFraction] = 16;
					PlayerInfo[LeaderID][pRank] = 10;
					switch(PlayerInfo[LeaderID][pGender])
					{
						case 1: { SetPlayerSkin(LeaderID, 248); PlayerInfo[LeaderID][pFractionSkin] = 248; }
						case 2: { SetPlayerSkin(LeaderID, 298); PlayerInfo[LeaderID][pFractionSkin] = 298; }
					}
					new string[256];
					format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] {FF69B4}контролировать фракцию {FFFFFF}Outlaws MC", PlayerInfo[LeaderID][pName], LeaderID);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вас назначили контролировать фракцию {FFFFFF}Outlaws MC!");
				}
				case 16: // Снять лидера
				{
					if(PlayerInfo[LeaderID][pFraction] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не лидер организации!");
					new string[256];
					format(query, sizeof(query), "UPDATE `fractions` SET `fLeader` = '' WHERE `fID` = '%d'", PlayerInfo[LeaderID][pFraction]);
					mysql_tquery(dbHandle, query);
					format(string, sizeof(string), "[Информация] {FF69B4}Вы сняли игрока{FFFFFF} %s[%d] {FF69B4}с контроля за фракцией{FFFFFF} %s", PlayerInfo[LeaderID][pName], LeaderID, FracInfo[PlayerInfo[LeaderID][pFraction]-1][fName]);
					SCM(playerid, COLOR_INFO, string);
					SCM(LeaderID, COLOR_INFO, "[Информация] {FF69B4}Вы были сняты с {FFFFFF}поста лидера {FF69B4}администратором сервера!");
					FracInfo[PlayerInfo[LeaderID][pFraction]-1][fLeader] = 0;
					PlayerInfo[LeaderID][pRank] = 0;
					PlayerInfo[LeaderID][pFractionSkin] = 0;
					PlayerInfo[LeaderID][pFraction] = 0;
					SetPlayerSkin(LeaderID, PlayerInfo[LeaderID][pSkin]);
					SetPVarInt(playerid, "LeaderUninvite", 1);
				}
			}
			format(query, sizeof(query), "UPDATE `users` SET `pFraction` = '%d', `pRank` = '%d', `pFractionSkin` = '%d' WHERE `pName` = '%s'", PlayerInfo[LeaderID][pFraction], PlayerInfo[LeaderID][pRank], PlayerInfo[LeaderID][pFractionSkin], PlayerInfo[LeaderID][pName]);
			mysql_tquery(dbHandle, query);
			switch(PlayerInfo[LeaderID][pFraction])
			{
				case 0: SetPlayerColor(LeaderID, 0xFFFFFF00);
				case 1: SetPlayerColor(LeaderID, 0x110CE7FF);
				case 2: SetPlayerColor(LeaderID, 0x313131AA);
				case 3: SetPlayerColor(LeaderID, 0x51964DFF);
				case 4: SetPlayerColor(LeaderID, 0x954F4FFF);
				case 5: SetPlayerColor(LeaderID, 0xDDA701FF);
				case 6: SetPlayerColor(LeaderID, 0xFF0000AA);
				case 7: SetPlayerColor(LeaderID, 0x114D71FF);
				case 8: SetPlayerColor(LeaderID, 0x5F9EA0FF);
				case 9: SetPlayerColor(LeaderID, 0xB313E7FF);
				case 10: SetPlayerColor(LeaderID, 0xDBD604AA);
				case 12: SetPlayerColor(LeaderID, 0x009F00AA);
				case 13: SetPlayerColor(LeaderID, 0x01FCFFC8);
				case 14: SetPlayerColor(LeaderID, 0x40848BFF);
			}
			if(GetPVarInt(playerid, "LeaderUninvite") == 0)
			{
				if(PlayerInfo[LeaderID][pAdmin] >= 1) return SetPVarInt(playerid, "LeaderID", 0);
				format(query, sizeof(query), "UPDATE `fractions` SET `fLeader` = '%s' WHERE `fID` = '%d'", PlayerInfo[LeaderID][pName], PlayerInfo[LeaderID][pFraction]);
				mysql_tquery(dbHandle, query);
			}
			else SetPVarInt(playerid, "LeaderUninvite", 0);
			SetPVarInt(playerid, "LeaderID", 0);
		}
		case DLG_LSPDGUN:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0:
				{
					if(GetPlayerWeaponAmmo(playerid, 24) >= 56) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше патрон!");
					GivePlayerWeapon(playerid, 24, 56);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада пистолет Deagle.");
					SPD(playerid, DLG_LSPDGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Дубинка", "Выбрать", "Отмена");
				}
				case 1:
				{
					if(GetPlayerWeaponAmmo(playerid, 31) >= 360) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше патрон!");
					GivePlayerWeapon(playerid, 31, 360);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада винтовку M4A1.");
					SPD(playerid, DLG_LSPDGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Дубинка", "Выбрать", "Отмена");
				}
				case 2:
				{
					if(GetPlayerWeaponAmmo(playerid, 25) >= 56) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше патрон!");
					GivePlayerWeapon(playerid, 25, 56);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада дробовик Shotgun.");
					SPD(playerid, DLG_LSPDGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Дубинка", "Выбрать", "Отмена");
				}
				case 3:
				{
					if(GetPlayerWeaponAmmo(playerid, 34) >= 56) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше патрон!");
					GivePlayerWeapon(playerid, 34, 56);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада снайперскую винтовку.");
					SPD(playerid, DLG_LSPDGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Дубинка", "Выбрать", "Отмена");
				}
				case 4:
				{
					SetPlayerHealth(playerid, 100.0);
					SetPlayerArmour(playerid, 100.0);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада аптечку и бронежилет.");
					SPD(playerid, DLG_LSPDGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Дубинка", "Выбрать", "Отмена");
				}
				case 5:
				{
					if(GetPlayerWeaponAmmo(playerid, 46) >= 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше одного парашюта!");
					GivePlayerWeapon(playerid, 46, 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада парашют.");
					SPD(playerid, DLG_LSPDGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Дубинка", "Выбрать", "Отмена");
				}
			}
		}
		case DLG_SANGGUN:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0:
				{
					if(GetPlayerWeaponAmmo(playerid, 24) >= 56) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше патрон!");
					GivePlayerWeapon(playerid, 24, 56);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада пистолет Deagle.");
					SPD(playerid, DLG_SANGGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Парашют", "Выбрать", "Отмена");
				}
				case 1:
				{
					if(GetPlayerWeaponAmmo(playerid, 31) >= 360) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше патрон!");
					GivePlayerWeapon(playerid, 31, 360);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада винтовку M4A1.");
					SPD(playerid, DLG_SANGGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Парашют", "Выбрать", "Отмена");
				}
				case 2:
				{
					if(GetPlayerWeaponAmmo(playerid, 25) >= 56) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше патрон!");
					GivePlayerWeapon(playerid, 25, 56);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада дробовик Shotgun.");
					SPD(playerid, DLG_SANGGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Парашют", "Выбрать", "Отмена");
				}
				case 3:
				{
					if(GetPlayerWeaponAmmo(playerid, 34) >= 56) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше патрон!");
					GivePlayerWeapon(playerid, 34, 56);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада снайперскую винтовку.");
					SPD(playerid, DLG_SANGGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Парашют", "Выбрать", "Отмена");
				}
				case 4:
				{
					SetPlayerHealth(playerid, 100.0);
					SetPlayerArmour(playerid, 100.0);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада аптечку и бронежилет.");
					SPD(playerid, DLG_SANGGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Парашют", "Выбрать", "Отмена");
				}
				case 5:
				{
					if(GetPlayerWeaponAmmo(playerid, 46) >= 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не можете взять больше одного парашюта!");
					GivePlayerWeapon(playerid, 46, 1);
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы взяли со склада парашют.");
					SPD(playerid, DLG_SANGGUN, DSL, "{FFFFFF}Оружейная {2776AB}|| Фракция", "[1] Пистолет Deagle\n[2] Винтовка M4A1\n[3] Дробовик Shotgun\n[4] Снайперская винтовка\n[5] Аптечка и бронежилет\n[6] Парашют", "Выбрать", "Отмена");
				}
			}
		}
		case DLG_SANGSTART:
		{
			if(!response) return 1;
			if(GetPVarInt(playerid, "DutyStart") == 0)
			{
				switch(listitem)
				{
					case 0:
					{
						SetPVarInt(playerid, "DutyStart", 1);
						SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
						SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы начали свой рабочий день.");
						SetPlayerColor(playerid, 0x51964DFF);
					}
				}
			}
			else
			{
				switch(listitem)
				{
					case 0:
					{
						if(PlayerInfo[playerid][pRank]<3)
						{
							SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете закончить рабочий день.");
						}
						else
						{
							SetPVarInt(playerid, "DutyStart", 0);
							SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
							SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы закончили свой рабочий день.");
							SetPlayerColor(playerid, 0xFFFFFF00);	
						}
						
					}
					case 1:
					{
						new string[128];
						format(string, sizeof(string), "Одежда\tРанг\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d",
						FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin1], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank1], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin2], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank2], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin3], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank3],
						FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin4], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank4], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin5], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank5], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin6], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank6]);
						SPD(playerid, DLG_LSPDCLOTHES, DSTH, "{FFFFFF}Раздевалка {2776AB}|| Фракция", string, "Выбрать", "Назад");
					}
				}
			}
		}
		case DLG_LSPDSTART:
		{
			if(!response) return 1;
			if(GetPVarInt(playerid, "DutyStart") == 0)
			{
				switch(listitem)
				{
					case 0:
					{
						SetPVarInt(playerid, "DutyStart", 1);
						SetPlayerSkin(playerid, PlayerInfo[playerid][pFractionSkin]);
						SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы начали свой рабочий день.");
						SetPlayerColor(playerid, 0x110CE7FF);
					}
				}
			}
			else
			{
				switch(listitem)
				{
					case 0:
					{
						SetPVarInt(playerid, "DutyStart", 0);
						SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
						SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы закончили свой рабочий день.");
						PlayerInfo[playerid][pCopKey] = 1;
						SetPlayerColor(playerid, 0xFFFFFF00);
					}
					case 1:
					{
						new string[128];
						format(string, sizeof(string), "Одежда\tРанг\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d\nОдежда %d\t%d",
						FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin1], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank1], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin2], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank2], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin3], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank3],
						FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin4], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank4], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin5], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank5], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin6], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank6],
						FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin7], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank7], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin8], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank8], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin9], FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank9]);
						SPD(playerid, DLG_LSPDCLOTHES, DSTH, "{FFFFFF}Раздевалка {2776AB}|| Фракция", string, "Выбрать", "Назад");
					}
				}
			}
		}
		case DLG_LSPDCLOTHES:
		{
			if(response)
			{
				new query[128];
				switch(listitem)
				{
					case 0:
					{
						if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank1]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная одежда!");
						PlayerInfo[playerid][pFractionSkin] = FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin1];
						SetPlayerSkin(playerid, FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin1]);
					}
					case 1:
					{
						if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank2]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная одежда!");
						PlayerInfo[playerid][pFractionSkin] = FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin2];
						SetPlayerSkin(playerid, FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin2]);
					}
					case 2:
					{
						if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank3]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная одежда!");
						PlayerInfo[playerid][pFractionSkin] = FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin3];
						SetPlayerSkin(playerid, FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin3]);
					}
					case 3:
					{
						if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank4]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная одежда!");
						PlayerInfo[playerid][pFractionSkin] = FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin4];
						SetPlayerSkin(playerid, FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin4]);
					}
					case 4:
					{
						if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank5]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная одежда!");
						PlayerInfo[playerid][pFractionSkin] = FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin5];
						SetPlayerSkin(playerid, FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin5]);
					}
					case 5:
					{
						if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank6]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная одежда!");
						PlayerInfo[playerid][pFractionSkin] = FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin6];
						SetPlayerSkin(playerid, FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin6]);
					}
					case 6:
					{
						if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank7]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная одежда!");
						PlayerInfo[playerid][pFractionSkin] = FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin7];
						SetPlayerSkin(playerid, FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin7]);
					}
					case 7:
					{
						if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank8]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная одежда!");
						PlayerInfo[playerid][pFractionSkin] = FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin8];
						SetPlayerSkin(playerid, FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin8]);
					}
					case 8:
					{
						if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fSkinRank9]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная одежда!");
						PlayerInfo[playerid][pFractionSkin] = FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin9];
						SetPlayerSkin(playerid, FracInfo[PlayerInfo[playerid][pFraction]-1][fSkin9]);
					}
				}
				SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы переоделись.");
				format(query, sizeof(query), "UPDATE `users` SET `pFractionSkin` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[playerid][pFractionSkin], PlayerInfo[playerid][pID]);
				mysql_tquery(dbHandle, query);
			}
			else
			{
				if(GetPVarInt(playerid, "DutyStart") == 0)
				{
					SPD(playerid, DLG_LSPDSTART, DSL, "{FFFFFF}Раздевалка {2776AB}|| Фракция", "[1] Начать рабочий день", "Выбрать", "Отмена");
				}
				else
				{
					SPD(playerid, DLG_LSPDSTART, DSL, "{FFFFFF}Раздевалка {2776AB}|| Фракция", "[1] Закончить рабочий день\n[2] Сменить одежду", "Выбрать", "Отмена");
				}
				return 1;
			}
		}
		case DLG_HOUSENOWNER:
		{
			if(!response) return 1;
			new HouseID = GetPVarInt(playerid, "HouseID");
			SetPlayerVirtualWorld(playerid, HouseID + 100);
			SetPlayerInterior(playerid, HouseInfo[HouseID][hInterior]);
			SetPlayerPos(playerid, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY], HouseInfo[HouseID][hiEnterZ]);
			SetPlayerFacingAngle(playerid, HouseInfo[HouseID][hiEnterAngle]);
			SetCameraBehindPlayer(playerid);
			SetPVarInt(playerid, "PlayerIntoHouse", 1);
		}
		case DLG_HOUSEOWNER:
		{
			if(!response) return 1;
			new HouseID = GetPVarInt(playerid, "HouseID");
			if(HouseInfo[HouseID][hLocked] == 1)
			{
				if(HouseID + 1 != PlayerInfo[playerid][pHouse])
				{
					GameTextForPlayer(playerid, "~r~CLOSED", 2000, 1);
					return 1;
				}
			}
			SetPlayerVirtualWorld(playerid, HouseID + 100);
			SetPlayerInterior(playerid, HouseInfo[HouseID][hInterior]);
			SetPlayerPos(playerid, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY], HouseInfo[HouseID][hiEnterZ]);
			SetPlayerFacingAngle(playerid, HouseInfo[HouseID][hiEnterAngle]);
			SetCameraBehindPlayer(playerid);
			SetPVarInt(playerid, "PlayerIntoHouse", 1);
		}
		case DLG_ALTHOUSEMENU:
		{
			if(!response) return 1;
			new HouseID = GetPVarInt(playerid, "HouseID");
			if(HouseInfo[HouseID][hOwned] == 0)
			{
				switch(listitem)
				{
				 	case 0:
				 	{
				 		if(PlayerInfo[playerid][pHouse] != 9999) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У вас уже есть дом. Чтобы купить новый, необходимо сначала продать предыдущий!");
				 		if(PlayerInfo[playerid][pMoney] < HouseInfo[HouseID][hCost])
				 		{
				 			if(PlayerInfo[playerid][pBankMoney] < HouseInfo[HouseID][hCost]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У вас недостаточно средств для покупки дома!");
				 			SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы успешно купили дом.");
				 			SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте {DCBC3D}\"ALT\" {FF69B4}у двери, чтобы узнать о новых функциях!");
				 			SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Из-за недостатка средств у Вас на руках, деньги были списаны с банка!");
				 			new query[128];
				 			PlayerInfo[playerid][pBankMoney] -= HouseInfo[HouseID][hCost];
				 			format(query, sizeof(query), "UPDATE `users` SET `pBankMoney` = '%d' WHERE `pID` = '%d'", PlayerInfo[playerid][pBankMoney], PlayerInfo[playerid][pID]);
				 			mysql_tquery(dbHandle, query);
				 		}
				 		else
				 		{
				 			SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы успешно купили дом.");
				 			SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте {DCBC3D}\"ALT\" {FF69B4}у двери, чтобы узнать о новых функциях!");
				 			GiveMoney(playerid, -HouseInfo[HouseID][hCost]);
				 		}
				 		PlayerInfo[playerid][pHouse] = HouseInfo[HouseID][hID];
				 		HouseInfo[HouseID][hOwned] = 1;
				 		HouseInfo[HouseID][hLocked] = 1;
				 		if(HouseInfo[HouseID][hMedKit] == 0) HouseInfo[HouseID][hMedKit] += 10;
				 		PlayerInfo[playerid][pSpawn] = 3; // Ставим местовозрождение на дом
				 		strmid(HouseInfo[HouseID][hOwner], PlayerInfo[playerid][pName], 0, strlen(PlayerInfo[playerid][pName]), 24);
				 		SetPlayerVirtualWorld(playerid, HouseID + 100);
				 		SetPlayerInterior(playerid, HouseInfo[HouseID][hInterior]);
				 		SetPlayerPos(playerid, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY], HouseInfo[HouseID][hiEnterZ]);
				 		SetPlayerFacingAngle(playerid, HouseInfo[HouseID][hiEnterAngle]);
				 		SetCameraBehindPlayer(playerid);
				 		if(PlayerInfo[playerid][pCarModel] != -1) HouseInfo[HouseID][hCar] = CreateVehicle(PlayerInfo[playerid][pCarModel], HouseInfo[HouseID][hCarPosX], HouseInfo[HouseID][hCarPosY], HouseInfo[HouseID][hCarPosZ], HouseInfo[HouseID][hCarAngle], PlayerInfo[playerid][pCarColor1], PlayerInfo[playerid][pCarColor2], 0);
				 		HousePickupAndIcon(HouseID);
				 		new query[128], year, month, day, time[16];
				 		gmtime(gettime(), year, month, day);
				 		format(time, sizeof(time), "%04d.%02d.%02d", year, month, day + 1);
				 		HouseInfo[HouseID][hPay] = time;
				 		format(query, sizeof(query), "UPDATE `houses` SET `hPay` = '%04d.%02d.%02d', `hMedKit` = '%d' WHERE `hID` = '%d'", year, month, day + 1, HouseInfo[HouseID][hMedKit], HouseInfo[HouseID][hID]);
				 		mysql_tquery(dbHandle, query);
				 		format(query, sizeof(query), "UPDATE `users` SET `pHouse` = '%d', `pSpawn` = '%d' WHERE `pID` = '%d'", PlayerInfo[playerid][pHouse], PlayerInfo[playerid][pSpawn], PlayerInfo[playerid][pID]);
				 		mysql_tquery(dbHandle, query);
				 		SaveHouse(HouseID);
				 	}
				 	case 1:
				 	{
				 		new string[256], locked[15];
				 		switch(HouseInfo[HouseID][hLocked])
				 		{
				 			case 0: locked = "{77DC34}Открыт";
				 			case 1: locked = "{D50000}Закрыт";
				 		}
				 		format(string, sizeof(string), "{FFFFFF}Номер дома: {5FA3B1}%d\n{FFFFFF}Тип: {E2BE2E}%s\n{FFFFFF}Количество комнат: {5FA3B1}%d\n{FFFFFF}Количество гаражных мест: {5FA3B1}%d\n{FFFFFF}Стоимость: {5FA3B1}%d\n{FFFFFF}Статус замка: %s",
				 		HouseInfo[HouseID][hID], HouseInfo[HouseID][hType], HouseInfo[HouseID][hRoomAmount], HouseInfo[HouseID][hGarage], HouseInfo[HouseID][hCost], locked);
				 		SPD(playerid, DLG_NONE, DSM, "{FFFFFF}Информация о доме {29B4EF}|| Дом", string, "Закрыть", "");
				 	}
				}
			}
			else
			{
				new query[256];
				switch(listitem)
				{
					case 0: // Открыть(закрыть) дом
					{
						if(PlayerInfo[playerid][pHouse] != HouseInfo[HouseID][hID]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Это не ваш дом!");
						switch(HouseInfo[HouseID][hLocked])
						{
							case 0: // Закрыть
							{
								HouseInfo[HouseID][hLocked] = 1;
								SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы успешно {BB0000}закрыли {FFFFFF}дом!");
								format(query, sizeof(query), "UPDATE `houses` SET `hLocked` = '%d' WHERE `hID` = '%d'", HouseInfo[HouseID][hLocked], HouseInfo[HouseID][hID]);
								mysql_tquery(dbHandle, query);
							}
							case 1: // Открыть
							{
								HouseInfo[HouseID][hLocked] = 0;
								SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы успешно {64A21A}открыли {FFFFFF}дом!");
								format(query, sizeof(query), "UPDATE `houses` SET `hLocked` = '%d' WHERE `hID` = '%d'", HouseInfo[HouseID][hLocked], HouseInfo[HouseID][hID]);
								mysql_tquery(dbHandle, query);
							}
						}
					}
					case 1: // Улучшить дом
					{
						if(PlayerInfo[playerid][pHouse] != HouseInfo[HouseID][hID]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Это не ваш дом!");
					}
					case 2: // Информация о доме
					{
						if(PlayerInfo[playerid][pHouse] != HouseInfo[HouseID][hID]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Это не ваш дом!");
						new string[300], locked[15];
				 		switch(HouseInfo[HouseID][hLocked])
				 		{
				 			case 0: locked = "{77DC34}Открыт";
				 			case 1: locked = "{D50000}Закрыт";
				 		}
				 		format(string, sizeof(string), "{FFFFFF}Номер дома: {5FA3B1}%d\n{FFFFFF}Тип: {E2BE2E}%s\n{FFFFFF}Количество комнат: {5FA3B1}%d\n{FFFFFF}Количество гаражных мест: {5FA3B1}%d\n{FFFFFF}Стоимость: {5FA3B1}%d\n{FFFFFF}Дом оплачен до: {9FA318}%s\n{FFFFFF}Статус замка: %s",
				 		HouseInfo[HouseID][hID], HouseInfo[HouseID][hType], HouseInfo[HouseID][hRoomAmount], HouseInfo[HouseID][hGarage], HouseInfo[HouseID][hCost], HouseInfo[HouseID][hPay], locked);
				 		SPD(playerid, DLG_NONE, DSM, "{FFFFFF}Информация о доме {29B4EF}|| Дом", string, "Закрыть", "");
					}
					case 3: // Использовать аптечку
					{
						if(PlayerInfo[playerid][pHouse] != HouseInfo[HouseID][hID]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Это не ваш дом!");
						if(HouseInfo[HouseID][hMedKit] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У вас нет аптечек в доме!");
						if(PlayerInfo[playerid][pHP] >= 100) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам не требуется аптечка!");
						if(GetPVarInt(playerid, "HealthHome") == 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы недавно уже использовали аптечку, попробуйте позже!");
						SetPVarInt(playerid, "HealthHome", 1);
						SetHealth(playerid, PlayerInfo[playerid][pHP] + 50);
						GameTextForPlayer(playerid, "~r~HEALING", 2700, 3);
						ApplyAnimation(playerid, "PED", "GUM_EAT", 4.1, 0, 0, 0, 0, 2700, 1);
						SetTimerEx("HealthTimer", 2000, false, "i", playerid);
						HouseInfo[HouseID][hMedKit] -= 1;
						format(query, sizeof(query), "UPDATE `houses` SET `hMedKit` = '%d' WHERE `hID` = '%d'", HouseInfo[HouseID][hMedKit], HouseInfo[HouseID][hID]);
						mysql_tquery(dbHandle, query);
					}
					case 4: // Продать дом
					{
						if(PlayerInfo[playerid][pHouse] != HouseInfo[HouseID][hID]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Это не ваш дом!");
						PlayerInfo[playerid][pHouse] = 9999;
						PlayerInfo[playerid][pSpawn] = 1;
						HouseInfo[HouseID][hOwned] = 0;
						HouseInfo[HouseID][hLocked] = 0;
						HouseInfo[HouseID][hPay] = 0;
						HouseInfo[HouseID][hStoreMaterials] = 0;
						HouseInfo[HouseID][hStoreDrugs] = 0;
						PlayerInfo[playerid][pMoney] += HouseInfo[HouseID][hCost] / 3;
						SetPlayerVirtualWorld(playerid, 0);
						SetPlayerInterior(playerid, 0);
						SetPlayerPos(playerid, HouseInfo[HouseID][hExitX], HouseInfo[HouseID][hExitY], HouseInfo[HouseID][hExitZ]);
						SetPlayerFacingAngle(playerid, HouseInfo[HouseID][hExitAngle]);
						SetCameraBehindPlayer(playerid);
						format(query, sizeof(query), "UPDATE `houses` SET `hOwned` = '%d', `hOwner` = '', `hPay` = '', `hLocked` = '%d', `hStoreDrugs` = '%d', `hStoreMaterials` = '%d' WHERE `hID` = '%d'", HouseInfo[HouseID][hOwned], HouseInfo[HouseID][hLocked], HouseInfo[HouseID][hStoreDrugs], HouseInfo[HouseID][hStoreMaterials], HouseInfo[HouseID][hID]);
						mysql_tquery(dbHandle, query);
						format(query, sizeof(query), "UPDATE `users` SET `pMoney` = '%d', `pSpawn` = '%d', `pHouse` = '%d' WHERE `pID` = '%d'", PlayerInfo[playerid][pMoney], PlayerInfo[playerid][pSpawn], PlayerInfo[playerid][pHouse], PlayerInfo[playerid][pID]);
						mysql_tquery(dbHandle, query);
						HousePickupAndIcon(HouseID);
						SetStorage(HouseID);
						SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы успешно продали дом государству! Вам возвращено {E6E613}30 процентов {FF69B4}от его стоимости.");
						SetPVarInt(playerid, "HouseID", 0);
					}
				}
			}
		}
		case DLG_TPLIST:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0:
				{
					SPD(playerid, DLG_TPLIST_BASE, DSL, "{FFFFFF}Mеню телепорта {F385D5}|| Базы организаций", "[1] SANG\n[2] LSPD\n[3] Government\n[4] Grove\n[5] Ballas\n[6] Rifa\n[7] Aztecas\n[8] Vagos\n", "Далее", "Отмена");
				}
			}
		}
		case DLG_TPLIST_BASE:
		{
			if(!response) return 1;
			switch(listitem)
			{
				
				case 0:// SANG
				{
					new vehicleid = GetPlayerVehicleID(playerid);
			        if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			        {
			            SetVehiclePos(vehicleid, -1092.8636,-1653.6351,76.3739);
			        }
			        else
			        {
			            SetPlayerPos(playerid, -1092.8636,-1653.6351,76.3739);
			        }
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
 	    			SetCameraBehindPlayer(playerid);
					SCM(playerid, COLOR_INFO, "[Информация] {FFFFFF}Вы были успешно телепортированы.");
				}
				case 1:// LSPD
				{
					new vehicleid = GetPlayerVehicleID(playerid);
			        if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			        {
			            SetVehiclePos(vehicleid, 1540.1812,-1674.9091,13.5501);
			        }
			        else
			        {
			            SetPlayerPos(playerid, 1540.1812,-1674.9091,13.5501);
			        }
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
 	    			SetCameraBehindPlayer(playerid);
					SCM(playerid, COLOR_INFO, "[Информация] {FFFFFF}Вы были успешно телепортированы.");
				}
				case 2:// Government
				{
					new vehicleid = GetPlayerVehicleID(playerid);
			        if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			        {
			            SetVehiclePos(vehicleid, 1480.6522,-1742.4301,13.5469);
			        }
			        else
			        {
			            SetPlayerPos(playerid, 1480.6522,-1742.4301,13.5469);
			        }
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
 	    			SetCameraBehindPlayer(playerid);
					SCM(playerid, COLOR_INFO, "[Информация] {FFFFFF}Вы были успешно телепортированы.");
				}
				case 3:// Grove
				{
					new vehicleid = GetPlayerVehicleID(playerid);
			        if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			        {
			            SetVehiclePos(vehicleid, 2481.1501,-1672.4698,13.3398);
			        }
			        else
			        {
			            SetPlayerPos(playerid, 2481.1501,-1672.4698,13.3398);
			        }
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
 	    			SetCameraBehindPlayer(playerid);
					SCM(playerid, COLOR_INFO, "[Информация] {FFFFFF}Вы были успешно телепортированы.");
				}
				case 4:// Ballas
				{
					new vehicleid = GetPlayerVehicleID(playerid);
			        if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			        {
			            SetVehiclePos(vehicleid, 2645.6284,-2002.9883,13.3828);
			        }
			        else
			        {
			            SetPlayerPos(playerid, 2645.6284,-2002.9883,13.3828);
			        }
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
 	    			SetCameraBehindPlayer(playerid);
					SCM(playerid, COLOR_INFO, "[Информация] {FFFFFF}Вы были успешно телепортированы.");
				}
				case 5:// Rifa
				{
					new vehicleid = GetPlayerVehicleID(playerid);
			        if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			        {
			            SetVehiclePos(vehicleid, 2184.8130,-1808.0417,13.3736);
			        }
			        else
			        {
			            SetPlayerPos(playerid, 2184.8130,-1808.0417,13.3736);
			        }
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
 	    			SetCameraBehindPlayer(playerid);
					SCM(playerid, COLOR_INFO, "[Информация] {FFFFFF}Вы были успешно телепортированы.");
				}
				case 6:// Aztecas
				{
					new vehicleid = GetPlayerVehicleID(playerid);
			        if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			        {
			            SetVehiclePos(vehicleid, 1665.4808,-2113.3335,13.5469);
			        }
			        else
			        {
			            SetPlayerPos(playerid, 1665.4808,-2113.3335,13.5469);
			        }
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
 	    			SetCameraBehindPlayer(playerid);
					SCM(playerid, COLOR_INFO, "[Информация] {FFFFFF}Вы были успешно телепортированы.");
				}
				case 7:// Vagos
				{
					new vehicleid = GetPlayerVehicleID(playerid);
			        if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			        {
			            SetVehiclePos(vehicleid, 2772.8479,-1618.5504,10.9219);
			        }
			        else
			        {
			            SetPlayerPos(playerid, 2772.8479,-1618.5504,10.9219);
			        }
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
 	    			SetCameraBehindPlayer(playerid);
					SCM(playerid, COLOR_INFO, "[Информация] {FFFFFF}Вы были успешно телепортированы.");
				}
			}
		}
		case WORK_BUILDER:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0: // Кто ты?
				{
					SCM(playerid, COLOR_WHITE, "Дейв: Эх.. Слушай парень, меня зовут Дейв. Знаешь у меня нет времени болтать по пустякам.");
					SCM(playerid, COLOR_WHITE, "Дейв: Ты либо работаешь, либо иди отсюда, нечего людям мешать.");
					SPD(playerid, WORK_BUILDER, DSL, "Строитель","Кто ты?\nЧто это за место?\nЯ хочу начать работать.\nЯ хочу забрать свою зарплату.", "Далее", "X");
				}
				case 1: // Что это за место?
				{
					SCM(playerid, COLOR_WHITE, "Дейв: А ты как думаешь? Стройка тут.");
					SCM(playerid, COLOR_WHITE, "Дейв: Много кто приходит сюда поднять денег на хлеб.");
					SPD(playerid, WORK_BUILDER, DSL, "Строитель","Кто ты?\nЧто это за место?\nЯ хочу начать работать.\nЯ хочу забрать свою зарплату.", "Далее", "X");
				}
				case 2: // Я хочу начать работать
				{
					if(GetPVarInt(playerid, "BuildStart") == 0)
					{
						SCM(playerid, COLOR_WHITE, "Дейв: Работать пришёл? Отлично! Вот тебе одежда - переодевайся.");
						SCM(playerid, COLOR_WHITE, "Дейв: А теперь иди и разгреби эти кучи с кирпичами, а то работать невозможно.");
						SetPlayerSkin(playerid, 27);
						SetPVarInt(playerid, "BuildStart", 1);
						SetPlayerCheckpoint(playerid, 1255.0181,-1267.3550,13.4216, 2.0);
					}
					else
					{
						SCM(playerid, COLOR_WHITE, "Дейв: Уже закончил? Хорошо, сдавай форму.");
						SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
						SetPVarInt(playerid, "BuildStart", 0);
						DisablePlayerCheckpoint(playerid);
					}
				}
				case 3: // Забрать зарплату
				{
					
				}
			}
		}
		case DLG_LEADER_MENU:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0: // Меню лидера
				{
					new string[1200];
					switch(PlayerInfo[playerid][pFraction])
					{
						case 1:
						{
							format(string, sizeof(string), "[1] %s\n[2] %s\n[3] %s\n[4] %s\n[5] %s\n[6] %s\n[7] %s\n[8] %s\n[9] %s\n[10] %s\
							\n[11] %s\n[12] %s\n[13] %s\n[14] %s", FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang9], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang10], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang11], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang12]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang13], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang14]);
							SPD(playerid, DLG_LEADER_MENU_RANG, DSL, "{FFFFFF}Mеню лидера", string, "Далее", "Отмена");
						}
						case 2:
						{
							format(string, sizeof(string), "[1] %s\n[2] %s\n[3] %s\n[4] %s\n[5] %s\n[6] %s\n[7] %s\n[8] %s\n[9] %s\n[10] %s", FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang9], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang10]);
							SPD(playerid, DLG_LEADER_MENU_RANG, DSL, "{FFFFFF}Mеню лидера", string, "Далее", "Отмена");
						}
						case 3:
						{
							format(string, sizeof(string), "[1] %s\n[2] %s\n[3] %s\n[4] %s\n[5] %s\n[6] %s\n[7] %s\n[8] %s\n[9] %s\n[10] %s\
							\n[11] %s\n[12] %s\n[13] %s\n[14] %s\n[15] %s", FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang9], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang10], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang11], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang12]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang13], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang14], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang15]);
							SPD(playerid, DLG_LEADER_MENU_RANG, DSL, "{FFFFFF}Mеню лидера", string, "Далее", "Отмена");
						}
						case 4:
						{
							format(string, sizeof(string), "[1] %s\n[2] %s\n[3] %s\n[4] %s\n[5] %s\n[6] %s\n[7] %s\n[8] %s\n[9] %s\n[10] %s", FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang9], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang10]);
							SPD(playerid, DLG_LEADER_MENU_RANG, DSL, "{FFFFFF}Mеню лидера", string, "Далее", "Отмена");
						}
						case 5:
						{
							format(string, sizeof(string), "[1] %s\n[2] %s\n[3] %s\n[4] %s\n[5] %s\n[6] %s\n[7] %s\n[8] %s\n[9] %s\n[10] %s", FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang9], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang10]);
							SPD(playerid, DLG_LEADER_MENU_RANG, DSL, "{FFFFFF}Mеню лидера", string, "Далее", "Отмена");
						}
						case 6:
						{
							format(string, sizeof(string), "[1] %s\n[2] %s\n[3] %s\n[4] %s\n[5] %s\n[6] %s\n[7] %s\n[8] %s\n[9] %s\n[10] %s", FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang9], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang10]);
							SPD(playerid, DLG_LEADER_MENU_RANG, DSL, "{FFFFFF}Mеню лидера", string, "Далее", "Отмена");
						}
						case 7:
						{
							format(string, sizeof(string), "[1] %s\n[2] %s\n[3] %s\n[4] %s\n[5] %s\n[6] %s\n[7] %s\n[8] %s", FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8]);
							SPD(playerid, DLG_LEADER_MENU_RANG, DSL, "{FFFFFF}Mеню лидера", string, "Далее", "Отмена");
						}
						case 8..16:
						{
							format(string, sizeof(string), "[1] %s\n[2] %s\n[3] %s\n[4] %s\n[5] %s\n[6] %s\n[7] %s\n[8] %s\n[9] %s\n[10] %s", FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8]
							, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang9], FracInfo[PlayerInfo[playerid][pFraction]-1][fRang10]);
							SPD(playerid, DLG_LEADER_MENU_RANG, DSL, "{FFFFFF}Mеню лидера", string, "Далее", "Отмена");
						}
					}
					
				}
			}
		}
		case DLG_LEADER_MENU_RANG:
		{
			if(!response) return 1;
			redrang = listitem+1;
			SPD(playerid, DLG_RED_RANG, DSI, "{FFFFFF}Изменение ранга", "Введите новое название.", "Далее", "Отмена");
		}
		case DLG_RED_RANG:
		{
			if(!response) return 1;
			new query[128], string[32];
			if(strlen(inputtext) > 18)
			{
				SCM(playerid, COLOR_ERROR, "[Ошибка]{9AAAAB} Количество сивмолов не должно превышать 18-ти.");
				return SPD(playerid, DLG_RED_RANG, DSI, "{FFFFFF}Изменение ранга", "Введите новое название.", "Далее", "Отмена");
			}
			switch(redrang)
			{
				case 1: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1], inputtext, 0, strlen(inputtext), 32);
				case 2: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2], inputtext, 0, strlen(inputtext), 32);
				case 3: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3], inputtext, 0, strlen(inputtext), 32);
				case 4: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4], inputtext, 0, strlen(inputtext), 32);
				case 5: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5], inputtext, 0, strlen(inputtext), 32);
				case 6: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6], inputtext, 0, strlen(inputtext), 32);
				case 7: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7], inputtext, 0, strlen(inputtext), 32);
				case 8: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8], inputtext, 0, strlen(inputtext), 32);
				case 9: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang9], inputtext, 0, strlen(inputtext), 32);
				case 10: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang10], inputtext, 0, strlen(inputtext), 32);
				case 11: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang11], inputtext, 0, strlen(inputtext), 32);
				case 12: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang12], inputtext, 0, strlen(inputtext), 32);
				case 13: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang13], inputtext, 0, strlen(inputtext), 32);
				case 14: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang14], inputtext, 0, strlen(inputtext), 32);
				case 15: strmid(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang15], inputtext, 0, strlen(inputtext), 32);
			}
			SCM(playerid, COLOR_INFO, "[Информация]{FF69B4} Название ранга изменено.");
			SPD(playerid, DLG_LEADER_MENU, DSL, "{FFFFFF}Меню лидера", "{FFFFFF}1. Название рангов", "Далее", "Отмена");
			format(string, sizeof(string), "FracInfo[PlayerInfo[playerid][pFraction]-1][fRang%d]", redrang);
			strmid(string, inputtext, 0, strlen(inputtext), 32);
			format(query, sizeof(query), "UPDATE `fractions` SET `fRang%d` = '%s' WHERE `fID` = '%d' LIMIT 1", redrang, string, PlayerInfo[playerid][pFraction]);
			mysql_tquery(dbHandle, query);
		}
		case DLG_CARM:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0:
				{
					if(VehicleInfo[GetPlayerVehicleID(playerid)][vMaterials] > 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Сначала нужно разгрузить ресурсы на Главный склад {FFFFFF}'/carm'");
					SetPVarInt(playerid, "LoadStart", 1);
					SetPlayerCheckpoint(playerid, -1075.8771,-1587.6854,76.3913, 10.0);
				}
				case 1:
				{
					SetPVarInt(playerid, "UnLoadToMainSkladStart", 1);
					SetPlayerCheckpoint(playerid, -1075.8771,-1587.6854,76.3913, 10.0);
				}
				case 2:
				{
					SetPVarInt(playerid, "UnLoadToFBI", 1);
					SetPlayerCheckpoint(playerid, 289.3908,-1634.0247,33.1562, 10.0);
				}
				case 3:
				{
					SetPVarInt(playerid, "UnLoadToLSPD", 1);
					SetPlayerCheckpoint(playerid, 1528.8911,-1677.5168,5.8906, 10.0);
				}
			}
		}
		case DLG_MAINMENU_ADMIN:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0: // Окно репорта
				{
					SPD(playerid, DLG_REPORT, DSI, "{FFFFFF}Mеню персонажа {4DB8E6}|| Связь с администрацией", "{FFFFFF}Введите вашу жалобу. Опишите кратко и понятно.", "Далее", "Отмена");	
				}
				case 1: // Окно смены ника
				{
					SPD(playerid, DLG_RED_NAME, DSI, "{FFFFFF}Mеню персонажа {4DB8E6}|| Смена имени", "{FFFFFF}Введите ваше новое имя.\nАдминистрация меняет только nonRP ники.", "Далее", "Отмена");	
				}
			}
		}
		case DLG_REPORT:
		{
			new string[128];
			if(response)
			{
				if(strlen(inputtext) > 18)
				{
					SCM(playerid, COLOR_ERROR, "[Ошибка]{9AAAAB} Количество сивмолов не должно превышать 18-ти.");
					return SPD(playerid, DLG_REPORT, DSI, "{FFFFFF}Mеню персонажа {4DB8E6}|| Связь с администрацией", "{FFFFFF}Введите вашу жалобу. Опишите кратко и понятно.", "Далее", "Отмена");	
				}
				if(!strlen(inputtext))
				{
					SCM(playerid, COLOR_ERROR, "[Ошибка]{9AAAAB} Поле не может быть пустым.");
					return SPD(playerid, DLG_REPORT, DSI, "{FFFFFF}Mеню персонажа {4DB8E6}|| Связь с администрацией", "{FFFFFF}Введите вашу жалобу. Опишите кратко и понятно.", "Далее", "Отмена");	
				}
				format(string, sizeof(string), "Жалоба от %s[%i]: %s", PlayerInfo[playerid][pName], playerid, inputtext);
				SendAdminMessage(COLOR_YELLOW, string);
				SCM(playerid, COLOR_YELLOW, "Ваша жалоба была отправлена администрации.");
			}
			else
			{
				SPD(playerid, DLG_MAINMENU_ADMIN, DSL, "{FFFFFF}Mеню персонажа {4DB8E6}|| Администрациия", "{FFFFFF}1. Связь с администрацией\n2. Заявка на смену ника\n3. Задать вопрос", "Далее", "Отмена");
			}
		}
		case DLG_RED_NAME:
		{
			new query[128];
			if(response)
			{
				if(strlen(inputtext) > 20)
				{
					SCM(playerid, COLOR_ERROR, "[Ошибка]{9AAAAB} Количество сивмолов не должно превышать 20-ти.");
					return SPD(playerid, DLG_RED_NAME, DSI, "{FFFFFF}Mеню персонажа {4DB8E6}|| Смена имени", "{FFFFFF}Введите ваше новое имя.\nАдминистрация меняет только nonRP ники.", "Далее", "Отмена");	
				}
				if(!strlen(inputtext))
				{
					SCM(playerid, COLOR_ERROR, "[Ошибка]{9AAAAB} Поле не может быть пустым.");
					return SPD(playerid, DLG_RED_NAME, DSI, "{FFFFFF}Mеню персонажа {4DB8E6}|| Смена имени", "{FFFFFF}Введите ваше новое имя.\nАдминистрация меняет только nonRP ники.", "Далее", "Отмена");	
				}
				SetPVarString(playerid, "RedName_String", inputtext);
				format(query, sizeof(query), "SELECT `pID` FROM `users` WHERE `pName` = '%s'", inputtext);
				mysql_tquery(dbHandle, query, "CheckAccountName", "is", playerid, inputtext);
			}
			else
			{
				SPD(playerid, DLG_MAINMENU_ADMIN, DSL, "{FFFFFF}Mеню персонажа {4DB8E6}|| Администрациия", "{FFFFFF}1. Связь с администрацией\n2. Заявка на смену ника\n3. Задать вопрос", "Далее", "Отмена");
			}
		}
		case DLG_MAINMENU:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0: // Статистика персонажа
				{
					new string[1200];
					new frakname[526];
					new nextlevel = PlayerInfo[playerid][pLevel] + 1;
					switch(PlayerInfo[playerid][pFraction])
					{
						case 0: { frakname = "Нет"; }
						case 1: { frakname = "LSPD"; }
						case 2: { frakname = "FBI"; }
						case 3: { frakname = "SANG"; }
						case 4: { frakname = "EMS"; }
						case 5: { frakname = "LCN"; }
						case 6: { frakname = "Yakuza"; }
						case 7: { frakname = "Government"; }
						case 8: { frakname = "CNN"; }
						case 9: { frakname = "The Ballas Gang"; }
						case 10: { frakname = "Los Santos Vagos"; }
						case 11: { frakname = "Russian Mafia"; }
						case 12: { frakname = "Grove Street"; }
						case 13: { frakname = "Varios Los Aztecas"; }
						case 14: { frakname = "The Rifa Gang"; }
						case 15: { frakname = "Hell’s Angels MC"; }
						case 16: { frakname = "Outlaws MC"; }
					}
					format(string, sizeof(string), "Наименование\tЗначение\n\
						Имя и Фамилия:\t%s\nУровень:\t%d\nОчки опыта:\t%d/%d\nДеньги:\t%d\n\
						Деньги в банке:\t%d\nТелефон:\t1\nОрганизация:\t%s\nРанг:\t%d\n\
						Наркотики:\t%d\nМатериалы:\t%d", 
						PlayerInfo[playerid][pName], PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pExp], nextlevel * exptonextlevel, 
						PlayerInfo[playerid][pMoney], PlayerInfo[playerid][pBankMoney], FracInfo[PlayerInfo[playerid][pFraction]-1][fName], PlayerInfo[playerid][pRank], PlayerInfo[playerid][pDrugs], PlayerInfo[playerid][pMaterials]);
					SPD(playerid, DLG_STATS, DSTH, "{FFFFFF}Mеню персонажа {4DB8E6}|| Статистика персонажа", string, "Далее", "Отмена");
				}
				case 4:
				{
					SPD(playerid, DLG_MAINMENU_ADMIN, DSL, "{FFFFFF}Mеню персонажа {4DB8E6}|| Администрациия", "{FFFFFF}1. Связь с администрацией\n2. Заявка на смену ника\n3. Задать вопрос", "Далее", "Отмена");
				}
			}
		}
		case DLG_SETSPAWN:
		{
			if(!response) return 1;
			new query[128];
			switch(listitem)
			{
				case 0:
				{
					if(PlayerInfo[playerid][pSpawn] == 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Данный тип местовозрождения уже выбран!");
					PlayerInfo[playerid][pSpawn] = 1;
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы выбрали новое местовозрождение. Новый тип местовозрождения - \"Спавн\".");
				}
				case 1:
				{
					if(PlayerInfo[playerid][pHouse] == 9999) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У вас нет дома!");
					if(PlayerInfo[playerid][pSpawn] == 3) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Данный тип местовозрождения уже выбран!");
					PlayerInfo[playerid][pSpawn] = 3;
					SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы выбрали новое местовозрождение. Новый тип местовозрождения - \"Частное имущество\".");
				}
			}
			format(query, sizeof(query), "UPDATE `users` SET `pSpawn` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[playerid][pSpawn], PlayerInfo[playerid][pID]);
			mysql_tquery(dbHandle, query);
		}
		case DLG_WARDROBEMENU:
		{
			if(!response) return 1;
			new HouseID = GetPVarInt(playerid, "HouseID");
			switch(listitem)
			{
				case 0: // Взять материалы
				{
					if(HouseInfo[HouseID][hStoreMaterials] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}В вашем шкафу отсутствуют материалы!");
					SPD(playerid, DLG_WMATERIALS, DSI, "{FFFFFF}Материалы {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во материалов, которое вы хотите взять", "Далее", "Назад");
				}
				case 1: // Взять наркотики
				{
					if(HouseInfo[HouseID][hStoreDrugs] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}В вашем шкафу отсутствуют наркотики!");
					SPD(playerid, DLG_WDRUGS, DSI, "{FFFFFF}Наркотики {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во наркотиков, которое вы хотите взять", "Далее", "Назад");
				}
				case 2: // Положить материалы
				{
					if(PlayerInfo[playerid][pMaterials] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У вас нет материалов, чтобы их положить!");
					SPD(playerid, DLG_WSETMATERIALS, DSI, "{FFFFFF}Материалы {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во материалов, которое вы хотите положить", "Далее", "Назад");
				}
				case 3: // Положить наркотики
				{
					if(PlayerInfo[playerid][pDrugs] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У вас нет наркотиков, чтобы их положить!");
					SPD(playerid, DLG_WSETDRUGS, DSI, "{FFFFFF}Наркотики {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во наркотиков, которое вы хотите положить", "Далее", "Назад");
				}
			}
		}
		case DLG_WMATERIALS:
		{
			if(!response) return SPD(playerid, DLG_WARDROBEMENU, DSL, "{FFFFFF}Шкаф {29B4EF}|| Дом", "{FFFFFF}[1] Взять материалы\n[2] Взять наркотики\n[3] Положить материалы\n[4] Положить наркотики", "Далее", "Закрыть");
			if(PlayerInfo[playerid][pMaterials] > 500) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете взять больше материалов!");
			if(!strlen(inputtext)) return SPD(playerid, DLG_WMATERIALS, DSI, "{FFFFFF}Материалы {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во материалов, которое вы хотите взять", "Далее", "Назад");
			new amount, query[128], string[128];
			if(sscanf(inputtext, "d", amount)) return SPD(playerid, DLG_WMATERIALS, DSI, "{FFFFFF}Материалы {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во материалов, которое вы хотите взять", "Далее", "Назад");
			if(amount > 500 || amount < 1)
			{
				SPD(playerid, DLG_WMATERIALS, DSI, "{FFFFFF}Материалы {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во материалов, которое вы хотите взять", "Далее", "Назад");
				return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете взять больше 500 материалов со шкафа!");
			}
			new HouseID = GetPVarInt(playerid, "HouseID");
			if(HouseInfo[HouseID][hStoreMaterials] < amount) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB} В шкафу нет столько материалов!");
			if(PlayerInfo[playerid][pMaterials] + amount > 500) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете взять столько материалов с собой!");
			HouseInfo[HouseID][hStoreMaterials] -= amount;
			PlayerInfo[playerid][pMaterials] += amount;
			format(query, sizeof(query), "UPDATE `users` SET `pMaterials` = '%d' WHERE `pID` = '%d'", PlayerInfo[playerid][pMaterials], PlayerInfo[playerid][pID]);
			mysql_tquery(dbHandle, query);
			format(string, sizeof(string), "[Информация] {FF69B4}Вы взяли {E3BB4F}%d {FFFFFF}материалов со шкафа!", amount);
			SCM(playerid, COLOR_INFO, string);
			SetStorage(HouseID);
		}
		case DLG_WSETMATERIALS:
		{
			if(!response) return SPD(playerid, DLG_WARDROBEMENU, DSL, "{FFFFFF}Шкаф {29B4EF}|| Дом", "{FFFFFF}[1] Взять материалы\n[2] Взять наркотики\n[3] Положить материалы\n[4] Положить наркотики", "Далее", "Закрыть");
			new HouseID = GetPVarInt(playerid, "HouseID");
			if(HouseInfo[HouseID][hStoreMaterials] > 1500) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете положить больше материалов!");
			if(!strlen(inputtext)) return SPD(playerid, DLG_WMATERIALS, DSI, "{FFFFFF}Материалы {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во материалов, которое вы хотите положить", "Далее", "Назад");
			new amount, query[128], string[128];
			if(sscanf(inputtext, "d", amount)) return SPD(playerid, DLG_WMATERIALS, DSI, "{FFFFFF}Материалы {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во материалов, которое вы хотите положить", "Далее", "Назад");
			if(amount > 1500 || amount < 1)
			{
				SPD(playerid, DLG_WMATERIALS, DSI, "{FFFFFF}Материалы {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во материалов, которое вы хотите положить", "Далее", "Назад");
				return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете положить больше 1500 материалов в шкаф!");
			}
			if(PlayerInfo[playerid][pMaterials] < amount) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB} У вас нет столько материалов!");
			if(HouseInfo[HouseID][hStoreMaterials] + amount > 1500) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете положить столько материалов в шкаф!");
			HouseInfo[HouseID][hStoreMaterials] += amount;
			PlayerInfo[playerid][pMaterials] -= amount;
			format(query, sizeof(query), "UPDATE `users` SET `pMaterials` = '%d' WHERE `pID` = '%d'", PlayerInfo[playerid][pMaterials], PlayerInfo[playerid][pID]);
			mysql_tquery(dbHandle, query);
			format(string, sizeof(string), "[Информация] {FF69B4}Вы положили {E3BB4F}%d {FFFFFF}материалов в шкаф!", amount);
			SCM(playerid, COLOR_INFO, string);
			SetStorage(HouseID);
		}
		case DLG_WSETDRUGS:
		{
			if(!response) return SPD(playerid, DLG_WARDROBEMENU, DSL, "{FFFFFF}Шкаф {29B4EF}|| Дом", "{FFFFFF}[1] Взять материалы\n[2] Взять наркотики\n[3] Положить материалы\n[4] Положить наркотики", "Далее", "Закрыть");
			new HouseID = GetPVarInt(playerid, "HouseID");
			if(HouseInfo[HouseID][hStoreDrugs] > 2000) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете положить больше материалов!");
			if(!strlen(inputtext)) return SPD(playerid, DLG_WSETDRUGS, DSI, "{FFFFFF}Наркотики {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во наркотиков, которое вы хотите положить", "Далее", "Назад");
			new amount, query[128], string[128];
			if(sscanf(inputtext, "d", amount)) return SPD(playerid, DLG_WSETDRUGS, DSI, "{FFFFFF}Наркотики {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во наркотиков, которое вы хотите положить", "Далее", "Назад");
			if(amount > 2000 || amount < 1)
			{
				SPD(playerid, DLG_WSETDRUGS, DSI, "{FFFFFF}Наркотики {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во наркотиков, которое вы хотите положить", "Далее", "Назад");
				return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете положить больше 2000 наркотиков в шкаф!");
			}
			if(PlayerInfo[playerid][pDrugs] < amount) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB} У вас нет столько наркотиков!");
			if(HouseInfo[HouseID][hStoreDrugs] + amount > 2000) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете положить столько наркотиков в шкаф!");
			HouseInfo[HouseID][hStoreDrugs] += amount;
			PlayerInfo[playerid][pDrugs] -= amount;
			format(query, sizeof(query), "UPDATE `users` SET `pDrugs` = '%d' WHERE `pID` = '%d'", PlayerInfo[playerid][pDrugs], PlayerInfo[playerid][pID]);
			mysql_tquery(dbHandle, query);
			format(string, sizeof(string), "[Информация] {FF69B4}Вы положили {E3BB4F}%d {FFFFFF}наркотиков в шкаф!", amount);
			SCM(playerid, COLOR_INFO, string);
			SetStorage(HouseID);
		}
		case DLG_WDRUGS:
		{
			if(!response) return SPD(playerid, DLG_WARDROBEMENU, DSL, "{FFFFFF}Шкаф {29B4EF}|| Дом", "{FFFFFF}[1] Взять материалы\n[2] Взять наркотики\n[3] Положить материалы\n[4] Положить наркотики", "Далее", "Закрыть");
			if(PlayerInfo[playerid][pDrugs] > 150) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете взять больше материалов!");
			if(!strlen(inputtext)) return SPD(playerid, DLG_WDRUGS, DSI, "{FFFFFF}Наркотики {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во наркотиков, которое вы хотите взять", "Далее", "Назад");
			new amount, query[128], string[128];
			if(sscanf(inputtext, "d", amount)) return SPD(playerid, DLG_WDRUGS, DSI, "{FFFFFF}Наркотики {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во наркотиков, которое вы хотите взять", "Далее", "Назад");
			if(amount > 500 || amount < 1)
			{
				SPD(playerid, DLG_WDRUGS, DSI, "{FFFFFF}Наркотики {29B4EF}|| Шкаф", "{FFFFFF}Введите кол-во наркотиков, которое вы хотите взять", "Далее", "Назад");
				return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете взять больше 150 наркотиков со шкафа!");
			}
			new HouseID = GetPVarInt(playerid, "HouseID");
			if(HouseInfo[HouseID][hStoreDrugs] < amount) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB} В шкафу нет столько наркотиков!");
			if(PlayerInfo[playerid][pDrugs] + amount > 150) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете взять столько наркотиков с собой!");
			HouseInfo[HouseID][hStoreDrugs] -= amount;
			PlayerInfo[playerid][pDrugs] += amount;
			format(query, sizeof(query), "UPDATE `users` SET `pDrugs` = '%d' WHERE `pID` = '%d'", PlayerInfo[playerid][pDrugs], PlayerInfo[playerid][pID]);
			mysql_tquery(dbHandle, query);
			format(string, sizeof(string), "[Информация] {FF69B4}Вы взяли {E3BB4F}%d {FFFFFF}наркотиков со шкафа!", amount);
			SCM(playerid, COLOR_INFO, string);
			SetStorage(HouseID);
		}
		case DLG_SPAWNCARS:
		{
			new string[128];
			if(response)
			{
				for(new i = 1; i < GetVehiclePoolSize(); i++)
				{
					SetVehicleToRespawn(i);
				}
				format(string, sizeof(string), "Администратор %s заспавнил весь транспорт!", PlayerInfo[playerid][pName]);
				SCMTA(0xFF0000FF, string);
			}
			else
			{
				for(new i = 1; i < GetVehiclePoolSize(); i++)
				{
					if(!IsVehicleOccupied(i))
					{
						SetVehicleToRespawn(i);
					}
				}
				format(string, sizeof(string), "Администратор %s[%d] заспавнил весь незанятый транспорт!", PlayerInfo[playerid][pName]);
				SCMTA(0xFF0000FF, string);
			}
		}
		case DLG_CREATEHOUSECLASS:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0:
				{
					SetPVarInt(playerid, "HouseType", 1);
					SPD(playerid, DLG_CREATEHOUSEINT, DSL, "{FFFFFF}Создание дома {FEA9D8}|| Интерьер дома", "{F3B634}[1] {FFFFFF}Интерьер \"Burglary house 2\"\n{F3B634}[2] {FFFFFF}Интерьер \"Burglary house 3\"\n{F3B634}[3] {FFFFFF}Интерьер \"Burglary house 19\"\n{F3B634}[4] {FFFFFF}Интерьер \"Safe House 2\"", "Далее", "Отмена");
				}
			}
		}
		case DLG_CREATEHOUSEINT:
		{
			if(!response) return SetPVarInt(playerid, "HouseType", 0);
			switch(listitem)
			{
				case 0:
				{
					SetPVarInt(playerid, "HouseInterior", 1);
					SetPVarInt(playerid, "SetPickupEnterHouse", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {7AC5E0}Нажмите клавишу \"Y\" на том месте, где будет расположен пикап входа");
				}
				case 1:
				{
					SetPVarInt(playerid, "HouseInterior", 2);
					SetPVarInt(playerid, "SetPickupEnterHouse", 1);
					SCM(playerid, COLOR_INFO, "[Информация] {7AC5E0}Нажмите клавишу \"Y\" на том месте, где будет расположен пикап входа");
				}
			}
		}
		case DLG_CREATEHOUSECOST:
		{
			new amount, query[128];
			if(sscanf(inputtext, "d", amount)) return SPD(playerid, DLG_CREATEHOUSECOST, DSI, "{FFFFFF}Создание дома {FEA9D8}|| Стоимость", "{FFFFFF}Введите стоимость будущего дома:", "Далее", "");
			if(amount > 50000000 || amount < 1)
			{
				SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Стоимость дома не может быть ниже 1 и выше 50-ти миллионов!");
				return SPD(playerid, DLG_CREATEHOUSECOST, DSI, "{FFFFFF}Создание дома {FEA9D8}|| Стоимость", "{FFFFFF}Введите стоимость будущего дома:", "Далее", "");
			}
			format(query, sizeof(query), "UPDATE `houses` SET `hCost` = '%d' WHERE `hID` = '%d'", amount, TotalHouses);
			mysql_tquery(dbHandle, query);
			SCM(playerid, COLOR_INFO, "[Информация] {7AC5E0}Нажмите клавишу \"Y\" на том месте, куда будет телепортироваться игрок при выходе из дома!");
			SetPVarInt(playerid, "SetHouseExitWaypoint", 1);
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
   	if(PlayerInfo[playerid][pAdmin] > 1 && AdminInfo[playerid][aLogged] == 1)
    {
            new vehicleid = GetPlayerVehicleID(playerid);
            if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
            {
                SetVehiclePos(vehicleid, fX, fY, fZ);
            }
            else
            {
                SetPlayerPos(playerid, fX, fY, fZ);
            }
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerInterior(playerid, 0);
            SendClientMessage(playerid, -1, "Вы были успешно телепортированы.");
    }
    return 1;
}
//============================== [ Стоки ] ================================
stock ConnectMySQL()
{
	dbHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_BASE);
	switch(mysql_errno())
	{
		case 0: print("\n[MySQL]: Подключение к базе данных успешно!\n");
		default: print("\n[MySQL]: Соединение с базой данных не найдено!\n");
	}
	mysql_log(ALL);
	mysql_set_charset("cp1251", dbHandle);
}

stock GetGangZoneColor(gangzone)
{
	new gOwnerGang;
	switch(GZInfo[gangzone][gOwner])
	{
		case 9: gOwnerGang = 0xD200FF99;
		case 10: gOwnerGang = 0xCFBE0899;
		case 12: gOwnerGang = 0x06B50699;
		case 13: gOwnerGang = 0x03C3B899;
		case 14: gOwnerGang = 0x007FFFAA;
		default: gOwnerGang = 0xFEFEFEAA;
	}
	return gOwnerGang;
}

stock StartSpectate(playerid, specid)
{
	if(IsPlayerInAnyVehicle(specid))
	{
		SetPlayerInterior(playerid,GetPlayerInterior(specid));
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(specid));
		TogglePlayerSpectating(playerid, 1);
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(specid));
	}
	else
	{
		SetPlayerInterior(playerid,GetPlayerInterior(specid));
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(specid));
		TogglePlayerSpectating(playerid, 1);
		PlayerSpectatePlayer(playerid, specid);
	}
	return true;
}

stock StopSpectate(playerid)
{
	return true;
}

stock SendMes(playerid, fstring[], {Float, _}:...)
{
    static const STATIC_ARGS = 3;
    new n = (numargs() - STATIC_ARGS) * BYTES_PER_CELL;
    if (n)
    {
        new message[128], arg_start, arg_end;
        #emit CONST.alt        fstring
        #emit LCTRL          5
        #emit ADD
        #emit STOR.S.pri        arg_start
        #emit LOAD.S.alt        n
        #emit ADD
        #emit STOR.S.pri        arg_end
        do
        {
            #emit LOAD.I
            #emit PUSH.pri
            arg_end -= BYTES_PER_CELL;
            #emit LOAD.S.pri      arg_end
        }
        while (arg_end > arg_start);
        // Push the static format parameters.
        #emit PUSH.S          fstring
        #emit PUSH.C          128
        #emit PUSH.ADR         message
        n += BYTES_PER_CELL * 3;
        #emit PUSH.S          n
        #emit SYSREQ.C         format
        n += BYTES_PER_CELL;
        #emit LCTRL          4
        #emit LOAD.S.alt        n
        #emit ADD
        #emit SCTRL          4
        return SendClientMessage(playerid, 0xFFFFFF, message);
    }
    else return SendClientMessage(playerid, 0xFFFFFF, fstring);
}

stock SendMesAll(fstring[], {Float, _}:...) 
{ 
    static const STATIC_ARGS = 2; 
    new n = (numargs() - STATIC_ARGS) * BYTES_PER_CELL; 
    if (n) 
    { 
        new message[128], arg_start, arg_end; 
        #emit CONST.alt        fstring 
        #emit LCTRL          5 
        #emit ADD 
        #emit STOR.S.pri        arg_start 
        #emit LOAD.S.alt        n 
        #emit ADD 
        #emit STOR.S.pri        arg_end 
        do 
        { 
            #emit LOAD.I 
            #emit PUSH.pri 
            arg_end -= BYTES_PER_CELL; 
            #emit LOAD.S.pri      arg_end 
        } 
        while (arg_end > arg_start); 
        // Push the static format parameters. 
        #emit PUSH.S          fstring 
        #emit PUSH.C          128 
        #emit PUSH.ADR         message 
        n += BYTES_PER_CELL * 3; 
        #emit PUSH.S          n 
        #emit SYSREQ.C         format 
        n += BYTES_PER_CELL; 
        #emit LCTRL          4 
        #emit LOAD.S.alt        n 
        #emit ADD 
        #emit SCTRL          4 
        return SendClientMessageToAll(0xFFFFFF, message); 
    } 
    else return SendClientMessageToAll(0xFFFFFF, fstring); 
} 

stock GetXYInBackOfPlayer(const playerid, &Float:x, &Float:y, const Float:distance)
{
	new Float:a; GetPlayerPos(playerid, x, y, a); GetPlayerFacingAngle(playerid, a);
	if (IsPlayerInAnyVehicle(playerid))
	{
		new vid=GetPlayerVehicleID(playerid);
		if (vid > 0 && vid <= MAX_VEHICLES)GetVehicleZAngle(vid, a);
	}
	x -= (distance * floatsin(-a, degrees)); y -= (distance * floatcos(-a, degrees));
}

stock GetPlayerWeaponAmmo(playerid, weaponid)
{
    new ammo, weapons[13][2];
    for(new i = 0; i < 13;i++)
    {
        GetPlayerWeaponData(playerid, i, weapons[i][0], weapons[i][1]);
        if(weapons[i][0] == weaponid)
        {
            ammo = weapons[i][1];
            break;
        }
    }
    return ammo;
}

stock GetVehicleSpeed(vehicleid)
{
    new Float:x, Float:y, Float:z;
    GetVehicleVelocity(vehicleid, x, y, z);
    return floatround(floatsqroot(x*x+y*y+z*z)*100);
}

stock SetVehicleSpeed(vehicleid, Float:speed)
{
    new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2, Float:a;
    GetVehicleVelocity(vehicleid, x1, y1, z1);
    GetVehiclePos(vehicleid, x2, y2, z2);
    GetVehicleZAngle(vehicleid, a); a = 360 - a;
    x1 = (floatsin(a, degrees) * (speed/100) + floatcos(a, degrees) * 0 + x2) - x2;
    y1 = (floatcos(a, degrees) * (speed/100) + floatsin(a, degrees) * 0 + y2) - y2;
    SetVehicleVelocity(vehicleid, x1, y1, z1);
}

stock SetPlayerToFacePlayer(playerid, targetid)
{
        new
                Float:pX,
                Float:pY,
                Float:pZ,
                Float:X,
                Float:Y,
                Float:Z,
                Float:ang;
        if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;
        GetPlayerPos(targetid, X, Y, Z);
        GetPlayerPos(playerid, pX, pY, pZ);
        if( Y > pY ) ang = (-acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);
        else if( Y < pY && X < pX ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 450.0);
        else if( Y < pY ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);
        if(X > pX) ang = (floatabs(floatabs(ang) + 180.0));
        else ang = (floatabs(ang) - 180.0);
        SetPlayerFacingAngle(playerid, ang);
        return 0;
}

stock CreateObjects()
{
    gate[1] = CreateObject(19911, 214.062667, 1875.866455, 13.201104, 0.000000, 0.000000, 90.000000); // гараж
    gate[0] = CreateObject(19313, 134.877975, 1941.352905, 21.657272, 0.000000, 0.000000, 180.000000); // кпп1
    gate[3] = CreateObject(19313, 285.734924, 1821.661865, 19.933525, 0.000000, 0.000000, 90.000000); // ворота внутри
    gate[4] = CreateObject(968, 1544.696777, -1630.804199, 13.012815, 0.000000, 89.399986, 90.000000); // шлагбаум_ЛСПД
	gate[2] = CreateObject(968, 347.687957, 1799.582519, 18.201555, 2.399999, -89.700057, 34.699996); // кпп-2
	gate[5] = CreateObject(1495, 1493.127685, 1051.502685, -51.427848, -0.000000, 0.000007, -0.000000); // rightIN
	SetObjectMaterial(gate[5], 2, 14668, "711c", "gun_ceiling1128", 0x00000000);
	gate[6] = CreateObject(1495, 1472.185668, 1032.260131, -51.427848, 0.000000, -0.000007, 179.999954); // leftO
	SetObjectMaterial(gate[6], 2, 14668, "711c", "gun_ceiling1128", 0x00000000);
	gate[7] = CreateObject(1495, 1473.152587, 1039.616333, -51.412124, 0.000007, 0.000000, 89.999977); // dopors1
	SetObjectMaterial(gate[7], 1, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	SetObjectMaterial(gate[7], 2, 14668, "711c", "gun_ceiling1128", 0x00000000);
	gate[8] = CreateObject(1495, 1473.152587, 1044.330810, -51.412124, -0.000007, -0.000000, -89.999977); // dopors2
	SetObjectMaterial(gate[8], 1, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	SetObjectMaterial(gate[8], 2, 14668, "711c", "gun_ceiling1128", 0x00000000);
	gate[9] = CreateObject(1495, 1494.634155, 1032.274047, -51.421325, 0.000000, -0.000007, 179.999954); // rightO
	SetObjectMaterial(gate[9], 2, 14668, "711c", "gun_ceiling1128", 0x00000000);
	gate[10] = CreateObject(19912, -979.041015, -1714.996704, 79.593902, 0.000000, 0.000000, 92.299964);
}

stock PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid, animlib, "null", 0.0, 0, 0, 0, 0, 0);
	return 1;
}

stock PreloadAnim(playerid)
{
    PreloadAnimLib(playerid, "PED");
    PreloadAnimLib(playerid, "FOOD");
    PreloadAnimLib(playerid, "CARRY");
    PreloadAnimLib(playerid, "BEACH");
    PreloadAnimLib(playerid, "GHANDS");
    PreloadAnimLib(playerid, "BASEBALL");
    PreloadAnimLib(playerid, "OTB");
    PreloadAnimLib(playerid, "ON_LOOKERS");
	return 1;
}

stock CreateVehicles()
{
	//======================================== [ LSPD ] =============================================
	lspdcar[0] = CreateVehicle(596, 1558.95801, -1709.74805, 5.711, 0.00, 0, 1, 600); //vehicle (Police LS) (1)
	lspdcar[1] = CreateVehicle(596, 1574.37793, -1709.74805, 5.711, 0.00, 0, 1, 600); //vehicle (Police LS) (2)
	lspdcar[2] = CreateVehicle(596, 1570.47754, -1709.74805, 5.711, 0.00, 0, 1, 600); //vehicle (Police LS) (3)
	lspdcar[3] = CreateVehicle(596, 1591.37793, -1709.74805, 5.711, 0.00, 0, 1, 600); //vehicle (Police LS) (4)
	lspdcar[4] = CreateVehicle(596, 1578.37793, -1709.74805, 5.711, 0.00, 0, 1, 600); //vehicle (Police LS) (5)
	lspdcar[5] = CreateVehicle(596, 1583.37793, -1709.74805, 5.711, 0.00, 0, 1, 600); //vehicle (Police LS) (6)
	lspdcar[6] = CreateVehicle(596, 1587.57715, -1709.74805, 5.711, 0.00, 0, 1, 600); //vehicle (Police LS) (7)
	lspdcar[7] = CreateVehicle(596, 1600.53003, -1704.07605, 5.711, 90, 0, 1, 600); //vehicle (Police LS) (8)
	lspdcar[8] = CreateVehicle(596, 1600.5293, -1696.17517, 5.711, 90, 0, 1, 600); //vehicle (Police LS) (9)
	lspdcar[9] = CreateVehicle(596, 1600.5293, -1700.1748, 5.711, 90, 0, 1, 600); //vehicle (Police LS) (10)
	lspdcar[10] = CreateVehicle(596, 1600.5293, -1692.07483, 5.711, 90, 0, 1, 600); //vehicle (Police LS) (11)
	lspdcar[11] = CreateVehicle(596, 1600.5293, -1687.87427, 5.711, 90, 0, 1, 600); //vehicle (Police LS) (12)
	lspdcar[12] = CreateVehicle(596, 1600.5293, -1684.0741, 5.711, 90, 0, 1, 600); //vehicle (Police LS) (13)
	lspdcar[13] = CreateVehicle(599, 1544.41895, -1684.24597, 6.051, 90, 0, 1, 600); //vehicle (Police Ranger) (1)
	lspdcar[14] = CreateVehicle(599, 1544.41895, -1680.24512, 6.051, 90, 0, 1, 600); //vehicle (Police Ranger) (2)
	lspdcar[15] = CreateVehicle(599, 1544.41895, -1676.24512, 6.051, 90, 0, 1, 600); //vehicle (Police Ranger) (3)
	lspdcar[16] = CreateVehicle(599, 1544.41895, -1672.24512, 6.051, 90, 0, 1, 600); //vehicle (Police Ranger) (4)
	lspdcar[17] = CreateVehicle(427, 1544.19104, -1663.18103, 6.139, 90, 0, 1, 600); //vehicle (Enforcer) (1)
	lspdcar[18] = CreateVehicle(427, 1544.19043, -1659.18066, 6.139, 90, 0, 1, 600); //vehicle (Enforcer) (2)
	lspdcar[19] = CreateVehicle(427, 1544.19043, -1655.18066, 6.139, 90, 0, 1, 600); //vehicle (Enforcer) (3)
	lspdcar[20] = CreateVehicle(427, 1544.19043, -1651.18066, 6.139, 90, 0, 1, 600); //vehicle (Enforcer) (4)
	lspdcar[21] = CreateVehicle(426, 1538.55505, -1645.36401, 5.711, 180, 54, 1, 600); //vehicle (Premier) (1)
	lspdcar[22] = CreateVehicle(426, 1526.55469, -1645.36328, 5.711, 180, 54, 1, 600); //vehicle (Premier) (5)
	lspdcar[23] = CreateVehicle(426, 1530.55469, -1645.36328, 5.711, 180, 54, 1, 600); //vehicle (Premier) (6)
	lspdcar[24] = CreateVehicle(426, 1534.55469, -1645.36328, 5.711, 180, 54, 1, 600); //vehicle (Premier) (7)
	lspdcar[25] = CreateVehicle(523, 1529.24902, -1687.81494, 5.551, 270, 0, 0, 600); //vehicle (HPV1000) (1)
	lspdcar[26] = CreateVehicle(523, 1529.34302, -1684.06995, 5.551, 270, 0, 0, 600); //vehicle (HPV1000) (2)
	lspdcar[27] = CreateVehicle(523, 1544.29004, -1688.42004, 5.551, 90, 0, 0, 600); //vehicle (HPV1000) (3)
	lspdcar[28] = CreateVehicle(497, 1566.84204, -1654.62097, 28.661, 90, 0, 1, 600); //vehicle (Police Maverick) (1)
	lspdcar[29] = CreateVehicle(497, 1563.17505, -1643.06299, 28.667, 90, 0, 1, 600); //vehicle (Police Maverick) (2)
	//========================================= [ Rifa ] ============================================
	rifacar[0] = AddStaticVehicle(518,2159.4414,-1790.6936,13.1090,222.5660,217,217); // Buccaner [1]
	rifacar[1] = AddStaticVehicle(518,2164.1260,-1790.3690,13.1178,219.7980,217,217); // Buccaner [2]
	rifacar[2] = AddStaticVehicle(518,2168.8757,-1790.3706,13.1029,217.8429,217,217); // Buccaner [3]
	rifacar[3] = AddStaticVehicle(516,2190.8057,-1808.5251,13.2962,60.3480,217,217); // Nebula [1]
	rifacar[4] = AddStaticVehicle(516,2190.9258,-1804.3878,13.3034,61.4332,217,217); // Nebula [2]
	rifacar[5] = AddStaticVehicle(516,2191.3674,-1800.8794,13.3393,63.5904,217,217); // Nebula [3]
	rifacar[6] = AddStaticVehicle(422,2189.8557,-1786.0369,13.4432,359.2167,217,1); // Bobcat [1]
	rifacar[7] = AddStaticVehicle(482,2189.6477,-1792.5364,13.5785,358.7269,217,217); // Burrito [1]
	//========================================== [ Grove ] ==========================================
	grovecar[0] = AddStaticVehicle(482,2505.4175,-1694.7318,13.6743,0.0623,128,1); // Burrito [1]
	grovecar[1] = AddStaticVehicle(492,2486.7393,-1681.4042,13.1170,14.1089,128,128); // Greenwood [1]
	grovecar[2] = AddStaticVehicle(492,2490.5574,-1681.6705,13.1179,14.1139,128,128); // Greenwood [2]
	grovecar[3] = AddStaticVehicle(492,2495.5562,-1681.6583,13.1252,15.0337,128,128); // Greenwood [3]
	grovecar[4] = AddStaticVehicle(492,2499.2197,-1681.4493,13.1531,14.8996,128,128); // Greenwood [4]
	grovecar[5] = AddStaticVehicle(466,2506.2405,-1676.4003,13.1192,327.0371,128,128); // Glendale [1]
	grovecar[6] = AddStaticVehicle(466,2508.2493,-1666.3334,13.1404,11.5999,128,128); // Glendale [2]
	grovecar[7] = AddStaticVehicle(422,2473.5391,-1695.0175,13.5027,0.0952,128,1); // Bobcat [1]
	//========================================== [ Ballas ] =========================================
	ballascar[0] = AddStaticVehicle(566,2659.1335,-2011.1858,13.3358,306.1449,232,232); // Tahoma [1]
	ballascar[1] = AddStaticVehicle(566,2654.0247,-2011.1061,13.3362,307.2499,232,232); // Tahoma [2]
	ballascar[2] = AddStaticVehicle(422,2654.4963,-2031.4188,13.5461,86.3879,232,1); // Bobcat [1]
	ballascar[3] = AddStaticVehicle(412,2652.2971,-2041.9813,13.3877,1.0433,232,232); // Voodoo [1]
	ballascar[4] = AddStaticVehicle(412,2656.5288,-2042.0098,13.3876,359.8465,232,232); // Voodoo [2]
	ballascar[5] = AddStaticVehicle(482,2644.7644,-2036.0724,13.6753,1.0208,232,232); // Burrito [1]
	ballascar[6] = AddStaticVehicle(516,2660.1995,-2036.7361,13.3823,63.0128,232,232); // Nebula [1]
	//========================================== [ Aztec ] ==========================================
	azteccar[0] = AddStaticVehicle(518,1691.1556,-2120.2131,13.2152,319.3785,135,135); // Buccaneer [1]
	azteccar[1] = AddStaticVehicle(518,1686.5238,-2120.0706,13.2178,321.9630,135,135); // Buccaneer [2]
	azteccar[2] = AddStaticVehicle(567,1686.6616,-2105.4019,13.4192,223.2613,135,135); // Savanna [1]
	azteccar[3] = AddStaticVehicle(567,1690.8568,-2105.0710,13.4179,221.2854,135,135); // Savanna [2]
	azteccar[4] = AddStaticVehicle(567,1682.7570,-2106.2725,13.3756,224.5717,135,135); // Savanna [3]
	azteccar[5] = AddStaticVehicle(482,1662.6036,-2110.2490,13.6698,270.6568,135,135); // Burrito [1]
	azteccar[6] = AddStaticVehicle(422,1662.5122,-2116.0742,13.5353,269.5667,135,1); // Bobcat [1]
	//========================================== [ Vagos ] ==========================================
	vagoscar[0] = AddStaticVehicle(467,2769.8125,-1615.0052,10.6619,270.0323,6,6); // Oceanic [1]
	vagoscar[1] = AddStaticVehicle(467,2769.5835,-1606.4330,10.6619,270.6729,6,6); // Oceanic [2]
	vagoscar[2] = AddStaticVehicle(474,2789.1023,-1624.0983,10.6526,338.5455,6,1); // Hermes [1]
	vagoscar[3] = AddStaticVehicle(474,2784.7542,-1623.9557,10.6844,341.1503,6,1); // Hermes [2]
	vagoscar[4] = AddStaticVehicle(474,2780.5723,-1623.9972,10.6852,341.1966,6,1); // Hermes [3]
	vagoscar[5] = AddStaticVehicle(482,2800.7065,-1600.6243,11.1211,335.5752,6,1); // Burrito [1]
	vagoscar[6] = AddStaticVehicle(422,2797.5625,-1607.9323,10.9833,336.9315,6,1); // Bobcat [1]
	//=========================================  [ Грузчики ] =======================================
	loadercar[0] = AddStaticVehicle(530,2760.2234,-2204.8760,13.3116,90.1495,166,166); // Forklift [1]
	loadercar[1] = AddStaticVehicle(530,2760.1833,-2208.3521,13.3101,89.7337,166,166); // Forklift [2]
	loadercar[2] = AddStaticVehicle(530,2760.1868,-2211.8882,13.3117,90.1383,166,166); // Forklift [3]
	loadercar[3] = AddStaticVehicle(530,2760.1707,-2215.4224,13.3114,90.1917,166,166); // Forklift [4]
	loadercar[4] = AddStaticVehicle(530,2760.1589,-2219.0212,13.3107,90.0499,166,166); // Forklift [5]
	loadercar[5] = AddStaticVehicle(530,2741.8806,-2215.3015,13.3125,270.2171,166,166); // Forklift [6]
	loadercar[6] = AddStaticVehicle(530,2741.9133,-2212.6028,13.3116,269.0132,166,166); // Forklift [7]
	loadercar[7] = AddStaticVehicle(530,2741.9343,-2210.1011,13.3105,269.8704,166,166); // Forklift [8]
	loadercar[8] = AddStaticVehicle(530,2742.0098,-2207.4529,13.3110,268.6528,166,166); // Forklift [9]
	loadercar[9] = AddStaticVehicle(530,2742.1296,-2204.7095,13.3104,270.3819,166,166); // Forklift [10]
	//========================================= [ Автошкола ] =======================================
	ascar[0] = AddStaticVehicle(458,741.0390,-1437.7183,13.4177,1.6536,17,17); // Solair [1]
	ascar[1] = AddStaticVehicle(458,737.2419,-1437.6429,13.4176,359.6708,17,17); // Solair [2]
	ascar[2] = AddStaticVehicle(458,733.8050,-1437.5452,13.4140,0.3827,17,17); // Solair [3]
	ascar[3] = AddStaticVehicle(458,730.2997,-1437.6049,13.4171,358.8391,17,17); // Solair [4]
	ascar[4] = AddStaticVehicle(507,726.6663,-1437.3647,13.3625,359.2387,17,17); // Elegant [1]
	ascar[5] = AddStaticVehicle(507,722.6409,-1437.2748,13.3603,358.7411,17,17); // Elegant [2]
	ascar[6] = AddStaticVehicle(529,718.9680,-1437.4779,13.1676,0.9047,17,17); // Willard [1]
	ascar[7] = AddStaticVehicle(529,715.3720,-1437.5576,13.1688,359.8776,17,17); // Willard [2]
	ascar[8] = AddStaticVehicle(461,712.3361,-1438.7344,13.1252,4.0396,17,17); // PCJ-600 [1]
	ascar[9] = AddStaticVehicle(461,710.3662,-1438.8477,13.1222,0.2001,17,17); // PCJ-600 [2]
	ascar[10] = AddStaticVehicle(461,708.3637,-1438.9426,13.1225,6.2881,17,17); // PCJ-600 [3]
	ascar[11] = AddStaticVehicle(461,706.1718,-1438.9705,13.1248,2.2826,17,17); // PCJ-600 [4]
	//===================================== [ Автобусы ЛС ] =========================================
	CreateVehicle(431, 1274.89099, -1797.09595, 13.645, 90, 71, 87, 600); //vehicle (Bus) (1)
	CreateVehicle(431, 1274.89099, -1802.09595, 13.645, 90, 71, 87, 600); //vehicle (Bus) (2)
	CreateVehicle(431, 1274.89063, -1807.0957, 13.645, 90, 71, 87, 600); //vehicle (Bus) (3)
	CreateVehicle(431, 1274.89063, -1812.0957, 13.645, 90, 71, 87, 600); //vehicle (Bus) (4)
	CreateVehicle(431, 1274.89063, -1817.0957, 13.645, 90, 71, 87, 600); //vehicle (Bus) (5)
	CreateVehicle(431, 1274.89063, -1822.0957, 13.645, 90, 71, 87, 600); //vehicle (Bus) (6)
	CreateVehicle(431, 1274.89063, -1827.0957, 13.645, 90, 71, 87, 600); //vehicle (Bus) (7)
	//=================================== [ Такси ЛС (1lvl) ] =======================================
	CreateVehicle(420, 1061.94397, -1775.58728, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (1)
	CreateVehicle(420, 1061.94336, -1737.48633, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (2)
	CreateVehicle(420, 1061.94336, -1740.28711, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (3)
	CreateVehicle(420, 1061.94336, -1743.18652, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (4)
	CreateVehicle(420, 1061.94336, -1746.18652, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (5)
	CreateVehicle(420, 1061.94336, -1749.18652, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (6)
	CreateVehicle(420, 1061.94336, -1752.08691, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (7)
	CreateVehicle(420, 1061.94336, -1754.88672, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (8)
	CreateVehicle(420, 1061.94336, -1757.88672, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (9)
	CreateVehicle(420, 1061.94336, -1760.88672, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (10)
	CreateVehicle(420, 1061.94336, -1763.78711, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (11)
	CreateVehicle(420, 1061.94336, -1766.78711, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (12)
	CreateVehicle(420, 1061.94336, -1769.58691, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (13)
	CreateVehicle(420, 1061.94336, -1772.58691, 13.329, 270, 6, 1, 600); //vehicle (Taxi) (14)
	//================================== [ Las-Venturas ARMY ] ======================================
	sangcar[0] = CreateVehicle(497, -1050.745, -1625.10205, 82.07, 0.00, 44, 44, 600); //vehicle (Police Maverick) (1)
	sangcar[1] = CreateVehicle(497, -1038.81494, -1625.72998, 82.07, 0.00, 44, 44, 600); //vehicle (Police Maverick) (2)
	sangcar[2] = CreateVehicle(433, -986.521, -1582.20203, 76.944, 180, 43, 0, 600); //vehicle (Barracks) (1)
	sangcar[3] = CreateVehicle(433, -1011.52051, -1582.20117, 76.944, 180, 43, 0, 600); //vehicle (Barracks) (2)
	sangcar[4] = CreateVehicle(433, -1006.52051, -1582.20117, 76.944, 180, 43, 0, 600); //vehicle (Barracks) (3)
	sangcar[5] = CreateVehicle(433, -1001.52051, -1582.20117, 76.944, 180, 43, 0, 600); //vehicle (Barracks) (4)
	sangcar[6] = CreateVehicle(433, -996.52051, -1582.20117, 76.944, 180, 43, 0, 600); //vehicle (Barracks) (5)
	sangcar[7] = CreateVehicle(433, -991.52051, -1582.20117, 76.944, 180, 43, 0, 600); //vehicle (Barracks) (6)
	sangcar[8] = CreateVehicle(470, -977.78998, -1610.625, 76.204, 90, 43, 0, 600); //vehicle (Patriot) (1)
	sangcar[9] = CreateVehicle(470, -977.789, -1593.625, 76.204, 90, 43, 0, 600); //vehicle (Patriot) (2)
	sangcar[10] = CreateVehicle(470, -977.78906, -1597.625, 76.204, 90, 43, 0, 600); //vehicle (Patriot) (3)
	sangcar[11] = CreateVehicle(470, -977.78906, -1601.625, 76.204, 90, 43, 0, 600); //vehicle (Patriot) (4)
	sangcar[12] = CreateVehicle(470, -977.78906, -1605.625, 76.204, 90, 43, 0, 600); //vehicle (Patriot) (5)
	sangcar[13] = CreateVehicle(598, -1019.37402, -1585.44397, 76.029, 180, 44, 44, 600); //vehicle (Police LV) (1)
	sangcar[14] = CreateVehicle(598, -1046.37402, -1585.44299, 76.029, 180, 44, 44, 600); //vehicle (Police LV) (2)
	sangcar[15] = CreateVehicle(598, -1037.37402, -1585.44336, 76.029, 180, 44, 44, 600); //vehicle (Police LV) (3)
	sangcar[16] = CreateVehicle(598, -1028.37402, -1585.44336, 76.029, 180, 44, 44, 600); //vehicle (Police LV) (4)
	sangcar[17] = CreateVehicle(470, -1121.93701, -1662.03796, 76.327, 270, 43, 0, 600); //vehicle (Patriot) (6)
	sangcar[18] = CreateVehicle(470, -1121.93652, -1658.03711, 76.327, 270, 43, 0, 600); //vehicle (Patriot) (7)
	sangcar[19] = CreateVehicle(470, -1121.93652, -1654.03711, 76.327, 270, 43, 0, 600); //vehicle (Patriot) (8)
	sangcar[20] = CreateVehicle(470, -1121.93652, -1650.03711, 76.327, 270, 43, 0, 600); //vehicle (Patriot) (9)
	sangcar[21] = CreateVehicle(470, -1121.93652, -1646.03711, 76.327, 270, 43, 0, 600); //vehicle (Patriot) (10)
	sangcar[22] = CreateVehicle(500, -1100.32495, -1638.88196, 76.462, 180, 44, 1, 600); //vehicle (Mesa) (1)
	sangcar[23] = CreateVehicle(500, -1097.32422, -1638.88184, 76.462, 180, 44, 1, 600); //vehicle (Mesa) (2)
	sangcar[24] = CreateVehicle(500, -1091.32422, -1638.88184, 76.462, 180, 44, 1, 600); //vehicle (Mesa) (4)
	sangcar[25] = CreateVehicle(427, -1081.51099, -1627.60803, 76.29, 270, 44, 44, 600); //vehicle (Enforcer) (1)
	sangcar[26] = CreateVehicle(427, -1081.51074, -1623.60742, 76.29, 270, 44, 44, 600); //vehicle (Enforcer) (2)
	sangcar[27] = CreateVehicle(427, -1081.51074, -1619.60742, 76.29, 270, 44, 44, 600); //vehicle (Enforcer) (3)
	sangcar[28] = CreateVehicle(427, -1081.51074, -1615.60742, 76.29, 270, 44, 44, 600); //vehicle (Enforcer) (4)
	sangcar[29] = CreateVehicle(522, -1094.76001, -1633.16003, 76.034, 180, 44, 44, 600); //vehicle (NRG-500) (1)
	sangcar[30] = CreateVehicle(522, -1100.75977, -1633.15918, 76.034, 180, 44, 44, 600); //vehicle (NRG-500) (2)
	sangcar[31] = CreateVehicle(522, -1098.75977, -1633.15918, 76.034, 180, 44, 44, 600); //vehicle (NRG-500) (3)
	sangcar[32] = CreateVehicle(522, -1096.75977, -1633.15918, 76.034, 180, 44, 44, 600); //vehicle (NRG-500) (4)
	sangcar[33] = CreateVehicle(500, -1094.32422, -1638.88184, 76.462, 180, 44, 1, 600); //vehicle (Mesa) (5)
}

stock SaveHouse(HouseID)
{
	new query[256];
	format(query, sizeof(query), "UPDATE `houses` SET `hOwner` = '%s', `hOwned` = '%d', `hLocked` = '%d' WHERE `hID` = '%d'", HouseInfo[HouseID][hOwner], HouseInfo[HouseID][hOwned], HouseInfo[HouseID][hLocked], HouseInfo[HouseID][hID]);
	mysql_tquery(dbHandle, query);
}

stock SaveAccount(playerid)
{
	new query[256];
	format(query, sizeof(query), "UPDATE `users` SET `pBankMoney` = '%d', `pWanted` = '%d', `pTimeWanted` = '%d' WHERE `pName` = '%s'", PlayerInfo[playerid][pBankMoney], PlayerInfo[playerid][pWanted], PlayerInfo[playerid][pTimeWanted], PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query);
}

stock GiveMoney(playerid, amount)
{
	PlayerInfo[playerid][pMoney] += amount;
	new query[128];
	format(query, sizeof(query), "UPDATE `users` SET `pMoney` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[playerid][pMoney], PlayerInfo[playerid][pID]);
	mysql_tquery(dbHandle, query);
	GivePlayerMoney(playerid, amount);
}

stock SetHealth(playerid, Float:health)
{
	new query[75];
	format(query, sizeof(query), "UPDATE `users` SET `pHP` = '%f' WHERE `pID` = '%d' LIMIT 1", health, PlayerInfo[playerid][pID]);
	mysql_tquery(dbHandle, query);
	SetPlayerHealth(playerid, health);
}

stock IsACar(carid)
{
	switch(GetVehicleModel(carid))
	{
		case 400..416,418..424,426..429,431..445,449,451,455,456,458,459,461: return true;
		case 463,466..468,470,471,474,475,477..480,482,483,485,486,489..492,494..496,498..508: return true;
		case 514..518,521..531,533..537,539..547,549..551,554..562,564..568,572..576,578..583,585..589,596..605,609: return true;
	}
	return false;
}

stock ShowDamage(playerid, hitplayerid, idweapon, Float: damaga) // playerid - тот, кто наносит, hitplayerid - кому наносим, idweapon - ид оружия, damaga - урон
{
    new weapname[32],playeridname[MAX_PLAYER_NAME],hitplayerids[MAX_PLAYER_NAME],damages[MAX_PLAYER_NAME + 32 + 12];
    GetWeaponName(idweapon,weapname,sizeof(weapname)); GetPlayerName(playerid, playeridname, MAX_PLAYER_NAME); GetPlayerName(hitplayerid, hitplayerids, MAX_PLAYER_NAME);
    format(damages,sizeof(damages),"%s %s +%.0f", hitplayerids, weapname, damaga);
    TextDrawSetString(damage[playerid][0],damages);
    TextDrawShowForPlayer(playerid, damage[playerid][0]);
    format(damages,sizeof(damages),"%s %s -%.0f", playeridname, weapname, damaga);
    TextDrawSetString(damage[hitplayerid][1],damages);
    TextDrawShowForPlayer(hitplayerid, damage[hitplayerid][1]);
    SetTimerEx("HideTextdraw",5000,false,"ii",playerid,hitplayerid);
}

stock ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
	if(IsPlayerConnected(playerid))
	{
		new Float:posx;new Float:posy;new Float:posz;new Float:oldposx;new Float:oldposy;new Float:oldposz;new Float:tempposx;new Float:tempposy;new Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		foreach(new i: Player)
		{
			if(IsPlayerConnected(i))
			{
				if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
				{
					GetPlayerPos(i, posx, posy, posz);
					tempposx = (oldposx -posx);
					tempposy = (oldposy -posy);
					tempposz = (oldposz -posz);
					if(((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16))) SCM(i, col1, string);
					else if(((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8))) SCM(i, col2, string);
					else if(((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4))) SCM(i, col3, string);
					else if(((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2))) SCM(i, col4, string);
					else if(((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))) SCM(i, col5, string);
				}
			}
		}
	}
	return 1;
}

stock ShowLogin(playerid)
{
	SPD(playerid, DLG_AUTHORIZATION, DSP, "{FFFFFF}Авторизация {F385D5}|| Ввод пароля", "{FFFFFF}Добро пожаловать на Alliant Role Play\nВаш аккаунт зарегистрирован.\n\nВведите пароль от вашего аккаунта и нажмите \"Далее\"", "Далее", "Отмена");
}

stock ShowRegister(playerid)
{
	SPD(playerid, DLG_REGPASSWORD, DSI, "{FFFFFF}Регистрация {F385D5}|| Ввод пароля [1/5]", "{FFFFFF}Добро пожаловать на Alliant Role Play\nДля дальнейшей игры на сервере Вам необходимо пройти регистрацию\nВведите будущий пароль в поле ниже и нажмите \"Далее\"\n\n\t{1295CD}Примечания:\n\t * Пароль должен состоять только из латинских символов\n\t * Длина пароля должна составлять от 6-ти до 24-х символов\n\t * Пароль чувствителен к регистру", "Далее", "Отмена");
}

stock ShowRules(playerid)
{
	new string[2875];
	format(string, sizeof(string), "{FFFFFF}==========================================================================================================\n\n");
	format(string, sizeof(string), "%s{FF8B17}1. {80FF00}Игровой процесс.\n", string);
	format(string, sizeof(string), "%s{D70000}Запрещено:\n\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Использование любых программ, скриптов, читов и т.п., дающих нечестное преимущество в игре;\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Использование багов (Ошибок, неисправностей мода);\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Использование ESC в целях ухода от погони/смерти;\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Убийство игроков на спавне ( Место возрождения, базы организаций );\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Убийство игроков при помощи транспорта (Давить, Стрелять с водительского места);\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Убийство/нанесение физического вреда игрокам без причины (ДМ - Death Match);\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Развод игроков на имущество;\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Просьбы, вымогательство паролей от аккаунта;\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Выдача себя за членов администрации;\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Злоупотребление игровыми возможностями для создания неудобств игрокам.\n\n", string);
	format(string, sizeof(string), "%s{FF8B17}2. {80FF00}Ник в игре.\n", string);
	format(string, sizeof(string), "%s{D70000}Запрещено:\n\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Использовать чужие (уже кем-то занятые) ники;\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Использовать ники, содержащие нецензурные или оскорбительные слова;\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Отправлять более одной заявки на смену ника в час (Исключение: просьба администрации);\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Если вам отказали в смене ника, значит нельзя.\n\n", string);
	format(string, sizeof(string), "%s{FF8B17}3. {80FF00}Чат сервера.\n", string);
	format(string, sizeof(string), "%s{D70000}Запрещено:\n\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Ругательство, оскорбления или нецензурная речь;\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Угрозы игрокам (Не относящиеся к игровому процессу);\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Писать сообщения в верхнем регистре (Caps Lock);\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Писать в чат объявлений сообщения не относящихся к Role Play;\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Писать одно и тоже сообщение слишком часто (Flood);\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Обсуждать, критиковать действия администрации;\n\t", string);
	format(string, sizeof(string), "%s{FFFFFF}- Реклама сторонних ресурсов.\n\n", string);
	format(string, sizeof(string), "%s{FFFFFF}==========================================================================================================", string);
	SPD(playerid, DLG_REGRULES, DSM, "{FFFFFF}Регистрация {F385D5}|| Правила сервера [4/5]", string, "Принять", "Отмена");
	return 1;
}

stock IsAGos(playerid)
{
	new member = PlayerInfo[playerid][pFraction];
	if(member == 1 || member == 2 || member == 3 || member == 4 || member == 7) return true;
	else return false;
}

stock ZeroCharacter(playerid)
{
	PlayerInfo[playerid][pID] = 0;
	PlayerInfo[playerid][pName] = 0;
	PlayerInfo[playerid][pPassword] = 0;
	PlayerInfo[playerid][pEmail] = 0;
	PlayerInfo[playerid][pReferal] = 0;
	PlayerInfo[playerid][pGender] = 0;
	PlayerInfo[playerid][pAdmin] = 0;
	PlayerInfo[playerid][pLevel] = 0;
	PlayerInfo[playerid][pExp] = 0;
	PlayerInfo[playerid][pTime] = 0;
	PlayerInfo[playerid][pSkin] = 0;
	PlayerInfo[playerid][pRegData] = 0;
	PlayerInfo[playerid][pRegIP] = 0;
	PlayerInfo[playerid][pMoney] = 0;
	PlayerInfo[playerid][pBankMoney] = 0;
	PlayerInfo[playerid][pCarLic] = 0;
	PlayerInfo[playerid][pBikeLic] = 0;
	PlayerInfo[playerid][pAirLic] = 0;
	PlayerInfo[playerid][pBoatLic] = 0;
	PlayerInfo[playerid][pFishLic] = 0;
	PlayerInfo[playerid][pBizLic] = 0;
	PlayerInfo[playerid][pGunLic] = 0;
	PlayerInfo[playerid][pFraction] = 0;
	PlayerInfo[playerid][pRank] = 0;
	PlayerInfo[playerid][pFractionSkin] = 0;
	PlayerInfo[playerid][pHP] = 0;
	PlayerInfo[playerid][pMaterials] = 0;
	PlayerInfo[playerid][pDrugs] = 0;
	AdminInfo[playerid][aID] = 0;
	AdminInfo[playerid][aName] = 0;
	AdminInfo[playerid][aPassword] = 0;
	AdminInfo[playerid][aLastOnline] = 0;
	AdminInfo[playerid][aLogged] = 0;
	PlayerMute[playerid] = 0;
	PlayerAFK[playerid] = -2;
	SpecAd[playerid] = 65535;
	return 1;
}

stock HousePickupAndIcon(HouseID)
{
	DestroyDynamicMapIcon(HouseInfo[HouseID][hIcon]);
    DestroyDynamicPickup(HouseInfo[HouseID][hPickup]);
    new string[256];
	if(HouseInfo[HouseID][hOwned] == 0)
	{
		HouseInfo[HouseID][hPickup] = CreateDynamicPickup(1273, 23, HouseInfo[HouseID][hEnterX], HouseInfo[HouseID][hEnterY], HouseInfo[HouseID][hEnterZ], -1);
		HouseInfo[HouseID][hIcon] = CreateDynamicMapIcon(HouseInfo[HouseID][hEnterX], HouseInfo[HouseID][hEnterY], HouseInfo[HouseID][hEnterZ], 31, 0, -1, 0, -1, 180);
		format(string, sizeof(string), "{AAE837}[ Шкаф ]\n\n{EEA331}Материалы: {459EDA}%d/1500\n{EEA331}Наркотики: {459EDA}%d/2000", HouseInfo[HouseID][hStoreMaterials], HouseInfo[HouseID][hStoreDrugs]);
	}
	else
	{
		HouseInfo[HouseID][hPickup] = CreateDynamicPickup(1272, 23, HouseInfo[HouseID][hEnterX], HouseInfo[HouseID][hEnterY], HouseInfo[HouseID][hEnterZ], -1);
		HouseInfo[HouseID][hIcon] = CreateDynamicMapIcon(HouseInfo[HouseID][hEnterX], HouseInfo[HouseID][hEnterY], HouseInfo[HouseID][hEnterZ], 32, 0, -1, 0, -1, 180);
		format(string, sizeof(string), "{AAE837}[ Шкаф ]\n\n{EEA331}Материалы: {459EDA}%d/1500\n{EEA331}Наркотики: {459EDA}%d/2000\n\n{FFFFFF}Нажмите {F4D109}\"H\", {FFFFFF}чтобы открыть меню шкафа", HouseInfo[HouseID][hStoreMaterials], HouseInfo[HouseID][hStoreDrugs]);
	}
	switch(HouseInfo[HouseID][hClass])
	{
		case 1:
		{
			switch(HouseInfo[HouseID][hInterior])
			{
				// case 8:
				// {
				// 	HouseInfo[HouseID][hText3D] = CreateDynamic3DTextLabel("{FFFFFF}Нажмите {96B618}\"Enter\", {FFFFFF}чтобы выйти из дома\n{FFFFFF}Используйте {DCBC3D}\"ALT\", {FFFFFF}чтобы открыть настройки дома", 0xFFFFFFFF, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY] - 1.8, HouseInfo[HouseID][hiEnterZ] + 0.5, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, HouseID + 100, HouseInfo[HouseID][hInterior], -1, 3.0);
				// 	HouseInfo[HouseID][hWardrobeText] = CreateDynamic3DTextLabel(string, 0xFFFFFFFF, HouseInfo[HouseID][hWardrobeX], HouseInfo[HouseID][hWardrobeY], HouseInfo[HouseID][hWardrobeZ] + 0.7, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, HouseID + 100, 8, -1, 3.0);
				// }
				case 1:
				{
					HouseInfo[HouseID][hText3D] = CreateDynamic3DTextLabel("{FFFFFF}Нажмите {96B618}\"Enter\", {FFFFFF}чтобы выйти из дома\n{FFFFFF}Используйте {DCBC3D}\"ALT\", {FFFFFF}чтобы открыть настройки дома", 0xFFFFFFFF, HouseInfo[HouseID][hiEnterX] + 0.3, HouseInfo[HouseID][hiEnterY] - 1.8, HouseInfo[HouseID][hiEnterZ] + 0.5, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, HouseID + 100, HouseInfo[HouseID][hInterior], -1, 3.0);
					HouseInfo[HouseID][hWardrobeText] = CreateDynamic3DTextLabel(string, 0xFFFFFFFF, HouseInfo[HouseID][hWardrobeX], HouseInfo[HouseID][hWardrobeY], HouseInfo[HouseID][hWardrobeZ] + 0.7, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, HouseID + 100, HouseInfo[HouseID][hInterior], -1, 3.0);
				}
				case 2:
				{
					HouseInfo[HouseID][hText3D] = CreateDynamic3DTextLabel("{FFFFFF}Нажмите {96B618}\"Enter\", {FFFFFF}чтобы выйти из дома\n{FFFFFF}Используйте {DCBC3D}\"ALT\", {FFFFFF}чтобы открыть настройки дома", 0xFFFFFFFF, HouseInfo[HouseID][hiEnterX] + 1.5, HouseInfo[HouseID][hiEnterY], HouseInfo[HouseID][hiEnterZ] + 0.5, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, HouseID + 100, HouseInfo[HouseID][hInterior], -1, 3.0);
					HouseInfo[HouseID][hWardrobeText] = CreateDynamic3DTextLabel(string, 0xFFFFFFFF, HouseInfo[HouseID][hWardrobeX], HouseInfo[HouseID][hWardrobeY], HouseInfo[HouseID][hWardrobeZ] + 0.7, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, HouseID + 100, HouseInfo[HouseID][hInterior], -1, 3.0);
				}
				case 9:
				{
					HouseInfo[HouseID][hText3D] = CreateDynamic3DTextLabel("{FFFFFF}Нажмите {96B618}\"Enter\", {FFFFFF}чтобы выйти из дома\n{FFFFFF}Используйте {DCBC3D}\"ALT\", {FFFFFF}чтобы открыть настройки дома", 0xFFFFFFFF, HouseInfo[HouseID][hiEnterX], HouseInfo[HouseID][hiEnterY] - 2.2, HouseInfo[HouseID][hiEnterZ] + 0.5, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, HouseID + 100, HouseInfo[HouseID][hInterior], -1, 3.0);
					HouseInfo[HouseID][hWardrobeText] = CreateDynamic3DTextLabel(string, 0xFFFFFFFF, HouseInfo[HouseID][hWardrobeX], HouseInfo[HouseID][hWardrobeY], HouseInfo[HouseID][hWardrobeZ] + 0.7, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, HouseID + 100, 9, -1, 3.0);
				}
			}
		}
	}
}

stock SetStorage(HouseID)
{
	new string[256];
	format(string, sizeof(string), "{AAE837}[ Шкаф ]\n\n{EEA331}Материалы: {459EDA}%d/1500\n{EEA331}Наркотики: {459EDA}%d/2000\n\n{FFFFFF}Нажмите {F4D109}\"H\", {FFFFFF}чтобы открыть меню шкафа", HouseInfo[HouseID][hStoreMaterials], HouseInfo[HouseID][hStoreDrugs]);
	UpdateDynamic3DTextLabelText(HouseInfo[HouseID][hWardrobeText], 0xFFFFFFFF, string);
	SaveStorage(HouseID);
}

stock SaveStorage(HouseID)
{
	new query[256];
	format(query, sizeof(query), "UPDATE `houses` SET `hStoreMaterials` = '%d', `hStoreDrugs` = '%d' WHERE `hID` = '%d'", HouseInfo[HouseID][hStoreMaterials], HouseInfo[HouseID][hStoreDrugs], HouseInfo[HouseID][hID]);
	mysql_tquery(dbHandle, query);
}

stock PickupLoad()
{
	healthspls = CreatePickup(1240, 23, 1160.8635, -1771.6140, 16.5938, 0); // Пикап выдачи здоровья на спавне ЛС
	LOADERPIC = CreatePickup(19135, 23, 2682.7825,-2263.4648,12.0966 - 0.5, 0); // Пикап получения обьекта на грузчиках
	DRUGDEN[0] = CreatePickup(1318, 23, 2165.9128,-1671.2115,15.0732, 0); // Пикап входа в наркопритон
	DRUGDEN[1] = CreatePickup(1318, 23, 318.6221, 1114.4792, 1083.8828, 5); // Пикап выхода из наркопритона
 	victimenter[0] = CreatePickup(1318, 23, 460.9278,-1500.8904,31.0586, 0); // Вход в МО Стандарт
	victimenter[1] = CreatePickup(1318, 23, 227.5629,-8.0838,1002.2109, 5); // Вход в МО Стандарт
	lspd[0] = CreatePickup(353, 23, 1481.9948, 1057.2197, -50.4082, 1); // Оружие LSPD
	lspdenter[0] = CreatePickup(1318, 23, 1555.4999, -1675.5962, 16.1953, 0); // Вход в LSPD
	lspdexit[0] = CreatePickup(1318, 23, 1483.253540, 1021.407653, -50.380134, 1); // Выход из LSPD
	lspdenter[1] = CreatePickup(1318, 23, 1568.6572, -1689.9727 ,6.2188, 0); // Вход в LSPD (Гараж)
	lspdexit[1] = CreatePickup(1318, 23, 1497.1587,1046.6195,-50.4082, 1); // Выход из LSPD (Гараж)
	lspdinvite = CreatePickup(1275, 23, 1484.8503,1057.2629,-50.4082, 1); // Раздевалка LSPD
	rifaenter = CreatePickup(1318, 23, 2185.8254,-1815.2264,13.5469, 0); // Вход в здание Rifa
	rifaexit = CreatePickup(1318, 23, 2807.6382, -1174.7576, 1025.5703, 8); // Выход из здания Rifa
	loaderinvite = CreatePickup(1275, 23, 2644.5476,-2215.4133,13.5501, 0); // Трудоустройство на грузчиках
	SANG[0] = CreatePickup(1318, 23, -1107.0048,-1672.4940,76.3672, 0); // Вход в казарму SANG
	SANG[1] = CreatePickup(1318, 23, -1112.3726,-1724.7053,59.9490, 25); // Выход из казармы SANG
	SANG[2] = CreatePickup(353, 23, -1095.6782,-1727.9934,59.9490, 25); // Оружие SANG
	SANG[3] = CreatePickup(1275, 23, -1120.2867,-1711.9076,59.9548, 25); // Раздевалка SANG
	SANG[4] = CreatePickup(1318, 23, -1108.9335,-1641.7371,76.3672, 0); // Вход в штаб SANG
	SANG[5] = CreatePickup(1318, 23, -1115.5889,-1633.5762,59.9490, 26); // Выход из штаба SANG
	SANG[6] = CreatePickup(1318, 23, -1065.0961,-1582.3878,76.3672, 0); // Вход в ГС SANG
	SANG[7] = CreatePickup(1318, 23, 316.4197,-170.2965,999.5938, 25); // Выход из ГС SANG
	GROVE[0] = CreatePickup(1318, 23, 2495.4175,-1691.1396,14.7656, 0); // Вход в Grove
	GROVE[1] = CreatePickup(1318, 23, 2496.0236,-1692.0837,1014.7422, 3); // Выход из Grove
	VAGOS[0] = CreatePickup(1318, 23, 2770.7031,-1628.7231,12.1775, 0); // Вход в Vagos
	VAGOS[1] = CreatePickup(1318, 23, 299.8171,310.1722,1003.3047, 4); // Выход из Vagos
	BALLAS[0] = CreatePickup(1318, 23, 2650.7043,-2021.8202,14.1766, 0); // Вход в Ballas
	BALLAS[1] = CreatePickup(1318, 23, 2333.0840,-1077.3541,1049.0234, 6); // Выход из Ballas
	AZTEC[0] = CreatePickup(1318, 23, 1667.4838,-2106.9377,14.0723, 0); // Вход в Aztec
	AZTEC[1] = CreatePickup(1318, 23, -42.5801,1405.4681,1084.4297, 8); // Выход из Aztec
	AUTOSCHOOL[0] = CreatePickup(1318, 23, 739.0128, -1418.5146, 13.5234, 0); // Вход в АШ передний
	AUTOSCHOOL[1] = CreatePickup(1318, 23, -2026.9050,-103.6016,1035.1836, 3); // Выход из АШ (первый)
	AUTOSCHOOL[2] = CreatePickup(1318, 23, 739.0376, -1428.7720, 13.8984, 0); // Вход в АШ с заднего двора
	AUTOSCHOOL[3] = CreatePickup(1318, 23, -2029.6948,-119.6248,1035.1719, 3); // Выход на задний двор с АШ
	MayorPic[0] = CreatePickup(1318, 23, 1481.0587,-1772.3138,18.7958, 0); // Вход в мэрию
	MayorPic[1] = CreatePickup(1318, 23, 389.9373,173.7561,1008.3828, 3); // Выход из мэрии
 	// AddStaticPickup(19607, 23, -125.457, -103.603, -39.33, 18);
	// AddStaticPickup(19607, 23, 204.32001, 1869.49805, 11.841);
}

stock CreateTextDraws()
{
	//=========================== [ Грузчики ] ===============================
	selectskinloader[0] = TextDrawCreate(257.000000, 389.200012, "ld_beat:chit");
	TextDrawFont(selectskinloader[0], 4);
	TextDrawLetterSize(selectskinloader[0], 0.600000, 2.000000);
	TextDrawTextSize(selectskinloader[0], 30.000000, 28.500000);
	TextDrawSetOutline(selectskinloader[0], 1);
	TextDrawSetShadow(selectskinloader[0], 0);
	TextDrawAlignment(selectskinloader[0], 1);
	TextDrawColor(selectskinloader[0], -1962934017);
	TextDrawBackgroundColor(selectskinloader[0], 255);
	TextDrawBoxColor(selectskinloader[0], 50);
	TextDrawUseBox(selectskinloader[0], 1);
	TextDrawSetProportional(selectskinloader[0], 1);
	TextDrawSetSelectable(selectskinloader[0], 0);

	selectskinloader[1] = TextDrawCreate(273.000000, 394.000000, "ld_dual:white");
	TextDrawFont(selectskinloader[1], 4);
	TextDrawLetterSize(selectskinloader[1], 0.600000, 2.000000);
	TextDrawTextSize(selectskinloader[1], 86.500000, 18.500000);
	TextDrawSetOutline(selectskinloader[1], 1);
	TextDrawSetShadow(selectskinloader[1], 0);
	TextDrawAlignment(selectskinloader[1], 1);
	TextDrawColor(selectskinloader[1], -1962934017);
	TextDrawBackgroundColor(selectskinloader[1], 255);
	TextDrawBoxColor(selectskinloader[1], 50);
	TextDrawUseBox(selectskinloader[1], 1);
	TextDrawSetProportional(selectskinloader[1], 1);
	TextDrawSetSelectable(selectskinloader[1], 0);

	selectskinloader[2] = TextDrawCreate(345.000000, 389.200012, "ld_beat:chit");
	TextDrawFont(selectskinloader[2], 4);
	TextDrawLetterSize(selectskinloader[2], 0.600000, 2.000000);
	TextDrawTextSize(selectskinloader[2], 31.500000, 28.500000);
	TextDrawSetOutline(selectskinloader[2], 1);
	TextDrawSetShadow(selectskinloader[2], 0);
	TextDrawAlignment(selectskinloader[2], 1);
	TextDrawColor(selectskinloader[2], -1962934017);
	TextDrawBackgroundColor(selectskinloader[2], 255);
	TextDrawBoxColor(selectskinloader[2], 50);
	TextDrawUseBox(selectskinloader[2], 1);
	TextDrawSetProportional(selectskinloader[2], 1);
	TextDrawSetSelectable(selectskinloader[2], 0);

	selectskinloader[3] = TextDrawCreate(352.000000, 396.000000, ">>");
	TextDrawFont(selectskinloader[3], 1);
	TextDrawLetterSize(selectskinloader[3], 0.329165, 1.549998);
	TextDrawTextSize(selectskinloader[3], 368.500000, 17.000000);
	TextDrawSetOutline(selectskinloader[3], 1);
	TextDrawSetShadow(selectskinloader[3], 0);
	TextDrawAlignment(selectskinloader[3], 1);
	TextDrawColor(selectskinloader[3], -1);
	TextDrawBackgroundColor(selectskinloader[3], 255);
	TextDrawBoxColor(selectskinloader[3], 0);
	TextDrawUseBox(selectskinloader[3], 1);
	TextDrawSetProportional(selectskinloader[3], 0);
	TextDrawSetSelectable(selectskinloader[3], 1);

	selectskinloader[4] = TextDrawCreate(265.000000, 396.000000, "<<");
	TextDrawFont(selectskinloader[4], 1);
	TextDrawLetterSize(selectskinloader[4], 0.329165, 1.549998);
	TextDrawTextSize(selectskinloader[4], 280.500000, 17.000000);
	TextDrawSetOutline(selectskinloader[4], 1);
	TextDrawSetShadow(selectskinloader[4], 0);
	TextDrawAlignment(selectskinloader[4], 1);
	TextDrawColor(selectskinloader[4], -1);
	TextDrawBackgroundColor(selectskinloader[4], 255);
	TextDrawBoxColor(selectskinloader[4], 0);
	TextDrawUseBox(selectskinloader[4], 1);
	TextDrawSetProportional(selectskinloader[4], 0);
	TextDrawSetSelectable(selectskinloader[4], 1);

	selectskinloader[5] = TextDrawCreate(293.000000, 395.000000, "SELECT");
	TextDrawFont(selectskinloader[5], 1);
	TextDrawLetterSize(selectskinloader[5], 0.412499, 1.649999);
	TextDrawTextSize(selectskinloader[5], 340.500000, 17.000000);
	TextDrawSetOutline(selectskinloader[5], 1);
	TextDrawSetShadow(selectskinloader[5], 0);
	TextDrawAlignment(selectskinloader[5], 1);
	TextDrawColor(selectskinloader[5], -1);
	TextDrawBackgroundColor(selectskinloader[5], 255);
	TextDrawBoxColor(selectskinloader[5], 0);
	TextDrawUseBox(selectskinloader[5], 1);
	TextDrawSetProportional(selectskinloader[5], 1);
	TextDrawSetSelectable(selectskinloader[5], 1);

	selectskinloader[6] = TextDrawCreate(279.000000, 414.200012, "ld_beat:chit");
	TextDrawFont(selectskinloader[6], 4);
	TextDrawLetterSize(selectskinloader[6], 0.600000, 2.000000);
	TextDrawTextSize(selectskinloader[6], 30.000000, 28.500000);
	TextDrawSetOutline(selectskinloader[6], 1);
	TextDrawSetShadow(selectskinloader[6], 0);
	TextDrawAlignment(selectskinloader[6], 1);
	TextDrawColor(selectskinloader[6], -1962934017);
	TextDrawBackgroundColor(selectskinloader[6], 255);
	TextDrawBoxColor(selectskinloader[6], 50);
	TextDrawUseBox(selectskinloader[6], 1);
	TextDrawSetProportional(selectskinloader[6], 1);
	TextDrawSetSelectable(selectskinloader[6], 0);

	selectskinloader[7] = TextDrawCreate(293.000000, 419.000000, "ld_dual:white");
	TextDrawFont(selectskinloader[7], 4);
	TextDrawLetterSize(selectskinloader[7], 0.600000, 2.000000);
	TextDrawTextSize(selectskinloader[7], 46.000000, 19.000000);
	TextDrawSetOutline(selectskinloader[7], 1);
	TextDrawSetShadow(selectskinloader[7], 0);
	TextDrawAlignment(selectskinloader[7], 1);
	TextDrawColor(selectskinloader[7], -1962934017);
	TextDrawBackgroundColor(selectskinloader[7], 255);
	TextDrawBoxColor(selectskinloader[7], 50);
	TextDrawUseBox(selectskinloader[7], 1);
	TextDrawSetProportional(selectskinloader[7], 1);
	TextDrawSetSelectable(selectskinloader[7], 0);

	selectskinloader[8] = TextDrawCreate(323.100006, 414.200012, "ld_beat:chit");
	TextDrawFont(selectskinloader[8], 4);
	TextDrawLetterSize(selectskinloader[8], 0.600000, 2.000000);
	TextDrawTextSize(selectskinloader[8], 30.000000, 28.500000);
	TextDrawSetOutline(selectskinloader[8], 1);
	TextDrawSetShadow(selectskinloader[8], 0);
	TextDrawAlignment(selectskinloader[8], 1);
	TextDrawColor(selectskinloader[8], -1962934017);
	TextDrawBackgroundColor(selectskinloader[8], 255);
	TextDrawBoxColor(selectskinloader[8], 50);
	TextDrawUseBox(selectskinloader[8], 1);
	TextDrawSetProportional(selectskinloader[8], 1);
	TextDrawSetSelectable(selectskinloader[8], 0);

	selectskinloader[9] = TextDrawCreate(290.000000, 420.000000, "CANCEL");
	TextDrawFont(selectskinloader[9], 1);
	TextDrawLetterSize(selectskinloader[9], 0.412499, 1.649999);
	TextDrawTextSize(selectskinloader[9], 340.500000, 17.000000);
	TextDrawSetOutline(selectskinloader[9], 1);
	TextDrawSetShadow(selectskinloader[9], 0);
	TextDrawAlignment(selectskinloader[9], 1);
	TextDrawColor(selectskinloader[9], -1);
	TextDrawBackgroundColor(selectskinloader[9], 255);
	TextDrawBoxColor(selectskinloader[9], 0);
	TextDrawUseBox(selectskinloader[9], 1);
	TextDrawSetProportional(selectskinloader[9], 1);
	TextDrawSetSelectable(selectskinloader[9], 1);
	//========================= [ Выбор скина ] ==============================
	selectskin_TD[0] = TextDrawCreate(235.000000, 407.000000, "ld_dual:white");
	TextDrawFont(selectskin_TD[0], 4);
	TextDrawLetterSize(selectskin_TD[0], 0.600000, 2.000000);
	TextDrawTextSize(selectskin_TD[0], 31.500000, -19.500000);
	TextDrawSetOutline(selectskin_TD[0], 1);
	TextDrawSetShadow(selectskin_TD[0], 0);
	TextDrawAlignment(selectskin_TD[0], 1);
	TextDrawColor(selectskin_TD[0], -2016478475);
	TextDrawBackgroundColor(selectskin_TD[0], 255);
	TextDrawBoxColor(selectskin_TD[0], 50);
	TextDrawUseBox(selectskin_TD[0], 1);
	TextDrawSetProportional(selectskin_TD[0], 1);
	TextDrawSetSelectable(selectskin_TD[0], 0);

	selectskin_TD[1] = TextDrawCreate(224.000000, 412.000000, "ld_beat:chit");
	TextDrawFont(selectskin_TD[1], 4);
	TextDrawLetterSize(selectskin_TD[1], 0.600000, 2.000000);
	TextDrawTextSize(selectskin_TD[1], 21.500000, -29.000000);
	TextDrawSetOutline(selectskin_TD[1], 1);
	TextDrawSetShadow(selectskin_TD[1], 0);
	TextDrawAlignment(selectskin_TD[1], 1);
	TextDrawColor(selectskin_TD[1], -2016478465);
	TextDrawBackgroundColor(selectskin_TD[1], 255);
	TextDrawBoxColor(selectskin_TD[1], 50);
	TextDrawUseBox(selectskin_TD[1], 1);
	TextDrawSetProportional(selectskin_TD[1], 1);
	TextDrawSetSelectable(selectskin_TD[1], 0);

	selectskin_TD[2] = TextDrawCreate(255.000000, 411.000000, "ld_beat:chit");
	TextDrawFont(selectskin_TD[2], 4);
	TextDrawLetterSize(selectskin_TD[2], 0.600000, 2.000000);
	TextDrawTextSize(selectskin_TD[2], 21.500000, -27.500000);
	TextDrawSetOutline(selectskin_TD[2], 1);
	TextDrawSetShadow(selectskin_TD[2], 0);
	TextDrawAlignment(selectskin_TD[2], 1);
	TextDrawColor(selectskin_TD[2], -2016478465);
	TextDrawBackgroundColor(selectskin_TD[2], 255);
	TextDrawBoxColor(selectskin_TD[2], 50);
	TextDrawUseBox(selectskin_TD[2], 1);
	TextDrawSetProportional(selectskin_TD[2], 1);
	TextDrawSetSelectable(selectskin_TD[2], 0);

	selectskin_TD[3] = TextDrawCreate(230.000000, 390.000000, "<< BACK");
	TextDrawFont(selectskin_TD[3], 1);
	TextDrawLetterSize(selectskin_TD[3], 0.275000, 1.450000);
	TextDrawTextSize(selectskin_TD[3], 270.500000, 17.000000);
	TextDrawSetOutline(selectskin_TD[3], 1);
	TextDrawSetShadow(selectskin_TD[3], 1);
	TextDrawAlignment(selectskin_TD[3], 1);
	TextDrawColor(selectskin_TD[3], -1);
	TextDrawBackgroundColor(selectskin_TD[3], 255);
	TextDrawBoxColor(selectskin_TD[3], 0);
	TextDrawUseBox(selectskin_TD[3], 1);
	TextDrawSetProportional(selectskin_TD[3], 1);
	TextDrawSetSelectable(selectskin_TD[3], true);

	selectskin_TD[4] = TextDrawCreate(286.000000, 407.000000, "ld_dual:white");
	TextDrawFont(selectskin_TD[4], 4);
	TextDrawLetterSize(selectskin_TD[4], 0.600000, 2.000000);
	TextDrawTextSize(selectskin_TD[4], 61.500000, -19.500000);
	TextDrawSetOutline(selectskin_TD[4], 1);
	TextDrawSetShadow(selectskin_TD[4], 0);
	TextDrawAlignment(selectskin_TD[4], 1);
	TextDrawColor(selectskin_TD[4], -2016478465);
	TextDrawBackgroundColor(selectskin_TD[4], 255);
	TextDrawBoxColor(selectskin_TD[4], 50);
	TextDrawUseBox(selectskin_TD[4], 1);
	TextDrawSetProportional(selectskin_TD[4], 1);
	TextDrawSetSelectable(selectskin_TD[4], 0);

	selectskin_TD[5] = TextDrawCreate(274.000000, 412.000000, "ld_beat:chit");
	TextDrawFont(selectskin_TD[5], 4);
	TextDrawLetterSize(selectskin_TD[5], 0.600000, 2.000000);
	TextDrawTextSize(selectskin_TD[5], 21.500000, -29.000000);
	TextDrawSetOutline(selectskin_TD[5], 1);
	TextDrawSetShadow(selectskin_TD[5], 0);
	TextDrawAlignment(selectskin_TD[5], 1);
	TextDrawColor(selectskin_TD[5], -2016478465);
	TextDrawBackgroundColor(selectskin_TD[5], 255);
	TextDrawBoxColor(selectskin_TD[5], 50);
	TextDrawUseBox(selectskin_TD[5], 1);
	TextDrawSetProportional(selectskin_TD[5], 1);
	TextDrawSetSelectable(selectskin_TD[5], 0);

	selectskin_TD[6] = TextDrawCreate(335.000000, 411.850006, "ld_beat:chit");
	TextDrawFont(selectskin_TD[6], 4);
	TextDrawLetterSize(selectskin_TD[6], 0.600000, 2.000000);
	TextDrawTextSize(selectskin_TD[6], 21.500000, -29.000000);
	TextDrawSetOutline(selectskin_TD[6], 1);
	TextDrawSetShadow(selectskin_TD[6], 0);
	TextDrawAlignment(selectskin_TD[6], 1);
	TextDrawColor(selectskin_TD[6], -2016478465);
	TextDrawBackgroundColor(selectskin_TD[6], 255);
	TextDrawBoxColor(selectskin_TD[6], 50);
	TextDrawUseBox(selectskin_TD[6], 1);
	TextDrawSetProportional(selectskin_TD[6], 1);
	TextDrawSetSelectable(selectskin_TD[6], 0);

	selectskin_TD[7] = TextDrawCreate(297.000000, 390.000000, "SELECT");
	TextDrawFont(selectskin_TD[7], 1);
	TextDrawLetterSize(selectskin_TD[7], 0.337500, 1.400000);
	TextDrawTextSize(selectskin_TD[7], 330.000000, 17.000000);
	TextDrawSetOutline(selectskin_TD[7], 1);
	TextDrawSetShadow(selectskin_TD[7], 0);
	TextDrawAlignment(selectskin_TD[7], 1);
	TextDrawColor(selectskin_TD[7], -1);
	TextDrawBackgroundColor(selectskin_TD[7], 255);
	TextDrawBoxColor(selectskin_TD[7], 0);
	TextDrawUseBox(selectskin_TD[7], 1);
	TextDrawSetProportional(selectskin_TD[7], 1);
	TextDrawSetSelectable(selectskin_TD[7], true);

	selectskin_TD[8] = TextDrawCreate(366.000000, 407.000000, "ld_dual:white");
	TextDrawFont(selectskin_TD[8], 4);
	TextDrawLetterSize(selectskin_TD[8], 0.600000, 2.000000);
	TextDrawTextSize(selectskin_TD[8], 31.500000, -19.500000);
	TextDrawSetOutline(selectskin_TD[8], 1);
	TextDrawSetShadow(selectskin_TD[8], 0);
	TextDrawAlignment(selectskin_TD[8], 1);
	TextDrawColor(selectskin_TD[8], -2016478465);
	TextDrawBackgroundColor(selectskin_TD[8], 255);
	TextDrawBoxColor(selectskin_TD[8], 50);
	TextDrawUseBox(selectskin_TD[8], 1);
	TextDrawSetProportional(selectskin_TD[8], 1);
	TextDrawSetSelectable(selectskin_TD[8], 0);

	selectskin_TD[9] = TextDrawCreate(355.000000, 412.000000, "ld_beat:chit");
	TextDrawFont(selectskin_TD[9], 4);
	TextDrawLetterSize(selectskin_TD[9], 0.600000, 2.000000);
	TextDrawTextSize(selectskin_TD[9], 21.500000, -29.000000);
	TextDrawSetOutline(selectskin_TD[9], 1);
	TextDrawSetShadow(selectskin_TD[9], 0);
	TextDrawAlignment(selectskin_TD[9], 1);
	TextDrawColor(selectskin_TD[9], -2016478465);
	TextDrawBackgroundColor(selectskin_TD[9], 255);
	TextDrawBoxColor(selectskin_TD[9], 50);
	TextDrawUseBox(selectskin_TD[9], 1);
	TextDrawSetProportional(selectskin_TD[9], 1);
	TextDrawSetSelectable(selectskin_TD[9], 0);

	selectskin_TD[10] = TextDrawCreate(386.000000, 411.000000, "ld_beat:chit");
	TextDrawFont(selectskin_TD[10], 4);
	TextDrawLetterSize(selectskin_TD[10], 0.600000, 2.000000);
	TextDrawTextSize(selectskin_TD[10], 21.500000, -27.500000);
	TextDrawSetOutline(selectskin_TD[10], 1);
	TextDrawSetShadow(selectskin_TD[10], 0);
	TextDrawAlignment(selectskin_TD[10], 1);
	TextDrawColor(selectskin_TD[10], -2016478465);
	TextDrawBackgroundColor(selectskin_TD[10], 255);
	TextDrawBoxColor(selectskin_TD[10], 50);
	TextDrawUseBox(selectskin_TD[10], 1);
	TextDrawSetProportional(selectskin_TD[10], 1);
	TextDrawSetSelectable(selectskin_TD[10], 0);

	selectskin_TD[11] = TextDrawCreate(364.000000, 390.000000, "NEXT >>");
	TextDrawFont(selectskin_TD[11], 1);
	TextDrawLetterSize(selectskin_TD[11], 0.275000, 1.450000);
	TextDrawTextSize(selectskin_TD[11], 403.500000, 17.000000);
	TextDrawSetOutline(selectskin_TD[11], 1);
	TextDrawSetShadow(selectskin_TD[11], 0);
	TextDrawAlignment(selectskin_TD[11], 1);
	TextDrawColor(selectskin_TD[11], -1);
	TextDrawBackgroundColor(selectskin_TD[11], 255);
	TextDrawBoxColor(selectskin_TD[11], 0);
	TextDrawUseBox(selectskin_TD[11], 1);
	TextDrawSetProportional(selectskin_TD[11], 1);
	TextDrawSetSelectable(selectskin_TD[11], true);
	//========================= [ Логотип ] ==============================
	LogoAlliant_TD[0] = TextDrawCreate(575.3332, 11.6296, "ALLI"); // пусто
	TextDrawLetterSize(LogoAlliant_TD[0], 0.4000, 1.6000);
	TextDrawAlignment(LogoAlliant_TD[0], 1);
	TextDrawColor(LogoAlliant_TD[0], -1);
	TextDrawSetOutline(LogoAlliant_TD[0], 1);
	TextDrawBackgroundColor(LogoAlliant_TD[0], 255);
	TextDrawFont(LogoAlliant_TD[0], 1);
	TextDrawSetProportional(LogoAlliant_TD[0], 1);
	TextDrawSetShadow(LogoAlliant_TD[0], 1);

	LogoAlliant_TD[1] = TextDrawCreate(602.2266, 11.4148, "ANT"); // пусто
	TextDrawLetterSize(LogoAlliant_TD[1], 0.3733, 1.6082);
	TextDrawAlignment(LogoAlliant_TD[1], 1);
	TextDrawColor(LogoAlliant_TD[1], 512819199);
	TextDrawSetOutline(LogoAlliant_TD[1], 1);
	TextDrawBackgroundColor(LogoAlliant_TD[1], 255);
	TextDrawFont(LogoAlliant_TD[1], 1);
	TextDrawSetProportional(LogoAlliant_TD[1], 1);
	TextDrawSetShadow(LogoAlliant_TD[1], 1);

	LogoAlliant_TD[2] = TextDrawCreate(610.9998, -1.3851, "LD_BEAT:chit"); // пусто
	TextDrawTextSize(LogoAlliant_TD[2], 22.0000, 16.0000);
	TextDrawAlignment(LogoAlliant_TD[2], 1);
	TextDrawColor(LogoAlliant_TD[2], 512819199);
	TextDrawBackgroundColor(LogoAlliant_TD[2], 255);
	TextDrawFont(LogoAlliant_TD[2], 4);
	TextDrawSetProportional(LogoAlliant_TD[2], 0);
	TextDrawSetShadow(LogoAlliant_TD[2], 0);
	 
	LogoAlliant_TD[3] = TextDrawCreate(616.7998, 2.2037, "RP"); // пусто
	TextDrawLetterSize(LogoAlliant_TD[3], 0.2186, 0.9072);
	TextDrawAlignment(LogoAlliant_TD[3], 1);
	TextDrawColor(LogoAlliant_TD[3], -1);
	TextDrawBackgroundColor(LogoAlliant_TD[3], 255);
	TextDrawFont(LogoAlliant_TD[3], 2);
	TextDrawSetProportional(LogoAlliant_TD[3], 1);
	TextDrawSetShadow(LogoAlliant_TD[3], 1);
	//============================= [ Аренда транспорта ] ==============================
	rentcar_TD[0] = TextDrawCreate(246.2353, 121.4332, "Box"); // пусто
	TextDrawLetterSize(rentcar_TD[0], 0.0000, 20.5280);
	TextDrawTextSize(rentcar_TD[0], 418.2911, 0.0000);
	TextDrawAlignment(rentcar_TD[0], 1);
	TextDrawColor(rentcar_TD[0], 255);
	TextDrawUseBox(rentcar_TD[0], 1);
	TextDrawBoxColor(rentcar_TD[0], 255);
	TextDrawBackgroundColor(rentcar_TD[0], -5963521);
	TextDrawFont(rentcar_TD[0], 1);
	TextDrawSetProportional(rentcar_TD[0], 1);
	TextDrawSetShadow(rentcar_TD[0], 0);

	rentcar_TD[1] = TextDrawCreate(247.6470, 122.4166, "Box"); // пусто
	TextDrawLetterSize(rentcar_TD[1], 0.0000, 20.2698);
	TextDrawTextSize(rentcar_TD[1], 416.9508, 0.0000);
	TextDrawAlignment(rentcar_TD[1], 1);
	TextDrawColor(rentcar_TD[1], -5963521);
	TextDrawUseBox(rentcar_TD[1], 1);
	TextDrawBoxColor(rentcar_TD[1], 1736414062);
	TextDrawBackgroundColor(rentcar_TD[1], 255);
	TextDrawFont(rentcar_TD[1], 1);
	TextDrawSetProportional(rentcar_TD[1], 1);
	TextDrawSetShadow(rentcar_TD[1], 0);

	rentcar_TD[2] = TextDrawCreate(250.8822, 240.1665, "LD_BEAT:chit"); // пусто
	TextDrawTextSize(rentcar_TD[2], 35.0000, 44.0000);
	TextDrawAlignment(rentcar_TD[2], 1);
	TextDrawColor(rentcar_TD[2], 255);
	TextDrawBackgroundColor(rentcar_TD[2], 255);
	TextDrawFont(rentcar_TD[2], 4);
	TextDrawSetProportional(rentcar_TD[2], 0);
	TextDrawSetShadow(rentcar_TD[2], 0);

	rentcar_TD[3] = TextDrawCreate(379.8901, 240.0666, "LD_BEAT:chit"); // пусто
	TextDrawTextSize(rentcar_TD[3], 35.0000, 44.0000);
	TextDrawAlignment(rentcar_TD[3], 1);
	TextDrawColor(rentcar_TD[3], 255);
	TextDrawBackgroundColor(rentcar_TD[3], 255);
	TextDrawFont(rentcar_TD[3], 4);
	TextDrawSetProportional(rentcar_TD[3], 0);
	TextDrawSetShadow(rentcar_TD[3], 0);

	rentcar_TD[4] = TextDrawCreate(253.2353, 242.5000, "LD_BEAT:chit"); // пусто
	TextDrawTextSize(rentcar_TD[4], 30.0900, 38.9697);
	TextDrawAlignment(rentcar_TD[4], 1);
	TextDrawColor(rentcar_TD[4], 8423167);
	TextDrawBackgroundColor(rentcar_TD[4], 255);
	TextDrawFont(rentcar_TD[4], 4);
	TextDrawSetProportional(rentcar_TD[4], 0);
	TextDrawSetShadow(rentcar_TD[4], 0);
	TextDrawSetSelectable(rentcar_TD[4], true);

	rentcar_TD[5] = TextDrawCreate(382.3432, 242.5000, "LD_BEAT:chit"); // пусто
	TextDrawTextSize(rentcar_TD[5], 30.0900, 38.9697);
	TextDrawAlignment(rentcar_TD[5], 1);
	TextDrawColor(rentcar_TD[5], 8423167);
	TextDrawBackgroundColor(rentcar_TD[5], 255);
	TextDrawFont(rentcar_TD[5], 4);
	TextDrawSetProportional(rentcar_TD[5], 0);
	TextDrawSetShadow(rentcar_TD[5], 0);
	TextDrawSetSelectable(rentcar_TD[5], true);

	rentcar_TD[6] = TextDrawCreate(260.3529, 254.7500, "<<"); // пусто
	TextDrawLetterSize(rentcar_TD[6], 0.4000, 1.6000);
	TextDrawAlignment(rentcar_TD[6], 1);
	TextDrawColor(rentcar_TD[6], -1);
	TextDrawBackgroundColor(rentcar_TD[6], 255);
	TextDrawFont(rentcar_TD[6], 2);
	TextDrawSetProportional(rentcar_TD[6], 1);
	TextDrawSetShadow(rentcar_TD[6], 0);

	rentcar_TD[7] = TextDrawCreate(390.7058, 255.3332, ">>"); // пусто
	TextDrawLetterSize(rentcar_TD[7], 0.4000, 1.6000);
	TextDrawAlignment(rentcar_TD[7], 1);
	TextDrawColor(rentcar_TD[7], -1);
	TextDrawBackgroundColor(rentcar_TD[7], 255);
	TextDrawFont(rentcar_TD[7], 2);
	TextDrawSetProportional(rentcar_TD[7], 1);
	TextDrawSetShadow(rentcar_TD[7], 0);

	rentcar_TD[8] = TextDrawCreate(270.6470, 282.7500, "LD_SPAC:white"); // пусто
	TextDrawTextSize(rentcar_TD[8], 58.0000, 18.0000);
	TextDrawAlignment(rentcar_TD[8], 1);
	TextDrawColor(rentcar_TD[8], 255);
	TextDrawBackgroundColor(rentcar_TD[8], 255);
	TextDrawFont(rentcar_TD[8], 4);
	TextDrawSetProportional(rentcar_TD[8], 0);
	TextDrawSetShadow(rentcar_TD[8], 0);

	rentcar_TD[9] = TextDrawCreate(338.6513, 282.7500, "LD_SPAC:white"); // пусто
	TextDrawTextSize(rentcar_TD[9], 58.0000, 18.0000);
	TextDrawAlignment(rentcar_TD[9], 1);
	TextDrawColor(rentcar_TD[9], 255);
	TextDrawBackgroundColor(rentcar_TD[9], 255);
	TextDrawFont(rentcar_TD[9], 4);
	TextDrawSetProportional(rentcar_TD[9], 0);
	TextDrawSetShadow(rentcar_TD[9], 0);

	rentcar_TD[10] = TextDrawCreate(271.5176, 283.8832, "LD_SPAC:white"); // пусто
	TextDrawTextSize(rentcar_TD[10], 56.0699, 15.5299);
	TextDrawAlignment(rentcar_TD[10], 1);
	TextDrawColor(rentcar_TD[10], 8423167);
	TextDrawBackgroundColor(rentcar_TD[10], 255);
	TextDrawFont(rentcar_TD[10], 4);
	TextDrawSetProportional(rentcar_TD[10], 0);
	TextDrawSetShadow(rentcar_TD[10], 0);

	rentcar_TD[11] = TextDrawCreate(339.5218, 283.7832, "LD_SPAC:white"); // пусто
	TextDrawTextSize(rentcar_TD[11], 56.0000, 15.7599);
	TextDrawAlignment(rentcar_TD[11], 1);
	TextDrawColor(rentcar_TD[11], 8423167);
	TextDrawBackgroundColor(rentcar_TD[11], 255);
	TextDrawFont(rentcar_TD[11], 4);
	TextDrawSetProportional(rentcar_TD[11], 0);
	TextDrawSetShadow(rentcar_TD[11], 0);

	rentcar_TD[12] = TextDrawCreate(278.8941, 285.3835, "SELECT"); // пусто
	TextDrawLetterSize(rentcar_TD[12], 0.3519, 1.3999);
	TextDrawAlignment(rentcar_TD[12], 1);
	TextDrawColor(rentcar_TD[12], -1);
	TextDrawBackgroundColor(rentcar_TD[12], 255);
	TextDrawFont(rentcar_TD[12], 2);
	TextDrawSetProportional(rentcar_TD[12], 1);
	TextDrawSetShadow(rentcar_TD[12], 0);

	rentcar_TD[13] = TextDrawCreate(345.4982, 285.3835, "CANCEL"); // пусто
	TextDrawLetterSize(rentcar_TD[13], 0.3519, 1.3999);
	TextDrawAlignment(rentcar_TD[13], 1);
	TextDrawColor(rentcar_TD[13], -1);
	TextDrawBackgroundColor(rentcar_TD[13], 255);
	TextDrawFont(rentcar_TD[13], 2);
	TextDrawSetProportional(rentcar_TD[13], 1);
	TextDrawSetShadow(rentcar_TD[13], 0);

	rentcar_TD[14] = TextDrawCreate(299.8234, 146.8332, "LD_SPAC:white"); // пусто
	TextDrawTextSize(rentcar_TD[14], 63.0000, 79.0000);
	TextDrawAlignment(rentcar_TD[14], 1);
	TextDrawColor(rentcar_TD[14], 255);
	TextDrawBackgroundColor(rentcar_TD[14], 255);
	TextDrawFont(rentcar_TD[14], 4);
	TextDrawSetProportional(rentcar_TD[14], 0);
	TextDrawSetShadow(rentcar_TD[14], 0);

	rentcar_TD[15] = TextDrawCreate(301.7353, 148.6000, "LD_SPAC:white"); // пусто
	TextDrawTextSize(rentcar_TD[15], 59.5500, 75.7099);
	TextDrawAlignment(rentcar_TD[15], 1);
	TextDrawColor(rentcar_TD[15], 8423167);
	TextDrawBackgroundColor(rentcar_TD[15], 255);
	TextDrawFont(rentcar_TD[15], 4);
	TextDrawSetProportional(rentcar_TD[15], 0);
	TextDrawSetShadow(rentcar_TD[15], 0);

	rentcar_TD[16] = TextDrawCreate(295.2424, 131.5827, ""); // пусто
	TextDrawTextSize(rentcar_TD[16], 79.0000, 107.0000);
	TextDrawAlignment(rentcar_TD[16], 1);
	TextDrawColor(rentcar_TD[16], -1);
	TextDrawBackgroundColor(rentcar_TD[16], -12288);
	TextDrawFont(rentcar_TD[16], 5);
	TextDrawSetProportional(rentcar_TD[16], 0);
	TextDrawSetShadow(rentcar_TD[16], 0);
	TextDrawSetPreviewModel(rentcar_TD[16], 542);
	TextDrawSetPreviewRot(rentcar_TD[16], 0.0000, 0.0000, -45.0000, 1.0000);
	TextDrawSetPreviewVehCol(rentcar_TD[16], 3, 3);

	rentcar_TD[17] = TextDrawCreate(300.0409, 127.7833, "RENT_CAR"); // пусто
	TextDrawLetterSize(rentcar_TD[17], 0.4000, 1.6000);
	TextDrawAlignment(rentcar_TD[17], 1);
	TextDrawColor(rentcar_TD[17], -1);
	TextDrawBackgroundColor(rentcar_TD[17], 255);
	TextDrawFont(rentcar_TD[17], 2);
	TextDrawSetProportional(rentcar_TD[17], 1);
	TextDrawSetShadow(rentcar_TD[17], 0);

	rentcar_TD[18] = TextDrawCreate(291.5239, 229.2532, "Box"); // пусто
	TextDrawLetterSize(rentcar_TD[18], 0.0000, 1.9999);
	TextDrawTextSize(rentcar_TD[18], 371.0000, 0.0000);
	TextDrawAlignment(rentcar_TD[18], 1);
	TextDrawColor(rentcar_TD[18], -1);
	TextDrawUseBox(rentcar_TD[18], 1);
	TextDrawBoxColor(rentcar_TD[18], 255);
	TextDrawBackgroundColor(rentcar_TD[18], 32255);
	TextDrawFont(rentcar_TD[18], 1);
	TextDrawSetProportional(rentcar_TD[18], 1);
	TextDrawSetShadow(rentcar_TD[18], 0);

	rentcar_TD[19] = TextDrawCreate(331.1428, 230.9333, "CLOVER"); // пусто
	TextDrawLetterSize(rentcar_TD[19], 0.4000, 1.6000);
	TextDrawTextSize(rentcar_TD[19], 0.0000, 73.0000);
	TextDrawAlignment(rentcar_TD[19], 2);
	TextDrawColor(rentcar_TD[19], -1);
	TextDrawUseBox(rentcar_TD[19], 1);
	TextDrawBoxColor(rentcar_TD[19], 8423167);
	TextDrawSetOutline(rentcar_TD[19], 1);
	TextDrawBackgroundColor(rentcar_TD[19], 255);
	TextDrawFont(rentcar_TD[19], 2);
	TextDrawSetProportional(rentcar_TD[19], 1);
	TextDrawSetShadow(rentcar_TD[19], 0);

	rentcar_TD[20] = TextDrawCreate(317.2940, 259.4166, "$125"); // пусто
	TextDrawLetterSize(rentcar_TD[20], 0.4000, 1.6000);
	TextDrawAlignment(rentcar_TD[20], 1);
	TextDrawColor(rentcar_TD[20], -1061109505);
	TextDrawSetOutline(rentcar_TD[20], 1);
	TextDrawBackgroundColor(rentcar_TD[20], 255);
	TextDrawFont(rentcar_TD[20], 3);
	TextDrawSetProportional(rentcar_TD[20], 1);
	TextDrawSetShadow(rentcar_TD[20], 1);

	rentcar_TD[21] = TextDrawCreate(272.4762, 284.2933, "selectbox"); // пусто
	TextDrawLetterSize(rentcar_TD[21], 0.4000, 1.6000);
	TextDrawTextSize(rentcar_TD[21], 327.0000, 16.0000);
	TextDrawAlignment(rentcar_TD[21], 1);
	TextDrawColor(rentcar_TD[21], -256);
	TextDrawUseBox(rentcar_TD[21], 1);
	TextDrawBoxColor(rentcar_TD[21], 0);
	TextDrawBackgroundColor(rentcar_TD[21], 255);
	TextDrawFont(rentcar_TD[21], 1);
	TextDrawSetProportional(rentcar_TD[21], 1);
	TextDrawSetShadow(rentcar_TD[21], 0);
	TextDrawSetSelectable(rentcar_TD[21], true);

	rentcar_TD[22] = TextDrawCreate(341.0475, 284.7199, "cancelbox"); // пусто
	TextDrawLetterSize(rentcar_TD[22], 0.4000, 1.6000);
	TextDrawTextSize(rentcar_TD[22], 394.0000, 16.0000);
	TextDrawAlignment(rentcar_TD[22], 1);
	TextDrawColor(rentcar_TD[22], -256);
	TextDrawUseBox(rentcar_TD[22], 1);
	TextDrawBoxColor(rentcar_TD[22], 0);
	TextDrawBackgroundColor(rentcar_TD[22], 255);
	TextDrawFont(rentcar_TD[22], 1);
	TextDrawSetProportional(rentcar_TD[22], 1);
	TextDrawSetShadow(rentcar_TD[22], 0);
	TextDrawSetSelectable(rentcar_TD[22], true);
	return 1;
}

stock SendAdminMessage(color, text[])
{
	foreach(new i:Player)
	{
	    if(PlayerInfo[i][pAdmin] > 0 && AdminInfo[i][aLogged] == 1) SCM(i, color, text);
	}
	return 1;
}

stock SendSpecAdminMessage(color, text[])
{
	foreach(new i:Player)
	{
	    if(PlayerInfo[i][pAdmin] >= 8 && AdminInfo[i][aLogged] == 1) SCM(i, color, text);
	}
	return 1;
}

stock SendSupportMessage(color, message[])
{
	foreach(new i:Player)
	{
		if(PlayerInfo[i][pSupport] == 1 && GetPVarInt(i, "sDuty") == 1 || PlayerInfo[i][pAdmin] > 0 && GetPVarInt(i, "sDuty") == 1) SCM(i, color, message);
	}
	return 1;
}
//============================ [ Форварды ] ===============================
forward ConnectPlayerToServer(playerid);
public ConnectPlayerToServer(playerid)
{
	SCM(playerid, 0xA0DB40FF, "Добро пожаловать на Alliant Role Play!");
	SetPlayerColor(playerid, 0xFFFFFFFF);
	SetPlayerVirtualWorld(playerid, 125);
	SetPlayerInterior(playerid, 0);
	SetTimerEx("SetCameraIntro", 300, false, "i", playerid);
	Streamer_Update(playerid);
	for(new i = 0; i < 4; i++)
	{
		TextDrawShowForPlayer(playerid, LogoAlliant_TD[i]);
	}
	for(new i = 0; i <= TotalGZ; i++) GangZoneShowForPlayer(playerid, GZInfo[i][gZone], GetGangZoneColor(i));
	new query[128];
	format(query, sizeof(query), "SELECT `pID` FROM `users` WHERE `pName` = '%s'", PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query, "CheckAccountRegistration", "i", playerid);
}

forward ProxDetectorS(Float:radi, playerid, targetid);
public ProxDetectorS(Float:radi, playerid, targetid)
{
	if(IsPlayerConnected(playerid)&&IsPlayerConnected(targetid))
	{
		new Float:posx, Float:posy, Float:posz;
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		GetPlayerPos(targetid, posx, posy, posz);
		tempposx = (oldposx -posx);
		tempposy = (oldposy -posy);
		tempposz = (oldposz -posz);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
		{
			return true;
		}
	}
	return false;
}

forward CheckSupport(playerid);
public CheckSupport(playerid)
{
	new rows, query[128];
	cache_get_row_count(rows);
	if(rows)
	{
		if(GetPVarInt(playerid, "sDuty") == 0)
		{
			cache_get_value_name_int(0, "sID", SupportInfo[playerid][sID]);
			cache_get_value_name(0, "sName", SupportInfo[playerid][sName]);
			cache_get_value_name_int(0, "sAnswer", SupportInfo[playerid][sAnswer]);
			SCM(playerid, 0x2A8D9CFF, "<< SUPPORT >> Вы начали рабочий день саппорта!");
			SetPVarInt(playerid, "sDuty", 1);
		}
		else
		{
			SCM(playerid, 0x2A8D9CFF, "<< SUPPORT >> Вы завершили рабочий день саппорта!");
			SetPVarInt(playerid, "sDuty", 0);
		}
	}
	else
	{
		format(query, sizeof(query), "INSERT INTO `supports` (`sName`) VALUES ('%s')", PlayerInfo[playerid][pName]);
		mysql_tquery(dbHandle, query);
		format(query, sizeof(query), "SELECT * FROM `supports` WHERE `sName` = '%s'", PlayerInfo[playerid][pName]);
		mysql_tquery(dbHandle, query);
	}
}

forward SpecPlayers(playerid);
public SpecPlayers(playerid)
{
	StartSpectate(playerid, SpecAd[playerid]);
}

forward PlayerOnGangZone(playerid, Float:min_x, Float:min_y, Float:max_x, Float:max_y);
public PlayerOnGangZone(playerid, Float:min_x, Float:min_y, Float:max_x, Float:max_y)
{
	new Float:fX, Float:fY, Float:fZ;
	GetPlayerPos(playerid, fX, fY, fZ);
	if((fX <= max_x && fX >= min_x) && (fY <= max_y && fY >= min_y)) return true;
	return false;
}

forward PickObjectLoader(playerid);
public PickObjectLoader(playerid)
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	if(GetPVarInt(playerid, "LoaderInvite") == 1)
	{
		switch(PlayerInfo[playerid][pGender])
		{
			case 1:
			{
				switch(random(6))
				{
					case 0: SetPlayerAttachedObject(playerid, 5, 2912, 1, -0.060686, 0.655520, -0.038872, 99.500968, 90.024620, 78.623825, 1.025472, 1.000000, 1.000000);
					case 1: SetPlayerAttachedObject(playerid, 5, 918, 1, 0.189312, 0.464522, 0.046128, -176.799179, 174.824798, -7.976276, 1.025472, 1.000000, 1.000000);
					case 2: SetPlayerAttachedObject(playerid, 5, 1218, 1, 0.270312, 0.569521, 0.012128, 176.400817, 178.824768, -22.876199, 1.025472, 1.000000, 1.000000);
					case 3: SetPlayerAttachedObject(playerid, 5, 2060, 1, 0.076312, 0.437522, 0.033127, 108.700759, 77.424743, -101.376228, 1.025472, 1.000000, 1.000000);
					case 4: SetPlayerAttachedObject(playerid, 5, 3052, 1, 0.048312, 0.487520, -0.006871, 89.600822, 87.624694, 86.923797, 1.025472, 1.000000, 1.000000);
					case 5: SetPlayerAttachedObject(playerid, 5, 2478, 1, 0.248312, 0.403521, -0.003872, 43.400814, 95.724685, -42.676258, 1.025472, 1.000000, 1.000000);
				}
			}
			case 2:
			{
				switch(random(4))
				{
					case 0: SetPlayerAttachedObject(playerid, 5, 1230, 1, 0.241313, 0.493520, -0.024872, -20.299156, 95.324607, -166.176147, 0.714471, 0.723999, 0.691999);
					case 1: SetPlayerAttachedObject(playerid, 5, 2900, 1, -0.044687, 0.788520, -0.017872, 89.600822, 87.624694, 86.923797, 1.025472, 1.000000, 1.000000);
					case 2: SetPlayerAttachedObject(playerid, 5, 2654, 1, 0.159312, 0.455521, -0.076872, 144.500854, 82.624687, -52.576278, 1.025472, 1.000000, 1.000000);
					case 3: SetPlayerAttachedObject(playerid, 5, 2478, 1, 0.248312, 0.403521, -0.003872, 43.400814, 95.724685, -42.676258, 1.025472, 1.000000, 1.000000);
				}
			}
		}
	}
}



forward pTazer(playerid);
public pTazer(playerid)
{
	TogglePlayerControllable(playerid, 1);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	ClearAnimations(playerid);
	SetPVarInt(playerid, "OnTazer" , 0);
	return 1;
}

forward speed_timer(playerid);
public speed_timer(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return false; // Проверка на то, сидит ли игрок за рулём
    new veh_id = GetPlayerVehicleID(playerid); // Получаем ID авто, в котором находится игрок
    if(GetVehicleModel(veh_id) != 522) return true; // Если модель из массива и модель авто, где сидит игрок не совпадают, то пропускаем
    new now_speed = GetVehicleSpeed(veh_id); // Получаем скорость игрока на данный момент
    if(now_speed<100) return true;
    new Float:mltupline = 1.3; // Значение, в которое будем увеличивать скорость автомобиля
    if(now_speed*mltupline >= 200) return true; // Проверка, на то, превысим ли мы уловно максимальную скорость или нет
    SetVehicleSpeed(veh_id, now_speed*mltupline); // Устанавливаем новую скорость автомобилю
    return true;
}

forward SetCameraIntro(playerid);
public SetCameraIntro(playerid)
{
	InterpolateCameraPos(playerid, 2133.793212, -94.768066, 1.255280, 2133.793212, -94.768066, 1.255280, 1000);
	InterpolateCameraLookAt(playerid, 2135.047607, -101.182060, 2.095280, 2135.047607, -101.182060, 2.095280, 1000);
	SetTimerEx("SetAnimationActorIntro", 300, false, "i", playerid);
	return 1;
}

forward SetAnimationActorIntro(playerid);
public SetAnimationActorIntro(playerid)
{
	ApplyActorAnimation(actorintro, "BEACH", "PARKSIT_M_LOOP", 4.0, 1, 0, 0, 0, 0); // Задаем актёру на интро анимацию
	return 1;
}

forward IsVehicleOccupied(vehicleid);
public IsVehicleOccupied(vehicleid)
{
	foreach(new i: Player)
	{
		if(IsPlayerInVehicle(i, vehicleid)) return 1;
	}
	return 0;
}

forward SetPlayerAdmin(playerid);
public SetPlayerAdmin(playerid)
{
	new rows, query[128], string[256];
	new AdminLevel = GetPVarInt(playerid, "SetAdminLevel");
	new AdminID = GetPVarInt(playerid, "SetAdminID");
	cache_get_row_count(rows);
	if(rows)
	{
		PlayerInfo[AdminID][pAdmin] = AdminLevel;
		format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] администратором %d-го уровня!", PlayerInfo[AdminID][pName], PlayerInfo[AdminID][pAdmin]);
		SCM(playerid, COLOR_INFO, string);
		format(string, sizeof(string), "[Информация] {FF69B4}Вы были назначены на пост администратора %d-го уровня", PlayerInfo[AdminID][pAdmin]);
		SCM(AdminID, COLOR_INFO, string);
		format(query, sizeof(query), "UPDATE `accounts` SET `pAdmin` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[AdminID][pAdmin], PlayerInfo[AdminID][pID]);
		mysql_tquery(dbHandle, query);
	}
	else
	{
		PlayerInfo[AdminID][pAdmin] = AdminLevel;
		format(string, sizeof(string), "[Информация] {FF69B4}Вы назначили игрока {FFFFFF}%s[%d] администратором %d-го уровня!", PlayerInfo[AdminID][pName], PlayerInfo[AdminID][pAdmin]);
		SCM(playerid, COLOR_INFO, string);
		format(string, sizeof(string), "[Информация] {FF69B4}Вы были назначены на пост администратора %d-го уровня", PlayerInfo[AdminID][pAdmin]);
		SCM(AdminID, COLOR_INFO, string);
		SCM(AdminID, COLOR_INFO, "[Информация] {FF69B4}Используйте {B90000}/alogin {FF69B4}для авторизации в админ-панели.");
		format(query, sizeof(query), "UPDATE `accounts` SET `pAdmin` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[AdminID][pAdmin], PlayerInfo[AdminID][pID]);
		mysql_tquery(dbHandle, query);
	}
	return 1;
}

forward CheckAccountName(playerid, inputtext);
public CheckAccountName(playerid, inputtext)
{
	new rows, string[128];
	cache_get_row_count(rows);
	if(rows) 
	{
		SPD(playerid, DLG_RED_NAME, DSI, "{FFFFFF}Mеню персонажа {4DB8E6}|| Смена имени", "{FFFFFF}Введите ваше новое имя.\nАдминистрация меняет только nonRP ники.", "Далее", "Отмена");	
		return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Данный ник уже занят."); 
	}
	else 
	{
		SetPVarInt(playerid, "RedName", 1);
		GetPVarString(playerid, "RedName_String", RedName_String, sizeof(RedName_String));
		format(string, sizeof(string), "[A] Игрок %s[%i] оставил заявку на смену ника -> %s {FFFFFF}(/setname id)", PlayerInfo[playerid][pName], playerid, RedName_String);
		SendAdminMessage(COLOR_YELLOW, string);
		format(string, sizeof(string), "[Информация] {FF69B4}Вы оставили заявку на смену ника. %s - > %s. Ожидайте подтверждения от администрации.", PlayerInfo[playerid][pName], RedName_String);
		return SCM(playerid, COLOR_INFO, string);
	}
}

forward CheckAccountRegistration(playerid);
public CheckAccountRegistration(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows) ShowLogin(playerid);
	else ShowRegister(playerid);
}

forward InviteAcceptTimer(playerid);
public InviteAcceptTimer(playerid)
{
	if(playerid == GetPVarInt(playerid, "InviteID"))
	{
		if(GetPVarInt(playerid, "InviteAccept") == 1)
		{
			SetPVarInt(playerid, "InviteAccept", 0);
		}
	}
	return 1;
}

forward PayDay();
public PayDay()
{
	new hour, minute, second, EXPAmount;
	new query[128];
	gettime(hour, minute, second);
	SetWorldTime(hour);
	foreach(new i:Player)
	{
		if(GetPVarInt(i, "pLogged") == 1)
		{
			new nextlevel = PlayerInfo[i][pLevel] + 1;
			new string[256], balance[128];
			EXPAmount = exptonextlevel * nextlevel;
			if(PlayerInfo[i][pWanted] > 0)
			{
				PlayerInfo[i][pWanted] -= 1;
				SetPlayerWantedLevel(i, PlayerInfo[i][pWanted]);
				format(query, sizeof(query), "UPDATE `users` SET `pWanted` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[i][pWanted], PlayerInfo[i][pID]);
				mysql_tquery(dbHandle, query);
				if(PlayerInfo[i][pWanted] == 0) SCM(i, COLOR_WHITE, "Ваша узнаваемость понизилась.");
			}
			if(PlayerAFK[i] > 5)
			{
				if(minute < 10)
				{
					format(string, sizeof(string), "{FFFFFF}Текущее время: %d:0%d", hour, minute);
				}
				else
				{
					format(string, sizeof(string), "{FFFFFF}Текущее время: %d:%d", hour, minute);
				}
				SCM(i, 0xDFCB40AA, "================ [ Alliant State Bank ] ================");
				SCM(i, 0x67BA43AA, "Счёт за телефон: 20 вирт");
				SCM(i, 0x67BA43AA, "Казна государства: 0 вирт");
				SCM(i, 0xFFFFFFAA, "");
				SCM(i, 0xFFFFFFAA, "Для получения зарплаты Вы не должны находиться на паузе!");
				SCM(i, 0xDFCB40AA, "=================================================");
				return 1;
			}
			if(PlayerInfo[i][pTime] < 20)
			{
				if(minute < 10)
				{
					format(string, sizeof(string), "{FFFFFF}Текущее время: %d:0%d", hour, minute);
				}
				else
				{
					format(string, sizeof(string), "{FFFFFF}Текущее время: %d:%d", hour, minute);
				}
				SCM(i, 0xDFCB40AA, "================ [ Alliant State Bank ] ================");
				SCM(i, 0x67BA43AA, "Счёт за телефон: 20 вирт");
				SCM(i, 0x67BA43AA, "Казна государства: 0 вирт");
				SCM(i, 0xFFFFFFAA, "");
				SCM(i, 0xFFFFFFAA, "Для получения зарплаты Вы должны отыграть более 20-ти минут");
				SCM(i, 0xDFCB40AA, "=================================================");
			}
			else
			{
				PlayerInfo[i][pExp]++;
				format(query, sizeof(query), "UPDATE `users` SET `pExp` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[i][pExp], PlayerInfo[i][pID]);
				mysql_tquery(dbHandle, query);
				format(string, sizeof(string), "{FFFFFF}Текущее время: %d:%d", hour, minute); 
				SCM(i, 0xDFCB40AA, "================ [ Alliant State Bank ] ================");
				SCM(i, 0x67BA43AA, "Счёт за телефон: 20 вирт");
				SCM(i, 0x67BA43AA, "Казна государства: 0 вирт");
				SCM(i, 0xFFFFFFAA, "");
				SCM(i, 0xFFFFFFAA, "Зарплата: 0 вирт");
				format(balance, sizeof(balance), "Текущий баланс: %d вирт", PlayerInfo[i][pBankMoney]);
				SCM(i, 0xFFFFFFAA, balance);
				SCM(i, 0xDFCB40AA, "=================================================");
			}
			new nowexp = PlayerInfo[i][pExp];
			if(nowexp >= EXPAmount)
			{
				PlayerInfo[i][pLevel]++;
				if(GetPlayerScore(i) != PlayerInfo[i][pLevel])
				{
					SetPlayerScore(i, PlayerInfo[i][pLevel]);
				} 
				PlayerInfo[i][pExp] = 0;
				SCM(i, COLOR_WHITE, "Ваш уровень повысился");
				format(query, sizeof(query), "UPDATE `users` SET `pLevel` = '%d', `pExp` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[i][pLevel], PlayerInfo[i][pExp], PlayerInfo[i][pID]);
				mysql_tquery(dbHandle, query);
			}
			PlayerInfo[i][pTime] = 0;
		}
	}
	format(query, sizeof(query), "UPDATE `users` SET `pTime` = '0'");
	mysql_tquery(dbHandle, query);
	return 1;
}

forward TimeMute(playerid);
public TimeMute(playerid)
{
	if(PlayerInfo[playerid][pMute] == 0)
	{
		SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Время блокировки чата истекло. Вы снова можете писать в чат!");
		KillTimer(PlayerMute[playerid]);
		new query[128];
		format(query, sizeof(query), "UPDATE `users` SET `pMute` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[playerid][pMute], PlayerInfo[playerid][pID]);
		mysql_tquery(dbHandle, query);
	}
	if(PlayerInfo[playerid][pMute] != 0)
	{
		PlayerInfo[playerid][pMute]--;
		PlayerMute[playerid] = SetTimerEx("TimeMute", 1000, false, "i", playerid);
	}
}

forward EscortedTimer(playerid);
public EscortedTimer(playerid)
{
	if(!IsPlayerConnected(GetPVarInt(playerid, "OnEscort")))
	{
		KillTimer(FollowTimer[playerid]);
		FollowTimer[playerid] = INVALID_PLAYER_ID;
		SetPVarInt(playerid, "OnEscort", -1);
		TogglePlayerControllable(playerid, 1);
		ClearAnimations(playerid);
		return 1;
	}
	else if(!IsPlayerConnected(playerid))
	{
		SetPVarInt(GetPVarInt(playerid, "OnEscort"), "Escorted", -1);
		KillTimer(FollowTimer[playerid]);
		FollowTimer[playerid] = INVALID_PLAYER_ID;
		SetPVarInt(playerid, "OnEscort", -1);
		return 1;
	}
	else if(GetPlayerVirtualWorld(GetPVarInt(playerid, "OnEscort")) != GetPlayerVirtualWorld(playerid) || GetPlayerInterior(GetPVarInt(playerid, "OnEscort")) != GetPlayerInterior(playerid))
	{
		new Float: X, Float: Y, Float: Z;
		GetPlayerPos(GetPVarInt(playerid, "OnEscort"), X, Y, Z);
		SetPlayerPos(playerid, X, Y, Z);
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(GetPVarInt(playerid, "OnEscort")));
		SetPlayerInterior(playerid, GetPlayerInterior(GetPVarInt(playerid, "OnEscort")));
		TogglePlayerControllable(playerid, 0);
		return 1;
	}
	new Float: GotDistance = GetDistanceBetweenPlayers(playerid, GetPVarInt(playerid, "OnEscort"));
	if(GotDistance < 1.0)
	{
		TogglePlayerControllable(playerid, 0);
		SetPlayerToFacePlayer(playerid, GetPVarInt(playerid, "OnEscort"));
		return 1;
	}
	else if(GotDistance > 3.5)
	{
		TogglePlayerControllable(playerid, 1);
		SetPlayerToFacePlayer(playerid, GetPVarInt(playerid, "OnEscort"));
		ApplyAnimation(playerid, "PED", "SPRINT_PANIC", 6.0, 1, 1, 1, 1, 0, 1);
		return 1;
	}
	else
	{
		TogglePlayerControllable(playerid, 1);
		SetPlayerToFacePlayer(playerid, GetPVarInt(playerid, "OnEscort"));
		ApplyAnimation(playerid, "ped", "WALK_civi", 6.0, 1, 1, 1, 1, 0, 1);
	}
	return 1;
}

forward ThirtySecondUpdate();
public ThirtySecondUpdate()
{

}

forward Float:GetDistanceBetweenPlayers(p1,p2);
public Float:GetDistanceBetweenPlayers(p1,p2)
{
	new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
	if(!IsPlayerConnected(p1) || !IsPlayerConnected(p2))
	{
		return -1.00;
	}
	GetPlayerPos(p1,x1,y1,z1);
	GetPlayerPos(p2,x2,y2,z2);
	return floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
}

forward SecondUpdate();
public SecondUpdate()
{
	new string[128], query[128];
	foreach(new i:Player)
	{
		if(PlayerAFK[i] == 0) PlayerAFK[i] = -1;
		else if(PlayerAFK[i] == -1)
		{
		    PlayerAFK[i] = 1;
		}
		else if(PlayerAFK[i] > 0)
		{
			PlayerAFK[i]++;
			if(PlayerAFK[i] > 4)
			{
				if(PlayerAFK[i] >= 360) return SetPlayerChatBubble(i, "AFK: 360+ сек.", 0xFF0000FF, 20, 1000);
				format(string, sizeof(string), "{FF0000}AFK: %d cек.", PlayerAFK[i]);
				SetPlayerChatBubble(i, string, 0xFF0000FF, 20, 1000);
			}
		}
		if(PlayerInfo[i][pTimeWanted] > 0)
		{
			if(PlayerInfo[i][pTimeWanted] > 1) PlayerInfo[i][pTimeWanted]--;
			if(PlayerInfo[i][pTimeWanted] == 1)
			{
				PlayerInfo[i][pTimeWanted] = 0;
				SetPlayerPos(i, 1543.8656,-1675.3438,13.5573);
				SetPlayerFacingAngle(i, 88.6170);
				SetPlayerInterior(i, 0);
				SetPlayerVirtualWorld(i, 0);
				SCM(i, COLOR_INFO, "[Информация] {FF69B4}Вы заплатили свой долг обществу. Теперь вы свободны.");
				format(query, sizeof(query), "UPDATE `users` SET `pTimeWanted` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[i][pTimeWanted], PlayerInfo[i][pID]);
				mysql_tquery(dbHandle, query);
				SetPlayerWantedLevel(i, 0);
			}
		}
		
	}
	return 1;
}

forward MinuteUpdate();
public MinuteUpdate()
{
	foreach(new i:Player)
	{
		if(GetPVarInt(i, "pLogged") == 1)
		{
			new query[128];
			PlayerInfo[i][pTime]++;
			format(query, sizeof(query), "UPDATE `users` SET `pTime` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[i][pTime], PlayerInfo[i][pID]);
			mysql_tquery(dbHandle, query);
			if(GetPlayerScore(i) != PlayerInfo[i][pLevel])
			{
				SetPlayerScore(i, PlayerInfo[i][pLevel]);
			} 
		}
	}
	new hour, minute, second;
	gettime(hour, minute, second);
	if(minute == 0)
	{
		PayDay();
	}
	if(minute == 46 && morder == 0)
	{
		gettime(hour, minute);
		time_call = (hour * 3600) + (minute * 60);
		submarine = CreateObject(9958, 2318.906494, -2880.927734, -11.957567, 0.000000, 0.000000, 130.800125);
		submarinestat = 1;
		MoveObject(submarine, 2751.048583, -2586.376220, 5.262427+0.0001, 50.0, 0.000000, 0.000000, -270.000000);
		foreach(new i: Player)
		{ 
			if(PlayerInfo[i][pFraction] == 3 && GetPVarInt(i, "DutyStart") == 1) 
			{
				SCM(i, COLOR_INFO, "[Информация] {FF69B4}В порт Лос-Сантоса скоро прибудет грузовая подлодка. Подготовьтесь.");
			}
		}
	}
	if(minute == 48 && morder == 0)
	{
		DestroyDynamicPickup(loadzone);
		Delete3DTextLabel(loadzone3dtext);
		MoveObject(submarine, 3252.048583, -2586.376220, -14.737571, 50.0);
	}
	if(minute == SOStime + 1 && morder == 1)
	{
		gettime(hour, minute);
		time_call = (hour * 3600) + (minute * 60);
		DestroyDynamicPickup(loadzone);
		morder = 0;
		Delete3DTextLabel(loadzone3dtext);
		MoveObject(submarine, 3252.048583, -2586.376220, -14.737571, 50.0);
	}
}

forward HealthTimer(playerid);
public HealthTimer(playerid)
{
	SetPVarInt(playerid, "HealthHome", 0);
	return 1;
}

forward CheckLeader(playerid);
public CheckLeader(playerid)
{
	new rows, query[128];
	new LeaderID = GetPVarInt(playerid, "LeaderID");
	cache_get_row_count(rows);
	if(rows)
	{
		format(query, sizeof(query), "UPDATE `fractions` SET `fLeader` = '' WHERE `fLeader` = '%s'", PlayerInfo[LeaderID][pName]);
		mysql_tquery(dbHandle, query);
	}
}

forward ChatAnimation(playerid);
public ChatAnimation(playerid)
{
	ApplyAnimation(playerid, "PED", "facanger", 4.1, 0, 1, 1, 1, 1);
	return 1;
}

forward LoadWorks(playerid);
public LoadWorks(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(!rows) return print("[WORKS]: Данные из таблицы не получены!");
	for(new i = 0; i < rows; i++)
	{
		cache_get_value_name_int(i, "wID", WorkInfo[i][wID]);
		cache_get_value_name(i, "wName", WorkInfo[i][wName], 64);
		cache_get_value_name_int(i, "wSalary", WorkInfo[i][wSalary]);
		cache_get_value_name_int(i, "wSalary2", WorkInfo[i][wSalary2]);
		cache_get_value_name_int(i, "wSalary3", WorkInfo[i][wSalary3]);
		cache_get_value_name(i, "wLastChange", WorkInfo[i][wLastChange], 16);
	}
	printf("[WORKS]: Получены данные из таблицы для %d работ.", rows);
	return 1;
}

forward LoadGangZones(playerid);
public LoadGangZones(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(!rows) return print("[GANGZONES]: Данные из таблицы не получены!");
	for(new i = 0; i < rows; i++)
	{
		cache_get_value_name_int(i, "gID", GZInfo[i][gID]);
		cache_get_value_name_float(i, "gCoord_One", GZInfo[i][gCoords][0]);
		cache_get_value_name_float(i, "gCoord_Two", GZInfo[i][gCoords][1]);
		cache_get_value_name_float(i, "gCoord_Three", GZInfo[i][gCoords][2]);
		cache_get_value_name_float(i, "gCoord_Four", GZInfo[i][gCoords][3]);
		cache_get_value_name_int(i, "gOwner", GZInfo[i][gOwner]);
		GZInfo[i][gZone] = GangZoneCreate(GZInfo[i][gCoords][0], GZInfo[i][gCoords][1], GZInfo[i][gCoords][2], GZInfo[i][gCoords][3]);
		TotalGZ++;
	}
	printf("[GANGZONES]: Данные из таблицы получены! Загружено - %d гангзон.", TotalGZ);
	return 1;
}

forward LoadHouses(playerid);
public LoadHouses(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(!rows) return print("[HOUSES]: Данные из таблицы не получены!");
	for(new i = 0; i < rows; i++)
	{
		cache_get_value_name_int(i, "hID", HouseInfo[i][hID]);
		cache_get_value_name_int(i, "hOwned", HouseInfo[i][hOwned]);
		cache_get_value_name(i, "hOwner", HouseInfo[i][hOwner], 24);
		cache_get_value_name_int(i, "hCost", HouseInfo[i][hCost]);
		cache_get_value_name(i, "hType", HouseInfo[i][hType], 24);
		cache_get_value_name_int(i, "hClass", HouseInfo[i][hClass]);
		cache_get_value_name_int(i, "hRoomAmount", HouseInfo[i][hRoomAmount]);
		cache_get_value_name_int(i, "hRent", HouseInfo[i][hRent]);
		cache_get_value_name_float(i, "hEnterX", HouseInfo[i][hEnterX]);
		cache_get_value_name_float(i, "hEnterY", HouseInfo[i][hEnterY]);
		cache_get_value_name_float(i, "hEnterZ", HouseInfo[i][hEnterZ]);
		cache_get_value_name_int(i, "hInterior", HouseInfo[i][hInterior]);
		cache_get_value_name_float(i, "hiEnterX", HouseInfo[i][hiEnterX]);
		cache_get_value_name_float(i, "hiEnterY", HouseInfo[i][hiEnterY]);
		cache_get_value_name_float(i, "hiEnterZ", HouseInfo[i][hiEnterZ]);
		cache_get_value_name_float(i, "hiEnterAngle", HouseInfo[i][hiEnterAngle]);
		cache_get_value_name_float(i, "hExitX", HouseInfo[i][hExitX]);
		cache_get_value_name_float(i, "hExitY", HouseInfo[i][hExitY]);
		cache_get_value_name_float(i, "hExitZ", HouseInfo[i][hExitZ]);
		cache_get_value_name_float(i, "hExitAngle", HouseInfo[i][hExitAngle]);
		cache_get_value_name_int(i, "hLocked", HouseInfo[i][hLocked]);
		cache_get_value_name_int(i, "hGarage", HouseInfo[i][hGarage]);
		cache_get_value_name(i, "hPay", HouseInfo[i][hPay], 16);
		cache_get_value_name_int(i, "hMedKit", HouseInfo[i][hMedKit]);
		cache_get_value_name_float(i, "hWardrobeX", HouseInfo[i][hWardrobeX]);
		cache_get_value_name_float(i, "hWardrobeY", HouseInfo[i][hWardrobeY]);
		cache_get_value_name_float(i, "hWardrobeZ", HouseInfo[i][hWardrobeZ]);
		cache_get_value_name_int(i, "hStoreMaterials", HouseInfo[i][hStoreMaterials]);
		cache_get_value_name_int(i, "hStoreDrugs", HouseInfo[i][hStoreDrugs]);
		cache_get_value_name_float(i, "hCarPosX", HouseInfo[i][hCarPosX]);
		cache_get_value_name_float(i, "hCarPosY", HouseInfo[i][hCarPosY]);
		cache_get_value_name_float(i, "hCarPosZ", HouseInfo[i][hCarPosZ]);
		cache_get_value_name_float(i, "hCarAngle", HouseInfo[i][hCarAngle]);
		HousePickupAndIcon(i); // Создание пикапов и иконок
		TotalHouses++;
	}
	printf("[HOUSES]: Данные из таблицы получены! Загружено - %d домов", TotalHouses);
	return 1;
}

forward LoadFractions();
public LoadFractions()
{
	new rows;
	cache_get_row_count(rows);
	if(!rows) return print("[FRACTIONS]: Данные из таблицы не получены!");
	for(new i; i < rows; i++)
	{
		cache_get_value_name_int(i, "fID", FracInfo[i][fID]);
		cache_get_value_name(i, "fName", FracInfo[i][fName], 50);
		cache_get_value_name(i, "fLeader", FracInfo[i][fLeader], MAX_PLAYER_NAME);
		cache_get_value_name_int(i, "fBank", FracInfo[i][fBank]);
		cache_get_value_name_int(i, "fMaterials", FracInfo[i][fMaterials]);
		cache_get_value_name_int(i, "fInvRang", FracInfo[i][fInvRang]);
		cache_get_value_name_int(i, "fSkin1", FracInfo[i][fSkin1]);
		cache_get_value_name_int(i, "fSkin2", FracInfo[i][fSkin2]);
		cache_get_value_name_int(i, "fSkin3", FracInfo[i][fSkin3]);
		cache_get_value_name_int(i, "fSkin4", FracInfo[i][fSkin4]);
		cache_get_value_name_int(i, "fSkin5", FracInfo[i][fSkin5]);
		cache_get_value_name_int(i, "fSkin6", FracInfo[i][fSkin6]);
		cache_get_value_name_int(i, "fSkin7", FracInfo[i][fSkin7]);
		cache_get_value_name_int(i, "fSkin8", FracInfo[i][fSkin8]);
		cache_get_value_name_int(i, "fSkin9", FracInfo[i][fSkin9]);
		cache_get_value_name_int(i, "fSkinRank1", FracInfo[i][fSkinRank1]);
		cache_get_value_name_int(i, "fSkinRank2", FracInfo[i][fSkinRank2]);
		cache_get_value_name_int(i, "fSkinRank3", FracInfo[i][fSkinRank3]);
		cache_get_value_name_int(i, "fSkinRank4", FracInfo[i][fSkinRank4]);
		cache_get_value_name_int(i, "fSkinRank5", FracInfo[i][fSkinRank5]);
		cache_get_value_name_int(i, "fSkinRank6", FracInfo[i][fSkinRank6]);
		cache_get_value_name_int(i, "fSkinRank7", FracInfo[i][fSkinRank7]);
		cache_get_value_name_int(i, "fSkinRank8", FracInfo[i][fSkinRank8]);
		cache_get_value_name_int(i, "fSkinRank9", FracInfo[i][fSkinRank9]);
		cache_get_value_name(i, "fRang1", FracInfo[i][fRang1], 32);
        cache_get_value_name(i, "fRang2", FracInfo[i][fRang2], 32);
        cache_get_value_name(i, "fRang3", FracInfo[i][fRang3], 32);
        cache_get_value_name(i, "fRang4", FracInfo[i][fRang4], 32);
        cache_get_value_name(i, "fRang5", FracInfo[i][fRang5], 32);
        cache_get_value_name(i, "fRang6", FracInfo[i][fRang6], 32);
        cache_get_value_name(i, "fRang7", FracInfo[i][fRang7], 32);
        cache_get_value_name(i, "fRang8", FracInfo[i][fRang8], 32);
        cache_get_value_name(i, "fRang9", FracInfo[i][fRang9], 32);
        cache_get_value_name(i, "fRang10", FracInfo[i][fRang10], 32);
        cache_get_value_name(i, "fRang11", FracInfo[i][fRang11], 32);
        cache_get_value_name(i, "fRang12", FracInfo[i][fRang12], 32);
        cache_get_value_name(i, "fRang13", FracInfo[i][fRang13], 32);
        cache_get_value_name(i, "fRang14", FracInfo[i][fRang14], 32);
        cache_get_value_name(i, "fRang15", FracInfo[i][fRang15], 32);
	}
	printf("[FRACTIONS]: Данные из таблицы получены! Загружено - %d фракций", rows);
	return 1;
}

forward CheckReferal(playerid, referal);
public CheckReferal(playerid, referal)
{
	new rows;
	cache_get_row_count(rows);
	if(rows)
	{
		ShowRules(playerid);
	}
	else
	{
		SPD(playerid, DLG_REGREFERAL, DSI, "{FFFFFF}Регистрация {F385D5}|| Ник пригласившего игрока [3/5]", "{FFFFFF}Если Вы узнали о нашем сервере от своего друга\nто введите его ник в поле ниже и нажмите \"Далее\"\n\n{1295CD}При достижении вами 4-го уровня он получит вознаграждение!", "Далее", "Пропустить");
		return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Указанный Вами игрок не найден!");
	}
	return 1;
}

forward LoadAccount(playerid);
public LoadAccount(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows)
	{
		cache_get_value_name_int(0, "pID", PlayerInfo[playerid][pID]);
		cache_get_value_name(0, "pName", PlayerInfo[playerid][pName], MAX_PLAYER_NAME);
		cache_get_value_name(0, "pEmail", PlayerInfo[playerid][pEmail], 64);
		cache_get_value_name_int(0, "pAdmin", PlayerInfo[playerid][pAdmin]);
		cache_get_value_name_int(0, "pSupport", PlayerInfo[playerid][pSupport]);
		cache_get_value_name(0, "pReferal", PlayerInfo[playerid][pReferal], MAX_PLAYER_NAME);
		cache_get_value_name_int(0, "pGender", PlayerInfo[playerid][pGender]);
		cache_get_value_name_int(0, "pLevel", PlayerInfo[playerid][pLevel]);
		cache_get_value_name_int(0, "pExp", PlayerInfo[playerid][pExp]);
		cache_get_value_name_int(0, "pTime", PlayerInfo[playerid][pTime]);
		cache_get_value_name_int(0, "pSkin", PlayerInfo[playerid][pSkin]);
		cache_get_value_name(0, "pRegData", PlayerInfo[playerid][pRegData], 16);
		cache_get_value_name(0, "pRegIP", PlayerInfo[playerid][pRegIP], 16);
		cache_get_value_name_int(0, "pMoney", PlayerInfo[playerid][pMoney]);
		cache_get_value_name_int(0, "pBankMoney", PlayerInfo[playerid][pBankMoney]);
		cache_get_value_name_int(0, "pFraction", PlayerInfo[playerid][pFraction]);
		cache_get_value_name_int(0, "pRank", PlayerInfo[playerid][pRank]);
		cache_get_value_name_int(0, "pFractionSkin", PlayerInfo[playerid][pFractionSkin]);
		cache_get_value_name_int(0, "pCarLic", PlayerInfo[playerid][pCarLic]);
		cache_get_value_name_int(0, "pBikeLic", PlayerInfo[playerid][pBikeLic]);
		cache_get_value_name_int(0, "pAirLic", PlayerInfo[playerid][pAirLic]);
		cache_get_value_name_int(0, "pBoatLic", PlayerInfo[playerid][pBoatLic]);
		cache_get_value_name_int(0, "pFishLic", PlayerInfo[playerid][pFishLic]);
		cache_get_value_name_int(0, "pBizLic", PlayerInfo[playerid][pBizLic]);
		cache_get_value_name_int(0, "pGunLic", PlayerInfo[playerid][pGunLic]);
		cache_get_value_name_float(0, "pHP", PlayerInfo[playerid][pHP]);
		cache_get_value_name_int(0, "pDrugs", PlayerInfo[playerid][pDrugs]);
		cache_get_value_name_int(0, "pMaterials", PlayerInfo[playerid][pMaterials]);
		cache_get_value_name_int(0, "pHouse", PlayerInfo[playerid][pHouse]);
		cache_get_value_name_int(0, "pSpawn", PlayerInfo[playerid][pSpawn]);
		cache_get_value_name_int(0, "pCarModel", PlayerInfo[playerid][pCarModel]);
		cache_get_value_name_int(0, "pCarColor1", PlayerInfo[playerid][pCarColor1]);
		cache_get_value_name_int(0, "pCarColor2", PlayerInfo[playerid][pCarColor2]);
		cache_get_value_name_int(0, "pMute", PlayerInfo[playerid][pMute]);
		cache_get_value_name_int(0, "pWarn", PlayerInfo[playerid][pWarn]);
		cache_get_value_name_int(0, "pWanted", PlayerInfo[playerid][pWanted]);
		cache_get_value_name_int(0, "pTimeWanted", PlayerInfo[playerid][pTimeWanted]);
		cache_get_value_name_int(0, "pCopKey", PlayerInfo[playerid][pCopKey]);
		SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		if(PlayerInfo[playerid][pSkin] != 0)
		{
			SetPVarInt(playerid, "pLogged", 1);
			SetPlayerColor(playerid, 0xFFFFFF00);
			SpawnPlayer(playerid);
		}
		if(PlayerInfo[playerid][pSkin] == 0 && GetPVarInt(playerid, "RegistrationSkin") == 0)
		{
			SetPVarInt(playerid, "pLogged", 1);
			SetPlayerColor(playerid, 0xFFFFFF00);
			SetPVarInt(playerid, "RegistrationSkin", 1);
			SpawnPlayer(playerid);
		}
		if(PlayerInfo[playerid][pMute] != 0) 
		{
			PlayerMute[playerid] = SetTimerEx("TimeMute", 1000, false, "i", playerid);
		}
		if(PlayerInfo[playerid][pHouse] != 9999)
		{
			if(PlayerInfo[playerid][pCarModel] != -1)
			{
				new HouseID = PlayerInfo[playerid][pHouse] - 1;
				HouseInfo[HouseID][hCar] = CreateVehicle(PlayerInfo[playerid][pCarModel], HouseInfo[HouseID][hCarPosX], HouseInfo[HouseID][hCarPosY], HouseInfo[HouseID][hCarPosZ], HouseInfo[HouseID][hCarAngle], PlayerInfo[playerid][pCarColor1], PlayerInfo[playerid][pCarColor2], 0);
			}
		}
	}
	else
	{
		if(GetPVarInt(playerid, "WrongPassword") == 3)
		{
			SPD(playerid, DLG_NONE, DSM, "{FFFFFF}Авторизация {F385D5}|| Ввод пароля", "{FFFFFF}Ваши попытки по вводу пароля исчерпаны. Вы были отключены от сервера!", "Хорошо", "");
			SCM(playerid, COLOR_ERROR, "[Выход]: {9AAAAB}Используйте \"/q\", чтобы покинуть сервер!");
			return Kick(playerid);
		}
		else
		{
			SetPVarInt(playerid, "WrongPassword", GetPVarInt(playerid, "WrongPassword") + 1);
			new string[256];
			format(string, sizeof(string), "{FFFFFF}Добро пожаловать на Alliant Role Play\nВаш аккаунт зарегистрирован.\nВведите пароль от вашего аккаунта и нажмите \"Далее\"\n\n{B61616}Неверный пароль. Осталось попыток: %d/3.", 4 - GetPVarInt(playerid, "WrongPassword"));
			SPD(playerid, DLG_AUTHORIZATION, DSP, "{FFFFFF}Авторизация {F385D5}|| Ввод пароля", string, "Далее", "Отмена");
		}
	}
	return 1;
}

forward LoadAdmin(playerid);
public LoadAdmin(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows)
	{
		new string[128];
		format(string, sizeof(string), "<ADM> Администратор %d-го уровня %s[%d] авторизовался в админ-панели.", PlayerInfo[playerid][pAdmin], PlayerInfo[playerid][pName], playerid);
		cache_get_value_name_int(0, "aID", AdminInfo[playerid][aID]);
		cache_get_value_name(0, "aName", AdminInfo[playerid][aName], MAX_PLAYER_NAME);
		cache_get_value_name(0, "aLastOnline", AdminInfo[playerid][aLastOnline], 16);
		cache_get_value_name_int(0, "aSkin", AdminInfo[playerid][aSkin]);
		if(PlayerInfo[playerid][pAdmin] >= 8)
        {
        	SendSpecAdminMessage(0xDCBD43FF, string);
            SCM(playerid, 0xDCBD43FF, string);
        }
        else
        {
            SendAdminMessage(0xDCBD43FF, string);
            SCM(playerid, 0xDCBD43FF, string);
        }
		AdminInfo[playerid][aLogged] = 1;
		if(GetPVarInt(playerid, "FirstAdminLogin") == 0)
		{
			static const fmt_query[] = "UPDATE `admins` SET `aLastOnline` = '%04d.%02d.%02d %02d:%02d', `aLogged` = '%d' WHERE `aName` = '%s'";
			new year, month, day, hour, minute, query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)+17];
			gmtime(gettime(), year, month, day, hour, minute);
			format(query, sizeof(query), fmt_query, year, month, day, hour + 3, minute, AdminInfo[playerid][aLogged], AdminInfo[playerid][aName]);
			mysql_tquery(dbHandle, query);
		}
		DeletePVar(playerid, "FirstAdminLogin");
		if(AdminInfo[playerid][aSkin] != 0) return SetPlayerSkin(playerid, AdminInfo[playerid][aSkin]);
	}
	else
	{
		foreach(new i:Player)
		{
			if(PlayerInfo[i][pAdmin] < 8 && PlayerInfo[playerid][pAdmin] > 8) return 1;
			new string[128];
			format(string, sizeof(string), "<ADM> Администратор %s[%d] ввёл неверный пароль.", PlayerInfo[playerid][pName], playerid);
			SendAdminMessage(0xDCBD43FF, string);
		}
		SCM(playerid, 0xDCBD43FF, "<ADM> Вы ввели неверный пароль от админ-панели!");
	}
	return 1;
}

forward HideTextdraw(playerid, hitplayerid);
public HideTextdraw(playerid, hitplayerid)
{
	TextDrawHideForPlayer(playerid, damage[playerid][0]);
	TextDrawHideForPlayer(hitplayerid, damage[hitplayerid][1]);
}

forward CheckAdmin(playerid);
public CheckAdmin(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows)
	{
		SetPVarInt(playerid, "FirstAdminLogin", 0);
		SPD(playerid, DLG_ADMINLOGIN, DSP, "{FFFFFF}Админ-панель {F385D5}|| Авторизация", "{FFFFFF}Введите ваш пароль от админ-панели.", "Далее", "Отмена");
	}
	else
	{
		SetPVarInt(playerid, "FirstAdminLogin", 1);
		SPD(playerid, DLG_ADMINLOGIN, DSI, "{FFFFFF}Админ-панель {F385D5}|| Авторизация", "{FFFFFF}Введите ваш будущий пароль от админ-панели.\n\n{1295CD}Пароль должен иметь длину от 4-х до 16-ти символов!", "Далее", "Отмена");
	}
}

//================================= [ Команды ] =======================================
//------------------------------ [ Админ-команды ] ------------------------------------
CMD:alogin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] == 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы уже авторизированы в админ-панели!");
	static const fmt_query[] = "SELECT `aID` FROM `admins` WHERE `aName` = '%s'";
	new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
	format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query, "CheckAdmin", "i", playerid);
	return 1;
}

CMD:setmats(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {FFFFFF}Вы не авторизированы в админ-панели!");
	if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	SPD(playerid, DLG_FMATS, DSL, "{FFFFFF}Управление {F385D5}|| Установить материалы", "1. Los Santos Police Department\n2. Federal Bureau of Investigation\n3. San Andreas National Guard\n4. Emergency Medical Services\n5. La Cosa Nostra\n6. Yakuza\n7. Government\n8. Weazel News\n9. The Ballas Gang\n10. Los Santos Vagos\n11. Russian Mafia\n12. Grove Street\n13. Varios Los Aztecas\n14. The Rifa Gang\n15. Hell's Angels MC\n16. Outlaws MC\n17. Снять лидера", "Далее", "Отмена");
	return 1;
}

CMD:makesupport(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 9) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {FFFFFF}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /makesupport [id игрока] [1 - назначить | 0 - снять]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
	new query[128];
	switch(params[1])
	{
		case 0:
		{
			PlayerInfo[params[0]][pSupport] = 0;
			if(GetPVarInt(playerid, "sDuty") == 1) SetPVarInt(playerid, "sDuty", 0);
			format(query, sizeof(query), "UPDATE `users` SET `pSupport` = '0' WHERE `pName` = '%s", PlayerInfo[params[0]][pName]);
			mysql_tquery(dbHandle, query);
			SendMes(playerid, "{EE82EE}[Информация]: {FF69B4}Вы сняли игрока {FFFFFF}%s[%d] {FF69B4}с поста саппорта!", PlayerInfo[params[0]][pName], params[0]);
			SCM(params[0], COLOR_INFO, "[Информация]: {FF69B4}Вы были сняты с поста игрового помощника!");
		}
		case 1:
		{
			PlayerInfo[params[0]][pSupport] = 1;
			format(query, sizeof(query), "UPDATE `users` SET `pSupport` = '1' WHERE `pName` = '%s", PlayerInfo[params[0]][pName]);
			mysql_tquery(dbHandle, query);
			SCM(params[0], COLOR_INFO, "[Информация]: {FF69B4}Вы были назначены на пост игрового помощника!");
		}
		default: SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /makesupport [id игрока] [1 - назначить | 0 - снять]");
	}
	return 1;
}

CMD:makeleader(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {FFFFFF}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /makeleader [id игрока]");
	if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	new dialogname[128];
	format(dialogname, sizeof(dialogname), "{FFFFFF}Назначить лидера {F385D5}|| %s[%d]", PlayerInfo[params[0]][pName], params[0]);
	SPD(playerid, DLG_SETLEADER, DSL, dialogname, "1. Los Santos Police Department\n2. Federal Bureau of Investigation\n3. San Andreas National Guard\n4. Emergency Medical Services\n5. La Cosa Nostra\n6. Yakuza\n7. Government\n8. Weazel News\n9. The Ballas Gang\n10. Los Santos Vagos\n11. Russian Mafia\n12. Grove Street\n13. Varios Los Aztecas\n14. The Rifa Gang\n15. Hell's Angels MC\n16. Outlaws MC\n17. Снять лидера", "Далее", "Отмена");
	SetPVarInt(playerid, "LeaderID", params[0]);
	return 1;
}

CMD:goto(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 2) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
   	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /goto [id игрока]");
    if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
    if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете телепортироваться к самому себе!");
    if(PlayerInfo[playerid][pAdmin] < 8 && PlayerInfo[params[0]][pAdmin] >= 8) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете телепортироваться к этому администратору!");
    new Float:fX, Float:fY, Float:fZ;
    GetPlayerPos(params[0], fX, fY, fZ);
    new vw = GetPlayerVirtualWorld(params[0]);
    new pi = GetPlayerInterior(params[0]);
    SetPlayerPos(playerid, fX+1.0, fY+1.0, fZ);
    SetPlayerVirtualWorld(playerid, vw);
    SetPlayerInterior(playerid, pi);
    SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы были успешно телепортированы к игроку!");
    return 1;
}
alias:goto("g")

CMD:auninvite(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /auninvite [id]");
	if(PlayerInfo[params[0]][pFraction] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не состоит в организации.");
	new string[92], query[128];
	format(string, sizeof(string), "[Информация]: {FF69B4}Администратор %s[%d] уволил вас из организации", PlayerInfo[playerid][pName], playerid);
	SCM(params[0], COLOR_INFO, string);
	PlayerInfo[params[0]][pRank] = 0;
	PlayerInfo[params[0]][pFraction] = 0;
	SetPlayerColor(params[0], 0xFFFFFF00);
	SetPlayerSkin(params[0], PlayerInfo[params[0]][pSkin]);
	SetPVarInt(params[0], "DutyStart", 0);
	format(string, sizeof(string), "[A]: {FF69B4}Вы уволили игрока %s из фракции.", PlayerInfo[params[0]][pName]);
	SCM(playerid, COLOR_INFO, string);
	format(query, sizeof(query), "UPDATE `users` SET `pRank` = '%d', `pFraction` = '%d' WHERE `pName` = '%s'", PlayerInfo[params[0]][pRank], PlayerInfo[params[0]][pFraction], PlayerInfo[params[0]][pName]);
	mysql_tquery(dbHandle, query);
	return 1;
}

// CMD:agiverank(playerid, params[])
// {
// 	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
// 	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
// 	if(AdminInfo[playerid][aLogged] != 1 && PlayerInfo[playerid][pAdmin] >= 10) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
// 	if(PlayerInfo[params[0]][pFraction] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не состоит в организации.");
// 	if(sscanf(params, "dd", params[0],params[1])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /agiverank [id] [1-14]");
// 	if(params[1]<1 || params[1]> 14) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Новый ранг должен быть от 1 до 14.");
// 	new string[92], query[128];
// 	format(string, sizeof(string), "[A] Администратор %s[%d] изменил вам ранг. Новый ранг: %d.", PlayerInfo[playerid][pName], playerid, params[1]);
// 	SCM(params[0], COLOR_GREY, string);
// 	PlayerInfo[params[0]][pRank] = params[1];
// 	if(params[1] == 0) 
// 	{
// 		PlayerInfo[params[0]][pFraction] = 0;
// 		SetPlayerSkin(params[0], PlayerInfo[params[0]][pSkin]);
// 		SetPVarInt(params[0], "DutyStart", 0);	
// 	}
// 	if(PlayerInfo[params[0]][pFraction] == 3 && params[1] < 3) 
// 	{
// 		SetPVarInt(params[0], "DutyStart", 1);
// 		SetPlayerSkin(params[0], PlayerInfo[params[0]][pFractionSkin]);
// 	}
// 	format(string, sizeof(string), "[A] Вы изменили ранг игроку %s. Новый ранг: %d.", PlayerInfo[params[0]][pName], params[1]);
// 	SCM(playerid, COLOR_GREY, string);
// 	format(query, sizeof(query), "UPDATE `users` SET `pRank` = '%d', `pFraction` = '%d' WHERE `pName` = '%s'", PlayerInfo[params[0]][pRank], PlayerInfo[params[0]][pFraction], PlayerInfo[params[0]][pName]);
// 	mysql_tquery(dbHandle, query);
// 	return 1;
// }

CMD:delcar(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(PlayerInfo[playerid][pAdmin] < 5) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    new vehicleid = GetPlayerVehicleID(playerid);
	if(GetPlayerVehicleSeat(playerid) == 0) { DestroyVehicle(vehicleid); SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Транспорт удален!"); }
	else if(GetPlayerVehicleSeat(playerid) == 1 || GetPlayerVehicleSeat(playerid) == 2 || GetPlayerVehicleSeat(playerid) == 3 || GetPlayerVehicleSeat(playerid) == 4) { SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Необходимо находиться на водительском месте."); }
	else if(GetPlayerVehicleSeat(playerid) == -1) { SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Необходимо находиться в транспорте!"); }
	return 1;
}
alias:delcar("delveh")

CMD:gzcolor(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 6) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "d", params[0]))
    {
     	SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Используйте: /gzcolor [ID банды]");
     	SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Ballas - 9; Vagos - 10; Grove - 12; Aztec - 13; Rifa - 14");
     	return 1;
    }
    new query[128];
    for(new i = 0; i < TotalGZ; i++)
	{
		if(PlayerOnGangZone(playerid, GZInfo[i][gCoords][0], GZInfo[i][gCoords][1], GZInfo[i][gCoords][2], GZInfo[i][gCoords][3]))
		{
			GZInfo[i][gOwner] = params[0];
			GangZoneStopFlashForAll(GZInfo[i][gZone]);
			GangZoneHideForAll(GZInfo[i][gZone]);
			GangZoneShowForAll(GZInfo[i][gZone], GetGangZoneColor(i));
			format(query, sizeof(query), "UPDATE `gangzone` SET `gOwner` = '%d' WHERE `gID` = '%d'", GZInfo[i][gOwner], GZInfo[i][gID]);
			mysql_tquery(dbHandle, query);
		}
	}
    return 1;
}

CMD:gethere(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /gethere [id игрока]");
    if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
   	if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете телепортировать самого себя!");
    if(PlayerInfo[playerid][pAdmin] < 8 && PlayerInfo[params[0]][pAdmin] >= 8) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете телепортировать этого администратора к себе!");
    new Float:fX, Float:fY, Float:fZ;
    GetPlayerPos(playerid, fX, fY, fZ);
    new vw = GetPlayerVirtualWorld(playerid);
    new pi = GetPlayerInterior(playerid);
    SetPlayerPos(params[0], fX+1.0, fY+1.0, fZ);
    SetPlayerVirtualWorld(params[0], vw);
    SetPlayerInterior(params[0], pi);
    SCM(params[0], COLOR_INFO, "[Информация] {FF69B4}Вы были телепортированы к себе администратором Alliant Role Play!");
    return 1;
}

CMD:mute(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "dds[32]", params[0], params[1], params[2])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /mute [id игрока] [кол-во минут] [причина]");
	if(params[1] < 1 || params[2] > 500) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Время блокировки чата должно быть от 1 до 500 минут!");
	if(PlayerInfo[params[0]][pMute] != 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У данного игрока уже заблокирован чат!");
	new string[144], query[128];
	format(string, sizeof(string), "Администратор %s[%d] заблокировал чат игроку %s[%d] на %d минут. Причина: %s", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]][pName], params[0], params[1], params[2]);
	SCMTA(COLOR_ADMIN, string);
	PlayerInfo[params[0]][pMute] = params[1]*60;
	format(query, sizeof(query), "UPDATE `users` SET `pMute` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[params[0]][pMute], PlayerInfo[params[0]][pID]);
	mysql_tquery(dbHandle, query);
	PlayerMute[playerid] = SetTimerEx("TimeMute", 1000, false, "i", params[0]);
	return 1;
}

CMD:unmute(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "ds[32]", params[0], params[1])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /unmute [id игрока] [причина]");
	if(PlayerInfo[params[0]][pMute] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У игрока нет блокировки чата!");
	KillTimer(PlayerMute[params[0]]);
	PlayerInfo[params[0]][pMute] = 0;
	new query[128], string[128];
	format(query, sizeof(query), "UPDATE `users` SET `pMute` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[params[0]][pMute], PlayerInfo[params[0]][pID]);
	mysql_tquery(dbHandle, query);
	format(string, sizeof(string), "Администратор %s[%d] снял блокировку чата с игрока %s[%d]. Причина: %s", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]], params[0], params[1]);
	SCMTA(COLOR_ADMIN, string);
	SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Блокировка чата снята. Вы снова можете писать в чат!");
	return 1;
}

CMD:createhouse(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 10) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	SPD(playerid, DLG_CREATEHOUSECLASS, DSL, "{FFFFFF}Создание дома {FEA9D8}|| Тип дома", "{F3B634}[1] {FFFFFF}Эконом класс\n{F3B634}[2] {FFFFFF}Средний класс\n{F3B634}[3] {FFFFFF}Премиум класс\n{F3B634}[4] {FFFFFF}Элитный класс", "Далее", "Закрыть");
	return 1;
}

CMD:veh(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "ddd", params[0], params[1], params[2])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /veh [id авто] [Цвет №1] [Цвет №2]");
	if(params[0] < 400 || params[0] > 611) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Неверный ID транспорта.");
	if((params[1] < 0 || params[1] > 255) || (params[2] < 0 || params[2] > 255)) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Неверный цвет транспорта.");
	new string[128];
	new Float:fX, Float:fY, Float:fZ, Float:fAngle;
	GetPlayerPos(playerid, fX, fY, fZ);
	GetPlayerFacingAngle(playerid, fAngle);
	new vehicleid = CreateVehicle(params[0], fX, fY, fZ, fAngle, params[1], params[2], 0);
	SetVehicleNumberPlate(vehicleid, "Admins");
	format(string, sizeof(string), "[Информация] {FF69B4}Транспорт установлен. ID: %d", params[0]);
	SCM(playerid, COLOR_INFO, string);
	PutPlayerInVehicle(playerid, vehicleid, 0);
	return 1;
}

CMD:gotocar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /gotocar [id авто]");
	if(GetVehicleModel(params[0]) == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Не корректный ID.");
	new string[128], Float:fX, Float:fY, Float:fZ;
	GetVehiclePos(params[0], Float:fX, Float:fY, Float:fZ);
	SetPlayerPos(playerid, Float:fX+2, Float:fY, Float:fZ);
	format(string, sizeof(string), "[Информация] {FF69B4}Вы были телепортированы к транспорту [ID:%d].", params[0]);
	SCM(playerid, COLOR_INFO, string);
	return 1;
}

CMD:tpcar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /tpcar [id авто]");
	if(GetVehicleModel(params[0]) == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Не корректный ID.");
	new string[128], Float:fX, Float:fY, Float:fZ;
	GetPlayerPos(playerid, fX, fY, fZ);
	SetVehiclePos(params[0], Float:fX+2, Float:fY, Float:fZ);
	format(string, sizeof(string), "[Информация] {FF69B4}Транспорт [ID:%d] перемещён к вам.", params[0]);
	SCM(playerid, COLOR_INFO, string);
	return 1;
}
alias:tpcar("getherecar")

CMD:tpcord(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	new Float:fX, Float:fY,Float:fZ;
	if(sscanf(params, "p<,>fff", fX, fY, fZ)) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /tpcord [координаты (x,y,z) через пробел]");
	SetPlayerPos(playerid, fX, fY, fZ);
	return 1;
}
alias:tpcord("tpcor")

CMD:givegun(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "udd",params[0],params[1],params[2])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /givegun [id] [id оружия] [патроны]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
	if(params[2] < 1 || params[2] > 9999) return SendClientMessage(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя меньше 1 или больше 9999 патронов!");
	GivePlayerWeapon(params[0],params[1],params[2]);
	SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Оружие выдано.");
	return true;
}

CMD:skin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /skin [id скина]");
	if(params[0] < 0 || params[0] > 311) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Неверный ID скина.");
	new string[128];
	new query[512];
	format(string, sizeof(string), "[Информация] {FF69B4}Вы установили себе временный скин. ID: %d", params[0]);
	SCM(playerid, COLOR_INFO, string);
	AdminInfo[playerid][aSkin] = params[0];
	SetPlayerSkin(playerid, AdminInfo[playerid][aSkin]);
	static const fmt_query[] = "UPDATE `admins` SET `aSkin` = '%d' WHERE `aName` = '%s' LIMIT 1";
	format(query, sizeof(query), fmt_query, AdminInfo[playerid][aSkin], PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query);
	return 1;
}

CMD:setint(playerid, params[])
{
	new string[256];
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "dd",params[0],params[1])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /setint [id игрока] [id интерьера]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	if(PlayerInfo[playerid][pAdmin] <= 7)
	{
		format(string, sizeof(string), "[A] Администратор %s[%d] телепортировал игрока %s[%d] в интерьер с ID: %d", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]][pName], params[0], params[1]);
		SendAdminMessage(COLOR_INFO, string);
	}
	else
	{
		format(string, sizeof(string), "[Информация] {FF69B4}Вы установили игроку %s[%d] интерьер с ID: %d.", PlayerInfo[params[0]][pName], params[0], params[1]);
		SCM(playerid, COLOR_INFO, string);
	}
	SetPlayerInterior(params[0], params[1]);
	return 1;
}

CMD:pspawn(playerid, params[])
{
	new string[256];
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "d",params[0])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /pspawn [id]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
    SpawnPlayer(params[0]);
    if(PlayerInfo[playerid][pAdmin] < 8)
    {
	    format(string, sizeof(string), "[A] Администратор %s[%d] заспавнил игрока %s[%d]", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]][pName], params[0]);
	    SendAdminMessage(COLOR_GREY, string);
	}
	SCM(params[0], COLOR_INFO, "[Информация] {FF69B4}Вы были зареспавнены администратором Alliant RP!");
    return 1;
}

CMD:slap(playerid, params[])
{
	new string[256];
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "d",params[0])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /slap [id]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
	if(PlayerInfo[playerid][pAdmin] < 1) return 1;
	format(string, sizeof(string), "[A] Администратор %s[%d] дал поджопник игроку %s", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]][pName]);
	SendAdminMessage(COLOR_GREY, string);
	format(string, sizeof(string), "Администратор %s[%d] дал вам поджопник.", PlayerInfo[playerid][pName], playerid);
	SCM(params[0], COLOR_ADMIN, string);
	new Float:fX, Float:fY, Float:fZ;
	GetPlayerPos(params[0], Float:fX, Float:fY, Float:fZ);
	if(IsPlayerInVehicle(params[0], GetPlayerVehicleID(params[0]))) 
	{
		RemovePlayerFromVehicle(params[0]);
		SetPlayerPos(params[0], Float:fX, Float:fY, Float:fZ+5);
	}
	else
	{
		SetPlayerPos(params[0], Float:fX, Float:fY, Float:fZ+5);
	}
	PlayerPlaySound(params[0], 1130, Float:fX, Float:fY, Float:fZ+5);
	return 1;
}

CMD:aad(playerid, params[])
{
	new string[256];
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "s[92]",params[0])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /aad [сообщение]");
	format(string, sizeof(string), "Администратор %s[%d]: %s", PlayerInfo[playerid][pName], playerid, params[0]);
	SCMTA(COLOR_ADMIN, string);
	return 1;
}

CMD:ooc(playerid, params[])
{
	new string[256];
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "s[92]",params[0])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /ooc [сообщение]");
	format(string, sizeof(string), "%s[%d]: %s", PlayerInfo[playerid][pName], playerid, params[0]);
	SCMTA(COLOR_WHITE, string);
	return 1;
}

CMD:skick(playerid, params[])
{
	new string[256];
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "ds[92]",params[0],params[1])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /skick [id] [причина]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете кикнуть самого себя!");
	format(string, sizeof(string), "[A] Администратор %s[%d] тихо кикнул игрока %s", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]][pName]);
	SendAdminMessage(COLOR_GREY, string);
	Kick(params[0]);
	return 1;
}

CMD:kick(playerid, params[])
{
	new string[256];
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "ds[92]",params[0],params[1])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /kick [id] [причина]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не можете кикнуть самого себя!");
	format(string, sizeof(string), "Администратор %s[%d] кикнул игрока %s. Причина: %s", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]][pName], params[1]);
	SCMTA(COLOR_ADMIN, string);
	Kick(params[0]);
	return 1;
}

CMD:editattachedobject(playerid,params[])
{
	if(PlayerInfo[playerid][pAdmin] < 10) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /editattachedobject(/eao) [id игрока] [id слота]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
	EditAttachedObject(params[0], params[1]);
	SetPVarInt(playerid, "EditObject", 1);
	return 1;
}
alias:editattachedobject("eao")

CMD:admin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "s[95]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /admin(/a) [сообщение]");
	new string[128];
    format(string, sizeof(string), "<ADM> %s[%d]: %s", PlayerInfo[playerid][pName], playerid, params[0]);
	SendAdminMessage(0xDCBD43FF, string);
	return 1;
}
alias:admin("a")

CMD:hp(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	SetHealth(playerid, 200);
	SCM(playerid, COLOR_WHITE, "Значение здоровья установлено: 200.");
	if(IsPlayerInVehicle(playerid, GetPlayerVehicleID(playerid))) 
	{
		SetVehicleHealth(GetPlayerVehicleID(playerid), 1000);
		RepairVehicle(GetPlayerVehicleID(playerid));
		SCM(playerid, COLOR_WHITE, "Машина отремонтирована.");
	}
	return 1;
}

CMD:makeadmin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 9) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "dd",params[0],params[1])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /makeadmin [id] [уровень админ-прав(1-7)]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
    if(PlayerInfo[params[0]][pAdmin] > 8) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Недостаточно полномочий!");
    new query[256];
    if(params[1] == 0)
    {
    	PlayerInfo[params[0]][pAdmin] = 0;
    	SetPVarInt(params[0], "aLogged", 0);
    	format(query, sizeof(query), "DELETE * FROM `admins` WHERE `aName` = '%s' LIMIT 1", PlayerInfo[params[0]][pName]);
    	mysql_tquery(dbHandle, query);
    	return 1;
    }
    SetPVarInt(playerid, "SetAdminID", params[0]);
    SetPVarInt(playerid, "SetAdminLevel", params[1]);
   	format(query, sizeof(query), "SELECT * FROM `admins` WHERE `aName` = '%s' LIMIT 1", PlayerInfo[params[0]][pName]);
   	mysql_tquery(dbHandle, query, "SetPlayerAdmin", "i", playerid);
   	return 1;
}

CMD:givearm(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "ud",params[0],params[1])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /givearm [id] [кол-во]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
	if(params[1] < 0 || params[1] > 100) return SendClientMessage(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя меньше 0 или больше 100 патронов!");
	SetPlayerArmour(params[0], params[1]);
	SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Броня установлена.");
	return 1;
}
alias:givearm("setarm")

CMD:warn(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "dds[32]", params[0], params[1])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /warn [id игрока] [кол-во дней] [причина]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
    new query[256], string[128];
	PlayerInfo[params[0]][pWarn]++;
	new year, month, day, hour, minute;
	gmtime(gettime(), year, month, day, hour, minute);
	if(PlayerInfo[params[0]][pWarn] == 3)
    {
    	return 1;
    }
    format(query, sizeof(query), "INSERT INTO `warns` (`wNick`, `wAmountID`, `wDate`, `wAdminName`, `wReason`) VALUES ('%s', '%d', '%02d.%02d.%04d %02d:%02d', '%s', '%s')", PlayerInfo[params[0]][pName], PlayerInfo[params[0]][pWarn], day, month, year, hour, minute, PlayerInfo[playerid][pName], params[1]);
	mysql_tquery(dbHandle, query);
	format(query, sizeof(query), "UPDATE `users` SET `pWarn` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[params[0]][pWarn], PlayerInfo[params[0]][pID]);
	mysql_tquery(dbHandle, query);
	format(string, sizeof(string), "Администратор %s[%d] выдал предупреждение игроку %s[%d]. Причина: %s", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]][pName], params[0], params[1]);
	SCMTA(COLOR_ADMIN, string);
	if(PlayerInfo[params[0]][pFraction] != 0)
    {
    	PlayerInfo[params[0]][pFraction] = 0;
    	PlayerInfo[params[0]][pRank] = 0;
    	format(query, sizeof(query), "UPDATE `users` SET `pFraction` = '%d', `pRank` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[params[0]][pFraction], PlayerInfo[params[0]][pRank], PlayerInfo[params[0]][pID]);
    	mysql_tquery(dbHandle, query);
    }
	Kick(params[0]);
	return 1;
}

CMD:unwarn(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "ds[32]", params[0], params[1])) return SendClientMessage(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /unwarn [id игрока] [причина]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
    if(PlayerInfo[params[0]][pWarn] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У данного игрока нет предупреждений!");
    new query[128], string[128];
    format(query, sizeof(query), "DELETE FROM `warns` WHERE `wNick` = '%s' AND `wAmountID` = '%d'", PlayerInfo[params[0]][pName], PlayerInfo[params[0]][pWarn]);
    mysql_tquery(dbHandle, query);
    PlayerInfo[params[0]][pWarn]--;
    format(query, sizeof(query), "UPDATE `users` SET `pWarn` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[params[0]][pWarn], PlayerInfo[params[0]][pID]);
    mysql_tquery(dbHandle, query);
    format(string, sizeof(string), "[A] Администратор %s[%d] снял предупреждение игроку %s[%d]. Причина: %s", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]][pName], params[0], params[1]);
    SendAdminMessage(COLOR_GREY, string);
    format(string, sizeof(string), "[Информация] {FF69B4}Администратор %s[%d] снял Вам предупреждение!", PlayerInfo[playerid][pName], playerid);
    SCM(params[0], COLOR_INFO, string);
	return 1;
}

CMD:givelic(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1 && PlayerInfo[playerid][pAdmin] >= 2) return SCM(playerid, COLOR_ERROR, "[Ошибка] {FFFFFF}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /givelic [ID]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
	new query[512];
	PlayerInfo[params[0]][pCarLic] = 1; PlayerInfo[params[0]][pAirLic] = 1;	PlayerInfo[params[0]][pBoatLic] = 1; PlayerInfo[params[0]][pBikeLic] = 1; PlayerInfo[params[0]][pFishLic] = 1; PlayerInfo[params[0]][pBizLic] = 1; PlayerInfo[params[0]][pGunLic] = 1;
	format(query, sizeof(query), "UPDATE `users` SET `pCarLic` = '%d', `pAirLic` = '%d', `pBikeLic` = '%d', `pBoatLic` = '%d', `pFishLic` = '%d', `pBizLic` = '%d', `pGunLic` = '%d' WHERE `pName` = '%s' LIMIT 1", PlayerInfo[params[0]][pCarLic], PlayerInfo[params[0]][pAirLic], PlayerInfo[params[0]][pBikeLic], PlayerInfo[params[0]][pBoatLic], PlayerInfo[params[0]][pFishLic], PlayerInfo[params[0]][pBizLic], PlayerInfo[params[0]][pGunLic], PlayerInfo[params[0]][pName]);
	mysql_tquery(dbHandle, query);
	SCM(playerid, 0x90EE90AA, "[Выполнено]: {FFFFFF}Игроку выданы все лицензии.");
	return 1;
}

CMD:tp(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1 && PlayerInfo[playerid][pAdmin] >= 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {FFFFFF}Вы не авторизированы в админ-панели!");
	SPD(playerid, DLG_TPLIST, DSL, "{4DB8E6}Mеню телепорта", "[1] Базы организаций", "Далее", "Отмена");
	return 1;
}
CMD:PayDay(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1 && PlayerInfo[playerid][pAdmin] >= 10) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	foreach(new i: Player)
	{
		PlayerInfo[i][pTime] = 21;
	}
	PayDay();
	return 1;
}

CMD:getstats(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1 && PlayerInfo[playerid][pAdmin] >= 2) return SCM(playerid, COLOR_ERROR, "[Ошибка] {FFFFFF}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /getstats [ID]");
	if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Для получения своей статистики используйте /stats.");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
	new string[1200];
	new frakname[526];
	new nextlevel = PlayerInfo[params[0]][pLevel] + 1;
	switch(PlayerInfo[params[0]][pFraction])
	{
		case 0: { frakname = "Нет"; }
		case 1: { frakname = "LSPD"; }
		case 2: { frakname = "FBI"; }
		case 3: { frakname = "SANG"; }
		case 4: { frakname = "EMS"; }
		case 5: { frakname = "LCN"; }
		case 6: { frakname = "Yakuza"; }
		case 7: { frakname = "Government"; }
		case 8: { frakname = "CNN"; }
		case 9: { frakname = "The Ballas Gang"; }
		case 10: { frakname = "Los Santos Vagos"; }
		case 11: { frakname = "Russian Mafia"; }
		case 12: { frakname = "Grove Street"; }
		case 13: { frakname = "Varios Los Aztecas"; }
		case 14: { frakname = "The Rifa Gang"; }
		case 15: { frakname = "Hell’s Angels MC"; }
		case 16: { frakname = "Outlaws MC"; }
	}
	format(string, sizeof(string), "Наименование\tЗначение\n\
		Имя и Фамилия:\t%s\nУровень:\t%d\nОчки опыта:\t%d/%d\nДеньги:\t%d\n\
		Деньги в банке:\t%d\nТелефон:\t1\nОрганизация:\t%s\nРанг:\t%d\n\
		Наркотики:\t%d\nМатериалы:\t%d", 
		PlayerInfo[params[0]][pName], PlayerInfo[params[0]][pLevel], PlayerInfo[params[0]][pExp], nextlevel *exptonextlevel, 
		PlayerInfo[params[0]][pMoney], PlayerInfo[params[0]][pBankMoney], frakname, PlayerInfo[params[0]][pRank], PlayerInfo[params[0]][pDrugs], PlayerInfo[params[0]][pMaterials]);
	SPD(playerid, DLG_STATS, DSTH, "{FFFFFF}Mеню персонажа {4DB8E6}|| Статистика персонажа", string, "Далее", "Отмена");
	return 1;
}

CMD:sethp(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1 && PlayerInfo[playerid][pAdmin] >= 2) return SCM(playerid, COLOR_ERROR, "[Ошибка] {FFFFFF}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /sethp [ID] [Здоровье]");
	if(params[1]<0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Здоровье не может быть ниже 0."); 
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован!");
	SCM(playerid, 0x90EE90AA, "[Выполнено]: {FFFFFF}Игроку установлено здоровье.");
	SetPlayerHealth(params[0], params[1]);
	return 1;
}

CMD:spcar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /spcar [id авто]");
	if(GetVehicleModel(params[0]) == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Некорректный ID.");
	SetVehicleToRespawn(params[0]);
	new string[128];
	format(string, sizeof(string), "[Информация] {FF69B4}Вы заспавнили транспорт. {FFFFFF}[ID: %d]", params[0]);
	SCM(playerid, COLOR_INFO, string);
	return 1;
}

CMD:sprcar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1 && PlayerInfo[playerid][pAdmin] >= 2) return SCM(playerid, COLOR_ERROR, "[Ошибка] {FFFFFF}Вы не авторизированы в админ-панели!");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /sprcar [радиус]");
	if(params[0] < 1 || params[0] > 300) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Некорректный радиус. Значение должно быть от 1 до 300.");
	new Float:fX, Float:fY, Float:fZ;
	for(new i = 0; i < GetVehiclePoolSize(); i++)
	{
		GetVehiclePos(i, fX, fY, fZ);
		if(!IsPlayerInRangeOfPoint(playerid, params[0] + 2, fX, fY, fZ)) continue;
		SetVehicleToRespawn(i);
	}
	return 1;
}

CMD:spawncars(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	SPD(playerid, DLG_SPAWNCARS, DIALOG_STYLE_MSGBOX, "{66D9BC}Спавн транспорта {FFFFFF}|| Админ-права", "{FFFFFF}Выберите, какой тип транспорта Вы хотите заспавнить.", "Весь", "Незанятый");
	return 1;
}

CMD:settime(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 8) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Используйте: /settime [время]");
    if(params[0] < 0 || params[0] > 23) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Нельзя меньше 0 или больше 23 часов!");
    SetWorldTime(params[0]);
    SendClientMessage(playerid, COLOR_INFO, "[Информация]: {FF69B4}Время успешно установлено!");
    return 1;
}

CMD:setweather(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 8) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Используйте: /setweather [id погоды]");
    if(params[0] < 0 || params[0] > 45) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}ID погоды не может быть меньше 0 или больше 45!");
    SetWeather(params[0]);
    new string[128]; 
    format(string, sizeof(string), "[Информация]: {FF69B4}Погода успешно установлена! ID погоды: %d", params[0]);
    SendClientMessage(playerid, COLOR_INFO, string);
    return 1;
}

CMD:recon(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Используйте: /(re)con [id игрока]");
	if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя использовать команду на себе!");
	if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    // SpecAd[playerid] = 65535;
	SpecAd[playerid] = params[0];
	GetPlayerPos(playerid, SpecPos[playerid][0], SpecPos[playerid][1], SpecPos[playerid][2]);
	SetPVarInt(playerid, "SpecVirtualWorld", GetPlayerVirtualWorld(playerid));
	SetPVarInt(playerid, "SpecInterior", GetPlayerInterior(playerid));
	new string[128]; 
    format(string, sizeof(string), "[A]: {FF69B4}Вы начали следить за {FFFFFF}%s", PlayerInfo[params[0]][pName]);
    SendClientMessage(playerid, COLOR_INFO, string);
    format(string, sizeof(string), "[A]: Администратор %s начал следить за %s.", PlayerInfo[playerid][pName], PlayerInfo[params[0]][pName]);
    if(PlayerInfo[playerid][pAdmin] >= 7) SendAdminMessage(COLOR_YELLOW, string);
	SetTimerEx("SpecPlayers", 100, false, "i", playerid);
	return 1;
}
alias:recon("re")

CMD:reoff(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 7) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы в админ-панели!");
	TogglePlayerSpectating(playerid, 0);
	return 1;
}

CMD:pm(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return 1;
	new text[128], string[128];
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "ds[128]",params[0], text)) return SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Используйте: /pm [id игрока] [текст]");
    format(string, sizeof(string), "Ответ от администратора %s[%i]:{FFFFFF} %s", PlayerInfo[playerid][pName], playerid, text);
    SCM(params[0], COLOR_YELLOW, string);
    SendAdminMessage(COLOR_YELLOW, string);
	return 1;
}

CMD:setname(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
	new string[128], query[128];
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(AdminInfo[playerid][aLogged] != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не авторизированы в админ-панели!");
    if(sscanf(params, "d",params[0])) return SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Используйте: /setname [id игрока]");
    if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    if(GetPVarInt(params[0], "RedName") != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Игрок не запрашивал смену ника.");
    GetPVarString(params[0], "RedName_String", RedName_String, sizeof(RedName_String));
    SetPlayerName(params[0], RedName_String);
    SetPVarInt(params[0], "RedName", 0);
    format(string, sizeof(string), "Администратор %s[%i] одобрил смену ника игроку %s -> %s", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]][pName], RedName_String);
    SCMTA(COLOR_ADMIN, string);
    format(string, sizeof(string), "Администратор %s[%i] вам смену ника.", PlayerInfo[playerid][pName], playerid);
    SCM(params[0], COLOR_YELLOW, string);
    GetPVarString(params[0], "RedName_String", PlayerInfo[params[0]][pName], sizeof(RedName_String));
    format(query, sizeof(query), "UPDATE `users` SET `pName` = '%s' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[params[0]][pName], PlayerInfo[params[0]][pID]);
    mysql_tquery(dbHandle, query);
	return 1;
}
//============================== [ Саппортские CMD ] ====================================
CMD:sduty(playerid, params[])
{
	if(PlayerInfo[playerid][pSupport] < 1 || PlayerInfo[playerid][pAdmin] < 1) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	new query[128];
	format(query, sizeof(query), "SELECT * FROM `supports` WHERE `sName` = '%s'", PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query, "CheckSupport", "i", playerid);
	return 1;
}

CMD:sc(playerid, params[])
{
	if(PlayerInfo[playerid][pSupport] < 1 || PlayerInfo[playerid][pAdmin] < 1) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(GetPVarInt(playerid, "sDuty") != 1) return SCM(playerid, COLOR_ERROR, "[Ошибка]: {9AAAAB}Вы не начали рабочий день саппорта!");
	if(sscanf(params, "s[95]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /sc [сообщение]");
	new string[128];
    format(string, sizeof(string), "[S] %s[%d]: %s", PlayerInfo[playerid][pName], playerid, params[0]);
    SendSupportMessage(0x5D9B9BFF, string);
    return 1;
}
//------------------------------ [ Команды игроков ] ------------------------------------
CMD:ask(playerid, params[])
{
	if(sscanf(params, "s[95]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /ask [текст]");
	if(TotalQuestions == 0)
	{
		QInfo[TotalQuestions][qID] = TotalQuestions + 1;
		strmid(QInfo[TotalQuestions][qName], PlayerInfo[playerid][pName], 0, strlen(PlayerInfo[playerid][pName]), 24);
		strmid(QInfo[TotalQuestions][qQuestion], params[0], 0, strlen(params[0]), 128);
	}
	else
	{
		QInfo[TotalQuestions + 1][qID] = TotalQuestions + 1;
		strmid(QInfo[TotalQuestions + 1][qName], PlayerInfo[playerid][pName], 0, strlen(PlayerInfo[playerid][pName]), 24);
		strmid(QInfo[TotalQuestions + 1][qQuestion], params[0], 0, strlen(params[0]), 128);
	}
	TotalQuestions++;
	return 1;
}

CMD:test123(playerid, params[])
{
	new string[256];
	format(string, sizeof(string), "ID\tИмя\n");
	for(new i = 0; i < TotalQuestions; i++)
	{
		format(string, sizeof(string), "%s%d\t%s\n", string, QInfo[i][qID], QInfo[i][qName]);
	}
	SPD(playerid, DLG_ASK, DSTH, "{FFFFFF}Mеню персонажа {4DB8E6}|| Статистика персонажа", string, "Далее", "Отмена");
	return 1;
}

CMD:report(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	new text[128], string[128];
	if(sscanf(params, "ds[128]",params[0], text)) return SCM(playerid, COLOR_INFO, "[Информация]: {FF69B4}Используйте: /report [id игрока] [текст]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	format(string, sizeof(string), "Жалоба от %s[%i] на %s[%i]: %s", PlayerInfo[playerid][pName], playerid, PlayerInfo[params[0]][pName], params[0], text);
	SendAdminMessage(COLOR_YELLOW, string);
	SCM(playerid, COLOR_YELLOW, "Ваша жалоба была отправлена администрации");
	return true;
}

CMD:leadermenu(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    SPD(playerid, DLG_LEADER_MENU, DSL, "{FFFFFF}Меню лидера", "{FFFFFF}1. Название рангов\n{FFFFFF}2. Название рангов", "Далее", "Отмена");
	return true;
}

CMD:invite(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2, 3, 4, 7, 8: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    } 
    if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fInvRang]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная команда.");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /invite [id игрока]");
	if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя использовать команду на себе!");
	if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	if(!ProxDetectorS(3.0,playerid,params[0]) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок слишком далеко.");
	if(PlayerInfo[playerid][pFraction] == PlayerInfo[params[0]][pFraction]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок уже состоит в вашей организации!");
	if(PlayerInfo[params[0]][pFraction] != 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок уже состоит в организации!");
	new string[128];
	format(string, sizeof(string), "[Информация]: {FFFFFF}%s[%d] {FF69B4}приглашает вас вступить во фракцию {FFFFFF}%s.", PlayerInfo[playerid][pName], playerid, FracInfo[PlayerInfo[playerid][pFraction]-1][fName]);
	SCM(params[0], COLOR_INFO, string);
	SCM(params[0], COLOR_INFO, "[Информация]: {FF69B4}Нажмите {FF9910}Y {FF69B4}- чтобы вступить во фракцию, {FF9910}N {FF69B4}- чтобы отказаться от вступления.");
	format(string, sizeof(string), "[Информация]: {FF69B4}Вы пригласили {FFFFFF}%s[%d] {FF69B4}вступить во фракцию  {FFFFFF}%s.", PlayerInfo[params[0]][pName], params[0], FracInfo[PlayerInfo[playerid][pFraction]-1][fName]);
	SCM(playerid, COLOR_INFO, string);
	SetPVarInt(params[0], "InviterID", playerid);
	SetPVarInt(params[0], "InviteID", PlayerInfo[playerid][pFraction]);
	SetPVarInt(params[0], "InviteAccept", 1);
	SetTimerEx("InviteAcceptTimer", 30000, false, "i", playerid);
	return true;
}

CMD:uninvite(playerid, params[])
{
	new string[128], query[128];
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2, 3, 4, 7, 8: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    } 
    if(sscanf(params, "ds[32]", params[0], params[1])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /uninvite [id игрока] [причина]");
	if(PlayerInfo[playerid][pRank]< FracInfo[PlayerInfo[playerid][pFraction]-1][fInvRang] || PlayerInfo[playerid][pRank]<PlayerInfo[params[0]][pRank]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная команда.");
	if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя применять на себе.");
	if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	if(PlayerInfo[playerid][pFraction] != PlayerInfo[params[0]][pFraction]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не состоит в вашей организации!");
	format(string, sizeof(string), "[Информация] {FFFFFF}%s {FF69B4}уволил вас из организации. Причина: {FFFFFF}%s", PlayerInfo[playerid][pName], params[1]);
	SCM(params[0], COLOR_INFO, string);
	SetPlayerColor(params[0], 0xFFFFFF00);
	format(string, sizeof(string), "[Информация]{FF69B4} Вы уволили {FFFFFF}%s {FF69B4}из организации. Причина: {FFFFFF}%s", PlayerInfo[params[0]][pName], params[1]);
	SCM(playerid, COLOR_INFO, string);
	SetPlayerSkin(params[0], PlayerInfo[params[0]][pSkin]);
	PlayerInfo[params[0]][pFraction] = 0;
	PlayerInfo[params[0]][pRank] = 0;
	SetPlayerColor(params[0], 0xFFFFFF00);
	format(query, sizeof(query), "UPDATE `users` SET `pFraction` = '0', `pFractionSkin` = '0', `pRank` = '0' WHERE `pName` = '%s'", PlayerInfo[params[0]][pName]);
	mysql_tquery(dbHandle, query);
	return true;
}

CMD:giverank(playerid, params[])
{
    new rangname[32], string[128], query[128]; 
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2, 3, 4, 7, 8: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }//) || PlayerInfo[playerid][pName] != FracInfo[PlayerInfo[playerid][pFraction]-1][fLeader]
    if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fInvRang]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная команда.");
	if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /giverank [id игрока] [ранг]");
	if(params[1] >= FracInfo[PlayerInfo[playerid][pFraction]-1][fInvRang] && PlayerInfo[playerid][pName] != FracInfo[PlayerInfo[playerid][pFraction]-1][fLeader]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная функция.");
	if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя применять на себе.");
	if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
    switch(params[1])
    {
    	case 1: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang1]), 32);
    	case 2: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang2]), 32);
    	case 3: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang3]), 32);
    	case 4: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang4]), 32);
    	case 5: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang5]), 32);
    	case 6: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang6]), 32);
    	case 7: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang7]), 32);
    	case 8: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang8]), 32);
    	case 9: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang9], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang9]), 32);
    	case 10: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang10], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang10]), 32);
    	case 11: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang11], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang11]), 32);
    	case 12: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang12], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang12]), 32);
    	case 13: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang13], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang13]), 32);
    	case 14: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang14], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang14]), 32);
    	case 15: strmid(rangname, FracInfo[PlayerInfo[playerid][pFraction]-1][fRang15], 0, strlen(FracInfo[PlayerInfo[playerid][pFraction]-1][fRang15]), 32);
    }   
	if(PlayerInfo[playerid][pFraction] != PlayerInfo[params[0]][pFraction]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не состоит в вашей организации!");
	PlayerInfo[params[0]][pRank] = params[1];
	format(string, sizeof(string), "[Информация] {FF69B4}%s повысил/понизил вас до %s [%d]", PlayerInfo[playerid][pName], rangname, params[1]);
	SCM(params[0], COLOR_INFO, string);
	format(string, sizeof(string), "[Информация] {FF69B4}Вы повысили/понизили игрока %s до %s [%d]", PlayerInfo[params[0]][pName], rangname, params[1]);
	SCM(playerid, COLOR_INFO, string);
	format(query, sizeof(query), "UPDATE `users` SET `pRank` = '%d' WHERE `pName` = '%s'", params[1], PlayerInfo[params[0]][pName]);
	mysql_tquery(dbHandle, query);
	return true;
}

CMD:warehouse(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    new fraction = PlayerInfo[playerid][pFraction];
    new string[526];
	if(fraction != 4 && fraction != 7 && fraction != 8 && fraction != 0)
	{
		format(string, sizeof(string), "Материалов на складе %s: {FFFFFF}%d", FracInfo[fraction-1][fName], FracInfo[fraction-1][fMaterials]);
		SCM(playerid, COLOR_INFO, string);
		if(PlayerInfo[playerid][pName] == FracInfo[fraction-1][fLeader]) { format(string, sizeof(string), "Бюджет: {FFFFFF}%d", FracInfo[fraction-1][fBank]); SCM(playerid, COLOR_INFO, string); }
	}
	return true;
}

CMD:prem(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 ) { switch(PlayerInfo[playerid][pFraction]) { case 1, 2, 3, 4, 7, 8: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день."); } }
    if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fInvRang]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная команда.");
	if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /prem [id игрока] [сумма выплаты]");
	if(GetPVarInt(params[0], "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не авторизирован на сервере!");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не найден!");
	if(PlayerInfo[playerid][pFraction] != PlayerInfo[params[0]][pFraction]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не состоит в вашей организации!");
	if(params[1] > FracInfo[PlayerInfo[playerid][pFraction]-1][fBank]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}На балансе вашей организации нет такой суммы!");
	PlayerInfo[params[0]][pBankMoney] += params[1];
	new fraction = PlayerInfo[playerid][pFraction];
	FracInfo[fraction-1][fBank] -= params[1];
    new string[526];
	format(string, sizeof(string), "[Организация] %s выплатил премию %s в размере %d", PlayerInfo[playerid][pName], PlayerInfo[params[0]][pName], params[1]);
	foreach(new i:Player) {	if(PlayerInfo[i][pFraction] == PlayerInfo[playerid][pFraction]) SCM(i, 0x9370DBFF, string); }
	format(string, sizeof(string), "[Организация] %s выплатил вам премию размере %d", PlayerInfo[playerid][pName], params[1]);
	SCM(params[0], 0x9370DBFF, string);
	return true;
}

CMD:arrest(playerid, params[])
{
	new string[128], query[128];
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }
	if(PlayerInfo[playerid][pFraction] != 1 && PlayerInfo[playerid][pFraction] !=2) return 1;
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /arrest [id игрока]");
    if(playerid == params[0]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя применять на самого себя.");
	if(!ProxDetectorS(3.0,playerid,params[0]) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок слишком далеко.");
	if(PlayerInfo[playerid][pCopKey] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам нужны ключи от камеры. ({FFFFFF}/takekeys{9AAAAB})");
	if(!IsPlayerInRangeOfPoint(playerid, 6.0, 1472.5946,1055.5625,-50.4082) && GetPlayerVirtualWorld(playerid) != 1) return true;
	if(PlayerInfo[params[0]][pWanted] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}У игрока должен быть хотя бы один уровень розыска.");
	if(GetPVarInt(params[0], "OnEscort") != -1)
	{
		SetPVarInt(playerid, "Escorted", -1);
		SetPVarInt(params[0], "OnEscort", -1);
		KillTimer(FollowTimer[params[0]]);
		FollowTimer[params[0]] = INVALID_PLAYER_ID;
		ClearAnimations(playerid);
		TogglePlayerControllable(params[0], 0);
		GameTextForPlayer(params[0],"~g~unfollow", 2000, 3);
	}
	if(GetPVarInt(params[0], "Cuffed") != 0)
	{
		RemovePlayerAttachedObject(params[0], 0);
		SetPlayerSpecialAction(params[0],SPECIAL_ACTION_NONE);
	    TogglePlayerControllable(params[0], 1);
	    SetPVarInt(params[0], "Cuffed", 0);
	}
	SetPlayerPos(params[0], 1477.1868,1057.2545,-50.4020);
	SetPlayerFacingAngle(params[0], 90.9791);
    PlayerInfo[params[0]][pTimeWanted] = PlayerInfo[params[0]][pWanted]*10;
	PlayerInfo[params[0]][pWanted] = 0;
	SetPlayerWantedLevel(params[0], 0);
	switch(PlayerInfo[playerid][pFraction])
	{
		case 1: format(string, sizeof(string), "{FF69B4}Офицер {FFFFFF}%s {FF69B4}арестовал {FFFFFF}%s", PlayerInfo[playerid][pName], PlayerInfo[params[0]][pName]);
		case 2: format(string, sizeof(string), "{FF69B4}Агент {FFFFFF}%s {FF69B4}арестовал {FFFFFF}%s", PlayerInfo[playerid][pName], PlayerInfo[params[0]][pName]);
	}
	foreach(new i: Player) { if(PlayerInfo[i][pFraction] == 1 || PlayerInfo[i][pFraction] == 2 && GetPVarInt(i, "DutyStart") == 1) SCM(i, COLOR_INFO, string); }
	format(string, sizeof(string), "{FFFFFF}%s {FF69B4}арестовал вас. Время заключения: {FFFFFF}%d {FF69B4}секунд.", PlayerInfo[playerid][pName], PlayerInfo[params[0]][pTimeWanted]);
	SCM(params[0], COLOR_INFO, string);
	format(query, sizeof(query), "UPDATE `users` SET `pTimeWanted` = '%d', `pWanted` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[playerid][pTimeWanted], PlayerInfo[playerid][pWanted], PlayerInfo[playerid][pID]);
	mysql_tquery(dbHandle, query);
	return true;
}

CMD:follow(playerid,params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2, 3: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }
	if(PlayerInfo[playerid][pFraction] != 1 && PlayerInfo[playerid][pFraction] !=2) return 1;
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /follow [id игрока]");
    if(playerid == params[0]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя применять на самого себя.");
	if(!ProxDetectorS(3.0,playerid,params[0]) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок слишком далеко.");
	if(IsPlayerInAnyVehicle(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок не должен находиться в автомобиле.");
	if(GetPVarInt(params[0], "Cuffed") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок должен быть в наручниках.");
	if(params[0] == GetPVarInt(playerid, "Escorted"))
	{
		SetPVarInt(playerid, "Escorted", -1);
		SetPVarInt(params[0], "OnEscort", -1);
		KillTimer(FollowTimer[params[0]]);
		FollowTimer[params[0]] = INVALID_PLAYER_ID;
		ClearAnimations(playerid);
		TogglePlayerControllable(params[0], 0);
		return 	GameTextForPlayer(params[0],"~g~unfollow", 2000, 3);
	}
	if(GetPVarInt(playerid, "Escorted") != -1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы уже кого-то конвоируете.");
	if(GetPVarInt(params[0], "OnEscort") != -1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок уже под конвоем.");
	Escort[params[0]] = playerid;
	SetPVarInt(playerid, "Escorted", params[0]);
	SetPVarInt(params[0], "OnEscort", playerid);
	FollowTimer[params[0]] = SetTimerEx("EscortedTimer", 250, 1, "i", params[0]);
	GameTextForPlayer(params[0],"~r~follow", 2000, 3);
    return true;
}

CMD:su(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }
	if(PlayerInfo[playerid][pFraction] != 1 && PlayerInfo[playerid][pFraction] !=2) return 1;
    if(sscanf(params, "dds[36]", params[0],params[1],params[2])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /su [id игрока] [Кол-во звёзд] [Причина]");
    if(params[1] > 6 || params[1] < 1 ) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Количество звёзд должно быть от 1 до 6.");
    if(playerid == params[0]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя применять на самого себя.");
    if(IsAGos(params[0]) && GetPVarInt(params[0], "DutyStart") == 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя объявить в розыск гос.служащего.");
    new string[526], query[128];
    if(PlayerInfo[params[0]][pWanted] == 6) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}У человека максимальный уровень розыска.");
	PlayerInfo[params[0]][pWanted] += params[1];
	if(PlayerInfo[params[0]][pWanted] > 6) PlayerInfo[params[0]][pWanted] = 6;
	format(string, sizeof(string), "{FF69B4}[Wanted: {FFFFFF}%d{FF69B4}] [Преступник: {FFFFFF}%s{FF69B4}] [Сообщает: {FFFFFF}%s{FF69B4}] [{FFFFFF}%s{FF69B4}]", PlayerInfo[params[0]][pWanted], PlayerInfo[params[0]][pName], PlayerInfo[playerid][pName], params[2]);
	foreach(new i: Player) { if(PlayerInfo[i][pFraction] == 1 || PlayerInfo[i][pFraction] == 2 && GetPVarInt(i, "DutyStart") == 1) SCM(i, COLOR_INFO, string); }
	format(string, sizeof(string), "{FFFFFF}%s{FF69B4} объявил вас в розыск. Уровень розыска: {FFFFFF}%d{FF69B4}. Причина: {FFFFFF}%s{FF69B4}", PlayerInfo[playerid][pName], params[1], params[2]);
	SCM(params[0], COLOR_INFO, string);
	SetPlayerWantedLevel(params[0], PlayerInfo[params[0]][pWanted]);
	format(query, sizeof(query), "UPDATE `users` SET `pWanted` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[params[0]][pWanted], PlayerInfo[params[0]][pID]);
	mysql_tquery(dbHandle, query);
	return true;
}

CMD:clear(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }
	if(PlayerInfo[playerid][pFraction] != 1 && PlayerInfo[playerid][pFraction] !=2) return 1;
    if(sscanf(params, "ds[36]", params[0],params[1])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /clear [id игрока] [Причина]");
    if(playerid == params[0]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя применять на самого себя.");
    new string[526], query[128];
    PlayerInfo[params[0]][pWanted] = 0;
	format(string, sizeof(string), "{FFFFFF}%s{FF69B4} очистил полицейскую базу данных на имя {FFFFFF}%s{FF69B4}. Причина: {FFFFFF}%s", PlayerInfo[playerid][pName], PlayerInfo[params[0]][pName], params[1]);
	foreach(new i: Player) { if(PlayerInfo[i][pFraction] == 1 || PlayerInfo[i][pFraction] ==2 && GetPVarInt(i, "DutyStart") == 1) SCM(i, COLOR_INFO, string); }
	format(string, sizeof(string), "{FFFFFF}%s{FF69B4} очистил полицейскую базу данных розыска на ваше имя.", PlayerInfo[playerid][pName]);
	SCM(params[0], COLOR_INFO, string);
	SetPlayerWantedLevel(params[0], 0);
	format(query, sizeof(query), "UPDATE `users` SET `pWanted` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[params[0]][pWanted], PlayerInfo[params[0]][pID]);
	mysql_tquery(dbHandle, query);
	return true;
}

CMD:cput(playerid, params[])
{
	new string[128];
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2, 3: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }
	if(PlayerInfo[playerid][pFraction] != 1 && PlayerInfo[playerid][pFraction] !=2) return 1;
    if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /cput [id игрока] [1-3]");
    if(GetVehicleModel(GetPlayerVehicleID(playerid)) != 596 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 490 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 597 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 598) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не в патрульной машине");
    if(playerid == params[0]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя применять на самого себя.");
    if(!ProxDetectorS(3.0,playerid,params[0]) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок слишком далеко.");
    if(PlayerInfo[params[0]][pWanted] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Данный человек на является преступником.");
	if(GetPlayerState(params[0]) != PLAYER_STATE_ONFOOT) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Данный человек находится в автомобиле");
	if(GetPVarInt(params[0], "Cuffed") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок должен быть в наручниках.");
	foreach(new i: Player) { if(IsPlayerInVehicle(i,GetPlayerVehicleID(playerid)) && GetPlayerVehicleSeat(i) == params[1]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Место в машине уже занято"); }
	PutPlayerInVehicle(params[0], GetPlayerVehicleID(playerid), params[1]);
	SetPlayerArmedWeapon(params[0],0);
	format(string,sizeof(string), "{FFFFFF}%s {FF69B4}затащил вас в машину", PlayerInfo[playerid][pName]);
	SCM(params[0], COLOR_INFO,string);
	format(string,sizeof(string), "{FF69B4}Вы затащили в машину преступника {FFFFFF}%s", PlayerInfo[params[0]][pName]);
	SCM(playerid, COLOR_INFO,string);
	return true;
}

CMD:ceject(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }
	if(PlayerInfo[playerid][pFraction] != 1 && PlayerInfo[playerid][pFraction] !=2) return 1;
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /ceject [id игрока]");
    if(playerid == params[0]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя применять на самого себя.");
    if(PlayerInfo[params[0]][pWanted] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Данный человек на является преступником.");
    if(!IsPlayerInRangeOfPoint(playerid, 5.0, 1568.5134,-1694.7603,5.8906)) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы должны быть у участка.");
	if(!ProxDetectorS(3.0,playerid,params[0]) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок слишком далеко.");
    if(GetPlayerVehicleID(playerid) != GetPlayerVehicleID(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Человек не в вашей машине.");
    new string[526];
    format(string, sizeof(string), "{FFFFFF}%s {FF69B4}высадил вас в участок.", PlayerInfo[playerid][pName]);
	SCM(params[0], COLOR_INFO, string);
	format(string, sizeof(string), "Вы высадили {FFFFFF}%s{FF69B4} в участок.", PlayerInfo[params[0]][pName]);
	SCM(playerid, COLOR_INFO, string);
	SetPlayerPos(params[0], 1472.1298,1059.5127,-50.4082);
	SetPlayerFacingAngle(params[0], 178.8058);
	SetCameraBehindPlayer(params[0]);
	SetPlayerInterior(params[0], 1);
	SetPlayerVirtualWorld(params[0], 1);
	return true;
}

CMD:tazer(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }
	if(PlayerInfo[playerid][pFraction] != 1 && PlayerInfo[playerid][pFraction] !=2) return 1;
	switch(GetPVarInt(playerid, "Tazer"))
	{
		case 0: {SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы переключились на {FFFFFF}резиновые пули {FF69B4}на дробовике и пистолете."); SetPVarInt(playerid, "Tazer", 1);}
		case 1: {SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Вы переключились на {FFFFFF}обычные пули {FF69B4}на дробовике и пистолете."); SetPVarInt(playerid, "Tazer", 0);}
	}
	return true;
}

CMD:cuff(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2, 3: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }
	if(PlayerInfo[playerid][pFraction] != 1 && PlayerInfo[playerid][pFraction] !=2 && PlayerInfo[playerid][pFraction] !=3) return 1;
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /cuff [id игрока]");
    if(playerid == params[0]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя применять на самого себя.");
	if(!ProxDetectorS(3.0,playerid,params[0]) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок слишком далеко.");
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы находитесь в транспорте.");
	if(GetPlayerState(params[0]) != PLAYER_STATE_ONFOOT) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок находится в транспорте.");
    if(GetPVarInt(params[0], "Cuffed") == 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Человек уже в наручниках.");
    new string[526];
    format(string, sizeof(string), "{FFFFFF}%s {FF69B4}надел на вас наручники.", PlayerInfo[playerid][pName]);
	SCM(params[0], COLOR_INFO, string);
	format(string, sizeof(string), "{FF69B4}Вы надели наручники на {FFFFFF}%s{FF69B4}.", PlayerInfo[params[0]][pName]);
	SCM(playerid, COLOR_INFO, string);
	SetPlayerAttachedObject(params[0], 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977, -81.700035, 0.891999, 1.000000, 1.168000);
	SetPlayerSpecialAction(params[0],SPECIAL_ACTION_CUFFED);
    TogglePlayerControllable(params[0], 0);
    SetPVarInt(params[0], "Cuffed", 1);
	return true;
}

CMD:uncuff(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2, 3: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }
	if(PlayerInfo[playerid][pFraction] != 1 && PlayerInfo[playerid][pFraction] !=2 && PlayerInfo[playerid][pFraction] !=3) return 1;
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /uncuff [id игрока]");
    if(playerid == params[0]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя применять на самого себя.");
	if(!ProxDetectorS(3.0,playerid,params[0]) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок слишком далеко.");
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы находитесь в транспорте.");
	if(GetPlayerState(params[0]) != PLAYER_STATE_ONFOOT) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Игрок находится в транспорте.");
    if(GetPVarInt(params[0], "Cuffed") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Человек не в наручниках.");
    new string[526];
    format(string, sizeof(string), "{FFFFFF}%s {FF69B4}снял с вас наручники.", PlayerInfo[playerid][pName]);
	SCM(params[0], COLOR_INFO, string);
	format(string, sizeof(string), "Вы сняли наручники с {FFFFFF}%s{FF69B4}.", PlayerInfo[params[0]][pName]);
	SCM(playerid, COLOR_INFO, string);
	RemovePlayerAttachedObject(params[0], 0);
	SetPlayerSpecialAction(params[0],SPECIAL_ACTION_NONE);
    TogglePlayerControllable(params[0], 1);
    SetPVarInt(params[0], "Cuffed", 0);
	return true;
}

CMD:takekeys(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0 )
    {
    	switch(PlayerInfo[playerid][pFraction])
    	{
    		case 1, 2: return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    	}
    }
	if(PlayerInfo[playerid][pFraction] != 1 && PlayerInfo[playerid][pFraction] !=2) return 1;
	if(PlayerInfo[playerid][pCopKey] == 1) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Нельзя брать больше одного ключа.");
	PlayerInfo[playerid][pCopKey] = 1;
	new string[526], query[128];
    format(string, sizeof(string), "{FFFFFF}%s {FF69B4}взял ключи от камеры.", PlayerInfo[playerid][pName]);
	foreach(new i: Player) { if(PlayerInfo[i][pFraction] == 1 && GetPVarInt(i, "DutyStart") == 1) SCM(i, COLOR_INFO, string); }
	format(query, sizeof(query), "UPDATE `users` SET `pCopKey` = '%d' WHERE `pID` = '%d' LIMIT 1", PlayerInfo[playerid][pCopKey], PlayerInfo[playerid][pID]);
	mysql_tquery(dbHandle, query);
	return true;
}

CMD:time(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) ApplyAnimation(playerid, "COP_AMBIENT", "Coplook_watch",4.1,0,0,0,0,0);
	SetPlayerChatBubble(playerid, "взглянул на часы", COLOR_PURPLE, 30.0, 10000);
	new mtext[20], string[128];
	new year, month,day;
	getdate(year, month, day);
	switch(month)
	{
		case 1: mtext = "January";
		case 2: mtext = "February";
		case 3: mtext = "March";
		case 4: mtext = "April";
		case 5: mtext = "May";
		case 6: mtext = "June";
		case 7: mtext = "July";
		case 8: mtext = "August";
		case 9: mtext = "September";
		case 10: mtext = "October";
		case 11: mtext = "November";
		case 12: mtext = "December";
	}
	new hour,minute;
	gettime(hour, minute);
	if(PlayerInfo[playerid][pTimeWanted] > 0) format(string, sizeof(string), "~g~%s~n~~y~%02i %s~n~~g~~w~%02i:%02i~n~~g~Alliant-RP~n~~y~Jail: %02i second", PlayerInfo[playerid][pName], day, mtext, hour, minute, PlayerInfo[playerid][pTimeWanted]);
	else format(string, sizeof(string), "~g~%s~n~~y~%02i %s~n~~g~~w~%02i:%02i~n~~g~Alliant-RP", PlayerInfo[playerid][pName], day, mtext, hour, minute);
	GameTextForPlayer(playerid, string, 5000, 1);
	return true;
}

CMD:carm(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	new string[1200];
	if(!IsPlayerConnected(playerid)) return 1;
	if(PlayerInfo[playerid][pFraction] != 3 || GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) return 1;
	if(!(GetPlayerVehicleID(playerid) >= sangcar[2] && GetPlayerVehicleID(playerid) <= sangcar[7]) && !(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetPVarInt(playerid, "DutyStart") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не на работе.");
	format(string, sizeof(string), "[1] Загрузиться на главном складе\n[2] Разгрузится на главном складе\n[3] Разгрузится в FBI\n[4] Разгрузится в LSPD\n");
	SPD(playerid, DLG_CARM, DSL, "{FFFFFF}Mеню загрузки {F385D5}|| Фракция", string, "Далее", "Отмена");
	return true;
}

CMD:stats(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	new string[1200];
	new frakname[526];
	new nextlevel = PlayerInfo[playerid][pLevel] + 1;
	switch(PlayerInfo[playerid][pFraction])
	{
		case 0: { frakname = "Нет"; }
		case 1: { frakname = "LSPD"; }
		case 2: { frakname = "FBI"; }
		case 3: { frakname = "SANG"; }
		case 4: { frakname = "EMS"; }
		case 5: { frakname = "LCN"; }
		case 6: { frakname = "Yakuza"; }
		case 7: { frakname = "Government"; }
		case 8: { frakname = "CNN"; }
		case 9: { frakname = "The Ballas Gang"; }
		case 10: { frakname = "Los Santos Vagos"; }
		case 11: { frakname = "Russian Mafia"; }
		case 12: { frakname = "Grove Street"; }
		case 13: { frakname = "Varios Los Aztecas"; }
		case 14: { frakname = "The Rifa Gang"; }
		case 15: { frakname = "Hell’s Angels MC"; }
		case 16: { frakname = "Outlaws MC"; }
	}
	format(string, sizeof(string), "Наименование\tЗначение\n\
		Имя и Фамилия:\t%s\nУровень:\t%d\nОчки опыта:\t%d/%d\nДеньги:\t%d\n\
		Деньги в банке:\t%d\nТелефон:\t1\nОрганизация:\t%s\nРанг:\t%d\n\
		Наркотики:\t%d\nМатериалы:\t%d", 
		PlayerInfo[playerid][pName], PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pExp], nextlevel * exptonextlevel, 
		PlayerInfo[playerid][pMoney], PlayerInfo[playerid][pBankMoney], frakname, PlayerInfo[playerid][pRank], PlayerInfo[playerid][pDrugs], PlayerInfo[playerid][pMaterials]);
	SPD(playerid, DLG_STATS, DSTH, "{FFFFFF}Mеню персонажа {4DB8E6}|| Статистика персонажа", string, "Далее", "Отмена");
	return true;
}

CMD:mn(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	SPD(playerid, DLG_MAINMENU, DSL, "{FFFFFF}Mеню персонажа {4DB8E6}|| Меню персонажа", "{FFFFFF}1. Статистика персонажа\n2. Список команд\n3. Личные настройки\n4. Настройки безопасности\n5. Администрациия\n6. Улучшения\n7. Правила сервера\n{ECE15B}8. Дополнительно", "Далее", "Отмена");
	return 1;
}
alias:mn("mm", "menu")

CMD:setspawn(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	SPD(playerid, DLG_SETSPAWN, DSL, "{FFFFFF}Главное меню {94DDEF}|| Место возрождения", "{FFFFFF}[1] Спавн\n[2] Частное имущество", "Выбрать", "Закрыть");
	return 1;
}

CMD:me(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(sscanf(params, "s[100]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /me [сообщение]");
	if(PlayerInfo[playerid][pMute] > 0)
	{
		new string[128]; 
		if(PlayerInfo[playerid][pMute] < 1)
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}секунд!", PlayerInfo[playerid][pMute]);
		}
		else
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}минут!", PlayerInfo[playerid][pMute]/60);
		}
		SCM(playerid, COLOR_INFO, string);
		SetPlayerChatBubble(playerid, "блокировка чата", 0xDDA0DDFF, 15, 2000);
		return 1;
	}
	new string[128];
	format(string, sizeof(string), "%s %s", PlayerInfo[playerid][pName], params[0]);
	ProxDetector(10.0, playerid, string, 0xDDA0DDFF, 0xDDA0DDFF, 0xDDA0DDFF, 0xDDA0DDFF, 0xDDA0DDFF);
	SetPlayerChatBubble(playerid, string, 0xDDA0DDFF, 20.0, 10000);
	return 1;
}

CMD:b(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(sscanf(params, "s[100]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /b [сообщение]");
	if(PlayerInfo[playerid][pMute] > 0)
	{
		new string[128]; 
		if(PlayerInfo[playerid][pMute] < 1)
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}секунд!", PlayerInfo[playerid][pMute]);
		}
		else
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}минут!", PlayerInfo[playerid][pMute]/60);
		}
		SCM(playerid, COLOR_INFO, string);
		SetPlayerChatBubble(playerid, "блокировка чата", 0xDDA0DDFF, 15, 2000);
		return 1;
	}
	new string[128];
	format(string, sizeof(string), "(( %s[%d]: %s ))", PlayerInfo[playerid][pName], playerid, params[0]);
	ProxDetector(30.0, playerid, string, 0xFFFFFFAA, 0xFFFFFFAA, 0xF5F5F5AA, 0xE6E6E6AA,0xB8B8B8AA);
	return 1;
}
alias:b("n")

CMD:do(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(sscanf(params, "s[100]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /do [сообщение]");
	if(PlayerInfo[playerid][pMute] > 0)
	{
		new string[128]; 
		if(PlayerInfo[playerid][pMute] < 1)
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}секунд!", PlayerInfo[playerid][pMute]);
		}
		else
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}минут!", PlayerInfo[playerid][pMute]/60);
		}
		SCM(playerid, COLOR_INFO, string);
		SetPlayerChatBubble(playerid, "блокировка чата", 0xDDA0DDFF, 15, 2000);
		return 1;
	}
	new string[128];
	format(string, sizeof(string), "(( %s[%d] )) {EDB610}%s", PlayerInfo[playerid][pName], playerid, params[0]);
	ProxDetector(30.0, playerid, string, 0xFFFFFFAA, 0xFFFFFFAA, 0xFFFFFFAA, 0xFFFFFFAA,0xFFFFFFAA);
	return 1;
}

CMD:showlic(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /showlic(enses) [ID]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "[Ошибка] {FFFFFF}Игрок не найден!");
	new string[1000], net[28], da[28];
	format(da, sizeof(da), "{00FF00}Есть{FFFFFF}");
	format(net, sizeof(net), "{FF0000}Отсутствует{FFFFFF}");
	format(string, sizeof(string), "Тип лицензии\tНаличие\nВодительское удостоверение:\t[%s]\nЛицензия пилота:\t[%s]\nЛицензия на катера:\t[%s]\nЛицензия рыбака:\t[%s]\nЛицензия на бизнес:\t[%s]\nЛицензия на оружие:\t[%s]", (!PlayerInfo[playerid][pCarLic])?(net) : (da),(!PlayerInfo[playerid][pAirLic])?(net) : (da),(!PlayerInfo[playerid][pBoatLic])?(net) : (da),(!PlayerInfo[playerid][pFishLic])?(net) : (da),(!PlayerInfo[playerid][pBizLic])?(net) : (da),(!PlayerInfo[playerid][pGunLic])?(net) : (da));
	SPD(params[0], DLG_SHOW_LICENS, DSTH, "{C6EDAD}Лицензии", string, "Далее", "Отмена");
	return 1;
}
alias:showlic("showlicenses")

CMD:licenses(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	new string[1000], net[28], da[28];
	format(da, sizeof(da), "{00FF00}Есть{FFFFFF}");
	format(net, sizeof(net), "{FF0000}Отсутствует{FFFFFF}");
	format(string, sizeof(string), "Тип лицензии\tНаличие\nВодительское удостоверение:\t[%s]\nЛицензия пилота:\t[%s]\nЛицензия на катера:\t[%s]\nЛицензия рыбака:\t[%s]\nЛицензия на бизнес:\t[%s]\nЛицензия на оружие:\t[%s]", (!PlayerInfo[playerid][pCarLic])?(net) : (da),(!PlayerInfo[playerid][pAirLic])?(net) : (da),(!PlayerInfo[playerid][pBoatLic])?(net) : (da),(!PlayerInfo[playerid][pFishLic])?(net) : (da),(!PlayerInfo[playerid][pBizLic])?(net) : (da),(!PlayerInfo[playerid][pGunLic])?(net) : (da));
	SPD(playerid, DLG_SHOW_LICENS, DSTH, "{C6EDAD}Лицензии", string, "Далее", "Отмена");
	return 1;
}

CMD:en(playerid, params[])
{
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 481 || GetVehicleModel(GetPlayerVehicleID(playerid)) == 509 || GetVehicleModel(GetPlayerVehicleID(playerid)) == 510) return 1;
    if(GetPlayerVehicleID(playerid) == INVALID_VEHICLE_ID) return true;
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return true;
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(GetPlayerVehicleID(playerid),engine,lights,alarm,doors,bonnet,boot,objective);
    if(engine == 0)
    {
        SetVehicleParamsEx(GetPlayerVehicleID(playerid), true, true, alarm, doors, bonnet, boot, objective);
    }
    else
    {
        SetVehicleParamsEx(GetPlayerVehicleID(playerid), false, false, alarm, doors, bonnet, boot, objective);
    }
    return true;
}

CMD:gov(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(!IsAGos(playerid)) return 1;
	if(GetPVarInt(playerid, "DutyStart") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
	if(sscanf(params, "s[96]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /gov [сообщение]");
	if(PlayerInfo[playerid][pMute] > 0)
	{
		new string[128]; 
		if(PlayerInfo[playerid][pMute] < 1)
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}менее {FF69B4}минуты!");
		}
		else
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}минут!", PlayerInfo[playerid][pMute]/60);
		}
		SCM(playerid, COLOR_INFO, string);
		SetPlayerChatBubble(playerid, "блокировка чата", 0xDDA0DDFF, 15, 2000);
		return 1;
	}
	new string[256];
	format(string, sizeof(string), "[Гос.Новости] %s: %s", PlayerInfo[playerid][pName], params[0]);
	foreach(new i:Player)
	{
		SCM(i,0x4169E1FF, string); 
	}
	return 1;
}

CMD:try(playerid, params[]) {
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(sscanf(params, "s[100]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /try [сообщение]");
	if(PlayerInfo[playerid][pMute] > 0)
	{
		new string[128]; 
		if(PlayerInfo[playerid][pMute] < 1)
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}менее {FF69B4}минуты!");
		}
		else
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}минут!", PlayerInfo[playerid][pMute]/60);
		}
		SCM(playerid, COLOR_INFO, string);
		SetPlayerChatBubble(playerid, "блокировка чата", 0xDDA0DDFF, 15, 2000);
		return 1;
	}
	new string[128], catch[24];
	switch(random(2))
	{
		case 0: { catch = "{B22222}Неудачно"; }
		case 1: { catch = "{3CB371}Удачно"; }
	}
	format(string, sizeof(string), "%s | %s", params[0], catch);
	SetPlayerChatBubble(playerid, string, 0xDDA0DDFF, 20.0, 10000);
	format(string, sizeof(string), "%s %s | %s", PlayerInfo[playerid][pName], params[0], catch);
	ProxDetector(10.0, playerid, string, 0xDDA0DDFF, 0xDDA0DDFF, 0xDDA0DDFF, 0xDDA0DDFF, 0xDDA0DDFF);
	return 1;
}

CMD:d(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(!IsAGos(playerid)) return 1;
	if(GetPVarInt(playerid, "DutyStart") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
	if(sscanf(params, "s[96]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /d [сообщение]");
	if(PlayerInfo[playerid][pMute] > 0)
	{
		new string[128]; 
		if(PlayerInfo[playerid][pMute] < 1)
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}менее {FF69B4}минуты!");
		}
		else
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}минут!", PlayerInfo[playerid][pMute]/60);
		}
		SCM(playerid, COLOR_INFO, string);
		SetPlayerChatBubble(playerid, "блокировка чата", 0xDDA0DDFF, 15, 2000);
		return 1;
	}
	new string[256], frakname[32], rName[32], frak = PlayerInfo[playerid][pFraction]-1;
	switch(PlayerInfo[playerid][pRank])
	{
		case 1: strmid(rName, FracInfo[frak][fRang1], 0, strlen(FracInfo[frak][fRang1]), 32);
		case 2: strmid(rName, FracInfo[frak][fRang2], 0, strlen(FracInfo[frak][fRang2]), 32);
		case 3: strmid(rName, FracInfo[frak][fRang3], 0, strlen(FracInfo[frak][fRang3]), 32);
		case 4: strmid(rName, FracInfo[frak][fRang4], 0, strlen(FracInfo[frak][fRang4]), 32);
		case 5: strmid(rName, FracInfo[frak][fRang5], 0, strlen(FracInfo[frak][fRang5]), 32);
		case 6: strmid(rName, FracInfo[frak][fRang6], 0, strlen(FracInfo[frak][fRang6]), 32);
		case 7: strmid(rName, FracInfo[frak][fRang7], 0, strlen(FracInfo[frak][fRang7]), 32);
		case 8: strmid(rName, FracInfo[frak][fRang8], 0, strlen(FracInfo[frak][fRang8]), 32);
		case 9: strmid(rName, FracInfo[frak][fRang9], 0, strlen(FracInfo[frak][fRang9]), 32);
		case 10: strmid(rName, FracInfo[frak][fRang10], 0, strlen(FracInfo[frak][fRang10]), 32);
		case 11: strmid(rName, FracInfo[frak][fRang11], 0, strlen(FracInfo[frak][fRang11]), 32);
		case 12: strmid(rName, FracInfo[frak][fRang12], 0, strlen(FracInfo[frak][fRang12]), 32);
		case 13: strmid(rName, FracInfo[frak][fRang13], 0, strlen(FracInfo[frak][fRang13]), 32);
		case 14: strmid(rName, FracInfo[frak][fRang14], 0, strlen(FracInfo[frak][fRang14]), 32);
		case 15: strmid(rName, FracInfo[frak][fRang15], 0, strlen(FracInfo[frak][fRang15]), 32);
	}
	switch(PlayerInfo[playerid][pFraction])
	{
		case 1: { frakname = "LSPD"; }
		case 2: { frakname = "FBI"; }
		case 3: { frakname = "SANG"; }
		case 4: { frakname = "EMS"; }
		case 7: { frakname = "GOV"; }
	}
	format(string, sizeof(string), "[%s] %s %s: %s", frakname, rName, PlayerInfo[playerid][pName], params[0]);
	foreach(new i:Player)
	{
		if(IsAGos(playerid)) SCM(i,0xff8282FF, string); 
	}
	return 1;
}

CMD:megaphone(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(PlayerInfo[playerid][pFraction] == 0 && PlayerInfo[playerid][pAdmin] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная команда.");
	if(GetPVarInt(playerid, "DutyStart") == 0 && GetPVarInt(playerid, "aLogged") == 0 && PlayerInfo[playerid][pAdmin] != 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
	if(sscanf(params, "s[96]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /megaphone(/m) [текст]");
	if(PlayerInfo[playerid][pMute] > 0)
	{
		new string[128]; 
		if(PlayerInfo[playerid][pMute] < 1)
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}менее {FF69B4}минуты!");
		}
		else
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}минут!", PlayerInfo[playerid][pMute]/60);
		}
		SCM(playerid, COLOR_INFO, string);
		SetPlayerChatBubble(playerid, "блокировка чата", 0xDDA0DDFF, 15, 2000);
		return 1;
	}
	new string[256], frakname[32];
	switch(PlayerInfo[playerid][pFraction])
	{
		case 1: { frakname = "Полицейский"; }
		case 2: { frakname = "Агент"; }
		case 3: { frakname = "Солдат"; }
		case 7: { frakname = "Конгрессмен"; }
	}
	if(PlayerInfo[playerid][pFraction] == 7 && PlayerInfo[playerid][pRank] < 4) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная команда.");
	if(PlayerInfo[playerid][pAdmin] > 0) frakname = "Сенатор";
	format(string, sizeof(string), "{FFFF00}%s %s[%d]: %s", frakname, PlayerInfo[playerid][pName], playerid, params[0]);
	SetPlayerChatBubble(playerid, string, 0xFFFF00FF, 20.0, 10000);
	ProxDetector(40.0, playerid, string, 0xFFFF00FF, 0xFFFF00FF, 0xFFFF00FF, 0xFFFF00FF, 0xFFFF00FF);
	return 1;
}
alias:megaphone("m")

CMD:r(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(PlayerInfo[playerid][pFraction] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не состоите в организации.");
	if(GetPVarInt(playerid, "DutyStart") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
	if(sscanf(params, "s[96]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /r(f) [текст]");
	if(PlayerInfo[playerid][pMute] > 0)
	{
		new string[128]; 
		if(PlayerInfo[playerid][pMute] < 1)
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}менее {FF69B4}минуты!");
		}
		else
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}минут!", PlayerInfo[playerid][pMute]/60);
		}
		SCM(playerid, COLOR_INFO, string);
		SetPlayerChatBubble(playerid, "блокировка чата", 0xDDA0DDFF, 15, 2000);
		return 1;
	}
	new string[256], rName[32], frak = PlayerInfo[playerid][pFraction]-1;
	switch(PlayerInfo[playerid][pRank])
	{
		case 1: strmid(rName, FracInfo[frak][fRang1], 0, strlen(FracInfo[frak][fRang1]), 32);
		case 2: strmid(rName, FracInfo[frak][fRang2], 0, strlen(FracInfo[frak][fRang2]), 32);
		case 3: strmid(rName, FracInfo[frak][fRang3], 0, strlen(FracInfo[frak][fRang3]), 32);
		case 4: strmid(rName, FracInfo[frak][fRang4], 0, strlen(FracInfo[frak][fRang4]), 32);
		case 5: strmid(rName, FracInfo[frak][fRang5], 0, strlen(FracInfo[frak][fRang5]), 32);
		case 6: strmid(rName, FracInfo[frak][fRang6], 0, strlen(FracInfo[frak][fRang6]), 32);
		case 7: strmid(rName, FracInfo[frak][fRang7], 0, strlen(FracInfo[frak][fRang7]), 32);
		case 8: strmid(rName, FracInfo[frak][fRang8], 0, strlen(FracInfo[frak][fRang8]), 32);
		case 9: strmid(rName, FracInfo[frak][fRang9], 0, strlen(FracInfo[frak][fRang9]), 32);
		case 10: strmid(rName, FracInfo[frak][fRang10], 0, strlen(FracInfo[frak][fRang10]), 32);
		case 11: strmid(rName, FracInfo[frak][fRang11], 0, strlen(FracInfo[frak][fRang11]), 32);
		case 12: strmid(rName, FracInfo[frak][fRang12], 0, strlen(FracInfo[frak][fRang12]), 32);
		case 13: strmid(rName, FracInfo[frak][fRang13], 0, strlen(FracInfo[frak][fRang13]), 32);
		case 14: strmid(rName, FracInfo[frak][fRang14], 0, strlen(FracInfo[frak][fRang14]), 32);
		case 15: strmid(rName, FracInfo[frak][fRang15], 0, strlen(FracInfo[frak][fRang15]), 32);
	}
	format(string, sizeof(string), "%s %s[%d]: %s", rName, PlayerInfo[playerid][pName], playerid, params[0]);
	foreach(new i:Player) 
	{
		if(PlayerInfo[i][pFraction] == PlayerInfo[playerid][pFraction]) SCM(i, 0x9370DBFF, string); 
	}
	return 1;
}
alias:r("f")

CMD:loadmats(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(PlayerInfo[playerid][pFraction] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не состоите в организации.");
	if(GetPVarInt(playerid, "DutyStart") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
	if(submarinestat == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Погрузку можно начать только по прибытию подлодки.");
	new Float:mX, Float:mY, Float:mZ, string[128];
	VehicleInfo[GetPlayerVehicleID(playerid)][vLoading] = 1;
	GetVehiclePos(GetPlayerVehicleID(playerid), mX, mY, mZ);
	GetXYInBackOfPlayer(playerid, mX, mY, 5.0);
	Farmcar_pickup[GetPlayerVehicleID(playerid)] = CreateDynamicPickup(19197,23,mX,mY,mZ+0.3, -1);
	format(string, sizeof(string), "Ресурсов в машине:\n%d/10000", VehicleInfo[GetPlayerVehicleID(playerid)][vMats]);
	unloadzone3dtext[GetPlayerVehicleID(playerid)] = Create3DTextLabel(string, COLOR_DARK_BLUE, mX,mY,mZ+0.3, 15.0, 0, 0);
	SetVehicleParamsEx(GetPlayerVehicleID(playerid),false,false,false,false,false,false,false);
	RemovePlayerFromVehicle(playerid);
	return 1;
}

CMD:matsorder(playerid, params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
    if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
    if(PlayerInfo[playerid][pFraction] != 3) return 1;
    if(GetPVarInt(playerid, "DutyStart") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
    if(PlayerInfo[playerid][pRank] < FracInfo[PlayerInfo[playerid][pFraction]-1][fInvRang]) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная команда.");
    new fraction = PlayerInfo[playerid][pFraction];
    new string[526], hour, minute, seconds;
	gettime(hour, minute);
	if(hour==0) hour = 24;
	seconds = (hour * 3600) + (minute * 60);
    if(FracInfo[fraction-1][fMaterials]>50000) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Экстренный заказ материалов разрешён только если склад ниже 50.000");
	if(seconds - time_call<3600) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Экстренный вызов разрешён не раньше чем через час с последней поставки.");
    if(morder == 1 || submarinestat != 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Подлодка уже на месте.");
	format(string, sizeof(string), "[Информация] {FF69B4}Вы экстренно заказали поставку материалов. Грузовая подлодка уже направляется в порт.");
	SCM(playerid, COLOR_INFO, string);
	submarine = CreateObject(9958, 2318.906494, -2880.927734, -11.957567, 0.000000, 0.000000, 130.800125);
	submarinestat = 1;
	morder = 1;
	SOStime = minute;
	//if(SOStime>=50) SOStime -=60;
	foreach(new i: Player)
	{ 
		if(PlayerInfo[i][pFraction] == 3 && GetPVarInt(i, "DutyStart") == 1) 
		{
			SCM(i, COLOR_INFO, "[Информация] {FF69B4}В порт Лос-Сантоса скоро прибудет грузовая подлодка. Подготовьтесь.");
		}
	}
	MoveObject(submarine, 2751.048583, -2586.376220, 5.262427+0.0001, 50.0, 0.000000, 0.000000, -270.000000);
	return true;
}

CMD:rb(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(PlayerInfo[playerid][pFraction] == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не состоите в организации.");
	if(GetPVarInt(playerid, "DutyStart") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
	if(sscanf(params, "s[96]", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /r(f) [текст]");
	if(PlayerInfo[playerid][pMute] > 0)
	{
		new string[128]; 
		if(PlayerInfo[playerid][pMute] < 1)
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}менее {FF69B4}минуты!");
		}
		else
		{
			format(string, sizeof(string), "[Информация] {FF69B4}Ваш чат заблокирован. Время до разблокировки: {CC0000}%d {FF69B4}минут!", PlayerInfo[playerid][pMute]/60);
		}
		SCM(playerid, COLOR_INFO, string);
		SetPlayerChatBubble(playerid, "блокировка чата", 0xDDA0DDFF, 15, 2000);
		return 1;
	}
	new string[256], rName[32], frak = PlayerInfo[playerid][pFraction]-1;
	switch(PlayerInfo[playerid][pRank])
	{
		case 1: strmid(rName, FracInfo[frak][fRang1], 0, strlen(FracInfo[frak][fRang1]), 32);
		case 2: strmid(rName, FracInfo[frak][fRang2], 0, strlen(FracInfo[frak][fRang2]), 32);
		case 3: strmid(rName, FracInfo[frak][fRang3], 0, strlen(FracInfo[frak][fRang3]), 32);
		case 4: strmid(rName, FracInfo[frak][fRang4], 0, strlen(FracInfo[frak][fRang4]), 32);
		case 5: strmid(rName, FracInfo[frak][fRang5], 0, strlen(FracInfo[frak][fRang5]), 32);
		case 6: strmid(rName, FracInfo[frak][fRang6], 0, strlen(FracInfo[frak][fRang6]), 32);
		case 7: strmid(rName, FracInfo[frak][fRang7], 0, strlen(FracInfo[frak][fRang7]), 32);
		case 8: strmid(rName, FracInfo[frak][fRang8], 0, strlen(FracInfo[frak][fRang8]), 32);
		case 9: strmid(rName, FracInfo[frak][fRang9], 0, strlen(FracInfo[frak][fRang9]), 32);
		case 10: strmid(rName, FracInfo[frak][fRang10], 0, strlen(FracInfo[frak][fRang10]), 32);
		case 11: strmid(rName, FracInfo[frak][fRang11], 0, strlen(FracInfo[frak][fRang11]), 32);
		case 12: strmid(rName, FracInfo[frak][fRang12], 0, strlen(FracInfo[frak][fRang12]), 32);
		case 13: strmid(rName, FracInfo[frak][fRang13], 0, strlen(FracInfo[frak][fRang13]), 32);
		case 14: strmid(rName, FracInfo[frak][fRang14], 0, strlen(FracInfo[frak][fRang14]), 32);
		case 15: strmid(rName, FracInfo[frak][fRang15], 0, strlen(FracInfo[frak][fRang15]), 32);
	}
	format(string, sizeof(string), "(( %s %s[%d]: %s ))", rName, PlayerInfo[playerid][pName], playerid, params[0]);
	foreach(new i:Player) 
	{
		if(PlayerInfo[i][pFraction] == PlayerInfo[playerid][pFraction]) SCM(i, 0x9370DBFF, string);
	}
	return 1;
}
alias:rb("fb")
//============================ [ Команды для GOV ] ==============================
CMD:manager(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(PlayerInfo[playerid][pFraction] != 7) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вам недоступна данная команда.");
	if(GetPVarInt(playerid, "DutyStart") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не начали рабочий день.");
	new dialogname[128];
	format(dialogname, sizeof(dialogname), "{FFFFFF}Панель управления {F385D5}|| Штат");
	SPD(playerid, DLG_MANAGER_MENU, DSL, dialogname, "1. Выделить средства организации\n2. Настроить зарплату на подработках\n3. Налоговые операции\n4. Главы организаций\n5. Полная информация", "Далее", "Отмена");
	return 1;
}
alias:manager("man")
//=========================== [ Команды для теста ] =============================
CMD:getci(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1 && PlayerInfo[playerid][pAdmin] >= 2) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(GetPlayerVehicleID(playerid),engine,lights,alarm,doors,bonnet,boot,objective);
	new string[256];
	format(string, sizeof(string), "{DAEA80}[Информация] {FF69B4}Статус: engine:{D90000} %s{FFFFFF}, lights:{D90000} %s{FFFFFF}, doors:{D90000} %s{FFFFFF}", (!engine)? ("0"): ("1"), (!lights)?("0"): ("1"), (!doors)?("0"): ("1"));
	SCM(playerid, COLOR_INFO, string);
	return 1;
}

CMD:fre(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /fre id");
	TogglePlayerControllable(params[0], false);
	return 1;
}
CMD:unfre(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_INFO, "[Информация] {FF69B4}Используйте: /fre id");
	TogglePlayerControllable(params[0], true);
	return 1;
}



CMD:getint(playerid, params[])
{
	if(GetPVarInt(playerid, "pLogged") == 0) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы на сервере! Пройдите авторизацию.");
	if(AdminInfo[playerid][aLogged] != 1 && PlayerInfo[playerid][pAdmin] >= 2) return SCM(playerid, COLOR_ERROR, "[Ошибка] {9AAAAB}Вы не авторизированы в админ-панели!");
	new interiorid = GetPlayerInterior(playerid);
	new string[128];
	format(string, sizeof(string), "[Информация] {DAEA80}Ваш интерьер на данный момент - ID: %d", interiorid);
	SCM(playerid, COLOR_INFO, string);
	return 1;
}

CMD:carj(playerid, params[])
{
	VehicleInfo[GetPlayerVehicleID(playerid)][vMaterials] = 10000;
	return 1;
}

CMD:sub1(playerid, params[])
{
	//SetObjectPos(submarine, 2563.651367, -2959.630126, -11.197566);
	//SetObjectRot(submarine, 0.000000, 0.000000, -180.000000);
	submarinestat = 1;
	MoveObject(submarine, 2751.048583, -2586.376220, 5.262427+0.0001, 50.0, 0.000000, 0.000000, -270.000000);
	return 1;
}

CMD:sub2(playerid, params[])
{
	submarinestat = 3;
	MoveObject(submarine, 3252.048583, -2586.376220, -14.737571, 50.0);
	return 1;
}

CMD:sub3(playerid, params[])
{
	new Float:fX, Float:fY, Float:fZ; 
	GetObjectPos(submarine, fX, fY, fZ);
	printf("Object X: %d Y: %d Z: %d.", fX, fY, fZ);
	return 1;
}
