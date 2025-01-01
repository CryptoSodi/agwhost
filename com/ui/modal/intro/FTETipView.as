package com.ui.modal.intro
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.presenter.shared.IUIPresenter;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.hud.battle.BattleShipSelectionView;
	import com.ui.hud.battle.BattleUserView;
	import com.ui.hud.shared.ChatView;
	import com.ui.hud.shared.IconDrawerView;
	import com.ui.hud.shared.MiniMapView;
	import com.ui.hud.shared.PlayerView;
	import com.ui.hud.shared.bridge.BridgeView;
	import com.ui.hud.shared.command.CommandView;
	import com.ui.hud.shared.engineering.EngineeringView;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	import org.parade.core.ViewEvent;
	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class FTETipView extends View
	{
		private var _bg:DefaultWindowBG;
		private var _eightsImage:Bitmap;
		private var _skipButton:BitmapButton;
		private var _engageButton:BitmapButton;
		private var _offset:Number          = 0;
		private var _selectedComponent:FAQSelectionComponent;

		private var _titleText:String       = 'CodeString.FTETipView.Title'; //WELCOME TO THE MAELSTROM!
		private var _trainingBtnText:String = 'CodeString.FTETipView.Training'; //TRAINING
		private var _playNowBtnText:String  = 'CodeString.FTETipView.PlayNow'; //PLAY NOW
		private var _tip1Text:String        = 'CodeString.FTETipView.Tip1'; //This sector is controlled by your faction, but beware of attacks by enemy players
		private var _tip2Text:String        = 'CodeString.FTETipView.Tip2'; //Upgrade your base and research new technologies to build stronger ships
		private var _tip3Text:String        = 'CodeString.FTETipView.Tip3'; //The Mission system will guide you, reward you, and challenge you
		private var _tip4Text:String        = 'CodeString.FTETipView.Tip4'; //Do not ignore base defenses! Your protective shield depletes in 7 days
		private var _tip5Text:String        = 'CodeString.FTETipView.Tip5'; //Make use of the <font color='#fac569'>Store</font> (top left) to speed-up your upgrades, research, repair, and ship construction

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(555, 354);
			_bg.x = 286;
			_bg.addTitle(_titleText, 314);
			addListener(_bg.closeButton, MouseEvent.CLICK, onSkipFTEClick);

			_eightsImage = UIFactory.getBitmap('EightsBMD');
			_eightsImage.y = -30;

			_engageButton = UIFactory.getButton(ButtonEnum.GREEN_A, 240, 40, 607, 400, _trainingBtnText, LabelEnum.H1);

			_skipButton = UIFactory.getButton(ButtonEnum.BLUE_A, 240, 40, 310, 400, _playNowBtnText, LabelEnum.H1);

			addListener(_engageButton, MouseEvent.CLICK, onClose);
			addListener(_skipButton, MouseEvent.CLICK, onSkipFTEClick);

			addChild(_bg);
			addChild(_eightsImage);
			addChild(_skipButton);
			addChild(_engageButton);

			createBulletPoint(_tip1Text);
			createBulletPoint(_tip2Text);
			createBulletPoint(_tip3Text);
			createBulletPoint(_tip4Text);
			createBulletPoint(_tip5Text);

			addEffects();
			effectsIN();
		}

		private function createBulletPoint( txt:String ):void
		{
			var img:Bitmap  = PanelFactory.getPanel("FTEBulletBMD");
			img.x = 329;
			img.y = 89 + _offset;

			var label:Label = new Label(16, 0xfffee6, 475, 100, true, 1);
			label.constrictTextToSize = false;
			label.letterSpacing = .75;
			label.multiline = true;
			label.align = TextFormatAlign.LEFT;
			label.leading = -3;
			label.htmlText = txt;
			label.x = img.x + 15;
			label.y = img.y - 5;

			addChild(img)
			addChild(label);
			_offset += label.textHeight + 13;
		}

		override protected function onClose( e:MouseEvent = null ):void
		{
			presenter.fteNextStep();
			destroy();
		}

		private function onSkipFTEClick( e:MouseEvent ):void
		{
			var event:ViewEvent = new ViewEvent(ViewEvent.UNHIDE_VIEWS);
			event.targetClass = [BridgeView, ChatView, IconDrawerView, PlayerView, EngineeringView, MiniMapView, CommandView];
			presenter.dispatch(event);

			presenter.fteSkip();
			destroy();
		}

		override public function get type():String  { return ViewEnum.HOVER; }

		override public function get height():Number  { return _bg.height + 48; }
		override public function get width():Number  { return _bg.width + _bg.x; }

		[Inject]
		public function set presenter( v:IUIPresenter ):void  { _presenter = v; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			super.destroy();
			_bg = null;
			_eightsImage = null;
			_engageButton = null;
		}
	}
}

