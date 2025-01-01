package com.ui.hud.shared.engineering
{
	import com.enum.TypeEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.model.transaction.TransactionVO;
	import com.presenter.shared.IEngineeringPresenter;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class GroupButton extends Sprite
	{
		private var _actionSignal:Signal;
		private var _bottomLabel:Label;
		private var _button:BitmapButton;
		private var _image:ImageComponent;
		private var _index:int;
		private var _middleLabel:Label;
		private var _parentID:int;
		private var _presenter:IEngineeringPresenter;
		private var _topLabel:Label;
		private var _transaction:TransactionVO;
		private var _type:int;

		private var _speedUpText:String    = 'CodeString.Shared.SpeedUp'; //SPEED UP
		private var _noRepairText:String   = 'CodeString.EngineeringView.NoRepair'; //NO REPAIR
		private var _noResearchText:String = 'CodeString.EngineeringView.NoResearch'; //NO RESEARCH
		private var _noBuildText:String    = 'CodeString.EngineeringView.NoBuild'; //NO BUILD
		private var _noDefenseText:String  = 'CodeString.EngineeringView.NoDefense'; //NO DEFENSE

		public function init( parentID:int, type:int, index:int, actionSignal:Signal, presenter:IEngineeringPresenter ):void
		{
			_actionSignal = actionSignal;
			_index = index;
			_parentID = parentID;
			_presenter = presenter;
			_type = type;

			_bottomLabel = UIFactory.getLabel(LabelEnum.H4, 60, 28, 0, 57);
			_bottomLabel.textColor = 0xffe3b2;
			_bottomLabel.constrictTextToSize = true;
			_bottomLabel.text = "";

			_image = ObjectPool.get(ImageComponent);
			_image.init(60, 60);
			_image.center = _image.smoothing = true;

			_middleLabel = UIFactory.getLabel(LabelEnum.DEFAULT, 60, 60, 0, 0);
			_middleLabel.multiline = _middleLabel.bold = _middleLabel.constrictTextToSize = true;
			_middleLabel.textColor = 0x597181;
			_middleLabel.text = '';

			_topLabel = UIFactory.getLabel(LabelEnum.DEFAULT, 60, 30, 0, -18);
			_topLabel.fontSize = 15;
			_topLabel.text = "";

			showState();
		}

		public function addTransaction( transaction:TransactionVO ):void
		{
			_transaction = transaction;
			_presenter.loadTransactionIcon(transaction, _image.onImageLoaded);
			_bottomLabel.text = _speedUpText;
			_topLabel.setBuildTime(transaction.timeRemainingMS * .001, 2);
			showState();
		}

		public function updateTransactionTime():void
		{
			if (_transaction)
				_topLabel.setBuildTime(transaction.timeRemainingMS * .001, 2);
		}

		public function removeTransaction( transaction:TransactionVO ):void
		{
			_transaction = null;
			_image.clearBitmap();
			showState();
		}

		public function showState():void
		{
			if (!_transaction)
			{
				_bottomLabel.text = '';
				_topLabel.text = '';
			}

			var hasBuilding:Boolean;
			var middleText:String = '';
			switch (_type)
			{
				case GroupTray.REPAIR_BASE:
					middleText = _noRepairText;
					skin = ButtonEnum.FRAME_RED;
					break;
				case GroupTray.REPAIR_SHIP:
					middleText = _noRepairText;
					skin = ButtonEnum.FRAME_RED;
					break;
				case GroupTray.RESEARCH_A:
					middleText = _noResearchText;
					if (!_transaction)
					{
						hasBuilding = _presenter.getBuildingCount(_index == 0 ? TypeEnum.WEAPONS_FACILITY : TypeEnum.ADVANCED_TECH) > 0;
						skin = (true) ? ButtonEnum.FRAME_BLUE : ButtonEnum.FRAME_RED;
					} else
						skin = ButtonEnum.FRAME_BLUE;
					break;
				case GroupTray.RESEARCH_B:
					middleText = _noResearchText;
					if (!_transaction)
					{
						hasBuilding = _presenter.getBuildingCount(_index == 0 ? TypeEnum.DEFENSE_DESIGN : TypeEnum.SHIPYARD) > 0;
						skin = (true) ? ButtonEnum.FRAME_BLUE : ButtonEnum.FRAME_RED;
					} else
						skin = ButtonEnum.FRAME_BLUE;
					break;
				case GroupTray.SHIP_BUILD:
					middleText = _noBuildText;
					skin = ButtonEnum.FRAME_BLUE;
					break;
				case GroupTray.STARBASE_BUILD:
					middleText = (_index == 0) ? _noBuildText : _noDefenseText;
					skin = ButtonEnum.FRAME_BLUE;
					break;
			}
			_middleLabel.htmlText = (_transaction) ? '' : middleText;
			_middleLabel.y = (60 - _middleLabel.textHeight) * .5 - 4;
		}

		protected function onMouseClick( e:MouseEvent ):void  { _actionSignal.dispatch(_parentID, _type, _index, _transaction); e.stopPropagation(); }

		public function get image():ImageComponent  { return _image; }

		private function set skin( type:String ):void
		{
			if (_button)
			{
				_button.removeEventListener(MouseEvent.CLICK, onMouseClick);
				removeChild(_button);
				_button = UIFactory.destroyButton(_button);
			}
			if (type)
			{
				_button = UIFactory.getButton(type, 60, 60, 0, 20);
				_button.addChild(_bottomLabel);
				_button.addChild(_image);
				_button.addChild(_middleLabel);
				_button.addChild(_topLabel);
				_button.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
				addChild(_button);
			}
		}

		public function get transaction():TransactionVO  { return _transaction; }

		public function destroy():void
		{
			_actionSignal = null;
			_presenter = null;
			skin = null;
		}
	}
}
