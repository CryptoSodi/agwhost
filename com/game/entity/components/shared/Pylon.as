package com.game.entity.components.shared
{
	import com.game.entity.nodes.starbase.BuildingNode;

	import org.ash.core.Entity;

	public class Pylon
	{
		private static const FIELDS:Object = {};

		public var baseX:int;
		public var baseY:int;
		public var bottom:Entity;
		public var color:uint;
		public var node:BuildingNode;

		private var _bottomConnection:BuildingNode;
		private var _leftConnection:BuildingNode;
		private var _rightConnection:BuildingNode;
		private var _topConnection:BuildingNode;

		public function addConnection( connection:BuildingNode ):Object
		{
			var temp:BuildingNode;
			if (connection.$pylon.baseX == baseX)
			{
				if (connection.$pylon.baseY < baseY)
				{
					if (!_topConnection)
					{
						_topConnection = connection;
						return craftReturn(connection, null);
					} else if (connection.building.buildingVO.baseY > _topConnection.building.buildingVO.baseY || connection == _topConnection)
					{
						if (connection != _topConnection)
						{
							temp = _topConnection;
							removeConnection(_topConnection);
						}
						_topConnection = connection;
						return craftReturn(connection, temp);
					}
				} else
				{
					if (!_bottomConnection)
					{
						_bottomConnection = connection;
						return craftReturn(connection, null);
					} else if (_bottomConnection && connection.building.buildingVO.baseY < _bottomConnection.building.buildingVO.baseY || connection == _bottomConnection)
					{
						if (connection != _bottomConnection)
						{
							temp = _bottomConnection;
							removeConnection(_bottomConnection);
						}
						_bottomConnection = connection;
						return craftReturn(connection, temp);
					}
				}
			} else if (connection.$pylon.baseY == baseY)
			{
				if (connection.$pylon.baseX < baseX)
				{
					if (!_leftConnection)
					{
						_leftConnection = connection
						return craftReturn(connection, null);
					} else if (_leftConnection && connection.building.buildingVO.baseX > _leftConnection.building.buildingVO.baseX || connection == _leftConnection)
					{
						if (connection != _leftConnection)
						{
							temp = _leftConnection;
							removeConnection(_leftConnection);
						}
						_leftConnection = connection;
						return craftReturn(connection, temp);
					}
				} else
				{
					if (!_rightConnection)
					{
						_rightConnection = connection;
						return craftReturn(connection, null);
					} else if (_rightConnection && connection.building.buildingVO.baseX < _rightConnection.building.buildingVO.baseX || connection == _rightConnection)
					{
						if (connection != _rightConnection)
						{
							temp = _rightConnection;
							removeConnection(_rightConnection);
						}
						_rightConnection = connection;
						return craftReturn(connection, temp);
					}
				}
			}
			return null;
		}

		public function removeConnection( connection:BuildingNode, notifyConnection:Boolean = true ):void
		{
			if (_bottomConnection == connection)
				_bottomConnection = null;
			if (_leftConnection == connection)
				_leftConnection = null;
			if (_rightConnection == connection)
				_rightConnection = null;
			if (_topConnection == connection)
				_topConnection = null;
			if (notifyConnection)
				connection.$pylon.removeConnection(node, false);
		}

		public function clearConnections():void
		{
			_bottomConnection = _leftConnection = _rightConnection = _topConnection = null;
		}

		public function craftKey( bnode:BuildingNode ):String
		{
			if (bnode == null)
				return null;
			return "Forcefield" + ((node.entity.id < bnode.entity.id) ? node.entity.id + "-" + bnode.entity.id : bnode.entity.id + "-" + node.entity.id);
		}

		private function craftReturn( added:BuildingNode, removed:BuildingNode ):Object
		{
			FIELDS.added = craftKey(added);
			FIELDS.removed = craftKey(removed);
			return FIELDS;
		}

		public function get bottomConnection():BuildingNode  { return _bottomConnection; }
		public function get bottomWallKey():String  { return craftKey(_bottomConnection); }

		public function get leftConnection():BuildingNode  { return _leftConnection; }
		public function get leftWallKey():String  { return craftKey(_leftConnection); }

		public function get rightConnection():BuildingNode  { return _rightConnection; }
		public function get rightWallKey():String  { return craftKey(_rightConnection); }

		public function get topConnection():BuildingNode  { return _topConnection; }
		public function get topWallKey():String  { return craftKey(_topConnection); }

		public function destroy():void
		{
			node = null;
			_bottomConnection = null;
			_leftConnection = null;
			_rightConnection = null;
			_topConnection = null;
		}
	}
}
