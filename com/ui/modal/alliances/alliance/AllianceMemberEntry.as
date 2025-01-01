package com.ui.modal.alliances.alliance
{
	import com.enum.server.AllianceRankEnum;
	import com.model.alliance.AllianceMemberVO;
	import com.model.player.CurrentUser;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;

	public class AllianceMemberEntry extends Sprite
	{
		private var _bg:Bitmap;

		private var _name:Label;
		private var _rank:Label;
		private var _level:Label;

		private var _promoteBtn:BitmapButton;
		private var _demoteBtn:BitmapButton;
		private var _removeBtn:BitmapButton;

		private var _member:AllianceMemberVO;
		private var _allianceKey:String;

		public var onPromoteMember:Signal;
		public var onDemoteMember:Signal;
		public var onRemoveMember:Signal;
		public var onShowProfile:Signal;

		private var WIDTH:Number  = 460;
		private var HEIGHT:Number = 25;

		public function AllianceMemberEntry( index:uint, member:AllianceMemberVO, allianceKey:String )
		{
			buttonMode = true;

			_allianceKey = allianceKey;

			onPromoteMember = new Signal(AllianceMemberVO);
			onDemoteMember = new Signal(AllianceMemberVO);
			onRemoveMember = new Signal(AllianceMemberVO);
			onShowProfile = new Signal(AllianceMemberVO);

			if ((index + 1) % 2 == 0)
			{
				_bg = PanelFactory.getScaleBitmapPanel('AllianceMemberRowBMD', WIDTH, HEIGHT, new Rectangle(15, 11, 2, 2));
			}

			var center:Number = HEIGHT * 0.5 - 9;

			_name = new Label(16, 0xf0f0f0, 213, 39, false);
			_name.constrictTextToSize = false;
			_name.align = TextFormatAlign.LEFT;

			_rank = new Label(16, 0xf0f0f0, 110, 39);
			_rank.constrictTextToSize = false;
			_rank.align = TextFormatAlign.LEFT;


			_level = new Label(16, 0xf0f0f0, 22, 39, false);
			_level.constrictTextToSize = false;
			_level.align = TextFormatAlign.CENTER;

			_promoteBtn = ButtonFactory.getBitmapButton('AlliancePromoteUpBMD', 0, 0, '', 0, 'AlliancePromoteRollOverBMD');
			_promoteBtn.addEventListener(MouseEvent.CLICK, onPromoteMemberClick, false, 0, true);

			_demoteBtn = ButtonFactory.getBitmapButton('AllianceDemoteUpBtnBMD', 0, 0, '', 0, 'AllianceDemoteRollOverBtnBMD');
			_demoteBtn.addEventListener(MouseEvent.CLICK, onDemoteMemberClick, false, 0, true);

			_removeBtn = ButtonFactory.getBitmapButton('AllianceRemoveUpBMD', 0, 0, '', 0, 'AllianceRemoveRollOverBMD');
			_removeBtn.addEventListener(MouseEvent.CLICK, onRemoveMemberClick, false, 0, true);

			addEventListener(MouseEvent.CLICK, onMemberClick, false, 0, true);

			if ((index + 1) % 2 == 0)
				addChild(_bg);

			addChild(_rank);
			addChild(_name);
			addChild(_level);
			addChild(_promoteBtn);
			addChild(_demoteBtn);
			addChild(_removeBtn);

			update(member);
		}

		public function update( member:AllianceMemberVO ):void
		{
			_member = member;

			_name.text = _member.name;
			_level.text = String(CommonFunctionUtil.findPlayerLevel(_member.xp));
			_rank.text = CommonFunctionUtil.getAllianceRankName(_member.rank);

			if (CurrentUser.alliance == _allianceKey && CurrentUser.allianceRank > AllianceRankEnum.MEMBER && member.key != CurrentUser.id)
			{
				if (member.rank < CurrentUser.allianceRank && (CurrentUser.allianceRank == AllianceRankEnum.LEADER || CurrentUser.allianceRank == AllianceRankEnum.OFFICER))
				{
					if (CurrentUser.allianceRank == AllianceRankEnum.LEADER && member.rank < AllianceRankEnum.LEADER)
						_promoteBtn.visible = true;
					else if (CurrentUser.allianceRank == AllianceRankEnum.OFFICER && member.rank < AllianceRankEnum.MEMBER)
						_promoteBtn.visible = true;
					else
						_promoteBtn.visible = false;

					if (member.rank > AllianceRankEnum.RECRUIT)
						_demoteBtn.visible = true;
					else
						_demoteBtn.visible = false;
				} else
				{
					_promoteBtn.visible = false;
					_demoteBtn.visible = false;
				}

				if (CurrentUser.allianceRank > member.rank)
					_removeBtn.visible = true;
				else
					_removeBtn.visible = false;

			} else
			{
				_promoteBtn.visible = false;
				_demoteBtn.visible = false;
				_removeBtn.visible = false;
			}

			layout();
		}

		private function layout():void
		{
			var center:Number  = HEIGHT * 0.5 - 9;

			_name.x = 7;
			_name.y = center;

			_rank.x = 177;
			_rank.y = center;

			_level.x = 306;
			_level.y = center;

			var btnXPos:Number = 358;
			if (_promoteBtn.visible)
			{
				_promoteBtn.x = btnXPos;
				_promoteBtn.y = 3;
				btnXPos = 394;
			}

			if (_demoteBtn.visible)
			{
				_demoteBtn.x = btnXPos;
				_demoteBtn.y = 3;
				btnXPos = 430;
			}

			if (_removeBtn.visible)
			{
				_removeBtn.x = btnXPos;
				_removeBtn.y = 5;
			}

		}

		private function onMemberClick( e:MouseEvent ):void
		{
			onShowProfile.dispatch(_member);
		}

		private function onPromoteMemberClick( e:MouseEvent ):void
		{
			e.stopImmediatePropagation();
			onPromoteMember.dispatch(_member);
		}

		private function onDemoteMemberClick( e:MouseEvent ):void
		{
			e.stopImmediatePropagation();
			onDemoteMember.dispatch(_member);
		}

		private function onRemoveMemberClick( e:MouseEvent ):void
		{
			e.stopImmediatePropagation();
			onRemoveMember.dispatch(_member);
		}

		public function get filterBy():String  { return _member.name.toLowerCase(); }
		public function get xp():int  { return _member.xp; }
		public function get rank():int  { return _member.rank; }

		override public function get height():Number  { return HEIGHT; }
		override public function get width():Number  { return WIDTH; }

		public function destroy():void
		{

			removeEventListener(MouseEvent.CLICK, onMemberClick);

			if (onPromoteMember)
				onPromoteMember.removeAll();

			onPromoteMember = null;

			if (onDemoteMember)
				onDemoteMember.removeAll();

			onDemoteMember = null;

			if (onRemoveMember)
				onRemoveMember.removeAll();

			onRemoveMember = null;

			_bg = null;

			if (_rank)
				_rank.destroy();
			_rank = null;

			if (_name)
				_name.destroy();
			_name = null;

			if (_level)
				_level.destroy();
			_level = null;

			if (_promoteBtn)
			{
				_promoteBtn.removeEventListener(MouseEvent.CLICK, onPromoteMemberClick);
				_promoteBtn.destroy();
			}
			_promoteBtn = null;

			if (_demoteBtn)
			{
				_demoteBtn.removeEventListener(MouseEvent.CLICK, onDemoteMemberClick);
				_demoteBtn.destroy();
			}
			_demoteBtn = null;

			if (_removeBtn)
			{
				_removeBtn.removeEventListener(MouseEvent.CLICK, onRemoveMemberClick);
				_removeBtn.destroy();
			}
			_removeBtn = null;
		}
	}
}
