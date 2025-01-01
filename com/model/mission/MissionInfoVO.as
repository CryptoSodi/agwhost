package com.model.mission
{
	public class MissionInfoVO
	{
		public var alloyReward:uint;
		public var creditReward:uint;
		public var energyReward:uint;
		public var syntheticReward:uint;
		public var palladiumCurrencyReward:uint;

		public var blueprintReward:Boolean;

		public var currentProgress:int   = 0;
		public var progressRequired:int  = 0;

		private var _dialogStrings:Array = [];
		private var _soundStrings:Array = [];
		private var _smallImages:Array   = [];
		private var _mediumImages:Array  = [];
		private var _largeImages:Array   = [];
		private var _npcTitle:Array      = [];
		private var _objectives:Array    = [];
		private var _titleColor:uint     = 0xffffff;

		public function addDialog( v:String ):void  { _dialogStrings.push(v); }
		public function addSound( v:String ):void  { _soundStrings.push(v); }
		public function addImages( small:String, medium:String, large:String ):void
		{
			_smallImages.push(small);
			_mediumImages.push(medium);
			_largeImages.push(large);
		}
		public function addObjective( v:String ):void  { _objectives.push(v); }
		public function addTitle( v:String, color:uint = 0xffffff ):void  { _npcTitle.push(v); _titleColor = color; }

		public function get hasDialog():Boolean  { return _dialogStrings.length > 0; }
		public function get hasSound():Boolean  { return _soundStrings.length > 0; }
		public function get hasImage():Boolean  { return _smallImages.length > 0; }
		public function get hasObjectives():Boolean  { return _objectives.length > 0; }
		public function get hasTitle():Boolean  { return _npcTitle.length > 0; }

		public function get dialog():String
		{
			if (_dialogStrings.length > 0)
				return _dialogStrings.shift();
			return '';
		}
		public function get sound():String
		{
			if (_soundStrings.length > 0)
				return _soundStrings.shift();
			return '';
		}

		public function get smallImage():String
		{
			if (_smallImages.length > 0)
			{
				_mediumImages.unshift();
				_largeImages.shift();
				return _smallImages.shift();
			}
			return '';
		}

		public function get mediumImage():String
		{
			if (_mediumImages.length > 0)
			{
				_smallImages.shift();
				_largeImages.shift();
				return _mediumImages.shift();
			}
			return '';
		}

		public function get largeImage():String
		{
			if (_largeImages.length > 0)
			{
				_smallImages.shift();
				_mediumImages.shift();
				return _largeImages.shift();
			}
			return '';
		}

		public function get npcTitle():String
		{
			if (_npcTitle.length > 0)
				return _npcTitle.shift();
			return '';
		}

		public function get objective():String
		{
			if (_objectives.length > 0)
				return _objectives.shift();
			return '';
		}

		public function get titleColor():uint  { return _titleColor; }

		public function destroy():void
		{
			currentProgress = 0;
			_dialogStrings.length = 0;
			_soundStrings.length = 0;
			_smallImages.length = 0;
			_mediumImages.length = 0;
			_largeImages.length = 0;
			_npcTitle.length = 0;
			_objectives.length = 0;
			progressRequired = 0;
		}
	}
}
