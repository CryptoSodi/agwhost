package com.ui.modal.alliances.noalliance
{
	import com.model.alliance.AllianceVO;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;

	public class AllianceEntry extends Sprite
	{
		public var onViewClick:Signal;
		public var onAcceptClick:Signal;

		public static var TYPE_OPEN_ALLIANCE:uint   = 0;
		public static var TYPE_ALLIANCE_INVITE:uint = 1;

		private var _bg:Bitmap;

		private var _name:Label;
		private var _members:Label;

		private var _joinBtn:BitmapButton;
		private var _viewBtn:BitmapButton;

		private var _alliance:AllianceVO;

		private var _isInvite:Boolean;

		private var _acceptBtnText:String           = 'CodeString.Shared.Accept'; //ACCEPT
		private var _joinBtnText:String             = 'CodeString.Shared.Join'; //JOIN
		private var _viewBtnText:String             = 'CodeString.Alliance.View' //VIEW
		private var _outOf:String                   = 'CodeString.Shared.OutOf' //[[Number.MinValue]]/[[Number.MaxValue]]

		public function AllianceEntry( alliance:AllianceVO, index:uint, type:uint )
		{
			onViewClick = new Signal(String);
			onAcceptClick = new Signal(String);

			super();

			if ((index + 1) % 2 == 0)
			{
				_bg = PanelFactory.getScaleBitmapPanel('AllianceMemberRowBMD', 497, 30, new Rectangle(15, 11, 2, 2));
			}

			_isInvite = (type == TYPE_ALLIANCE_INVITE) ? true : false;

			_name = new Label(16, 0xf0f0f0, 361, 39, false);
			_name.constrictTextToSize = false;
			_name.align = TextFormatAlign.LEFT;

			_members = new Label(16, 0xf0f0f0, 48, 39, false);
			_members.constrictTextToSize = false;
			_members.constrictTextToSize = false;
			_members.align = TextFormatAlign.CENTER;

			_viewBtn = ButtonFactory.getBitmapButton('BlueBtnCNeutralBMD', 0, 0, _viewBtnText, 0xf0f0f0, 'BlueBtnCRollOverBMD', 'BlueBtnCSelectedBMD', null, 'BlueBtnCSelectedBMD');
			_viewBtn.scaleX = 0.5;
			_viewBtn.scaleY = 0.75;
			_viewBtn.addEventListener(MouseEvent.CLICK, onViewAllianceClick, false, 0, true);

			_joinBtn = ButtonFactory.getBitmapButton('BlueBtnCNeutralBMD', 0, 0, (_isInvite) ? _acceptBtnText : _joinBtnText, 0xf0f0f0, 'BlueBtnCRollOverBMD', 'BlueBtnCSelectedBMD', null, 'BlueBtnCSelectedBMD');
			_joinBtn.scaleX = 0.5;
			_joinBtn.scaleY = 0.75;
			_joinBtn.addEventListener(MouseEvent.CLICK, onAcceptAllianceClick, false, 0, true);

			if ((index + 1) % 2 == 0)
				addChild(_bg);

			addChild(_name);
			addChild(_members);
			addChild(_viewBtn);
			addChild(_joinBtn);

			update(alliance);
		}

		private function onViewAllianceClick( e:MouseEvent ):void
		{
			if (_alliance)
				onViewClick.dispatch(_alliance.key);
		}

		private function onAcceptAllianceClick( e:MouseEvent ):void
		{
			if (_alliance)
				onAcceptClick.dispatch(_alliance.key);
		}

		public function update( alliance:AllianceVO ):void
		{
			_alliance = alliance;

			_name.text = _alliance.name;
			_members.setTextWithTokens(_outOf, {'[[Number.MinValue]]':alliance.memberCount, '[[Number.MaxValue]]':100});
			layout();
		}

		private function layout():void
		{
			var center:Number = 30 * 0.5 - 11;

			_name.x = 5;
			_name.y = center;

			_members.x = 293;
			_members.y = center;

			_viewBtn.x = 343;
			_viewBtn.y = 5;

			_joinBtn.x = _viewBtn.x + _viewBtn.width + 5;
			_joinBtn.y = 5;
		}

		public function set enabled( v:Boolean ):void
		{
			_joinBtn.enabled = v;
		}

		public function get filterBy():String  { return _alliance.name.toLowerCase(); }
		
		public function get memberCount():int  { return _alliance.memberCount; }

		override public function get height():Number  { return 30; }
		override public function get width():Number  { return 497; }

		public function destroy():void
		{
			if (onAcceptClick)
				onAcceptClick.removeAll();

			onAcceptClick = null;

			if (onViewClick)
				onViewClick.removeAll();

			onViewClick = null;

			_bg = null;

			if (_name)
				_name.destroy();
			_name = null;

			if (_name)
				_name.destroy();
			_name = null;

			if (_members)
				_members.destroy();
			_members = null;


			if (_viewBtn)
				_viewBtn.destroy();
			_viewBtn = null;

			if (_joinBtn)
				_joinBtn.destroy();
			_joinBtn = null;

		}
	}
}
