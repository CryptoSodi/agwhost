package com.ui.hud.shared.engineering
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.event.TransactionEvent;
	import com.model.transaction.TransactionVO;
	import com.presenter.shared.IEngineeringPresenter;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.pulldown.DrawerComponent;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class EngineerGroup extends Sprite
	{
		private var _actionSignal:Signal;
		private var _button:BitmapButton;
		private var _count:int;
		private var _countLabel:Label;
		private var _drawer:DrawerComponent;
		private var _id:int;
		private var _numberBox:Bitmap;
		private var _presenter:IEngineeringPresenter;
		private var _repairCount:int;
		private var _transactionLookup:Dictionary;
		private var _trays:Vector.<GroupTray>;

		public function init( id:int, title:String, presenter:IEngineeringPresenter ):void
		{
			_presenter = presenter;
			_actionSignal = new Signal(int, int, int, TransactionVO);
			_transactionLookup = new Dictionary(false);
			_trays = new Vector.<GroupTray>;

			//main button
			_button = UIFactory.getButton(ButtonEnum.BLUE_A, 155, 41, 0, 0, title, LabelEnum.H3);
			_button.setMargin(36, 0);
			_numberBox = UIFactory.getBitmap(PanelEnum.NUMBER_BOX);
			_numberBox.x = _numberBox.y = 5;
			_countLabel = UIFactory.getLabel(LabelEnum.H3, _numberBox.width, _numberBox.height, _numberBox.x, _numberBox.y + 1);
			_count = _repairCount = 0;
			_countLabel.text = _count + "";
			_countLabel.textColor = 0xacd1ff;
			_button.addChild(_numberBox);
			_button.addChild(_countLabel);
			_button.addEventListener(MouseEvent.CLICK, onButtonClicked, false, 0, true);

			//drawer component
			_drawer = ObjectPool.get(DrawerComponent);
			_drawer.init(PanelEnum.CONTAINER_DOUBLE_NOTCHED_ARROWS, 152, 115, DrawerComponent.EXPANDS_DOWN, 5, 30);
			_drawer.useMask = true;
			_drawer.x = 1.5;
			_drawer.y = 40 - _drawer.height;

			_id = id;

			addChild(_drawer);
			addChild(_button);

			//set up the default trays based on the id of the group
			setupTrays();
		}

		public function addTransaction( transaction:TransactionVO ):int
		{
			if (!_transactionLookup.hasOwnProperty(transaction.id + transaction.type))
			{
				_count++;
				_countLabel.text = '' + _count;
				_transactionLookup[transaction.id + transaction.type] = transaction;
				for (var i:int = 0; i < _trays.length; i++)
					_trays[i].addTransaction(transaction);
				if (_id == EngineeringView.BUILD && transaction.type == TransactionEvent.STARBASE_REPAIR_BASE)
				{
					_repairCount++;
					_drawer.addElement(_trays[0]);
					_trays[1].y = 140;
					_drawer.dirty = true;
				}
				return 1;
			}
			return 0;
		}

		public function removeTransaction( transaction:TransactionVO ):int
		{
			if (_transactionLookup.hasOwnProperty(transaction.id + transaction.type))
			{
				_count--;
				_countLabel.text = '' + _count;
				delete _transactionLookup[transaction.id + transaction.type];
				for (var i:int = 0; i < _trays.length; i++)
					_trays[i].removeTransaction(transaction);
				if (_id == EngineeringView.BUILD && transaction.type == TransactionEvent.STARBASE_REPAIR_BASE)
				{
					_repairCount--;
					if (_repairCount <= 0)
					{
						_drawer.removeElement(_trays[0]);
						_trays[1].y = 0;
						_drawer.dirty = true;
					}
				}
				return 1;
			}
			return 0;
		}

		protected function setupTrays():void
		{
			var tray:GroupTray;
			switch (_id)
			{
				case EngineeringView.BUILD:
					//create the repair tray
					tray = ObjectPool.get(GroupTray);
					tray.init(id, GroupTray.REPAIR_BASE, _actionSignal, _presenter);
					_presenter.injectObject(tray);
					_trays.push(tray);

					//create the build tray
					tray = ObjectPool.get(GroupTray);
					tray.init(id, GroupTray.STARBASE_BUILD, _actionSignal, _presenter);
					_presenter.injectObject(tray);
					_trays.push(tray);
					_drawer.addElement(tray);
					break;
				case EngineeringView.DOCK:
					tray = ObjectPool.get(GroupTray);
					tray.init(id, GroupTray.REPAIR_SHIP, _actionSignal, _presenter);
					_presenter.injectObject(tray);
					_trays.push(tray);
					_drawer.addElement(tray);
					break;
				case EngineeringView.RESEARCH:
					//weapons / tech tray
					tray = ObjectPool.get(GroupTray);
					tray.init(id, GroupTray.RESEARCH_A, _actionSignal, _presenter);
					_presenter.injectObject(tray);
					_trays.push(tray);
					_drawer.addElement(tray);

					//defense / hulls tray
					tray = ObjectPool.get(GroupTray);
					tray.init(id, GroupTray.RESEARCH_B, _actionSignal, _presenter);
					_presenter.injectObject(tray);
					tray.y = 140;
					_trays.push(tray);
					_drawer.addElement(tray);
					break;
				case EngineeringView.SHIPYARD:
					tray = ObjectPool.get(GroupTray);
					tray.init(id, GroupTray.SHIP_BUILD, _actionSignal, _presenter);
					_presenter.injectObject(tray);
					_trays.push(tray);
					_drawer.addElement(tray);
					break;
			}
		}

		protected function onButtonClicked( e:MouseEvent ):void
		{
			if (!_presenter.hudEnabled)
				return;
			_actionSignal.dispatch(_id, -1, -1, null);
			e.stopPropagation();
		}

		public function updateTransactionTime():void
		{
			for (var i:int = 0; i < _trays.length; i++)
				_trays[i].updateTransactionTime();
		}

		public function addActionListener( listener:Function ):void  { _actionSignal.add(listener); }
		public function removeActionListener( listener:Function ):void  { _actionSignal.remove(listener); }

		public function set buttonText( v:String ):void  { _button.text = v; }
		public function set canDragExpand( v:Boolean ):void  { _drawer.canDragExpand = v; }
		public function get id():int  { return _id; }

		public function destroy():void
		{
			_actionSignal.removeAll();
			_actionSignal = null;

			_button.removeEventListener(MouseEvent.CLICK, onButtonClicked);
			_button = UIFactory.destroyButton(_button);
			_countLabel = UIFactory.destroyLabel(_countLabel);
			ObjectPool.give(_drawer);
			_drawer = null;
			_numberBox = UIFactory.destroyPanel(_numberBox);
			_presenter = null;
			_transactionLookup = null;

			for (var i:int = 0; i < _trays.length; i++)
				_trays[i].destroy();
			_trays.length = 0;
		}
	}
}
