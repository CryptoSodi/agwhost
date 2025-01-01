package com.ui.hud.shared.engineering
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.enum.StarbaseCategoryEnum;
	import com.enum.TypeEnum;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.event.TransactionEvent;
	import com.event.signal.TransactionSignal;
	import com.model.transaction.TransactionVO;
	import com.presenter.shared.IEngineeringPresenter;
	import com.ui.core.View;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.core.effects.EffectFactory;
	import com.ui.modal.construction.ConstructionInfoView;
	import com.ui.modal.construction.ConstructionView;
	import com.ui.modal.dock.DockView;
	import com.ui.modal.shipyard.ShipyardView;
	import com.ui.modal.store.StoreView;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	import org.parade.core.IView;
	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;

	public class EngineeringView extends View
	{
		public static const BUILD:int       = 0;
		public static const DOCK:int        = 1;
		public static const RESEARCH:int    = 2;
		public static const SHIPYARD:int    = 3;

		private var _buildGroup:EngineerGroup;
		private var _count:int;
		private var _dockGroup:EngineerGroup;
		private var _researchGroup:EngineerGroup;
		private var _shipyardGroup:EngineerGroup;
		private var _timer:Timer;
		private var _tooltip:Tooltips;

		private const MIN_X_POS:Number      = 385;

		private var _buffDescription:String = 'CodeString.EngineeringView.BuffInfo'; //Click here to get more buffs
		private var _buildText:String       = 'CodeString.Controls.Build'; //BUILD
		private var _fleetsText:String      = 'CodeString.Controls.Fleets'; //FLEETS
		private var _researchText:String    = 'CodeString.Controls.Research'; //RESEARCH
		private var _shipyardText:String    = 'CodeString.Controls.Shipyard'; //SHIPYARD

		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addTransactionListener(TransactionSignal.TRANSACTION_UPDATED, onTransactionUpdated);
			presenter.addTransactionListener(TransactionSignal.TRANSACTION_REMOVED, onTransactionRemoved);
			y = 4;
			_count = 0;
			//initialize groups
			_buildGroup = ObjectPool.get(EngineerGroup);
			_buildGroup.init(BUILD, _buildText, presenter);
			_buildGroup.addActionListener(onGroupAction);
			_buildGroup.canDragExpand = !presenter.inFTE;

			_dockGroup = ObjectPool.get(EngineerGroup);
			_dockGroup.init(DOCK, _fleetsText, presenter);
			_dockGroup.addActionListener(onGroupAction);
			_dockGroup.canDragExpand = !presenter.inFTE;

			_researchGroup = ObjectPool.get(EngineerGroup);
			_researchGroup.init(RESEARCH, _researchText, presenter);
			_researchGroup.addActionListener(onGroupAction);
			_researchGroup.canDragExpand = !presenter.inFTE;

			_shipyardGroup = ObjectPool.get(EngineerGroup);
			_shipyardGroup.init(SHIPYARD, _shipyardText, presenter);
			_shipyardGroup.addActionListener(onGroupAction);
			_shipyardGroup.canDragExpand = !presenter.inFTE;

			//position groups
			_researchGroup.x = _buildGroup.x + _buildGroup.width + 6;
			_shipyardGroup.x = _researchGroup.x + _researchGroup.width + 6;
			_dockGroup.x = _shipyardGroup.x + _shipyardGroup.width + 6;

			//transaction update timer
			_timer = new Timer(1000);
			addListener(_timer, TimerEvent.TIMER, onTimer);

			//add to the display list
			addChild(_buildGroup);
			addChild(_dockGroup);
			addChild(_researchGroup);
			addChild(_shipyardGroup);

			//initialize with the existing transactions
			var transactions:Dictionary = presenter.transactions;
			for each (var transaction:TransactionVO in transactions)
				onTransactionUpdated(transaction);

			//show the view
			onStageResized();
			addHitArea();
			addEffects();
			effectsIN();

			visible = !presenter.inFTE;
		}

		private function onTransactionUpdated( transaction:TransactionVO ):void
		{
			var group:EngineerGroup = getGroupForTransaction(transaction);
			if (group)
			{
				_count += group.addTransaction(transaction);
				if (!_timer.running && _count > 0)
					_timer.start();
			}
		}

		private function onTransactionRemoved( transaction:TransactionVO ):void
		{
			var group:EngineerGroup = getGroupForTransaction(transaction);
			if (group)
			{
				_count -= group.removeTransaction(transaction);
				if (_count == 0)
					_timer.reset();
			}
		}

		private function getGroupForTransaction( transaction:TransactionVO ):EngineerGroup
		{
			if (transaction.timeMS <= 0)
				return null;
			switch (transaction.type)
			{
				case TransactionEvent.STARBASE_BUILD_SHIP:
				case TransactionEvent.STARBASE_REFIT_SHIP:
					return _shipyardGroup;

				case TransactionEvent.STARBASE_BUILDING_BUILD:
				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
				case TransactionEvent.STARBASE_REFIT_BUILDING:
				case TransactionEvent.STARBASE_REPAIR_BASE:
					return _buildGroup;

				case TransactionEvent.STARBASE_REPAIR_FLEET:
					return _dockGroup;

				case TransactionEvent.STARBASE_RESEARCH:
					return _researchGroup;
			}

			return null;
		}

		private function onGroupAction( id:int, type:int, index:int, transaction:TransactionVO ):void
		{
			if (!presenter.hudEnabled)
				return;
			if (transaction)
			{
				var storeView:StoreView = StoreView(showView(StoreView));
				storeView.setSelectedTransaction(transaction);
			} else
			{
				var hasBuilding:Boolean;
				var view:IView;
				switch (id)
				{
					case BUILD:
						switch (type)
						{
							case GroupTray.STARBASE_BUILD:
								if (Application.STATE == StateEvent.GAME_STARBASE)
								{
									view = _viewFactory.createView(ConstructionView);
									ConstructionView(view).openOn(ConstructionView.BUILD, index == 0 ? StarbaseCategoryEnum.INFRASTRUCTURE : StarbaseCategoryEnum.DEFENSE, null);
									_viewFactory.notify(view);
								} else
									enterStarbase(ConstructionView, {type:ConstructionView.BUILD, groupID:(index == 0 ? StarbaseCategoryEnum.INFRASTRUCTURE : StarbaseCategoryEnum.DEFENSE)});
								break;
							default:
								if (Application.STATE == StateEvent.GAME_STARBASE)
								{
									view = _viewFactory.createView(ConstructionView);
									ConstructionView(view).openOn(ConstructionView.BUILD, null, null);
									_viewFactory.notify(view);
								} else
									enterStarbase(ConstructionView, {type:ConstructionView.BUILD, groupID:StarbaseCategoryEnum.INFRASTRUCTURE});
								break;
						}
						break;
					case DOCK:
						showView(DockView);
						break;
					case RESEARCH:
						switch (type)
						{
							case GroupTray.RESEARCH_A:
								hasBuilding = presenter.getBuildingCount(index == 0 ? TypeEnum.WEAPONS_FACILITY : TypeEnum.ADVANCED_TECH) > 0;
								if (Application.STATE == StateEvent.GAME_STARBASE)
								{
									if (!hasBuilding)
									{
										view = _viewFactory.createView(ConstructionInfoView);
										ConstructionInfoView(view).setup(ConstructionView.BUILD,
																		 presenter.getBuildingPrototypeByClassAndLevel(index == 0 ? TypeEnum.WEAPONS_FACILITY : TypeEnum.ADVANCED_TECH, 1));
										_viewFactory.notify(view);
									} else
									{
										view = _viewFactory.createView(ConstructionView);
										ConstructionView(view).openOn(ConstructionView.RESEARCH, index == 0 ? TypeEnum.WEAPONS_FACILITY : TypeEnum.ADVANCED_TECH, null);
										_viewFactory.notify(view);
									}
								} else
								{
									if (!hasBuilding)
										enterStarbase(ConstructionInfoView, {type:ConstructionView.BUILD,
														  proto:presenter.getBuildingPrototypeByClassAndLevel(index == 0 ? TypeEnum.WEAPONS_FACILITY : TypeEnum.ADVANCED_TECH, 1)});
									else
										enterStarbase(ConstructionView, {type:ConstructionView.RESEARCH, groupID:(index == 0 ? TypeEnum.WEAPONS_FACILITY : TypeEnum.ADVANCED_TECH)});
								}
								break;
							case GroupTray.RESEARCH_B:
								hasBuilding = presenter.getBuildingCount(index == 0 ? TypeEnum.DEFENSE_DESIGN : TypeEnum.SHIPYARD) > 0;
								if (Application.STATE == StateEvent.GAME_STARBASE)
								{
									if (!hasBuilding)
									{
										view = _viewFactory.createView(ConstructionInfoView);
										ConstructionInfoView(view).setup(ConstructionView.BUILD,
																		 presenter.getBuildingPrototypeByClassAndLevel(index == 0 ? TypeEnum.DEFENSE_DESIGN : TypeEnum.SHIPYARD, 1));
										_viewFactory.notify(view);
									} else
									{
										view = _viewFactory.createView(ConstructionView);
										ConstructionView(view).openOn(ConstructionView.RESEARCH, index == 0 ? TypeEnum.DEFENSE_DESIGN : TypeEnum.SHIPYARD, null);
										_viewFactory.notify(view);
									}
								} else
								{
									if (!hasBuilding)
										enterStarbase(ConstructionInfoView, {type:ConstructionView.BUILD,
														  proto:presenter.getBuildingPrototypeByClassAndLevel(index == 0 ? TypeEnum.DEFENSE_DESIGN : TypeEnum.SHIPYARD, 1)});
									else
										enterStarbase(ConstructionView, {type:ConstructionView.RESEARCH, groupID:(index == 0 ? TypeEnum.DEFENSE_DESIGN : TypeEnum.SHIPYARD)});
								}
								break;
							default:
								if (Application.STATE == StateEvent.GAME_STARBASE)
								{
									view = _viewFactory.createView(ConstructionView);
									ConstructionView(view).openOn(ConstructionView.RESEARCH, null, null);
									_viewFactory.notify(view);
								} else
									enterStarbase(ConstructionView, {type:ConstructionView.RESEARCH});
								break;
						}
						break;
					case SHIPYARD:
						if (Application.STATE == StateEvent.GAME_STARBASE)
							showView(ShipyardView);
						else
							enterStarbase(ShipyardView, null);
						break;
				}
			}
		}

		override protected function onStateChange( state:String ):void
		{
			if (state == StateEvent.GAME_BATTLE)
				destroy();
		}

		private function onTimer( e:TimerEvent ):void
		{
			_buildGroup.updateTransactionTime();
			_dockGroup.updateTransactionTime();
			_researchGroup.updateTransactionTime();
			_shipyardGroup.updateTransactionTime();
		}

		private function enterStarbase( view:Class, viewData:* ):void
		{
			var starbaseEvent:StarbaseEvent = new StarbaseEvent(StarbaseEvent.ENTER_BASE);
			starbaseEvent.view = view;
			starbaseEvent.viewData = viewData;
			presenter.dispatch(starbaseEvent);
		}

		override protected function addEffects():void  { _effects.addEffect(EffectFactory.repositionEffect(PositionEnum.CENTER, PositionEnum.TOP, onStageResized)); }

		private function onStageResized( e:Event = null ):void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			var bounds:Rectangle = this.getBounds(this);
			var pos:Number       = MIN_X_POS * Application.SCALE;
			x = (((DeviceMetrics.WIDTH_PIXELS - super.width) * .5 - bounds.x) > pos ? ((DeviceMetrics.WIDTH_PIXELS - super.width) * .5 - bounds.x) : pos);
		}

		override public function get height():Number  { return super.height * Application.SCALE; }
		override public function get width():Number  { return super.width * Application.SCALE; }

		[Inject]
		public function set presenter( value:IEngineeringPresenter ):void  { _presenter = value; }
		public function get presenter():IEngineeringPresenter  { return IEngineeringPresenter(_presenter); }

		[Inject]
		public function set tooltip( value:Tooltips ):void  { _tooltip = value; }

		override public function get type():String  { return ViewEnum.UI }
		override public function get screenshotBlocker():Boolean {return true;}

		override public function destroy():void
		{
			presenter.removeTransactionListener(onTransactionUpdated);
			presenter.removeTransactionListener(onTransactionRemoved);

			super.destroy();

			ObjectPool.give(_buildGroup);
			_buildGroup = null;
			ObjectPool.give(_dockGroup);
			_dockGroup = null;
			ObjectPool.give(_researchGroup);
			_researchGroup = null;
			ObjectPool.give(_shipyardGroup);
			_shipyardGroup = null;

			_timer.reset();
			_timer = null;

			_tooltip.removeTooltip(null, this);
			_tooltip = null;
		}
	}
}
