package com.game.entity.factory
{
	import com.controller.sound.SoundController;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.prototype.PrototypeModel;

	import flash.events.IEventDispatcher;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.shared.ObjectPool;
	import org.swiftsuspenders.Injector;

	public class BaseFactory
	{
		protected var _assetModel:AssetModel;
		protected var _eventDispatcher:IEventDispatcher;
		protected var _game:Game;
		protected var _injector:Injector;
		protected var _prototypeModel:PrototypeModel;
		protected var _soundController:SoundController;

		protected function createEntity():Entity
		{
			return ObjectPool.get(Entity);
		}

		protected function addEntity( entity:Entity ):void
		{
			_game.addEntity(entity);
		}

		protected function playSound( assetVO:AssetVO ):void
		{
		if (assetVO && assetVO.audio)
				_soundController.playSound(assetVO.audio, assetVO.volume, 0, assetVO.loops);
		}

		public function destroyEntity( entity:Entity ):void
		{
			_game.removeEntity(entity);
			ObjectPool.give(entity);
		}

		[Inject]
		public function set assetModel( value:AssetModel ):void  { _assetModel = value; }
		[Inject]
		public function set eventDispatcher( value:IEventDispatcher ):void  { _eventDispatcher = value; }
		[Inject]
		public function set game( value:Game ):void  { _game = value; }
		[Inject]
		public function set inject( value:Injector ):void  { _injector = value; }
		[Inject]
		public function set prototypeModel( value:PrototypeModel ):void  { _prototypeModel = value; }
		[Inject]
		public function set soundController( value:SoundController ):void  { _soundController = value; }
	}
}
