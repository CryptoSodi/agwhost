package com.ui.core.component.button
{
	import com.controller.sound.SoundController;
	import com.enum.AudioEnum;
	import com.enum.ui.ButtonEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.label.Label;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class ButtonBase extends Sprite implements IComponent
	{
		protected static const DEFAULT_MARGIN:int = 3;

		protected var _leftMargin:Number          = 0;
		protected var _rightMargin:Number         = 0;
		protected var _bottomMargin:Number        = 0;
		protected var _topMargin:Number           = 0;

		protected var _font:int 				  = -1;
		protected var _label:Label;
		protected var _labelFormat:ButtonLabelFormat;
		protected var _labelType:String;
		protected var _selected:Boolean           = false;
		protected var _selectable:Boolean         = false;
		protected var _state:String;
		protected var _onRollOverSound:String     = 'sounds/sfx/AFX_UI_Mouse2_V001A.mp3';
		protected var _onClickSound:String        = 'sounds/sfx/AFX_UI_Mouse1_V001A.mp3';

		protected function onMouse( e:MouseEvent ):void
		{
			if (mouseEnabled)
			{
				switch (e.type)
				{
					case MouseEvent.MOUSE_DOWN:
						_state = ButtonEnum.STATE_DOWN;
						break;
					case MouseEvent.MOUSE_UP:
						_state = _selected ? ButtonEnum.STATE_SELECTED : ButtonEnum.STATE_OVER;
						if (_onClickSound != '')
							SoundController.instance.playSound(AudioEnum.AFX_MOUSE_DOWN_CLICK_1, 0.5);
						break;
					case MouseEvent.ROLL_OVER:
						_state = (_selected) ? ButtonEnum.STATE_SELECTED : ButtonEnum.STATE_OVER;
						if (_onRollOverSound != '')
							SoundController.instance.playSound(AudioEnum.AFX_MOUSE_DOWN_CLICK_2, 0.5);
						break;
					case MouseEvent.ROLL_OUT:
						_state = (_selected) ? ButtonEnum.STATE_SELECTED : ButtonEnum.STATE_NORMAL;
						break;
					case MouseEvent.CLICK:
						if (_selectable)
						{
							_selected = !_selected;
							_state = _selected ? ButtonEnum.STATE_SELECTED : ButtonEnum.STATE_OVER;
						}
						break;
				}
				showState();
			}
			//e.stopPropagation();
		}

		protected function showState():void  {}

		public function setMargin( horzMargin:Number, vertMargin:Number ):void
		{
			if (_label)
			{
				if (!isNaN(vertMargin))
					vertTxtMargin = vertMargin;

				if (!isNaN(horzMargin))
					horzTxtMargin = horzMargin;

				resizeAndLayoutLabel();
			}
		}

		protected function resizeAndLayoutLabel():void
		{
			_label.setSize(defaultSkinWidth - (_leftMargin + _rightMargin), defaultSkinHeight - (_topMargin + _bottomMargin));
			_label.x = _leftMargin + (defaultSkinWidth - _leftMargin - _rightMargin - _label.width) / 2;
			_label.y = _topMargin + (defaultSkinHeight - _topMargin - _bottomMargin - (_label.height - (_label.height - _label.textHeight) / 2)) / 2;
		}

		public function setSize( width:int, height:int ):void  {}
		public function setLabelSize( width:int, height:int ):void  { if (_label) _label.setSize(width, height); }

		protected function addListeners():void
		{
			addEventListener(MouseEvent.CLICK, onMouse, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, onMouse, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouse, false, 0, true);
			addEventListener(MouseEvent.ROLL_OVER, onMouse, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onMouse, false, 0, true);
		}

		protected function removeListeners():void
		{
			removeEventListener(MouseEvent.CLICK, onMouse);
			removeEventListener(MouseEvent.MOUSE_UP, onMouse);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			removeEventListener(MouseEvent.ROLL_OVER, onMouse);
			removeEventListener(MouseEvent.ROLL_OUT, onMouse);
		}

		public function get defaultSkinWidth():Number  { throw new Error('ButtonBase:[defaultSkinWidth], must be overriden by subclass.'); return null; }
		public function get defaultSkinHeight():Number  { throw new Error('ButtonBase:[defaultSkinHeight], must be overriden by subclass.'); return null; }

		public function get enabled():Boolean  { return mouseEnabled; }
		public function set enabled( value:Boolean ):void
		{
			mouseEnabled = value;
			buttonMode = value;
			_state = value ? ((_selected) ? ButtonEnum.STATE_SELECTED : ButtonEnum.STATE_NORMAL) : (_selected) ? ButtonEnum.STATE_SELECTED : ButtonEnum.STATE_DISABLED;
			showState();
		}

		public function set font( value:int ):void  { _font = value; }
		public function set fontSize( fontSize:int ):void
		{
			if (_label)
			{
				_label.fontSize = fontSize;
				resizeAndLayoutLabel();
			}
		}

		public function get label():Label  { return _label; }
		public function set labelFormat( v:ButtonLabelFormat ):void  { _labelFormat = v; showState(); }
		public function set labelType( v:String ):void  { _labelType = v; }

		public function get selectable():Boolean  { return _selectable; }
		public function set selectable( value:Boolean ):void  { _selectable = value; }

		public function get selected():Boolean  { return _selected; }
		public function set selected( value:Boolean ):void
		{
			_selected = value;
			_state = _selected ? ButtonEnum.STATE_SELECTED : ButtonEnum.STATE_NORMAL;
			if (enabled)
				showState();
		}

		public function set state( value:String ):void  { _state = value; showState(); }

		public function get text():String  { return (_label) ? _label.text : ""; }
		public function set text( msg:String ):void
		{
			if (!_label)
			{
				if (_labelType)
					_label = UIFactory.getLabel(_labelType, 50, 50, 0, 0);
				else if (_font>=0)
					_label = new Label(50, 0, 50, 50, true, _font);
				else
					_label = new Label(50, 0, 50, 50);
				_label.constrictTextToSize = true;
				addChild(_label);
			}
			_label.text = msg;
			resizeAndLayoutLabel();
			showState();
		}

		public function set textColor( color:uint ):void  { if (_label) _label.textColor = color; }

		public function get textColor():uint  { return _label.textColor; }


		public function set horzTxtMargin( horzMargin:Number ):void
		{
			if (_label && !isNaN(horzMargin))
			{
				_leftMargin = _rightMargin = horzMargin;
				resizeAndLayoutLabel();
			}
		}

		public function set vertTxtMargin( vertMargin:Number ):void
		{
			if (_label && !isNaN(vertMargin))
			{
				_topMargin = _bottomMargin = vertMargin;
				resizeAndLayoutLabel();
			}
		}

		public function destroy():void
		{
			hitArea = null;
			_labelFormat = null;
			_labelType = null;
			while (numChildren > 0)
				removeChildAt(0);
			removeListeners();
			_label = UIFactory.destroyLabel(_label);
			x = y = 0;
			alpha = scaleX = scaleY = 1;
			visible = true;
		}
	}
}
