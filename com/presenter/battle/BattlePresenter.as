package com.presenter.battle
{
	import com.controller.ServerController;
	import com.controller.transaction.TransactionController;
	import com.enum.CategoryEnum;
	import com.event.SectorEvent;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.game.entity.components.battle.Modules;
	import com.game.entity.components.shared.Position;
	import com.game.entity.systems.battle.VitalsSystem;
	import com.game.entity.systems.interact.BattleInteractSystem;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleEntityVO;
	import com.model.battle.BattleModel;
	import com.model.battle.BattleRerollVO;
	import com.model.blueprint.BlueprintModel;
	import com.model.blueprint.BlueprintVO;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.model.sector.SectorModel;
	import com.presenter.shared.GamePresenter;
	import com.service.ExternalInterfaceAPI;

	import flash.geom.Point;
	import flash.utils.Dictionary;

	import org.ash.core.Entity;
	import org.osflash.signals.Signal;

	public class BattlePresenter extends GamePresenter implements IBattlePresenter
	{
		private var _abilitySignal:Signal;
		private var _battleModel:BattleModel;
		private var _blueprintModel:BlueprintModel;
		private var _transactionController:TransactionController;
		private var _fleetModel:FleetModel;
		private var _playerModel:PlayerModel;
		private var _sectorModel:SectorModel;
		private var _serverController:ServerController;
		private var _startSignal:Signal;
		private var _system:BattleInteractSystem;

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_abilitySignal = new Signal(Entity);
			participants.sort(orderParticipants);
			_startSignal = new Signal();
			_system = BattleInteractSystem(_game.getSystem(BattleInteractSystem));
			_system.presenter = this;
		}

		public function getModuleAssetVo( entity:Entity, idx:Number ):AssetVO
		{
			var modules:Modules             = entity.get(Modules);
			var abilityPrototype:IPrototype = modules.activatedModules[idx];
			return _assetModel.getEntityData(abilityPrototype.uiAsset);
		}

		public function loadSmallImage( portraitName:String, callback:Function ):void
		{
			if (portraitName != '')
			{
				var avatarVO:AssetVO = AssetVO(AssetModel.instance.getFromCache(portraitName));
				if (avatarVO)
					AssetModel.instance.getFromCache('assets/' + avatarVO.smallImage, callback);
			}
		}

		public function loadMediumImage( portraitName:String, callback:Function ):void
		{
			if (portraitName != '')
			{
				var avatarVO:AssetVO = AssetVO(AssetModel.instance.getFromCache(portraitName));
				if (avatarVO)
					AssetModel.instance.getFromCache('assets/' + avatarVO.mediumImage, callback);
			}
		}

		public function addStartListener( callback:Function ):void  { _startSignal.addOnce(callback); }
		public function removeStartListener( callback:Function ):void  { _startSignal.remove(callback); }

		public function onBattleStarted():void
		{
			if (_startSignal)
				_startSignal.dispatch();
			//update the fte if it is running
			if (_fteController && _fteController.running)
				_fteController.nextStep();
		}
		public function onBattleEnded():void
		{
			_startSignal.dispatch();
			if (BattleInteractSystem(_system).inFTE && _fteController.running)
			{
				_system.inFTE = false;
				_fteController.nextStep();
			}
		}

		public function sharePvPVictory():void
		{
			var enemyVO:PlayerVO = getPlayer(participants[1]);
			ExternalInterfaceAPI.shareVictory(enemyVO, isBaseCombat);
		}

		public function getSelectedFleet():FleetVO
		{
			return _fleetModel.getFleet(_sectorModel.focusFleetID);
		}

		public function getShip( shipId:String ):Entity
		{
			return _game.getEntity(shipId);
		}

		public function selectOwnedShipById( shipId:String ):void
		{
			_system.selectOwnedShipByID(shipId);
		}

		public function loadIcon( url:String, callback:Function ):void
		{
			_assetModel.getFromCache("assets/" + url, callback);
		}

		public function loadMiniIconFromEntityData( type:String, callback:Function ):void
		{
			var _currentAssetVO:AssetVO = _assetModel.getEntityData(type);
			var icon:String             = _currentAssetVO.iconImage;
			loadIcon(icon, callback);
		}

		public function addListenerVitalPercentUpdates( listener:Function ):void
		{
			var vitalsSystem:VitalsSystem = VitalsSystem(_game.getSystem(VitalsSystem));
			if (vitalsSystem)
				vitalsSystem.onHealthChanged.add(listener);
		}

		public function removeListenerVitalPercentUpdates( listener:Function ):void
		{
			var vitalsSystem:VitalsSystem = VitalsSystem(_game.getSystem(VitalsSystem));
			if (vitalsSystem)
				vitalsSystem.onHealthChanged.remove(listener);
		}

		public function getHealthPercentByPlayerID( id:String ):Number
		{
			var vitalsSystem:VitalsSystem = VitalsSystem(_game.getSystem(VitalsSystem));
			if (vitalsSystem)
				return vitalsSystem.getTotalHealthByPlayer(id);

			return 1;
		}

		public function getPlayer( id:String ):PlayerVO  { return _playerModel.getPlayer(id); }

		public function getParticipantRating( id:String ):int  { return _battleModel.getParticipantRating(id); }

		public function getBattleEntitiesByPlayer( id:String, category:String = CategoryEnum.SHIP ):Vector.<BattleEntityVO>  { return _battleModel.getBattleEntitiesByPlayer(id, category); }

		public function exitCombat():void
		{
			if (_battleModel.oldGameState == StateEvent.GAME_SECTOR)
			{
				var fleetID:String  = null;
				var sectorEvent:SectorEvent;
				var sectorID:String = _battleModel.oldSector;
				if (_sectorModel.focusFleetID != null)
				{
					var fleetVO:FleetVO = _fleetModel.getFleet(_sectorModel.focusFleetID);
					if (fleetVO.sector == _battleModel.oldSector)
						fleetID = _sectorModel.focusFleetID;
					else if (fleetVO.sector == _sectorModel.sectorID)
					{
						fleetID = _sectorModel.focusFleetID;
						sectorID = _sectorModel.sectorID;
					}
				}
				if (fleetID != null)
					sectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, sectorID, fleetID);
				else
					sectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, sectorID, null, _battleModel.focusLocation.x, _battleModel.focusLocation.y);

				dispatch(sectorEvent);
			} else
			{
				var event:StarbaseEvent = new StarbaseEvent(StarbaseEvent.ENTER_BASE);
				dispatch(event);
			}
		}

		override public function loadBackground(battleModel:BattleModel, useModelData:Boolean = false):void
		{
			super.loadBackground(battleModel, useModelData);
			//position the view on the ships
			var battleEntities:Vector.<BattleEntityVO> = _battleModel.battleEntities;
			var entity:Entity;
			var position:Position;
			if (_battleModel.isBaseCombat)
			{
				for (var i:int = 0; i < battleEntities.length; i++)
				{
					if (battleEntities[i].category == CategoryEnum.SHIP && battleEntities[i].healthPercent > 0)
					{
						entity = _game.getEntity(battleEntities[i].id);
						if (entity)
						{
							position = entity.get(Position);
							_system.jumpToLocation(position.x, position.y);
						}
					}
				}
			} else if (_battleModel.timeRemaining != 0)
			{
				//battle has already started. find the ships in the battle and center on them
				var p1:Point;
				var p2:Point;
				var lastOwner:String;
				for (i = 0; i < battleEntities.length; i++)
				{
					entity = _game.getEntity(battleEntities[i]);
					if (entity)
					{
						position = entity.get(Position);
						if (!p1)
						{
							p1 = new Point(position.x, position.y);
							lastOwner = battleEntities[i].ownerID;
						} else if (battleEntities[i].ownerID != lastOwner)
							p2 = new Point(position.x, position.y);
					}
				}
				//we found two ships owned by different players
				if (p1 && p2)
				{
					var p3:Point = Point.interpolate(p1, p2, 0.5);
					_system.jumpToLocation(p3.x, p3.y);
				}
				//only found one ship
				else if (p1)
					_system.jumpToLocation(p1.x, p1.y);
			}
		}

		private function orderParticipants( participantA:String, participantB:String ):int
		{
			var playerA:PlayerVO = getPlayer(participantA);
			var playerB:PlayerVO = getPlayer(participantB);

			if (playerA.id == CurrentUser.id || (playerA.faction == CurrentUser.battleFaction && !playerA.isNPC))
				return -1;
			if (playerB.id == CurrentUser.id || (playerB.faction == CurrentUser.battleFaction && !playerB.isNPC))
				return 1;
			if (!playerA.isNPC && playerB.isNPC)
				return -1;
			if (!playerB.isNPC && playerA.isNPC)
				return 1;
			return 0;
		}

		public function isPlayerBaseOwner( playerID:String ):Boolean  { return _battleModel.baseOwnerID == playerID; }
		public function isInstancedMission():Boolean {return _battleModel.isInstancedMission;}
		public function isPlayerInCombat( playerID:String ):Boolean  { return (_battleModel.participants) ? _battleModel.participants.indexOf(playerID) > -1 : false; }

		public function getConstantPrototypeValueByName( name:String ):Number
		{
			var proto:IPrototype = _prototypeModel.getConstantPrototypeByName(name);
			return proto.getValue('value');
		}

		public function getStoreItemPrototypeByName( name:String ):IPrototype
		{
			var proto:IPrototype = _prototypeModel.getStoreItemPrototypeByName(name);
			return proto;
		}

		public function getBlueprintHardCurrencyCost( blueprint:BlueprintVO, partsPurchased:Number ):Number
		{
			return _transactionController.getBlueprintHardCurrencyCost(blueprint, partsPurchased);
		}

		public function purchaseBlueprint( blueprint:BlueprintVO, partsPurchased:Number ):void
		{
			_transactionController.buyBlueprintTransaction(blueprint, partsPurchased);
		}
		public function completeBlueprintResearch( blueprint:BlueprintVO):void  
		{ 
			_transactionController.completeBlueprintResearchTransaction(blueprint); 
		}

		public function purchaseReroll( battleKey:String ):void
		{
			_transactionController.starbasePurchaseReroll(battleKey);
		}

		public function purchaseDeepScan( battleKey:String ):void
		{
			_transactionController.starbasePurchaseDeepScan(battleKey);
		}

		public function addRerollFromRerollCallback( callback:Function ):void
		{
			_battleModel.onRerollUpdated.add(callback);
		}

		public function removeRerollFromRerollCallback( callback:Function ):void
		{
			_battleModel.onRerollUpdated.remove(callback);
		}

		public function addRerollFromScanCallback( callback:Function ):void
		{
			_battleModel.onRerollUpdated.add(callback);
		}

		public function removeRerollFromScanCallback( callback:Function ):void
		{
			_battleModel.onRerollUpdated.remove(callback);
		}

		public function removeRerollFromAvailable( battleID:String ):void
		{
			_battleModel.removeRerollByID(battleID);
		}

		public function getBlueprintByID( id:String ):BlueprintVO
		{
			return _blueprintModel.getBlueprintByID(id);
		}

		public function removeBlueprintByName( name:String ):void
		{
			_blueprintModel.removeBlueprintByName(name);
		}

		public function getBlueprintByName( name:String ):BlueprintVO  { return _blueprintModel.getBlueprintByName(name); }

		public function getAvailableRerollById( id:String ):BattleRerollVO  { return _battleModel.getAvailableRerollByID(id); }

		public function addListenerBattleEntitiesControlledUpdated( listener:Function ):void
		{
			if (_system)
				_system.onControlledUpdated.add(listener);
		}

		public function getBlueprintPrototypeByName( v:String ):IPrototype
		{
			return _prototypeModel.getBlueprintPrototype(v);
		}

		public function getResearchPrototypeByName( v:String ):IPrototype
		{
			return _prototypeModel.getResearchPrototypeByName(v);
		}

		public function getShipPrototype( v:String ):IPrototype
		{
			return _prototypeModel.getShipPrototype(v);
		}

		public function getModulePrototypeByName( v:String ):IPrototype
		{
			var iproto:IPrototype = _prototypeModel.getShipPrototype(v);
			if (!iproto)
				iproto = _prototypeModel.getWeaponPrototype(v);
			return iproto;
		}

		public function getConstantPrototypeByName( name:String ):IPrototype
		{
			return _prototypeModel.getConstantPrototypeByName(name);
		}

		public function getBEDialogueByFaction( faction:String, result:String = 'Victory' ):Vector.<IPrototype>
		{
			return _prototypeModel.getBEDialogueByFaction(faction, result);
		}

		public function getUnavailableReroll( id:String ):int
		{
			return _battleModel.getUnavailableRerollByID(id);
		}

		public function get battleRunning():Boolean  { return !_battleModel.finished; }
		public function get battleTimeRemaining():Number  { return _battleModel.timeRemaining; }
		public function get doesPlayerOwnBase():Boolean  { return true; }
		public function get isBaseCombat():Boolean  { return _battleModel.isBaseCombat; }
		public function get isFTERunning():Boolean  { return _fteController.running; }
		public function get ownedBlueprints():Dictionary  { return _blueprintModel.ownedBlueprints; }
		public function get participants():Vector.<String>  { return _battleModel.participants; }
		public function get players():Dictionary  { return _playerModel.getPlayers(); }
		public function get showRetreat():Boolean  { return isBaseCombat && !isPlayerBaseOwner(CurrentUser.id) && isPlayerInCombat(CurrentUser.id) && !getPlayer(_battleModel.baseOwnerID).isNPC; }
		
		public function get isPVEBattle():Boolean
		{
			var vo:PlayerVO;
			for (var i:int = 0; i < _battleModel.participants.length; i++)
			{
				vo = getPlayer(_battleModel.participants[i]);
				if (vo.isNPC)
					return true;
			}
			return false;
		}

		public function getPrototypeByName( proto:String ):IPrototype
		{
			var iproto:IPrototype = _prototypeModel.getBuildingPrototype(proto);
			if (!iproto)
				iproto = _prototypeModel.getResearchPrototypeByName(proto);
			if (!iproto)
				iproto = _prototypeModel.getShipPrototype(proto);
			if (!iproto)
				iproto = _prototypeModel.getStoreItemPrototypeByName(proto);
			if (!iproto)
				iproto = _prototypeModel.getWeaponPrototype(proto);
			return iproto;
		}

		public function addListenerOnParticipantsAdded( listener:Function ):void
		{
			_battleModel.onParticipantsAdded.add(listener);
		}

		public function removeListenerOnParticipantsAdded( listener:Function ):void
		{
			_battleModel.onParticipantsAdded.remove(listener);
		}

		[Inject]
		public function set battleModel( v:BattleModel ):void  { _battleModel = v; }
		[Inject]
		public function set blueprintModel( v:BlueprintModel ):void  { _blueprintModel = v; }
		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }
		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }

		override public function destroy():void
		{
			super.destroy();
			_abilitySignal.removeAll();
			_abilitySignal = null;
			_battleModel = null;
			_blueprintModel = null;
			_fleetModel = null;
			_playerModel = null;
			_sectorModel = null;
			_serverController = null;
			_startSignal.removeAll();
			_startSignal = null;
			_system = null;
		}
	}
}


