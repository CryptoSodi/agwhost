package com.presenter.shared
{
	import com.controller.GameController;
	import com.event.TransitionEvent;
	import com.game.entity.systems.shared.background.BackgroundSystem;
	import com.game.entity.systems.shared.grid.GridSystem;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.scene.SceneModel;
	import com.presenter.ImperiumPresenter;
	
	import com.model.battle.BattleModel;
	
	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.osflash.signals.Signal;

	public class GamePresenter extends ImperiumPresenter implements IGamePresenter
	{
		protected var _assetModel:AssetModel;
		protected var _cleanupSignal:Signal;
		protected var _game:Game;
		protected var _gameController:GameController;
		protected var _prototypeModel:PrototypeModel;
		protected var _sceneModel:SceneModel;

		override public function init():void
		{
			super.init();
			removeContextListeners();
			_cleanupSignal = new Signal();
		}

		public function confirmReady():void
		{
			dispatch(new TransitionEvent(TransitionEvent.TRANSITION_COMPLETE));
			_fteController.ready = true;
			if (_fteController.progressStepOnStateChange)
				_fteController.nextStep();
		}

		public function cleanup():void
		{
			//send out a cleanup signal to notify view to destroy themselves.
			//once all views are finished being destroyed the presenter will automatically be destroyed as well
			if (_cleanupSignal)
				_cleanupSignal.dispatch();
		}

		public function addCleanupListener( callback:Function ):void  { _cleanupSignal.addOnce(callback); }
		public function removeCleanupListener( callback:Function ):void  { _cleanupSignal.remove(callback); }

		public function loadBackground(battleModel:BattleModel, useModelData:Boolean = false):void
		{
			var bgSystem:BackgroundSystem = BackgroundSystem(_game.getSystem(BackgroundSystem));
			bgSystem.addReadySignal(confirmReady);
			bgSystem.buildBackground(battleModel, useModelData);
			var gridSystem:GridSystem     = GridSystem(_game.getSystem(GridSystem));
			gridSystem.onBackgroundReady();
		}

		public function getEntity( id:String ):Entity  { return _game.getEntity(id); }

		public function getAssetVO( prototype:IPrototype ):AssetVO
		{
			var assetName:String = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;
			return _assetModel.getEntityData(assetName);
		}

		public function getAssetVOByName( name:String ):AssetVO
		{
			return _assetModel.getEntityData(name);
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set game( v:Game ):void  { _game = v; }
		[Inject]
		public function set gameController( v:GameController ):void  { _gameController = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set sceneModel( v:SceneModel ):void  { _sceneModel = v; }

		override public function destroy():void
		{
			super.destroy();
			_cleanupSignal.removeAll();
			_cleanupSignal = null;

			_assetModel = null;
			_sceneModel = null;
			_game = null;
			_gameController = null;
			_prototypeModel = null;
		}
	}
}
