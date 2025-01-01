package com.ui.modal.intro
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.PanelEnum;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.osflash.signals.Signal;

	public class FAQSelectionComponent extends Sprite
	{
		private var _bg:ScaleBitmap;
		private var _hitArea:Sprite;
		private var _scrollRect:Rectangle;
		private var _selection:*;
		private var _extended:Boolean;
		private var _filter:String;
		private var _sort:Number;
		private var _contractBtn:BitmapButton;
		private var _expandBtn:BitmapButton;
		private var _selectionName:Label;
		private var _selectionInfo:Label;

		public var onSizeUpdated:Signal;
		public var onResizeFinish:Signal;
		public var onClicked:Signal;

		public function FAQSelectionComponent()
		{
			onClicked = new Signal(FAQSelectionComponent);
			onSizeUpdated = new Signal();
			onResizeFinish = new Signal(FAQSelectionComponent);

			_bg = UIFactory.getScaleBitmap(PanelEnum.FAQ_SUBJECT_BG);

			_scrollRect = new Rectangle(0, 0, _bg.width, _bg.height);
			this.scrollRect = _scrollRect;

			_selectionName = new Label(20, 0xfbefaf, 90, 20, true);
			_selectionName.allCaps = true;
			_selectionName.autoSize = TextFieldAutoSize.LEFT;
			_selectionName.constrictTextToSize = false;

			_selectionInfo = new Label(13, 0xf0f0f0, 485, 30, true, 1);
			_selectionInfo.constrictTextToSize = false;
			_selectionInfo.multiline = true;
			_selectionInfo.autoSize = TextFieldAutoSize.LEFT;
			_selectionInfo.align = TextFormatAlign.LEFT;

			_contractBtn = UIFactory.getButton(ButtonEnum.FAQ_DOWN_ARROW, 0, 0, 503);
			_contractBtn.addEventListener(MouseEvent.CLICK, onSelectionClick, false, 0, true);

			_expandBtn = UIFactory.getButton(ButtonEnum.FAQ_UP_ARROW, 0, 0, 503);
			_expandBtn.addEventListener(MouseEvent.CLICK, onSelectionClick, false, 0, true);
			_expandBtn.visible = false;


			_hitArea = new Sprite();
			resizeHitArea();

			addChild(_bg);
			addChild(_hitArea);
			addChild(_expandBtn);
			addChild(_contractBtn);
			addChild(_selectionName);
			addChild(_selectionInfo);

			layout();
		}

		private function layout():void
		{
			_selectionName.y = 10;
			_selectionName.x = 6;

			_selectionInfo.y = 40;
			_selectionInfo.x = 8;

			_contractBtn.y = _selectionName.y + (_selectionName.textHeight - _contractBtn.height) * 0.5
			_expandBtn.y = _selectionName.y + (_selectionName.textHeight - _expandBtn.height) * 0.5
		}

		private function resizeHitArea():void
		{
			_hitArea.graphics.clear();
			_hitArea.graphics.beginFill(0x000000, 0.001);
			_hitArea.graphics.drawRect(0, 0, _scrollRect.width, _scrollRect.height);
			_hitArea.graphics.endFill();
			_hitArea.mouseEnabled = false;

			_contractBtn.hitArea = _hitArea;
			_expandBtn.hitArea = _hitArea;
		}

		public function setInfoText( text:String, color:uint ):void
		{
			_selectionInfo.textColor = color;
			_selectionInfo.htmlText = text;
		}

		public function get infoText():String
		{
			return _selectionInfo.text;
		}

		public function set frameName( v:String ):void
		{
			_selectionName.text = v;
			layout();
		}

		public function set selection( v:* ):void
		{
			_selection = v;
		}

		public function get selection():*
		{
			return _selection;
		}

		public function set extended( v:Boolean ):void
		{
			_extended = v;

			_expandBtn.visible = _extended;
			_contractBtn.visible = !_extended;

			TweenLite.killTweensOf(_bg);
			TweenLite.killTweensOf(_scrollRect);

			var height:int            = (_extended) ? (_selectionInfo.y + _selectionInfo.height + 10) : 43;
			var easeFunction:Function = (_extended) ? Quad.easeOut : Quad.easeIn;
			var time:Number           = (_extended) ? 0.4 : 0.3;

			TweenLite.to(_bg, time, {height:height, ease:easeFunction, onComplete:onResizeComplete});
			TweenLite.to(_scrollRect, time, {height:(height + 1), ease:easeFunction, onUpdate:onScrollRectUpdate});

		}

		public function get extended():Boolean
		{
			return _extended;
		}

		public function get sort():Number
		{
			return _sort;
		}

		public function set sort( v:Number ):void
		{
			_sort = v;
		}

		public function get filter():String
		{
			return _filter;
		}

		public function set filter( v:String ):void
		{
			_filter = v;
		}

		override public function get height():Number
		{
			return _bg.height;
		}

		override public function get width():Number
		{
			return _bg.width;
		}

		override public function set width( value:Number ):void
		{
			_bg.width = value;
		}

		override public function set height( value:Number ):void
		{
			_bg.height = value;
		}

		public function get selectionName():String
		{
			return _selectionName.text;
		}

		private function onScrollRectUpdate():void
		{
			this.scrollRect = _scrollRect;
			onSizeUpdated.dispatch();
		}

		private function onResizeComplete():void
		{
			_scrollRect.height = _bg.height + 1;
			this.scrollRect = _scrollRect;
			resizeHitArea();
			onResizeFinish.dispatch(this);
		}

		private function onSelectionClick( e:MouseEvent ):void
		{
			onClicked.dispatch(this);
		}

		public function destroy():void
		{
			_bg = null;
			_hitArea = null;
			_scrollRect = null;
			_selection = null;

			if (_contractBtn)
			{
				_contractBtn.removeEventListener(MouseEvent.CLICK, onSelectionClick);
				_contractBtn.destroy();
			}

			_contractBtn = null;

			if (_expandBtn)
			{
				_expandBtn.removeEventListener(MouseEvent.CLICK, onSelectionClick);
				_expandBtn.destroy();
			}

			_expandBtn = null;

			if (_selectionName)
				_selectionName.destroy();

			_selectionName = null;

			if (_selectionInfo)
				_selectionInfo.destroy();

			_selectionInfo = null;

			if (onClicked)
				onClicked.removeAll();

			onClicked = null;

			if (onSizeUpdated)
				onSizeUpdated.removeAll();

			onSizeUpdated = null;
		}
	}
}
