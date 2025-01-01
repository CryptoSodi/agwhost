package com.ui.hud.shared
{
	import com.Application;
	import com.controller.keyboard.KeyboardKey;
	import com.enum.PositionEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.event.StateEvent;
	import com.model.chat.ChatChannelVO;
	import com.model.chat.ChatPanelVO;
	import com.model.motd.MotDVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerVO;
	import com.presenter.shared.IChatPresenter;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.contextmenu.ContextMenu;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.tab.TabComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.core.effects.EffectFactory;
	import com.ui.modal.alliances.alliance.AllianceView;
	import com.ui.modal.alliances.noalliance.NoAllianceView;
	import com.ui.modal.ignore.IgnoreListView;
	import com.ui.modal.information.MessageOfTheDayView;
	import com.ui.modal.playerinfo.PlayerProfileView;

	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	import org.adobe.utils.StringUtil;
	import org.greensock.TweenLite;
	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;
	
	import com.enum.server.AllianceRankEnum;
	import com.enum.ToastEnum;

	public class ChatView extends View
	{

		public static const SECTOR_TAB:String   = "SectorTab";
		public static const ALLIANCE_TAB:String = "AllianceTab";

		public static const HALF:Number         = 0;
		public static const FULL:Number         = 1;
		public static const MIN:Number          = 2;

		private var _tabs:TabComponent;

		private var _chatLog:Label;
		private var _textInput:Label;
		private var _motd:Label;

		private var _fullBtn:BitmapButton;
		private var _halfBtn:BitmapButton;
		private var _minBtn:BitmapButton;
		private var _ignorePlayerListBtn:BitmapButton;
		private var _unselectedTab:BitmapButton;
		private var _alertedBtn:BitmapButton;

		private var _stage:Stage;

		private var _inputBG:ScaleBitmap;
		private var _chatBG:ScaleBitmap;
		private var _motdBG:ScaleBitmap;

		private var _textAlertColor:uint;

		private var _motdHitArea:Sprite;
		private var _motdHolder:Sprite;
		private var _chatHolder:Sprite;

		private var _scrollbar:VScrollbar;

		private var _scrollRect:Rectangle;

		private var _minYPos:Number;

		private var _currentChatWindowState:uint;
		private var _selectedTab:int;

		private var _chatPanels:Vector.<ChatPanelVO>;
		private var _motdMessages:Vector.<MotDVO>;
		private var _animating:Boolean;
		private var _currentMOTDIndex:int;
		private var shownMOTD:Boolean;

		private var _tooltip:Tooltips;

		private const MIN_Y_POS:Number          = 467;

		private var _enterMessage:String        = 'CodeString.Comms.EnterMessage'; //Enter Message
		private var _block:String               = 'CodeString.ContextMenu.Chat.Block'; //Block
		private var _unblock:String             = 'CodeString.ContextMenu.Chat.Unblock'; //Unblock
		private var _muteString:String          = 'CodeString.ContextMenu.Chat.Mute'; //Mute
		private var _unmute:String              = 'CodeString.ContextMenu.Chat.Unmute'; //Unmute
		private var _viewProfile:String         = 'CodeString.ContextMenu.Chat.ViewProfile'; //View Profile
		private var _sendMessage:String         = 'CodeString.ContextMenu.Shared.SendMessage'; //Send Message

		private var _ignoreListTooltip:String   = 'CodeString.Chat.IgnoreListTooltip'; //Ignored Player List
		
		private var _tooLowAllianceRankText:String  = 'CodeString.Toast.TooLowAllianceRank'; //Too Low Alliance Rank. You need to be promoted first

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_motdHitArea = new Sprite();
			_motdHitArea.graphics.beginFill(0xf0f0f0, 0.0);
			_motdHitArea.graphics.drawRect(0, 0, 461, 30);
			_motdHitArea.graphics.endFill();
			_motdHitArea.x = 9;
			_motdHitArea.y = -24;
			addListener(_motdHitArea, MouseEvent.CLICK, showMotDView);
			addListener(_motdHitArea, MouseEvent.ROLL_OVER, onMOTDRollOver);
			addListener(_motdHitArea, MouseEvent.ROLL_OUT, onMOTDRollOut);

			_motdHolder = new Sprite();
			_motdHolder.mouseEnabled = false;
			_motdHolder.x = _motdHitArea.x;
			_motdHolder.y = _motdHitArea.y;

			_motd = new Label(18, 0xfef9bd, 453, 30);
			_motd.alpha = 0;
			_motd.constrictTextToSize = false;
			_motd.align = TextFormatAlign.LEFT;
			_motd.letterSpacing = 1.5;
			_motdHolder.addChild(_motd);

			_tabs = ObjectPool.get(TabComponent);
			_tabs.init(PanelEnum.CONTAINER_RIGHT_NOTCHED_ARROW, PanelEnum.HEADER_NOTCHED, 515, 156, 32);

			_chatPanels = presenter.chatPanels;
			var len:uint                = _chatPanels.length;
			var xPos:Number;
			var currentPanel:ChatPanelVO;
			var headerToUse:String;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPanel = _chatPanels[i];				
				if (i == 0)
				{
					headerToUse = ButtonEnum.HEADER_NOTCHED;
					_tabs.addTab(String(currentPanel.id), headerToUse, 60, 32, xPos, 0, currentPanel.name, LabelEnum.H2);
				}
				else
				{
					xPos = 61 + (i-1) * 101;
					headerToUse = ButtonEnum.HEADER;
					_tabs.addTab(String(currentPanel.id), headerToUse, 100, 32, xPos, 0, currentPanel.name, LabelEnum.H2);
				}
			}
			_tabs.addSwitchTabListener(onTabSwitched);

			_fullBtn = UIFactory.getButton(ButtonEnum.ICON_WINDOW_HALF, 0, 0, 496, 13);
			_halfBtn = UIFactory.getButton(ButtonEnum.ICON_WINDOW_FULL, 0, 0, 496, 13);
			_minBtn = UIFactory.getButton(ButtonEnum.ICON_WINDOW_MIN, 0, 0, 481, 13);
			_ignorePlayerListBtn = UIFactory.getButton(ButtonEnum.ICON_IGNORE, 0, 0, 5, _tabs.height - 35);
			_halfBtn.visible = false;

			_tooltip.addTooltip(_ignorePlayerListBtn, this, null, Localization.instance.getString(_ignoreListTooltip));

			addListener(_fullBtn, MouseEvent.CLICK, onMouseClick);
			addListener(_halfBtn, MouseEvent.CLICK, onMouseClick);
			addListener(_minBtn, MouseEvent.CLICK, onMouseClick);
			addListener(_ignorePlayerListBtn, MouseEvent.CLICK, popChatContextMenu);

			_inputBG = UIFactory.getPanel(PanelEnum.CONTAINER_NOTCHED, 474, 30);
			_inputBG.x = 35;
			_inputBG.y = _tabs.height - 36;

			_chatHolder = new Sprite();
			_chatHolder.x = 9;
			_chatHolder.y = 45;

			_chatBG = UIFactory.getPanel(PanelEnum.CONTAINER_NOTCHED_RIGHT_SMALL, 487, 107);
			_chatBG.x = 6;
			_chatBG.y = 41;

			_chatLog = new Label(12, 0xf0f0f0, 480, 95, false, 1);
			_chatLog.autoSize = TextFieldAutoSize.LEFT
			_chatLog.align = TextFormatAlign.LEFT;
			_chatLog.selectable = true;
			_chatLog.mouseEnabled = true;
			_chatLog.constrictTextToSize = false;
			_chatLog.multiline = true;
			_chatLog.addEventListener(TextEvent.LINK, onHyperLinkEvent, false, 0, true);
			_chatHolder.addChild(_chatLog);
			_chatLog.y -= 2;

			_scrollRect = new Rectangle(0, 0, 490, 95);
			_scrollRect.y = 0;
			_chatHolder.scrollRect = _scrollRect

			_textInput = new Label(13, 0xbdfefd, 470, 21, true, 1);
			_textInput.text = _enterMessage;
			_textInput.allowInput = true;
			_textInput.clearOnFocusIn = true;
			_textInput.letterSpacing = .8;
			_textInput.addLabelColor(0xbdfefd, 0x000000);
			_textInput.x = 40;
			_textInput.y = _tabs.height - 33;
			addListener(_textInput, FocusEvent.FOCUS_IN, onInputGainedFocus);
			addListener(_textInput, FocusEvent.FOCUS_OUT, onInputLostFocus);

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(5, 5, 2, 2);
			var scrollbarXPos:Number    = _tabs.width - 21;
			var scrollbarYPos:Number    = _chatBG.y;
			_scrollbar.init(7, _chatBG.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollBarBMD', '', true, this, _chatHolder);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateDisplayedHeight(_chatBG.height);
			_scrollbar.updateScrollableHeight(_chatLog.textHeight);
			_scrollbar.maxScroll = 16;

			_keyboard.addKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);

			addChild(_tabs);
			addChild(_fullBtn);
			addChild(_halfBtn);
			addChild(_minBtn);
			addChild(_ignorePlayerListBtn);
			addChild(_inputBG);
			addChild(_motdHitArea);
			addChild(_motdHolder);
			addChild(_textInput);
			addChild(_scrollbar);
			addChild(_chatBG);
			addChild(_chatHolder);

			_motdMessages = presenter.motdMessages;
			if (_motdMessages && _motdMessages.length > 0)
			{
				_motdHitArea.buttonMode = true;
				startMOTDFade();
			}

			presenter.addMotDUpdatedListener(onNewMOTDMessageAdded);
			presenter.addChatListener(onChatUpdate);
			presenter.addOnDefaultChannelUpdatedListener(onDefaultChannelUpdated);
			_tabs.setSelectedTab('0');

			addEffects();
			effectsIN();
			onResize();

			visible = !presenter.inFTE;
		}

		//============================================================================================================
		//************************************************************************************************************
		//												GENERAL
		//************************************************************************************************************
		//============================================================================================================

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.LEFT, PositionEnum.BOTTOM, onResize));
		}

		private function onTabSwitched( name:String ):void
		{
			var panelIndex:int = int(name);
			if (_selectedTab != panelIndex)
			{

				if ((panelIndex == 3 || panelIndex == 4) && CurrentUser.alliance == '')
				{
					_tabs.setSelectedTab('0');
					var noAllianceView:NoAllianceView = NoAllianceView(_viewFactory.createView(NoAllianceView));
					_viewFactory.notify(noAllianceView);
				}
				else if (panelIndex == 4 && CurrentUser.allianceRank < AllianceRankEnum.MEMBER)
				{
					_tabs.setSelectedTab('3');
					showToast(ToastEnum.WRONG, null, _tooLowAllianceRankText);
				} else
				{
					_selectedTab = int(name);
					var selectedTab:ChatPanelVO;
					if (_selectedTab < _chatPanels.length)
					{
						selectedTab = _chatPanels[_selectedTab];
						presenter.defaultChannel = selectedTab.defaultSendChannel;
						onChatUpdate(_selectedTab, presenter.getPanelLogs(_selectedTab), false);
					}

					if (_alertedBtn)
						TweenLite.killTweensOf(_alertedBtn);

				}
			}

		}

		private function selectChannel( selectedChannelArgs:Array ):void
		{
			var currentChannel:ChatChannelVO = selectedChannelArgs[0];
			if (currentChannel != null)
			{
				var color:uint = selectedChannelArgs[0].channelColor;
				_textInput.updateLabelColor(color);
				_textInput.updateLabelSelectionColor(color);
				presenter.defaultChannel = currentChannel;
			}
		}

		private function onDefaultChannelUpdated( v:ChatChannelVO ):void
		{
			var color:uint = v.channelColor;
			_textInput.updateInputText(v.displayName);
			_textInput.updateLabelColor(color);
			_textInput.updateLabelSelectionColor(color);
		}

		private function onEnterPress( keyCode:uint ):void
		{
			if (!presenter.hudEnabled)
				return;
			if (_stage.focus == null || _stage.focus == _textInput || _stage.focus == Application.STAGE)
			{
				if (_stage.focus != _textInput)
				{
					_stage.focus = _textInput;
					_textInput.setSelection(_textInput.length, _textInput.length);
				} else
				{
					if (_textInput.text != '')
					{
						presenter.sendChatMessage(StringUtil.escapeHTML(_textInput.text));
						_textInput.text = '';
					}
				}
			}
		}

		private function onChatUpdate( panelID:int, chat:String, update:Boolean ):void
		{
			if (_selectedTab == panelID)
			{
				_chatLog.htmlText = chat;
				_scrollbar.updateScrollableHeight(_chatLog.textHeight);
				if (_scrollbar.percent == 1)
				{
					onChangedScroll(_scrollbar.percent);
				}
			} else
			{
				_alertedBtn = _tabs.getTab(panelID.toString());
				_textAlertColor = _alertedBtn.textColor;
				onFadeOut();
			}
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_chatLog.textHeight - _scrollRect.height) * percent;
			_chatHolder.scrollRect = _scrollRect;
		}

		private function onResize():void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			var yPos:Number;
			switch (_currentChatWindowState)
			{
				case HALF:
				case FULL:
					yPos = DeviceMetrics.HEIGHT_PIXELS - (_tabs.height * Application.SCALE);
					break;
				case MIN:
					yPos = DeviceMetrics.HEIGHT_PIXELS - (33 * Application.SCALE);
					break;
			}

			y = (yPos < MIN_Y_POS) ? MIN_Y_POS : yPos;
		}

		private function popChatContextMenu( e:MouseEvent ):void
		{
			if (!presenter.hudEnabled)
				return;
			_viewFactory.notify(IgnoreListView(_viewFactory.createView(IgnoreListView)));
			e.stopPropagation();
		}

		private function onInputGainedFocus( e:FocusEvent ):void  { presenter.chatHasFocus = true; }
		private function onInputLostFocus( e:FocusEvent ):void  { presenter.chatHasFocus = false; }

		//============================================================================================================
		//************************************************************************************************************
		//										CHAT WINDOW MANIPULATION
		//************************************************************************************************************
		//============================================================================================================

		private function onMouseClick( e:MouseEvent ):void
		{
			if (!presenter.hudEnabled)
				return;
			switch (e.target)
			{
				case _fullBtn:
					updateWindowState(FULL);
					TweenLite.to(_tabs, .2, {height:249, onUpdate:onMoveTweenUpdate, overwrite:0});
					TweenLite.to(_chatBG, .2, {height:200, overwrite:0});
					TweenLite.to(_scrollRect, .2, {height:178, onUpdate:onScrollRectUpdate, onComplete:onTweenComplete, overwrite:0});
					break;
				case _halfBtn:
					updateWindowState(HALF);
					TweenLite.to(_tabs, .2, {height:156, onUpdate:onMoveTweenUpdate, overwrite:0});
					TweenLite.to(_chatBG, .2, {height:107, overwrite:0});
					TweenLite.to(_scrollRect, .2, {height:90, onUpdate:onScrollRectUpdate, onComplete:onTweenComplete, overwrite:0});
					break;
				case _minBtn:
					updateWindowState(MIN);
					TweenLite.to(_tabs, .2, {height:24, onUpdate:onMoveTweenUpdate, overwrite:0});
					TweenLite.to(_chatBG, .2, {height:1, overwrite:0});
					TweenLite.to(_scrollRect, .2, {height:1, onUpdate:onScrollRectUpdate, onComplete:onTweenComplete, overwrite:0});
					break;
			}
			e.stopPropagation();
		}

		private function onFadeOut():void
		{
			if (_alertedBtn)
			{
				_alertedBtn.textColor = 0xfff2dd;
				TweenLite.to(_alertedBtn, 0.5, {onComplete:onFadeIn});
			}
		}

		private function onFadeIn():void
		{
			if (_alertedBtn)
			{
				_alertedBtn.textColor = _textAlertColor;
				TweenLite.to(_alertedBtn, 0.5, {onComplete:onFadeOut});
			}
		}

		private function onMoveTweenUpdate():void
		{
			var yPos:Number;
			if (_currentChatWindowState == MIN)
			{
				var displayObject:DisplayObject = _tabs.panelBG;
				yPos = DeviceMetrics.HEIGHT_PIXELS - (displayObject.height * Application.SCALE);
				y = (yPos < MIN_Y_POS) ? MIN_Y_POS : yPos;
			} else
			{
				_inputBG.y = _tabs.height - 36;
				_textInput.y = _tabs.height - 33;
				_ignorePlayerListBtn.y = _tabs.height - 35;
				yPos = DeviceMetrics.HEIGHT_PIXELS - (_tabs.height * Application.SCALE);
				y = (yPos < MIN_Y_POS) ? MIN_Y_POS : yPos;
			}

		}

		private function onScrollRectUpdate():void
		{
			_chatHolder.scrollRect = _scrollRect;
		}

		private function updateWindowState( newState:uint ):void
		{
			_currentChatWindowState = newState;

			_scrollbar.visible = false;
			switch (_currentChatWindowState)
			{
				case HALF:
					_halfBtn.visible = false;

					_minBtn.x = 481;
					_minBtn.visible = true;

					_fullBtn.x = 496;
					_fullBtn.visible = true;
					break;
				case FULL:
					_fullBtn.visible = false;

					_minBtn.x = 481;
					_minBtn.visible = true;

					_halfBtn.x = 496;
					_halfBtn.visible = true;
					break;
				case MIN:
					_minBtn.visible = false;

					_halfBtn.x = 481;
					_halfBtn.visible = true;

					_fullBtn.x = 496;
					_fullBtn.visible = true;
					break;
			}
			TweenLite.killTweensOf(_tabs);
		}

		private function onScrollUp( e:MouseEvent ):void
		{
			_scrollbar.scrollUp();
		}

		private function onScrollDown( e:MouseEvent ):void
		{
			_scrollbar.scrollDown();
		}

		private function onTweenComplete():void
		{
			_chatHolder.y = 55;
			_scrollRect.y = (_chatLog.textHeight - _scrollRect.height) * _scrollbar.percent;
			_chatHolder.scrollRect = _scrollRect;

			_scrollbar.updateScrollbarHeight(_chatBG.height);
			_scrollbar.updateScrollableHeight(_chatLog.textHeight);
			_scrollbar.updateDisplayedHeight(_chatBG.height);

			_scrollbar.visible = true;

			if (_currentChatWindowState == MIN)
			{
				var newYPos:Number = DeviceMetrics.HEIGHT_PIXELS - (33 * Application.SCALE);
				y = (newYPos < MIN_Y_POS) ? MIN_Y_POS : newYPos;
			}
		}

		override protected function onStateChange( state:String ):void
		{
			if (state == StateEvent.GAME_BATTLE)
			{
				TweenLite.killTweensOf(_motd);
				_motd.visible = false;
			} else
			{
				_motd.visible = true;
				startMOTDFade();
			}
		}

		//============================================================================================================
		//************************************************************************************************************
		//											CHAT HYPERLINKS
		//************************************************************************************************************
		//============================================================================================================

		private function onHyperLinkEvent( e:TextEvent ):void
		{
			e.stopPropagation();
			var indexToSplitAt:int = e.text.indexOf('.');
			if (indexToSplitAt != -1 && e.text.length > (indexToSplitAt + 1))
			{
				var linkType:String = e.text.slice(0, indexToSplitAt);
				var text:String = e.text.slice(indexToSplitAt + 1);
				if(linkType == "NameLink")
				{			
					if (text.indexOf(':') != -1)
					{
						var nameLinkArgs:Array = text.split(':');
						var playerName:String  = nameLinkArgs[1];
						var playerKey:String   = nameLinkArgs[0];
	
						if (CurrentUser.id != playerKey)
						{
							var currentPlayer:PlayerVO  = presenter.getPlayer(playerKey);
							var target:*                = e.target;
							var parent:*                = e.target.parent;
	
							var location:Point          = new Point(parent.mouseX, parent.mouseY);
							location = parent.localToGlobal(location);
	
							var nameContext:ContextMenu = ObjectPool.get(ContextMenu);
							nameContext.setup(playerName, location.x, location.y, 150, DeviceMetrics.WIDTH_PIXELS, DeviceMetrics.HEIGHT_PIXELS);
							if (presenter.isBlocked(playerKey))
							{
								nameContext.addContextMenuChoice(_unblock, onBlockPlayer, [playerKey]);
							} else
							{
								nameContext.addContextMenuChoice(_block, onBlockPlayer, [playerKey]);
							}
	
	
							if (presenter.isMuted(playerKey))
							{
								nameContext.addContextMenuChoice(_unmute, onMutePlayer, [playerKey]);
							} else
							{
								nameContext.addContextMenuChoice(_muteString, onMutePlayer, [playerKey]);
							}
							nameContext.addContextMenuChoice(_viewProfile, onViewProfile, [playerKey]);
							_viewFactory.notify(nameContext);
						} else
						{
							onViewProfile(CurrentUser.id);
						}
					}
				}
				else if (linkType == "AllianceLink")
				{
					onViewAlliance("alliance." + text);
				}
				else if (linkType == "CoordLink")
				{
					if (!presenter.inFTE)
					{
						var coords:Array = text.split(',');
						presenter.gotoCoords(int(coords[0] * 100), int(coords[1] * 100), coords[2]);
					}
				}
			}
		}

		private function onBlockPlayer( playerID:String ):void
		{
			presenter.blockOrUnblockPlayer(playerID);
		}

		private function onMutePlayer( playerID:String ):void
		{
			presenter.mutePlayer(playerID);
		}

		private function onViewProfile( playerID:String ):void
		{
			var playerProfileView:PlayerProfileView = PlayerProfileView(_viewFactory.createView(PlayerProfileView));
			playerProfileView.playerKey = playerID;
			_viewFactory.notify(playerProfileView);
		}
		
		private function onViewAlliance( allianceKey:String ):void
		{
			var allianceView:AllianceView = AllianceView(_viewFactory.createView(AllianceView));
			allianceView.allianceKey = allianceKey;
			_viewFactory.notify(allianceView);
		}

		//============================================================================================================
		//************************************************************************************************************
		//												MOTD
		//************************************************************************************************************
		//============================================================================================================

		private function onMOTDRollOut( e:MouseEvent ):void
		{
			_motd.textColor = 0xfef9bd;
		}

		private function onMOTDRollOver( e:MouseEvent ):void
		{
			_motd.textColor = 0xffffe6;
		}

		private function showMotDView( e:MouseEvent = null ):void
		{
			if (_motdMessages && _motdMessages.length > 0)
			{
				var view:MessageOfTheDayView = MessageOfTheDayView(_viewFactory.createView(MessageOfTheDayView));
				_viewFactory.notify(view);
			}
			e.stopPropagation();
		}

		private function onNewMOTDMessageAdded( motd:Vector.<MotDVO> ):void
		{
			_motdMessages = presenter.motdMessages;

			if (_animating)
				_currentMOTDIndex = -1;
			else
			{
				_motdHitArea.buttonMode = true;
				startMOTDFade();
			}

		/*if (!presenter.inFTE && !StarbaseCommand.shownMOTD)
		   {
		   presenter.dispatch(new StarbaseEvent(StarbaseEvent.WELCOME_BACK));
		   }*/
		}

		private function startMOTDFade():void
		{
			if (_motdMessages && _motdMessages.length > 0)
			{
				_animating = true;
				_currentMOTDIndex = 0;
				_motd.text = _motdMessages[_currentMOTDIndex].title;
				TweenLite.to(_motd, 2.0, {alpha:1.0, onComplete:onMOTDFadeInComplete})
			}
		}

		private function onMOTDFadeInComplete():void
		{
			TweenLite.to(_motd, 2.0, {alpha:0.0, onComplete:onMOTDTweenComplete, delay:10.0})
		}

		private function onMOTDTweenComplete():void
		{
			++_currentMOTDIndex;
			if (_currentMOTDIndex >= _motdMessages.length || _currentMOTDIndex < 0)
				_currentMOTDIndex = 0;

			_motd.text = _motdMessages[_currentMOTDIndex].title;
			TweenLite.to(_motd, 2.0, {alpha:1.0, onComplete:onMOTDFadeInComplete})
		}

		//============================================================================================================
		//************************************************************************************************************
		//										GENERAL VIEW
		//************************************************************************************************************
		//============================================================================================================

		[Inject]
		public function set presenter( value:IChatPresenter ):void  { _presenter = value; }
		public function get presenter():IChatPresenter  { return IChatPresenter(_presenter); }

		[Inject]
		public function set stage( value:Stage ):void  { _stage = value; }

		[Inject]
		public function set tooltip( value:Tooltips ):void  { _tooltip = value; }

		override public function get height():Number  { return _tabs.height * Application.SCALE; }
		override public function get width():Number  { return _tabs.width * Application.SCALE; }

		override public function get type():String  { return ViewEnum.UI }
		
		override public function get screenshotBlocker():Boolean {return true;}

		override public function destroy():void
		{
			_keyboard.removeKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);
			presenter.removeChatListener(onChatUpdate);
			presenter.removeMotDUpdatedListener(onNewMOTDMessageAdded);
			presenter.removeOnDefaultChannelUpdatedListener(onDefaultChannelUpdated);

			super.destroy();

			if (_tabs)
			{
				_tabs.removeSwitchTabListener(onTabSwitched);
				_tabs.destroy();
			}

			_tabs = null;

			if (_chatLog)
				_chatLog.destroy();

			_chatLog = null;

			if (_textInput)
				_textInput.destroy();

			_textInput = null;

			if (_motd)
			{
				TweenLite.killTweensOf(_motd);
				_motd.destroy();
			}

			_motd = null;

			if (_fullBtn)
			{
				removeListener(_fullBtn, MouseEvent.CLICK, onMouseClick);
				_fullBtn.destroy();
			}

			_fullBtn = null;

			if (_halfBtn)
			{
				removeListener(_halfBtn, MouseEvent.CLICK, onMouseClick);
				_halfBtn.destroy();
			}

			_halfBtn = null;

			if (_minBtn)
			{
				removeListener(_minBtn, MouseEvent.CLICK, onMouseClick);
				_minBtn.destroy();
			}

			_minBtn = null;

			if (_ignorePlayerListBtn)
			{
				removeListener(_ignorePlayerListBtn, MouseEvent.CLICK, popChatContextMenu);
			}

			_ignorePlayerListBtn = null;

			_alertedBtn = null;

			_stage = null;

			_inputBG = null;
			_chatBG = null;
			_motdBG = null;

			_motdHolder = null;
			_chatHolder = null;

			if (_scrollbar)
				_scrollbar.destroy();

			_scrollbar = null;

			_scrollRect = null;

			if (_keyboard)
				_keyboard.removeKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);

			_keyboard = null;

		}

	}
}
