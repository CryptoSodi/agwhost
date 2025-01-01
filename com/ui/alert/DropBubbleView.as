package com.ui.alert
{
	import com.presenter.sector.ISectorPresenter;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	import org.ash.core.Entity;
	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class DropBubbleView extends View
	{
		public var entity:Entity;

		private var _bg:Bitmap;
		private var _body:Label;
		private var _closeButton:BitmapButton;
		private var _retreatButton:BitmapButton;
		private var _attackButton:BitmapButton;
		private var _margin:int         = 30;
		private var _title:Label;

		private var _titleText:String   = 'CodeString.BubbleDropView.Title'; //PROTECTION ALERT
		private var _bodyText:String    = 'CodeString.BubbleDropView.Body'; //You will lose your base protection if you attack this base. <br\><br\>Are you sure you wish to continue?
		private var _retreatText:String = 'CodeString.BubbleDropView.Retreat'; //Retreat
		private var _attackText:String  = 'CodeString.BubbleDropView.Attack'; //Attack

		[PostConstruct]
		public override function init():void
		{
			super.init();
			_bg = PanelFactory.getPanel("WindowContextMenuBMD");

			_title = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DIALOG_TITLE, _bg.width - _margin);
			_title.align = TextFormatAlign.LEFT;
			_title.text = _titleText;
			_title.x = _margin;
			_title.y = 13;

			_body = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DYNAMIC, _bg.width - 2 * _margin - 10, 18);
			_body.align = TextFormatAlign.CENTER;
			_body.constrictTextToSize = false;
			_body.leading = -4;
			_body.multiline = true;
			_body.htmlText = _bodyText;
			_body.setSize(_body.width, _body.textHeight);
			_body.x = _margin;
			_body.y = 65;

			_closeButton = ButtonFactory.getCloseButton(_bg.width - 40, 15);

			_retreatButton = ButtonFactory.getBitmapButton('LeftBtnUpBMD', x, y, _retreatText, 0xFFFFFFF, 'LeftBtnRollOverBMD', 'LeftBtnDownBMD', '', '', 12, 0);
			_retreatButton.x = (_bg.width * .5) - _retreatButton.width - _margin;
			_retreatButton.y = _bg.height - _retreatButton.height - _margin;

			_attackButton = ButtonFactory.getBitmapButton('RightBtnUpBMD', x, y, _attackText, 0xFFFFFFF, 'RightBtnRollOverBMD', 'RightBtnDownBMD', '', '', 12, 0);
			_attackButton.x = (_bg.width * .5) + _margin;
			_attackButton.y = _retreatButton.y;

			addListener(_closeButton, MouseEvent.CLICK, onClose);
			addListener(_retreatButton, MouseEvent.CLICK, onClose);
			addListener(_attackButton, MouseEvent.CLICK, onAttack);

			addChild(_bg);
			addChild(_title);
			addChild(_body);
			addChild(_closeButton);
			addChild(_retreatButton);
			addChild(_attackButton);

			addEffects();
			effectsIN();
		}

		private function onAttack( e:MouseEvent ):void
		{
			presenter.attackEntity(entity, true);
			destroy();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:ISectorPresenter ):void  { _presenter = value; }
		public function get presenter():ISectorPresenter  { return ISectorPresenter(_presenter); }

		override public function get type():String  { return ViewEnum.ALERT; }
		override public function get typeUnique():Boolean  { return true; }

		override public function destroy():void
		{
			super.destroy();

			entity = null;
			_bg = null;
			_body.destroy();
			_body = null;
			ObjectPool.give(_closeButton);
			_closeButton = null;
			ObjectPool.give(_retreatButton);
			_retreatButton = null;
			ObjectPool.give(_attackButton);
			_attackButton = null;
			_title.destroy();
			_title = null;
		}
	}
}
