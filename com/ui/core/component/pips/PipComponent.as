package com.ui.core.component.pips
{
	import com.enum.ui.ButtonEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;

	/**
	 *  The PipComponent provides a convenient way to add pip navigation to the interface. Set 'totalPips'
	 *  equal to the number of pips you want to show. Set the initially selected pip by setting 'selected'
	 *  equal to the desired pip index. Clicking on a pip will dispatch a PipEvent to notify which pip was selected.
	 *  Change the size and spacing of the pips via 'pipSize' and 'spacing'.
	 *
	 *  @author Phillip Reagan
	 *  @langversion ActionScript 3.0
	 *  @playerversion Flash 10.0
	 */
	public class PipComponent extends Sprite
	{
		private static const PIP_UP_COLOR:uint       = 0x111111;
		private static const PIP_DOWN_COLOR:uint     = 0x0F8584;
		private static const PIP_OVER_COLOR:uint     = 0x23A4A2;
		private static const PIP_SELECTED_COLOR:uint = 0x17DBDB;

		private var _pipUpBMD:BitmapData;
		private var _pipDownBMD:BitmapData;
		private var _pipOverBMD:BitmapData;
		private var _pipSelectedBMD:BitmapData;
		private var _pipUnreadBMD:BitmapData;
		private var _pips:Array;
		private var _pooledPips:Array; //keep a list of unused pips in case we need to use them again
		private var _showPips:Boolean;
		private var _showArrows:Boolean;
		private var _arrowLeft:BitmapButton;
		private var _arrowRight:BitmapButton;
		private var _pipUnreadClass:Class;

		private var _totalPips:int;
		public var spacing:Number                    = 4;
		public var pipSize:Number                    = 8;

		public function init( showPips:Boolean, showArrows:Boolean ):void
		{
			_showPips = showPips;
			_showArrows = showArrows;

			var pipUnreadClass:Class = Class(getDefinitionByName(('MotDPipNewBMD')));
			_pipUnreadBMD = BitmapData(new pipUnreadClass());

			_arrowLeft = UIFactory.getButton(ButtonEnum.BACK_ARROW);
			_arrowLeft.addEventListener(MouseEvent.CLICK, onShiftLeft, false, 0, true);
			_arrowLeft.visible = _showArrows;

			_arrowRight = UIFactory.getButton(ButtonEnum.FORWARD_ARROW);
			_arrowRight.x = _arrowLeft.x + _arrowLeft.width + spacing;
			_arrowRight.y = 0;
			_arrowRight.addEventListener(MouseEvent.CLICK, onShiftRight, false, 0, true);
			_arrowRight.visible = _showArrows;

			addChild(_arrowLeft);
			addChild(_arrowRight);
		}

		private function addPip():void
		{
			var pip:BitmapButton = _pooledPips.shift();
			if (!pip)
			{
				pip = new BitmapButton();
				pip.init(_pipUpBMD, _pipOverBMD, _pipDownBMD, _pipDownBMD, _pipSelectedBMD);
				pip.addEventListener(MouseEvent.CLICK, onPipClick, false, 0, true);
			}

			pip.visible = _showPips;
			_pips.push(pip);
			addChild(pip);
		}

		private function removePip():void
		{
			var pip:BitmapButton = _pips.shift();
			removeChild(pip);
			_pooledPips.push(pip);
		}

		private function layout():void
		{
			var len:uint = _pips.length;
			var currentPip:BitmapButton;

			var xPos:int;
			if (_showArrows)
				xPos = _arrowLeft.width + spacing;

			for (var i:uint = 0; i < len; ++i)
			{
				currentPip = _pips[i];
				currentPip.x = xPos;
				if (_showArrows)
					currentPip.y = _arrowRight.y + (_arrowRight.height - currentPip.height) * 0.5;

				xPos += currentPip.width + spacing;
			}

			_arrowRight.x = xPos;
		}

		private function onPipClick( e:MouseEvent ):void
		{
			var index:int = _pips.indexOf(e.currentTarget);
			if (index != -1 && index != selected)
			{
				var oldIndex:int = selected;
				selected = index;
				dispatchEvent(new PipEvent(PipEvent.PIP_CLICKED, index, oldIndex));
				updateArrowState();
			}
		}

		private function onShiftLeft( e:MouseEvent ):void
		{
			var oldIndex:int = selected;
			--selected;
			dispatchEvent(new PipEvent(PipEvent.PIP_CLICKED, selected, oldIndex))
			updateArrowState();
		}

		private function onShiftRight( e:MouseEvent ):void
		{
			var oldIndex:int = selected;
			++selected;
			dispatchEvent(new PipEvent(PipEvent.PIP_CLICKED, selected, oldIndex))
			updateArrowState();
		}

		private function updateArrowState():void
		{
			var selectedValue:int = selected;

			if (selectedValue == -1)
			{
				_arrowRight.enabled = false;
				_arrowLeft.enabled = false;
			} else
			{
				if (selectedValue != (_totalPips - 1))
				{
					if (!_arrowRight.enabled)
						_arrowRight.enabled = true;
				} else
				{
					if (_arrowRight.enabled)
						_arrowRight.enabled = false;
				}

				if (selectedValue != 0)
				{
					if (!_arrowLeft.enabled)
						_arrowLeft.enabled = true;
				} else
				{
					if (_arrowLeft.enabled)
						_arrowLeft.enabled = false;
				}
			}
		}

		private function createPipBitmapData():void
		{
			//			var pip:Sprite = new Sprite();
			//			_pipUpBMD = drawPip(pip, PIP_UP_COLOR);
			//			_pipDownBMD = drawPip(pip, PIP_DOWN_COLOR);
			//			_pipOverBMD = drawPip(pip, PIP_OVER_COLOR);
			//			_pipSelectedBMD = drawPip(pip, PIP_SELECTED_COLOR);
			var pipUp:Class   = Class(getDefinitionByName(('MotDPipNeutralBMD')));
			var pipDown:Class = Class(getDefinitionByName(('MotDPipSelectedBMD')));
			//			var pipSelected:Class          = Class(getDefinitionByName(('MotDPipNeutralBMD')));

			_pipUpBMD = BitmapData(new pipUp());
			_pipDownBMD = BitmapData(new pipDown());
			_pipOverBMD = BitmapData(new pipDown());
			_pipSelectedBMD = BitmapData(new pipDown());
			_pips = [];
			_pooledPips = [];
		}

		//		private function drawPip( pip:Sprite, col:uint ):BitmapData
		//		{
		//			pip.graphics.clear();
		//			pip.graphics.beginFill(col);
		//			pip.graphics.drawCircle(pipSize, pipSize, pipSize);
		//			pip.graphics.endFill();
		//
		//			var bmd:BitmapData = new BitmapData(pip.width, pip.height, true, 0);
		//			bmd.draw(pip, null, null, null, null, true);
		//			return bmd;
		//		}

		public function get totalPips():int  { return _totalPips; }
		public function set totalPips( value:int ):void
		{
			_totalPips = value;
			if (value < 0)
				return;
			if (!_pipUpBMD)
				createPipBitmapData();
			if (value == 1)
				value = 0;
			while (_pips.length > value)
				removePip();
			//reposition
			var pip:BitmapButton;
			for (var i:int = 0; i < _pips.length; i++)
			{
				pip = _pips[i];
				pip.x = (i != 0) ? _pips[i - 1].x + pip.width + spacing : 0;
			}
			while (_pips.length < value)
				addPip();

			updateArrowState();
			layout();
		}

		public function get selected():int
		{
			for (var i:int = 0; i < _pips.length; i++)
			{
				if (_pips[i].selected)
					return i;
			}
			return -1;
		}
		public function set selected( v:int ):void
		{
			for (var i:int = 0; i < _pips.length; i++)
				_pips[i].selected = i == v;

			updateArrowState();
		}

		public function setPipState( idx:uint, isRead:Boolean ):void
		{
			if (isRead)
				BitmapButton(_pips[idx]).updateBackgrounds(_pipUpBMD);
			else
				BitmapButton(_pips[idx]).updateBackgrounds(_pipUnreadBMD);
		}

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);

			if (_pips)
			{
				for (var i:int = 0; i < _pips.length; i++)
					_pips[i].destroy();
				for (i = 0; i < _pooledPips.length; i++)
					_pooledPips[i].destroy();
			}
			_pips = null;
			_pooledPips = null;
			_pipUpBMD = null;
			_pipDownBMD = null;
			_pipOverBMD = null;
			_pipSelectedBMD = null;
		}
	}
}
