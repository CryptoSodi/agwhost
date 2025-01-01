package com.ui.hud.sector
{
	import com.Application;
	import com.enum.CategoryEnum;
	import com.enum.FactionEnum;
	import com.enum.FleetStateEnum;
	import com.enum.PositionEnum;
	import com.enum.ToastEnum;
	import com.enum.TypeEnum;
	import com.enum.server.AllianceRankEnum;
	import com.enum.server.AllianceResponseEnum;
	import com.enum.ui.ButtonEnum;
	import com.game.entity.components.battle.Attack;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Enemy;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Owned;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.sector.Transgate;
	import com.model.fleet.FleetVO;
	import com.model.mission.MissionVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerVO;
	import com.model.sector.SectorVO;
	import com.model.starbase.BaseVO;
	import com.model.prototype.IPrototype
	import com.presenter.shared.IUIPresenter;
	import com.presenter.starbase.IMissionPresenter;
	import com.service.ExternalInterfaceAPI;
	import com.service.language.Localization;
	import com.service.server.incoming.data.SectorBattleData;
	import com.ui.UIFactory;
	import com.ui.alert.DropBubbleView;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.contextmenu.ContextMenu;
	import com.ui.core.effects.EffectFactory;
	import com.ui.modal.playerinfo.PlayerProfileView;
	import com.util.CommonFunctionUtil;
	import com.ui.core.ButtonPrototype;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import org.ash.core.Entity;
	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;

	public class SectorView extends SectorBaseView
	{
		private var _battleServerAddress:String;
		private var _joinBattleBtn:BitmapButton;
		private var _stage:Stage;
		private var _uiPresenter:IUIPresenter;
		private var _missionPresenter:IMissionPresenter;

		private var _tyrDestinations:Vector.<SectorVO>;
		private var _sovDestinations:Vector.<SectorVO>;
		private var _igaDestinations:Vector.<SectorVO>;
		
		private var _privateDestinations:Vector.<SectorVO>;
		
		private var _relocateSectorKey:String = "";
		private var _relocateTransgateKey:String = "";
		private var _sectorFaction:String = "";

		private const MIN_X_POS:Number                       = 385;
		private const MAX_BOOKMARKS:uint                     = 35;

		private var _joinBattle:String                       = 'CodeString.FleetStatus.JoinBattleBtn'; //JOIN BATTLE

		private var _contextMenuStarbaseText:String          = 'CodeString.ContextMenu.Sector.Starbase'; //Starbase
		private var _contextMenuRecallText:String            = 'CodeString.ContextMenu.Sector.Recall'; //Recall
		private var _contextMenuEnterText:String             = 'CodeString.ContextMenu.Sector.Enter'; //Enter
		private var _contextMenuDefendText:String            = 'CodeString.Alert.Battle.ViewBtn'; // Defend
		private var _contextMenuJoinBattleText:String        = 'CodeString.ContextMenu.Sector.JoinBattle'; //Join Battle
		private var _contextMenuTackleText:String            = "Scramble Warp"; //Join Battle
		private var _contextMenuAttackText:String            = 'CodeString.ContextMenu.Sector.Attack'; //Attack
		private var _contextMenuWatchBattleText:String       = 'CodeString.ContextMenu.Sector.WatchBattle'; //Watch Battle
		private var _contextMenuTravelText:String            = 'CodeString.ContextMenu.Sector.Travel'; //Travel To:
		private var _contextMenuFleetText:String             = 'CodeString.ContextMenu.Sector.Fleet'; //Fleet

		private var _contextMenuMissionSectorText:String     = 'CodeString.ContextMenu.Sector.MissionSector'; //Mission Sector
		private var _contextMenuDebrisText:String            = 'CodeString.ContextMenu.Sector.CargoDebris'; //Cargo Debris
		private var _contextMenuLoadCargoText:String         = 'CodeString.ContextMenu.Sector.LoadCargo'; //Load Cargo
		private var _contextMenuLinkCoords:String            = 'CodeString.ContextMenu.Sector.LinkCoords' //Link Coordinates 

		private var _sendMessage:String                      = 'CodeString.ContextMenu.Shared.SendMessage'; //Send Message
		private var _viewProfile:String                      = 'CodeString.ContextMenu.Chat.ViewProfile'; //View Profile
		private var _addBookmark:String                      = 'CodeString.ContextMenu.Sector.AddBookmark'; //Add Bookmark
		private var _sectorNameText:String                   = "[[String.SectorName]] [[String.SectorEnum]]"; //[[String.SectorName]] [[String.SectorEnum]]

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
		
		private var _contextMenuRelocate:String            = 'CodeString.ContextMenu.Sector.Relocate' //Relocate
		private var _acceptBtnText:String        			 = 'CodeString.Shared.Accept'; //ACCEPT
		private var _cancelBtnText:String    				 = 'CodeString.Shared.CancelBtn'; //CANCEL
		private var _relocateAlertTitle:String  			 = 'CodeString.Alert.RelocateToTransgate.Title'; //RELOCATE
		private var _relocateAlertBody:String   			 = 'CodeString.Alert.RelocateToTransgate.Body'; //This will move your starbase close to the selected player's starbase.\nAre you Sure?
		
		private var _buyBtnText:String        				 = 'CodeString.Shared.BuyPalladium'; //Buy Palladium
		private var _notEnoughPalladiumTitle:String  			 = 'CodeString.Alert.NotEnoughPalladium.Title'; //NOT ENOUGH PALLADIUM
		private var _notEnoughPalladiumBody:String   			 = 'CodeString.Alert.NotEnoughPalladium.Body'; //NOT ENOUGH PALLADIUM
		
		

		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addBattleListener(onBattle);
			presenter.addInteractListener(popContextMenuFromEntity);
			presenter.addNotificationListener(onNotification);

			_battleServerAddress = null;

			_joinBattleBtn = UIFactory.getButton(ButtonEnum.RED_A, 640, 40, 0, 100, _joinBattle);
			_joinBattleBtn.alpha = 0;
			_joinBattleBtn.visible = false;
			addChild(_joinBattleBtn);
			addListener(_joinBattleBtn, MouseEvent.CLICK, onButtonClick);

			{
				var destinations:Vector.<SectorVO> = presenter.getTransgateDestinations();
	
				_tyrDestinations = new Vector.<SectorVO>;
				_sovDestinations = new Vector.<SectorVO>;
				_igaDestinations = new Vector.<SectorVO>;
	
				var len:uint                       = destinations.length;
				var currentDestination:SectorVO;
				for (var i:uint = 0; i < len; i++)
				{
					currentDestination = destinations[i];
					if (currentDestination.id == presenter.sectorID)
					{
						_sectorFaction = currentDestination.sectorFaction;
						continue;
					}
					switch (currentDestination.sectorFaction)
					{
						case FactionEnum.SOVEREIGNTY:
							_sovDestinations.push(currentDestination);
							break;
						case FactionEnum.TYRANNAR:
							_tyrDestinations.push(currentDestination);
							break;
						case FactionEnum.IGA:
							_igaDestinations.push(currentDestination);
							break;
					}
	
				}
			}
			{
				var destinations:Vector.<SectorVO> = presenter.getPrivateDestinations();
				_privateDestinations = new Vector.<SectorVO>;
				
				var len:uint                       = destinations.length;
				var currentDestination:SectorVO;
				for (var i:uint = 0; i < len; i++)
				{
					currentDestination = destinations[i];
					if (currentDestination.id == presenter.sectorID)
					{
						_sectorFaction = currentDestination.sectorFaction;
						continue;
					}
					_privateDestinations.push(currentDestination);
					
				}
				
				
			}

			_igaDestinations.sort(ordeSectors);
			_tyrDestinations.sort(ordeSectors);
			_sovDestinations.sort(ordeSectors);
			
			_privateDestinations.sort(ordeSectors);

			addHitArea();
			presenter.addOnGenericAllianceMessageRecievedListener(onGenericAllianceMessage);
			presenter.onBattle();
			onResize();
			addEffects();
			effectsIN();
		}

		//============================================================================================================
		//************************************************************************************************************
		//											ENTITY INTERACTION
		//************************************************************************************************************
		//============================================================================================================

		public function popContextMenuFromEntity( x:int, y:int, entity:Entity, selectedEntity:Entity ):void
		{
			var detail:Detail                 = entity.get(Detail);
			var entityPlayer:PlayerVO = presenter.getPlayer(detail.ownerID);
			
			var selectedFleetHP:Number;
			var selectedFleetVO:FleetVO;
			var selectedFleetRating:int;
			var selectedEntityLevel:int;
			if (selectedEntity)
			{
				
				selectedFleetVO = presenter.getFleetVO(selectedEntity.id);
				selectedFleetHP = selectedFleetVO.currentHealth;
				selectedFleetRating = selectedFleetVO.level;
				
				var selectedDetail:Detail = selectedEntity.get(Detail);
				var selectedEntityPlayer:PlayerVO = presenter.getPlayer(selectedDetail.ownerID);
				selectedEntityLevel = selectedEntityPlayer.level;
			}
			// don't allow commands when a fleet is being force recalled
			var forceRecalling:Boolean        = (selectedFleetVO && (selectedFleetVO.state == FleetStateEnum.FORCED_RECALLING));
			var contextMenu:ContextMenu;
			if (detail.category == CategoryEnum.SHIP)
			{
				contextMenu = ObjectPool.get(ContextMenu);
				contextMenu.setup(_contextMenuFleetText, x, y, 150, _stage.stageWidth, _stage.stageHeight);
				if (entity.has(Enemy))
				{
					if (Attack(entity.get(Attack)).inBattle)
					{
						contextMenu.addContextMenuChoice(_contextMenuWatchBattleText, presenter.watchBattle, [entity]);

						var entityAttack:Attack = Attack(entity.get(Attack));
						if (canJoinBattle(entityAttack))
							contextMenu.addContextMenuChoice(_contextMenuJoinBattleText, presenter.attackEntity, [entity]);

					} else if (selectedEntity && selectedFleetHP != 0 && !forceRecalling)
					{
						var isEnabled:Boolean                       = true;
						//Make this work for tackling people he he
						if (Move(entity.get(Move)) && Move(entity.get(Move)).moving)
						   contextMenu.addContextMenuChoice(_contextMenuTackleText, presenter.tackleEntity, [entity]);
						  /* else*/
						
						if(entityPlayer && !entityPlayer.isNPC)
						{
							if(entityPlayer.level < 60 && entityPlayer.level * 3 < selectedEntityLevel * 2)
								isEnabled = false;
							else if(selectedEntityLevel < 60 && selectedEntityLevel * 3 < entityPlayer.level * 2)
								isEnabled = false;
						}
						
						if (Move(entity.get(Move)) && !Move(entity.get(Move)).moving)
							contextMenu.addContextMenuChoice(_contextMenuAttackText, presenter.attackEntity, [entity], isEnabled);
					}
				} else if (entity.has(Owned))
				{
					if (forceRecalling)
					{
						contextMenu.destroy();
						contextMenu = null;
					} else if (!Attack(entity.get(Attack)).inBattle)
						contextMenu.addContextMenuChoice(_contextMenuRecallText, presenter.recallFleet, [entity]);
					else
						contextMenu.addContextMenuChoice(_contextMenuJoinBattleText, presenter.watchBattle, [entity]);
				} else
				{
					if (Attack(entity.get(Attack)).inBattle)
						contextMenu.addContextMenuChoice(_contextMenuWatchBattleText, presenter.watchBattle, [entity]);
				}
			} else if (detail.waypointType != '')
			{
				switch (detail.waypointType)
				{
					case TypeEnum.WAYPOINT_TYPE_COLLECT:
						contextMenu = ObjectPool.get(ContextMenu);
						contextMenu.setup("Mission", x, y, 184, _stage.stageWidth, _stage.stageHeight);
						contextMenu.addContextMenuChoice("Collect", presenter.travelToWaypoint, [presenter.selectedEntity, entity]);
						break;
					case TypeEnum.WAYPOINT_TYPE_ESCORT:
						contextMenu = ObjectPool.get(ContextMenu);
						contextMenu.setup("Mission", x, y, 184, _stage.stageWidth, _stage.stageHeight);
						contextMenu.addContextMenuChoice("Escort", presenter.travelToWaypoint, [presenter.selectedEntity, entity]);
						break;
					case TypeEnum.WAYPOINT_TYPE_SCAN:
						contextMenu = ObjectPool.get(ContextMenu);
						contextMenu.setup("Mission", x, y, 184, _stage.stageWidth, _stage.stageHeight);
						contextMenu.addContextMenuChoice("Scan", presenter.travelToWaypoint, [presenter.selectedEntity, entity]);
						break;
				}

			} else
			{
				switch (detail.type)
				{
					case TypeEnum.STARBASE_SECTOR_IGA:
					case TypeEnum.STARBASE_SECTOR_SOVEREIGNTY:
					case TypeEnum.STARBASE_SECTOR_TYRANNAR:
						if (entity.has(Owned))
						{
							contextMenu = ObjectPool.get(ContextMenu);
							contextMenu.setup(_contextMenuStarbaseText, x, y, 150, _stage.stageWidth, _stage.stageHeight);
							if (selectedEntity && !Attack(entity.get(Attack)).inBattle)
							{
								contextMenu.addContextMenuChoice(_contextMenuRecallText, presenter.recallFleet, [presenter.selectedEntity]);
								if (entityPlayer && !entityPlayer.isNPC && selectedFleetVO && selectedFleetVO.defendTarget != entity.id)
									contextMenu.addContextMenuChoice(_contextMenuDefendText, presenter.defendBase, [presenter.selectedEntity, entity]);
							}
							if (!Attack(entity.get(Attack)).inBattle)
								contextMenu.addContextMenuChoice(_contextMenuEnterText, presenter.enterStarbase, [entity]);
							else
								contextMenu.addContextMenuChoice(_contextMenuJoinBattleText, presenter.watchBattle, [entity]);
						} else if (entity.has(Enemy))
						{
							contextMenu = ObjectPool.get(ContextMenu);
							contextMenu.setup(_contextMenuStarbaseText, x, y, 150, _stage.stageWidth, _stage.stageHeight);
							if (selectedEntity  && !Attack(entity.get(Attack)).bubbled)
							{
								var isEnabled:Boolean                       = true;
								var baseAttackRatingDifferenceLimit:int     = presenter.getConstantPrototypeByName('baseAttackRatingDifferenceLimit');
								var baseAttackFreeForAllRatingThreshold:int = presenter.getConstantPrototypeByName('baseAttackFreeForAllRatingThreshold');
									
								var baseRating:uint								= detail.baseRatingTech;
								if(baseRating == 0)
								{
									baseRating = detail.baseLevel;
								}
								var diff:int                                = selectedFleetRating - baseRating;

								if (entityPlayer && !entityPlayer.isNPC)
								{
									if (diff > baseAttackRatingDifferenceLimit && baseRating < baseAttackFreeForAllRatingThreshold)
										isEnabled = false;
								}
								
								if(entityPlayer && !entityPlayer.isNPC)
								{
									if(entityPlayer.level < 60 && entityPlayer.level * 3 < selectedEntityLevel * 2)
										isEnabled = false;
									else if(selectedEntityLevel < 60 && selectedEntityLevel * 3 < entityPlayer.level * 2)
										isEnabled = false;
								}
								
								if(!Attack(entity.get(Attack)).inBattle)
								{
									contextMenu.addContextMenuChoice(_contextMenuAttackText, presenter.attackEntity, [entity], isEnabled);
								}
								else if (entity.get(Attack).battle)
								{
									if(canJoinBattle(entity.get(Attack)))
									{
										contextMenu.addContextMenuChoice(_contextMenuJoinBattleText, presenter.attackEntity, [entity], isEnabled);
									}
								}
							}
						} else if (Attack(entity.get(Attack)).inBattle)
						{
							contextMenu = ObjectPool.get(ContextMenu);
							contextMenu.setup(_contextMenuStarbaseText, x, y, 150, _stage.stageWidth, _stage.stageHeight);
							contextMenu.addContextMenuChoice(_contextMenuWatchBattleText, presenter.watchBattle, [entity]);
						} else if (!entity.has(Enemy))
						{
							contextMenu = ObjectPool.get(ContextMenu);
							contextMenu.setup(_contextMenuStarbaseText, x, y, 150, _stage.stageWidth, _stage.stageHeight);
							// defend anyone in your faction! what a nice guy you are
							if (selectedEntity && !Attack(entity.get(Attack)).inBattle)
							{
								if (selectedFleetVO && selectedFleetVO.defendTarget != entity.id && !entityPlayer.isNPC)
									contextMenu.addContextMenuChoice(_contextMenuDefendText, presenter.defendBase, [presenter.selectedEntity, entity]);
							}
						}
						break;
					case TypeEnum.TRANSGATE_IGA:
					case TypeEnum.TRANSGATE_SOVEREIGNTY:
					case TypeEnum.TRANSGATE_TYRANNAR:
						
						var transgateC:Transgate = entity.get(Transgate);
						
						contextMenu = ObjectPool.get(ContextMenu);
						contextMenu.setup(_contextMenuTravelText, x, y, 184, _stage.stageWidth, _stage.stageHeight);
						if (selectedEntity)
						{
							var base:BaseVO       = presenter.getBase(selectedFleetVO.starbaseID);
							var mission:MissionVO = presenter.currentMission;
							
							var _centerSpaceDestinations:Vector.<SectorVO>;
							_centerSpaceDestinations = new Vector.<SectorVO>;
							if (transgateC.customDestinationPrototypeGroup.length > 0)
							{
								var transgateCustomDestination:IPrototype = presenter.getTransgateCustomDestinationPrototype(transgateC.customDestinationPrototypeGroup);
								if(transgateCustomDestination)
								{
									var transgateCustomDestinationGroup:Vector.<IPrototype> = presenter.getTransgateCustomDestinationGroupByCustomDestinationGroup(transgateCustomDestination.getValue('transgateCustomDestinationGroup'));
									var customDestination:IPrototype;
									for (var k:int = 0; k < transgateCustomDestinationGroup.length; k++)
									{
										customDestination = transgateCustomDestinationGroup[k];
										var sectorKey:String = customDestination.getValue('sectorKey');
										
										for (var j:uint = 0; j < _privateDestinations.length; j++)
										{
											if (_privateDestinations[j].id != sectorKey)
												continue;
											
											_centerSpaceDestinations.push(_privateDestinations[j]);
										}
										
									}
								}
							}
							//ensure that we have something to add to the context menu
							if (base.sectorID != presenter.sectorID || (_centerSpaceDestinations.length != 0 || _igaDestinations.length != 0 || _tyrDestinations.length != 0 || _sovDestinations.length != 0))
							{
								//see if this transgate is part of a mission
								var len:uint;
								var max:int;
								var defaultIndex:int;
								var currentDestination:SectorVO;
								var loc:Localization = Localization.instance;
								var i:uint           = 0;
								var current:int      = Math.floor((Number(presenter.sectorID.split('.')[1]) - 1) / 3);
							
								len = _centerSpaceDestinations.length;
								if (len > 0)
								{
									if (_uiPresenter.csContextMenuDefaultIndex == -1)
									{
										if (current == 0)
											defaultIndex = current;
										else
										{
											max = len - 1;
											if (current > max)
												defaultIndex = max;
											else
												defaultIndex = current;
										}
									} else
									{
										defaultIndex = _uiPresenter.csContextMenuDefaultIndex;
										max = len - 1;
										if (defaultIndex > max)
											defaultIndex = max;
									}
									
									contextMenu.addContextMenuMultiChoice(FactionEnum.IMPERIUM, defaultIndex, _uiPresenter.setCSContextMenuDefaultIndex);
									for (i = 0; i < len; i++)
									{
										currentDestination = _centerSpaceDestinations[i];
										contextMenu.addChoiceToMultiChoice(FactionEnum.IMPERIUM, loc.getString(currentDestination.sectorName) + " " + loc.
											getString(currentDestination.sectorEnum),
											presenter.travelViaTransgate, [currentDestination.id, presenter.selectedEntity, entity],
											true, "", CommonFunctionUtil.getFactionColor(FactionEnum.IMPERIUM));
									}
									
									//contextMenu.addContextMenuChoice("Go 9001", presenter.travelViaTransgate, ["sector.9001", presenter.selectedEntity, entity]);
								}
								
								
								len = _igaDestinations.length;
								if (len > 0)
								{
									if (_uiPresenter.igaContextMenuDefaultIndex == -1)
									{
										if (current == 0)
											defaultIndex = current;
										else
										{
											max = len - 1;
											if (current > max)
												defaultIndex = max;
											else
												defaultIndex = current;
										}
									} else
									{
										defaultIndex = _uiPresenter.igaContextMenuDefaultIndex;

										max = len - 1;
										if (defaultIndex > max)
											defaultIndex = max;
									}

									contextMenu.addContextMenuMultiChoice(FactionEnum.IGA, defaultIndex, _uiPresenter.setIGAContextMenuDefaultIndex);
									for (i = 0; i < len; i++)
									{
										currentDestination = _igaDestinations[i];
										contextMenu.addChoiceToMultiChoice(currentDestination.sectorFaction, loc.getString(currentDestination.sectorName) + " " + loc.
																		   getString(currentDestination.sectorEnum),
																		   presenter.travelViaTransgate, [currentDestination.id, presenter.selectedEntity, entity],
																		   true, "", CommonFunctionUtil.getFactionColor(currentDestination.sectorFaction));
									}
								}

								len = _tyrDestinations.length;
								if (len > 0)
								{
									if (_uiPresenter.tyrContextMenuDefaultIndex == -1)
									{
										if (current == 0)
											defaultIndex = current;
										else
										{
											max = len - 1;
											if (defaultIndex > max)
												defaultIndex = max;
											else
												defaultIndex = current;
										}
									} else
									{
										defaultIndex = _uiPresenter.tyrContextMenuDefaultIndex;
										max = len - 1;
										if (current > max)
											defaultIndex = max;
									}

									contextMenu.addContextMenuMultiChoice(FactionEnum.TYRANNAR, defaultIndex, _uiPresenter.setTYRContextMenuDefaultIndex);
									for (i = 0; i < len; i++)
									{
										currentDestination = _tyrDestinations[i];
										contextMenu.addChoiceToMultiChoice(currentDestination.sectorFaction, loc.getString(currentDestination.sectorName) + " " + loc.
																		   getString(currentDestination.sectorEnum),
																		   presenter.travelViaTransgate, [currentDestination.id, presenter.selectedEntity, entity],
																		   true, "", CommonFunctionUtil.getFactionColor(currentDestination.sectorFaction));
									}
								}

								len = _sovDestinations.length;
								if (len > 0)
								{
									if (_uiPresenter.sovContextMenuDefaultIndex == -1)
									{
										if (current == 0)
											defaultIndex = current;
										else
										{
											max = len - 1;
											if (current > max)
												defaultIndex = max;
											else
												defaultIndex = current;
										}
									} else
									{
										defaultIndex = _uiPresenter.sovContextMenuDefaultIndex;
										max = len - 1;
										if (defaultIndex > max)
											defaultIndex = max;
									}

									contextMenu.addContextMenuMultiChoice(FactionEnum.SOVEREIGNTY, defaultIndex, _uiPresenter.setSOVContextMenuDefaultIndex);
									for (i = 0; i < len; i++)
									{
										currentDestination = _sovDestinations[i];
										contextMenu.addChoiceToMultiChoice(currentDestination.sectorFaction, loc.getString(currentDestination.sectorName) + " " + loc.
																		   getString(currentDestination.sectorEnum),
																		   presenter.travelViaTransgate, [currentDestination.id, presenter.selectedEntity, entity],
																		   true, "", CommonFunctionUtil.getFactionColor(currentDestination.sectorFaction));
									}
								}
								_centerSpaceDestinations.length = 0;
								_centerSpaceDestinations = null;
								

								// show an option to hop to mission sector if it's not in your sector
								if (mission && mission.accepted && !mission.rewardAccepted && mission.sector != presenter.sectorID)
									contextMenu.addContextMenuChoice(_contextMenuMissionSectorText, presenter.travelViaTransgate, [mission.sector, presenter.selectedEntity, entity]);

								//show the option to recall the fleet if the fleet is now in its' home sector
								if (base.sectorID != presenter.sectorID)
									contextMenu.addContextMenuChoice(_contextMenuRecallText, presenter.recallFleet, [selectedEntity, entity]);
								
								//add check for same faction id with sector id
								if(/*base.sectorID != presenter.sectorID && */CurrentUser.faction == _sectorFaction && presenter.neighborhood >= 0/*&& presenter.sectorID < 9000*/)
									contextMenu.addContextMenuChoice(_contextMenuRelocate, relocateToTransgate, [presenter.sectorID, entity]);
							}
						}
						break;
					case TypeEnum.TRADEDEPOT_IGA:
					case TypeEnum.TRADEDEPOT_SOVEREIGNTY:
					case TypeEnum.TRADEDEPOT_TYRANNAR:
						/*contextMenu = ObjectPool.get(ContextMenu);
						   contextMenu.init('Trade Depot', x, y, _stage.stageWidth, _stage.stageHeight);
						   contextMenu.addContextMenuChoice('Coming Soon!', null, null);*/
						break;
					case TypeEnum.DERELICT_IGA:
					case TypeEnum.DERELICT_SOVEREIGNTY:
					case TypeEnum.DERELICT_TYRANNAR:
						if (selectedEntity && selectedFleetHP != 0)
						{
							contextMenu = ObjectPool.get(ContextMenu);
							contextMenu.setup(_contextMenuDebrisText, x, y, 150, _stage.stageWidth, _stage.stageHeight);
							contextMenu.addContextMenuChoice(_contextMenuLoadCargoText, presenter.lootDerelictFleet, [entity]);
						}
						break;
				}
			}

			if (contextMenu)
			{
				contextMenu.addContextMenuChoice(_contextMenuLinkCoords, linkCoords, [entity]);
				if (CurrentUser.bookmarkCount < MAX_BOOKMARKS)
					contextMenu.addContextMenuChoice(_addBookmark, addBookmark, [entity]);

				if (entityPlayer && !entityPlayer.isNPC && entityPlayer.id != CurrentUser.id)
					contextMenu.addContextMenuChoice(_viewProfile, onViewProfile, [entityPlayer.id]);

				_viewFactory.notify(contextMenu);
			}

		}

		//============================================================================================================
		//************************************************************************************************************
		//													CONTROLS
		//************************************************************************************************************
		//============================================================================================================

		private function onButtonClick( e:MouseEvent ):void
		{
			switch (e.currentTarget)
			{
				case _joinBattleBtn:
					presenter.joinBattle(_battleServerAddress);
					_joinBattleBtn.enabled = false;
					break;
			}
		}

		private function onBattle( entity:Entity, added:Boolean, battleServerAddress:String ):void
		{
			if (added)
			{
				_battleServerAddress = battleServerAddress;
				TweenLite.to(_joinBattleBtn, .2, {alpha:1.0, ease:Quad.easeIn});
			} else
				_joinBattleBtn.alpha = 0;

			_joinBattleBtn.visible = added;
		}

		private function onNotification( type:String, entity:Entity ):void
		{
			switch (type)
			{
				case 'bubble':
					var view:DropBubbleView = DropBubbleView(showView(DropBubbleView, false));
					view.entity = entity;
					_viewFactory.notify(view);
					break;
			}
		}
		private function relocateToTransgate( sectorKey:String, entity:Entity):void
		{
			_relocateSectorKey = sectorKey;
			_relocateTransgateKey = entity.id;
			
			if( CurrentUser.wallet.premium < 100)
			{
				var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
				buttons.push(new ButtonPrototype(_buyBtnText, openPalladiumShop, null, true, ButtonEnum.GOLD_A));
				buttons.push(new ButtonPrototype(_cancelBtnText));
				showConfirmation(_notEnoughPalladiumTitle, _notEnoughPalladiumBody, buttons);
				return;
			}
			
			var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
			buttons.push(new ButtonPrototype(_acceptBtnText, onRelocateToTransgate, null, true, ButtonEnum.GOLD_A));
			buttons.push(new ButtonPrototype(_cancelBtnText));
			showConfirmation(_relocateAlertTitle, _relocateAlertBody, buttons);
		}
		private function openPalladiumShop():void
		{
			CommonFunctionUtil.popPaywall();
		}
		private function onRelocateToTransgate():void
		{
			if(_relocateTransgateKey.length > 0)
				presenter.relocateToTransgate(_relocateSectorKey, _relocateTransgateKey);
		}

		private function linkCoords( entity:Entity ):void
		{
			if (entity)
			{
				var pos:Position = entity.get(Position);
				if (pos && _uiPresenter)
					_uiPresenter.linkCoords(int(pos.x * 0.01), int(pos.y * 0.01));

			}
		}

		private function addBookmark( entity:Entity ):void
		{
			if (entity)
			{
				var pos:Position = entity.get(Position);
				if (pos && _uiPresenter)
					_uiPresenter.addBookmark(pos.x, pos.y);

			}
		}

		private function onViewProfile( playerID:String ):void
		{
			var playerProfileView:PlayerProfileView = PlayerProfileView(_viewFactory.createView(PlayerProfileView));
			playerProfileView.playerKey = playerID;
			_viewFactory.notify(playerProfileView);
		}

		private function onResize( e:Event = null ):void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			var bounds:Rectangle = this.getBounds(this);
			var pos:Number       = MIN_X_POS * Application.SCALE;
			x = (((DeviceMetrics.WIDTH_PIXELS - super.width) * .5 - bounds.x) > pos ? ((DeviceMetrics.WIDTH_PIXELS - super.width) * .5 - bounds.x) : pos);
		}

		private function ordeSectors( sectorOne:SectorVO, sectorTwo:SectorVO ):Number
		{
			if (!sectorOne)
				return -1;
			if (!sectorTwo)
				return 1;

			var sectorOneNumber:int = int(sectorOne.id.substr(7));
			var sectorTwoNumber:int = int(sectorTwo.id.substr(7));

			if (sectorOneNumber > sectorTwoNumber)
				return 1;
			else if (sectorOneNumber < sectorTwoNumber)
				return -1;

			return 0;
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

		private function canJoinBattle( entityAttack:Attack ):Boolean
		{

			//TODO: Client guys, I don't know the client code well enough to do this, so this needs to only pop up in the following circumstances:
			//1) My faction is part of the existing attack AND the number of FLEETS and BASES of that faction already involved is < maxPlayersPerFaction (Can't use players because one player may have both a fleet and a base, and that counts as two)
			//2) My faction is NOT part of the existing attack AND the number of factions currently involved is < maxFactions
			//Note that it IS allowed to join if the number of factions is > maxFactions, but my faction is one of the factions involved
			if (entityAttack)
			{
				var currentBattle:SectorBattleData = entityAttack.battle;
				
				if(currentBattle == null)
					return false;
				
				if(CurrentUser == null)
					return false;
				
				var entities:Array                 = currentBattle.participantFleets.concat(currentBattle.participantBase);
				var canJoin:Boolean                = true;
				var currentPlayer:PlayerVO;
				var i:uint;
				var currentIGACount:int;
				var currentSOVCount:int;
				var currentTYRCount:int;
				var factionCount:int;
				var currentUsersFactionIsPresent:Boolean;

				for (; i < entities.length; ++i)
				{
					if (entities[i] != null && entities[i] != '')
					{
						currentPlayer = presenter.getPlayer(Detail(presenter.getEntity(entities[i]).get(Detail)).ownerID);
						
						if(currentPlayer != null)
						{
							switch (currentPlayer.faction)
							{
								case FactionEnum.IGA:
									++currentIGACount;
									break;
								case FactionEnum.SOVEREIGNTY:
									++currentSOVCount;
									break;
								case FactionEnum.TYRANNAR:
									++currentTYRCount;
									break;
							}
						}
					}
				}

				if (currentIGACount > 0)
				{
					++factionCount;
					if (CurrentUser.faction == FactionEnum.IGA)
					{
						currentUsersFactionIsPresent = true;
						if (currentIGACount > currentBattle.maxPlayersPerFaction)
							canJoin = false;
					}
				}

				if (currentSOVCount > 0)
				{
					++factionCount;
					if (CurrentUser.faction == FactionEnum.SOVEREIGNTY)
					{
						currentUsersFactionIsPresent = true;
						if (currentSOVCount > currentBattle.maxPlayersPerFaction)
							canJoin = false;
					}
				}
				if (currentTYRCount > 0)
				{
					++factionCount;
					if (CurrentUser.faction == FactionEnum.TYRANNAR)
					{
						currentUsersFactionIsPresent = true;
						if (currentTYRCount > currentBattle.maxPlayersPerFaction)
							canJoin = false;
					}
				}

				if (!currentUsersFactionIsPresent && factionCount > currentBattle.maxFactions)
					canJoin = false;

				if (!currentBattle.joinable)
					canJoin = false;

				if (currentBattle.participantPlayers.length > currentBattle.maxPlayersPerFaction * entityAttack.battle.maxFactions)
					canJoin = false;
				
				if (currentBattle.pvp == 0 && currentBattle.firstJoiningFactionPrototype.length > 0 &&  currentBattle.firstJoiningFactionPrototype != CurrentUser.faction)
					canJoin = false;

				return canJoin;
			} else
				return false;
		}

		[Inject]
		public function set stage( value:Stage ):void  { _stage = value; }
		[Inject]
		public function set missionPresenter( v:IMissionPresenter ):void  { _missionPresenter = v; }
		[Inject]
		public function set uiPresenter( v:IUIPresenter ):void  { _uiPresenter = v; }

		override public function destroy():void
		{
			presenter.removeOnGenericAllianceMessageRecievedListener(onGenericAllianceMessage);
			super.destroy();

			_tyrDestinations.length = 0;
			_sovDestinations.length = 0;
			_igaDestinations.length = 0;
			_privateDestinations.length = 0;
			_igaDestinations = _sovDestinations = _tyrDestinations = _privateDestinations = null;

			_joinBattleBtn = UIFactory.destroyButton(_joinBattleBtn);
			_missionPresenter = null;
			_uiPresenter = null;
		}
	}
}
