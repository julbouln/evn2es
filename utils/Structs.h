/* https://github.com/nickshanks/ResKnife/blob/master/NovaTools/Structs.h */
/* Nova Resource structures */

typedef struct Rect {
	short top;
	short left;
	short bottom;
	short right;
};

typedef struct NovaControlBits
{
	// 10,000 bits for ncbs, could be made faster by aligning to word boundries? (using longs) but would require padding
	char bits[1250];			// access bit 777 thus:	bits[777/8] >> (777 % 8)) & 0x01
								//					or:	bits[777/8] & (0x01 << (777 % 8))
};

typedef struct BoomRec
{
	short FrameAdvance;		// 100 = normal speed, less is slower, higher faster
	short SoundIndex;		// 0-63 index, mapping to 300-363 resID, -1 == no sound
	short GraphicIndex;		// 0-63 index, mapping to 400-463 resID
};

typedef struct CharRec
{
	long startCash;
	short startShipType;
	short startSystem[4];
	short startGovt[4];
	short startStatus[4];
	short startKills;
	short introPictID[4];
	short introPictDelay[4];
	short introTextID;
	char OnStart[256];
	short Flags;
	short startDay;
	short startMonth;
	short startYear;
	char Prefix[16];
	char Suffix[16];
	short UnusedA[8];
};

typedef struct ColrRec
{
	long ButtonUp;
	long ButtonDown;
	long ButtonGrey;
	char MenuFont[64];
	short MenuFontSize;
	long MenuColor1;
	long MenuColor2;
	long GridBright;
	long GridDim;
	//	p2c: Structs.p, line 696: Warning: Symbol 'RECT' is not defined [221]
	struct Rect ProgArea;
	long ProgBright;
	long ProgDim;
	long ProgOutline;

	short Button1x;
	short Button1y;
	short Button2x;
	short Button2y;
	short Button3x;
	short Button3y;
	short Button4x;
	short Button4y;
	short Button5x;
	short Button5y;
	short Button6x;
	short Button6y;

	long FloatingMap;
	long ListText;
	long ListBkgnd;
	long ListHilite;
	long EscortHilite;

	char ButtonFont[64];
	short ButtonFontSz;

	short LogoX;
	short LogoY;

	short RolloverX;
	short RolloverY;

	short Slide1x;
	short Slide1y;
	short Slide2x;
	short Slide2y;
	short Slide3x;
	short Slide3y;

};

typedef struct CronRec
{
	short FirstDay;
	short FirstMonth;
	short FirstYear;
	short LastDay;
	short LastMonth;
	short LastYear;
	short Random;
	short Duration;
	short PreHoldoff;
	short PostHoldoff;
	short IndNewsStr;
	short Flags;
	char EnableOn[254+1];
	char OnStart[254+1];
	char OnEnd[255+1];
//	char cdata[766];
	long Contributes0;
	long Contributes1;
	long Require0;
	long Require1;
	short NewsGovt[4];
	short GovtNewsString[4];
};

typedef struct DescRec
{
	char Description[1];
};

typedef struct DescCodaRec
{
	short Graphic;
	char Movie[32];
	short Flags;
};

typedef struct DeqtRec
{
	short Flags;
};

typedef struct DudeRec
{
	short AIType;
	short Govt;
	short Booty;
	short InfoTypes;
	short ShipTypes[16];
	short Probs[16];
	short UnusedA[8];
};

typedef struct FletRec
{
	short LeadShipType;
	short EscortShipType[4];
	short EscortMin[4];
	short EscortMax[4];
	short Govt;
	short LinkSyst;
	char ActivateOn[256];
	short Quote;
	short Flags;
	short UnusedA[8];
};

typedef struct IntfRec
{
	long BrightText;
	long DimText;
	struct Rect RadarArea;
	long BrightRadar;
	long DimRadar;
	struct Rect ShieldArea;
	long Shield;
	struct Rect ArmorArea;
	long Armor;
	struct Rect FuelArea;
	long FuelFull;
	long FuelPartial;
	struct Rect NavArea;
	struct Rect WeapArea;
	struct Rect TargArea;
	struct Rect CargoArea;
	char StatusFont[64];
	short StatFontSize;
	short SubtitleSize;
	short StatusBkgnd;
};

typedef struct JunkRec
{
	short SoldAt[8];
	short BoughtAt[8];
	short BasePrice;
	short Flags;
	short ScanMask;
	char LCName[63+1];
	char Abbrev[63+1];
	char BuyOn[254+1];
	char SellOn[254+1];
//	char cdata[638];
};

typedef struct GovtRec
{
	short VoiceType;
	short Flags;
	short Flags2;
	short ScanFine;
	short CrimeTol;
	short SmugPenalty;
	short DisabPenalty;
	short BoardPenalty;
	short KillPenalty;
	short ShootPenalty;
	short InitialRec;
	short MaxOdds;
	short Classes[4];
	short Allies[4];
	short Enemies[4];
	short SkillMult;
	short ScanMask;
	char CommName[16];
	char TargetCode[16];
	long Require0;
	long Require1;
	short InhJam[4];
	char MediumName[64];
	long color;
	long ShipColor;
	short intf;
	short NewsPict;
	short UnusedA[8];
};


typedef struct MisnRec
{
	short AvailStel;
	short Unused1;
	short AvailLoc;
	short AvailRecord;
	short AvailRating;
	short AvailRandom;
	short TravelStel;
	short ReturnStel;
	short CargoType;
	short CargoQty;
	short PickupMode;
	short DropoffMode;
	short ScanGovt;
	short Unused2;
	long PayVal;
	short ShipCount;
	short ShipSyst;
	short ShipDude;
	short ShipGoal;
	short ShipBehav;
	short ShipNameID;
	short ShipStart;
	short CompGovt;
	short CompReward;
	short ShipSubTitle;
	short BriefText;
	short QuickBrief;
	short LoadCargText;
	short DropCargText;
	short CompText;
	short FailText;
	short TimeLimit;
	short CanAbort;
	short ShipDoneText;
	short Unused3;
	short AuxShipCount;
	short AuxShipDude;
	short AuxShipSyst;
	short Unused4;
	short Flags;
	short Flags2;
	short Unused6;
	short Unused7;
	short RefuseText;
	short AvailShipType;
	char AvailBits[254+1];
	char OnAccept[254+1];
	char OnRefuse[254+1];
	char OnSuccess[254+1];
	char OnFailure[254+1];
	char OnAbort[254+1];

//	char cdata[1530];

	long Require0;
	long Require1;
	short DatePostInc;
	char OnShipDone[254+1];
	char AcceptButton[31+1];
	char RefuseButton[31+1];
//	char cdata2[320];
	short DispWeight;

	short UnusedA[8];
};

typedef struct NebuRec
{
	short XPos;
	short YPos;
	short XSize;
	short YSize;
	char ActiveOn[254+1];
	char OnExplore[254+1];
//	char cdata[510];
	short UnusedA[8];
};

typedef struct OopsRec
{
	short Stellar;
	short Commodity;
	short PriceDelta;
	short Duration;
	short Freq;
	char ActivateOn[256];
	short UnusedA[8];
};

typedef struct OutfRec
{
	short DispWeight;
	short Mass;
	short TechLevel;
	short ModType;
	short ModVal;
	short Max;
	short Flags;
	long Cost;
	short ModType2;
	short ModVal2;
	short ModType3;
	short ModVal3;
	short ModType4;
	short ModVal4;
	long Contributes0;
	long Contributes1;
	long Require0;
	long Require1;
	char Availability[254+1];
	char OnPurchase[254+1];
	char OnSell[254+1];
	char ShortName[63+1];
	char LCName[63+1];
	char LCPlural[64+1];
//	char cdata[958];
	short ItemClass;
	short ScanMask;
	short BuyRandom;
	short RequireGovt;
	short UnusedA[8];
};

typedef struct PersRec
{
	short LinkSyst;
	short Govt;
	short AIType;
	short Aggress;
	short Coward;
	short ShipType;
	short WeapType[4];
	short WeapCount[4];
	short AmmoLoad[4];
	long Credits;
	short ShieldMod;
	short HailPict;
	short CommQuote;
	short HailQuote;
	short LinkMission;
	short Flags;
	char ActivateOn[256];
	short GrantClass;
	short GrantCount;
	short GrantProb;
	char SubTitle[64];
	long ShipColor;
	short Flags2;
	short UnusedA[8];
};

typedef struct RankRec
{
	short Weight;
	short Govt;
	short PriceMod;
	long Salary;
	long SalaryCap;
	long Contributes0;
	long Contributes1;
	short flags;
	char ConvName[63+1];
	char ShortName[63+1];
//	char cdata[128];
};


typedef struct RoidRec
{
	short Strength;
	short spinRate;
	short yieldType;
	short yieldQty;
	short partCount;
	long partColor;
	short fragType[2];
	short fragCount;
	short ExplodeType;
	short Mass;
	short UnusedA[8];
};

typedef struct RLEPixelData
{
	// 'rl�#' resource
	short width;	// pixel width (max for all frames)
	short height;	// pixel height (max for all frames)
	short depth;	// bit depth (8/16/32)
	short palette;	// color table 'clut' ID (0 for default)
	short nframes;	// number of frames in this resource
	short reserved1;
	short reserved2;
	short reserved3;
	char tokens[1];	// the RLE token data (variable size array)
};

typedef struct ShanRec
{
	short BaseImageID;
	short BaseMaskID;
	short BaseSetCount;
	short BaseXSize;
	short BaseYSize;
	short BaseTransp;

	short AltImageID;
	short AltMaskID;
	short AltSetCount;
	short AltXSize;
	short AltYSize;

	short GlowImageID;
	short GlowMaskID;
	short GlowXSize;
	short GlowYSize;

	short LightImageID;
	short LightMaskID;
	short LightXSize;
	short LightYSize;

	short WeapImageID;
	short WeapMaskID;
	short WeapXSize;
	short WeapYSize;

	short Flags;

	short AnimDelay;
	short WeapDecay;
	short FramesPer;
	short BlinkMode;
	short BlinkA;
	short BlinkB;
	short BlinkC;
	short BlinkD;

	short ShieldImgID;
	short ShieldMaskID;
	short ShieldXSize;
	short ShieldYSize;

	short GunPosX[4];
	short GunPosY[4];
	short TurretPosX[4];
	short TurretPosY[4];
	short GuidedPosX[4];
	short GuidedPosY[4];
	short BeamPosX[4];
	short BeamPosY[4];

	short UpCompressX;
	short UpCompressY;
	short DnCompressX;
	short DnCompressY;

	short GunPosZ[4];
	short TurretPosZ[4];
	short GuidedPosZ[4];
	short BeamPosZ[4];

	short UnusedA[8];

};

typedef struct ShipRec
{
	short holds;
	short Shield;
	short Accel;
	short Speed;
	short Maneuver;
	short Fuel;
	short freeMass;
	short Armor;
	short ShieldRegen;
	short WType[4];
	short WCount[4];
	short Ammo[4];
	short MaxGun;
	short MaxTur;
	short TechLevel;
	long Cost;
	short DeathDelay;
	short ArmorRech;
	short Explode1;
	short Explode2;
	short DispWeight;
	short Mass;
	short Length;
	short InherentAI;
	short Crew;
	short Strength;
	short InherentGovt;
	short Flags;
	short PodCount;
	short DefaultItems[4];
	short ItemCount[4];
	short FuelRegen;
	short SkillVar;
	short Flags2;
	long Contributes0;
	long Contributes1;
	char Availability[254+1];
	char AppearOn[254+1];
	char OnPurchase[255+1];

//	char cdata1[766];

	short Deionize;
	short IonizeMax;
	short KeyCarried;
	short DefaultItems2[4];
	short ItemCount2[4];
	long Require0;
	long Require1;

	short BuyRandom;
	short HireRandom;

	short unusedBlock[34];
	
	char OnCapture[254+1];
	char OnRetire[254+1];
	char ShortName[63+1];
	char CommName[31+1];
	char LongName[127+1];
	char MovieFile[31+1];

//	char cdata2[766];

	short WType2[4];
	short WCount2[4];
	short Ammo2[4];
	
	char SubTitle[63+1];
//	char cdata3[64];
	short Flags3;
	short UpgradeTo;
	long EscUpgrdCost;
	long EscSellValue;
	short EscortType;
	short UnusedA[8];
};

typedef struct SpinRec
{
	short SpritesID;
	short MasksID;
	short xSize;
	short ySize;
	short nx;
	short ny;
};

typedef struct SpobRec
{
	short xPos;
	short yPos;
	short spobType;
	long Flags;
	short Tribute;
	short TechLevel;
	short SpecialTech1;
	short SpecialTech2;
	short SpecialTech3;
	short Govt;
	short MinCoolness;
	short CustPicID;
	short CustSndID;
	short DefDude;
	short DefCount;
	short Flags2;
	short AnimDelay;
	short Frame0Bias;
	short HyperLink[8];
	char OnDominate[254+1];
	char OnRelease[254+1];
//	char cdata[510];
	long Fee;
	short Gravity;
	short Weapon;
	long Strength;
	short DeadType;
	short DeadTime;
	short ExplodType;
	char OnDestroy [254+1];
	char OnRegen [254+1];
//	char cdata2[510];
	short SpecialTech4;
	short SpecialTech5;
	short SpecialTech6;
	short SpecialTech7;
	short SpecialTech8;
	short UnusedA[8];
};

typedef struct SystRec
{
	short xPos;
	short yPos;
	short con[16];
	short nav[16];
	short DudeTypes[8];
	short Probs[8];
	short AvgShips;
	short Govt;
	short Message;
	short Asteroids;
	short Interference;
	short Person[8];
	short PersonProb[8];
	long BkgndColor;
	short Murk;
	short AstTypes;
	char Visiblility[256];
	short ReinfFleet;
	short ReinfTime;
	short ReinfIntrval;
	short UnusedA[8];
};

typedef struct WeapRec
{
	short Reload;
	short Count;
	short MassDmg;
	short EnergyDmg;
	short Guidance;
	short Speed;
	short AmmoType;
	short Graphic;
	short Inaccuracy;
	short Sound;
	short Impact;
	short ExplodType;
	short ProxRadius;
	short BlastRadius;
	short Flags;
	short Seeker;
	short SmokeSet;
	short Decay;
	short Particles;
	short PartVel;
	short PartLifeMin;
	short PartLifeMax;
	long PartColor;
	short BeamLength;
	short BeamWidth;
	short Falloff;
	long BeamColor;
	long CoronaColor;
	short SubCount;
	short SubType;
	short SubTheta;
	short SubLimit;
	short ProxSafety;
	short Flags2;
	short Ionization;
	short HitParticles;
	short HitPartLife;
	short HitPartVel;
	long HitPartColor;
	short Recoil;
	short ExitType;
	short BurstCount;
	short BurstReload;
	short JamVuln1;
	short JamVuln2;
	short JamVuln3;
	short JamVuln4;
	short Flags3;
	short Durability;
	short GuidedTurn;
	short MaxAmmo;
	short LiDensity;
	short LiAmplitude;
	long IonizeColor;
	short UnusedA[8];
};

typedef struct YearRec
{
	short Day;
	short Month;
	short Year;
	char Prefix[16];
	char Suffix[15];
};
