package com.ui.hud.starbase
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.enum.ToastEnum;
	import com.enum.TypeEnum;
	import com.enum.server.AllianceRankEnum;
	import com.enum.server.AllianceResponseEnum;
	import com.event.TransactionEvent;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.starbase.Building;
	import com.game.entity.components.starbase.Platform;
	import com.game.entity.components.starbase.State;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BuildingVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.shared.IUIPresenter;
	import com.service.ExternalInterfaceAPI;
	import com.service.language.Localization;
	import com.ui.core.component.contextmenu.ContextMenu;
	import com.ui.core.effects.EffectFactory;
	import com.ui.modal.building.RefitBuildingView;
	import com.ui.modal.building.RepairBaseView;
	import com.ui.modal.construction.ConstructionInfoView;
	import com.ui.modal.construction.ConstructionView;
	import com.ui.modal.dock.DockView;
	import com.ui.modal.shipyard.ShipyardView;
	import com.ui.modal.store.StoreView;

	import flash.display.Stage;

	import org.ash.core.Entity;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;

	public class StarbaseView extends StarbaseBaseView
	{
		private var _stage:Stage;
		private var _uiPresenter:IUIPresenter;

		private const MIN_X_POS:Number                       = 650;
		private const EXIT_MIN_X_POS:Number                  = 67;

		private var _build:String                            = 'CodeString.Controls.Build'; //BUILD
		private var _fleets:String                           = 'CodeString.Controls.Fleets'; //FLEETS
		private var _shipyard:String                         = 'CodeString.Controls.Shipyard'; //SHIPYARD
		private var _research:String                         = 'CodeString.Controls.Research'; //RESEARCH
		private var _store:String                            = 'CodeString.Controls.Store'; //STORE

		private var _contextMenuStarbaseText:String          = 'CodeString.ContextMenu.Starbase.Move'; //Move
		private var _contextMenuRecycleStructureText:String  = 'CodeString.ContextMenu.Starbase.RecycleStructure'; //Recycle Structure
		private var _contextMenuRepairText:String            = 'CodeString.ContextMenu.Starbase.Repair'; //Repair
		private var _contextMenuBuildShipText:String         = 'CodeString.ContextMenu.Starbase.BuildShip'; //Build Ship
		private var _contextMenuViewFleetsText:String        = 'CodeString.ContextMenu.Starbase.ViewFleets'; //View Fleets
		private var _contextMenuRefitText:String             = 'CodeString.ContextMenu.Starbase.Refit'; //Refit
		private var _contextMenuShipDesignerText:String      = 'CodeString.ContextMenu.Starbase.ShipDesigner'; //Ship Designer
		private var _contextMenuResearchDefensesText:String  = 'CodeString.ContextMenu.Starbase.ResearchDefenses'; //Research Defenses

		private var _contextMenuResearchWeaponsText:String   = 'CodeString.ContextMenu.Starbase.ResearchWeapons'; //Research Weapons
		private var _contextMenuResearchTechText:String      = 'CodeString.ContextMenu.Starbase.ResearchTech'; //Research Tech
		private var _contextMenuUpgradeText:String           = 'CodeString.ContextMenu.Starbase.Upgrade'; //Upgrade
		private var _contextMenuDetailsText:String           = 'CodeString.ContextMenu.Starbase.Details'; //Details
		private var _contextMenuSpeedUpText:String           = 'CodeString.ContextMenu.Starbase.SpeedUp'; //Speed Up
		private var _contextMenuCancelBuildText:String       = 'CodeString.ContextMenu.Starbase.CancelBuild'; //Cancel Build
		private var _contextMenuCancelRepairText:String      = 'CodeString.ContextMenu.Starbase.CancelRepair'; //Cancel Repair
		private var _contextMenuCancelResearchText:String    = 'CodeString.ContextMenu.Starbase.CancelResearch'; //Cancel Research
		private var _contextMenuCancelUpgradeText:String     = 'CodeString.ContextMenu.Starbase.CancelUpgrade'; //Cancel Upgrade

		private var _alertFleetBattleTitleText:String        = 'CodeString.Alert.FleetBattle.Title'; //Fleet Battle!
		private var _alertFleetBattleBodyText:String         = 'CodeString.Alert.FleetBattle.Body'; //You are currently engaged in a fleet battle.
		private var _alertBaseBattleTitleText:String         = 'CodeString.Alert.BaseBattle.Title'; //Base Battle!
		private var _alertBaseBattleBodyText:String          = 'CodeString.Alert.BaseBattle.Body'; //You are currently engaged in a base battle.
		private var _alertViewBtnText:String                 = 'CodeString.Alert.BaseBattle.ViewBtn'; //View
		private var _alertDontViewBtnText:String             = 'CodeString.Alert.FleetBattle.DontViewBtn'; //Dont View

		private var _sharedLevel:String                      = 'CodeString.Shared.Level'; //Level [[Number.Level]]

		private var _toastAllianceRemoved:String             = 'CodeString.Toast.AllianceRemoved'; //You have been removed from your alliance.
		private var _toastAllianceBadName:String             = 'CodeString.Toast.AllianceBadName'; //Alliance creation failed bad name.
		private var _toastAllianceNameInUse:String           = 'CodeString.Toast.AllianceNameInUse'; //Alliance creation failed name in use.
		private var _toastAllianceFailedOffline:String       = 'CodeString.Toast.AllianceInviteFailedOffline'; //Alliance invite failed target offline.
		private var _toastAllianceFailedIgnored:String       = 'CodeString.Toast.AllianceInviteFailedIgnored'; //Alliance invite failed target is ignoring invites.
		private var _toastAllianceAlreadyInAnAlliance:String = 'CodeString.Toast.AllianceInviteFailedAlreadyInAnAlliance'; //Alliance invite failed target is already in an alliance.
		private var _toastAllianceTooManyAlready:String      = 'CodeString.Toast.AllianceJoinFailedTooManyAlready'; //Alliance join failed too many players in alliance.
		private var _toastAllianceNoLongerExists:String      = 'CodeString.Toast.AllianceJoinFailedNoLongerExists'; //Alliance join failed it no longer exists
		private var _toastAllianceInviteRecieved:String      = 'CodeString.Toast.AllianceInviteRecieved'; //You have been invited to join an alliance.
		private var _toastAllianceJoined:String              = 'CodeString.Toast.AllianceJoined'; //You have joined an alliance.


		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addBaseInteractionListener(popContextMenuFromEntity);
			presenter.showBuildings();
			_uiPresenter && _uiPresenter.highfive();

			x = DeviceMetrics.WIDTH_PIXELS * 0.5;

			if (x < MIN_X_POS)
				x = MIN_X_POS;

			presenter.addOnGenericAllianceMessageRecievedListener(onGenericAllianceMessage);

			addHitArea();
			addEffects();
			effectsIN();
			onResize();
		}

		//============================================================================================================
		//************************************************************************************************************
		//											ENTITY INTERACTION
		//************************************************************************************************************
		//============================================================================================================

		private function popContextMenuFromEntity( x:int, y:int, baseEntity:Entity ):void
		{
			var contextMenu:ContextMenu = ObjectPool.get(ContextMenu);
			var buildingState:State     = State(baseEntity.get(State));
			var detail:Detail           = baseEntity.get(Detail);
			var buildingVO:BuildingVO   = (baseEntity.has(Building)) ? Building(baseEntity.get(Building)).buildingVO : Platform(baseEntity.get(Platform)).buildingVO;
			var buildingName:String     = presenter.getEntityName(buildingVO.asset);
			var level:String            = Localization.instance.getStringWithTokens(_sharedLevel, {'[[Number.Level]]':buildingVO.level});

			contextMenu.setup(buildingName, x, y, 150, _stage.stageWidth, _stage.stageHeight, level);
			if (baseEntity.has(Platform))
			{
				contextMenu.addContextMenuChoice(_contextMenuStarbaseText, presenter.moveEntity, []);
				if (buildingVO.prototype.getValue("canBeRecycled") == true)
					//contextMenu.addContextMenuChoice(_contextMenuRecycleStructureText, showRecycleView, [baseEntity]);
					contextMenu.addContextMenuChoice(_contextMenuDetailsText, showUpgradeView, [baseEntity]);
			} else
			{
				if (buildingVO.currentHealth < 1 && (!buildingState || buildingState.type != TransactionEvent.STARBASE_REPAIR_BASE))
				{
					contextMenu.addContextMenuChoice(_contextMenuRepairText, showBaseRepair, []);
					contextMenu.addContextMenuChoice(_contextMenuStarbaseText, presenter.moveEntity, []);
				} else if (!buildingState)
				{
					switch (detail.type)
					{
						case TypeEnum.CONSTRUCTION_BAY:
							contextMenu.addContextMenuChoice(_contextMenuBuildShipText, showShipyard, []);
							break;
						case TypeEnum.DOCK:
							contextMenu.addContextMenuChoice(_contextMenuViewFleetsText, showDocks, []);
							break;
						case TypeEnum.SHIPYARD:
							contextMenu.addContextMenuChoice(_contextMenuShipDesignerText, enterResearchView, [baseEntity]);
							break;
						case TypeEnum.DEFENSE_DESIGN:
							contextMenu.addContextMenuChoice(_contextMenuResearchDefensesText, enterResearchView, [baseEntity]);
							break;
						case TypeEnum.WEAPONS_FACILITY:
							contextMenu.addContextMenuChoice(_contextMenuResearchWeaponsText, enterResearchView, [baseEntity]);
							break;
						case TypeEnum.ADVANCED_TECH:
							contextMenu.addContextMenuChoice(_contextMenuResearchTechText, enterResearchView, [baseEntity]);
							break;
						case TypeEnum.POINT_DEFENSE_PLATFORM:
						case TypeEnum.SHIELD_GENERATOR:
							contextMenu.addContextMenuChoice(_contextMenuRefitText, showRefitView, [baseEntity]);
							break;
					}
					var upgradePrototype:IPrototype = presenter.getBuildingUpgrade(buildingVO);
					if (upgradePrototype)
						contextMenu.addContextMenuChoice(_contextMenuUpgradeText, showUpgradeView, [baseEntity]);
					else
						contextMenu.addContextMenuChoice(_contextMenuDetailsText, showUpgradeView, [baseEntity]);
					contextMenu.addContextMenuChoice(_contextMenuStarbaseText, presenter.moveEntity, []);
				} else
				{
					if (buildingState.type == TransactionEvent.STARBASE_REPAIR_BASE)
					{
						contextMenu.addContextMenuChoice(_contextMenuSpeedUpText, showTransactionView, [buildingState.transaction]);
						contextMenu.addContextMenuChoice(_contextMenuStarbaseText, presenter.moveEntity, []);
					} else
					{
						if (buildingState.type == TransactionEvent.STARBASE_REFIT_BUILDING)
							contextMenu.addContextMenuChoice(_contextMenuRefitText, showRefitView, [baseEntity]);
						//PR: Adding the speed up option back in for now so that the fte isn't broken
						contextMenu.addContextMenuChoice(_contextMenuSpeedUpText, showTransactionView, [buildingState.transaction]);
						if (buildingState.type != TransactionEvent.STARBASE_BUILDING_UPGRADE)
							contextMenu.addContextMenuChoice(_contextMenuUpgradeText, showUpgradeView, [baseEntity]);
						contextMenu.addContextMenuChoice(_contextMenuStarbaseText, presenter.moveEntity, []);
						switch (buildingState.type)
						{
							case TransactionEvent.STARBASE_BUILDING_BUILD:
								contextMenu.addContextMenuChoice(_contextMenuCancelBuildText, presenter.cancelTransaction, [buildingState.transaction]);
								break;
							case TransactionEvent.STARBASE_RESEARCH:
								contextMenu.addContextMenuChoice(_contextMenuCancelResearchText, presenter.cancelTransaction, [buildingState.transaction]);
								break;
							case TransactionEvent.STARBASE_BUILDING_UPGRADE:
								contextMenu.addContextMenuChoice(_contextMenuCancelUpgradeText, presenter.cancelTransaction, [buildingState.transaction]);
								break;
						}
					}
				}
			}

			_viewFactory.notify(contextMenu);
		}

		private function showBaseRepair():void
		{
			showView(RepairBaseView);
		}

		private function enterResearchView( baseEntity:Entity ):void
		{
			var view:ConstructionView = ConstructionView(_viewFactory.createView(ConstructionView));
			view.openOn(ConstructionView.RESEARCH, Building(baseEntity.get(Building)).buildingVO.asset, null);
			_viewFactory.notify(view);
		}

		private function showRefitView( baseEntity:Entity ):void
		{
			var nShieldView:RefitBuildingView = RefitBuildingView(_viewFactory.createView(RefitBuildingView));
			nShieldView.buildingVO = presenter.getBuildingVO(baseEntity.id);
			_viewFactory.notify(nShieldView);
		}

		private function showUpgradeView( baseEntity:Entity ):void
		{
			var view:ConstructionInfoView = ConstructionInfoView(_viewFactory.createView(ConstructionInfoView));
			view.setup(ConstructionView.BUILD, presenter.getBuildingVO(baseEntity.id));
			_viewFactory.notify(view);
		}

		private function showTransactionView( transaction:TransactionVO ):void
		{
			var nStoreView:StoreView = StoreView(_viewFactory.createView(StoreView));
			_viewFactory.notify(nStoreView);
			nStoreView.setSelectedTransaction(transaction);
		}

		private function showDocks():void  { showView(DockView); }
		private function showShipyard():void  { showView(ShipyardView); }

		//============================================================================================================
		//************************************************************************************************************
		//													CONTROLS
		//************************************************************************************************************
		//============================================================================================================

		private function onResize():void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			x = DeviceMetrics.WIDTH_PIXELS * 0.5;

			if (x < MIN_X_POS)
				x = MIN_X_POS;
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.CENTER, PositionEnum.TOP, onResize));
		}

		private function onGenericAllianceMessage( messageEnum:int, allianceKey:String ):void
		{
			switch (messageEnum)
			{
				case AllianceResponseEnum.SET_SUCCESS:
					break;
				case AllianceResponseEnum.KICKED:
				case AllianceResponseEnum.LEFT:
					showToast(ToastEnum.ALLIANCE, null, _toastAllianceRemoved);
					CurrentUser.alliance = '';
					CurrentUser.allianceName = '';
					CurrentUser.allianceRank = AllianceRankEnum.UNAFFILIATED;
					CurrentUser.isAllianceOpen = false;
					break;
				case AllianceResponseEnum.ALLIANCE_CREATION_FAILED_BADNAME:
					showToast(ToastEnum.ALLIANCE, null, _toastAllianceBadName);
					break;
				case AllianceResponseEnum.ALLIANCE_CREATION_FAILED_NAMEINUSE:
					showToast(ToastEnum.ALLIANCE, null, _toastAllianceNameInUse);
					break;
				case AllianceResponseEnum.INVITE_FAILED_OFFLINE:
					showToast(ToastEnum.ALLIANCE, null, _toastAllianceFailedOffline);
					break;
				case AllianceResponseEnum.INVITE_FAILED_IGNORED:
					showToast(ToastEnum.ALLIANCE, null, _toastAllianceFailedIgnored);
					break;
				case AllianceResponseEnum.INVITE_FAILED_INALLIANCE:
					showToast(ToastEnum.ALLIANCE, null, _toastAllianceAlreadyInAnAlliance);
					break;
				case AllianceResponseEnum.JOIN_FAILED_TOOMANYPLAYERS:
					showToast(ToastEnum.ALLIANCE, null, _toastAllianceTooManyAlready);
					break;
				case AllianceResponseEnum.JOIN_FAILED_NOALLIANCE:
					showToast(ToastEnum.ALLIANCE, null, _toastAllianceNoLongerExists);
					break;
				case AllianceResponseEnum.INVITED:
					showToast(ToastEnum.ALLIANCE, null, _toastAllianceInviteRecieved);
					break;
				case AllianceResponseEnum.JOINED:
					showToast(ToastEnum.ALLIANCE, null, _toastAllianceJoined);
					ExternalInterfaceAPI.shareAllianceJoin();
					break;
			}

		}

		[Inject]
		public function set stage( value:Stage ):void  { _stage = value; }
		[Inject]
		public function set uiPresenter( v:IUIPresenter ):void  { _uiPresenter = v; }

		override public function destroy():void
		{
			presenter.removeOnGenericAllianceMessageRecievedListener(onGenericAllianceMessage);

			_uiPresenter && _uiPresenter.shun();
			_uiPresenter = null;

			super.destroy();
			_stage = null;
		}
	}
}
