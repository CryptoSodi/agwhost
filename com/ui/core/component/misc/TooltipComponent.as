package com.ui.core.component.misc
{
	import com.enum.ui.LabelEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.label.Label;

	import flash.display.Sprite;
	import flash.text.TextFormatAlign;

	public class TooltipComponent extends Sprite implements IComponent
	{
		private var _numCols:int;
		private var _tipLabels:Vector.<Label>;
		private var _tipStrings:Vector.<String>

		public function TooltipComponent()
		{
			super();

			_tipLabels = new Vector.<Label>;
			_tipStrings = new Vector.<String>;
		}

		public function init( numCols:int = 1, labelWidth:int = 100, labelHeight:int = 100, fontSize:int = 12, labelFont:String = 'Open Sans' ):void
		{
			_numCols = numCols;

			var label:Label;
			for (var i:int = 0; i < numCols; i++)
			{
				label = UIFactory.getLabel((labelFont == "Open Sans") ? LabelEnum.DEFAULT_OPEN_SANS : LabelEnum.DEFAULT, labelWidth / numCols, labelHeight);
				label.align = TextFormatAlign.LEFT;
				label.fontSize = fontSize;
				label.constrictTextToSize = false;
				label.multiline = true;
				_tipLabels.push(label);
			}
		}

		public function layoutTooltip( tooltip:String, dx:int = 0, dy:int = 0, padding:int = 6, leading:int = 0 ):void
		{
			if (tooltip)
			{
				var i:int                  = 0
				var endTag:String;
				var count:int              = 0;
				var oldIdx:int             = 0;
				var elementsPerCol:int     = 0;

				//Clear out old strings; otherwise, they just keep getting added if the window isn't closed
				_tipStrings.length = 0;

				for (i = 0; i <= tooltip.length; i++)
				{
					endTag = tooltip.substr(i, 6);

					if (endTag == '<br/>\n')
					{
						if (oldIdx != 0)
							oldIdx += 6;

						_tipStrings.push(tooltip.substring(oldIdx, i + 5));

						oldIdx = i;

						count++;

					}
				}

				elementsPerCol = Math.ceil(count / _numCols);
				var unevenElements:Boolean = false;
				//If the elements are uneven we need to account for that in the last column
				if ((count % _numCols) != 0)
					unevenElements = true;


				for (i = 0; i < _numCols; i++)
				{
					//Make sure labels don't have any left over text
					_tipLabels[i].text = _tipLabels[i].htmlText = '';

					//Set up leading for the tooltip
					_tipLabels[i].htmlText += '<textformat leading="' + leading + '">';
					for (var j:int = 0; j < elementsPerCol; j++)
					{
						if (unevenElements && _numCols == 3 && i == (_numCols - 1) && j == (elementsPerCol - 2))
							break;

						if (j + elementsPerCol * i < _tipStrings.length)
							Label(_tipLabels[i]).htmlText += _tipStrings[j + elementsPerCol * i];

						if (unevenElements && _numCols == 2 && i == (_numCols - 1) && j == (elementsPerCol - 2))
							break;

					}
					//Close leading tag
					_tipLabels[i].htmlText += '</textformat>';

					if (i != 0)
						_tipLabels[i].x = dx + Label(_tipLabels[i - 1]).width * i + padding;
					else
						_tipLabels[i].x = dx;
					_tipLabels[i].y = dy;


					addChild(_tipLabels[i]);
				}
			}
		}

		public function get enabled():Boolean  { return false; }
		public function set enabled( value:Boolean ):void  {}

		public function destroy():void
		{
			for each (var label:Label in _tipLabels)
			{
				if (contains(label))
					removeChild(label);
					//UIFactory.destroyLabel(label);
			}

			_tipLabels.length = 0;
			_tipStrings.length = 0;
			x = y = 0;
			visible = true;
		}
	}
}
