package com.util
{
	import com.enum.FactionEnum;
	import com.game.entity.components.sector.Mission;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.EventComponent;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;

	import flash.geom.ColorTransform;

	import org.ash.core.Entity;

	/**
	 * Class that contains a number of useful static functions that wrap color transform & glows
	 * to indicate entity relationships. Primarily intended for use by the minimap.
	 *
	 * @author tkeating
	 *
	 */
	public class AllegianceUtil
	{
		public static var instance:AllegianceUtil;

		public static var COLOR_IGA_BASE:uint          = 0x4477FF;
		public static var COLOR_IGA_RANGE:uint         = 0xCCCCCC;//= 0x65B1E1;
		public static var COLOR_IGA_OWNER:uint         = 0x88DDFF;
		public static var COLOR_IMPERIUM_BASE:uint     = 0xC0FF27;
		public static var COLOR_IMPERIUM_RANGE:uint    = 0xCCCCCC;//= 0x7DB96F;
		public static var COLOR_IMPERIUM_OWNER:uint    = 0x00ff00;
		public static var COLOR_TYRANNAR_BASE:uint     = 0xFF5444;
		public static var COLOR_TYRANNAR_RANGE:uint    = 0xCCCCCC;//0xEB4545;
		public static var COLOR_TYRANNAR_OWNER:uint    = 0xFF9888;
		public static var COLOR_SOVEREIGNTY_BASE:uint  = 0x8833FF;
		public static var COLOR_SOVEREIGNTY_RANGE:uint = 0xCCCCCC;//= 0xE56BDD;
		public static var COLOR_SOVEREIGNTY_OWNER:uint = 0xCC77FF;
		public static var COLOR_NPC_ENEMY:uint         = 0xFFFFFF;
		public static var COLOR_NPC_FREINDLY:uint      = 0x444444;
		public static var COLOR_NPC_MISSION:uint       = 0xFFEE88;
		public static var COLOR_NPC_EVENT:uint         = 0xDDCC66;
		public static var COLOR_DEFAULT:uint           = 0x00CC00;
		public static var COLOR_DERELICT:uint          = 0xFFEE44;

		public static var CT_IGA_BASE:ColorTransform;
		public static var CT_IGA_OWNER:ColorTransform;
		public static var CT_TYRANNAR_BASE:ColorTransform;
		public static var CT_TYRANNAR_OWNER:ColorTransform;
		public static var CT_SOVEREIGNTY_BASE:ColorTransform;
		public static var CT_SOVEREIGNTY_OWNER:ColorTransform;
		public static var CT_IMPERIUM_BASE:ColorTransform;
		public static var CT_NPC_ENEMY:ColorTransform;
		public static var CT_NPC_FREINDLY:ColorTransform;
		public static var CT_NPC_MISSION:ColorTransform;
		public static var CT_NPC_EVENT:ColorTransform;
		public static var CT_DEFAULT:ColorTransform;
		public static var CT_DERELICT:ColorTransform;

		private static var CT_BRIGHTNESS:Number        = 0.025;

		private var _playerModel:PlayerModel;

		public function AllegianceUtil()
		{
			instance = this;

			CT_IGA_BASE = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_IGA_BASE >> 16) & 0xff, (COLOR_IGA_BASE >> 8) & 0xff, COLOR_IGA_BASE & 0xff);
			CT_IGA_OWNER = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_IGA_OWNER >> 16) & 0xff, (COLOR_IGA_OWNER >> 8) & 0xff, COLOR_IGA_OWNER & 0xff);
			CT_TYRANNAR_BASE = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_TYRANNAR_BASE >> 16) & 0xff, (COLOR_TYRANNAR_BASE >> 8) & 0xff, COLOR_TYRANNAR_BASE & 0xff);
			CT_TYRANNAR_OWNER = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_TYRANNAR_OWNER >> 16) & 0xff, (COLOR_TYRANNAR_OWNER >> 8) & 0xff, COLOR_TYRANNAR_OWNER & 0xff);
			CT_SOVEREIGNTY_BASE = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_SOVEREIGNTY_BASE >> 16) & 0xff, (COLOR_SOVEREIGNTY_BASE >> 8) & 0xff, COLOR_SOVEREIGNTY_BASE &
													 0xff);
			CT_SOVEREIGNTY_OWNER = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_SOVEREIGNTY_OWNER >> 16) & 0xff, (COLOR_SOVEREIGNTY_OWNER >> 8) & 0xff, COLOR_SOVEREIGNTY_OWNER &
													  0xff);
			CT_IMPERIUM_BASE = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_IMPERIUM_BASE >> 16) & 0xff, (COLOR_IMPERIUM_BASE >> 8) & 0xff, COLOR_IMPERIUM_BASE &
												  0xff);
			CT_NPC_ENEMY = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_NPC_ENEMY >> 16) & 0xff, (COLOR_NPC_ENEMY >> 8) & 0xff, COLOR_NPC_ENEMY & 0xff);
			CT_NPC_FREINDLY = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_NPC_FREINDLY >> 16) & 0xff, (COLOR_NPC_FREINDLY >> 8) & 0xff, COLOR_NPC_FREINDLY & 0xff);
			CT_NPC_MISSION = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_NPC_MISSION >> 16) & 0xff, (COLOR_NPC_MISSION >> 8) & 0xff, COLOR_NPC_MISSION & 0xff);
			CT_NPC_EVENT = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_NPC_EVENT >> 16) & 0xff, (COLOR_NPC_EVENT >> 8) & 0xff, COLOR_NPC_EVENT & 0xff);
			CT_DEFAULT = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_DEFAULT >> 16) & 0xff, (COLOR_DEFAULT >> 8) & 0xff, COLOR_DEFAULT & 0xff);
			CT_DERELICT = new ColorTransform(CT_BRIGHTNESS, CT_BRIGHTNESS, CT_BRIGHTNESS, 1, (COLOR_DERELICT >> 16) & 0xff, (COLOR_DERELICT >> 8) & 0xff, COLOR_DERELICT & 0xff);
		}

		public function getEntityColor( entity:Entity, useOwnerColors:Boolean = true ):uint
		{
			var entityDetail:Detail  = entity.get(Detail)
			var entityOwner:PlayerVO = _playerModel.getPlayer(entityDetail.ownerID);
			if (!entityOwner)
				return COLOR_DERELICT;

			if (!entityOwner.isNPC)
			{
				if (entityDetail.ownerID == CurrentUser.id && useOwnerColors)
				{
					if (entityOwner.faction == FactionEnum.TYRANNAR)
						return COLOR_TYRANNAR_OWNER;
					else if (entityOwner.faction == FactionEnum.IGA)
						return COLOR_IGA_OWNER;
					else if (entityOwner.faction == FactionEnum.SOVEREIGNTY)
						return COLOR_SOVEREIGNTY_OWNER;
					else if (entityOwner.faction == FactionEnum.IMPERIUM)
						return COLOR_IMPERIUM_OWNER;
					else
						return COLOR_DEFAULT;
				} else
				{
					if (entityOwner.faction == FactionEnum.TYRANNAR)
						return COLOR_TYRANNAR_BASE;
					else if (entityOwner.faction == FactionEnum.IGA)
						return COLOR_IGA_BASE;
					else if (entityOwner.faction == FactionEnum.SOVEREIGNTY)
						return COLOR_SOVEREIGNTY_BASE;
					else if (entityOwner.faction == FactionEnum.IMPERIUM)
						return COLOR_IMPERIUM_BASE;
					else
						return COLOR_DEFAULT;
				}
			} else
			{
				if (entity.has(Mission))
					return COLOR_NPC_MISSION;
				if (entity.has(EventComponent))
					return COLOR_NPC_EVENT;
				if (entityOwner.faction == CurrentUser.faction)
					return COLOR_NPC_FREINDLY;
				else
					return COLOR_NPC_ENEMY;
			}
		}

		public function getEntityColorTransform( entity:Entity, useOwnerColors:Boolean = true ):ColorTransform
		{
			var entityDetail:Detail  = entity.get(Detail)
			var entityOwner:PlayerVO = _playerModel.getPlayer(entityDetail.ownerID);
			if (!entityOwner)
				return CT_DERELICT;

			if (!entityOwner.isNPC)
			{
				if (entityDetail.ownerID == CurrentUser.id && useOwnerColors)
				{
					if (entityOwner.faction == FactionEnum.TYRANNAR)
						return CT_TYRANNAR_OWNER;
					else if (entityOwner.faction == FactionEnum.IGA)
						return CT_IGA_OWNER;
					else if (entityOwner.faction == FactionEnum.SOVEREIGNTY)
						return CT_SOVEREIGNTY_OWNER;
					else
						return CT_DEFAULT;
				} else
				{
					if (entityOwner.faction == FactionEnum.TYRANNAR)
						return (useOwnerColors) ? CT_TYRANNAR_OWNER : CT_TYRANNAR_BASE;
					else if (entityOwner.faction == FactionEnum.IGA)
						return (useOwnerColors) ? CT_IGA_OWNER : CT_IGA_BASE;
					else if (entityOwner.faction == FactionEnum.SOVEREIGNTY)
						return (useOwnerColors) ? CT_SOVEREIGNTY_OWNER : CT_SOVEREIGNTY_BASE;
					else
						return CT_DEFAULT;
				}
			} else
			{
				if (entity.has(Mission))
					return CT_NPC_MISSION;
				if (entity.has(EventComponent) && entityOwner.faction != FactionEnum.IMPERIUM)
					return CT_NPC_EVENT;
				if (entityOwner.faction == CurrentUser.faction)
					return CT_NPC_FREINDLY;
				else if (entityOwner.faction == FactionEnum.IMPERIUM)
					return CT_IMPERIUM_BASE;
				else
					return CT_NPC_ENEMY;
			}
		}

		public function getPlayerColor():uint
		{
			if (CurrentUser.faction == FactionEnum.TYRANNAR)
				return COLOR_TYRANNAR_BASE;
			else if (CurrentUser.faction == FactionEnum.IGA)
				return COLOR_IGA_BASE;
			else if (CurrentUser.faction == FactionEnum.SOVEREIGNTY)
				return COLOR_SOVEREIGNTY_BASE;
			else if (CurrentUser.faction == FactionEnum.IMPERIUM)
				return COLOR_IMPERIUM_BASE;
			else
				return COLOR_DEFAULT;
		}
		public function getPlayerBattleColor():uint
		{
			if (CurrentUser.battleFaction == FactionEnum.TYRANNAR)
				return COLOR_TYRANNAR_BASE;
			else if (CurrentUser.battleFaction == FactionEnum.IGA)
				return COLOR_IGA_BASE;
			else if (CurrentUser.battleFaction == FactionEnum.SOVEREIGNTY)
				return COLOR_SOVEREIGNTY_BASE;
			else if (CurrentUser.battleFaction == FactionEnum.IMPERIUM)
				return COLOR_IMPERIUM_BASE;
			else
				return COLOR_DEFAULT;
		}

		public function getFactionColor( faction:String ):uint
		{
			if (faction == FactionEnum.TYRANNAR)
				return COLOR_TYRANNAR_BASE;
			else if (faction == FactionEnum.IGA)
				return COLOR_IGA_BASE;
			else if (faction == FactionEnum.SOVEREIGNTY)
				return COLOR_SOVEREIGNTY_BASE;
			else if (faction == FactionEnum.IMPERIUM)
				return COLOR_IMPERIUM_BASE;
			else
				return COLOR_DEFAULT;
		}
		
		public function getFactionRangeColor( faction:String ):uint
		{
			if (faction == FactionEnum.TYRANNAR)
				return COLOR_TYRANNAR_RANGE;
			else if (faction == FactionEnum.IGA)
				return COLOR_IGA_RANGE;
			else if (faction == FactionEnum.SOVEREIGNTY)
				return COLOR_SOVEREIGNTY_RANGE;
			else if (faction == FactionEnum.IMPERIUM)
				return COLOR_IMPERIUM_RANGE;
			else
				return COLOR_DEFAULT;
		}

		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
	}
}
