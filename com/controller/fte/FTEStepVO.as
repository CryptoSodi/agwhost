package com.controller.fte
{
	import com.model.prototype.IPrototype;
	import com.service.language.Localization;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;

	public class FTEStepVO
	{
		private var _arrowPosition:Point;
		private var _arrowRotation:Number = -1;
		private var _currentStep:int      = 0;
		private var _cutout:Rectangle;
		private var _step:IPrototype;
		private var _steps:Vector.<IPrototype>;

		public function init( steps:Vector.<IPrototype> ):void  { _steps = steps; }

		public function updateStep( currentStep:int ):void
		{
			if (currentStep < _steps.length)
			{
				_currentStep = currentStep;
				_step = _steps[currentStep];

				var coords:Array;
				//set the cutout
				if (_step.getValue('cutoutCoordinates') != '' && _step.getValue('cutoutCoordinates') != null)
				{
					coords = String(_step.getValue('cutoutCoordinates')).split(',');
					_cutout = new Rectangle(coords[0], coords[1], coords[2], coords[3]);
				} else
					_cutout = null;

				//set the arrow position
				if (_step.getValue('arrowCoordinates') != '' && _step.getValue('arrowCoordinates') != null)
				{
					coords = String(_step.getValue('arrowCoordinates')).split(',');
					_arrowPosition = new Point(coords[0], coords[1]);
					_arrowRotation = coords[2];
				} else
					_arrowPosition = null;
			}
		}

		public function unescape( str:String ):String
		{
			return str.replace(/\\n/g, '\n');
		}

		public function get anchor():Boolean  { return _step.getValue('anchor'); }
		public function get arrowPosition():Point  { return _arrowPosition; }
		public function set arrowPosition( v:Point ):void  { _arrowPosition = v; }
		public function get arrowRotation():Number  { return _arrowRotation; }
		public function set arrowRotation( v:Number ):void  { _arrowRotation = v; }
		public function get currentStep():int  { return _currentStep; }
		public function get cutout():Rectangle  { return _cutout; }
		public function set cutout( v:Rectangle ):void  { _cutout = v; }
		public function get dialog():String  { return unescape(Localization.instance.getString(_step.getValue('dialogString'))); }
		public function get audioDir():String  { return _step.getValue('dialogAudioString'); }
		public function get titleText():String  { return Localization.instance.getString(_step.getValue('dialogString') + '.Title'); }
		public function get missionName():String  { return _step.getValue('missionName'); }
		public function get mood():int  { return _step.getValue('mood'); }
		public function get platform():String  { return _step.getValue('platform'); }
		public function get step():IPrototype  { return _step; }
		public function get stepId():int  { return _step.getValue("stepId"); }
		public function get timeDelay():int  { return _step.getValue('timeDelay'); }
		public function get totalSteps():int  { return _steps.length; }
		public function get trigger():String
		{
			if (_step.getValue('trigger') == "" || _step.getValue('trigger') == null)
				return null;
			return _step.getValue('trigger');
		}

		public function get viewClass():Class
		{
			if (_step.getValue('uiID') != "" && _step.getValue('uiID') != null)
			{
				try
				{
					return Class(getDefinitionByName(_step.getValue('uiID')));
				} catch ( e:Error )
				{
					//just do nothing
				}
			}
			return null;
		}
		public function get voiceOver():String  { return _step.getValue('voID'); }

		public function get name():String  { return _step.getUnsafeValue('name'); }
	}
}
