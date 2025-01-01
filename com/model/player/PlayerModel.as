package com.model.player
{
	import com.model.Model;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class PlayerModel extends Model
	{
		private var _players:Dictionary;

		public var onPlayerAdded:Signal = new Signal(PlayerVO);

		public function PlayerModel()
		{
			_players = new Dictionary();
		}

		public function addPlayer( player:PlayerVO ):void
		{
			_players[player.id] = player;

			onPlayerAdded.dispatch(player);
		}

		public function addPlayers( v:Vector.<PlayerVO> ):void
		{
			var len:uint = v.length;
			var currentPlayer:PlayerVO;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPlayer = v[i];
				_players[currentPlayer.id] = currentPlayer;
				onPlayerAdded.dispatch(currentPlayer);
			}
		}

		public function getPlayer( id:String ):PlayerVO
		{
			if(id == "")
				return null;
			
			if (id in _players)
				return _players[id];

			return null;
		}

		public function getPlayers():Dictionary
		{
			return _players;
		}

		public function removePlayer( id:String ):void
		{
			if (id in _players)
			{
				ObjectPool.give(_players[id]);
				delete _players[id];
			}
		}

		public function removeAllPlayers():void
		{
			for (var player:String in _players)
			{
				ObjectPool.give(_players[player]);
				delete _players[player];
			}
		}

		public function destroy():void
		{
			removeAllPlayers();
		}
	}
}
