package com.model.warfrontModel
{
	import com.model.Model;
	import com.model.prototype.PrototypeModel;
	import com.service.server.incoming.leaderboard.WarfrontUpdateResponse;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class WarfrontModel extends Model
	{
		private var _battles:Vector.<WarfrontVO>;
		private var _i:int;
		private var _lookup:Dictionary;
		private var _prototypeModel:PrototypeModel
		private var _updateSignal:Signal;

		public function WarfrontModel()
		{
			_battles = new Vector.<WarfrontVO>;
			_lookup = new Dictionary();
			_updateSignal = new Signal(Vector.<WarfrontVO>, Vector.<String>);
		}

		public function importData( response:WarfrontUpdateResponse ):void
		{
			var battle:WarfrontVO;
			//add new warfronts
			for (_i = 0; _i < response.warfronts.length; _i++)
			{
				battle = ObjectPool.get(WarfrontVO);
				battle.importData(response.warfronts[_i]);
				_battles.unshift(battle);
				_lookup[battle.id] = battle;
			}

			//remove warfronts
			var index:int;
			for (_i = 0; _i < response.removed.length; _i++)
			{
				battle = _lookup[response.removed[_i]];
				if (battle)
				{
					index = _battles.indexOf(battle);
					if (index > -1)
					{
						_battles.splice(index, 1);
						ObjectPool.give(battle);
					}
					delete _lookup[battle.id];
				}
			}

			_updateSignal.dispatch(_battles, response.removed);
		}

		public function addUpdateListener( listener:Function ):void  { _updateSignal.add(listener); }
		public function removeUpdateListener( listener:Function ):void  { _updateSignal.remove(listener); }

		public function get battles():Vector.<WarfrontVO>  { return _battles; }

		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
	}
}
