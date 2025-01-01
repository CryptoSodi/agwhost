package com.model.mission
{
	import com.enum.FactionEnum;
	import com.enum.MissionEnum;
	import com.model.Model;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.incoming.data.MissionData;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class MissionModel extends Model
	{
		private var _mission:MissionVO;
		private var _missionLookup:Dictionary    = new Dictionary(true);
		private var _missions:Vector.<MissionVO> = new Vector.<MissionVO>;
		private var _missionUpdated:Signal       = new Signal();
		private var _prototypeModel:PrototypeModel;

		public function importMissionData( mission:MissionData ):void
		{
			if (mission.prototype == null)
				return;
			if (!_missionLookup.hasOwnProperty(mission.id))
			{
				var missionVO:MissionVO = ObjectPool.get(MissionVO);
				missionVO.init(mission.id);
				_missionLookup[mission.id] = missionVO;
				_missions.push(missionVO);
				if (mission.category == MissionEnum.STORY)
				{
					_mission = missionVO;
					_missionUpdated.dispatch();
				}
			}
			_missionLookup[mission.id].importData(mission);
		}

		public function missionAccepted():void
		{
			_mission.accepted = true;
		}

		public function missionComplete():void
		{
			_mission.progress = _mission.progressRequired;
		}

		public function missionRewardAccepted():void
		{
			_mission.rewardAccepted = true;
			_missionUpdated.dispatch();
		}

		public function getStoryMission( chapterID:int, missionID:int ):MissionVO
		{
			var faction:String   = "IGA";
			if (CurrentUser.faction != FactionEnum.IGA)
				faction = (CurrentUser.faction == FactionEnum.SOVEREIGNTY) ? "SOV" : "TYR";
			var id:String        = faction + "_Ch" + chapterID + "_M" + missionID;
			var proto:IPrototype = _prototypeModel.getMissionPrototye(id);
			if (proto)
			{
				var missionData:MissionData = ObjectPool.get(MissionData);
				missionData.prototype = proto;
				var missionVO:MissionVO     = ObjectPool.get(MissionVO);
				missionVO.importData(missionData);
				ObjectPool.give(missionData);
				return missionVO;
			}
			return null;
		}

		public function getMissionByCategory( category:String ):MissionVO
		{
			for (var i:int = 0; i < _missions.length; i++)
			{
				if (_missions[i].category == category)
					return _missions[i];
			}
			return null;
		}

		public function getMissionByID( id:String ):MissionVO
		{
			if (_missionLookup.hasOwnProperty(id))
				return _missionLookup[id];
			return null;
		}

		public function get currentMission():MissionVO  { return _mission; }

		public function addListenerToUpdateMission( listener:Function ):void  { _missionUpdated.add(listener); }
		public function removeListenerToUpdateMission( listener:Function ):void  { _missionUpdated.remove(listener); }

		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
	}
}


