package com.ui.hud.shared
{
	import com.Application;
	import com.enum.CategoryEnum;
	import com.enum.PositionEnum;
	import com.enum.ToastEnum;
	import com.enum.TypeEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.event.StateEvent;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Owned;
	import com.game.entity.components.shared.Position;
	import com.google.analytics.debug.Panel;
	import com.model.mission.MissionVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerVO;
	import com.presenter.sector.IMiniMapPresenter;
	import com.presenter.shared.IUIPresenter;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.core.effects.EffectFactory;
	import com.ui.hud.sector.bookmarks.BookmarksView;
	import com.ui.modal.settings.SettingsView;
	import com.util.AllegianceUtil;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeStyle;
	import flash.globalization.LocaleID;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	import org.ash.core.Entity;
	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;

	public class MiniMapView extends View
	{
		/** For the minimap */
		private var _bg:Bitmap;
		private var _battery:Bitmap;
		private var _utilityBG:ScaleBitmap;
		private var _target:Sprite;
		private var _mouseTarget:Sprite;
		private var _ownedShipLayer:Sprite;
		private var _nonOwnedShipLayer:Sprite;
		private var _defaultLayer:Sprite;
		private var _bezel:Sprite;
		private var _currentTime:Label;
		private var _coordLabel:Label;
		private var _batteryLife:ProgressBar;

		private var _bookmarksButton:BitmapButton;
		private var _exitCombatButton:BitmapButton;
		private var _findButton:BitmapButton;
		private var _maximizeButton:BitmapButton;
		private var _minimizeButton:BitmapButton;
		private var _missionButton:BitmapButton;
		private var _retreatButton:BitmapButton;
		private var _instancedMissionButton:BitmapButton;
		
		private var _settingsButton:BitmapButton;
		private var _switchStateButton:BitmapButton;

		private var _redFilter:ColorMatrixFilter;
		private var _orangeFilter:ColorMatrixFilter;
		private var _yellowFilter:ColorMatrixFilter;
		private var _greenFilter:ColorMatrixFilter;
		private var _currentFilter:ColorMatrixFilter;

		private var _uiPresenter:IUIPresenter;

		private var _icons:Dictionary;
		private var _bounds:Rectangle;
		private var _mouseDownPoint:Point;
		private var _isDragging:Boolean;
		private var _isDraggingBezel:Boolean;
		private var _tmpBuildingIcon:BitmapData;
		private var _batteryBMD:BitmapData;
		private var _ChargingBatteryBMD:BitmapData;
		private var _currentDate:Date;
		private var _formatter:DateTimeFormatter;
		private var _timer:Timer;

		private var _tooltip:Tooltips;

		private const TARGET_OFFSET_X:Number  = 7;
		private const TARGET_OFFSET_Y:Number  = 29;

		private const BEZEL_ROT_OFFSET:Number = -45;
		private const BEZEL_ROT_RANGE:Number  = 90;

		private const MIN_X_POS:Number        = 1060;

		private var _enterBase:String         = 'CodeString.Controls.ViewBase'; //VIEW BASE
		private var _exitBase:String          = 'CodeString.Controls.ViewMap'; //VIEW MAP
		private var _enterInstancedMission:String = 'CodeString.Controls.EnterInstancedMission'; //ENTER INSTANCED MISSION
		private var _retreat:String           = 'CodeString.Controls.Retreat'; //RETREAT
		private var _findBase:String          = 'CodeString.Controls.FindBase'; //Find Starbase
		private var _fullScreen:String        = 'CodeString.Controls.FullScreen'; //Fullscreen
		private var _bookmarks:String         = 'CodeString.Bookmarks.Title'; //Bookmarks
		private var _minimize:String          = 'CodeString.Controls.Minimize'; //Minimize
		private var _gotoMission:String       = 'CodeString.Controls.GotoMission'; //Go to Mission
		private var _settings:String          = 'CodeString.Controls.Settings'; //Settings

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_currentFilter = _greenFilter = CommonFunctionUtil.getColorMatrixFilter(0x3cf219);
			_yellowFilter = CommonFunctionUtil.getColorMatrixFilter(0xfbe81a);
			_orangeFilter = CommonFunctionUtil.getColorMatrixFilter(0xfa7d0e);
			_redFilter = CommonFunctionUtil.getColorMatrixFilter(0xf81919);

			_batteryBMD = UIFactory.getBitmapData("BatteryBMD");
			_ChargingBatteryBMD = UIFactory.getBitmapData("ChargingBatteryBMD");

			_currentDate = new Date();
			_formatter = new DateTimeFormatter(Application.COUNTRY);
			_formatter.setDateTimePattern('hh:mm a');

			var timeToNextMin:Number = (60 - _currentDate.seconds) * 1000;

			_timer = new Timer(timeToNextMin, 1)
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFirstTimerTick, false, 0, true);
			_timer.start();

			_icons = new Dictionary();

			presenter.addToMiniMapSignal.add(addEntityToMiniMap);
			presenter.clearMiniMapSignal.add(clearMiniMap);
			presenter.removeFromMiniMapSignal.add(removeEntityFromMiniMap);
			presenter.scrollMiniMapSignal.add(repositionAllIcons);

			_bg = UIFactory.getBitmap("MinimapBMD");
			_bg.y = 21;
			_bg.smoothing = true;
			addChild(_bg);

			_utilityBG = UIFactory.getPanel(PanelEnum.CONTAINER_INNER_DARK, 168, 25, 0, -8);
			addChild(_utilityBG);

			_batteryLife = ObjectPool.get(ProgressBar);
			_batteryLife.init(ProgressBar.VERTICAL, UIFactory.getPanel(PanelEnum.STATBAR_GREY, 11, 17), null);
			_batteryLife.setMinMax(0, 1);
			_batteryLife.amount = 0;
			_batteryLife.x = _utilityBG.x + 6;
			_batteryLife.y = _utilityBG.y + 5;
			_batteryLife.filters = [_currentFilter];
			_batteryLife.amount = Application.batteryLife;
			_batteryLife.visible = false;
			addChild(_batteryLife);

			_battery = new Bitmap();
			_battery.x = _utilityBG.x + 5;
			_battery.y = _utilityBG.y + 2;
			_battery.visible = false;

			if (Application.isCharging)
				_battery.bitmapData = _ChargingBatteryBMD;
			else
				_battery.bitmapData = _batteryBMD;

			addChild(_battery);

			_currentTime = new Label(20, 0xacd1ff);
			_currentTime.constrictTextToSize = false;
			_currentTime.align = TextFormatAlign.CENTER;
			updateClock();
			addChild(_currentTime);

			_currentDate.time += timeToNextMin;

			var targetClass:Class    = Class(getDefinitionByName('MiniMapTargetMC'));
			var maskClass:Class      = Class(getDefinitionByName('MiniMapMaskMC'));

			_target = Sprite(new targetClass());
			var mask:Sprite          = Sprite(new maskClass());

			mask.x = TARGET_OFFSET_X;
			mask.y = TARGET_OFFSET_Y;
			mask.cacheAsBitmap = true;
			addChild(mask);
			_target.mask = mask;

			_defaultLayer = new Sprite();
			_target.addChild(_defaultLayer);

			_nonOwnedShipLayer = new Sprite();
			_target.addChild(_nonOwnedShipLayer);

			_ownedShipLayer = new Sprite();
			_target.addChild(_ownedShipLayer);

			_target.x = TARGET_OFFSET_X;
			_target.y = TARGET_OFFSET_Y;
			_target.cacheAsBitmap = true;
			addChildAt(_target, numChildren - 1);

			// We grab this at init because the target's dimensions can change when its children (i.e. the icons) move beyond the visible bounds.
			_bounds = new Rectangle(_target.x, _target.y, _target.width, _target.height);
			presenter.miniMapWidth = _target.width;

			// Cover the minimap with a slightly visible sprite to catch mouse events
			_mouseTarget = new Sprite();
			_mouseTarget.graphics.beginFill(0xffffff, 0.1);
			_mouseTarget.graphics.drawCircle(84, 106, 80);
			_mouseTarget.graphics.endFill();
			addChild(_mouseTarget);

			addListener(_mouseTarget, MouseEvent.MOUSE_DOWN, onMouseDown);
			addListener(_mouseTarget, MouseEvent.MOUSE_UP, onMouseUp);
			addListener(_mouseTarget, MouseEvent.MOUSE_MOVE, onMouseMove);
			addListener(_mouseTarget, MouseEvent.MOUSE_WHEEL, onMouseWheel);
			addListener(_mouseTarget, MouseEvent.MOUSE_OUT, onMouseOut);

			// The bezel, where clicking & dragging the bead can change the zoom level
			_bezel = new Sprite();
			// Spaces out the bezel
			_bezel.graphics.beginFill(0, 0);
			_bezel.graphics.drawRect(0, 0, mask.width >> 1, mask.height >> 1);
			_bezel.graphics.endFill();

			var bead:Sprite          = new Sprite();
			var beadBmp:Bitmap       = UIFactory.getBitmap('ZoomHandleBMD');
			beadBmp.smoothing = true;
			bead.addChild(beadBmp);
			bead.x = (mask.width - bead.width) / 2 + 1;
			bead.y = -bead.height / 2;
			addListener(bead, MouseEvent.MOUSE_DOWN, onMouseDownBezel);
			addListener(bead, MouseEvent.MOUSE_UP, onMouseUpBezel);

			_bezel.addChild(bead);
			_bezel.x = TARGET_OFFSET_X + (mask.width >> 1);
			_bezel.y = TARGET_OFFSET_Y + (mask.height >> 1) + 3;
			_bezel.mouseEnabled = false;
			_bezel.mouseChildren = true;
			addChild(_bezel);
			rotateBezel();

			_coordLabel = UIFactory.getLabel(LabelEnum.H4, _bg.width, 30, 0, _bg.y + _bg.height + 4);
			_coordLabel.textColor = 0xecffff;
			_coordLabel.useLocalization = false;
			addChild(_coordLabel);

			addListener(stage, MouseEvent.MOUSE_MOVE, onMouseMoveStage);
			addListener(stage, MouseEvent.MOUSE_UP, onMouseUpStage);

			_bookmarksButton = UIFactory.getButton(ButtonEnum.ICON_BOOKMARKS, 0, 0, -7, 157);
			_exitCombatButton = UIFactory.getButton(ButtonEnum.RED_A, _bg.width, 40, 0, _bg.y + _bg.height + 16, _exitBase);
			_findButton = UIFactory.getButton(ButtonEnum.ICON_FIND, 0, 0, -25, 128);
			_maximizeButton = UIFactory.getButton(ButtonEnum.ICON_MAXIMIZE, 0, 0, -6, 21);
			_minimizeButton = UIFactory.getButton(ButtonEnum.ICON_MINIMIZE, 0, 0, -6, 21);
			_missionButton = UIFactory.getButton(ButtonEnum.ICON_MISSION, 0, 0, -33, 95);
			_retreatButton = UIFactory.getButton(ButtonEnum.RED_A, _bg.width, 40, 0, _exitCombatButton.y + _exitCombatButton.height + 4, _retreat);
			_settingsButton = UIFactory.getButton(ButtonEnum.ICON_SETTINGS, 0, 0, 142, 21);
			_switchStateButton = UIFactory.getButton(ButtonEnum.BLUE_A, _bg.width, 40, 0, _bg.y + _bg.height + 16, _exitBase);
			_instancedMissionButton = UIFactory.getButton(ButtonEnum.RED_A, _bg.width, 40, 0, _switchStateButton.y + _switchStateButton.height + 4, _enterInstancedMission);
			
			addButton(_bookmarksButton);
			addButton(_exitCombatButton, true);
			removeChild(_exitCombatButton);
			addButton(_findButton);
			addButton(_maximizeButton);
			addButton(_minimizeButton);
			addButton(_missionButton);
			addButton(_retreatButton, true);
			removeChild(_retreatButton);
			addButton(_settingsButton);
			addButton(_switchStateButton, true);
			addButton(_instancedMissionButton, true);
			removeChild(_instancedMissionButton);
			

			var Loc:Localization     = Localization.instance;

			_tooltip.addTooltip(_bookmarksButton, this, null, Loc.getString(_bookmarks));
			_tooltip.addTooltip(_findButton, this, null, Loc.getString(_findBase));
			_tooltip.addTooltip(_maximizeButton, this, null, Loc.getString(_fullScreen));
			_tooltip.addTooltip(_minimizeButton, this, null, Loc.getString(_minimize));
			_tooltip.addTooltip(_missionButton, this, null, Loc.getString(_gotoMission));
			_tooltip.addTooltip(_settingsButton, this, null, Loc.getString(_settings));

			Application.onBatteryChargeChanged.add(updateBatteryLife);

			addHitArea();
			addEffects();
			effectsIN();
			onStageResize();
			onStateChange(Application.STATE);

			visible = !presenter.inFTE;
		}

		private function clickPreventer( e:Event ):void
		{
			e.preventDefault();
			e.stopImmediatePropagation();
		}

		private function addEntityToMiniMap( entity:Entity, quadBounds:Rectangle ):void
		{
			// Entities can straddle multiple grid cells, so we can get multiple add notifs.
			// Only add them the first time we encounter the entity ID, and ignore subsequent ones.
			if (_icons.hasOwnProperty(entity.id))
			{
				return;
			}

			var detail:Detail = entity.get(Detail);
			if (!detail)
				return;

			var isTmpIcon:Boolean;
			var iconClass:Class;
			var layer:Sprite  = _defaultLayer;
			var transgateColor:ColorTransform;

			switch (detail.category)
			{
				case CategoryEnum.SHIP:
					iconClass = Class(getDefinitionByName('MiniMapFleetIconBMD'));
					if (entity.has(Owned))
					{
						layer = _ownedShipLayer;
					} else
					{
						layer = _nonOwnedShipLayer;
					}
					break;

				case CategoryEnum.SECTOR:
					switch (detail.type)
					{
						case TypeEnum.DERELICT_IGA:
						case TypeEnum.DERELICT_SOVEREIGNTY:
						case TypeEnum.DERELICT_TYRANNAR:
							iconClass = Class(getDefinitionByName("MiniMapCargoIconBMP"));
							break;

						case TypeEnum.TRANSGATE_IGA:
							transgateColor = AllegianceUtil.CT_IGA_BASE;
						// intentional fall-through
						case TypeEnum.TRANSGATE_SOVEREIGNTY:
							transgateColor ||= AllegianceUtil.CT_SOVEREIGNTY_BASE;
						// intentional fall-through
						case TypeEnum.TRANSGATE_TYRANNAR:
							transgateColor ||= AllegianceUtil.CT_TYRANNAR_BASE;
							iconClass = Class(getDefinitionByName('SectorFleetTransgateIconBMD'));
							break;

						default:
							iconClass = Class(getDefinitionByName('MiniMapBaseIconBMD'));
					}
					break;

				case CategoryEnum.BUILDING:
				{
					//					iconClass = Class(getDefinitionByName("MiniMapBaseIconBMD"));
					//PR Disabling for the moment. Showing buildings on the minimap is causing a crash when making new 
					//isTmpIcon = true;

					break;
				}

				default:
					// If it's not one of the listed types, it doesn't show up on the minimap.
			}

			if (iconClass || isTmpIcon)
			{
				if (iconClass)
				{
					var bmd:BitmapData = BitmapData(new iconClass());
					var icon:Bitmap    = new Bitmap(bmd);
				}

				else
					icon = new Bitmap(TEMP_buildingIcon);

				if (transgateColor)
					icon.transform.colorTransform = transgateColor;

				else
				{
					var useOwnerColors:Boolean;
					if (detail.type == TypeEnum.STARBASE_SECTOR_IGA || detail.type == TypeEnum.STARBASE_SECTOR_SOVEREIGNTY || detail.type == TypeEnum.STARBASE_SECTOR_TYRANNAR)
					{
						var selectedEntityPlayer:PlayerVO           = presenter.getPlayer(detail.ownerID)
						var baseAttackRatingDifferenceLimit:int     = presenter.getConstantPrototypeByName('baseAttackRatingDifferenceLimit');
						var baseAttackFreeForAllRatingThreshold:int = presenter.getConstantPrototypeByName('baseAttackFreeForAllRatingThreshold');
						var focusedFleetLevel:int                   = presenter.focusedFleetRating;
						var diff:int                                = focusedFleetLevel - detail.baseLevel;

						if (selectedEntityPlayer && !selectedEntityPlayer.isNPC && CurrentUser.faction != selectedEntityPlayer.faction)
						{
							if (diff > baseAttackRatingDifferenceLimit && detail.baseLevel < baseAttackFreeForAllRatingThreshold)
								useOwnerColors = false;
							else
								useOwnerColors = true;
						}
					}

					if (detail.ownerID == CurrentUser.id)
						useOwnerColors = true;

					icon.transform.colorTransform = AllegianceUtil.instance.getEntityColorTransform(entity, useOwnerColors);
				}

				layer.addChild(icon);

				var position:Position = entity.get(Position);
				positionIcon(icon, position);

				var scaleFactor:Number = getScaleFactor();
				(icon as Bitmap).scaleX = scaleFactor;
				(icon as Bitmap).scaleY = scaleFactor;

				_icons[entity.id] = icon;
				_icons[icon] = entity.id;
			}
		}

		private function onButtonClick( e:MouseEvent ):void
		{
			e.preventDefault();
			e.stopPropagation();
			e.stopImmediatePropagation();
			if (!presenter.hudEnabled)
				return;

			switch (e.currentTarget)
			{
				case _bookmarksButton:
					if (!presenter.fteRunning)
						showView(BookmarksView);
					break;
				case _exitCombatButton:
					presenter.showSector();
					break;
				case _findButton:
					presenter.findBase(CurrentUser.id);
					break;
				case _maximizeButton:
					_maximizeButton.visible = false;
					_minimizeButton.visible = true;
					_uiPresenter.toggleFullScreen();
					break;
				case _minimizeButton:
					_maximizeButton.visible = true;
					_minimizeButton.visible = false;
					_uiPresenter.toggleFullScreen();
					break;
				case _missionButton:
					var result:String = presenter.moveToMissionTarget();
					if (result)
						showToast(ToastEnum.WRONG, null, result);
					break;
				case _retreatButton:
					presenter.retreat();
					break;
				case _settingsButton:
					if (!presenter.fteRunning)
						showView(SettingsView);
					break;
				case _switchStateButton:
					if (Application.STATE == StateEvent.GAME_STARBASE)
						presenter.showSector();
					else if (Application.STATE == StateEvent.GAME_SECTOR)
						presenter.enterStarbase();
					break;
				case _instancedMissionButton:
					presenter.enterInstancedMission();
					break
			}
		}

		private function get TEMP_buildingIcon():BitmapData
		{
			if (!_tmpBuildingIcon)
			{
				var s:Shape = new Shape();
				s.graphics.beginFill(0xf0f0f0, 0.5);
				s.graphics.moveTo(10, 0);
				s.graphics.lineTo(0, 5);
				s.graphics.lineTo(10, 10);
				s.graphics.lineTo(20, 5);
				s.graphics.lineTo(10, 0);
				s.graphics.endFill();

				_tmpBuildingIcon = new BitmapData(s.width, s.height, true, 0x00000000);
				_tmpBuildingIcon.draw(s);
			}

			return _tmpBuildingIcon;
		}

		private function removeEntityFromMiniMap( entity:Entity ):void
		{
			var icon:Bitmap = _icons[entity.id];
			if (icon)
			{
				icon.parent.removeChild(icon);
			}

			delete _icons[entity.id];
			delete _icons[icon];
		}

		private function clearMiniMap():void
		{
			for each (var key:* in _icons)
			{
				if (key is Bitmap)
				{
					(key as Bitmap).parent.removeChild(key);
				}
			}

			_icons = new Dictionary();
		}

		private function getScaleFactor():Number
		{
			var scaleFactor:Number = presenter.zoom;
			scaleFactor = scaleFactor < 0.5 ? 0.5 : scaleFactor;
			scaleFactor = scaleFactor > 1.5 ? 1.5 : scaleFactor;
			return scaleFactor;
		}

		private function repositionAllIcons():void
		{
			if (_icons)
			{
				var scaleFactor:Number = getScaleFactor();
				for (var icon:* in _icons)
				{
					if (icon)
					{
						if (icon is Bitmap)
						{
							var id:String     = _icons[icon];
							var entity:Entity = presenter.getEntity(id);
							if (entity)
							{
								var position:Position = entity.get(Position) as Position;
								if (position)
								{
									positionIcon(icon, position);

									(icon as Bitmap).scaleX = scaleFactor;
									(icon as Bitmap).scaleY = scaleFactor;
								}
							}
						}
					}
				}
			}
		}

		private function positionIcon( icon:Bitmap, position:Position ):void
		{
			var coords:Point = presenter.getIconPosition(_bounds.width, _bounds.height, position);

			icon.x = coords.x - (icon.width >> 1);
			icon.y = coords.y - (icon.height >> 1);
		}

		override protected function onMouseDown( event:MouseEvent ):void
		{
			if (event.target == _mouseTarget)
			{
				var hit:Point = new Point(event.localX, event.localY);
				_mouseDownPoint = hit;
				_isDragging = true;
				presenter.mouseDown();
				event.stopImmediatePropagation();
			}
		}

		override protected function onRightMouse( event:MouseEvent ):void
		{
			if (event.target == _mouseTarget)
				event.stopImmediatePropagation();
		}

		private function onMouseUp( event:MouseEvent ):void
		{
			if (_isDraggingBezel)
			{
				_isDragging = _isDraggingBezel = false;
				return;
			}
			_isDragging = false;
			presenter.mouseUp();

			if (!_mouseDownPoint)
				return;

			var xDelta:Number = Math.abs(event.localX - _mouseDownPoint.x);
			var yDelta:Number = Math.abs(event.localY - _mouseDownPoint.y);

			if (xDelta + yDelta <= 3)
			{
				presenter.mouseMove((_bounds.width >> 1) - _mouseDownPoint.x, (_bounds.height >> 1) - _mouseDownPoint.y);
			}
		}

		private function onMouseMove( event:MouseEvent ):void
		{
			if (_isDragging && !_isDraggingBezel)
			{
				presenter.mouseMove(event.localX - _mouseDownPoint.x, event.localY - _mouseDownPoint.y);
			}
		}

		private function onMouseWheel( event:MouseEvent ):void
		{
			presenter.mouseWheel(event.delta);
			repositionAllIcons();
			rotateBezel();
			event.stopImmediatePropagation();
		}

		private function onMouseOut( event:MouseEvent ):void
		{
			_isDragging = false;
		}

		private function onMouseDownBezel( event:MouseEvent ):void
		{
			event.stopImmediatePropagation();
			_isDraggingBezel = true;
			event.stopImmediatePropagation();
		}

		private function onMouseUpBezel( event:MouseEvent ):void
		{
			event.stopImmediatePropagation();
			_isDragging = _isDraggingBezel = false;
		}

		private function onMouseMoveStage( event:MouseEvent ):void
		{
			if (_isDraggingBezel)
			{
				var pt:Point        = _bezel.localToGlobal(new Point(0, 0));
				var angle:Number    = Math.atan2(event.stageY - pt.y, event.stageX - pt.x);
				var angleDeg:Number = (angle / Math.PI) * 180;
				presenter.zoomPercent = (angleDeg + BEZEL_ROT_OFFSET) / BEZEL_ROT_RANGE;
				repositionAllIcons();
				rotateBezel();
			}
		}

		private function onMouseUpStage( event:MouseEvent ):void
		{
			event.stopImmediatePropagation();
			_isDragging = _isDraggingBezel = false;
		}

		private function rotateBezel():void
		{
			// Rotation in degrees
			_bezel.rotation = (presenter.zoomPercent * BEZEL_ROT_RANGE) - BEZEL_ROT_OFFSET;
		}

		override protected function onStateChange( type:String ):void
		{
			presenter.removeListenerToUpdateMission(updateMissionButton);
			switch (type)
			{
				case StateEvent.GAME_BATTLE:
					_bookmarksButton.enabled = _findButton.enabled = _missionButton.enabled = false;
					_coordLabel.visible = _switchStateButton.visible = false;
					if (presenter.isMissionBattle)
					{
						_exitCombatButton.text = _retreat;
						if (presenter.showRetreat)
						{
							_retreatButton.y = _exitCombatButton.y;
							addChild(_retreatButton);
						} else
							addChild(_exitCombatButton);
					} else
					{
						_exitCombatButton.text = _exitBase;
						addChild(_exitCombatButton);
						if (presenter.showRetreat)
						{
							_retreatButton.y = _exitCombatButton.y + _exitCombatButton.height + 4
							addChild(_retreatButton);
						}
					}
					
					if(contains(_instancedMissionButton))
						removeChild(_instancedMissionButton);
					
					break;
				case StateEvent.GAME_SECTOR:
					updateMissionButton();
					_bookmarksButton.enabled = _findButton.enabled = true;
					_switchStateButton.text = _enterBase;
					_coordLabel.visible = _switchStateButton.visible = true;
					_switchStateButton.y = _bg.y + _bg.height + 30;
					if (contains(_exitCombatButton))
						removeChild(_exitCombatButton);
					if (contains(_retreatButton))
						removeChild(_retreatButton);
					
					if(presenter.isInInstancedMission())
					{
						_instancedMissionButton.y = _switchStateButton.y + _switchStateButton.height + 4;
						if(!contains(_instancedMissionButton))
						{
							addChild(_instancedMissionButton);
						}
					}
					else
					{
						if(contains(_instancedMissionButton))
							removeChild(_instancedMissionButton);
					}
					
					presenter.removeListenerOnCoordsUpdate(onCoordsUpdated);
					presenter.addListenerOnCoordsUpdate(onCoordsUpdated);
					presenter.removeSelectionChangeListener(onSelectionChange);
					presenter.addSelectionChangeListener(onSelectionChange);
					presenter.addListenerToUpdateMission(updateMissionButton);
					break;
				case StateEvent.GAME_STARBASE:
					_coordLabel.visible = false;
					_bookmarksButton.enabled = true;
					_findButton.enabled = _missionButton.enabled = false;
					_switchStateButton.text = _exitBase;
					_switchStateButton.visible = true;
					_switchStateButton.y = _bg.y + _bg.height + 16;
					if (contains(_exitCombatButton))
						removeChild(_exitCombatButton);
					if (contains(_retreatButton))
						removeChild(_retreatButton);
					
					if(presenter.isInInstancedMission())
					{
						_instancedMissionButton.y = _switchStateButton.y + _switchStateButton.height + 4;
						if(!contains(_instancedMissionButton))
						{
							addChild(_instancedMissionButton);
						}
					}
					else
					{
						if(contains(_instancedMissionButton))
							removeChild(_instancedMissionButton);
					}
					break;
			}
		}

		private function onCoordsUpdated( x:int, y:int ):void
		{
			_coordLabel.text = Localization.instance.getString(presenter.sectorName) + " " +
				Localization.instance.getString(presenter.sectorEnum) +
				" - " + int(x * 0.01) + "x" + int(y * 0.01) + "";
		}

		override protected function addEffects():void  { _effects.addEffect(EffectFactory.repositionEffect(PositionEnum.RIGHT, PositionEnum.TOP, onStageResize, x, y)); }

		private function onStageResize():void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			var pos:Number = MIN_X_POS * Application.SCALE;
			x = (DeviceMetrics.WIDTH_PIXELS - (_bg.width + 12) * Application.SCALE < pos) ? pos : DeviceMetrics.WIDTH_PIXELS - (12 + _bg.width) * Application.SCALE;
			y = 11 * Application.SCALE;

			_maximizeButton.visible = !_uiPresenter.isFullScreen;
			_minimizeButton.visible = _uiPresenter.isFullScreen;
		}

		private function addButton( btn:BitmapButton, onlyListeners:Boolean = false ):void
		{
			if (!onlyListeners)
			{
				var icon:Bitmap   = Bitmap(btn.getChildAt(0));
				var bitmap:Bitmap = UIFactory.getBitmap("IconCircleBMD");
				bitmap.smoothing = true;
				btn.addChildAt(bitmap, 0);
				icon.x = (bitmap.width - icon.width) * .5;
				icon.y = (bitmap.height - icon.height) * .5;
			}
			addListener(btn, MouseEvent.CLICK, onButtonClick);
			addListener(btn, MouseEvent.MOUSE_DOWN, clickPreventer);
			addListener(btn, MouseEvent.MOUSE_UP, clickPreventer);
			addChild(btn);
		}

		private function onSelectionChange():void
		{
			for (var icon:* in _icons)
			{
				if (icon is Bitmap)
				{
					var id:String     = _icons[icon];
					var entity:Entity = presenter.getEntity(id);
					if (entity)
					{
						var detail:Detail = entity.get(Detail);
						if (!detail)
							continue;

						if (detail.type != TypeEnum.TRANSGATE_IGA && detail.type != TypeEnum.TRANSGATE_SOVEREIGNTY && detail.type != TypeEnum.TRANSGATE_TYRANNAR)
						{
							var useOwnerColors:Boolean = false;
							if (detail.type == TypeEnum.STARBASE_SECTOR_IGA || detail.type == TypeEnum.STARBASE_SECTOR_SOVEREIGNTY || detail.type == TypeEnum.STARBASE_SECTOR_TYRANNAR)
							{
								var selectedEntityPlayer:PlayerVO           = presenter.getPlayer(detail.ownerID)
								var baseAttackRatingDifferenceLimit:int     = presenter.getConstantPrototypeByName('baseAttackRatingDifferenceLimit');
								var baseAttackFreeForAllRatingThreshold:int = presenter.getConstantPrototypeByName('baseAttackFreeForAllRatingThreshold');
								var focusedFleetLevel:int                   = presenter.focusedFleetRating;
								var diff:int                                = focusedFleetLevel - detail.baseLevel;

								if (selectedEntityPlayer && !selectedEntityPlayer.isNPC && CurrentUser.faction != selectedEntityPlayer.faction)
								{
									if (diff > baseAttackRatingDifferenceLimit && detail.baseLevel < baseAttackFreeForAllRatingThreshold)
										useOwnerColors = false;
									else
										useOwnerColors = true;
								}
							}

							if (detail.ownerID == CurrentUser.id)
								useOwnerColors = true;

							(icon as Bitmap).transform.colorTransform = AllegianceUtil.instance.getEntityColorTransform(entity, useOwnerColors);
						}
					}
				}
			}
		}

		private function updateMissionButton():void
		{
			var currentMission:MissionVO = presenter.currentMission;
			if (currentMission)
			{
				_missionButton.enabled = (currentMission.accepted && currentMission.complete) ? false : true;
			} else
				_missionButton.enabled = false;
		}

		private function onFirstTimerTick( e:TimerEvent ):void
		{
			_currentDate = new Date();
			updateClock();
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onFirstTimerTick);
			_timer.reset();
			_timer.repeatCount = 0;
			_timer.delay = 10000;
			_timer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);
			_timer.start();
		}

		private function onTimerTick( e:TimerEvent ):void
		{
			_currentDate = new Date();
			updateClock();
		}

		private function updateClock():void
		{
			_currentTime.text = _formatter.format(_currentDate);
			_currentTime.x = _utilityBG.x + (_utilityBG.width - _currentTime.width) * 0.5;
			_currentTime.y = _utilityBG.y + (_utilityBG.height - _currentTime.textHeight) * 0.5;
		}

		public function updateBatteryLife( charging:Boolean, v:Number ):void
		{
			if (!_battery.visible)
				_battery.visible = true;

			if (!_batteryLife.visible)
				_batteryLife.visible = true;

			if (charging)
				_battery.bitmapData = _ChargingBatteryBMD;
			else
				_battery.bitmapData = _batteryBMD;

			_batteryLife.amount = v;
			var newFilter:ColorMatrixFilter = getBatteryColor(v);
			if (_currentFilter != newFilter)
			{
				_currentFilter = newFilter
				_batteryLife.filters = [_currentFilter];
			}
		}

		private function getBatteryColor( batteryLife:Number ):ColorMatrixFilter
		{

			if (batteryLife >= 0.75)
				return _greenFilter;
			else if (batteryLife >= 0.50)
				return _yellowFilter;
			else if (batteryLife >= 0.25)
				return _orangeFilter;
			else
				return _redFilter;
		}

		override public function get height():Number  { return _bg ? _bg.height * Application.SCALE : this.height * Application.SCALE; }
		override public function get width():Number  { return _bg ? _bg.width * Application.SCALE : this.width * Application.SCALE; }

		[Inject]
		public function set presenter( value:IMiniMapPresenter ):void  { _presenter = value; }
		public function get presenter():IMiniMapPresenter  { return IMiniMapPresenter(_presenter); }

		[Inject]
		public function set uiPresenter( v:IUIPresenter ):void  { _uiPresenter = v; }

		[Inject]
		public function set tooltip( value:Tooltips ):void  { _tooltip = value; }
		
		override public function get screenshotBlocker():Boolean {return true;}

		override public function get type():String  { return ViewEnum.UI }

		override public function destroy():void
		{
			if (_timer.running)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
			}

			_timer = null;

			Application.onBatteryChargeChanged.remove(updateBatteryLife);

			presenter.removeListenerToUpdateMission(updateMissionButton);
			presenter.addToMiniMapSignal.remove(addEntityToMiniMap);
			presenter.removeFromMiniMapSignal.remove(removeEntityFromMiniMap);
			presenter.scrollMiniMapSignal.remove(repositionAllIcons);

			removeListener(_mouseTarget, MouseEvent.MOUSE_DOWN, onMouseDown);
			removeListener(_mouseTarget, MouseEvent.MOUSE_UP, onMouseUp);
			removeListener(_mouseTarget, MouseEvent.MOUSE_MOVE, onMouseMove);
			removeListener(_mouseTarget, MouseEvent.MOUSE_WHEEL, onMouseWheel);
			removeListener(_mouseTarget, MouseEvent.MOUSE_OUT, onMouseOut);

			_tooltip.removeTooltip(null, this);
			_tooltip = null;

			super.destroy();

			_bg = null;
			_battery = null;
			_utilityBG = null;
			_target = null;
			_mouseTarget = null;
			_ownedShipLayer = null;
			_nonOwnedShipLayer = null;
			_defaultLayer = null;
			_bezel = null;

			if (_currentTime)
				_currentTime.destroy();

			_currentTime = null;

			if (_coordLabel)
				_coordLabel.destroy();

			_coordLabel = null;

			if (_batteryLife)
				ObjectPool.give(_batteryLife);

			_coordLabel = null;

			if (_bookmarksButton)
				_bookmarksButton.destroy();

			_bookmarksButton = null;

			if (_exitCombatButton)
				_exitCombatButton.destroy();

			_exitCombatButton = null;

			if (_findButton)
				_findButton.destroy();

			_findButton = null;

			if (_maximizeButton)
				_maximizeButton.destroy();

			_maximizeButton = null;

			if (_minimizeButton)
				_minimizeButton.destroy();

			_minimizeButton = null;

			if (_missionButton)
				_missionButton.destroy();

			_missionButton = null;

			if (_retreatButton)
				_retreatButton.destroy();
			
			if(_instancedMissionButton)
				_instancedMissionButton.destroy();
			
			_instancedMissionButton = null;

			_retreatButton = null;

			if (_settingsButton)
				_settingsButton.destroy();

			_settingsButton = null;

			if (_switchStateButton)
				_switchStateButton.destroy();

			_switchStateButton = null;
		}
	}
}
