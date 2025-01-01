package com.presenter.shared
{
	import com.Application;
	import com.controller.ChatController;
	import com.controller.GameController;
	import com.controller.ServerController;
	import com.controller.SettingsController;
	import com.controller.transaction.TransactionController;
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.BattleEvent;
	import com.event.SectorEvent;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.event.signal.InteractSignal;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.model.alliance.AllianceModel;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleModel;
	import com.model.battle.BattleRerollVO;
	import com.model.battlelog.BattleLogModel;
	import com.model.blueprint.BlueprintModel;
	import com.model.blueprint.BlueprintVO;
	import com.model.event.EventModel;
	import com.model.event.EventVO;
	import com.model.mail.MailModel;
	import com.model.mail.MailVO;
	import com.model.motd.MotDDailyRewardModel;
	import com.model.motd.MotDModel;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerModel;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.scene.SceneModel;
	import com.model.sector.SectorModel;
	import com.model.sector.SectorVO;
	import com.model.starbase.BuffVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;
	import com.model.warfrontModel.WarfrontModel;
	import com.presenter.ImperiumPresenter;
	import com.service.loading.LoadPriority;
	import com.service.server.outgoing.alliance.AllianceSendInviteRequest;

	import flash.display.StageDisplayState;
	import flash.utils.Dictionary;

	import org.ash.core.Game;
	import org.parade.core.IView;
	import org.parade.core.ViewController;

	public class UIPresenter extends ImperiumPresenter implements IUIPresenter
	{
		private static var _currentBookmarkCount:uint;

		private var _currentState:String;

		private var _game:Game;

		private var _serverController:ServerController;
		private var _chatController:ChatController;
		private var _gameController:GameController;
		private var _settingsController:SettingsController;
		private var _viewController:ViewController;
		private var _transactionController:TransactionController;

		private var _sceneModel:SceneModel;
		private var _sectorModel:SectorModel;
		private var _battleLogModel:BattleLogModel;
		private var _assetModel:AssetModel;
		private var _starbaseModel:StarbaseModel;
		private var _blueprintModel:BlueprintModel;
		private var _motdModel:MotDModel;
		private var _motdDailyModel:MotDDailyRewardModel;
		private var _warfrontModel:WarfrontModel;
		private var _battleModel:BattleModel;
		private var _transactionModel:TransactionModel;
		private var _prototypeModel:PrototypeModel;
		private var _mailModel:MailModel;
		private var _allianceModel:AllianceModel;
		private var _playerModel:PlayerModel;
		private var _eventModel:EventModel;
		private var _interactSignal:InteractSignal;
		private var _starbaseFactory:IStarbaseFactory;

		[PostConstruct]
		override public function init():void
		{
			super.init();
		}

		public function gotoCoords( x:int, y:int, sector:String ):void
		{

			if (sector != _sectorModel.sectorID)
			{
				jumpToSector(x, y, sector);
			} else
			{
				var system:SectorInteractSystem = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
				if (system != null)
					system.moveToLocation(x, y);
				else
				{
					jumpToSector(x, y, sector);
				}
			}

		}

		public function viewBattleReplay( battleKey:String ):void
		{
			var battleEvent:BattleEvent = new BattleEvent(BattleEvent.BATTLE_REPLAY, battleKey);
			dispatch(battleEvent);
		}

		public function linkCoords( x:int, y:int ):void
		{
			_chatController.linkCoords(x, y);
		}

		public function addBookmark( x:int, y:int ):void
		{
			if (_currentBookmarkCount == 0)
				_currentBookmarkCount = CurrentUser.bookmarkCount + 1;

			var name:String            = 'Bookmark ' + _currentBookmarkCount;
			++_currentBookmarkCount;

			var sectorName:String      = _sectorModel.sectorName;
			var sector:String          = _sectorModel.sectorID;

			var currentSector:SectorVO = _sectorModel.currentSectorVO;
			CurrentUser.addBookmark(name, sector, currentSector.sectorPrototype, currentSector.sectorNamePrototype, currentSector.sectorEnumPrototype, x, y, CurrentUser.nextBookmarkIndex);
			_gameController.bookmarkSave(name, sector, currentSector.sectorNamePrototype.name, currentSector.sectorEnumPrototype.name, currentSector.sectorPrototype.name, x, y);
		}

		private function jumpToSector( x:int, y:int, sector:String ):void
		{
			var sectorEvent:SectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, sector, null, x, y);
			dispatch(sectorEvent);
		}

		public function changeResolution():void
		{
			_sceneModel.changeResolution();
			_interactSignal.resolutionChange();
			_interactSignal.scroll(0, 0);
		}

		public function toggleSFXMute():void
		{
			_settingsController.toggleSFXMute();
		}

		public function toggleMusicMute():void
		{
			_settingsController.toggleMusicMute();
		}

		public function setSFXVolume( v:Number ):void
		{
			_settingsController.setSFXVolume(v);
		}

		public function setMusicVolume( v:Number ):void
		{
			_settingsController.setMusicVolume(v);
		}

		public function toggleFullScreen():void
		{
			_settingsController.toggleFullScreen();
		}

		public function getTransactions():Dictionary
		{
			return _transactionModel.transactions;
		}

		public function loadIcon( url:String, callback:Function ):void
		{
			getFromCache("assets/" + url, callback);
		}

		public function loadIconFromEntityData( type:String, callback:Function ):void
		{
			var _currentAssetVO:AssetVO = _assetModel.getEntityData(type);
			loadIcon("assets/" + _currentAssetVO.smallImage, callback);
		}

		public function loadMessageImage( url:String, callback:Function ):void
		{
			getFromCache(url, callback, LoadPriority.LOW, true);
		}

		public function loadPortraitSmall( portraitName:String, callback:Function ):void
		{
			var avatarVO:AssetVO = AssetVO(getFromCache(portraitName));
			getFromCache('assets/' + avatarVO.smallImage, callback);
		}

		public function loadPortraitMedium( portraitName:String, callback:Function ):void
		{
			var avatarVO:AssetVO = AssetVO(getFromCache(portraitName));
			try{
			getFromCache('assets/' + avatarVO.mediumImage, callback);
			}catch(ex){}
		}

		public function loadPortraitIcon( portraitName:String, callback:Function ):void
		{
			var avatarVO:AssetVO = AssetVO(getFromCache(portraitName));
			getFromCache('assets/' + avatarVO.iconImage, callback);
		}

		public function getFromCache( url:String, callback:Function = null, priority:int = LoadPriority.LOW, absoluteURL:Boolean = false ):Object
		{
			return _assetModel.getFromCache(url, callback, priority, absoluteURL);
		}

		public function getPrototypeUIIcon( prototype:IPrototype ):String
		{
			var assetName:String       = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;

			var currentAssetVO:AssetVO = _assetModel.getEntityData(assetName);
			return currentAssetVO.iconImage;
		}

		public function getBlueprintByName( prototype:String ):BlueprintVO
		{
			return _blueprintModel.getBlueprintByName(prototype);
		}

		public function removeBlueprintByName( name:String ):void
		{
			_blueprintModel.removeBlueprintByName(name);
		}

		public function getBlueprintByID( id:String ):BlueprintVO
		{
			return _blueprintModel.getBlueprintByID(id);
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

		public function getPrototypeUIName( prototype:IPrototype ):String
		{

			var assetName:String       = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;

			var currentAssetVO:AssetVO = _assetModel.getEntityData(assetName);
			return currentAssetVO.visibleName;
		}

		public function getAssetVOFromIPrototype( prototype:IPrototype ):AssetVO
		{
			var assetName:String = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;
			return _assetModel.getEntityData(assetName);
		}

		public function getAssetVO( assetName:String ):AssetVO
		{
			return _assetModel.getEntityData(assetName);
		}

		public function getBattleEndDialogByFaction( faction:String, combatResult:String = 'Victory' ):Vector.<IPrototype>
		{
			return _prototypeModel.getBEDialogueByFaction(faction, combatResult);
		}

		public function getBlueprintPrototypeByName( name:String ):IPrototype
		{
			return _prototypeModel.getBlueprintPrototype(name);
		}

		public function getFilterAssetVO( prototype:IPrototype ):AssetVO
		{
			var assetName:String = prototype.getUnsafeValue('filterCategory');
			return _assetModel.getEntityData(assetName);
		}

		public function getBuffPrototypes():Dictionary
		{
			var buffs:Dictionary      = new Dictionary();
			var v:Vector.<IPrototype> = _prototypeModel.getBuffPrototypes();
			var l:uint                = v.length;
			for (var i:uint = 0; i < l; ++i)
			{
				var buffType:String = v[i].getValue('buffType');
				if (!(buffType in buffs))
				{
					buffs[buffType] = v[i];
				}
			}
			return buffs;
		}

		public function getBuffPrototypeByName( name:String ):IPrototype
		{
			return _prototypeModel.getBuffPrototype(name);
		}

		public function getConstantPrototypeValueByName( name:String ):Number
		{
			var proto:IPrototype = _prototypeModel.getConstantPrototypeByName(name);
			return proto.getValue('value');
		}

		public function getCommendationRankPrototypesByName( name:String ):IPrototype
		{
			return _prototypeModel.getCommendationRankPrototypesByName(name);
		}

		public function sendMailMessage( playerID:String, subject:String, body:String ):void
		{
			_gameController.mailSendMessage(playerID, subject, body);
		}

		public function sendAllianceMailMessage( subject:String, body:String ):void
		{
			_gameController.mailSendAllianceMessage(subject, body);
		}

		public function getFAQPrototypes():Vector.<IPrototype>
		{
			return _prototypeModel.getFAQEntryPrototypes();
		}

		public function sendGetMailboxMessage():void
		{
			_gameController.mailGetMailbox();
		}

		public function getMailDetails( mailKey:String ):void
		{
			_gameController.mailGetMailDetail(mailKey);
		}

		public function deleteMail( v:Vector.<String> ):void
		{
			var len:uint = v.length;
			for (var i:uint = 0; i < len; ++i)
			{
				_mailModel.deleteMail(v[i]);
			}

			_gameController.mailDelete(v);
		}

		public function mailRead( mailKey:String ):void
		{
			_mailModel.mailRead(mailKey);
		}

		public function getFactionPrototypesByName( name:String ):IPrototype
		{
			return _prototypeModel.getFactionPrototypeByName(name);
		}

		public function getRacePrototypeByName( name:String ):IPrototype
		{
			return _prototypeModel.getRacePrototypeByName(name);
		}

		public function sendMotDMessageRead( key:String ):void
		{
			_gameController.requestMotDRead(key);
		}

		public function requestPlayer( id:String, name:String = '' ):void
		{
			_gameController.leaderboardRequestPlayerProfile(id, name);
		}

		public function allianceSendInvite( playerKey:String ):void
		{
			var sendInvite:AllianceSendInviteRequest = AllianceSendInviteRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_SEND_INVITE));
			sendInvite.playerKey = playerKey;
			_serverController.send(sendInvite);
		}

		public function sendDailyClaimRequest( header:int, protocolID:int ):void
		{
			_gameController.requestDailyClaim(header, protocolID);
		}

		public function getTransactionByID( id:String ):TransactionVO
		{
			return _transactionController.getBuffTransaction(id);
		}

		public function getOfferPrototypeByName( name:String ):IPrototype
		{
			return _prototypeModel.getOfferPrototypeByName(name);
		}

		public function getOfferItemsByItemGroup( itemGroup:String ):Vector.<IPrototype>
		{
			return _prototypeModel.getOfferItemsByItemGroup(itemGroup);
		}

		public function canEquip( prototype:IPrototype, slotType:String ):RequirementVO  { return _transactionController.canEquip(prototype, slotType); }

		public function addBattleLogListUpdatedListener( callback:Function ):void  { _battleLogModel.battleLogListUpdated.add(callback); }
		public function removeBattleLogListUpdatedListener( callback:Function ):void  { _battleLogModel.battleLogListUpdated.remove(callback); }

		public function addBattleLogDetailUpdatedListener( callback:Function ):void  { _battleLogModel.battleLogDetailUpdated.add(callback); }
		public function removeBattleLogDetailUpdatedListener( callback:Function ):void  { _battleLogModel.battleLogDetailUpdated.remove(callback); }

		public function addMailCountUpdateListener( callback:Function ):void  { _mailModel.countUpdated.add(callback); }
		public function removeMailCountUpdateListener( callback:Function ):void  { _mailModel.countUpdated.remove(callback); }

		public function addOnMailHeadersUpdatedListener( callback:Function ):void  { _mailModel.mailHeadersUpdated.add(callback); }
		public function removeOnMailHeadersUpdatedListener( callback:Function ):void  { _mailModel.mailHeadersUpdated.remove(callback); }

		public function addOnMailDetailUpdatedListener( callback:Function ):void  { _mailModel.mailDetailUpdated.add(callback); }
		public function removeOnMailDetailUpdatedListener( callback:Function ):void  { _mailModel.mailDetailUpdated.remove(callback); }

		public function addMotDUpdatedListener( callback:Function ):void  { _motdModel.newMessage.add(callback); }
		public function removeMotDUpdatedListener( callback:Function ):void  { _motdModel.newMessage.remove(callback); }

		public function addDailyRewardListener( callback:Function ):void  { _motdDailyModel.rewardResponse.add(callback); }
		public function removeDailyRewardListener( callback:Function ):void  { _motdDailyModel.rewardResponse.remove(callback); }

		public function addOnPlayerVOAddedListener( callback:Function ):void  { _playerModel.onPlayerAdded.add(callback); }
		public function removeOnPlayerVOAddedListener( callback:Function ):void  { _playerModel.onPlayerAdded.remove(callback); }

		public function addWarfrontUpdateListener( listener:Function ):void  { _warfrontModel.addUpdateListener(listener); }
		public function removeWarfrontUpdateListener( listener:Function ):void  { _warfrontModel.removeUpdateListener(listener); }

		public function addAvailableRerollUpdatedListener( callback:Function ):void  { _battleModel.onRerollAdded.add(callback); }
		public function removeAvailableRerollUpdatedListener( callback:Function ):void  { _battleModel.onRerollAdded.remove(callback); }

		public function addEventUpdatedListener( callback:Function ):void  { _eventModel.onEventsUpdated.add(callback); }
		public function removeEventUpdatedListener( callback:Function ):void  { _eventModel.onEventsUpdated.remove(callback); }


		override protected function onStateChange( e:StateEvent ):void
		{
			_currentState = e.type;
			super.onStateChange(e);
		}

		public function fteNextStep():void
		{
			_fteController.nextStep();
		}

		public function fteSkip():void
		{
			_fteController.skipFTE();
		}

		public function get unreadMailCount():uint  { return _mailModel.unreadCount; }
		public function get mail():Vector.<MailVO>  { return _mailModel.mail; }

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
		public function getShipPrototypeByName( proto:String ):IPrototype
		{
			return _prototypeModel.getShipPrototype(proto);
		}

		public function getBattleLogList( filter:String ):void
		{
			_gameController.battleLogGetBattleList( filter );
		}

		public function getBattleLogDetails( battleKey:String ):void
		{
			_gameController.battleLogGetBattleDetail(battleKey);
		}

		public function getAvailableRerolls():Vector.<BattleRerollVO>
		{
			return _battleModel.getAllAvailableRerolls();
		}

		public function updateStarbasePlatform():void
		{
			if (Application.STATE == StateEvent.GAME_STARBASE)
				_starbaseFactory.createStarbasePlatform(CurrentUser.id, true);
		}

		public function getView( view:Class ):IView  { return _viewController.getView(view); }

		public function addTransactionListener( type:int, callback:Function ):void  { _transactionController.addListener(type, callback); }
		public function removeTransactionListener( callback:Function ):void  { _transactionController.removeListener(callback); }

		public function removeBuff( buff:BuffVO ):void  { _starbaseModel.removeBuffByID(buff.id); }

		public function get buffs():Vector.<BuffVO>  { return _starbaseModel.currentBase.buffs; }
		public function get bubbleTimeRemaining():Number  { return _starbaseModel.currentBase ? _starbaseModel.currentBase.bubbleTimeRemaining : 0; }

		public function get isSFXMuted():Boolean  { return _soundController.areSFXMuted; }
		public function get isMusicMuted():Boolean  { return _soundController.isMusicMuted; }
		public function get sfxVolume():Number  { return _soundController.sfxVolume; }
		public function get musicVolume():Number  { return _soundController.musicVolume; }
		public function get isFullScreen():Boolean  { return Application.STAGE.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE; }

		public function get motdModel():MotDModel  { return _motdModel; }

		public function get motdDailyModel():MotDDailyRewardModel  { return _motdDailyModel; }

		public function get currentGameState():String  { return _currentState; }

		public function get igaContextMenuDefaultIndex():int  { return _sectorModel.igaContextMenuDefaultIndex; }
		public function setIGAContextMenuDefaultIndex( v:int ):void  { _sectorModel.igaContextMenuDefaultIndex = v; }

		public function get tyrContextMenuDefaultIndex():int  { return _sectorModel.tyrContextMenuDefaultIndex; }
		public function setTYRContextMenuDefaultIndex( v:int ):void  { _sectorModel.tyrContextMenuDefaultIndex = v; }

		public function get sovContextMenuDefaultIndex():int  { return _sectorModel.sovContextMenuDefaultIndex; }
		public function setSOVContextMenuDefaultIndex( v:int ):void  { _sectorModel.sovContextMenuDefaultIndex = v; }
		
		public function get csContextMenuDefaultIndex():int  { return _sectorModel.csContextMenuDefaultIndex; }
		public function setCSContextMenuDefaultIndex( v:int ):void  { _sectorModel.csContextMenuDefaultIndex = v; }

		public function get currentActiveEvent():EventVO  { return _eventModel.currentActiveEvent; }

		public function get activeEvents():Vector.<EventVO>  { return _eventModel.activeEvents; }
		public function get upcomingEvents():Vector.<EventVO>  { return _eventModel.upcomingEvents; }

		[Inject]
		public function set game( v:Game ):void  { _game = v; }

		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		[Inject]
		public function set chatController( v:ChatController ):void  { _chatController = v; }
		[Inject]
		public function set gameController( v:GameController ):void  { _gameController = v; }
		[Inject]
		public function set settingsController( v:SettingsController ):void  { _settingsController = v; }
		[Inject]
		public function set viewController( v:ViewController ):void  { _viewController = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }

		[Inject]
		public function set sceneModel( v:SceneModel ):void  { _sceneModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set battleLogModel( v:BattleLogModel ):void  { _battleLogModel = v; }
		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set blueprintModel( v:BlueprintModel ):void  { _blueprintModel = v; }
		[Inject]
		public function set motdModel( v:MotDModel ):void  { _motdModel = v; }
		[Inject]
		public function set motdDailyModel( v:MotDDailyRewardModel ):void  { _motdDailyModel = v; }
		[Inject]
		public function set warfrontModel( v:WarfrontModel ):void  { _warfrontModel = v; }
		[Inject]
		public function set battleModel( value:BattleModel ):void  { _battleModel = value; }
		[Inject]
		public function set transactionModel( v:TransactionModel ):void  { _transactionModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set mailModel( v:MailModel ):void  { _mailModel = v; }
		[Inject]
		public function set allianceModel( v:AllianceModel ):void  { _allianceModel = v; }
		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set eventModel( v:EventModel ):void  { _eventModel = v; }
		[Inject]
		public function set starbaseFactory( v:IStarbaseFactory ):void  { _starbaseFactory = v; }

		[Inject]
		public function set interactSignal( v:InteractSignal ):void  { _interactSignal = v; }

		override public function destroy():void
		{
			super.destroy();

			_sceneModel = null;
			_serverController;
			_starbaseModel = null;
			_interactSignal = null;
			_warfrontModel = null;
			_battleModel = null;
			_starbaseFactory = null;
		}
	}
}


